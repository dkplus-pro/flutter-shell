# P2 · Flutter 基础底座证据（2026-10-31）

## 依赖解析

- 按版本矩阵登记：`flutter_riverpod 3.4.3`、`riverpod_annotation 4.0.7`、`riverpod_generator 4.0.9`、`go_router 18.1.2`、`logging 1.3.0`、`dio 5.11.1`、`shared_preferences 2.5.6`、`intl 0.20.3`（由 `flutter_localizations` 解析）。
- **DEC-015（新增决策）**：`build_runner` 初稿登记 2.17.1，但与 `riverpod_generator 4.0.9` 的 `build` 约束冲突（build_runner ≥2.17.1 需 `build >=5`，generator 需 `<5`），pub 报错原文：
  `Because riverpod_generator >=3.0.0 depends on build >=3.0.0 <5.0.0 and build_runner >=2.17.1 depends on build >=5.0.0 <5.1.0, ...`
  按 pub 解析结果改用 **build_runner 2.16.2**，已登记 `docs/00` 决策表并更新版本矩阵。

## 代码生成

```
$ fvm flutter gen-l10n            # apps/shell_app 下执行
→ lib/l10n/generated/{app_localizations.dart, app_localizations_en.dart, app_localizations_zh.dart}

$ fvm dart run build_runner build --delete-conflicting-outputs
→ config_providers.g.dart / log_providers.g.dart / app_router.g.dart（共 6 outputs）
```

## 静态检查与测试

```
$ fvm flutter analyze --fatal-infos   （app_core / app_ui / native_bridge / shell_app）
No issues found!（4/4 包）

$ fvm flutter test  （apps/shell_app）
00:00 +2: All tests passed!
（home_page_test.dart：Locale('en') → "Hello World"；Locale('zh') → "你好，世界"）
```

- **DEC-016（新增决策）**：very_good_analysis 11.0.0 的 `unnecessary_type_name_in_constructor` 强制声明式构造语法；经典写法 `const ShellApp({super.key})` 被判 info，其 autofix 产出的代码需要人工核对。统一采用 `const new(...)`（未命名）/ `new _(...)`（私有命名），已验证 Dart 3.13 合法并登记 `docs/00`。

## 模拟器验证（Pixel 7 AVD shell_api36，API 36）

```
$ adb install -r app-debug.apk → Success
$ adb shell am start -W -n com.dk.fluttershell/.MainActivity → Status: ok
```

- 英文界面截图：`docs/evidence/images/p2-home-en.png`（Shell / Hello World / Flutter shell baseline page）。
- 中文界面截图：`docs/evidence/images/p2-home-zh.png`（你好，世界 / Flutter 壳工程基线页面）。
- 切换方法：模拟器 SELinux 拒绝 `setprop persist.sys.locale`（`Failed to set property`），改用 **per-app locale**：
  `adb shell cmd locale set-app-locales com.dk.fluttershell --locales zh-CN`（API 33+），验证后重置为 en-US。
- `adb logcat -d -s flutter:I` 无未捕获异常。

## Gate 结论

- analyze（三包 + 插件）零 issue ✅
- widget 测试通过（计数 2）✅
- 模拟器 Hello 页中英文可见 ✅
