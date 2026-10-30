# AGENTS.md · 开发规范

> 项目：Flutter 壳工程（Android 优先，iOS 桩）  
> 规范文件名按 DEC-014 使用 `AGENTS.md`（通用 agent 约定）；与 `docs/00` 的决策一致。  
> 本文件对**所有后续编码者（人或模型）**生效。与代码冲突时，先改文档再改代码，不允许反向漂移。

## 1. 文档优先级

1. `docs/00-overview.md`：范围、非目标、已锁定决策、版本矩阵；
2. `docs/02-bridge-contract.md`：桥接契约（唯一来源是 Pigeon IDL）；
3. `docs/01-architecture.md`：分层、依赖、线程、性能、安全；
4. `docs/03-implementation-plan.md`：阶段与执行顺序；
5. `docs/04-acceptance.md`：验收口径与证据要求；
6. 本文件：日常编码规范。

冲突处理：以编号更小的文档为准；若确实需要偏离，先在 `docs/00` 追加决策并等待确认，**不得直接改代码**。

## 2. 不可协商的规则

1. 只通过 **Pigeon** 做 Flutter ↔ Native 通信；禁止手写 `MethodChannel` / `EventChannel`（生成代码内部除外）。
2. **禁止手改生成物**：`*.g.dart`、`*.g.kt`、`*.g.swift`、`apps/shell_app/lib/l10n/generated/**`。
3. 修改桥接接口必须「改 IDL → `bash tool/gen.sh` → 实现三端 → 更新文档/测试」，同一提交完成。
4. 依赖方向：`app → packages`；`packages` 不得依赖 app，不得依赖 Riverpod。
5. feature 之间不得互相 import；跨 feature 共享逻辑先提升为包（并记录决策）。
6. 用户可见文案必须进 ARB；禁止在 Flutter UI 中硬编码中文/英文文案。
7. 禁止 `print` / `debugPrint` 进入提交；统一 `AppLogger`。
8. 首帧前不做桥接调用；不在 `build()` 中发请求、做 IO 或解析大 JSON。
9. 不提交秘密：keystore、`key.properties`、token、真实 API Key 一律禁止。
10. 不自动 `git push`、不强推、不改远程；提交前检查暂存内容。
11. 不做本文档范围外的重构/抽象/依赖升级；需要时先改决策文档。
12. release 构建不得声称可发布（v0 使用 debug 签名）。

## 3. 目录与职责

```text
apps/shell_app/                 # 唯一组合根；页面、路由、provider 接线
packages/app_core/              # env、日志、错误、网络/存储接口与实现（无 Riverpod、无 UI）
packages/app_ui/                # 主题、tokens、基础组件（无业务、无 Riverpod）
packages/native_bridge/         # Pigeon IDL、Dart 封装、Android/iOS 插件实现
docs/                           # 决策、架构、契约、计划、验收、证据
tool/                           # 唯一可重复执行入口
.github/workflows/ci.yml        # CI 调用 tool/ 脚本
```

规则：

- 新代码先判断归属：页面/编排 → app；可复用基础设施 → `app_core`；可复用 UI → `app_ui`；桥接 → `native_bridge`。
- 不新增「utils」「common」「helpers」大杂烩；按领域命名文件。
- 新包/新 Gradle 模块必须先更新 `docs/00` 与 `docs/01`。

## 4. 依赖边界（对应 `tool/check_imports.sh`）

| 规则 | 内容 |
| --- | --- |
| R1 | `packages/**` 禁止 `package:fluttershell/` |
| R2 | `packages/**` 禁止 `package:flutter_riverpod` / `package:riverpod` |
| R3 | `apps/shell_app/lib/core/**` 禁止导入 `features/**` |
| R4 | 一个 feature 禁止导入另一个 feature |
| R5 | `app_ui` 只依赖 Flutter；不得出现路由、网络、存储、Riverpod |
| R6 | `native_bridge` 不得依赖 `app_core`/`app_ui`；错误类型自定义 |
| R7 | 依赖注入只在 `bootstrap.dart` 覆盖，不在 widget/service 中临时构造全局依赖 |
| R8 | 新依赖/新包/新模块先登记决策 |

`check_imports.sh` 是硬门禁；本地与 CI 都必须跑。

## 5. Dart / Flutter 规范

