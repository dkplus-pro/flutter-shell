# 03 · 实施计划（给后续编码模型）

> 目标：按阶段把空仓库实现为可运行、可验收的 Flutter 壳工程。  
> 先读：`00-overview.md`、`01-architecture.md`、`02-bridge-contract.md`、根目录 `AGENTS.md`。  
> 本文是**执行顺序**；契约以 `02` 为准，规范以 `AGENTS.md` 为准。禁止跳阶段、禁止改架构。

## 0. 执行纪律

1. **按阶段顺序执行**；每个阶段有 Gate，Gate 未通过不得进入下一阶段。
2. **版本以 `00` 版本矩阵为准**；出现 pub 解析冲突时停止并记录，不允许静默改版本或换库。
3. **生成物禁止手改**；所有生成统一走 `tool/gen.sh`；生成物必须提交。
4. **每个阶段写证据**：`docs/evidence/pN-<name>.md`，包含日期、执行的命令、关键输出、截图路径。没有证据 = 未完成。
5. **失败处理**：构建/测试失败先定位根因；禁止用 `--no-verify`、删除测试、关闭 lint、跳过生成等方式“变绿”。
6. **不自动 `git push`**；允许本地阶段性提交（Conventional Commits）。不得改远程、不得强推。
7. **不做本文之外的重构/抽象**；需要偏离时先在 `docs/00-overview.md` 追加决策并停止执行，等待确认。
8. **所有 UI 改动必须在模拟器上实际看过**；静态分析通过不等于功能正确。

## 1. 阶段总览

| 阶段 | 交付 | Gate |
| --- | --- | --- |
| P0 | macOS 工具链、Flutter 3.47.9、JDK17、Android SDK 36、AVD | `flutter doctor` Android ✓；模拟器可启动 |
| P1 | 空壳三件套 + workspace + lint + Gradle 模块纳入 | `flutter pub get`、debug APK 构建、`:native_bridge` 出现在 Gradle projects |
| P2 | app_core / app_ui / i18n / 路由 / Hello 页 | analyze + test + 模拟器可见 Hello（中英文） |
| P3 | Pigeon 契约 + Kotlin 桥接 + Compose 原生页 + 原生单测 | 生成物齐全、debug 构建、Kotlin 单测通过 |
| P4 | Dart bridge 封装 + Riverpod + 桥接演示页 + 集成测试 | 方法/事件流/原生页回传在模拟器跑通 |
| P5 | 网络/存储抽象 + 单元测试 | 两个抽象层的错误映射/读写测试通过 |
| P6 | 全量脚本 + CI + release 构建 + 启动/体积基线 | 所有脚本通过；release APK 产出；CI 文件静态核查 |
| P7 | iOS Swift 桩 + 文档标注 | 文件存在且标明 UNIMPLEMENTED；不编译 |
| P8 | 清理、文档同步、最终验收 | `04` 全表通过，evidence 完整 |

## P0 · 工具链从零搭建

当前开发机没有 Flutter/FVM/JDK/Android SDK/完整 Xcode；本阶段只装 Android 必需项。iOS 桩不需要 Xcode。

### 0.1 前置检查

```bash
uname -m                      # 期望 arm64
brew --version                # 若无 Homebrew，先安装
xcode-select -p               # 允许是 CommandLineTools；本轮不需要完整 Xcode
```

### 0.2 安装 FVM + Flutter 3.47.9

```bash
brew tap leoafarias/fvm
brew install fvm
cd /Volumes/LexarSSD/dev_test/flutter-shell
fvm install 3.47.9
fvm use 3.47.9                # 生成并写入 .fvmrc，检查内容为 {"flutter":"3.47.9"}
fvm flutter --version         # 期望 Flutter 3.47.9 / Dart 3.13.7
```

`.fvmrc` 必须提交；`.fvm/` 必须忽略（P1 的 `.gitignore`）。

### 0.3 安装 JDK 17

```bash
brew install --cask temurin@17
export JAVA_HOME="$(/usr/libexec/java_home -v 17)"
java -version                 # 期望 17.x
fvm flutter config --jdk-dir "$JAVA_HOME"
```

把 `JAVA_HOME` 与 Android 环境变量写入 `~/.zshrc`，新终端能复现。

### 0.4 Android SDK（cmdline-tools 路线）

```bash
mkdir -p "$HOME/Library/Android/sdk/cmdline-tools"
# 从 https://developer.android.com/studio#command-line-tools-only 下载 mac 版 zip
unzip commandlinetools-mac-*.zip -d /tmp/android-cmdline
mv /tmp/android-cmdline/cmdline-tools "$HOME/Library/Android/sdk/cmdline-tools/latest"
```

`~/.zshrc` 追加：

```bash
export ANDROID_HOME="$HOME/Library/Android/sdk"
export ANDROID_SDK_ROOT="$ANDROID_HOME"
export PATH="$ANDROID_HOME/cmdline-tools/latest/bin:$ANDROID_HOME/platform-tools:$ANDROID_HOME/emulator:$PATH"
```

安装 SDK 组件并接受许可：

