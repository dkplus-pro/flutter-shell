# 06 · 酒店 Demo 视觉重设计方案（对齐华住 App 设计语言）

> 状态：**已确认并实施（2026-11-02）**
> 背景：v0 走查截图暴露出明显 Material 3 模板感（默认 NavigationBar、stock ListTile 弹层、fromSeed 紫灰底色）。产品提供华住会 App 5 张参考截图，要求按该风格重做视觉。
> 参考图：`docs/evidence/images/reference-huazhu/`（chat / home / profile / member / services）。**仅提取设计语言（配色/布局/组件形态），不使用其 logo、吉祥物、文案、图片素材。**
> 范围：仅 presentation 与主题层；意图引擎、状态机、持久化、provider API 一律不动。组件对外签名（`ReplyTypewriter` / `showHotelOrderSheet` / `StarRatingBar`）保持不变。

## 1. 参考风格提炼

| 维度 | 华住参考的做法 | 与现状的差异 |
| --- | --- | --- |
| 色彩 | 蓝紫主色（约 `#5747C6`）+ 冷灰底（约 `#F4F5F7`）+ 纯白卡片；红/橙仅做促销点缀；金仅做会员点缀 | 现状是 `fromSeed(紫)` 产生的紫灰染色 surface，需要改为显式白卡片+冷灰底 |
| 卡片 | 白底、圆角 14–20、**零投影**，靠与灰底的对比分层 | 现状卡片带 M3 默认投影 |
| 文字 | 近黑粗标题（20 级加粗做区块标题）、大号粗数字、灰色辅助字 | 现状依赖 M3 默认字阶 |
| 形状 | CTA 全圆角胶囊、chips 胶囊、列表行=细分割线+chevron | 现状 chips/按钮是 M3 默认形 |
| 导航 | 无胶囊指示器：线性灰图标 → 选中紫色实心+紫字；特殊 tab 用紫色圆形 | 现状是 stock NavigationBar 胶囊 |
| 聊天页 | 白色 AppBar 居中标题、灰底、白色气泡无尾巴、头像白圆、整段时间戳、欢迎后跟「猜您想问」卡（chip 分类 + FAQ 行 + 换一换）、输入为灰胶囊内嵌 +/发送 | 现状紫染 AppBar、金色分隔线、输入区是裸 TextField |
| 弹层 | 与 App 内卡片同源的行式列表（图标块+粗标题+状态胶囊+细分割线） | 现状 stock ListTile |

## 2. 设计令牌（落入 `app_ui`，替换 §9 起点）

### 2.1 颜色（`HotelColors` 修订）

| Token | 值 | 用途 |
| --- | --- | --- |
| `primary` | `#5747C6` | 主色：用户气泡、CTA、选中态、导航选中 |
| `primaryDeep` | `#4638AC` | CTA 渐变深端、按压态 |
| `primarySoft` | `#ECE8FB` | 选中 chip 底、图标软底 |
| `bg` | `#F4F5F7` | 页面/聊天区背景（冷灰，去除紫染） |
| `surface` | `#FFFFFF` | 卡片、气泡、面板、弹层 |
| `textPrimary` | `#191B20` | 标题/正文 |
| `textSecondary` | `#9AA0A8` | 辅助文案、时间戳、未选中导航 |
| `textHint` | `#B9BDC6` | 输入占位 |
| `divider` | `#EEEEF1` | 0.5px 分割线、 AppBar 底 hairline |
| `statusPlaced` | `#5747C6` | 已下单/已预约 |
| `statusDelivering` | `#F5A623` | 配送中 |
| `statusDelivered` | `#34B36B` | 已送达 |
| `statusNeutral` | `#8E939C` | 待确认/已评价 |
| `promoRed` | `#FF5148` | 徽标点缀（新、评价红点） |
| `starGold` | `#F0A835` | 星级填充 |
| `inputPill` | `#F2F3F5` | 输入胶囊底 |
| `tileGray` | `#F4F5F7` | 图标块、面板 tile 底 |

状态胶囊统一「10% 色底 + 实色文字」，`hotelOrderSheetStatusColor` 仍为唯一色源（映射表改为上表）。

### 2.2 字体与形状（新增 `HotelTypography` / `HotelDimens`）

- 不引入自定义字体文件（v0 约束）；用系统字重表达层级：
  - `titleL` 20/w700：区块标题（猜您想问、本次订单、快捷服务）
  - `title` 17/w700：AppBar、卡片标题
  - `body` 16/w400：气泡正文
  - `sub` 13/w400：辅助、时间戳
  - `navLabel` 11
- 形状：卡片圆角 16、面板/弹层顶角 20、CTA 胶囊全圆、图标块 10、气泡 16（无尾巴）；全局 `elevation=0`，分割线 0.5px `divider`。

## 3. 逐页面改动

### 3.1 全局主题与壳

