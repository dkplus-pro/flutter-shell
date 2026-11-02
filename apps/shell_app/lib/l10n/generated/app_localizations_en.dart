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

  @override
  String chatAskQuantity(String item, String unit) {
    return 'Sure, how many $item would you like?';
  }

  @override
  String get chatQuantityInvalid =>
      'Please reply with a quantity between 1 and 9, for example \"2\".';

  @override
  String get chatCancelAck =>
      'No problem, I have cancelled that. Anything else I can help with?';

  @override
  String get chatAskWakeupTime =>
      'Sure, what time should the wake-up call be? For example: tomorrow 07:00.';

  @override
  String get chatAskLateCheckoutTime =>
      'Sure, until what time would you like to check out late?';

  @override
  String get chatTimeChipsPrompt =>
      'Sorry, I did not catch the time. Pick one below or type it, for example 07:00.';

  @override
  String chatWifiAnswer(String ssid, String password) {
    return 'The guest Wi-Fi network is $ssid, password $password. (demo data)';
  }

  @override
  String get chatBreakfastAnswer =>
      'Breakfast is served daily from 06:30 to 10:00 at the restaurant on the 2nd floor.';

  @override
  String get chatWakeupAlreadyBooked =>
      'You already have a wake-up call request. Check Current orders to review it.';

  @override
  String get chatLateCheckoutAlreadyRequested =>
      'You already have a late check-out request. Check Current orders to review it.';

  @override
  String get chatFallback =>
      'Sorry, I am still a demo concierge and did not understand that. Tap + to see everything I can do.';

  @override
  String get chatTyping => 'Concierge is typing…';

  @override
  String get amenitySlippers => 'Disposable slippers';

  @override
  String get amenityToiletries => 'Toiletries set';

  @override
  String get amenityTowels => 'Fresh towels';

  @override
  String get amenityWater => 'Bottled water';

  @override
  String get unitSlippers => 'pairs';

  @override
  String get unitToiletries => 'sets';

  @override
  String get unitTowels => 'pieces';

  @override
  String get unitWater => 'bottles';

  @override
  String get orderWakeupTitle => 'Wake-up call';

  @override
  String get orderLateCheckoutTitle => 'Late check-out';

  @override
  String orderDeliverTo(String room) {
    return 'Deliver to room $room';
  }

  @override
  String get orderConfirmButton => 'Confirm order';

  @override
  String get orderReserveButton => 'Confirm reservation';

  @override
  String orderQuantityLabel(int count) {
    return 'Quantity ×$count';
  }

  @override
  String get orderStatusPending => 'Pending';

  @override
  String get orderStatusPlaced => 'Placed';

  @override
  String get orderStatusDelivering => 'Delivering';

  @override
  String get orderStatusDelivered => 'Delivered';

  @override
  String orderStatusRated(int stars) {
    return 'Rated · $stars stars';
  }

  @override
  String get orderStatusReserved => 'Reserved';

  @override
  String get orderProgressPlaced => 'Staff notified.';

  @override
  String orderProgressDelivering(String room) {
    return 'On the way to room $room.';
  }

  @override
  String get orderProgressDelivered => 'Delivered, enjoy!';

  @override
  String get orderProgressReserved => 'Reserved. We will arrange it on time.';

  @override
  String orderWakeupSummary(String day, String time, String room) {
    return '$day $time wake-up call · room $room';
  }

  @override
  String orderLateCheckoutSummary(String time) {
    return 'Late check-out until $time';
  }

  @override
  String get dayToday => 'Today';

  @override
  String get dayTomorrow => 'Tomorrow';

  @override
  String get ratingPrompt => 'How was the delivery? Tap a star to rate.';

  @override
  String ratingStarSemantic(int stars) {
    return 'Rate $stars stars';
  }

  @override
  String get ratingBarSemantic => 'Service rating. Tap a star to rate.';

  @override
  String get orderStepperMinusSemantic => 'Decrease quantity';

  @override
  String get orderStepperPlusSemantic => 'Increase quantity';

  @override
  String ordersSheetTitleWithCount(int count) {
    return 'Current orders · $count';
  }

  @override
  String get ordersEmpty => 'No orders yet';

  @override
  String get guessCardTitle => 'You may ask';

  @override
  String get guessCategoryDelivery => 'Delivery';

  @override
  String get guessCategoryQa => 'Q&A';

  @override
  String get guessCategoryBooking => 'Booking';

  @override
  String get guessRefresh => 'Show more';

  @override
  String get faqSlippersDeliver =>
      'How do I get two pairs of slippers delivered?';

  @override
  String get faqToiletriesDeliver => 'Can you bring me a toiletries set?';

  @override
  String get faqTowelsDeliver => 'Could you bring a few more towels?';

  @override
  String get faqWaterDeliver =>
      'Please deliver two bottles of water to my room.';

  @override
  String get faqSlippersExchange =>
      'Can I exchange the slippers for another size?';

  @override
  String get faqTowelsBath => 'Please also bring some bath towels.';

  @override
  String get faqWifiPassword => 'What is the Wi-Fi password?';

  @override
  String get faqBreakfastTime => 'What time does breakfast start?';

  @override
  String get faqWifiConnect => 'How do I join the wireless network?';

  @override
  String get faqBreakfastFloor => 'Where is breakfast served?';

  @override
  String get faqWakeupSetup => 'Set a wake-up call for 07:00 tomorrow, please.';

  @override
  String get faqWakeupGeneral => 'I would like to set up a wake-up call.';

  @override
  String get faqLateCheckoutAsk => 'Can I request a late checkout?';

  @override
  String get faqLateCheckoutTime =>
      'I would like a late checkout at 14:00 tomorrow.';

  @override
  String homeGreeting(String guest) {
    return 'Good afternoon, $guest';
  }

  @override
  String get homeSearchHint => 'Search hotel services';

  @override
  String get homeSearchButton => 'Search';

  @override
  String get homeServicesTitle => 'Hotel services';

  @override
  String get homeTileDeliver => 'Item delivery';

  @override
  String get homeTileWakeup => 'Wake-up call';

  @override
  String get homeTileLateCheckout => 'Late check-out';

  @override
  String get homeTileOrders => 'My orders';

  @override
  String get profileMemberTitle => 'Shell Plus';

  @override
  String get profileMemberSubtitle => 'Demo member benefits';

  @override
  String get profileTileOrders => 'My orders';

  @override
  String get profileTileFavorites => 'Favorites';

  @override
  String get profileTileSettings => 'Settings';

  @override
  String get profileTileSupport => 'Contact support';

  @override
  String get profileMemberHint => 'Demo profile · decorative only';

  @override
  String get helloSubtitle => 'Flutter shell baseline page';
}