```bash
yes | sdkmanager --licenses
sdkmanager --install "platform-tools" "emulator" "platforms;android-36" "build-tools;36.0.0" \
  "system-images;android-36;google_apis;arm64-v8a"
```

创建并启动 AVD：

```bash
avdmanager list device | grep -i pixel        # 选择存在的设备 id
echo no | avdmanager create avd -n shell_api36 \
  -k "system-images;android-36;google_apis;arm64-v8a" -d pixel_7
emulator -avd shell_api36 -no-snapshot -no-boot-anim &
adb wait-for-device
adb shell getprop sys.boot_completed          # 轮询直到输出 1
adb devices                                   # 期望 emulator-5554 device
```

### 0.5 Gate 与证据

```bash
fvm flutter doctor -v
fvm flutter devices
adb devices
emulator -list-avds
```

期望：Android toolchain、Java、Android Studio（可缺省）正常；Xcode ✗ 可接受并记录。  
若构建时提示 NDK 缺失，按错误提示的版本安装 `ndk;<version>` 并记录；不要随意改模板的 `ndkVersion`。  
写入 `docs/evidence/p0-toolchain.md`：完整版本输出、`flutter doctor` 摘要、AVD 名称、启动命令。

**禁止**：跳过 `flutter doctor` 直接开始创建工程；使用非 17 JDK；把 SDK 装到非 `ANDROID_HOME` 路径却不记录。

## P1 · 仓库脚手架与 Gradle 模块

### 1.1 创建三件套

```bash
cd /Volumes/LexarSSD/dev_test/flutter-shell

fvm flutter create --org com.dk --project-name fluttershell \
  --platforms=android,ios apps/shell_app

fvm flutter create --template=package packages/app_core
fvm flutter create --template=package packages/app_ui

fvm flutter create --template=plugin --org com.dk.fluttershell \
  --project-name native_bridge --platforms=android,ios packages/native_bridge

rm -rf packages/native_bridge/example
```

先统一 lint 入口：删除 `flutter create` 在各成员生成的局部配置，避免覆盖根级规则；并从成员 pubspec 移除 `flutter_lints`（根使用 `very_good_analysis`）：

```bash
rm -f apps/shell_app/analysis_options.yaml packages/*/analysis_options.yaml
```

此时插件 Android namespace 是 `com.dk.fluttershell.native_bridge`，需改成契约规定的 `com.dk.fluttershell.bridge`：

```bash
# 1) 移动 Kotlin 文件并改 package
mkdir -p packages/native_bridge/android/src/main/kotlin/com/dk/fluttershell/bridge
mv packages/native_bridge/android/src/main/kotlin/com/dk/fluttershell/native_bridge/* \
   packages/native_bridge/android/src/main/kotlin/com/dk/fluttershell/bridge/
# 删除空目录
rmdir packages/native_bridge/android/src/main/kotlin/com/dk/fluttershell/native_bridge 2>/dev/null || true
# 2) 将 .kt 中 package com.dk.fluttershell.native_bridge 改为 com.dk.fluttershell.bridge
# 3) android/build.gradle.kts: group 与 namespace 改为 com.dk.fluttershell.bridge
# 4) pubspec.yaml: flutter.plugin.platforms.android.package 改为 com.dk.fluttershell.bridge
# 5) 若 AndroidManifest.xml 仍有 package 属性，一并改为 com.dk.fluttershell.bridge
```

插件测试目录中引用旧包名的默认测试直接删除（后续写 Kotlin 单测）。

### 1.2 根 workspace

根 `pubspec.yaml`：

```yaml
name: flutter_shell_workspace
publish_to: none

environment:
  sdk: ^3.13.0

workspace:
  - apps/shell_app
  - packages/app_core
  - packages/app_ui
  - packages/native_bridge

dev_dependencies:
  very_good_analysis: 11.0.0
```

每个成员 `pubspec.yaml` 增加：

```yaml
resolution: workspace
```

app 的依赖先接上包路径（后续阶段再补具体库）：

```yaml
dependencies:
  flutter:
    sdk: flutter
  app_core:
    path: ../../packages/app_core
  app_ui:
    path: ../../packages/app_ui
  native_bridge:
    path: ../../packages/native_bridge
```

根 `analysis_options.yaml`：

```yaml
include: package:very_good_analysis/analysis_options.yaml

analyzer:
  exclude:
    - "**/*.g.dart"
    - "**/l10n/generated/**"
    - "**/lib/src/generated/**"

formatter:
  page_width: 100

linter:
  rules:
    public_member_api_docs: false
```

`.editorconfig`：

```ini
root = true

[*]
charset = utf-8
end_of_line = lf
insert_final_newline = true
trim_trailing_whitespace = true
indent_style = space
indent_size = 2

[*.{kt,kts}]
indent_size = 4
```

`.gitignore` 至少包含（**不要**忽略 `*.g.dart` / `*.g.kt` / `*.g.swift`）：

