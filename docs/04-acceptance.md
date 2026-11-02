# 04 · 验收清单

> 验收原则：**跑真实链路、看工具自己的计数、留证据**。退出码为 0 不算通过；必须检查输出中的数量、字段、日志标记与截图。  
> 所有命令在仓库根目录执行，除非另有说明。证据写入 `docs/evidence/`。

## 1. 环境验收（P0）

| 编号 | 检查 | 命令 | 通过标准 |
| --- | --- | --- | --- |
| E1 | Flutter 版本 | `fvm flutter --version` | 输出 `3.47.9` 与 Dart `3.13.7` |
| E2 | Java | `java -version` | 17.x；`fvm flutter config --jdk-dir` 已指向 |
| E3 | Android 工具链 | `fvm flutter doctor -v` | Android toolchain ✓、Java ✓；Xcode ✗ 允许并记录 |
| E4 | 设备 | `adb devices` | 至少一台 `device` 状态 |
| E5 | AVD | `emulator -list-avds` | 含 `shell_api36` |
| E6 | SDK 级别 | `sdkmanager --list_installed` | 含 platform 36、build-tools 36、platform-tools、emulator |

证据：`docs/evidence/p0-toolchain.md`（完整输出，不只是命令）。

## 2. 结构验收

| 编号 | 检查 | 命令 / 方法 | 通过标准 |
| --- | --- | --- | --- |
| S1 | 目录完整 | `find apps packages docs tool .github -maxdepth 3 -type f` | 与 `01` 第 3 节一致；关键文件全部存在 |
| S2 | 工作区 | 根 `pubspec.yaml`、四个成员 `resolution: workspace` | `fvm flutter pub get` 成功 |
| S3 | 依赖边界 | `bash tool/check_imports.sh` | 输出空、退出 0 |
| S4 | 插件模块 | `cd apps/shell_app/android && ./gradlew projects` | 含 `:native_bridge` 与 `:app` |
| S5 | 生成物提交 | `git ls-files` 检查 | 三端生成物、`pubspec.lock`、`.fvmrc` 已跟踪 |
| S6 | 规范文件 | `test -f AGENTS.md && test -f docs/04-acceptance.md` | 存在且非空 |
| S7 | 无模板残留 | `rg -n "counter|MyHomePage" apps/shell_app/lib` | 无输出（模板 counter 已删除） |
| S8 | 无调试输出 | `rg -n "print\\(|debugPrint\\(" apps/shell_app/lib packages/*/lib --glob '!**/generated/**'` | 无输出 |
| S9 | 无手写 MethodChannel | `rg -n "MethodChannel" apps/shell_app/lib packages/*/lib --glob '!**/generated/**' --glob '!**/*.g.dart'` | 无输出（桥接只走 Pigeon） |
| S10 | TODO 洁癖 | `rg -n "TODO|FIXME|HACK" apps/shell_app/lib packages/*/lib packages/native_bridge/android/src/main/kotlin --glob '!**/generated/**'` | 无输出；iOS 桩的 UNIMPLEMENTED 不算 TODO |
| S11 | lint 唯一入口 | `find apps packages -name analysis_options.yaml` | 无输出（只保留仓库根配置，避免局部规则覆盖 VGA） |

## 3. 代码生成验收

```bash
bash tool/gen.sh
git status --porcelain -- \
  apps/shell_app/lib/l10n/generated \
  packages/native_bridge/lib/src/generated \
  packages/native_bridge/android/src/main/kotlin/com/dk/fluttershell/bridge/generated \
  packages/native_bridge/ios
```

| 编号 | 通过标准 |
| --- | --- |
| C1 | 命令退出 0；上述路径 `git status` 为空（无修改、无未跟踪文件） |
| C2 | `pubspec.lock` 中 Pigeon 版本为 29.1.0，且只出现一个版本 |
| C3 | Kotlin 生成物包含 `ShellHostApi`、`TicksStreamHandler`、`ShellFlutterApi`、`FlutterError`、`PigeonEventSink`（在 `com.dk.fluttershell.bridge.generated`） |
| C4 | Dart 生成物包含 `SystemInfo`、`NativeScreenResult`、`ShellHostApi`、`TickStreamApi` 的 `Stream<int> ticks()`、`ShellFlutterApi` |
| C5 | 手写代码未修改生成文件（生成后无 diff 即证明） |

## 4. 静态与单元验收

```bash
bash tool/check.sh
bash tool/test.sh
bash tool/test_native_android.sh
```

