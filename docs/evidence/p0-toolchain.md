# P0 · 工具链证据（2026-10-31）

## 环境与安装方式

- 机器：macOS 15.6.1 (24G90)，Apple Silicon（arm64）。
- 说明：GitHub 在本机网络不可达（连接 443 超时），因此部分组件未按文档默认渠道安装，替换为等价来源并记录：
  - **JDK 17**：`brew install --cask temurin@17` 下载失败（Temurin 托管在 GitHub）。改用 **Azul Zulu JDK 17**（`zulu17.70.113-ca-jdk17.0.21.0.3`，OpenJDK 17.0.21.0.3 LTS），解压到 `~/Library/Java/JavaVirtualMachines/`，`flutter config --jdk-dir` 已指向。`JAVA_HOME` 已写入 `~/.zshrc`。
  - **Flutter 3.47.9**：`fvm install 3.47.9` 卡死（FVM 从 GitHub 拉取）。改为从 `storage.googleapis.com/flutter_infra_release/releases/stable/macos/flutter_macos_arm64_3.47.9-stable.zip` 直接下载并解压到 `~/fvm/versions/3.47.9`，`.fvmrc` 手写为 `{"flutter":"3.47.9"}`，`.fvm/flutter_sdk` 软链指向该目录；`fvm list` 已识别（stable / Flutter 3.47.9 / Dart 3.13.7）。
  - 其余（Android cmdline-tools、SDK 组件、Gradle 发行版）按标准渠道安装；Gradle 9.3.1 发行版首次由 wrapper 下载中断，手动 `curl -C -` 续传后放入 `~/.gradle/wrapper/dists/`。
- `fvm flutter config --no-version-check` 已设置（避免 flutter 工具启动时访问 GitHub 导致阻塞）。

## 版本输出

```
$ fvm flutter --version
Flutter 3.47.9 • channel stable • https://github.com/flutter/flutter.git
Framework • revision c197ca5199 (28 hours ago) • 2026-10-29 10:10:20 -0400
Engine • hash 9e025265bef30b838c0c1b68cad19decf97048f2 (revision 89c39edfdf) (3 days ago) • 2026-10-27 19:51:20.000Z
Tools • Dart 3.13.7 • DevTools 2.60.0

$ java -version（Zulu 17）
openjdk version "17.0.21.0.3" 2026-10-24 LTS
OpenJDK Runtime Environment Zulu17.70+113-CA (build 17.0.21.0.3+1-LTS)
```

## flutter doctor 摘要

```
[✓] Flutter (Channel stable, 3.47.9, on macOS 15.6.1 24G90 darwin-arm64)
[✓] Android toolchain - develop for Android devices (Android SDK version 36.0.0)
    • Android SDK at /Users/dk/Library/Android/sdk
    • Java binary at ~/Library/Java/JavaVirtualMachines/zulu17.70.113-.../Contents/Home/bin/java
    • Java version OpenJDK Runtime Environment Zulu17.70+113-CA (build 17.0.21.0.3+1-LTS)
[!] Xcode - develop for iOS and macOS   ← 允许（本轮不验收 iOS）
[✓] Chrome - develop for the web
[✓] Connected device (2 available)
[!] Network resources                    ← GitHub 不可达导致的资源检查警告，可接受
```

## Android SDK 组件（E6）

```
platform-tools；emulator；platforms;android-36；build-tools;36.0.0；
system-images;android-36;google_apis;arm64-v8a
（system-image 首次安装 zip 损坏，重跑 sdkmanager 后成功）
```

## AVD 与模拟器（E4/E5）

- AVD 名称：`shell_api36`（`emulator -list-avds` 输出 `shell_api36`）。
- 启动命令：`emulator -avd shell_api36 -no-snapshot -no-boot-anim &`
- `adb devices`：`emulator-5554  device`；`getprop sys.boot_completed` = `1`。
- 模板 app 安装并启动成功：`adb install -r app-debug.apk` → `Success`；`am start -W` → `Status: ok`。

## 未验证项

- Xcode 完整安装（本轮不需要，iOS 仅生成桩）。
