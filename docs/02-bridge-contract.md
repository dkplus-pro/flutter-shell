# 02 · Native Bridge 契约

> 状态：设计定稿（2026-10-31）  
> 契约唯一来源：`packages/native_bridge/pigeons/shell_api.dart`  
> 生成工具：Pigeon **29.1.0**（与 `00` 版本矩阵一致）  
> 规则：**先改契约 → 重新生成 → 实现三端 → 更新本文与验收**。生成物禁止手改。

## 1. IDL（唯一来源）

`packages/native_bridge/pigeons/shell_api.dart` 的完整内容：

```dart
import 'package:pigeon/pigeon.dart';

class SystemInfo {
  SystemInfo({
    required this.platform,
    required this.osVersion,
    required this.deviceModel,
    required this.manufacturer,
    required this.appVersion,
    required this.buildNumber,
  });

  final String platform;
  final String osVersion;
  final String deviceModel;
  final String manufacturer;
  final String appVersion;
  final String buildNumber;
}

class NativeScreenResult {
  NativeScreenResult({
    required this.confirmed,
    required this.message,
  });

  final bool confirmed;
  final String message;
}

@HostApi()
abstract class ShellHostApi {
  @async
  SystemInfo getSystemInfo();

  @async
  bool openNativeScreen(String title, String message);
}

@EventChannelApi()
abstract class TickStreamApi {
  int ticks();
}

@FlutterApi()
abstract class ShellFlutterApi {
  void onNativeScreenResult(NativeScreenResult result);
}
```

约束：

- 本文件不允许出现函数体、`print`、业务逻辑。
- v0 不允许新增第二个 IDL 文件；所有桥接能力先集中在 `shell_api.dart`。
- 修改任何签名、字段名、字段类型都属于契约变更，必须走第 8 节流程。

## 2. 生成物与命令

### 2.1 输出路径（固定）

| 语言 | 路径 | 说明 |
| --- | --- | --- |
| Dart | `packages/native_bridge/lib/src/generated/shell_api.g.dart` | 禁止手改，提交 |
| Kotlin | `packages/native_bridge/android/src/main/kotlin/com/dk/fluttershell/bridge/generated/ShellApi.g.kt` | 包名 `com.dk.fluttershell.bridge.generated`，提交 |
| Swift | `packages/native_bridge/ios/<iOS 源码目录>/Generated/ShellApi.g.swift` | 本轮只生成 + 桩实现，不编译，提交；源码目录按模板实际结构确定（CocoaPods 通常 `Classes/`，SPM 通常 `Sources/native_bridge/`），P1 记录并回填本表 |

### 2.2 生成命令

必须由 `tool/gen.sh` 执行；其桥接部分等价于：

```bash
cd packages/native_bridge
fvm dart run pigeon \
  --input pigeons/shell_api.dart \
  --dart_out lib/src/generated/shell_api.g.dart \
  --kotlin_out android/src/main/kotlin/com/dk/fluttershell/bridge/generated/ShellApi.g.kt \
  --kotlin_package com.dk.fluttershell.bridge.generated \
  --swift_out "ios/<iOS 源码目录>/Generated/ShellApi.g.swift"
```

`<iOS 源码目录>` 在 P1/P3 按 `flutter create` 的实际模板确定（CocoaPods 或 SPM），由 `tool/gen.sh` 用变量固化，并记录到 evidence 与本表；不要凭本示例猜测。

注意：

- Dart 与 Kotlin/Swift 生成物必须来自同一 Pigeon 版本；升级 Pigeon 必须重跑全部输出并在同一提交内更新三端。
- 生成的 Dart 文件不要被其他包直接深度导入；`packages/native_bridge/lib/native_bridge.dart` 只做受控导出。
- CI 重新生成后要求 `git status --porcelain` 为空。

### 2.3 预期生成名称（Pigeon 29 命名规则）

