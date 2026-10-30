# P4 · Dart 桥接封装与演示页证据（2026-10-31）

## native_bridge Dart 封装

- `lib/native_bridge.dart` 只导出 `NativeBridge`、`BridgeException`、`SystemInfo`、`NativeScreenResult`。
- **契约差异记录**：Pigeon 29 生成的是顶层函数 `Stream<int> ticks({String instanceName})` 而非文档预期的 `TickStreamApi` 类；`NativeBridge` 构造参数相应为可注入的 `TickStreamFactory`（`Stream<int> Function()`）。`02` §2.3 的 Dart 列按实际生成物修正（类名与语义一致，仅形态为顶层函数）。
- 错误映射：`PlatformException` → `BridgeException`（code/message/details 原样保留）；其他异常 → `code=BRIDGE_FAILURE`；`ticks()` 未初始化抛 `StateError`；`nativeScreenResults` 为 broadcast；`dispose()` 注销 FlutterApi 并关闭流。
- 单测 `test/native_bridge_test.dart` **4/4 通过**（错误映射、未初始化 StateError、注入 tick 流、FlutterApi → broadcast 全链路经真实通道 codec）。

## app 接线

- `core/bridge/bridge_providers.dart`：`nativeBridgeProvider` 默认抛 `StateError`，仅 `bootstrap.dart` override（`NativeBridge()..initialize()`，首帧前无通道调用）。
- `features/bridge_demo/application/bridge_demo_providers.dart`：`systemInfoProvider` / `tickCountProvider` / `nativeScreenResultsProvider`（autoDispose）+ `openNativeScreenProvider`（presentation 不直接依赖 NativeBridge，DEC-019 记录了 router 的 R3 例外）。
- 演示页：三卡片；ticker 在独立 `Consumer` 中 watch；`ref.listen` 显示确认/取消 SnackBar；`AsyncValue` 三态齐全。
- 路由 `/bridge`；Home 增加 `openBridgeDemo` 按钮。

## 静态检查与测试

```
fvm flutter analyze --fatal-infos  # native_bridge、shell_app 均 No issues found!
fvm flutter test                    # shell_app 5/5（home 2 + bridge_demo 3）
fvm flutter test integration_test/bridge_e2e_test.dart -d emulator-5554
00:01 +1: All tests passed!         # platform=android、osVersion 含 API、ticks[0]=0
```

## 手工 7 步验收（模拟器 shell_api36）

| 步 | 结果 | 证据 |
| --- | --- | --- |
| 1. 启动 → 进入桥接页 | ✅ | `images/p4-home.png`、`images/p4-bridge-initial.png` |
| 2. 系统信息 6 字段 + 刷新 | ✅ platform=android、osVersion=Android 16 (API 36)、buildNumber=1 | `images/p4-bridge-info-ticker.png`、`images/p4-refresh.png` |
| 3. ticker 递增；返回后 TICK_STOPPED；重进从 0 开始 | ✅ `I NativeBridge: TICK_STOPPED`；重进截图显示 Ticks: 1 | `images/p4-back-home.png` |
| 4. 打开原生页 | ✅ `SCREEN_OPENED title=Native screen`；dumpsys：`topResumedActivity=...bridge.NativeInfoActivity` | `images/p4-native-screen.png` |
| 5. Confirm | ✅ `RESULT confirmed=true message=Confirmed in native screen`；SnackBar「Confirmed: Confirmed in native screen」 | `images/p4-confirm-snackbar.png` |
| 6. Cancel / 返回键 | ✅ `RESULT confirmed=false message=Cancelled in native screen`（Cancel 与返回键各一次，各只回传一次） | `images/p4-cancel-snackbar.png` |
| 7. 快速连点幂等 | ✅ 双击 Cancel 只产生一条 RESULT（`dispatched` 标志生效） | logcat 片段（本文件） |

**修复记录**：返回键首测未回传——API 36 预测性返回不调用 `onBackPressed`；`NativeInfoActivity` 改为注册 `onBackPressedDispatcher.addCallback` 后通过。

## Gate 结论

- 集成测试通过（真实链路：方法 + 事件流）✅
- 手工 7 步全部通过，截图与 logcat 标记齐全 ✅
- analyze 零 issue；widget 测试 5/5 ✅