- 语言：Dart 3.13，启用 sound null safety；禁止 `dynamic`（除非解析 JSON 边界并立即收敛类型）。
- lint：根 `analysis_options.yaml` 包含 `very_good_analysis 11.0.0`；成员目录不得保留自己的 `analysis_options.yaml`（会覆盖根规则）；不得关闭规则来变绿；生成目录已在 analyzer 中排除。
- 格式化：`dart format`，页宽 100；提交前运行 `tool/check.sh`。
- 命名：文件 `snake_case.dart`；类型 `UpperCamelCase`；变量/方法 `lowerCamelCase`；常量 `lowerCamelCase`；provider 生成名以 `Provider` 结尾。
- 类型：公开 API 写显式返回类型；局部变量优先 `final`；能用 `const` 就用 `const`。
- Widget：优先 `StatelessWidget` / `ConsumerWidget`；拆分小组件；避免巨型 `build`；可访问性（≥48dp、Semantics、对比度）。
- 异步：`async/await` 优先；禁止在 UI 事件中 `unawaited` 无处理；错误必须记录或转 UI 状态。
- 错误：`app_core` 用 sealed `AppFailure`；`native_bridge` 用 `BridgeException`；禁止空 `catch {}`。
- 日志：`AppLogger`，带 tag；不打印 PII；不用日志代替错误处理。
- 注释：解释「为什么」，不写「做了什么」；不保留被注释掉的代码。
- 测试：新增逻辑必须有测试；UI 必须有 widget 或集成测试覆盖主路径。

### feature 结构

```text
features/<name>/
├── presentation/   # 页面/Widget；只读本 feature 的 application provider
├── application/    # @riverpod provider/controller；编排
├── domain/         # 有业务后再加；纯 Dart
└── data/           # 有业务后再加；Repository 实现
```

- `presentation` 禁止直接调用 `NativeBridge`、`Dio`、`SharedPreferences`。
- provider 命名：`<name>Provider`；异步用 `FutureProvider`/`StreamProvider` 语义，不手写缓存层。
- `AsyncValue` 必须处理三态；错误要有用户可见反馈。

## 6. Riverpod 规范

- 版本：`flutter_riverpod 3.4.3` + `riverpod_annotation 4.0.7` + `riverpod_generator 4.0.9`。
- 一律使用 `@riverpod` 注解；生成文件 `*.g.dart` 提交，不手改。
- 默认 autoDispose；全局服务才用 `@Riverpod(keepAlive: true)`，并注释原因。
- 组合根覆盖：`appEnvProvider`、`appLoggerProvider`、`nativeBridgeProvider` 默认抛 `StateError`，只在 `bootstrap.dart` override。
- 页面中 `ref.listen` 处理 SnackBar/导航；`ref.watch` 只读数据；不在 `build` 中写状态。
- 高频流（ticker）只在小范围 `Consumer` 中 watch；禁止在页面根部造成整页重建。
- 测试：provider 逻辑优先纯函数/单元测试；widget 测试使用 `ProviderScope(overrides: ...)`。

## 7. 国际化（l10n）

- ARB：`apps/shell_app/lib/l10n/app_en.arb`（模板）与 `app_zh.arb`；key 一一对应。
- 生成：`flutter gen-l10n`（由 `tool/gen.sh` 调用）；输出 `lib/l10n/generated/`，不手改。
- 新增文案必须同时补中英文；占位符带类型声明。
- Flutter UI 文案一律 `AppLocalizations.of(context)`；原生演示页文案放 `res/values/strings.xml`（v0 仅英文，文档注明）。
- 新增语言按 `docs/01` 第 18.4 节执行，并更新验收。

## 8. Native Bridge 规范

### 8.1 契约

- 唯一来源：`packages/native_bridge/pigeons/shell_api.dart`。
- 规则：`@HostApi`（Dart→原生）、`@FlutterApi`（原生→Dart）、`@EventChannelApi`（流，方法只写元素类型，不写 `Stream<T>`）。
- `@async` 在 Kotlin 生成 `suspend`；事件流生成 `XxxStreamHandler` + `PigeonEventSink<T>`。
- Kotlin 错误使用生成包中的 `FlutterError(code, message, details)`；Swift 用 `PigeonError`。
- v0 契约冻结；只允许追加。破坏性变更走 V2 接口，不重命名/删除现有字段。

