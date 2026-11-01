// ignore: unused_import
import 'package:intl/intl.dart' as intl;

import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'Shell';

  @override
  String get helloWorld => 'Hello World';

  @override
  String get helloSubtitle => 'Flutter shell baseline page';

  @override
  String get openBridgeDemo => 'Open bridge demo';

  @override
  String get bridgeDemoTitle => 'Bridge Demo';

  @override
  String get systemInfoTitle => 'System information';

  @override
  String get refresh => 'Refresh';

  @override
  String get tickerTitle => 'Native ticker';

  @override
  String ticksValue(int count) {
    return 'Ticks: $count';
  }

  @override
  String get nativeScreenTitle => 'Native screen';

  @override
  String get openNativeScreen => 'Open native screen';

  @override
  String nativeResultConfirmed(String message) {
    return 'Confirmed: $message';
  }

  @override
  String nativeResultCancelled(String message) {
    return 'Cancelled: $message';
  }

  @override
  String get errorTitle => 'Something went wrong';

  @override
  String get retry => 'Retry';

  @override
  String get homeTab => 'Home';

  @override
  String get serviceTab => 'Services';

  @override
  String get profileTab => 'Profile';

  @override
  String get profileTitle => 'Profile';

  @override
  String get profileCenterTitle => 'Profile';

  @override
  String get profileCenterSubtitle =>
      'Personal information will show up here later.';

  @override
  String get placeholderNotAvailable => 'This feature is not available yet.';

  @override
  String get hotelChatTitle => 'AI Concierge';

  @override
  String hotelRoomBadge(String room, String guest) {
    return 'Room $room · $guest';
  }

  @override
  String get hotelMockGuestName => 'Mr. Zhang';

  @override
  String get hotelOrdersTooltip => 'View orders';

  @override
  String chatWelcome(String room) {
    return 'Hello, I am XiaoZhi, the smart butler for room $room. I can deliver items, answer questions and set wake-up calls. Tap + to see all services.';
  }

  @override
  String chatTodayMarker(String date) {
    return 'Today $date';
  }

  @override
  String get conciergeAvatarSemantic => 'Concierge avatar';

  @override
  String get quickPanelSemantic => 'Quick services';

  @override
  String get quickSlippers => 'Slippers';

  @override
  String get quickToiletries => 'Toiletries';

  @override
  String get quickTowels => 'Towels';

  @override
  String get quickWater => 'Water';

  @override
  String get quickWakeup => 'Wake-up call';

  @override
  String get quickLateCheckout => 'Late check-out';

  @override
  String get quickWifi => 'Wi-Fi password';

  @override
  String get quickBreakfast => 'Breakfast';

  @override
  String get presetSlippers =>
      'I need some disposable slippers delivered to my room.';

  @override
  String get presetToiletries => 'Please bring a toiletries set to my room.';

  @override
  String get presetTowels => 'Please bring some fresh towels to my room.';

  @override
  String get presetWater => 'Please deliver some bottled water to my room.';

  @override
  String get presetWakeup => 'I would like to set up a wake-up call.';

  @override
  String get presetLateCheckout => 'I would like to request a late check-out.';

  @override
  String get presetWifi => 'What is the Wi-Fi password?';

  @override
  String get presetBreakfast => 'What time is breakfast served?';

  @override
  String get chatInputHint => 'Type a message…';

  @override
  String get chatSendSemantic => 'Send';
}