- `app.dart` 主题：显式构造 `ColorScheme`（不再 fromSeed）；scaffold 底 `bg`；`appBarTheme`＝白底/居中标题/17 w700/零投影；`cardTheme`＝白底 16 圆角零投影；`dividerTheme`＝0.5 `divider`。
- **自绘底部导航**（替换 `NavigationBar`，放 `core/shell/`）：白底 + 顶部 hairline，3 项；未选中＝线性灰图标+灰字，选中＝紫色实心图标+紫字；**服务 tab（居中）选中时用 44dp 紫色圆形承载白色图标**（参考首页「推荐」的圆形选中样式）；保留 Semantics 与原有导航回调、测试语义。

### 3.2 聊天页（对齐参考 chat 图）

- AppBar：白底居中「华小二 / AI Concierge」；房号徽标改灰底胶囊（`inputPill` 底 + `textSecondary` 字）收在标题右侧；订单图标改黑色线性风格。
- 时间分隔：去掉金色双线，改为居中灰字整段格式 `2026-11-01 14:32`（与参考一致精确到分；不抄到秒）。
- 气泡：客服＝白底 16 圆角、近黑字、无尾；用户＝`primary` 底白字；头像＝白圆 + 0.5 边框 + 紫色耳机线性图标（不用吉祥物素材）。
- 输入区：改为 52dp 灰胶囊（`inputPill`）内含 [输入框] [＋圆形图标]；**发送键仅在输入非空时出现**（紫色箭头，胶囊内右侧）；快捷面板改为白底顶角 20 的卡，带「快捷服务」标题，条目改为 `tileGray` 圆角 14 小卡（图标入 `primarySoft` 圆底、文字 `FittedBox` 缩放——顺带修掉 "Late check-o…" 截断）。
- **猜您想问欢迎卡（P2，参考图最标志性交互）**：首次进入时在欢迎语气泡下渲染白卡：标题「猜您想问」+ 分类 chips（配送/问答/预约）+ 4 条 FAQ 行（问题式文案，如「怎么送两双拖鞋到房间」「Wi-Fi 密码是什么」）+ 底部「换一换」轮换；点行即发送该预设消息并进入正常意图流；用户发出第一条消息后此卡消失（不持久化）。

### 3.3 订单卡与弹层

- 订单卡：白卡 16 圆角；首行＝图标块（`tileGray` 圆角 10）+ 品名粗体 + 状态胶囊（新色映射）；数量行「×3」粗体 + 房号灰字；0.5 分割线；操作区＝数量步进胶囊（描边圆钮）+ **全宽紫色胶囊 CTA「确认下单」**（参考首页「查 询」按钮样式）；已送达后星级行保留（金色 `starGold`）。
- 弹层：顶角 20 + 把手；标题「本次订单 · N」粗体；行式列表（图标块 40 + 粗标题 + 灰副题 + 右侧状态胶囊与时间），细分割线，替换 stock ListTile 观感；`liveItems` 实时同步机制不变。

### 3.4 占位 tab（P3，可选）

- 首页/我的从「光秃占位」升级为风格化装饰 mock：首页＝紫渐变欢迎头卡 + 白色假搜索卡 + 图标格；我的＝头像/会员卡风格卡 + 图标格；点击仍全局 toast「暂未开发」。全部装饰性、无交互逻辑、文案进 ARB。

## 4. 实施阶段

> 三档均已完成（2026-11-02）：P1 由壳轨 `571c702` + 聊天轨 `3cc3e15` 两轨并行实施（合并 `b719a5f`），P2/P3 随对应轨落地；验收见 `docs/evidence/hotel-demo.md` restyle 章节。

| 阶段 | 内容 | 文件面 | 状态 |
| --- | --- | --- | --- |
| P1 换肤（必做） | 主题/令牌（§2）、自绘导航（§3.1）、聊天页（§3.2 除欢迎卡）、面板小卡化+截断修复、订单卡与弹层（§3.3） | `app_ui` 3 个 token/theme 文件、`app.dart`、`core/shell/*`、hotel presentation ~8 文件、ARB | ✅ 完成 |
| P2 欢迎卡（建议） | 猜您想问卡：预设问题数据 + widget + 点击发送接线 + 测试 | hotel data/presentation 新增 1–2 文件、chat page 接线、ARB、测试 | ✅ 完成 |
| P3 占位页 mock（可选） | 首页/我的风格化装饰 | 2 个 presentation 文件、ARB | ✅ 完成 |

## 5. 测试与文档影响

- 现有 70 测试为底线：组件签名不变、状态色映射函数保留（值更新）、语义标签保留；因视觉结构调整而失效的 finder 允许同步修正，不允许删除用例。
- 新增：欢迎卡点击发送预设的 widget 测试（P2）、导航渲染/切换 smoke（P1）。
- gates 全量重跑：`gen.sh` / `check.sh` / `test.sh` / debug 构建；模拟器重拍全套走查截图替换 `docs/evidence/images/hotel-*`。
- 文档同步：`docs/05` §9 token 表更新为本文件 §2（D9 决策不变，仍是紫金+灰白）；本方案生效后记入 `docs/evidence/hotel-demo.md` restyle 章节；`docs/01` §18 若登记组件清单则补自绘导航。

## 6. 明确不抄的部分

- 华住 logo、吉祥物形象、会员体系文案、营销卡片内容与照片素材；
- 5 tab 信息架构（保持本 demo 3 tab）；
- 精确到秒的时间戳（保留到分）。
