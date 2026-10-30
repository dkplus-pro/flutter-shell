# 00 · 项目总览与决策记录

> 状态：设计定稿（2026-10-31），**尚未实现**  
> 读者：后续执行编码的模型/工程师  
> 本文是范围与决策的唯一来源。架构见 `01-architecture.md`，桥接契约见 `02-bridge-contract.md`，实施步骤见 `03-implementation-plan.md`，验收见 `04-acceptance.md`，编码规范见仓库根目录 `AGENTS.md`。

## 1. 项目定位

一个 **Flutter 壳工程（Shell）**：本身不含业务，用于验证并固化「Flutter 页面 + 原生能力桥接 + 可持续扩展的工程底座」。

- **Android**：本轮必须完整实现并在模拟器上验收。
- **iOS**：保留 Flutter 脚手架与 Pigeon 生成的 Swift 桩，本轮**不验收**（开发机未安装完整 Xcode）。
- **演示内容**：Hello World 页面 + 桥接演示页（系统信息、原生事件流、原生页面往返）。
- **交付形态**：可编译、可运行、可回归的仓库，以及给后续编码模型使用的分阶段实施文档。

## 2. 目标

| 编号 | 目标 | 判定方式 |
| --- | --- | --- |
| G1 | Android 壳可运行，iOS 工程结构不被破坏 | 模拟器启动；Android debug/release 构建成功；iOS 仅静态结构检查 |
| G2 | 良好的目录架构 | Monorepo + 包边界 + 分层规则，且由 `tool/check_imports.sh` 机器校验 |
| G3 | 良好的扩展性 | 新增页面、桥接 API、原生能力、语言、环境变量都有固定路径与协议，见 `01-architecture.md` 第 18 节 |
| G4 | 良好的复用性 | `app_core`、`app_ui`、`native_bridge` 独立成包；桥接实现是独立 Flutter Plugin 模块 |
| G5 | 良好的性能基线 | release 构建可用；启动、首帧、构建体积有实测记录；无主线程阻塞式桥接调用 |
| G6 | Native Bridge 可供 Flutter 使用 | Pigeon 方法调用 + 事件流 + 原生 → Flutter 回调三条链路全部跑通 |
| G7 | 规范可执行 | `AGENTS.md` 含依赖边界、代码规范、codegen 规则、测试/性能/安全要求、完成定义 |

## 3. 非目标（v0 明确不做）

- 任何真实业务功能、登录、账号、推送、支付、埋点上报。
- 真实后端接口调用；网络层只提供接口与可测试的占位实现。
- iOS 的编译与运行验收；本轮只生成 Swift 桩，允许未验证。
- 原生复杂 UI、原生设计系统；原生页面仅用于验证宿主与回传链路。
- 多环境 product flavor、应用商店发布、正式签名、Crash 平台接入。
- FFI/C++ 共享核心、Pigeon Native Interop 实验能力。
- 性能压测平台、CI 真机矩阵、iOS CI。

## 4. 已锁定决策

