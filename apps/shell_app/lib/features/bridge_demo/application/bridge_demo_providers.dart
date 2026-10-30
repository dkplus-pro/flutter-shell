import 'package:fluttershell/core/bridge/bridge_providers.dart';
import 'package:native_bridge/native_bridge.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'bridge_demo_providers.g.dart';

/// System info, autoDispose: refetches on every page visit; refresh via
/// `ref.invalidate(systemInfoProvider)`.
@riverpod
Future<SystemInfo> systemInfo(Ref ref) {
  return ref.watch(nativeBridgeProvider).getSystemInfo();
}

/// Native 1Hz ticker, autoDispose: leaving the page cancels the subscription
/// which stops the native ticker (logcat TICK_STOPPED).
@riverpod
Stream<int> tickCount(Ref ref) {
  return ref.watch(nativeBridgeProvider).ticks();
}

/// Native screen round-trip results, autoDispose while the demo page listens.
@riverpod
Stream<NativeScreenResult> nativeScreenResults(Ref ref) {
  return ref.watch(nativeBridgeProvider).nativeScreenResults;
}

/// Opens the native demo screen; presentation calls this through the
/// provider so it never touches [NativeBridge] directly.
@riverpod
Future<bool> openNativeScreen(
  Ref ref, {
  required String title,
  required String message,
}) {
  return ref.read(nativeBridgeProvider).openNativeScreen(
        title: title,
        message: message,
      );
}