| 编号 | 检查 | 通过标准 |
| --- | --- | --- |
| Q1 | 格式化 | `check.sh` 中 `dart format --set-exit-if-changed` 通过 |
| Q2 | analyze | 四个包 `flutter analyze --fatal-infos` 均输出 `No issues found!` |
| Q3 | Dart 测试 | `test.sh` 汇总显示全部测试通过；不只看退出码 |
| Q4 | Kotlin 测试 | Gradle 输出 `BUILD SUCCESSFUL`，且测试任务执行了 `SystemInfoMapperTest` 的 3 个用例（模板 `testLogging` 会打印 passed） |
| Q5 | 边界 | `check_imports.sh` 无违例 |
| Q6 | 单测覆盖点 | 至少覆盖：`AppEnv` 解析、Dio 成功/失败映射、存储读写删除、`BridgeException` 映射、`SystemInfoMapper` |

## 5. 构建验收

```bash
bash tool/build_android.sh            # debug，APP_ENV=dev
bash tool/build_android.sh --release  # APP_ENV=prod + 混淆 + split-per-abi
ls -lh apps/shell_app/build/app/outputs/flutter-apk/
```

| 编号 | 检查 | 通过标准 |
| --- | --- | --- |
| B1 | Debug APK | 文件存在且 `> 0` 字节；`flutter build` 输出 `Built ...app-debug.apk` |
| B2 | Release APK | 各 ABI 文件存在；命令显式包含 `APP_ENV=prod`、`--obfuscate`、`--split-debug-info=build/symbols` |
| B3 | 符号文件 | `build/symbols` 存在；未被 git 跟踪 |
| B4 | 签名说明 | release 仍为 debug 签名（已知限制），验收记录中不得称为可发布 |
| B5 | iOS | 不构建；文件结构检查即可（见第 9 节） |

## 6. 运行时验收（真实链路，必须执行）

### 6.1 启动

```bash
emulator -avd shell_api36 -no-snapshot -no-boot-anim &
adb wait-for-device
adb shell getprop sys.boot_completed     # 1
cd apps/shell_app
fvm flutter run -d emulator-5554 --dart-define=APP_ENV=dev
```

| 编号 | 检查 | 通过标准 |
| --- | --- | --- |
| R1 | 首屏 | 显示 `Hello World` 与副标题；无红屏/异常 |
| R2 | 导航 | 点击入口进入 Bridge Demo，返回键回到 Home |
| R3 | 中英文 | 见 6.5 |
| R4 | 日志 | `adb logcat -d -s flutter:I` 无未捕获异常 |

### 6.2 系统信息（B1）

| 步 | 操作 | 通过标准 |
| --- | --- | --- |
| 1 | 进入 Bridge Demo | 页面显示 System information 卡片 |
| 2 | 等待或点刷新 | 6 个字段可见 |
| 3 | 核对 | `platform=android`；`osVersion` 含 `Android` 与 `API `；`buildNumber` 为纯数字；其余非空 |
| 4 | 点击刷新 | 重新加载，无崩溃 |

### 6.3 ticker（B2/B3）

| 步 | 操作 | 通过标准 |
| --- | --- | --- |
| 1 | 观察计数 | 从 0 开始，约每秒 +1；连续 3 秒无重复/跳变 |
| 2 | 返回 Home | `adb logcat -d -s NativeBridge:I` 出现 `TICK_STOPPED` |
| 3 | 再次进入 | 计数重新从 0 开始 |
| 4 | 集成测试 | `fvm flutter test integration_test/bridge_e2e_test.dart -d emulator-5554` 输出 `All tests passed`，且测试内断言 `platform=android`、tick 数量=2 |

### 6.4 原生页往返（B4/B5/B6）

```bash
adb logcat -c
# 在 app 内进入桥接页并点击「Open native screen」
adb shell dumpsys activity activities | grep -i NativeInfoActivity
adb logcat -d -s NativeBridge:I
```

| 步 | 操作 | 通过标准 |
| --- | --- | --- |
| 1 | 打开原生页 | `SCREEN_OPENED` 日志；`NativeInfoActivity` 出现在 dumpsys；页面显示标题/消息 |
| 2 | 点 Confirm | `RESULT confirmed=true message=Confirmed in native screen`；Flutter 页 SnackBar 显示确认 |
| 3 | 重进，点 Cancel | `confirmed=false`；SnackBar 显示取消 |
| 4 | 重进，按返回键 | 只回传一次取消；无重复 SnackBar |
| 5 | 快速连点 | 只回传一次（`dispatched` 生效） |

