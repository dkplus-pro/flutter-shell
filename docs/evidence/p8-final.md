# 最终验收报告（P8）

- **日期**：2026-10-31
- **Commit**：代码与文档同步 `a846f12`（本报告在紧随其后的提交中；两提交内容共同构成本报告依据）
- **环境**：macOS 15.6.1 arm64；Flutter 3.47.9 / Dart 3.13.7（FVM，见 `p0-toolchain.md` 的安装方式说明）；JDK 17（Zulu 17.0.21）；AGP 9.1.0 / Kotlin 2.4.0 / Gradle 9.3.1 / Pigeon 29.1.0；设备：AVD `shell_api36`（Pixel 7，API 36，arm64）。

## 分项结果

| 项 | 结果 | 证据 |
| --- | --- | --- |
| 代码生成（B8/C1） | PASS：`tool/gen.sh` 后生成物路径 `git status --porcelain` 为空 | 本报告当日实测 |
| 静态检查（Q1/Q2/Q5） | PASS：`check.sh`（格式 80 列 + 边界 + 四包 analyze）exit 0 | 当日实测；DEC-020 |
| Dart 测试（Q3/Q6） | PASS：shell_app 5、app_core 9、native_bridge 4，共 **18** 用例，覆盖 env 解析/Dio 映射/存储读写删/BridgeException 映射 | `test.sh` 输出 |
| Kotlin 测试（Q4） | PASS：`testDebugUnitTest` BUILD SUCCESSFUL；`SystemInfoMapperTest` 3 用例 PASSED（另有 shared_preferences 插件自带 13 个用例） | Gradle 输出 |
| Debug 构建（B1） | PASS：`✓ Built app-debug.apk`（207M，fat debug） | `p6-ci-release.md` |
| Release 构建（B2/B3/B4） | PASS：3 ABI（17.4/14.6/18.9M），显式 `APP_ENV=prod --obfuscate --split-per-abi --split-debug-info=build/symbols`；symbols 已生成且被忽略；**debug 签名，不可发布** | `p6-ci-release.md` |
| 运行时链路 B1–B6 | PASS：7 步手工验收 + 集成测试 `All tests passed`（platform=android、ticks≥2） | `p4-bridge-flutter.md` + `images/` |
| ticker 停止（B3） | PASS：logcat `TICK_STOPPED` | 同上 |
| 错误映射（B7/R5–R8） | PASS：单测注入 `PlatformException(NO_ACTIVITY)` → `BridgeException`；页面 loading/error 三态有 widget 测试 | `native_bridge_test.dart`、`bridge_demo_page_test.dart` |
| 中英文（R3/6.5） | PASS：widget 测试 en/zh 文案断言 + 模拟器 per-app locale 实机截图 | `p2-foundation.md` + `images/p2-home-{en,zh}.png` |
| 结构验收 S1–S11 | PASS：无 counter 残留、无 print/debugPrint、无手写 MethodChannel、无 TODO/FIXME、analysis_options 仅根级 | 当日 grep 实测 |
| 安全 SEC1–SEC6 | PASS：无签名文件入库；`usesCleartextTraffic=false`、`allowBackup=false`；原生页 `exported=false`；无 PII 日志；dart-define 仅 APP_ENV/API_BASE_URL | `p6-ci-release.md` |
| iOS（I1–I5） | PASS（仅结构）：Swift 生成物 + UNIMPLEMENTED 桩存在；podspec 覆盖 Generated/；未编译未运行 | `p7-ios-stub.md` |
| CI（CI1–CI6） | PASS（静态）：YAML 可解析、步骤与 tool/ 一致、含 codegen 门禁与 APK artifact；**未在远程运行** | `p6-ci-release.md` |

## 性能基线（模拟器，不设阈值，不代表真机）

- 冷启动 TotalTime 中位数：release（arm64）**3351ms**；debug **5386ms**（各 3 次）。
- APK 体积：debug 207M；release arm64-v8a 17.4M / armeabi-v7a 14.6M / x86_64 18.9M。
- 静态核查：首帧前无桥接调用；ticker 只在独立 `Consumer` watch。

## 未验证项

1. **iOS**：未编译、未运行、未 `pod install`（DEC-010）。
2. **远程 CI**：仓库无远程，GitHub Actions 未实际运行（仅本地静态核查 + YAML 校验）。
3. release 使用 debug 签名，仅构建验证。

## 已知限制（`docs/04` §12）

iOS 桩未验证；远程 CI 未运行；`NativeResultBus` 单引擎；原生演示页属可替换演示资产；release 不可发布；性能数字来自模拟器；网络/存储为占位抽象。

## 决策偏离记录（相对 03 初稿，均已登记 docs/00）

- DEC-015：build_runner 2.16.2（riverpod_generator 4.0.9 约束冲突）。
- DEC-016：声明式构造语法（very_good_analysis 11 强制）。
- DEC-017：Compose BOM 2025.09.00→2025.09.01（2026.09.00 需 compileSdk 37）。
- DEC-018：iOS 生成物 SPM 实际路径。
- DEC-019：core/router 的 R3 例外。
- DEC-020：dart format 页宽 80（VGA lint 兼容）。
- P0 工具链安装渠道替换（GitHub 不可达），见 `p0-toolchain.md`。

## 结论

**可交付（v0 范围内）**：Android 三条桥接链路真实跑通、可回归；架构、规范、脚本、CI 定义与文档一致；iOS 与远程 CI 按 DEC-010/DEC-012 明确列为未验证。