| 契约 | Dart | Kotlin | Swift |
| --- | --- | --- | --- |
| `ShellHostApi` | 具体类 `ShellHostApi` | 接口 + `ShellHostApi.setUp(messenger, api)` | protocol + setup |
| `TickStreamApi` | 顶层函数 `Stream<int> ticks({String instanceName})`（Pigeon 29 实际生成形态） | `TicksStreamHandler`（继承后实现 `onListen/onCancel`） | `TicksStreamHandler` |
| `ShellFlutterApi` | 抽象类 + `ShellFlutterApi.setUp(impl)` | 类 `ShellFlutterApi(messenger)`，方法为 `suspend` | 类 + 异步方法 |
| `SystemInfo` | 不可变数据类 | data class（`Long`/`String`） | struct |
| `NativeScreenResult` | 不可变数据类 | data class（`Boolean`/`String`） | struct |

实现时以实际生成物为准；如名称与上表不同，必须在 `docs/evidence/p3-bridge.md` 记录实际名称并同步本文，**不得凭猜测实现**。

## 3. 对外 Dart API（封装层）

`packages/native_bridge/lib/src/shell_bridge.dart` 暴露：

```dart
final class NativeBridge {
  NativeBridge({ShellHostApi? hostApi, TickStreamApi? tickStreamApi});

  /// 幂等；注册 ShellFlutterApi 处理器。必须在调用 ticks() 之前执行。
  void initialize();

  Future<SystemInfo> getSystemInfo();

  Stream<int> ticks();

  /// 返回 true 表示原生页已启动；失败以 BridgeException 抛出。
  Future<bool> openNativeScreen({required String title, required String message});

  /// 原生页回传结果；broadcast，页面可多次订阅。
  Stream<NativeScreenResult> get nativeScreenResults;

  /// 仅用于测试/引擎销毁；关闭结果流并注销 FlutterApi。
  Future<void> dispose();
}
```

```dart
final class BridgeException implements Exception {
  const BridgeException(this.code, this.message, [this.details]);
  final String code;
  final String message;
  final Object? details;
}
```

规则：

- `initialize()` 重复调用无副作用；未初始化调用 `ticks()` 属于编程错误，抛 `StateError`。
- 对 `PlatformException` 的转换：`code/message/details` 原样保留到 `BridgeException`；非 `PlatformException` 统一 `code = BRIDGE_FAILURE`。
- `nativeScreenResults` 为 broadcast stream；`dispose()` 后不得再 add，原生侧回传被丢弃。
- 封装层不得包含 UI、Riverpod、导航逻辑。
- `ShellHostApi`/`TickStreamApi` 仅作为可选构造参数用于测试，不作为公开 API 文档的一部分；实际调用方只依赖 `NativeBridge`。

## 4. 三条链路语义

### 4.1 `getSystemInfo`（Dart → 原生，请求/响应）

| 字段 | Android 取值 | 约束 |
| --- | --- | --- |
| `platform` | 固定 `"android"` | 小写；iOS 桩返回 `"ios"` |
| `osVersion` | `"Android ${Build.VERSION.RELEASE} (API ${Build.VERSION.SDK_INT})"` | 必须由 `SystemInfoMapper.formatOsVersion` 生成 |
| `deviceModel` | `Build.MODEL` | 空值回落 `"unknown"` |
| `manufacturer` | `Build.MANUFACTURER` | 空值回落 `"unknown"` |
| `appVersion` | `PackageInfo.versionName` | 空值回落 `"unknown"` |
| `buildNumber` | `versionCode`（API < 28 用 `versionCode.toLong()`） | 十进制字符串 |

执行规则：

- Kotlin 侧 `suspend`，在 `Dispatchers.IO` 中读取 PackageManager。
- 失败抛 `FlutterError("SYSTEM_INFO_FAILED", message, null)`。
- 不缓存；每次调用反映当前状态（页面可刷新）。

### 4.2 `ticks`（原生 → Dart，事件流）

- 元素类型：`int`；Kotlin 侧为 `Long`。
- 序列从 `0` 开始，每 1000ms +1；不做节流以外的聚合。
- `onListen` 启动协程；`onCancel` 立即取消；取消后不得继续发送。
- 页面通过 autoDispose `StreamProvider` 消费；离开页面必须停止原生 tick（logcat 应出现 `TICK_STOPPED`）。
- 事件流不支持回放；重新订阅从 0 开始（v0 明确行为）。

