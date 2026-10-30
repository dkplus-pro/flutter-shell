
import 'package:native_bridge/native_bridge_platform_interface.dart';

class NativeBridge {
  Future<String?> getPlatformVersion() {
    return NativeBridgePlatform.instance.getPlatformVersion();
  }
}
