"""Grouped submission tests; SSH and scheduler calls are always mocked."""
import hashlib
import importlib.util
import json
from pathlib import Path
import shlex
import subprocess
import sys
import tarfile
import tempfile
import unittest
from unittest.mock import patch


TOOLS = Path(__file__).resolve().parents[1] / "tools"
spec = importlib.util.spec_from_file_location("group_test_cluster", TOOLS / "cluster.py")
cluster = importlib.util.module_from_spec(spec)
spec.loader.exec_module(cluster)
spec = importlib.util.spec_from_file_location("cluster_group", TOOLS / "cluster_group.py")
group = importlib.util.module_from_spec(spec)
with patch.dict(sys.modules, {"cluster": cluster}):
    spec.loader.exec_module(group)


def result(code=0, stdout=b"", stderr=b""):
    return subprocess.CompletedProcess([], code, stdout, stderr)


class ClusterGroupTests(unittest.TestCase):
    def setUp(self):
        temporary = tempfile.TemporaryDirectory()
        self.addCleanup(temporary.cleanup)
        self.root = Path(temporary.name)
        config = self.root / "config.json"
        config.write_text(json.dumps({"host": "cluster.example.org", "user": "alice",
                                      "remote_root": "/home/alice/experiments"}))
        self.cfg = cluster.load_config(config)
        self.runs = []
        for name in ("C4 block 24", "C5 block 48"):
            run = self.root / name
            (run / "source").mkdir(parents=True)
            (run / "source/run.sh").write_text("#!/bin/bash\nexit 0\n")
            (run / "source/conv2d.c").write_text("int original = 1;\n")
            (run / "experiment.json").write_text(json.dumps({"problem": "conv", "settings": {}}))
            self.runs.append(run)

    def manifest(self, run):
        return json.loads((run / "cluster.json").read_text())

    def test_members_share_one_allocation_and_keep_independent_sources(self):
        calls, uploads, scripts = [], [], []

        def fake(argv, **kwargs):
            calls.append((argv, kwargs))
            self.assertNotIn("shell", kwargs)
            command = shlex.split(argv[-1])
            if "stdin" in kwargs:
                with tarfile.open(fileobj=kwargs["stdin"], mode="r:gz") as archive:
                    settings = json.load(archive.extractfile("remote-settings.json"))
                    self.assertEqual(settings["bench_repeats"], 3)
                    self.assertEqual(settings["environment"]["OMP_NUM_THREADS"], "38")
                    uploads.append(archive.extractfile("source/conv2d.c").read())
            if "input" in kwargs:
                scripts.append(kwargs["input"].decode())
            if command[0] == "dsub":
                self.assertTrue(all(self.manifest(r)["state"] == "submit_unknown" for r in self.runs))
                self.assertEqual(command[command.index("-R") + 1], "cpu=38,mem=24576")
                self.assertEqual(command[command.index("-a") + 1], "numa[count=1,distribution=pack]")
                return result(stdout=b"Job <1234> is submitted\n")
            return result()

        with patch.object(cluster.subprocess, "run", side_effect=fake):
            group.submit_group(self.cfg, self.runs)
        self.assertEqual(sum(shlex.split(a[-1])[0] == "dsub" for a, _ in calls), 1)
        self.assertEqual(len(uploads), 2)
        self.assertEqual(len(scripts), 1)
        manifests = [self.manifest(r) for r in self.runs]
        self.assertEqual({m["job_id"] for m in manifests}, {"1234"})
        self.assertEqual({m["state"] for m in manifests}, {"submitted"})
        self.assertEqual(len({m["group"] for m in manifests}), 1)
        self.assertEqual(len({m["remote_dir"] for m in manifests}), 2)
        self.assertEqual(scripts[0], group.group_script([m["remote_dir"] for m in manifests]))

    def test_member_failure_fails_group_and_preserves_later_member_run(self):
        directories = []
        for index, code in enumerate((0, 7, 0)):
            directory = self.root / ("member " + str(index) + "; ' literal")
            directory.mkdir()
            (directory / "remote_job.sh").write_text(f"#!/bin/bash\nprintf 'member-{index}\\n'\nexit {code}\n")
            directories.append(str(directory))
        completed = subprocess.run(["bash", "-c", group.group_script(directories)],
                                   text=True, capture_output=True, timeout=15)
        self.assertEqual(completed.returncode, 1)
        self.assertEqual(completed.stdout.splitlines(), ["member-0", "member-1", "member-2"])
        (Path(directories[1]) / "remote_job.sh").write_text("#!/bin/bash\nexit 0\n")
        completed = subprocess.run(["bash", "-c", group.group_script(directories)],
                                   text=True, capture_output=True, timeout=15)
        self.assertEqual(completed.returncode, 0)

    def test_reserved_member_and_repeated_member_never_connect(self):
        for state in ("submitted", "submit_unknown", "preparing", "upload_failed"):
            with self.subTest(state=state):
                (self.runs[1] / "cluster.json").write_text(json.dumps({"state": state}))
                with patch.object(cluster.subprocess, "run") as remote:
                    with self.assertRaises(cluster.ClusterError):
                        group.submit_group(self.cfg, self.runs)
                    remote.assert_not_called()
                self.assertFalse((self.runs[0] / "cluster.json").exists())
        with patch.object(cluster.subprocess, "run") as remote:
            with self.assertRaises(cluster.ClusterError):
                group.submit_group(self.cfg, [self.runs[0], self.runs[0]])
            remote.assert_not_called()

    def test_upload_failure_prevents_dsub_and_reserves_all_members(self):
        calls = []

        def fake(argv, **kwargs):
            calls.append(shlex.split(argv[-1]))
            return result(255, stderr=b"upload interrupted") if "stdin" in kwargs else result()

        with patch.object(cluster.subprocess, "run", side_effect=fake):
            with self.assertRaises(cluster.ClusterError):
                group.submit_group(self.cfg, self.runs)
        self.assertFalse(any(command[0] == "dsub" for command in calls))
        self.assertEqual({self.manifest(r)["state"] for r in self.runs}, {"upload_failed"})
        with patch.object(cluster.subprocess, "run") as remote:
            with self.assertRaises(cluster.ClusterError):
                group.submit_group(self.cfg, self.runs)
            remote.assert_not_called()

    def test_uncertain_submit_cannot_be_retried(self):
        uncertain = (result(stdout=b"Submission received"),
                     result(255, stdout=b"Job <1234> submitted"),
                     result(stdout=b"Job <1234> submitted\nJob <5678> submitted"),
                     subprocess.TimeoutExpired("ssh", 45))
        for reply in uncertain:
            with self.subTest(reply=reply):
                for run in self.runs:
                    (run / "cluster.json").unlink(missing_ok=True)

                def fake(argv, **kwargs):
                    if shlex.split(argv[-1])[0] == "dsub":
                        if isinstance(reply, Exception):
                            raise reply
                        return reply
                    return result()

                with patch.object(cluster.subprocess, "run", side_effect=fake):
                    with self.assertRaises((cluster.ClusterError, subprocess.TimeoutExpired)):
                        group.submit_group(self.cfg, self.runs)
                self.assertEqual({self.manifest(r)["state"] for r in self.runs}, {"submit_unknown"})
                self.assertTrue(all(self.manifest(r)["job_id"] is None for r in self.runs))
                with patch.object(cluster.subprocess, "run") as remote:
                    with self.assertRaises(cluster.ClusterError):
                        group.submit_group(self.cfg, self.runs)
                    remote.assert_not_called()

    def test_manifest_hashes_bind_uploaded_snapshot_after_live_edit(self):
        uploads = []

        def fake(argv, **kwargs):
            if "stdin" in kwargs:
                run = self.runs[len(uploads)]
                (run / "source/conv2d.c").write_text("edited during upload\n")
                with tarfile.open(fileobj=kwargs["stdin"], mode="r:gz") as archive:
                    source = archive.extractfile("source/conv2d.c").read()
                    uploads.append(source)
                self.assertEqual(self.manifest(run)["source_hashes"]["conv2d.c"],
                                 hashlib.sha256(source).hexdigest())
            if shlex.split(argv[-1])[0] == "dsub":
                return result(stdout=b"Job <1234> submitted\n")
            return result()

        with patch.object(cluster.subprocess, "run", side_effect=fake):
            group.submit_group(self.cfg, self.runs)
        self.assertEqual(uploads, [b"int original = 1;\n"] * 2)
        for run in self.runs:
            self.assertNotEqual(self.manifest(run)["source_hashes"], cluster.source_hashes(run / "source"))

    def test_scheduler_metacharacters_remain_single_argument(self):
        queue = "queue'; touch /tmp/SHOULD_NOT_EXIST; '"
        self.cfg["scheduler"]["queue"] = queue
        submitted = []

        def fake(argv, **kwargs):
            parsed = shlex.split(argv[-1])
            if parsed[0] == "dsub":
                submitted.append(parsed)
                self.assertEqual(parsed[parsed.index("-q") + 1], queue)
                self.assertNotIn("touch", parsed)
                self.assertEqual(argv[:3], ["ssh", "-o", "BatchMode=yes"])
                self.assertNotIn("shell", kwargs)
                return result(stdout=b"Job <1234> submitted\n")
            return result()

        with patch.object(cluster.subprocess, "run", side_effect=fake):
            group.submit_group(self.cfg, self.runs)
        self.assertEqual(len(submitted), 1)


if __name__ == "__main__":
    unittest.main()
