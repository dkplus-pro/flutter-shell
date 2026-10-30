import 'package:app_ui/app_ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fluttershell/core/bridge/bridge_providers.dart';
import 'package:fluttershell/features/bridge_demo/presentation/bridge_demo_page.dart';
import 'package:fluttershell/l10n/generated/app_localizations.dart';
import 'package:native_bridge/native_bridge.dart';
import 'package:native_bridge/src/generated/shell_api.g.dart' as shell_api;

/// Host API fake: system info fails with a platform error so the page's
/// error state can be asserted without touching real native code.
class _FailingHostApi extends shell_api.ShellHostApi {
  @override
  Future<shell_api.SystemInfo> getSystemInfo() async {
    throw PlatformException(code: 'SYSTEM_INFO_FAILED', message: 'boom');
  }

  @override
  Future<bool> openNativeScreen(String title, String message) async {
    throw PlatformException(code: 'NO_ACTIVITY', message: 'no activity');
  }
}

Widget _wrap(NativeBridge bridge) {
  return ProviderScope(
    overrides: [nativeBridgeProvider.overrideWithValue(bridge)],
    child: MaterialApp(
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: AppLocalizations.supportedLocales,
      theme: AppTheme.light(),
      home: const BridgeDemoPage(),
    ),
  );
}

void main() {
  late NativeBridge bridge;

  setUp(() {
    bridge = NativeBridge(hostApi: _FailingHostApi())..initialize();
  });

  tearDown(() async {
    await bridge.dispose();
  });

  testWidgets('system info card shows error state when bridge fails', (
    tester,
  ) async {
    await tester.pumpWidget(_wrap(bridge));
    await tester.pumpAndSettle();

    expect(find.textContaining('Something went wrong'), findsOneWidget);
    expect(find.textContaining('SYSTEM_INFO_FAILED'), findsOneWidget);
    expect(find.text('Refresh'), findsOneWidget);
  });

  testWidgets('system info card shows six fields on success', (tester) async {
    final bridgeOk = NativeBridge(
      hostApi: _StubHostApi(),
      tickStreamFactory: () => const Stream<int>.empty(),
    )..initialize();
    addTearDown(bridgeOk.dispose);
    await tester.pumpWidget(_wrap(bridgeOk));
    await tester.pumpAndSettle();

    expect(find.text('android'), findsOneWidget);
    expect(find.text('Android 16 (API 36)'), findsOneWidget);
    expect(find.text('Pixel 7'), findsOneWidget);
    expect(find.text('Google'), findsOneWidget);
    expect(find.text('1.0.0'), findsOneWidget);
    expect(find.text('42'), findsOneWidget);
  });

  testWidgets('ticker card renders the injected stream', (tester) async {
    final bridgeTicks = NativeBridge(
      hostApi: _StubHostApi(),
      tickStreamFactory: () => Stream<int>.fromIterable(<int>[3]),
    )..initialize();
    addTearDown(bridgeTicks.dispose);
    await tester.pumpWidget(_wrap(bridgeTicks));
    await tester.pumpAndSettle();

    expect(find.text('Ticks: 3'), findsOneWidget);
  });
}

class _StubHostApi extends shell_api.ShellHostApi {
  @override
  Future<shell_api.SystemInfo> getSystemInfo() async => shell_api.SystemInfo(
    platform: 'android',
    osVersion: 'Android 16 (API 36)',
    deviceModel: 'Pixel 7',
    manufacturer: 'Google',
    appVersion: '1.0.0',
    buildNumber: '42',
  );

  @override
  Future<bool> openNativeScreen(String title, String message) async => true;
}
