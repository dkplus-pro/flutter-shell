// ignore: unused_import
import 'package:intl/intl.dart' as intl;

import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Chinese (`zh`).
class AppLocalizationsZh extends AppLocalizations {
  AppLocalizationsZh([String locale = 'zh']) : super(locale);

  @override
  String get appTitle => 'Shell';

  @override
  String get helloWorld => '你好，世界';

  @override
  String get helloSubtitle => 'Flutter 壳工程基线页面';

  @override
  String get openBridgeDemo => '进入桥接演示';

  @override
  String get bridgeDemoTitle => '桥接演示';

  @override
  String get systemInfoTitle => '系统信息';

  @override
  String get refresh => '刷新';

  @override
  String get tickerTitle => '原生计数器';

  @override
  String ticksValue(int count) {
    return '计数：$count';
  }

  @override
  String get nativeScreenTitle => '原生页面';

  @override
  String get openNativeScreen => '打开原生页面';

  @override
  String nativeResultConfirmed(String message) {
    return '已确认：$message';
  }

  @override
  String nativeResultCancelled(String message) {
    return '已取消：$message';
  }

  @override
  String get errorTitle => '出错了';

  @override
  String get retry => '重试';

  @override
  String get homeTab => '首页';

  @override
  String get serviceTab => '服务';

  @override
  String get profileTab => '我的';

  @override
  String get profileTitle => '我的';

  @override
  String get profileCenterTitle => '我的';

  @override
  String get profileCenterSubtitle => '个人信息后续将在这里展示。';

  @override
  String get placeholderNotAvailable => '该功能暂未开发';

  @override
  String get hotelChatTitle => 'AI 客服';

  @override
  String hotelRoomBadge(String room, String guest) {
    return '$room 房 · $guest';
  }

  @override
  String get hotelMockGuestName => '张先生';

  @override
  String get hotelOrdersTooltip => '查看订单';

  @override
  String chatWelcome(String room) {
    return '您好，我是 $room 房的智能管家小智，可以为您送物品、解答问题、设置叫醒～点右下角 + 可查看全部服务。';
  }

  @override
  String chatTodayMarker(String date) {
    return '今天 $date';
  }

  @override
  String get conciergeAvatarSemantic => '客服头像';

  @override
  String get quickPanelSemantic => '快捷服务';

  @override
  String get quickSlippers => '拖鞋';

  @override
  String get quickToiletries => '洗漱用品';

  @override
  String get quickTowels => '毛巾';

  @override
  String get quickWater => '饮用水';

  @override
  String get quickWakeup => '叫醒服务';

  @override
  String get quickLateCheckout => '延迟退房';

  @override
  String get quickWifi => 'WiFi 密码';

  @override
  String get quickBreakfast => '早餐时间';

  @override
  String get presetSlippers => '我需要送几双一次性拖鞋到房间。';

  @override
  String get presetToiletries => '请给我送一套洗漱用品。';

  @override
  String get presetTowels => '请给我送几条干净毛巾。';

  @override
  String get presetWater => '请给我送几瓶饮用水。';

  @override
  String get presetWakeup => '我想设置叫醒服务。';

  @override
  String get presetLateCheckout => '我想申请延迟退房。';

  @override
  String get presetWifi => 'WiFi 密码是多少？';

  @override
  String get presetBreakfast => '早餐时间是几点？';

  @override
  String get chatInputHint => '输入消息…';

  @override
  String get chatSendSemantic => '发送';

  @override
  String chatAskQuantity(String item, String unit) {
    return '好的，请问需要几$unit$item？';
  }

  @override
  String get chatQuantityInvalid => '请告诉我 1–9 之间的数量，例如“2”。';

  @override
  String get chatCancelAck => '好的，已为您取消。还有其他需要吗？';

  @override
  String get chatAskWakeupTime => '好的，请问需要几点叫醒？例如：明天早上 7 点。';

  @override
  String get chatAskLateCheckoutTime => '好的，请问希望延迟到几点退房？';

  @override
  String get chatTimeChipsPrompt => '抱歉没听清时间，请在下方选择或直接输入，例如 07:00。';

  @override
  String chatWifiAnswer(String ssid, String password) {
    return '客房 WiFi：$ssid，密码：$password。（演示数据）';
  }

  @override
  String get chatBreakfastAnswer => '早餐时间为每天 06:30–10:00，地点在 2 层餐厅。';

  @override
  String get chatFallback => '抱歉，我还在学习中，暂时听不懂这句话。点击右下角 + 可查看我能提供的全部服务。';

  @override
  String get chatTyping => '客服正在输入…';

  @override
  String get amenitySlippers => '一次性拖鞋';

  @override
  String get amenityToiletries => '洗漱用品';

  @override
  String get amenityTowels => '干净毛巾';

  @override
  String get amenityWater => '瓶装饮用水';

  @override
  String get unitSlippers => '双';

  @override
  String get unitToiletries => '套';

  @override
  String get unitTowels => '条';

  @override
  String get unitWater => '瓶';

  @override
  String get orderWakeupTitle => '电话叫醒';

  @override
  String get orderLateCheckoutTitle => '延迟退房';

  @override
  String orderDeliverTo(String room) {
    return '配送至 $room 房';
  }

  @override
  String get orderConfirmButton => '确认下单';

  @override
  String get orderReserveButton => '确认预约';

  @override
  String orderQuantityLabel(int count) {
    return '数量 ×$count';
  }

  @override
  String get orderStatusPending => '待确认';

  @override
  String get orderStatusPlaced => '已下单';

  @override
  String get orderStatusDelivering => '配送中';

  @override
  String get orderStatusDelivered => '已送达';

  @override
  String orderStatusRated(int stars) {
    return '已评价 · $stars 星';
  }

  @override
  String get orderStatusReserved => '已预约';

  @override
  String get orderProgressPlaced => '已通知服务人员';

  @override
  String orderProgressDelivering(String room) {
    return '正在送往 $room 房';
  }

  @override
  String get orderProgressDelivered => '已送达，祝您使用愉快';

  @override
  String get orderProgressReserved => '已预约，将按时为您安排';

  @override
  String orderWakeupSummary(String day, String time, String room) {
    return '$day $time 电话叫醒 · $room 房';
  }

  @override
  String orderLateCheckoutSummary(String time) {
    return '延迟至 $time 退房';
  }

  @override
  String get dayToday => '今天';

  @override
  String get dayTomorrow => '明天';

  @override
  String get ratingPrompt => '本次配送体验如何？点击星星评分';

  @override
  String ratingStarSemantic(int stars) {
    return '评 $stars 星';
  }

  @override
  String get ratingBarSemantic => '服务评分，点按星星打分';

  @override
  String get orderStepperMinusSemantic => '减少数量';

  @override
  String get orderStepperPlusSemantic => '增加数量';

  @override
  String get ordersSheetTitle => '本次订单';

  @override
  String get ordersEmpty => '暂无订单';
}