### 6.5 国际化

- Widget 测试必须覆盖 `Locale('en')` 与 `Locale('zh')` 下 `helloWorld` 的文案不同；
- 手工：系统设置切换语言为中文 → 重启 app → Flutter 页面显示中文；切回英文 → 显示英文。若模拟器切换受系统限制，记录替代方法与证据，不得跳过测试覆盖。

### 6.6 错误与边界

| 编号 | 检查 | 方法 | 通过标准 |
| --- | --- | --- | --- |
| R5 | 桥接错误映射 | `packages/native_bridge/test/native_bridge_test.dart` | 抛 `BridgeException('NO_ACTIVITY')`，code 原样保留 |
| R6 | 网络错误映射 | app_core 单测 | 500/非 JSON → `NetworkFailure` |
| R7 | 存储 | app_core 单测 | 写读删成功，key 带 `app.` 前缀 |
| R8 | 页面三态 | 用测试 fake 注入错误（不临时断网） | loading/error 均有 UI 表现；不把临时断网作为验收手段 |

## 7. 性能基线

在模拟器上执行，记录真实数字（不设硬阈值）：

```bash
adb shell am force-stop com.dk.fluttershell
for i in 1 2 3; do adb shell am start -W -n com.dk.fluttershell/.MainActivity; done
```

| 指标 | 记录内容 |
| --- | --- |
| 冷启动 TotalTime | 3 次原始值 + 中位数（debug 与 release 分开） |
| APK 体积 | 每个 ABI 的 `ls -lh` 结果 |
| 首帧前桥接调用 | 代码检查：`bootstrap` 不调用 `getSystemInfo/ticks/openNativeScreen` |
| ticker 重建范围 | 代码检查：`tickCountProvider` 只在独立 `Consumer` 中 watch |

证据：`docs/evidence/p6-ci-release.md`，不得填写估计值。

## 8. 安全验收

| 编号 | 检查 | 命令 / 方法 | 通过标准 |
| --- | --- | --- | --- |
| SEC1 | 无签名文件入库 | `git ls-files | rg -i "\\.(jks|keystore)$|key\\.properties"` | 无输出 |
| SEC2 | 明文流量关闭 | 检查 release manifest / `AndroidManifest.xml` | `usesCleartextTraffic="false"` |
| SEC3 | 备份关闭 | 检查 manifest | `allowBackup="false"` |
| SEC4 | 原生页不可外部启动 | `aapt2 dump xmltree ... | grep NativeInfoActivity` | `exported=false` |
| SEC5 | 无 PII 日志 | 人工检查日志代码 | 不打印 token/账号/位置 |
| SEC6 | 无秘密进 dart-define | 检查脚本/CI | 只有 `APP_ENV`/`API_BASE_URL` 等非秘密 |

## 9. iOS 验收（仅结构）

| 编号 | 检查 | 通过标准 |
| --- | --- | --- |
| I1 | Swift 生成物存在 | 实际路径以 P3 evidence 记录为准（CocoaPods 通常 `ios/Classes/Generated/`，SPM 通常 `ios/Sources/native_bridge/Generated/`），文件非空 |
| I2 | 桩实现 | `NativeBridgePlugin.swift` 中所有 HostApi 方法抛 `PigeonError(code: "UNIMPLEMENTED")` |
| I3 | 事件流桩 | `onListen` 立即报错，不发送数据 |
| I4 | iOS target 覆盖 | podspec 的 `source_files` 或 SPM `Package.swift` 的 target 目录包含生成物 |
| I5 | 声明 | `docs/01`、`docs/04`、`AGENTS.md` 均标注 iOS 未验证 |

**不得**声称 iOS 编译通过或可运行；本轮没有执行 `pod install` / Xcode 构建。

## 10. CI 验收

| 编号 | 检查 | 通过标准 |
| --- | --- | --- |
| CI1 | workflow 存在 | `.github/workflows/ci.yml` 非空 |
| CI2 | 语法 | YAML 可解析（Python/Ruby/Node 任一） |
| CI3 | 步骤一致 | workflow 调用的脚本与 `tool/` 实际文件名/参数一致 |
| CI4 | 远程状态 | 仓库无远程时标注「未在 GitHub 实际运行」；不得声称 CI 绿 |
| CI5 | codegen 门禁 | workflow 含「生成后 `git status` 为空」步骤 |
| CI6 | 产物 | workflow 上传 debug APK artifact 的路径与实际输出一致 |

## 11. 需求追溯