```gitignore
.fvm/
.dart_tool/
build/
coverage/
**/android/local.properties
**/android/key.properties
*.jks
*.keystore
**/ios/Pods/
**/ios/.symlinks/
**/.flutter-plugins
**/.flutter-plugins-dependencies
.DS_Store
.idea/
*.iml
```

### 1.3 验证

```bash
fvm flutter pub get

cd apps/shell_app
fvm flutter build apk --debug

cd android
./gradlew projects | grep -i native_bridge   # 期望出现 :native_bridge
```

### 1.4 Gate 与证据

- `pub get` 成功，无未解析依赖；
- debug APK 构建成功；
- Gradle projects 含 `:native_bridge`；
- 模拟器能安装并打开默认 Flutter 页面（此时仍是模板 counter，P2 替换）。

写入 `docs/evidence/p1-scaffold.md`：三条命令输出、`./gradlew projects` 摘要、模板生成的 AGP/Kotlin/Gradle 版本（必须记录，供 Compose 插件对齐）。

## P2 · Flutter 基础底座

### 2.1 依赖

- `apps/shell_app`：`flutter_riverpod 3.4.3`、`riverpod_annotation 4.0.7`、`go_router 18.1.2`、`flutter_localizations`（SDK）、`intl: any`（跟随 `flutter_localizations` 解析，当前 0.20.3）；dev：`build_runner 2.17.1`、`riverpod_generator 4.0.9`。
- `packages/app_core`：`flutter`（SDK）、`logging 1.3.0`、`dio 5.11.1`、`shared_preferences 2.5.6`；dev：`flutter_test`（若 package 模板只带 `test`，补 `flutter_test: sdk: flutter`）。
- `packages/app_ui`：`flutter`（SDK）；不得加网络/存储/Riverpod；dev 同样按需补 `flutter_test`。
- app_core/app_ui 的 pubspec `environment` 与根一致；全部 `resolution: workspace`。

### 2.2 app_core

创建（完整实现，不留 TODO）：

```text
lib/app_core.dart
lib/src/config/app_env.dart
lib/src/error/app_failure.dart
lib/src/logging/app_logger.dart
```

`AppEnv`：

```dart
enum AppEnv {
  dev,
  prod;

  static AppEnv parse(String raw) {
    return AppEnv.values.firstWhere(
      (env) => env.name == raw,
      orElse: () => throw ArgumentError.value(raw, 'APP_ENV', 'Expected dev|prod'),
    );
  }

  static AppEnv fromDartDefine() =>
      parse(const String.fromEnvironment('APP_ENV', defaultValue: 'dev'));

  bool get isProd => this == AppEnv.prod;

  String get apiBaseUrl => const String.fromEnvironment(
        'API_BASE_URL',
        defaultValue: 'https://api.example.invalid',
      );
}
```

`AppFailure`：

```dart
sealed class AppFailure implements Exception {
  const AppFailure(this.message, {this.cause});
  final String message;
  final Object? cause;
}

final class NetworkFailure extends AppFailure {
  const NetworkFailure(super.message, {super.cause});
}

final class StorageFailure extends AppFailure {
  const StorageFailure(super.message, {super.cause});
}

final class UnexpectedFailure extends AppFailure {
  const UnexpectedFailure(super.message, {super.cause});
}
```

`AppLogger`：包装 `logging`，dev=ALL / prod=INFO；使用 `dart:developer` 的 `log` 输出；提供 `child(tag)`；禁止 PII。实现时确保 `Logger.root.onRecord` 只订阅一次（组合根只创建一次）。

### 2.3 app_ui

```text
lib/app_ui.dart
lib/src/theme/app_tokens.dart     # AppSpacing / AppRadius
lib/src/theme/app_theme.dart      # light/dark，Material 3，ColorScheme.fromSeed
lib/src/widgets/app_primary_button.dart
lib/src/widgets/app_section_card.dart
```

- `app_ui` 不得 import Riverpod、不得 import app 包。
- 组件只接受数据与回调，不内置文案。

### 2.4 国际化

`apps/shell_app/l10n.yaml`：

```yaml
arb-dir: lib/l10n
template-arb-file: app_en.arb
output-localization-file: app_localizations.dart
output-dir: lib/l10n/generated
nullable-getter: false
```

ARB 至少包含：`appTitle`、`helloWorld`、`helloSubtitle`、`openBridgeDemo`、`bridgeDemoTitle`、`systemInfoTitle`、`refresh`、`tickerTitle`、`ticksValue(count)`、`nativeScreenTitle`、`openNativeScreen`、`nativeResultConfirmed(message)`、`nativeResultCancelled(message)`、`errorTitle`、`retry`。中英文 key 必须一一对应。

### 2.5 应用骨架

```text
lib/main.dart
lib/bootstrap.dart
lib/app.dart
lib/core/config/config_providers.dart
lib/core/logging/log_providers.dart
lib/core/router/app_router.dart
lib/features/home/presentation/home_page.dart
```

