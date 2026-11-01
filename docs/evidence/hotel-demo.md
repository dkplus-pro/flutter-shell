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

## 5. restyle 验收（2026-11-02，docs/06 视觉重设计）

### 5.1 改动摘要

- **双轨实施**：壳与占位轨 `571c702`（`feat: hotel demo restyle shell track (nav bar, placeholder mocks)`：自绘导航 `AppBottomNavBar`、P3 首页/我的装饰 mock、app_ui 主题修正、本区 analyzer 清零、导航 widget 测试 6 例）+ 聊天轨 `3cc3e15`（`feat: hotel demo restyle chat track`：聊天页/气泡/订单卡/弹层/快捷面板/猜您想问欢迎卡）；合并 `b719a5f` 零冲突。
- **合并修复** `be048ee`：profile 页去掉跨 feature import hotel provider（R4，改为纯装饰、新增 `profileMemberHint` key）、删除壳轨加的 `HotelColors.star` 别名（聊天轨改用 `starGold`）、修 `_ProfileHeader` unused key lint。
- **文档**：`docs/05` §9 token 表替换为 docs/06 §2.1（D9 决策不变）；`docs/06` 状态行改「已确认并实施」、§4 三档标完成。

### 5.2 Gates

| 命令 | 结果 |
| --- | --- |
| `bash tool/gen.sh` | PASS；生成物零 diff |
| `bash tool/check.sh` | PASS（exit 0：format 零 diff、check_imports OK、四包 analyze 零 issue） |
| `bash tool/test.sh` | PASS：**82 = shell_app 69 + app_core 9 + native_bridge 4**（重设计前基线 70 → 净增 12：导航 widget 测试 6 例 + 欢迎卡点击发送 + mock 页/弹层 finder 适配等） |
| `fvm flutter build apk --debug` | PASS：`build/app/outputs/flutter-apk/app-debug.apk`（14.1s） |
| `adb shell am start -W` 冷启动 | COLD TotalTime 12729ms（模拟器 debug 首启实测，含首次 JIT；仅基线，不代表真机） |

### 5.3 走查逐项结果（emulator-5554，PRD §12 八项 + 重设计专项）

