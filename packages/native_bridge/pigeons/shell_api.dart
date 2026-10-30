import 'package:pigeon/pigeon.dart';

class SystemInfo {
  SystemInfo({
    required this.platform,
    required this.osVersion,
    required this.deviceModel,
    required this.manufacturer,
    required this.appVersion,
    required this.buildNumber,
  });

  final String platform;
  final String osVersion;
  final String deviceModel;
  final String manufacturer;
  final String appVersion;
  final String buildNumber;
}

class NativeScreenResult {
  NativeScreenResult({
    required this.confirmed,
    required this.message,
  });

  final bool confirmed;
  final String message;
}

@HostApi()
abstract class ShellHostApi {
  @async
  SystemInfo getSystemInfo();

  @async
  bool openNativeScreen(String title, String message);
}

@EventChannelApi()
abstract class TickStreamApi {
  int ticks();
}

@FlutterApi()
abstract class ShellFlutterApi {
  void onNativeScreenResult(NativeScreenResult result);
}
