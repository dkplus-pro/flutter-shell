# P1 · 仓库脚手架证据（2026-10-31）

## 执行内容

1. `fvm flutter create --org com.dk --project-name fluttershell --platforms=android,ios apps/shell_app`
2. `fvm flutter create --template=package packages/app_core` / `packages/app_ui`
3. `fvm flutter create --template=plugin --org com.dk.fluttershell --project-name native_bridge --platforms=android,ios packages/native_bridge`；删除 `example/`。
4. 删除各成员局部 `analysis_options.yaml`（保留仓库根，避免覆盖 very_good_analysis）；从成员 pubspec 移除 `flutter_lints`。
5. 插件 namespace 迁移：Kotlin 目录 `com/dk/fluttershell/native_bridge` → `com/dk/fluttershell/bridge`，`build.gradle.kts` 的 `group`/`namespace`、`AndroidManifest.xml` 的 `package`、`pubspec.yaml` 的 `plugin.platforms.android.package` 均改为 `com.dk.fluttershell.bridge`；删除模板自带的 `NativeBridgePluginTest.kt`（旧包名）。
6. 根 `pubspec.yaml`（pub workspace，4 成员 `resolution: workspace`）、根 `analysis_options.yaml`（very_good_analysis 11.0.0 + 生成目录排除）、`.editorconfig`、`.gitignore`（不忽略 `*.g.dart` 等生成物）。
7. app 依赖接上三个本地包路径；删除模板 `pubspec.lock`（workspace 根统一持有）与所有 `.iml`。

## 模板版本记录（供 P3 Compose 插件对齐）

| 项 | 值 |
| --- | --- |
| Gradle wrapper | 9.3.1-all |
| AGP（settings.gradle.kts） | 9.1.0 |
| Kotlin（settings.gradle.kts） | 2.4.0 |
| 插件模块 compileSdk | 36 |
| Java | 17（Zulu 17.0.21） |

## 验证输出

```
$ fvm flutter pub get
（workspace 解析成功；统一 package_config 到根 .dart_tool）

$ cd apps/shell_app && fvm flutter build apk --debug
✓ Built build/app/outputs/flutter-apk/app-debug.apk   （145M，debug）

$ cd android && ./gradlew projects
+--- Project ':app'
+--- Project ':integration_test'
\--- Project ':native_bridge'
（:native_bridge 由 Flutter 插件机制自动纳入，未手写 include）

$ adb install -r app-debug.apk → Success
$ adb shell am start -W -n com.dk.fluttershell/.MainActivity → Status: ok
```

模拟器截图：`docs/evidence/images/p1-template-home.png`（模板 counter 页运行正常，P2 将替换）。

## Gate 结论

- pub get 成功 ✅
- debug APK 构建成功 ✅
- `./gradlew projects` 含 `:native_bridge` ✅
- 模拟器安装并打开默认页面 ✅