| 编号 | 决策 | 理由 | 代价 / 约束 |
| --- | --- | --- | --- |
| DEC-001 | 桥接机制使用 **Pigeon 29.1.0**（platform channels），不用手写 MethodChannel，不引入 FFI | 类型安全、编译期发现接口漂移、原生支持方法/事件流/反向回调 | 改协议必须重新生成；Dart 与 Kotlin/Swift 生成物必须同一 Pigeon 版本、同批提交 |
| DEC-002 | **轻量 Monorepo**：`apps/shell_app` + `packages/{app_core, app_ui, native_bridge}`，使用 **pub workspace**，不引入 Melos | 包边界强制复用，依赖解析集中，构建链短 | 需要根 `pubspec.yaml` 与各成员 `resolution: workspace`；脚本自行维护 |
| DEC-003 | Android 原生桥接实现为 **Flutter Plugin 包 `native_bridge`**，其 `android/` 是独立 Gradle Library 模块（`:native_bridge`），由 Flutter 工具自动纳入构建 | 保持「`:app` + 独立桥接模块」的边界；Pigeon Dart/Kotlin/Swift 生成物同包共存；插件生命周期、ActivityAware、embedding 依赖由官方模板处理，避免手写 Gradle 依赖 | 不手工改 `MainActivity`；模块名是 `:native_bridge`，不是手写 `include(":nativebridge")` |
| DEC-004 | Flutter 侧按 feature 分层；状态管理用 **Riverpod 3 + riverpod_generator**（`@riverpod` 代码生成） | 依赖注入与状态统一；生成器提供类型安全 Provider；与 autoDispose 生命周期契合 | 多一条 build_runner 生成链；生成文件不得手改 |
| DEC-005 | UI 采用 **Material 3 + `app_ui` 设计令牌/基础组件 + go_router** | 壳需要可扩展的页面基座与统一视觉入口 | 业务组件不得下沉到 `app_ui`；路由集中在 app 层 |
| DEC-006 | 国际化使用 **flutter gen-l10n + ARB**，内置 `en` / `zh` | 框架自带，无额外生成依赖；后续语言可增量添加 | 所有用户可见文案必须进 ARB；生成目录禁止手改 |
| DEC-007 | 环境配置使用 **`--dart-define=APP_ENV=dev\|prod`**，v0 不建 Android product flavor | 壳阶段避免 Gradle flavor 与签名矩阵复杂度；Dart 侧统一读取 | 发布构建必须显式传 `APP_ENV=prod`；后续需要多渠道时再评估 flavor（见 `01` 第 18 节） |
| DEC-008 | 网络/存储只做**抽象 + 占位实现**：`ApiClient`（Dio）与 `KeyValueStore`（shared_preferences），v0 无业务调用 | 先把分层和接线方式立住，避免业务接口污染壳工程 | 必须提供单元测试证明错误映射与读写可用，不能是空壳 |
| DEC-009 | 桥接演示固定为三条链路：`getSystemInfo` 方法、1Hz tick 事件流、原生 Activity 往返（FlutterApi 回传） | 覆盖双向通信与原生 UI 宿主，正好匹配“壳”的定位 | 原生演示页与回传代码属于可替换演示资产；真实原生能力应按同一模式新增 |
| DEC-010 | iOS 保留 app/plugin 脚手架、生成 Swift 桩，本轮不编译不验收 | 开发机无完整 Xcode；先锁定接口与目录 | 文档必须标注“未验证”，不得声称 iOS 可用 |
| DEC-011 | 应用标识统一为 **`com.dk.fluttershell`**；插件 Android namespace 为 `com.dk.fluttershell.bridge` | 避免发布前改包名 | iOS bundle id 同步为 `com.dk.fluttershell`；插件 Pod 名仍为 `native_bridge` |
| DEC-012 | 工程脚本放 `tool/`，CI 使用 **GitHub Actions**；CI 与本地执行同一批脚本 | 可重复、可审计；flash 模型不靠临时命令 | 仓库尚无远程，workflow 只能做本地静态校验，需在验收中如实标注 |
| DEC-013 | Android baseline：**compileSdk 36 / targetSdk 36 / minSdk 24 / JDK 17**；原生演示页用 **Jetpack Compose**（BOM 2026.09.00） | 与 Flutter 3.47.9 默认值一致；Compose 是现代原生 UI 基座 | Flutter 3.47.9 模板为 AGP 9.1.0 + Kotlin 2.4.0（AGP 内置 Kotlin）；Compose 编译器插件版本必须等于模板 Kotlin 版本；Gradle 以模板 wrapper 为准 |
| DEC-014 | 文档分层：`00` 范围/决策、`01` 架构、`02` 桥接契约、`03` 实施计划、`04` 验收；规范写入根 `AGENTS.md`；生成代码与 `pubspec.lock` 一律提交 | flash 模型可按阶段执行；CI 可检查 codegen 漂移 | 文档变更必须与代码同提交；不得出现未记录的架构改动 |
| DEC-019 | `core/router/app_router.dart` 允许 import feature 页面；`check_imports.sh` 对 R3 显式放行该文件 | `01` §3 将 router 放在 `core/router/`，而 R3 禁止 core→features；路由的职责就是把路径映射到页面，二者冲突。取「文档树优先 + 检查脚本显式例外」，例外面最小化（仅此一个文件，且仅 R3） | 其余 core 代码仍禁止 import features |
| DEC-020 | `dart format` 页宽统一 **80**（03 §1.2 初稿写 100） | very_good_analysis 11 的 `lines_longer_than_80_chars` 与 formatter.page_width 100 互相矛盾，80 列是 lint 唯一兼容值；AGENTS 禁止关规则 | 根 analysis_options.yaml 已改为 80 |
| DEC-017 | Compose BOM 使用 **2025.09.01**（而非版本矩阵初稿的 2026.09.00），其余 DEC-013 值不变 | BOM 2026.09.00 解析出的 `material-ripple-android:1.12.1`、`foundation-android:1.12.1` 等要求 compileSdk ≥37，而 DEC-013 锁定 compileSdk 36 且 AGP 9.1.0 最高支持 36；Gradle 构建实测失败 | 保持 compileSdk 36；material3/ui 由 BOM 2025.09.01 解析（Compose 1.9.x 线）；activity-compose 1.13.0、coroutines 1.11.0 维持不变 |
| DEC-018 | iOS 生成物路径：`packages/native_bridge/ios/native_bridge/Sources/native_bridge/Generated/ShellApi.g.swift`（SPM 模板） | Flutter 3.47.9 插件模板使用 SPM 布局（podspec source_files 覆盖 `native_bridge/Sources/native_bridge/**/*`） | tool/gen.sh 用该路径变量固化 |