- `main.dart`：`void main() => bootstrap();`
- `bootstrap.dart`：`WidgetsFlutterBinding.ensureInitialized()` → `AppEnv.fromDartDefine()` → `AppLogger.create(env)` → 安装全局错误处理 → `runApp(ProviderScope(overrides: [appEnvProvider.overrideWithValue(env), appLoggerProvider.overrideWithValue(logger)], child: const ShellApp()))`。本阶段不要创建 NativeBridge（P4 加）。
- `lib/core/error/error_handlers.dart`：安装 `FlutterError.onError`、`PlatformDispatcher.instance.onError`，并在 release 设置简单的 `ErrorWidget.builder`（不依赖 l10n，避免启动期上下文不可用）。
- `config_providers.dart` / `log_providers.dart` 用 `@riverpod`，默认实现抛 `StateError('Override in bootstrap')`。
- `app_router.dart`：`AppRoutes.home = '/'`；P4 再加 `/bridge`。
- `app.dart`：`MaterialApp.router`，主题 `AppTheme.light()/dark()`，`ThemeMode.system`，`localizationsDelegates` / `supportedLocales`，`onGenerateTitle` 使用 `appTitle`。
- `home_page.dart`：显示 `helloWorld` + `helloSubtitle`；P4 增加进入桥接页的按钮。
- Android app label 改为 `Shell`（`android/app/src/main/AndroidManifest.xml`）；iOS `CFBundleDisplayName` 改为 `Shell`（本轮不验收）。

删除模板 counter 代码与 `test/widget_test.dart`，新增 `test/widget/home_page_test.dart`：使用 `MaterialApp` + 本地化 delegates，分别以 `Locale('en')` 与 `Locale('zh')` 断言 `helloWorld` 的英文/中文文案；P4 页面接入路由后再补 ShellApp 级导航测试。

### 2.6 生成与验证

```bash
cd /Volumes/LexarSSD/dev_test/flutter-shell
fvm flutter pub get
cd apps/shell_app
fvm dart run build_runner build --delete-conflicting-outputs
fvm flutter gen-l10n
cd ../..
for p in packages/app_core packages/app_ui apps/shell_app; do (cd "$p" && fvm flutter analyze --fatal-infos); done
cd apps/shell_app && fvm flutter test
cd ../.. && fvm flutter build apk --debug
```

启动模拟器，安装运行：

```bash
cd apps/shell_app
fvm flutter run -d emulator-5554 --dart-define=APP_ENV=dev
```

切换系统语言到中文，确认 `helloWorld` 显示中文；切回英文。

### 2.7 Gate 与证据

analyze（三个包）零 issue；widget 测试通过；模拟器 Hello 页中英文截图；`docs/evidence/p2-foundation.md`。

## P3 · 原生桥接插件（Android）

### 3.1 Pigeon 契约与依赖

- 将 `02` 第 1 节 IDL 原样写入 `packages/native_bridge/pigeons/shell_api.dart`。
- `packages/native_bridge/pubspec.yaml` dev_dependencies 增加 `pigeon: 29.1.0`。
- 先在仓库根执行 `fvm flutter pub get`，再运行生成（P6 后统一由 `tool/gen.sh` 执行）：

```bash
cd packages/native_bridge
fvm dart run pigeon \
  --input pigeons/shell_api.dart \
  --dart_out lib/src/generated/shell_api.g.dart \
  --kotlin_out android/src/main/kotlin/com/dk/fluttershell/bridge/generated/ShellApi.g.kt \
  --kotlin_package com.dk.fluttershell.bridge.generated \
  --swift_out "ios/<iOS 源码目录>/Generated/ShellApi.g.swift"
```

`<iOS 源码目录>` 按 P1 模板实际结构确定（CocoaPods 通常 `ios/Classes/`，SPM 通常 `ios/Sources/native_bridge/`）；在 `tool/gen.sh` 中用变量固化并在 evidence 记录，不要硬编码猜测。

检查生成物：`ShellHostApi`、`TickStreamApi`/`TicksStreamHandler`、`ShellFlutterApi`、`SystemInfo`、`NativeScreenResult`、`FlutterError`、`PigeonEventSink`（Kotlin 生成包为 `com.dk.fluttershell.bridge.generated`）。**记录实际类名到 evidence。**

### 3.2 Compose 编译插件（AGP 9 内置 Kotlin）

Flutter 3.47.9 模板使用 AGP 9.1.0 + Kotlin 2.4.0；插件模块不显式应用 `org.jetbrains.kotlin.android`（AGP 内置 Kotlin），但 Compose 仍需 Compose 编译器插件。

1. 在 `apps/shell_app/android/settings.gradle.kts` 的 `plugins` 块增加（版本 = 同文件 Kotlin 版本，模板预期 `2.4.0`）：

```kotlin
id("org.jetbrains.kotlin.plugin.compose") version "2.4.0" apply false
```

2. 在 `packages/native_bridge/android/build.gradle.kts` 的 `plugins` 块增加：

```kotlin
id("org.jetbrains.kotlin.plugin.compose")
```

