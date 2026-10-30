# P7 · iOS 桩证据（2026-10-31）

## 文件清单（未编译、未 pod install、未验收）

| 文件 | 内容 |
| --- | --- |
| `packages/native_bridge/ios/native_bridge/Sources/native_bridge/Generated/ShellApi.g.swift` | Pigeon 29.1.0 生成（非空，提交） |
| `packages/native_bridge/ios/native_bridge/Sources/native_bridge/NativeBridgePlugin.swift` | UNIMPLEMENTED 桩 |
| `packages/native_bridge/ios/native_bridge.podspec` | `source_files = 'native_bridge/Sources/native_bridge/**/*'`（覆盖 Generated/，I4） |

## 桩实现要点（I2/I3）

- `ShellHostApiStub`：`getSystemInfo` / `openNativeScreen` 全部 `throw PigeonError(code: "UNIMPLEMENTED", message: "iOS bridge not implemented", details: nil)`，经生成物 `ShellHostApiSetup.setUp` 注册。
- `TicksStreamHandlerStub`：`onListen` 立即 `sink.error(code: "UNIMPLEMENTED", ...)`，不产生任何数据。
- FlutterApi 代理（`ShellFlutterApi`）不被桩调用（无原生页可回传）。

## 明确不做

- 不运行 `pod install`、不编译、不修改 iOS Runner；`docs/01`、`docs/04`、`AGENTS.md` 均标注 iOS 未验证（I5）。
- `git status` 无其他 iOS 改动。
