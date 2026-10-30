# P3 · 原生桥接插件（Android）证据（2026-10-31）

## 契约与生成

- IDL：`packages/native_bridge/pigeons/shell_api.dart`（与 `docs/02` 第 1 节逐字一致）。
- Pigeon **29.1.0** 一次生成三端：
  - Dart：`lib/src/generated/shell_api.g.dart`
  - Kotlin：`android/src/main/kotlin/com/dk/fluttershell/bridge/generated/ShellApi.g.kt`（包 `com.dk.fluttershell.bridge.generated`）
  - Swift：`ios/native_bridge/Sources/native_bridge/Generated/ShellApi.g.swift`（**DEC-018**：SPM 模板实际路径）
- 实际生成类名（与 `02` §2.3 对照，全部一致）：
  - Dart：`ShellHostApi`（具体类）、`TickStreamApi.ticks() → Stream<int>`、`ShellFlutterApi`（抽象类 + setUp）、`SystemInfo`、`NativeScreenResult`
  - Kotlin：`interface ShellHostApi` + `ShellHostApi.setUp(messenger, api)`、`abstract class TicksStreamHandler`（`PigeonEventSink<Long>`）、`class ShellFlutterApi(messenger)`（`suspend fun onNativeScreenResult`）、`data class SystemInfo`、`data class NativeScreenResult`、`class FlutterError(code, message, details)`、`class PigeonEventSink<T>`、`TicksEventChannel`

## DEC-017（新增决策）：Compose BOM 降级

BOM **2026.09.00** 解析出的 `androidx.compose.material:material-ripple-android:1.12.1`、`androidx.compose.foundation:foundation-android:1.12.1` 要求 compileSdk ≥37；AGP 9.1.0 最高推荐 36，DEC-013 锁定 compileSdk 36。Gradle 报错原文（节选）：

```
Dependency 'androidx.compose.foundation:foundation-android:1.12.1' requires libraries and
applications that depend on it to compile against version 37 or later of the Android APIs.
:app is currently compiled against android-36.
Also, the maximum recommended compile SDK version for Android Gradle plugin 9.1.0 is 36.
```

改用 BOM **2025.09.01**（Compose 1.9.x 线）后构建通过；已登记 `docs/00`。

## Compose 编译插件（AGP 9 内置 Kotlin 2.4.0）

- `apps/shell_app/android/settings.gradle.kts` plugins 增加 `id("org.jetbrains.kotlin.plugin.compose") version "2.4.0" apply false`。
- 插件模块 `build.gradle.kts` plugins 增加 `id("org.jetbrains.kotlin.plugin.compose")`，`buildFeatures { compose = true }`，依赖 BOM 2025.09.01 / activity-compose 1.13.0 / material3 / ui / coroutines-android 1.11.0。
- 一次构建成功，未出现 Compose/Kotlin 版本不匹配。

## Kotlin 实现

文件（`com.dk.fluttershell.bridge`）：`NativeBridgePlugin.kt`（FlutterPlugin+ActivityAware，引擎 attach 时注册 HostApi/事件流/ResultBus，detach 时全部反注册）、`ShellHostApiImpl.kt`（IO 读 PackageManager；主线程 `startActivity`；错误抛生成包 `FlutterError`）、`TicksStreamHandlerImpl.kt`（1Hz 协程，`TICK_STOPPED`）、`NativeResultBus.kt`（单例 dispatcher，`RESULT_DROPPED`）、`NativeResultDispatcher.kt`（Main.immediate 调 `ShellFlutterApi`）、`NativeInfoActivity.kt`（Compose，`dispatched` 幂等，返回键=取消）、`SystemInfoMapper.kt`（纯 JVM）。Manifest：Activity `exported=false`，主题 `@style/Theme.NativeBridge`（`android:Theme.Material.Light.NoActionBar`）。

## 验证输出

```
$ fvm flutter build apk --debug        # apps/shell_app
✓ Built build/app/outputs/flutter-apk/app-debug.apk

$ ./gradlew testDebugUnitTest          # apps/shell_app/android
SystemInfoMapperTest > fallsBackForBlankValues() PASSED
SystemInfoMapperTest > usesLongVersionCodeFromApi28() PASSED
SystemInfoMapperTest > formatsOsVersion() PASSED
BUILD SUCCESSFUL

# 合并清单（debug）
grep NativeInfoActivity build/app/intermediates/merged_manifests/debug/processDebugManifest/AndroidManifest.xml
→ android:name="com.dk.fluttershell.bridge.NativeInfoActivity"
→ android:exported="false"
```

## Gate 结论

- debug APK 构建成功 ✅
- Kotlin 单测 3/3 通过（kotlin-test + JUnit Platform）✅
- 生成类名与契约一致 ✅
- 合并清单含 NativeInfoActivity 且 exported=false ✅