### 4.3 `openNativeScreen` + `onNativeScreenResult`（双向）

| 步骤 | 行为 |
| --- | --- |
| Dart 调用 | `openNativeScreen(title, message)`，非空；空值由调用方保证（UI 不传空） |
| Kotlin 校验 | `activityProvider()` 为空 → 抛 `FlutterError("NO_ACTIVITY", ...)` |
| 启动 | `startActivity(NativeInfoActivity.createIntent(...))`；异常 → `NATIVE_SCREEN_LAUNCH_FAILED` |
| 返回 | 启动成功返回 `true`；不等原生页结果 |
| 原生页确认 | `NativeResultBus.send(NativeScreenResult(true, "Confirmed in native screen"))` 后 `finish()` |
| 原生页取消/返回键 | `NativeResultBus.send(NativeScreenResult(false, "Cancelled in native screen"))` 后 `finish()` |
| 回传 | 插件 dispatcher 在 `Dispatchers.Main.immediate` 调用生成的 `ShellFlutterApi`（`suspend`） |
| Dart 接收 | 写入 `nativeScreenResults` broadcast stream；页面 `ref.listen` 显示 SnackBar |
| 丢失 | Flutter engine 已 detach / dispatcher 未安装时记录 `RESULT_DROPPED`；Dart 侧无订阅时 broadcast 丢弃事件（不额外记录）；均不崩溃 |

原生页契约：

- Activity：`com.dk.fluttershell.bridge.NativeInfoActivity`，`exported=false`。
- 主题：`@style/Theme.NativeBridge`（`android:Theme.Material.Light.NoActionBar`）。
- Intent extras：
  - `com.dk.fluttershell.bridge.extra.TITLE`
  - `com.dk.fluttershell.bridge.extra.MESSAGE`
- UI：显示标题、消息；提供 Confirm / Cancel 两个按钮；返回键等同取消。
- 结果只派发一次（`dispatched` 标志保护），即使快速连点或返回。
- 日志 tag 固定 `NativeBridge`，标记：
  - `SCREEN_OPENED title=<title>`
  - `RESULT confirmed=<true|false> message=<message>`
  - `RESULT_DROPPED ...`

## 5. 线程与生命周期

| 项 | 规则 |
| --- | --- |
| HostApi 默认线程 | Pigeon 默认在平台主线程进入；`@async` 生成 `suspend` |
| `getSystemInfo` | 入口主线程，`withContext(Dispatchers.IO)` 执行 PackageManager 查询 |
| `openNativeScreen` | 必须在主线程调用 `startActivity`；不要切 IO |
| 事件流 | `onListen/onCancel` 在主线程；ticker 协程 `Dispatchers.Main.immediate` + `delay(1000)`；`PigeonEventSink.success` 只在主线程调用 |
| FlutterApi 回调 | 插件使用 `CoroutineScope(SupervisorJob() + Dispatchers.Main.immediate)`；Activity 不得自行 `runBlocking` |
| 插件清理 | `onDetachedFromEngine`：`ShellHostApi.setUp(messenger, null)`、handler `dispose()`、取消 dispatcher scope、清空 `NativeResultBus` |
| Activity 引用 | `ActivityAware.onAttachedToActivity` 设置；`onDetachedFromActivity` 置空；不得在插件中长期持有 Activity 强引用泄漏 |
| 事件流结束 | v0 ticker 无限；仅取消，不调用 `endOfStream` |
| 多引擎 | 不支持；`NativeResultBus` 是进程级单例（已知限制） |

## 6. 错误码与映射