如果 Gradle 报找不到 Compose 插件：在插件模块 `buildscript.dependencies` 增加 `classpath("org.jetbrains.kotlin:compose-compiler-gradle-plugin:<同 Kotlin 版本>")` 后重试。若报 Compose 编译器与 Kotlin 版本不匹配，以 AGP 9.1 内置 Kotlin 的实际版本为准（从 Gradle 错误/AGP 文档确认），只调整 Compose 插件版本并记录；不得升级整个项目的 Kotlin。仍失败则停止并记录，不得改用 XML 或删除原生页。

3. 插件 `android { ... }` 增加 `buildFeatures { compose = true }`；依赖：

```kotlin
implementation(platform("androidx.compose:compose-bom:2026.09.00"))
implementation("androidx.activity:activity-compose:1.13.0")
implementation("androidx.compose.material3:material3")
implementation("androidx.compose.ui:ui")
implementation("org.jetbrains.kotlinx:kotlinx-coroutines-android:1.11.0")
```

保留模板已有的 Flutter embedding 配置与 test 配置，不要重写构建脚本。

### 3.3 Kotlin 实现文件

```text
android/src/main/kotlin/com/dk/fluttershell/bridge/
├── NativeBridgePlugin.kt        # FlutterPlugin + ActivityAware
├── ShellHostApiImpl.kt
├── TicksStreamHandlerImpl.kt
├── NativeResultBus.kt
├── NativeResultDispatcher.kt
├── NativeInfoActivity.kt
├── SystemInfoMapper.kt
└── generated/ShellApi.g.kt      # 生成，不手改
android/src/main/res/values/strings.xml
android/src/main/res/values/themes.xml
android/src/main/AndroidManifest.xml
android/src/test/kotlin/com/dk/fluttershell/bridge/SystemInfoMapperTest.kt
```

**NativeBridgePlugin**：`onAttachedToEngine` 注册 HostApi（`ShellHostApi.setUp(messenger, api)`）、`TicksStreamHandler.register(messenger, handler)`、创建 `NativeResultDispatcher(ShellFlutterApi(messenger))` 并 `NativeResultBus.install`；`ActivityAware` 维护 `activity` 引用；`onDetachedFromEngine` 反注册/取消 scope/清空 bus。不得在 `MainActivity` 加桥接代码。

**ShellHostApiImpl**：实现生成接口；`getSystemInfo` 在 `withContext(Dispatchers.IO)` 读取 PackageManager；`openNativeScreen` 在主线程 `startActivity`；错误抛生成包中的 `FlutterError`（`com.dk.fluttershell.bridge.generated.FlutterError`）。`SystemInfoMapper` 提供可纯 JVM 测试的 `formatOsVersion(release, sdkInt)`、`buildNumber(versionCode, longVersionCode, sdkInt)`、`orUnknown(value)`。

**TicksStreamHandlerImpl**：继承生成类 `TicksStreamHandler`；`onListen` 用 `CoroutineScope(SupervisorJob() + Dispatchers.Main.immediate)` 每秒 `sink.success(tick++)`；`onCancel` 取消并打印 `TICK_STOPPED`；`dispose()` 取消 scope。

**NativeResultDispatcher**：持有生成的 `ShellFlutterApi` 代理与 App 级协程 scope，`dispatch(result)` → `scope.launch { flutterApi.onNativeScreenResult(result) }`；失败只记日志。

**NativeResultBus**：`object`，install/uninstall dispatcher；`send` 时：无 dispatcher → `RESULT_DROPPED`；有 → `RESULT confirmed=... message=...` + dispatch。仅单引擎。

**NativeInfoActivity**：`ComponentActivity` + Compose；读取 02 定义的 extras；Confirm/Cancel；返回键按取消处理；`dispatched` 标志保证只回传一次；退出前调用 `NativeResultBus.send`。文案放 `res/values/strings.xml`（`native_confirm` / `native_cancel`）。

**Manifest**：插件 manifest 的 `<application>` 内声明 Activity，`exported=false`，`theme=@style/Theme.NativeBridge`。**themes.xml** 使用 `android:Theme.Material.Light.NoActionBar`，避免引入 AppCompat。

### 3.4 原生单元测试

使用模板自带 `kotlin-test` + JUnit Platform（不要改成 JUnit4）：

```kotlin
package com.dk.fluttershell.bridge

import kotlin.test.Test
import kotlin.test.assertEquals

class SystemInfoMapperTest {
    @Test
    fun formatsOsVersion() {
        assertEquals("Android 16 (API 36)", SystemInfoMapper.formatOsVersion("16", 36))
    }

    @Test
    fun usesLongVersionCodeFromApi28() {
        assertEquals("42", SystemInfoMapper.buildNumber(7, 42L, 28))
        assertEquals("7", SystemInfoMapper.buildNumber(7, 42L, 27))
    }

    @Test
    fun fallsBackForBlankValues() {
        assertEquals("unknown", SystemInfoMapper.orUnknown("  "))
    }
}
```

### 3.5 验证

```bash
cd apps/shell_app
fvm flutter build apk --debug

cd android
./gradlew testDebugUnitTest
```

同时检查生成物已在 `git status` 中；`git diff --exit-code` 只允许出现本次新增文件。

### 3.6 Gate 与证据

