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
}