| # | 走查项 | 结果 | 证据/说明 |
| --- | --- | --- | --- |
| 1 | 冷启动默认落「服务」tab；聊天页换肤（白 AppBar 居中标题、灰房号胶囊、黑色线性订单图标） | PASS | `hotel-01-welcome.png` |
| 2 | **猜您想问欢迎卡**：首进可见、chips 分类切换（Delivery/Q&A/Booking）、「换一换」轮换 FAQ、FAQ 行点击发送预设并进意图流、首条消息后消失（不持久化） | PASS | `hotel-17-guess-card.png`（轮换后 Q&A 分类：WiFi/早餐/联网/早餐位置）；点 "What is the Wi-Fi password?" 即发送并触发 S3；S1 截图中卡片已消失 |
| 3 | S1 主路径：追问量 → 数量收敛 → 订单卡（步进器 2→3→2 可调）→ 确认 → Placed（~3s）→ Delivering → Delivered → 星评一次成型 | PASS | `hotel-04-s1-ask-quantity.png`（快捷面板 Slippers 预设触发 → 追问数量）；`hotel-05-s1-order-card.png`；`hotel-06-s1-placed.png`（Bottled water 单 Placed 紫胶囊 + Staff notified；Placed 仅 ~3s，拖鞋单截图往返延迟未追上，改用更快的第二单捕获，状态机三单验证一致）；`hotel-07-s1-delivering.png`；`hotel-08-s1-delivered.png`（金色星评行 + Semantics "Service rating..."）；`hotel-09-s1-rated.png`（Rated · 3 stars 双处呈现，星级行移除不可再评） |
| 4 | 快捷面板：白卡 + 「Quick services」标题 + 8 张 tileGray 小卡（primarySoft 圆底图标）；`Late check-out` / `Wi-Fi password` 经 FittedBox 不再截断 | PASS | `hotel-13-s2-quick-panel.png`；小卡点击发送预设进意图流（Slippers/Toiletries/Water/Wake-up 实测） |
| 5 | S3 WiFi 直答（SSID/密码 demo 数据） | PASS | `hotel-10-s3-wifi.png` |
| 6 | S4 叫醒预约：预设 → 追问时间 → 文本 "tomorrow 07:00" 解析 → 摘要卡 → Reserved 终态 | PASS | `hotel-11-s4-card.png`（追问）；`hotel-11-s4-reserved.png`（Reserved 紫胶囊 + "Tomorrow 07:00 wake-up call · room 1208"） |
| 7 | S5 兜底 | PASS | 文本输入 "asdfgh qwerty" → "Sorry, I am still a demo concierge..."（UI describe 文本证据；无独立编号截图） |
| 8 | 订单弹层：把手、「Current orders · 4」粗标题、行式列表（图标块+粗标题×数量+灰副题+状态胶囊+时间）、liveItems 实时同步 | PASS | `hotel-12-order-sheet.png`（4 单倒序：Delivered 绿 / Reserved 紫 / Rated·3 stars 灰胶囊） |
| 9 | 首页 mock：紫渐变头卡 + 假搜索卡 + 图标格 + bridge demo 入口可达；点击任意处 toast | PASS | `hotel-02-home-toast.png`（SnackBar "This feature is not available yet."） |
| 10 | 我的 mock：通用图标头像（无照片/吉祥物素材）+ Shell Plus 渐变横幅 + 图标格；点击 toast；纯装饰无房号（R4 修复后） | PASS | `hotel-03-profile-toast.png` |
| 11 | 杀进程重启恢复：会话/订单完整还原、welcome 不重播、欢迎卡不重现 | PASS | `hotel-15-restore.png`（force-stop 后重启，Toiletries/Water Delivered 卡均在） |
| 12 | 自绘底部导航：白底 + 0.5 hairline；未选中线性灰图标+灰字；选中紫实心+紫字；服务 tab（居中）选中 44dp 紫圆白图标；Semantics（3 nav Button + button/selected 标志） | PASS | `hotel-18-nav-circle.png`（紫圆选中态特写，兼见各截图底部）；UI 树确认 `Home/Home`、`Services/Services`、`Profile/Profile` Button 节点；widget 测试覆盖 3 项渲染/点击回调/圆钮/Semantics |
| 13 | zh-CN 全界面中文（per-app locale） | PASS | `hotel-16-zh-locale.png`（AI 客服/1208 房·张先生/洗漱用品/已送达/数量×2/输入消息…/首页·服务·我的） |

### 5.4 新增/重拍截图清单

`hotel-01-welcome`、`hotel-02-home-toast`、`hotel-03-profile-toast`、`hotel-04-s1-ask-quantity`、`hotel-05-s1-order-card`、`hotel-06-s1-placed`、`hotel-07-s1-delivering`、`hotel-08-s1-delivered`、`hotel-09-s1-rated`、`hotel-10-s3-wifi`、`hotel-11-s4-card`、`hotel-11-s4-reserved`、`hotel-12-order-sheet`、`hotel-13-s2-quick-panel`、`hotel-14-s2-toiletries-card`、`hotel-15-restore`、`hotel-16-zh-locale`（全部按重设计后 UI 重拍替换）；新增 `hotel-17-guess-card`（欢迎卡特写）、`hotel-18-nav-circle`（导航紫圆选中态）。

### 5.5 遗留未验证项

1. **release 构建**：仅 debug 构建；沿袭已知限制（debug 签名不可发布）。
2. **性能帧率/逐帧 instrumentation**：未做；走查无可感知卡顿。
3. **中文 IME 自然语言输入**：adb `input text` 不支持非 ASCII，S1 中文触发路径由单测覆盖（走查用英文预设触发等价意图）。
4. **Placed 状态独立帧**：状态仅保持约 3s，MCP 截图工具往返延迟追不上，改用单条 adb `input tap + screencap`（~1s）以 Water 订单捕获；拖鞋单的 Placed→Delivering 流转由时间线文本证据确认。
5. **真机**：全部走查在模拟器（AVD shell_api36），数字与观感不代表真机。
6. **iOS**：未编译未运行（沿袭 v0 已知限制）。
