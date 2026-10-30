# P6 · 脚本、CI、release 与基线证据（2026-10-31）

## tool/ 脚本（全部可执行，统一 `set -euo pipefail`，fvm 自动回退裸命令）

| 脚本 | 实测结果 |
| --- | --- |
| `bootstrap.sh` | fvm/SDK 检查 → pub get → gen.sh（逻辑等价验证：pub get 与 gen 均单独跑通） |
| `gen.sh` | Pigeon 三端 + build_runner + gen-l10n 顺序执行成功；生成后 `git status --porcelain` 为空 |
| `check_imports.sh` | R1–R4（含 DEC-019 router 例外）通过：`check_imports: OK` |
| `check.sh` | 手写 Dart 80 列格式化（`--set-exit-if-changed`）→ check_imports → 四包 analyze 全绿：`check done` |
| `test.sh` | shell_app 5/5、app_core 9/9、native_bridge 4/4：`test done`（共 18 个用例） |
| `test_native_android.sh` | `./gradlew testDebugUnitTest` BUILD SUCCESSFUL（SystemInfoMapperTest 3/3 PASSED） |
| `build_android.sh` | debug：`✓ Built ...app-debug.apk` |
| `build_android.sh --release` | `✓ Built ...arm64-v8a-release.apk (17.4MB)` 等 3 个 ABI |
| `run_android.sh` / `e2e_android.sh` | run 逻辑与 `flutter run` 一致；e2e 与 P4 实测命令一致（`All tests passed`） |

**DEC-020（新增决策）**：`dart format` 页宽统一 80。`03` §1.2 初稿的 `formatter.page_width: 100` 与 very_good_analysis 11 的 `lines_longer_than_80_chars` 矛盾（`--fatal-infos` 必失败）；80 列为唯一兼容值，根 `analysis_options.yaml` 已改。

## CI（.github/workflows/ci.yml）

- YAML 语法校验通过（PyYAML safe_load）。
- 步骤与 `tool/` 一致：checkout → temurin 17 → `.fvmrc` 解析 Flutter 版本 → SDK 36 → pub get → gen.sh → **codegen 门禁 `test -z "$(git status --porcelain)"`** → check.sh → test.sh → build debug → test_native_android → 上传 app-debug.apk artifact。
- **未在 GitHub 远程实际运行**（仓库当前无远程），仅本地静态核查；已知限制之一。

## 安全加固

- `apps/shell_app/android/app/src/main/AndroidManifest.xml`（SEC2/SEC3）：
  `android:usesCleartextTraffic="false"`、`android:allowBackup="false"`、`android:label="Shell"`。
- `apps/shell_app/android/key.properties.example` 占位文件已提交；`key.properties`/`*.jks`/`*.keystore` 在 `.gitignore`。
- v0 主 manifest 无 INTERNET 权限；原生页 `exported=false`（P3 合并清单已验证）。

## Release 与基线（模拟器 shell_api36 / arm64）

APK 体积（`ls -lh` 实测）：

| APK | 体积 |
| --- | --- |
| app-debug.apk | 207M |
| app-arm64-v8a-release.apk | 17.4M |
| app-armeabi-v7a-release.apk | 14.6M |
| app-x86_64-release.apk | 18.9M |

Release 命令显式包含 `--dart-define=APP_ENV=prod`、`--split-per-abi`、`--obfuscate`、`--split-debug-info=build/symbols`；`build/symbols/` 已生成且被 git 忽略。

冷启动 TotalTime（`am start -W`，各 3 次取中位数，**模拟器数字仅作基线，不代表真机**）：

| 构建 | 3 次原始值 (ms) | 中位数 (ms) |
| --- | --- | --- |
| release（arm64，versionCode 2001） | 3547 / 2813 / 3351 | **3351** |
| debug（fat APK） | 5386 / 5541 / 5244 | **5386** |

静态核查：`bootstrap.dart` 首帧前无任何桥接调用（仅构造 env/logger/bridge）；`tickCountProvider` 仅在 `_TickerCard` 内独立 `Consumer` watch。

## Gate 结论

- 全部脚本通过；生成物无 diff；manifest hardening 完成；CI YAML 校验通过；release APK 产出、体积与启动基线已记录 ✅
- 远程 CI 未验证（无远程仓库）。