debug APK 构建成功；`./gradlew testDebugUnitTest` 通过；生成物与预期类名一致；插件 manifest 合并后 Activity 出现在合并清单：

```bash
grep -R "NativeInfoActivity" apps/shell_app/build/app/intermediates/merged_manifests/debug/ 2>/dev/null
```

（路径以实际构建目录为准；找不到就使用 `apkanalyzer manifest print` 或 `aapt2 dump xmltree` 验证并记录方法。）

证据：`docs/evidence/p3-bridge-android.md`。

## P4 · Dart 桥接封装与演示页

### 4.1 native_bridge Dart 封装

创建：

```text
lib/native_bridge.dart
lib/src/shell_bridge.dart
lib/src/bridge_exception.dart
```

- `BridgeException(code, message, details)`。
- `NativeBridge` 按 `02` 第 3 节实现；构造可注入 `ShellHostApi` / `TickStreamApi` 供单测；`initialize()` 注册 `ShellFlutterApi.setUp(...)`；`getSystemInfo/openNativeScreen` 捕获 `PlatformException` 转 `BridgeException`；`ticks()` 未初始化抛 `StateError`；`nativeScreenResults` 为 broadcast；`dispose()` 关闭流并尝试 `ShellFlutterApi.setUp(null)`。
- `native_bridge.dart` 只导出 `NativeBridge`、`BridgeException`、`SystemInfo`、`NativeScreenResult`。
- 单测 `test/native_bridge_test.dart`：用 `implements ShellHostApi` 的假实现抛 `PlatformException(code: 'NO_ACTIVITY')`，断言映射；假 `TickStreamApi` 返回 `Stream.value(1)`（若生成类不可实现，改用集成测试并在证据中说明）。

### 4.2 app 接线

- `lib/core/bridge/bridge_providers.dart`：`@riverpod NativeBridge nativeBridge(Ref ref) => throw StateError('Override in bootstrap');`
- `bootstrap.dart` 创建 `NativeBridge()..initialize()` 并加入 `ProviderScope` 覆盖。
- `features/bridge_demo/application/bridge_demo_providers.dart`：
  - `@riverpod Future<SystemInfo> systemInfo(Ref ref)`
  - `@riverpod Stream<int> tickCount(Ref ref)`
  - `@riverpod Stream<NativeScreenResult> nativeScreenResults(Ref ref)`
- 路由增加 `/bridge`；Home 增加按钮（l10n `openBridgeDemo`）。

### 4.3 桥接演示页

`bridge_demo_page.dart` 用 `ConsumerWidget`：

- AppBar 标题 `bridgeDemoTitle`；
- System Info 卡片：`AsyncValue` 三态；刷新按钮 `ref.invalidate(systemInfoProvider)`；
- Ticker 卡片：独立 `Consumer` watch `tickCountProvider`，显示 `ticksValue(count)`；离开页面自动停止；
- Native Screen 卡片：按钮调用 `openNativeScreen(title: l10n.nativeScreenTitle, message: l10n.helloSubtitle)`；`ref.listen(nativeScreenResultsProvider, ...)` 显示 SnackBar（确认/取消两条 l10n）；错误显示通用错误。
- 所有文案来自 l10n；布局用 `app_ui` 组件与 tokens。

### 4.4 测试与手工验收

```bash
cd apps/shell_app
fvm dart run build_runner build --delete-conflicting-outputs
fvm flutter gen-l10n
fvm flutter analyze --fatal-infos
fvm flutter test
fvm flutter test integration_test/bridge_e2e_test.dart -d emulator-5554
```

集成测试 `integration_test/bridge_e2e_test.dart`：

```dart
void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('bridge method and ticker work on device', (tester) async {
    final bridge = NativeBridge()..initialize();
    final info = await bridge.getSystemInfo();
    expect(info.platform, 'android');
    expect(info.osVersion, contains('API '));
    final ticks = await bridge.ticks().take(2).toList().timeout(const Duration(seconds: 6));
    expect(ticks.length, 2);
    expect(ticks.first, 0);
  });
}
```

手工验收（必须实际执行）：

1. 启动 app → 进入桥接页；
2. 点击刷新 → 6 个字段出现；
3. ticker 递增，离开页面后 logcat `TICK_STOPPED`；
4. 打开原生页 → `dumpsys activity activities | grep -i NativeInfoActivity`；
5. 点击 Confirm → SnackBar + logcat `RESULT confirmed=true`；
6. 再次进入，点击 Cancel / 返回键 → `confirmed=false`；
7. 截图保存到 `docs/evidence/images/`。

### 4.5 Gate 与证据

集成测试通过；手工 7 步全部通过；`docs/evidence/p4-bridge-flutter.md` 含命令/截图/logcat 片段。

## P5 · 网络与存储抽象

### 5.1 app_core 实现

```text
lib/src/network/api_client.dart
lib/src/network/dio_api_client.dart
lib/src/storage/key_value_store.dart
lib/src/storage/shared_preferences_key_value_store.dart
```

