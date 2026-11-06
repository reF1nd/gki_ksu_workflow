<div align="center">

🌐 [English](README.md) &nbsp;|&nbsp; [简体中文](README_CN.md) &nbsp;|&nbsp; [日本語](README_JP.md) &nbsp;|&nbsp; [한국어](README_KO.md)

</div>

<div align="center">

# 🌀 GKI KSU Workflow

![License](https://img.shields.io/github/license/reF1nd/gki_ksu_workflow?style=flat-square&color=blue)
![Last Commit](https://img.shields.io/github/last-commit/reF1nd/gki_ksu_workflow?style=flat-square&color=green)
![Release](https://img.shields.io/github/v/release/reF1nd/gki_ksu_workflow?style=flat-square&color=orange)

![Android](https://img.shields.io/badge/Android-GKI-3DDC84?style=for-the-badge&logo=android&logoColor=white)
![Kernel](https://img.shields.io/badge/Kernel-6.1_~_6.12-2F363D?style=for-the-badge&logo=linux&logoColor=white)
![Architecture](https://img.shields.io/badge/Arch-arm64-blue?style=for-the-badge)
![CI](https://img.shields.io/badge/CI-GitHub_Actions-2088FF?style=for-the-badge&logo=githubactions&logoColor=white)

*用于编译和分发 GKI 内核的自动化 GitHub Actions CI/CD 流水线。*

</div>

---

## 🚀 概述

本仓库实现了一个统一的、配置驱动的构建编排系统，只需单次工作流触发，即可跨多个内核版本编译多种 **KernelSU** 变体。每个变体均封装在各自独立的 Job 中，最大化可维护性，简化故障隔离，并为未来的变体和内核版本实现无缝的水平扩展。

---

## ⚙️ 配置

所有内核版本相关的配置均集中在 [`.github/config/kernel_versions.json`](.github/config/kernel_versions.json) 中。触发工作流时只需提供 `kernel_version` 一个输入，即可驱动整个构建矩阵——包括内核版本、子版本、编译器、Rust 可用性以及 AnyKernel3 分支选择。

> [!NOTE]
> 本仓库继续保留 6.12.23 的默认编译、源码配置和所需补丁。

---

## 📦 构建变体

| 变体 | SUSFS | Droidspaces | Hook 类型 |
| :--- | :---: | :---: | :--- |
| [KowSU](https://github.com/KOWX712/KernelSU) | ❌ | ❌ | `Kprobes` |
| [KowSU-DS](https://github.com/KOWX712/KernelSU) | ❌ | ✅ | `Kprobes` |
| [KowSU-SUSFS](https://github.com/KOWX712/KernelSU) | ✅ | ❌ | `De-inlined` |
| [KowSU-SUSFS-DS](https://github.com/KOWX712/KernelSU) | ✅ | ✅ | `De-inlined` |
| [KernelSU-Next](https://github.com/KernelSU-Next/KernelSU-Next) | ❌ | ❌ | `Tracepoint` |
| [KernelSU-Next-DS](https://github.com/KernelSU-Next/KernelSU-Next) | ❌ | ✅ | `Tracepoint` |
| [KernelSU-Next-SUSFS](https://github.com/KernelSU-Next/KernelSU-Next) | ✅ | ❌ | `De-inlined` |
| [KernelSU-Next-SUSFS-DS](https://github.com/KernelSU-Next/KernelSU-Next) | ✅ | ✅ | `De-inlined` |
| [KernelSU-Official](https://github.com/tiann/KernelSU) | ❌ | ❌ | `Kprobes` |
| [KernelSU-Official-DS](https://github.com/tiann/KernelSU) | ❌ | ✅ | `Kprobes` |
| [KernelSU-Official-SUSFS](https://github.com/tiann/KernelSU) | ✅ | ❌ | `De-inlined` |
| [KernelSU-Official-SUSFS-DS](https://github.com/tiann/KernelSU) | ✅ | ✅ | `De-inlined` |
| [ReSukiSU](https://github.com/ReSukiSU/ReSukiSU) | ❌ | ❌ | `Manual` |
| [ReSukiSU-DS](https://github.com/ReSukiSU/ReSukiSU) | ❌ | ✅ | `Manual` |
| [ReSukiSU-SUSFS](https://github.com/ReSukiSU/ReSukiSU) | ✅ | ❌ | `De-inlined` |
| [ReSukiSU-SUSFS-DS](https://github.com/ReSukiSU/ReSukiSU) | ✅ | ✅ | `De-inlined` |
| [KernelSU-XX](https://github.com/backslashxx/KernelSU) | ❌ | ❌ | `Branch Link` |
| [KernelSU-XX-DS](https://github.com/backslashxx/KernelSU) | ❌ | ✅ | `Branch Link` |
| [KernelSU-XX-SUSFS](https://github.com/backslashxx/KernelSU) | ✅ | ❌ | `De-inlined` |
| [KernelSU-XX-SUSFS-DS](https://github.com/backslashxx/KernelSU) | ✅ | ✅ | `De-inlined` |

> \* **ReSukiSU 和 KernelSU-XX 的 Hook 类型：** 可分别通过 `resukisu_hook_mode` 与 `kernelsu_xx_hook_mode` 运行时配置。
> - `resukisu_hook_mode` — `manual`（默认）/ `tracepoint`
> - `kernelsu_xx_hook_mode`：
>   - `branch link hijacking` — KernelSU-XX 的默认值；通过 `CONFIG_KSU_HACK_ARM64_BRANCH_LINK` 扫描内核 text 段并直接覆写调用处跳转指令（`b`/`bl`）重定向到 Hook，无 trampoline 开销且兼容 ARM64 CFI
>   - `syscall table tampering` — 通过 `CONFIG_KSU_TAMPER_SYSCALL_TABLE` 直接修改 `sys_call_table` 系统调用表指针，避免间接跳转（`blr`）开销并兼容 Clang CFI
>   - `manual` — 通过 `scope-min-manual-hooks-v2.3.patch` 打入的手动 hook
> - `kernelsu_xx_kpatch_compat` — 配合 `branch link hijacking` 使用，为 KernelSU-XX 打入 KernelPatch 兼容修复（execve 回退与 syscall table mirror 跳过）

> [!TIP]
> **矩阵构建编排：** 矩阵始终为每个变体产出恰好 **1 个构件** — 启用的功能（Droidspaces 和/或 SUSFS）会应用到该单一构件上。选择全部 5 个变体时，每个内核版本的 **每个子版本产生 5 次构建**。从 `kernel_version` 下拉菜单中选择 `all` 将并行编译 6.1、6.6 和 6.12 的所有子版本，在默认配置下共 **45 个并发 Job**。

---

## 📱 管理器

请使用所选上游提供的管理器：[KowSU](https://github.com/KOWX712/KernelSU)、[KernelSU-Next](https://github.com/KernelSU-Next/KernelSU-Next)、[KernelSU Official](https://github.com/tiann/KernelSU)、[ReSukiSU](https://github.com/ReSukiSU/ReSukiSU) 或 [KernelSU-XX](https://github.com/backslashxx/KernelSU)。工作流保留各上游原有的管理器验证逻辑，不再打包通用管理器 APK。

---

## 🔧 Hook 类型参考

| 类型 | 机制与特性 |
| :--- | :--- |
| `Kprobes` | 运行时通过 kprobe 断点动态插桩内核函数。内核占用极小，兼容性广泛。 |
| `Tracepoint` | 接入内核的静态系统调用 tracepoint 基础设施（`sys_enter`/`sys_exit`），无需修改内核源码。 |
| `Inline` | 编译时通过直接嵌入内核子系统源码的 `#ifdef CONFIG_KSU_SUSFS` 代码块注入。使用 `static_key` 分支实现运行时切换。不依赖 kprobes 或 LSM Hook。硬编码于 VFS（`exec`、`open`、`stat`、`readdir`、`statfs`）、SELinux（`avc`、`hooks`、`services`）、input、mounts 与 procfs。 |
| `De-inlined` | 通过内核源码打补丁而非内联 `#ifdef CONFIG_KSU_SUSFS` 代码块来应用 SUSFS Hook。SUSFS 逻辑与核心内核子系统分离更清晰。 |
| `Manual` | 静态内核源码打补丁。编译时将自定义 Hook 注入核心内核子系统。 |
| `Branch Link Hijacking` | 扫描内核 text 段并直接覆写调用处跳转指令（`b`/`bl`）重定向至 Hook，规避 trampoline 开销且符合 ARM64 Clang CFI 规范。通过 `CONFIG_KSU_HACK_ARM64_BRANCH_LINK` 启用。 |
| `Syscall Table Tampering` | 高性能系统调用表篡改方案，直接修改 `sys_call_table` 中用于 sucompat（如 `sys_execve` 等）与 `sys_reboot` 的函数指针，避免间接跳转（`blr`）开销且符合 Clang CFI 规范。通过 `CONFIG_KSU_TAMPER_SYSCALL_TABLE` 启用。 |

---

## 🧩 附加功能

| 功能 | 描述 |
| :--- | :--- |
| **内核版本** | 选择 `6.1`、`6.6`、`6.12` 或 `all` 来编译单个或全部内核版本。子版本、修订版本、编译器与 Rust 配置均从集中配置中自动解析。 |
| **源码镜像** | 支持在 Google 官方 AOSP 镜像与自建镜像之间进行选择，用于内核源码和工具链下载。 |
| **SUSFS 模块** | 当启用 SUSFS 时，自动获取最新的 [susfs4ksu-module](https://github.com/sidex15/susfs4ksu-module) 并在发布说明中附上下载链接。单个 `susfs_commit` 输入控制所有变体的 SUSFS 版本。 |
| **KSU 工具箱** | 自动从 nightly.link 获取最新的 [ksu_toolkit](https://github.com/backslashxx/ksu_toolkit) 模块，并在发布说明中附上下载链接。 |
| **Droidspaces** | 通过 [Droidspaces-OSS](https://github.com/ravindu644/Droidspaces-OSS) 提供容器支持 — SYSVIPC、IPC_NS、PID_NS、DEVTMPFS、NTSync 与网络。按变体通过 `use_droidspaces` 开关控制。 |
| **Re:Kernel(-X)** | 集成的 [Re:Kernel](https://github.com/Sakion-Team/Re-Kernel) 与 [Re:Kernel-X](https://github.com/myflavor/ReKernel-X) 模块直接编译进内核。提供 tombstone 冻结恢复、网络触发解冻与 binder 异步清理。通过 `use_rekernel` 开关控制。 |
| **VPNHide Next** | 通过树内 kpatch（`CONFIG_VPNHIDE=y`）集成 [VPNHide Next](https://github.com/soranerai/vpnhide_next_backend)，在内核层隐藏 VPN 网络接口、路由规则和套接字描述符，无需依赖动态 LKM。在发布说明中附上配套 `vpnhide-bridge.zip` 模块与管理器 APK（`vpnhide.apk`）的上游发布下载链接。通过 `use_vpnhide` 开关控制。 |
| **NoMount** | 集成的 [NoMount](https://github.com/maxsteeel/nomount) 直接编译进内核（`CONFIG_NOMOUNT=y`），这是一个 VFS 路径重定向框架，无需创建挂载、也不改动 `/proc/mounts` 即可注入和隐藏模块文件。在发布说明中附上配套 `NoMount-*.zip` 元模块的上游发布下载链接。通过 `use_nomount` 开关控制。 |
| **fgetpriority** | 集成的 [fgetpriority](https://github.com/aerath-stuff/fgetpriority) 直接编译进内核（`CONFIG_FGETPRIORITY=y`），对来自应用的 `getpriority` / `setpriority` / `ioprio_get` / `ioprio_set` 探测隐藏其他应用 UID。无需安装模块。通过 `use_fgetpriority` 开关控制。 |
| **Unicode 绕过修复** | 始终启用。修补内核 Unicode 规范化，以防止通过非标准 Unicode 编码进行文件系统绕过攻击。 |
| **CVE 修复** | 始终启用。检测内核源码中的 CVE-2026-43499（rtmutex）与 CVE-2026-64560（sighand / POSIX CPU timers），并在缺失时自动应用修复；各子版本的结果显示在发布说明中。 |
| **网络与文件系统** | 始终启用。TCP BBR、IPSET、增强型 NAT（IPv6 NAT 与 REDIRECT）以及 TMPFS xattr / POSIX ACL。 |
| **ADIOS I/O 调度器** | 可选集成 [ADIOS](https://github.com/firelzrd/adios)，并作为 kernel 6.6 和 6.12 构建的内置默认多队列 I/O 调度器。通过 `use_adios` 开关启用；kernel 6.1 保持不变。 |
| **LZ4/ZSTD ZRAM 后端** | 可选将内核中的 LZ4 与 ZSTD 实现更新为官方 LZ4 1.10.0 与 Zstandard 1.5.7 版本，并为内核 6.12（仅在 6.12.23 上测试）启用 ZRAM 后端支持。通过 `use_lz4_zstd` 开关控制；6.1 与 6.6 构建保持不变。 |
| **Ccache** | 编译器缓存集成，配备 60 秒依赖安装等待保护，确保跨工作流运行的健壮加速增量重建。 |
| **伪装构建元数据** | 可为编译出的镜像自定义 `kernel name`、`build timestamp`、`user` 与 `host` 字符串。 |
| **额外功能与修复** | 为对应变体应用 [midori01/KernelSU](https://github.com/midori01/KernelSU) 各分支顶部携带的额外功能与修复提交。通过 `use_extra_features` 开关控制。 |
| **KSU 调试** | 以 `CONFIG_KSU_DEBUG=y` 进行编译，并上传经 zstd 压缩的 `vmlinux` 构建产物以供 eBPF 调试。通过 `ksu_debug` 开关控制。 |
| **上游同步** | 构建前更新 `kernel_versions.json` 中的内核版本与源码，并从上游重新生成 SUSFS 补丁。通过 `sync_upstream` 开关控制。 |
| **发布类型** | `release` 发布正式版本并为每个内核版本保留最新 2 个发布，`pre-release` 发布预发布版本，`no-release` 仅上传构建产物。 |

---

## ✅ 已测试设备

以下设备已确认可使用本工作流构建的内核：

| 品牌 | 型号 |
| :--- | :--- |
| Google | Pixel 7/8/9/10/11 系列 (Tensor) |
| Xiaomi | Xiaomi 17 系列 (Snapdragon) |
| Xiaomi | REDMI K90 Pro Max (Snapdragon) |
| Xiaomi | POCO F8 Ultra (Snapdragon) |
| Tecno | Tecno Camon 40 Pro 4G (Helio) |
| Motorola | Moto Edge 70 Max (Snapdragon) |
| Lenovo | Legion Y70 2026 (Snapdragon) |
| Lenovo | Legion Y700 Infinite (Snapdragon) |

> [!NOTE]
> **兼容性说明：**
> - 以上设备均运行 Android 16+ 并搭载 GKI 内核（6.1/6.6/6.12）
> - SUSFS 与 Droidspaces 功能已在所有设备系列上完成测试
> - 原厂系统用户建议通过所选 KernelSU 变体提供的管理器或 Kernel Flasher 刷入内核

> [!TIP]
> **你的设备不在列表中？**
> 如果你已在其他设备上成功测试内核，欢迎提交 Issue 或 Pull Request 将其加入列表！

---
