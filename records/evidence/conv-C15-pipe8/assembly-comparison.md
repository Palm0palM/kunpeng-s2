# 2026-09-11 C3 / C15 静态汇编比较

仅阅读已取回的汇编、命令和日志，没有运行编译、测试、SSH 或题目程序。

## 证据与结论

- C3：`.runs/conv/C13-exttail/sve-correctness/raw/conv2d-sve.s`
- C15：`.runs/conv/sep11-checks/C15-pipe8/raw/conv2d-sve.s`
- 两份文件 **逐字节相同**，均为 44,122 字节；SHA-256：`0386b7863eb97bec15190335310a11ce5c939e9985ddcccc1de38cc2bd272030`。
- 整个 `conv_sve_prefix` 段也相同；段 SHA-256：`e54dfe04b503f1adc9481e7333a0065fd07b7d202eea6d4f135ad45606659ea8`。

在该 GCC 10.3.1 输出中，C15 的源码流式改写没有减少指令数、movprfx 或热点 spill；编译器已经把 C3 调度成相同的流式形态。任何这两份对应实现的观测耗时差不能归因于更少的静态指令，性能仍应按完整同环境测量判定。

## 主二步 kernel 循环

两份 `.L41` 从标签到回跳 `bgt .L41` 都是 56 条指令：

| 指令 | C3 | C15 |
| --- | ---: | ---: |
| fmul | 16 | 16 |
| fadd | 16 | 16 |
| ld1w | 9 | 9 |
| ld1rw | 2 | 2 |
| ext | 7 | 7 |
| add | 3 | 3 |
| lsl | 1 | 1 |
| cmp | 1 | 1 |
| bgt | 1 | 1 |
| 合计 | 56 | 56 |

主二步循环没有 `[sp, ...]` 访存，没有 `movprfx`，也没有 FMA；整段 prefix 没有 `movprfx`。函数有相同的 240 字节栈帧，序言/尾声及外层块处理保存恢复整数寄存器、指针和计数，不能把“热点无 spill”误写为整个函数完全不使用栈。

## 源码与编译条件

两份 probe.log 保存的算子 SHA-256 分别为：

- C3：`418191b0a5f8b5a97b219b2648df30132b935ae602e6a4c066cfadd8680554c8`
- C15：`9895bd9e0e0d71ff0f71dfcc6b25f389d46fb921aa3471562a5254c66988d1ab`

编译器均为 `gcc (GCC) 10.3.1`。汇编生成命令共有：`-O3 -std=c11 -fno-fast-math -ffp-contract=off -mcpu=generic -fopenmp -S conv2d.c -o conv2d-sve.s`。

C15 的命令额外有 `-D_DEFAULT_SOURCE -Wall -Wextra -DEXPECTED_ACC=8`，因此命令文本并非完全相同；算子源码不引用 EXPECTED_ACC，且最终完整汇编相同，未发现这些附加参数造成代码生成差异。未比较编译器二进制哈希，不将相同版本字符串扩大为已验证编译器二进制身份。