- `ApiClient`：`Future<Map<String, Object?>> getJson(Uri uri, {Map<String, String>? headers})`。
- `DioApiClient`：构造接收 `baseUrl` 与可选 `Dio`；超时 10s；非 Map JSON、非 2xx、`DioException` → `NetworkFailure`。
- `KeyValueStore`：`read/write/delete`；`SharedPreferencesKeyValueStore` 使用 legacy `SharedPreferences.getInstance()`（便于测试），key 自动补 `app.` 前缀；异常 → `StorageFailure`。
- 不接入任何业务调用。

### 5.2 app 接线

`lib/core/network/network_providers.dart` 与 `lib/core/storage/storage_providers.dart` 提供 `apiClientProvider`、`keyValueStoreProvider`；依赖 `appEnvProvider`。v0 不被 UI 使用。

### 5.3 测试

- `app_core/test/dio_api_client_test.dart`：自定义 `HttpClientAdapter` 返回 200 JSON → 读取成功；返回 500/非 JSON → `NetworkFailure`。
- `app_core/test/key_value_store_test.dart`：测试入口先 `TestWidgetsFlutterBinding.ensureInitialized()`；`SharedPreferences.setMockInitialValues({})`；写读删；确认 key 前缀。
- `app_core/test/app_env_test.dart`：`AppEnv.parse('dev'/'prod')` 正确；`AppEnv.parse('staging')` 抛 `ArgumentError`；不依赖 `--dart-define`。

### 5.4 Gate 与证据

`fvm flutter test`（app_core）通过；analyze 零 issue；`docs/evidence/p5-data-abstractions.md`。

## P6 · 脚本、CI、release 与基线

### 6.1 脚本（`tool/`）

全部 `chmod +x`，统一 `set -euo pipefail`，优先使用 `fvm`：

```bash
# 解析命令的公共片段
if command -v fvm >/dev/null 2>&1; then
  FLUTTER=(fvm flutter); DART=(fvm dart)
else
  FLUTTER=(flutter); DART=(dart)
fi
```

- `bootstrap.sh`：检查 fvm → `fvm install` → `fvm flutter pub get`（根）→ `bash tool/gen.sh`。
- `gen.sh`：Pigeon → app 的 build_runner → `flutter gen-l10n`（顺序执行，任一失败退出）；顶部用变量定义 Pigeon 的三个输出路径，其中 iOS 源码目录按 P1 实际模板设置。
- `check_imports.sh`：实现 R1–R4（见 `01` 第 4 节）；使用 `rg`，找不到 `rg` 时用 `grep -R` 等价实现；扫描时排除 `*.g.dart`/生成目录；违例打印文件/行号并退出 1。
- `check.sh`：格式化手写 Dart（用 `find` 生成文件列表，排除 `*.g.dart`、`src/generated`、`l10n/generated`；不要直接对包目录跑 `dart format`，否则会格式化生成物）→ `check_imports.sh` → 四个包逐一 `flutter analyze --fatal-infos`。
- `test.sh`：对存在 `test/` 的包执行 `flutter test`。
- `test_native_android.sh`：若 `apps/shell_app/android/local.properties` 不存在，先执行 `fvm flutter build apk --debug` 生成 Flutter SDK 路径；然后 `cd apps/shell_app/android && ./gradlew testDebugUnitTest`。
- `build_android.sh [--release]`：debug 注入 `APP_ENV=dev`；release 注入 `APP_ENV=prod`，带 `--split-per-abi --obfuscate --split-debug-info=build/symbols`。
- `run_android.sh [device]`：默认 `emulator-5554`，`flutter run`。
- `e2e_android.sh [device]`：`flutter test integration_test/bridge_e2e_test.dart -d <device>`。

### 6.2 CI

`.github/workflows/ci.yml`：

```yaml
name: ci
on:
  push:
    branches: [main]
  pull_request:

jobs:
  verify:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - uses: actions/setup-java@v4
        with:
          distribution: temurin
          java-version: "17"
      - name: Resolve Flutter version
        run: echo "FLUTTER_VERSION=$(python3 -c 'import json;print(json.load(open(".fvmrc"))["flutter"])')" >> "$GITHUB_ENV"
      - uses: subosito/flutter-action@v2
        with:
          flutter-version: ${{ env.FLUTTER_VERSION }}
          channel: stable
          cache: true
      - name: Android SDK 36
        run: |
          SDKMANAGER="$(command -v sdkmanager || echo "$ANDROID_HOME/cmdline-tools/latest/bin/sdkmanager")"
          yes | "$SDKMANAGER" --licenses > /dev/null
          "$SDKMANAGER" --install "platforms;android-36" "build-tools;36.0.0"
      - run: flutter doctor -v
      - run: flutter pub get
      - run: bash tool/gen.sh
      - name: Generated code must be committed
        run: test -z "$(git status --porcelain)"
      - run: bash tool/check.sh
      - run: bash tool/test.sh
      - run: bash tool/build_android.sh --debug
      - run: bash tool/test_native_android.sh
      - uses: actions/upload-artifact@v4
        with:
          name: shell-debug-apk
          path: apps/shell_app/build/app/outputs/flutter-apk/app-debug.apk
```

注意：

