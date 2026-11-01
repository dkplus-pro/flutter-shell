import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_zh.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'generated/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('zh'),
  ];

  /// Application title
  ///
  /// In en, this message translates to:
  /// **'Shell'**
  String get appTitle;

  /// Button that opens the bridge demo page
  ///
  /// In en, this message translates to:
  /// **'Open bridge demo'**
  String get openBridgeDemo;

  /// Title of the bridge demo page
  ///
  /// In en, this message translates to:
  /// **'Bridge Demo'**
  String get bridgeDemoTitle;

  /// Card title for system info
  ///
  /// In en, this message translates to:
  /// **'System information'**
  String get systemInfoTitle;

  /// Button to reload system info
  ///
  /// In en, this message translates to:
  /// **'Refresh'**
  String get refresh;

  /// Card title for the 1Hz ticker
  ///
  /// In en, this message translates to:
  /// **'Native ticker'**
  String get tickerTitle;

  /// Ticker value
  ///
  /// In en, this message translates to:
  /// **'Ticks: {count}'**
  String ticksValue(int count);

  /// Card title for the native screen round-trip
  ///
  /// In en, this message translates to:
  /// **'Native screen'**
  String get nativeScreenTitle;

  /// Button that opens the native demo screen
  ///
  /// In en, this message translates to:
  /// **'Open native screen'**
  String get openNativeScreen;

  /// Snackbar text when native screen confirmed
  ///
  /// In en, this message translates to:
  /// **'Confirmed: {message}'**
  String nativeResultConfirmed(String message);

  /// Snackbar text when native screen cancelled
  ///
  /// In en, this message translates to:
  /// **'Cancelled: {message}'**
  String nativeResultCancelled(String message);

  /// Generic error title
  ///
  /// In en, this message translates to:
  /// **'Something went wrong'**
  String get errorTitle;

  /// Button to retry a failed operation
  ///
  /// In en, this message translates to:
  /// **'Retry'**
  String get retry;

  /// Bottom navigation label for the home tab
  ///
  /// In en, this message translates to:
  /// **'Home'**
  String get homeTab;

  /// Bottom navigation label for the concierge chat tab
  ///
  /// In en, this message translates to:
  /// **'Services'**
  String get serviceTab;

  /// Bottom navigation label for the profile tab
  ///
  /// In en, this message translates to:
  /// **'Profile'**
  String get profileTab;

  /// Toast shown when tapping a placeholder page or deferred action
  ///
  /// In en, this message translates to:
  /// **'This feature is not available yet.'**
  String get placeholderNotAvailable;

  /// Title of the concierge chat page
  ///
  /// In en, this message translates to:
  /// **'AI Concierge'**
  String get hotelChatTitle;

  /// Room badge in the chat app bar
  ///
  /// In en, this message translates to:
  /// **'Room {room} · {guest}'**
  String hotelRoomBadge(String room, String guest);

  /// Mock guest display name (D8); rendered with the room badge
  ///
  /// In en, this message translates to:
  /// **'Mr. Zhang'**
  String get hotelMockGuestName;

  /// Tooltip and semantics label for the orders icon in the chat app bar
  ///
  /// In en, this message translates to:
  /// **'View orders'**
  String get hotelOrdersTooltip;

  /// Scripted concierge welcome message (S0)
  ///
  /// In en, this message translates to:
  /// **'Hello, I am XiaoZhi, the smart butler for room {room}. I can deliver items, answer questions and set wake-up calls. Tap + to see all services.'**
  String chatWelcome(String room);

  /// Semantics label for the concierge avatar placeholder
  ///
  /// In en, this message translates to:
  /// **'Concierge avatar'**
  String get conciergeAvatarSemantic;

  /// Tooltip and semantics label for the quick panel toggle
  ///
  /// In en, this message translates to:
  /// **'Quick services'**
  String get quickPanelSemantic;

  /// Quick panel entry label for slippers delivery
  ///
  /// In en, this message translates to:
  /// **'Slippers'**
  String get quickSlippers;

  /// Quick panel entry label for toiletries delivery
  ///
  /// In en, this message translates to:
  /// **'Toiletries'**
  String get quickToiletries;

  /// Quick panel entry label for towels delivery
  ///
  /// In en, this message translates to:
  /// **'Towels'**
  String get quickTowels;

  /// Quick panel entry label for drinking water delivery
  ///
  /// In en, this message translates to:
  /// **'Water'**
  String get quickWater;

  /// Quick panel entry label for the wake-up reservation
  ///
  /// In en, this message translates to:
  /// **'Wake-up call'**
  String get quickWakeup;

  /// Quick panel entry label for the late check-out reservation
  ///
  /// In en, this message translates to:
  /// **'Late check-out'**
  String get quickLateCheckout;

  /// Quick panel entry label for the Wi-Fi question
  ///
  /// In en, this message translates to:
  /// **'Wi-Fi password'**
  String get quickWifi;

  /// Quick panel entry label for the breakfast question
  ///
  /// In en, this message translates to:
  /// **'Breakfast'**
  String get quickBreakfast;

  /// Preset guest message sent from the slippers quick entry
  ///
  /// In en, this message translates to:
  /// **'I need some disposable slippers delivered to my room.'**
  String get presetSlippers;

  /// Preset guest message sent from the toiletries quick entry
  ///
  /// In en, this message translates to:
  /// **'Please bring a toiletries set to my room.'**
  String get presetToiletries;

  /// Preset guest message sent from the towels quick entry
  ///
  /// In en, this message translates to:
  /// **'Please bring some fresh towels to my room.'**
  String get presetTowels;

  /// Preset guest message sent from the water quick entry
  ///
  /// In en, this message translates to:
  /// **'Please deliver some bottled water to my room.'**
  String get presetWater;

  /// Preset guest message sent from the wake-up quick entry
  ///
  /// In en, this message translates to:
  /// **'I would like to set up a wake-up call.'**
  String get presetWakeup;

  /// Preset guest message sent from the late check-out quick entry
  ///
  /// In en, this message translates to:
  /// **'I would like to request a late check-out.'**
  String get presetLateCheckout;

  /// Preset guest message sent from the Wi-Fi quick entry
  ///
  /// In en, this message translates to:
  /// **'What is the Wi-Fi password?'**
  String get presetWifi;

  /// Preset guest message sent from the breakfast quick entry
  ///
  /// In en, this message translates to:
  /// **'What time is breakfast served?'**
  String get presetBreakfast;

  /// Hint text of the chat input field
  ///
  /// In en, this message translates to:
  /// **'Type a message…'**
  String get chatInputHint;

  /// Semantics label for the chat send button
  ///
  /// In en, this message translates to:
  /// **'Send'**
  String get chatSendSemantic;

  /// Concierge asks the quantity slot for an amenity (PRD 7.1)
  ///
  /// In en, this message translates to:
  /// **'Sure, how many {unit} of {item} would you like?'**
  String chatAskQuantity(String item, String unit);

  /// Re-ask when the quantity slot cannot be parsed
  ///
  /// In en, this message translates to:
  /// **'Please reply with a quantity between 1 and 9, for example \"2\".'**
  String get chatQuantityInvalid;

  /// Concierge acknowledges the guest cancelling an active slot flow
  ///
  /// In en, this message translates to:
  /// **'No problem, I have cancelled that. Anything else I can help with?'**
  String get chatCancelAck;

  /// Concierge asks the time slot for a wake-up reservation
  ///
  /// In en, this message translates to:
  /// **'Sure, what time should the wake-up call be? For example: tomorrow 07:00.'**
  String get chatAskWakeupTime;

  /// Concierge asks the time slot for a late check-out reservation
  ///
  /// In en, this message translates to:
  /// **'Sure, until what time would you like to check out late?'**
  String get chatAskLateCheckoutTime;

  /// Concierge offers quick time chips after a failed time parse
  ///
  /// In en, this message translates to:
  /// **'Sorry, I did not catch the time. Pick one below or type it, for example 07:00.'**
  String get chatTimeChipsPrompt;

  /// Direct answer to the Wi-Fi question, S3; mock credentials
  ///
  /// In en, this message translates to:
  /// **'The guest Wi-Fi network is {ssid}, password {password}. (demo data)'**
  String chatWifiAnswer(String ssid, String password);

  /// Direct answer to the breakfast-time question
  ///
  /// In en, this message translates to:
  /// **'Breakfast is served daily from 06:30 to 10:00 at the restaurant on the 2nd floor.'**
  String get chatBreakfastAnswer;

  /// Fallback reply guiding the guest to the quick panel (S5)
  ///
  /// In en, this message translates to:
  /// **'Sorry, I am still a demo concierge and did not understand that. Tap + to see everything I can do.'**
  String get chatFallback;

  /// Semantics label of the typing indicator bubble
  ///
  /// In en, this message translates to:
  /// **'Concierge is typing…'**
  String get chatTyping;

  /// Display name of the slippers amenity
  ///
  /// In en, this message translates to:
  /// **'Disposable slippers'**
  String get amenitySlippers;

  /// Display name of the toiletries amenity
  ///
  /// In en, this message translates to:
  /// **'Toiletries set'**
  String get amenityToiletries;

  /// Display name of the towels amenity
  ///
  /// In en, this message translates to:
  /// **'Fresh towels'**
  String get amenityTowels;

  /// Display name of the drinking water amenity
  ///
  /// In en, this message translates to:
  /// **'Bottled water'**
  String get amenityWater;

  /// Measure word for slippers
  ///
  /// In en, this message translates to:
  /// **'pairs'**
  String get unitSlippers;

  /// Measure word for toiletries
  ///
  /// In en, this message translates to:
  /// **'sets'**
  String get unitToiletries;

  /// Measure word for towels
  ///
  /// In en, this message translates to:
  /// **'pieces'**
  String get unitTowels;

  /// Measure word for bottled water
  ///
  /// In en, this message translates to:
  /// **'bottles'**
  String get unitWater;

  /// Title of the wake-up reservation card
  ///
  /// In en, this message translates to:
  /// **'Wake-up call'**
  String get orderWakeupTitle;

  /// Title of the late check-out reservation card
  ///
  /// In en, this message translates to:
  /// **'Late check-out'**
  String get orderLateCheckoutTitle;

  /// Delivery destination line on amenity order cards
  ///
  /// In en, this message translates to:
  /// **'Deliver to room {room}'**
  String orderDeliverTo(String room);

  /// Confirm button of amenity order cards
  ///
  /// In en, this message translates to:
  /// **'Confirm order'**
  String get orderConfirmButton;

  /// Confirm button of reservation cards
  ///
  /// In en, this message translates to:
  /// **'Confirm reservation'**
  String get orderReserveButton;

  /// Item count shown on a confirmed amenity order card
  ///
  /// In en, this message translates to:
  /// **'Quantity ×{count}'**
  String orderQuantityLabel(int count);

  /// Status badge of a not-yet-confirmed order card
  ///
  /// In en, this message translates to:
  /// **'Pending'**
  String get orderStatusPending;

  /// Status badge after confirmation (PRD 6.3)
  ///
  /// In en, this message translates to:
  /// **'Placed'**
  String get orderStatusPlaced;

  /// Status badge while the item is on the way
  ///
  /// In en, this message translates to:
  /// **'Delivering'**
  String get orderStatusDelivering;

  /// Status badge after arrival
  ///
  /// In en, this message translates to:
  /// **'Delivered'**
  String get orderStatusDelivered;

  /// Terminal badge after the guest submitted a rating
  ///
  /// In en, this message translates to:
  /// **'Rated · {stars} stars'**
  String orderStatusRated(int stars);

  /// Terminal badge of reservation cards
  ///
  /// In en, this message translates to:
  /// **'Reserved'**
  String get orderStatusReserved;

  /// Progress hint on the placed card
  ///
  /// In en, this message translates to:
  /// **'Staff notified.'**
  String get orderProgressPlaced;

  /// Progress hint on the delivering card
  ///
  /// In en, this message translates to:
  /// **'On the way to room {room}.'**
  String orderProgressDelivering(String room);

  /// Progress hint on the delivered card
  ///
  /// In en, this message translates to:
  /// **'Delivered, enjoy!'**
  String get orderProgressDelivered;

  /// Progress hint on the reserved card
  ///
  /// In en, this message translates to:
  /// **'Reserved. We will arrange it on time.'**
  String get orderProgressReserved;

  /// Slot summary of a wake-up reservation card
  ///
  /// In en, this message translates to:
  /// **'{day} {time} wake-up call · room {room}'**
  String orderWakeupSummary(String day, String time, String room);

  /// Slot summary of a late check-out card
  ///
  /// In en, this message translates to:
  /// **'Late check-out until {time}'**
  String orderLateCheckoutSummary(String time);

  /// Day word used in reservation slot summaries
  ///
  /// In en, this message translates to:
  /// **'Today'**
  String get dayToday;

  /// Day word used in reservation slot summaries
  ///
  /// In en, this message translates to:
  /// **'Tomorrow'**
  String get dayTomorrow;

  /// Prompt above the star rating row after delivery (D12)
  ///
  /// In en, this message translates to:
  /// **'How was the delivery? Tap a star to rate.'**
  String get ratingPrompt;

  /// Semantics label of one star in the rating row
  ///
  /// In en, this message translates to:
  /// **'Rate {stars} stars'**
  String ratingStarSemantic(int stars);

  /// Semantics label of the whole star rating bar (D12)
  ///
  /// In en, this message translates to:
  /// **'Service rating. Tap a star to rate.'**
  String get ratingBarSemantic;

  /// Semantics label of the quantity stepper minus button
  ///
  /// In en, this message translates to:
  /// **'Decrease quantity'**
  String get orderStepperMinusSemantic;

  /// Semantics label of the quantity stepper plus button
  ///
  /// In en, this message translates to:
  /// **'Increase quantity'**
  String get orderStepperPlusSemantic;

  /// Title of the orders bottom sheet with the live entry count (D11, docs/06 §3.3)
  ///
  /// In en, this message translates to:
  /// **'Current orders · {count}'**
  String ordersSheetTitleWithCount(int count);

  /// Empty state of the orders bottom sheet
  ///
  /// In en, this message translates to:
  /// **'No orders yet'**
  String get ordersEmpty;

  /// Section title of the quick services panel (docs/06 §3.2)
  ///
  /// In en, this message translates to:
  /// **'Quick services'**
  String get quickPanelTitle;

  /// Title of the guess-question welcome card (docs/06 §3.2)
  ///
  /// In en, this message translates to:
  /// **'You may ask'**
  String get guessCardTitle;

  /// Category chip of the guess card: item delivery questions
  ///
  /// In en, this message translates to:
  /// **'Delivery'**
  String get guessCategoryDelivery;

  /// Category chip of the guess card: information questions
  ///
  /// In en, this message translates to:
  /// **'Q&A'**
  String get guessCategoryQa;

  /// Category chip of the guess card: reservation questions
  ///
  /// In en, this message translates to:
  /// **'Booking'**
  String get guessCategoryBooking;

  /// Refresh action at the bottom of the guess card
  ///
  /// In en, this message translates to:
  /// **'Show more'**
  String get guessRefresh;

  /// Guess card preset question; wording matches the slippers intent trigger
  ///
  /// In en, this message translates to:
  /// **'How do I get two pairs of slippers delivered?'**
  String get faqSlippersDeliver;

  /// Guess card preset question; wording matches the toiletries intent trigger
  ///
  /// In en, this message translates to:
  /// **'Can you bring me a toiletries set?'**
  String get faqToiletriesDeliver;

  /// Guess card preset question; wording matches the towels intent trigger
  ///
  /// In en, this message translates to:
  /// **'Could you bring a few more towels?'**
  String get faqTowelsDeliver;

  /// Guess card preset question; wording matches the water intent trigger
  ///
  /// In en, this message translates to:
  /// **'Please deliver two bottles of water to my room.'**
  String get faqWaterDeliver;

  /// Guess card rotation extra; wording matches the slippers intent trigger
  ///
  /// In en, this message translates to:
  /// **'Can I exchange the slippers for another size?'**
  String get faqSlippersExchange;

  /// Guess card rotation extra; wording matches the towels intent trigger
  ///
  /// In en, this message translates to:
  /// **'Please also bring some bath towels.'**
  String get faqTowelsBath;

  /// Guess card preset question; wording matches the wifi intent trigger
  ///
  /// In en, this message translates to:
  /// **'What is the Wi-Fi password?'**
  String get faqWifiPassword;

  /// Guess card preset question; wording matches the breakfast intent trigger
  ///
  /// In en, this message translates to:
  /// **'What time does breakfast start?'**
  String get faqBreakfastTime;

  /// Guess card rotation extra; wording matches the wifi intent trigger
  ///
  /// In en, this message translates to:
  /// **'How do I join the wireless network?'**
  String get faqWifiConnect;

  /// Guess card rotation extra; wording matches the breakfast intent trigger
  ///
  /// In en, this message translates to:
  /// **'Where is breakfast served?'**
  String get faqBreakfastFloor;

  /// Guess card preset question; wording matches the wake-up intent and the time slot parser
  ///
  /// In en, this message translates to:
  /// **'Set a wake-up call for 07:00 tomorrow, please.'**
  String get faqWakeupSetup;

  /// Guess card preset question; wording matches the wake-up intent trigger
  ///
  /// In en, this message translates to:
  /// **'I would like to set up a wake-up call.'**
  String get faqWakeupGeneral;

  /// Guess card preset question; wording matches the late check-out intent trigger
  ///
  /// In en, this message translates to:
  /// **'Can I request a late checkout?'**
  String get faqLateCheckoutAsk;

  /// Guess card preset question; wording matches the late check-out intent and the time slot parser
  ///
  /// In en, this message translates to:
  /// **'I would like a late checkout at 14:00 tomorrow.'**
  String get faqLateCheckoutTime;

  /// Greeting on the home gradient header (docs/06 §3.4)
  ///
  /// In en, this message translates to:
  /// **'Good afternoon, {guest}'**
  String homeGreeting(String guest);

  /// Hint inside the decorative home search capsule
  ///
  /// In en, this message translates to:
  /// **'Search hotel services'**
  String get homeSearchHint;

  /// Label of the decorative full-round search button
  ///
  /// In en, this message translates to:
  /// **'Search'**
  String get homeSearchButton;

  /// Section title of the home icon grid card
  ///
  /// In en, this message translates to:
  /// **'Hotel services'**
  String get homeServicesTitle;

  /// Decorative home grid tile: item delivery
  ///
  /// In en, this message translates to:
  /// **'Item delivery'**
  String get homeTileDeliver;

  /// Decorative home grid tile: wake-up call
  ///
  /// In en, this message translates to:
  /// **'Wake-up call'**
  String get homeTileWakeup;

  /// Decorative home grid tile: late check-out
  ///
  /// In en, this message translates to:
  /// **'Late check-out'**
  String get homeTileLateCheckout;

  /// Decorative home grid tile: my orders
  ///
  /// In en, this message translates to:
  /// **'My orders'**
  String get homeTileOrders;

  /// Title of the profile member-style banner (demo copy, docs/06 §3.4)
  ///
  /// In en, this message translates to:
  /// **'Shell Plus'**
  String get profileMemberTitle;

  /// Subtitle of the profile member-style banner
  ///
  /// In en, this message translates to:
  /// **'Demo member benefits'**
  String get profileMemberSubtitle;

  /// Decorative profile grid tile: my orders
  ///
  /// In en, this message translates to:
  /// **'My orders'**
  String get profileTileOrders;

  /// Decorative profile grid tile: favorites
  ///
  /// In en, this message translates to:
  /// **'Favorites'**
  String get profileTileFavorites;

  /// Decorative profile grid tile: settings
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get profileTileSettings;

  /// Decorative profile grid tile: contact support
  ///
  /// In en, this message translates to:
  /// **'Contact support'**
  String get profileTileSupport;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['en', 'zh'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'zh':
      return AppLocalizationsZh();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
