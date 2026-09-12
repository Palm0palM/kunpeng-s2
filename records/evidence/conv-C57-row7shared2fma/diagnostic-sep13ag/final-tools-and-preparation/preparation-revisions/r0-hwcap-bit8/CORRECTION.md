# Preexecution correction r1

Independent review found that the original draft used HWCAP bit8 (ATOMICS) instead of bit22 (SVE). Root verified Linux UAPI hwcap.h line46 at https://raw.githubusercontent.com/torvalds/linux/master/arch/arm64/include/uapi/asm/hwcap.h and corrected the one constant before any import, execution, upload, reservation or job. The candidate source itself already uses the platform HWCAP_SVE macro and never had this issue.

Original r0 wrapper, first manifests/prepared and original diff are retained byte-for-byte here. Current transport wrapper and corresponding manifest association are explicit revision1; this is not a silent refresh of any submitted or returned evidence. All four candidate files and driver are unchanged.