| DEC-015 | `build_runner` 使用 **2.16.2**（而非版本矩阵初稿的 2.17.1） | `build_runner >=2.17.1` 依赖 `build >=5`，与 `riverpod_generator 4.0.9`（`build >=3 <5`）不可解析；pub 解析结果取 2.16.2 | 后续升级 build_runner 需先确认 riverpod_generator 的 build 约束 |
| DEC-016 | Dart 未命名构造统一使用声明式构造语法 `const new(...)` / `new _(...)`，命名构造仍用 `ClassName.name` | very_good_analysis 11.0.0 的 `unnecessary_type_name_in_constructor` 强制该风格；其自动修复对经典写法产出错误代码，已人工验证新语法在 Dart 3.13 合法 | 文档 03/AGENTS 中的示例代码片段（`const AppFailure(...)` 等）按此约定执行 |

## 5. 版本矩阵（2026-10-31 实测查询）

> 这些版本是 P0/P1 的输入。若 `pub get` 出现不可解析冲突，**停止并记录**，只允许按 pub 解析结果调整并在本文追加决策；禁止静默降级或猜测版本。

| 组件 | 版本 | 备注 |
| --- | --- | --- |
| Flutter | 3.47.9（stable） | 来源：`releases_macos.json`；Dart 3.13.7 |
| FVM | brew 最新稳定版 | `.fvmrc` 固定 Flutter 3.47.9，提交 `.fvmrc`，忽略 `.fvm/` |
| JDK | Temurin 17 | AGP 8.x 要求；`flutter config --jdk-dir` 指向它 |
| Android SDK | compileSdk 36 / targetSdk 36 / minSdk 24 | Flutter 3.47.9 `FlutterExtension` 默认值 |
| Pigeon | 29.1.0 | `native_bridge` dev_dependency |
| flutter_riverpod | 3.4.3 | 运行时 |
| riverpod_annotation | 4.0.7 | 依赖 `riverpod 3.4.3` |
| riverpod_generator | 4.0.9 | 依赖 `riverpod_annotation 4.0.7` |
| build_runner | 2.16.2 | dev（DEC-015 调整） |
| go_router | 18.1.2 | |
| dio | 5.11.1 | 仅占位网络实现 |
| shared_preferences | 2.5.6 | 仅占位存储实现 |
| logging | 1.3.0 | 结构化日志 |
| very_good_analysis | 11.0.0 | 根 `analysis_options.yaml` |
| intl | 当前 0.20.3（以 `flutter_localizations` 的约束为准） | 不要单独锁死版本；pub 冲突时以 Flutter SDK 解析结果为准 |
| Compose BOM | 2025.09.01 | 原生演示页（DEC-017 调整） |
| activity-compose | 1.13.0 | 稳定版 |
| kotlinx-coroutines-android | 1.11.0 | 事件流与 FlutterApi 回调 |
| AGP / Kotlin | 9.1.0 / 2.4.0（Flutter 3.47.9 模板值） | Gradle 以模板 wrapper 为准；AGP 9 内置 Kotlin；Compose 编译器插件版本 = Kotlin 版本；P1 记录实际值 |