| 原始需求 | 对应实现 | 验证据 |
| --- | --- | --- |
| 安卓/iOS App 壳，先安卓 | `apps/shell_app`（Android 验收，iOS 桩） | R1–R6、第 9 节 |
| 无业务，Hello World 验证 | Home 页 + 桥接演示 | R1、R2 |
| 良好目录架构 | `01` 第 3/4 节、workspace、边界脚本 | S1–S4、Q5 |
| 良好扩展性 | `01` 第 18 节、`AGENTS.md` 新增流程 | S6、文档评审 |
| 高性能 | 启动/重建/线程规则、release 构建、基线 | 第 7 节、B2 |
| 复用性 | 3 个共享包 + 桥接插件 | S4、`packages/*` 结构 |
| Flutter 构建页面 | Home + Bridge Demo，Material 3，i18n | R1–R3、6.5 |
| Native Bridge 给 Flutter | Pigeon 方法/事件流/FlutterApi | 第 3、6 节 |
| 开发规范写入 AGENT(S).md | 根 `AGENTS.md` | S6 |
| 酒店 AI 客服 Demo：3 tab 壳、聊天页（欢迎语/气泡/快捷面板/时间分组） | `features/hotel`（DEC-021，`docs/05` PRD） | `docs/evidence/hotel-demo.md`、shell/hotel widget 测试 |
| 酒店 Demo：脚本化意图引擎 + 多轮槽位（数量/时间）+ 兜底 | `data/concierge_agent.dart` + `data/slot_parsers.dart` | 意图引擎单测 24 例 |
| 酒店 Demo：订单卡状态机（下单→配送→送达→评价 / 预约终态） | `application/hotel_chat_providers.dart` + `presentation/order_card.dart` | 状态机单测 + 聊天主路径 widget 测试 |
| 酒店 Demo：打字机回复、订单弹层、星级评价 | `presentation/reply_text.dart`（`ReplyTypewriter`）、`order_sheet.dart`、`star_rating_bar.dart` | 组件 widget 测试 14 例 + 集成接线测试 |
| 酒店 Demo：会话持久化与恢复 | `KeyValueStore`（`hotel.chat.messages.v1` / `hotel.orders.v1`） | 持久化往返单测 + 杀进程重启走查 |

## 12. 已知限制（必须写入最终报告）

1. iOS 未编译、未运行、未做 `pod install`。
2. GitHub Actions 未在远程实际运行（无远程仓库）；本地脚本等价验证 + YAML 静态检查。
3. v0 release 使用 debug 签名，不可发布。
4. `NativeResultBus` 仅支持单 Flutter engine。
5. 原生页与回传是演示资产，接真实业务时替换/迁移。
6. 性能数据来自模拟器，仅作基线。
7. 网络/存储为占位抽象，无真实接口验证。

## 13. 完成定义（DoD）

全部满足才算完成：

- [ ] P0–P8 Gate 全部通过，证据齐全；
- [ ] `tool/gen.sh` 后生成物无 diff；
- [ ] `tool/check.sh`、`tool/test.sh`、`tool/test_native_android.sh` 通过，且检查了测试计数；
- [ ] debug/release APK 构建成功，体积/启动数字已记录；
- [ ] 模拟器 7 步手工验收完成，截图与 logcat 标记齐全；
- [ ] 三条桥接链路（方法、事件流、反向回调）真实跑通；
- [ ] 中英文页面验证完成；
- [ ] iOS 桩与“未验证”声明存在；
- [ ] `AGENTS.md` 与 `docs/00`–`04` 内容一致，无过期路径/版本；
- [ ] 无未解决的 TODO/FIXME（iOS UNIMPLEMENTED 除外）；
- [ ] 最终报告包含 commit、环境、通过项、未验证项、已知限制。

## 14. 最终报告模板

```markdown
# 最终验收报告

- 日期：
- Commit：
- 环境（Flutter / Dart / JDK / AGP / Kotlin / 设备）：
- 代码生成：PASS/FAIL（证据路径）
- 静态检查：PASS/FAIL（证据路径）
- Dart/Kotlin 测试：PASS/FAIL（测试数量、证据路径）
- Debug/Release 构建：PASS/FAIL（APK 体积、证据路径）
- 运行时链路：PASS/FAIL（7 步结果、截图、logcat）
- 性能基线：冷启动中位数 / APK 体积
- 未验证项：iOS、远程 CI
- 已知限制：见 04 第 12 节
- 结论：可交付 / 有条件交付（列条件）
```
