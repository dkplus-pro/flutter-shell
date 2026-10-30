# Flutter Shell

一个 **Android 优先**的 Flutter 壳工程：不含业务，用于验证并固化「Flutter 页面 + 原生能力桥接 + 可持续扩展的工程底座」。

- **状态**：v0 已实现并通过模拟器验收（2026-10-31）。阶段记录见 `docs/evidence/p0..p8`。
- **包名**：`com.dk.fluttershell`
- **技术栈**：Flutter 3.47.9 / Dart 3.13.7、Pigeon 29.1.0、Riverpod 3 + riverpod_generator、go_router、Material 3、Jetpack Compose（原生演示页）、AGP 9.1.0 + Kotlin 2.4.0、Compose BOM 2025.09.01（DEC-017）。

## 文档

| 文档 | 内容 |
| --- | --- |
| [docs/00-overview.md](docs/00-overview.md) | 范围、非目标、已锁定决策（DEC-001..020）、版本矩阵 |
| [docs/01-architecture.md](docs/01-architecture.md) | Monorepo、分层、桥接、性能、安全、扩展手册 |
| [docs/02-bridge-contract.md](docs/02-bridge-contract.md) | Pigeon 契约、线程、错误码、原生页协议、验收用例 |
| [docs/03-implementation-plan.md](docs/03-implementation-plan.md) | P0–P8 逐阶段步骤、命令、Gate、证据要求 |
| [docs/04-acceptance.md](docs/04-acceptance.md) | 验收清单、真实链路、性能基线、DoD |
| [AGENTS.md](AGENTS.md) | 开发规范（目录/依赖/代码/codegen/测试/性能/安全/Git） |

## 目标结构

```text
apps/shell_app          Flutter 宿主（Android 验收，iOS 脚手架）
packages/app_core       环境、日志、错误、网络/存储抽象
packages/app_ui         主题、设计令牌、基础组件
packages/native_bridge  Pigeon 契约 + Dart 封装 + Android/iOS 插件
tool/                   初始化、生成、检查、测试、构建脚本
docs/                   决策/架构/契约/计划/验收/证据
```

## 快速开始

```bash
# 工具链：FVM + Flutter 3.47.9（见 .fvmrc）、JDK 17、Android SDK 36（详见 docs/03 P0 与 docs/evidence/p0-toolchain.md）
cd <repo>
bash tool/bootstrap.sh          # pub get + 全部代码生成
bash tool/check.sh              # 格式化 + 依赖边界 + 四包 analyze
bash tool/test.sh               # Dart 测试（app_core/app_ui/native_bridge/shell_app）
bash tool/test_native_android.sh # Gradle JVM 单测（SystemInfoMapper）
bash tool/build_android.sh --release  # APP_ENV=prod + obfuscate + split-per-abi
bash tool/run_android.sh emulator-5554
bash tool/e2e_android.sh emulator-5554
```

演示链路：Home → Bridge Demo：系统信息（方法调用）、1Hz 原生 ticker（事件流，离开页面自动停止）、原生页往返（FlutterApi 回传，Confirm/Cancel/返回键）。

## 已知限制

- iOS 仅保留脚手架与 Swift 桩，本轮**不编译、不验收**。
- CI workflow 已就绪，但仓库尚无远程，未在 GitHub 实际运行。
- v0 release 使用 debug 签名，不可发布。
- 桥接演示页与原生页属于演示资产，接真实业务时按 `docs/01` 第 18 节替换/迁移。
- 网络/存储为占位抽象，无真实业务调用。
