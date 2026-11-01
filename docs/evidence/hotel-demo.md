# 酒店智能客服 Agent Demo · 验收证据

- **日期**：2026-11-01
- **Commits**：M1/M2 `9576ae0` + `86c5a31`；M3 组件轨 `42f65ca`（合并 `e3989e1`）；集成 `3edb848`（`feat: hotel demo M3 typewriter playback, order sheet and polish`）；文档/证据随本文件所在提交。
- **需求口径**：`docs/05-hotel-agent-demo-prd.md`（D1–D12），工程决策 DEC-021。
- **环境**：macOS 15.6.1 arm64；Flutter 3.47.9 / Dart 3.13.7（FVM）；JDK 17（Zulu 17.0.21）；AGP 9.1.0 / Kotlin 2.4.0 / Gradle 9.3.1；设备：AVD `shell_api36`（Pixel 7，API 36，arm64）→ `emulator-5554`。

## 1. 命令与关键输出

| 命令 | 结果 |
| --- | --- |
| `bash tool/gen.sh` | PASS；生成后 `git status --porcelain` 生成物零漂移（提交前核验） |
| `bash tool/check.sh` | PASS：`Formatted 70 files (0 changed)`、`check_imports: OK`、四包 `flutter analyze --fatal-infos` 均 `No issues found!` |
| `bash tool/test.sh` | PASS：shell_app **57**、app_core **9**、native_bridge **4**，共 **70** 用例（合并基线 67：40+9+4 + 组件轨 14；本阶段净增 3 个聊天主路径/弹层 widget 测试） |
| `flutter build apk --debug --dart-define=APP_ENV=dev` | PASS：`✓ Built build/app/outputs/flutter-apk/app-debug.apk`（需显式 `GRADLE_USER_HOME=/Volumes/LexarSSD/DevHome/gradle`） |
| `adb shell am start -W -n com.dk.fluttershell/.MainActivity` | 冷启动 TotalTime：2538ms / 2809ms（模拟器实测，仅基线，不代表真机） |
| `tool/run_android.sh emulator-5554` | 装机并拉起，链路可交互 |

## 2. PRD §12 验收清单逐项状态

| # | 清单项 | 状态 | 证据 |
| --- | --- | --- | --- |
| 1 | 冷启动默认落「服务」tab：欢迎语 + 当天日期分组线；首页/我的点击出「暂未开发」 | PASS | `images/hotel-01-welcome.png`（默认落服务 tab，欢迎语 + Today 分组线 + 房号徽标）；`images/hotel-02-home-toast.png`（Home tap 出 "This feature is not available yet."）；`images/hotel-03-profile-toast.png`（Profile 同）；`images/hotel-13-s2-quick-panel.png` 中可见 bridge demo 入口未被破坏（Home 保留 `Open bridge demo`，另见 hotel-02 折返路径实测可达 Bridge Demo 页） |
| 2 | S1 主路径：文本追问 → 数量收敛 → 卡片步进器 → 确认 → 三态流转 → 星评一次成型 | PASS | `hotel-04-s1-ask-quantity.png`（追问数量）；`hotel-05-s1-order-card.png`（"2 pairs" → 卡片数量 2，步进器实操 −/+ 后确认）；`hotel-06-s1-placed.png`（Placed + Staff notified，确认后按钮/步进器消失且二次确认无效）；`hotel-07-s1-delivering.png`（~3s）；`hotel-08-s1-delivered.png`（~8s + 星评行出现）；`hotel-09-s1-rated.png`（点 5 星 → "Rated · 5 stars"，评分行变终态不可再评） |
| 3 | S2 面板触发 / S3 直答 / S4 预约终态 / S5 兜底 | PASS | S2：`hotel-13-s2-quick-panel.png`（2×4 宫格）→ `hotel-14-s2-toiletries-card.png`（Toiletries 卡片 Placed ×3）；S3：`hotel-10-s3-wifi.png`（Hotel-Guest / 12345678，标注 demo data；拍摄期间捕到打字机半程输出，证 D5 生效）；S4：`hotel-11-s4-card.png`（"wakeup at 7:00 tomorrow" 行内时间解析 → 明早 07:00 卡）→ `hotel-11-s4-reserved.png`（Reserved 终态 + 预约摘要）；S5：`hotel-11-s4-card.png` 中两条 fallback 回复（"Sorry, I am still a demo concierge…"） |
| 4 | AppBar 订单弹层：数量、状态与聊天卡片一致，送达后同步 | PASS | `hotel-12-order-sheet.png`（"Current orders"：Wake-up call → Reserved 紫徽标；Disposable slippers ×3 → Rated · 5 stars 灰徽标；倒序 + 时间 + 类型图标）；弹层打开期间经 `liveItems` builder 随 provider 状态实时刷新（送达后重开亦一致） |
| 5 | 杀进程重启：记录与订单恢复，星评/终态不重复可评 | PASS | 洗漱用品订单确认后处于 placed 在途时 `am force-stop` → 重启 → `hotel-15-restore.png`：完整会话恢复、welcome 不重播（恢复历史为纯文本，无打字机重放）、在途订单按既定策略落「已送达」、Reserved 保持；评分行未重复出现 |
| 6 | 切英文：全部界面英文 | PASS | 走查 1–5 全程系统英文（截图 01–15）；反向切 zh-CN（per-app locale）：`hotel-16-zh-locale.png`——标题/房号徽标/卡片徽标/预约摘要/评分提示/输入框/底部导航全部中文，历史客服消息经 key 重渲染为中文 |
| 7 | check.sh / test.sh 通过且测试计数增加 | PASS | 见 §1；计数 67 → 70（另 M1/M2 阶段自 23 基线累计 +47） |
| 8 | 无 TODO/FIXME、无调试输出、无硬编码文案 | PASS | 提交前 grep 抽查 `TODO/FIXME/print(/debugPrint` 于 `features/hotel` 与 `app_ui` 零命中；用户可见文案均在 ARB（en/zh 各 93 key，脚本核对对称） |