| code | 来源 | 触发条件 | Dart 行为 |
| --- | --- | --- | --- |
| `NO_ACTIVITY` | Kotlin HostApi | 调用 `openNativeScreen` 时无前台 Activity | 抛 `BridgeException('NO_ACTIVITY', ...)`；UI 显示通用错误 |
| `SYSTEM_INFO_FAILED` | Kotlin HostApi | PackageManager 查询异常 | 同上，code 保留 |
| `NATIVE_SCREEN_LAUNCH_FAILED` | Kotlin HostApi | `startActivity` 异常 | 同上 |
| `UNIMPLEMENTED` | Swift 桩 | iOS 尚未实现 | iOS 本轮不验收；文档标注 |
| `BRIDGE_FAILURE` | Dart wrapper | 非 `PlatformException` 的未知异常 | 包装为 `BridgeException`，原始异常放 `details` |

Kotlin 侧使用的 `FlutterError`（以及 `PigeonEventSink`）由 Pigeon 生成在 `com.dk.fluttershell.bridge.generated` 包中，不是 Android 框架类；导入时以生成物为准，不要手写替代类。

展示层映射（app 层，非契约）：

- `NO_ACTIVITY` / `NATIVE_SCREEN_LAUNCH_FAILED` → 用户可见「无法打开原生页面」+ 重试；
- `SYSTEM_INFO_FAILED` → 用户可见「读取设备信息失败」+ 刷新；
- 其他 → 通用错误 + code 写入日志（不展示堆栈）。

## 7. 版本与兼容

- v0 契约冻结；新增能力只能**追加**方法/类。
- 已发布字段不得重命名、删除、改类型；如需破坏性变更，新增 `ShellHostApiV2` / `NativeScreenResultV2`，保留旧接口至少一个大版本。
- 同一 Pigeon 版本生成三端；Pigeon 生成代码是内部实现，不得被其他包公开依赖。
- 修改 IDL 后必须同时更新：生成物、Kotlin 实现、Swift 桩（可 UNIMPLEMENTED）、Dart wrapper、app provider/UI、本文、`04` 验收用例。

## 8. 变更流程（强制顺序）

1. 修改 `pigeons/shell_api.dart`；
2. `bash tool/gen.sh`；
3. 对照生成物确认类名/签名；
4. 实现/更新 Kotlin（并同步 Swift 桩）；
5. 更新 Dart wrapper 与错误映射；
6. 更新 app 层 provider/UI；
7. 更新本文与 `docs/04-acceptance.md`；
8. 跑 `tool/gen.sh` → `git status --porcelain` 为空 → `tool/check.sh` → `tool/test.sh` → 原生单测；
9. 同一提交完成，禁止拆成「先 Dart 后原生」的中间态提交。

## 9. 契约验收用例（必须逐条执行）

| 编号 | 场景 | 操作 | 预期 |
| --- | --- | --- | --- |
| B1 | 系统信息 | 桥接页触发 `getSystemInfo` | `platform=android`；6 个字段非空；`osVersion` 含 `API `；`buildNumber` 可解析为整数 |
| B2 | ticker 启动 | 进入桥接页观察 | 从 0 开始，约每秒 +1；无重复/跳变；UI 只重建计数区域 |
| B3 | ticker 停止 | 返回上一页 | logcat 出现 `TICK_STOPPED`；再次进入重新从 0 开始 |
| B4 | 原生页启动 | 点击「打开原生页面」 | logcat `SCREEN_OPENED`；`dumpsys activity activities` 可见 `NativeInfoActivity` |
| B5 | 确认回传 | 原生页点击 Confirm | SnackBar 显示确认；logcat `RESULT confirmed=true`；Dart stream 收到 `confirmed=true`、固定 message |
| B6 | 取消回传 | 原生页点击 Cancel 或返回键 | `confirmed=false`；只触发一次；SnackBar 显示取消 |
| B7 | 错误映射 | Dart 单测注入 `PlatformException(code: NO_ACTIVITY)` | 抛出 `BridgeException`，code 原样保留 |
| B8 | 生成物一致性 | `tool/gen.sh` 后 `git status --porcelain` | 输出为空 |
| B9 | iOS 桩 | 检查文件 | Swift 生成物与 `UNIMPLEMENTED` 桩存在；不声称可运行 |

B1–B6 需要模拟器真实链路；B7 用单元测试；B8 在 CI 与本地执行；B9 仅文件检查。
