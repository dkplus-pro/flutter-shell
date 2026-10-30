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
}
