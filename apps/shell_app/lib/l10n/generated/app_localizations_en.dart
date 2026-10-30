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
}