### 8.2 生成与提交

```bash
bash tool/gen.sh
git status --porcelain -- \
  apps/shell_app/lib/l10n/generated \
  packages/native_bridge/lib/src/generated \
  packages/native_bridge/android/src/main/kotlin/com/dk/fluttershell/bridge/generated \
  packages/native_bridge/ios
```

必须为空。Dart/Kotlin/Swift 生成物来自同一 Pigeon 版本；Pigeon 升级需单独提交并跑全量验收。

### 8.3 Dart 封装

- 对外只暴露 `NativeBridge`、`BridgeException`、`SystemInfo`、`NativeScreenResult`；不导出生成的 API 类。
- `PlatformException` 统一转 `BridgeException`，保留 code/message/details。
- 不在封装层写 UI、导航、Riverpod。
- 事件流必须可取消；autoDispose provider 离开页面时停止原生 ticker。

### 8.4 Android/Kotlin

- 插件模块：`packages/native_bridge/android`，namespace `com.dk.fluttershell.bridge`。
- Flutter 3.47.9 使用 AGP 9.1.0 + Kotlin 2.4.0（AGP 内置 Kotlin）；不要显式应用 `org.jetbrains.kotlin.android`，除非模板升级后明确要求。
- Compose 模块必须应用 `org.jetbrains.kotlin.plugin.compose`（版本与 Kotlin 一致）；依赖用 BOM 2026.09.00。
- `FlutterPlugin` + `ActivityAware` 管理 Activity；不得在插件中静态持有 Activity 强引用。
- `startActivity` 必须在主线程；文件/包查询放 `Dispatchers.IO`；协程用结构化并发，取消后不再发送事件。
- 原生页 `exported=false`；文案用资源；日志 tag `NativeBridge`，固定标记（`SCREEN_OPENED`、`RESULT ...`、`TICK_STOPPED`、`RESULT_DROPPED`）。
- 测试：纯逻辑抽到 `SystemInfoMapper`，用 `kotlin-test` + JUnit Platform；不要改成 JUnit4。
- `MainActivity` 不写桥接注册；插件由 `GeneratedPluginRegistrant` 自动注册。

### 8.5 iOS

- 本轮只生成 Swift 并写 UNIMPLEMENTED 桩；不编译、不 `pod install`、不声称可用。
- 所有 HostApi 方法抛 `PigeonError(code: "UNIMPLEMENTED", ...)`；事件流 onListen 立即报错。

## 9. 性能规范

- 首帧前只做 env/logger/bridge 构造，不发起通道调用。
- `build()` 中禁止 IO、JSON 解析、日志字符串拼接、桥接请求。
- 可静态化 Widget 用 `const`；高频更新用独立 `Consumer`。
- 列表用 builder；图片加载后续统一接入缓存组件，不在 v0 引入。
- 桥接报文 > 256KB 或原生处理可能 > 5ms：原生后台线程 + `Uint8List`，禁止主线程大 JSON。
- 事件流频率 ≤ 10Hz（v0 ticker 1Hz）；取消必须立即生效。
- release 构建保持 R8/resource shrinking 默认开启；需要关闭时先记录决策。
- 性能数字只记录实测值；模拟器数字不得表述为真机性能。

## 10. 安全规范

- 不提交 keystore、`key.properties`、`.env`、token；使用 `key.properties.example` 占位。
- 原生 Activity `exported=false`；不申请不需要的权限。
- release 禁止明文流量（`usesCleartextTraffic=false`）；`allowBackup=false`。
- 日志/错误不得包含 PII；桥接错误只记录 code 与截断 message。
- `--dart-define` 不是秘密存储；不得传密钥。
- 依赖版本锁定（`pubspec.lock`、Gradle 版本）；升级需单独提交 + 全量验收。
- 不在仓库中放真实后端地址/密钥；占位值必须明显（如 `https://api.example.invalid`）。

## 11. 测试规范

| 变更类型 | 最低测试要求 |
| --- | --- |
| app_core 纯逻辑 | 单元测试 |
| 网络/存储实现 | 单元测试（假 adapter / mock prefs） |
| Riverpod provider | 单元或 widget 测试 |
| 页面 | widget 测试主路径 + 模拟器人工确认 |
| 桥接 Dart 封装 | 错误映射单测 + 集成测试（真机/模拟器） |
| Kotlin 逻辑 | JVM 单测；事件流/Activity 走手工验收 |
| 契约变更 | 更新 `02` 的 B1–B9 并全部重跑 |