## 6. 需求 → 产物映射

| 需求 | 产物 | 验收 |
| --- | --- | --- |
| 良好目录架构 | `01` 第 3/4 节 + `tool/check_imports.sh` | 依赖边界检查通过 |
| 良好扩展性 | `01` 第 18 节扩展手册 + `AGENTS.md` 新增流程 | 能按手册新增页面/API 而不改架构 |
| 良好复用性 | 4 个 workspace 包 + 独立桥接插件 | 包依赖图符合规则；桥接包可被其他 app 引用 |
| 良好性能 | `01` 第 14 节 + release 构建 + 启动实测 | 构建成功；记录启动/体积基线；无主线程阻塞 |
| Flutter 页面 | Hello 页 + 桥接演示页 | 模拟器可见、可交互、支持中英文 |
| Native Bridge | `02` 契约 + `native_bridge` 插件 | 方法/事件流/反向回调三条链路 |
| 开发规范 | 根 `AGENTS.md` | 内容覆盖边界、codegen、测试、性能、安全、Git、DoD |

## 7. 成功标准（摘要）

完整清单见 `04-acceptance.md`。摘要：

1. `bash tool/bootstrap.sh`、`bash tool/gen.sh`、`bash tool/check.sh`、`bash tool/test.sh` 全部通过。
2. `cd apps/shell_app/android && ./gradlew testDebugUnitTest` 通过（含 `:native_bridge` 单测）。
3. 代码生成后 `git status --porcelain` 为空（生成物已提交且无漂移）。
4. `flutter build apk --debug --dart-define=APP_ENV=dev` 与 release 命令均成功。
5. 模拟器上：Hello 页 → 桥接页 → 系统信息 / ticker 递增 / 原生页确认回传，全部可见。
6. `docs/evidence/` 中每个阶段都有真实命令输出与截图路径；未验证项（iOS、远程 CI）明确列出。

## 8. 术语

| 术语 | 含义 |
| --- | --- |
| HostApi | Dart 调用原生（`@HostApi`） |
| FlutterApi | 原生调用 Dart（`@FlutterApi`） |
| EventChannelApi | Pigeon 生成的事件通道，Dart 侧表现为 `Stream<T>` |
| IDL | `packages/native_bridge/pigeons/shell_api.dart`，桥接契约唯一来源 |
| 生成物 | `*.g.dart`、`*.g.kt`、`*.g.swift`、`lib/l10n/generated/**`，禁止手改，必须提交 |
| 桥接模块 | `packages/native_bridge`（Flutter Plugin）及其 Android Gradle 模块 `:native_bridge` |
| 演示原生页 | `NativeInfoActivity`（Compose），由桥接方法启动并通过 FlutterApi 回传结果 |
| 基准/基线 | 性能实测记录，v0 只记录不设硬阈值（模拟器噪声大） |
