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

  /// Greeting shown on the home page
  ///
  /// In en, this message translates to:
  /// **'Hello World'**
  String get helloWorld;

  /// Subtitle under the greeting
  ///
  /// In en, this message translates to:
  /// **'Flutter shell baseline page'**
  String get helloSubtitle;

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

  /// App bar title of the profile placeholder page
  ///
  /// In en, this message translates to:
  /// **'Profile'**
  String get profileTitle;

  /// Centered title on the profile placeholder page
  ///
  /// In en, this message translates to:
  /// **'Profile'**
  String get profileCenterTitle;

  /// Centered subtitle on the profile placeholder page
  ///
  /// In en, this message translates to:
  /// **'Personal information will show up here later.'**
  String get profileCenterSubtitle;

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

  /// Day separator line above the first message
  ///
  /// In en, this message translates to:
  /// **'Today {date}'**
  String chatTodayMarker(String date);

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