- CI 没有 fvm，脚本自动回退到 `flutter`/`dart`；
- Ubuntu runner 自带 Android SDK；若 Gradle 提示缺 license，增加 `yes | sdkmanager --licenses` 并记录；
- 仓库无远程时 workflow 只做静态核查，`docs/04` 验收要如实标注。

### 6.3 安全 hardening

- `apps/shell_app/android/app/src/main/AndroidManifest.xml` 的 `<application>` 增加 `android:usesCleartextTraffic="false"`、`android:allowBackup="false"`，确认 `android:label="Shell"`；
- 新增 `apps/shell_app/android/key.properties.example`（`storeFile/storePassword/keyAlias/keyPassword` 占位），确认 `key.properties` 被忽略；
- v0 主 manifest 不添加 `INTERNET` 权限（无真实请求）；
- 在 evidence 中记录 manifest 片段，供 `04` 的 SEC2/SEC3 引用。

### 6.4 Release 与基线

```bash
bash tool/build_android.sh --release
ls -lh apps/shell_app/build/app/outputs/flutter-apk/*.apk
```

启动基线（debug 或 release 各 3 次，模拟器冷启动）：

```bash
adb shell am force-stop com.dk.fluttershell
adb shell am start -W -n com.dk.fluttershell/.MainActivity
```

记录 TotalTime 中位数、APK 体积到 `docs/evidence/p6-ci-release.md`。不设通过阈值，只要求有真实数字。

### 6.5 Gate 与证据

`bootstrap.sh`、`gen.sh`、`check.sh`、`test.sh`、`test_native_android.sh`、`build_android.sh --debug`、`--release` 全部通过；生成物无 diff；manifest hardening 完成；CI 文件通过 YAML 语法检查（`python3 -c 'import yaml,sys; yaml.safe_load(open(".github/workflows/ci.yml"))'`，无 PyYAML 则用 Ruby/Node 等价校验并记录）。

## P7 · iOS 桩（不验收）

1. 确认 `ShellApi.g.swift` 已生成且被 iOS target 包含：CocoaPods 检查 podspec 的 `source_files`，SPM 检查 `Package.swift` 的 target 目录；以实际模板为准。
2. 在 `NativeBridgePlugin.swift` 中实现最小桩：
   - 按生成物提供的 Setup API 注册 HostApi（以 `ShellApi.g.swift` 为准）；所有方法抛 `PigeonError(code: "UNIMPLEMENTED", message: "iOS bridge not implemented", details: nil)`；
   - 注册事件 handler：`onListen` 立即 `sink.error(...)`，不产生数据；
   - 不实现 FlutterApi 调用。
3. 不运行 `pod install`、不编译、不修改 iOS Runner。
4. 在 `01` 与 `04` 明确标注“未验证”。

Gate：文件存在、内容为显式 UNIMPLEMENTED 桩；`git status` 无其他 iOS 改动。

## P8 · 收尾与最终验收

1. 全量执行 `04-acceptance.md`；
2. 检查 `00`/`01`/`02`/`03`/`04`/`AGENTS.md` 与实际实现一致（类名、路径、命令、版本）；
3. 删除临时文件、调试代码、未使用的模板资源；替换/删除 `flutter create` 生成的示例 README、CHANGELOG 中与 example 相关的描述，避免误导；
4. 补齐 `docs/evidence/p0..p8`，所有“通过”都有输出/截图；
5. 更新 `README.md` 的当前状态与命令；
6. 在 `docs/evidence/p8-final.md` 写：完成项、已知限制（iOS、远程 CI、release 签名、模拟器性能）、最终 commit 哈希；
7. 汇报给用户，等待是否推送/下一步指令。

## 附录 A · 常用命令速查

| 目的 | 命令 |
| --- | --- |
| 初始化 | `bash tool/bootstrap.sh` |
| 生成 | `bash tool/gen.sh` |
| 静态检查 | `bash tool/check.sh` |
| Dart 测试 | `bash tool/test.sh` |
| 原生单测 | `bash tool/test_native_android.sh` |
| 运行 | `bash tool/run_android.sh emulator-5554` |
| 集成测试 | `bash tool/e2e_android.sh emulator-5554` |
| Debug 构建 | `bash tool/build_android.sh` |
| Release 构建 | `bash tool/build_android.sh --release` |
| 冷启动测量 | `adb shell am start -W -n com.dk.fluttershell/.MainActivity` |

## 附录 B · 每阶段必交证据

| 阶段 | 证据内容 |
| --- | --- |
| P0 | 版本、doctor、AVD、adb |
| P1 | pub get、debug 构建、Gradle projects、模板版本 |
| P2 | analyze/test、Hello 中英文截图 |
| P3 | 生成类名、debug 构建、Kotlin 单测、合并清单 |
| P4 | 集成测试、7 步手工验收、截图、logcat |
| P5 | 单测输出、analyze |
| P6 | 全部脚本、release APK 体积、启动 TotalTime、CI YAML 校验 |
| P7 | iOS 桩文件清单 |
| P8 | 全量验收表、最终 commit、已知限制 |
