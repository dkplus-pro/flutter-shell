import 'dart:async';

import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:native_bridge/native_bridge.dart';
import 'package:native_bridge/src/generated/shell_api.g.dart' as shell_api;

/// Fake host API: methods throw [PlatformException] like the platform layer
/// would; used to prove error code preservation in the wrapper.
class _FailingHostApi extends shell_api.ShellHostApi {
  new(this._code) : super();

  final String _code;

  @override
  Future<shell_api.SystemInfo> getSystemInfo() async {
    throw PlatformException(code: _code, message: 'boom');
  }

  @override
  Future<bool> openNativeScreen(String title, String message) async {
    throw PlatformException(code: _code, message: 'boom');
  }
}

const String _flutterApiChannel =
    'dev.flutter.pigeon.native_bridge.ShellFlutterApi.onNativeScreenResult';

void _pushResult({required bool confirmed, required String message}) {
  final binding = TestDefaultBinaryMessengerBinding.instance;
  unawaited(
    binding.defaultBinaryMessenger.handlePlatformMessage(
      _flutterApiChannel,
      shell_api.ShellFlutterApi.pigeonChannelCodec.encodeMessage(<Object?>[
        shell_api.NativeScreenResult(confirmed: confirmed, message: message),
      ]),
      (data) {},
    ),
  );
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('maps PlatformException to BridgeException preserving code', () async {
    final bridge = NativeBridge(hostApi: _FailingHostApi('NO_ACTIVITY'));
    await expectLater(
      bridge.getSystemInfo(),
      throwsA(
        isA<BridgeException>()
            .having((e) => e.code, 'code', 'NO_ACTIVITY')
            .having((e) => e.message, 'message', 'boom'),
      ),
    );
    await expectLater(
      bridge.openNativeScreen(title: 't', message: 'm'),
      throwsA(
        isA<BridgeException>().having((e) => e.code, 'code', 'NO_ACTIVITY'),
      ),
    );
  });

  test('ticks before initialize throws StateError', () {
    final bridge = NativeBridge();
    expect(bridge.ticks, throwsStateError);
  });

  test('initialize is idempotent and ticks uses injected stream', () async {
    final controller = StreamController<int>();
    addTearDown(controller.close);
    final bridge = NativeBridge(tickStreamFactory: () => controller.stream)
      ..initialize()
      ..initialize();

    final events = <int>[];
    final sub = bridge.ticks().listen(events.add);
    await controller.addStream(Stream<int>.fromIterable(<int>[0, 1]));
    await Future<void>.delayed(Duration.zero);
    expect(events, <int>[0, 1]);
    await sub.cancel();
  });

  test('flutter api handler feeds the broadcast results stream', () async {
    final bridge = NativeBridge(hostApi: _FailingHostApi('NO_ACTIVITY'))
      ..initialize();

    final first = <shell_api.NativeScreenResult>[];
    final second = <shell_api.NativeScreenResult>[];
    final sub1 = bridge.nativeScreenResults.listen(first.add);
    final sub2 = bridge.nativeScreenResults.listen(second.add);

    _pushResult(confirmed: true, message: 'Confirmed in native screen');
    await Future<void>.delayed(Duration.zero);

    expect(first.length, 1);
    expect(second.length, 1);
    expect(first.first.confirmed, isTrue);
    expect(first.first.message, 'Confirmed in native screen');

    await sub1.cancel();
    await sub2.cancel();
    await bridge.dispose();
    expect(bridge.isInitialized, isFalse);
  });
}