- 单测禁止真实网络与真实延迟；集成测试只允许在本机模拟器。
- 不以「退出码 0」为唯一证据；检查测试计数、日志标记、字段值。
- 不删除/跳过失败测试来变绿；不提交 `skip: true`。

## 12. Git 与提交

- 分支：`main` 为主；功能分支 `feat/<name>`、修复 `fix/<name>`、文档 `docs/<name>`。
- Conventional Commits：`feat:`、`fix:`、`docs:`、`refactor:`、`test:`、`build:`、`chore:`。
- 每个阶段的代码 + 生成物 + 文档 + 证据同一提交；禁止「先 Dart 后原生」的中间态。
- 提交前：`git status` 检查暂存清单；确认无 keystore/秘密/构建产物。
- 不自动 push；用户明确要求且确认后才推送；禁止 force push、禁止改远程。
- 不修改 git config；不跳过 hooks（`--no-verify` 禁止）。

## 13. 文档同步

以下变更必须同步文档，否则不算完成：

| 变更 | 更新 |
| --- | --- |
| 桥接接口 | `docs/02`、`docs/04`、生成物 |
| 依赖/包/模块 | `docs/00` 决策表、`docs/01` 依赖图 |
| 新增页面/feature | `docs/01` 第 18 节、`docs/04` 追溯表（如有用户可见行为） |
| 命令/脚本 | `docs/03` 附录 A、`README.md`、CI |
| 版本升级 | `docs/00` 版本矩阵、`pubspec.lock`、证据 |
| 已知限制变化 | `docs/01` 第 19 节、`docs/04` 第 12 节 |

## 14. 完成定义（DoD）

一个任务只有全部满足才算完成：

- [ ] 代码符合依赖边界与 lint；`tool/check.sh` 通过；
- [ ] 生成物由 `tool/gen.sh` 产生且无 diff；
- [ ] 相关测试新增/更新并通过（含计数检查）；
- [ ] 模拟器上真实走通受影响链路（UI/桥接/原生化）；
- [ ] 无 TODO/FIXME（iOS UNIMPLEMENTED 除外）、无调试输出；
- [ ] 文档与证据同步；
- [ ] 提交信息清晰，暂存内容无秘密/产物。

## 15. 命令速查

| 目的 | 命令 |
| --- | --- |
| 首次初始化 | `bash tool/bootstrap.sh` |
| 生成（Pigeon/build_runner/l10n） | `bash tool/gen.sh` |
| 静态检查 | `bash tool/check.sh` |
| Dart 测试 | `bash tool/test.sh` |
| Android 原生单测 | `bash tool/test_native_android.sh` |
| 运行 | `bash tool/run_android.sh emulator-5554` |
| 集成测试 | `bash tool/e2e_android.sh emulator-5554` |
| Debug 构建 | `bash tool/build_android.sh` |
| Release 构建 | `bash tool/build_android.sh --release` |
| 冷启动测量 | `adb shell am start -W -n com.dk.fluttershell/.MainActivity` |

## 16. 执行模型协议（flash/coding model）

1. 先读 `docs/00` → `docs/03` → `docs/02` → 本文件；按 P0..P8 顺序执行。
2. 每阶段结束写 `docs/evidence/pN-*.md`，再进入下一阶段。
3. 遇到以下情况**停止并报告**，不得猜测：
   - 依赖版本解析冲突；
   - 生成类名/签名与文档不一致且无法通过官方文档确认；
   - 模拟器无法启动或 Gradle/Android SDK 缺失；
   - 需要偏离已锁定决策。
4. 不允许通过删除测试、关闭 lint、跳过 codegen、改用未决策技术来绕过失败。
5. 不允许扩大范围：不新增业务、不新增原生能力、不重构无关代码。
6. 汇报时给出：执行命令、关键输出、测试计数、截图路径、未验证项；不得只写「已完成」。

## 17. 已知限制（继承自 `docs/01` 第 19 节）

- iOS 未编译未运行；
- CI 未在远程实际运行；
- `NativeResultBus` 单引擎；
- release 使用 debug 签名；
- 性能数据来自模拟器；
- 网络/存储为占位抽象。