## 3. 集成阶段实现要点

1. **打字机接线**：`HotelChatState.freshReplyIds`（瞬态，不持久化）记录本会话新到且未播完的客服回复 id；渲染时命中者用 `ReplyTypewriter`（key=消息 id，onCompleted → `markReplyPlayed` 移除），恢复历史与已播完者用普通 `Text`。typing 指示器与 800–1500ms 队列节奏未动。chips 消息新增提示气泡（同样走打字机）。
2. **星级接线**：`order_card.dart` 的 `_buildRatingRow` 换为 `StarRatingBar`（semanticsLabel=`ratingBarSemantic` ARB key；金色走 `HotelColors.star` token）。
3. **订单弹层**：AppBar 图标改 `showHotelOrderSheet`；行数据由 `state.orders` 映射（title=品名 ×数量 / 预约时间摘要，subtitle=配送至房号 / 类别，timeText=HH:mm，icon 按类型），title/emptyText 用 `ordersSheetTitle`/`ordersEmpty`。`HotelOrderSheetStatus` 补 `pending`（中性灰，与 rated 同族，保持组件测试 4 色族断言通过）；新增可选 `liveItems` builder 使弹层打开期间与聊天卡片状态实时同步（不传则为静态快照，组件轨 14 个测试全部保持通过）。
4. **颜色统一**：`HotelColors` 新增 `statusPlaced/#7C5CBF`、`statusDelivered` 沿用、`statusNeutral`（=textSecondary）、`starEmpty/#C7C7CC`；`order_sheet.dart`/`star_rating_bar.dart` 的 stopgap 本地常量全部替换为 token，组件文件零硬编码色值；`order_card._statusColor` 与 `hotelOrderSheetStatusColor` 同源（placed/reserved 紫、delivering 金、delivered 绿、pending/rated 灰）。

## 4. 已知瑕疵与未验证项

1. **时间戳时区差**：模拟器系统时区与应用时区不一致，会话时间戳显示 23:2x 而状态栏为 11:2x（仅影响演示观感；`HH:mm` 格式化本身正确）。
2. **en 文案小疵**：`chatAskQuantity` 的 en 文案 "how many sets of Toiletries set"（unit "sets" × 品名 "Toiletries set"）读起来略重复；zh 正常。后续可在 ARB 微调品名（如 "Toiletries"）。
3. **打字机仅覆盖客服文本**：时间 chips 的快捷选项与订单卡不参与打字机（符合 PRD——仅文本回复需要节奏）。
4. **release 构建/签名**：本轮仅 debug 构建；沿袭 v0 已知限制（debug 签名不可发布）。
5. **英文自然语言触发**："wake me up at 7:00 tomorrow" 初测落到 fallback，已补 `wake me up` 关键词（并入集成提交）；中文触发词表以 PRD 为准，中文语音输入未在模拟器实测（adb 无法注入中文 IME 文本，中文匹配由单测覆盖）。
6. **性能帧率**：未做逐帧 instrumentation；打字机为逐字符 setState，实测走查无可感知卡顿（列表已用 builder + 局部重建）。
