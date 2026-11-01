import 'package:app_core/app_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fluttershell/app.dart';
import 'package:fluttershell/core/logging/log_providers.dart';
import 'package:fluttershell/core/storage/storage_providers.dart';

import '../hotel/fake_key_value_store.dart';

/// Main-shell widget tests: tab navigation, placeholders and the chat page
/// static path. The real [ShellApp] provides router, theme and l10n; the
/// logger and store are overridden because bootstrap does not run here.
Widget _wrap() {
  return ProviderScope(
    overrides: [
      keyValueStoreProvider.overrideWithValue(FakeKeyValueStore()),
      appLoggerProvider.overrideWithValue(AppLogger.create(isProd: true)),
    ],
    child: const ShellApp(),
  );
}

/// Pumps the shell past the async session restore. Deliberately avoids
/// pumpAndSettle: the chat session is async and the typing indicator
/// animates indefinitely while a reply is in flight.
///
/// Uses a taller-than-default surface because the chat transcript, quick
/// panel and 52dp input pill need more vertical space than the 800x600
/// default provides once the app bar and the 64dp nav bar are deducted.
Future<void> pumpShell(WidgetTester tester) async {
  tester.view.physicalSize = const Size(1200, 1800);
  tester.view.devicePixelRatio = 1.0;
  addTearDown(tester.view.reset);
  await tester.pumpWidget(_wrap());
  await tester.pump();
  await tester.pump(const Duration(seconds: 1));
}

/// Advances the fake clock past the concierge typing delay so the queued
/// reply has been applied.
Future<void> pumpReply(WidgetTester tester) async {
  await tester.pump();
  await tester.pump(const Duration(seconds: 2));
}

void main() {
  testWidgets('shell lands on the services tab with the chat page', (
    tester,
  ) async {
    await pumpShell(tester);

    expect(find.text('AI Concierge'), findsOneWidget);
    expect(find.text('Room 1208 · Mr. Zhang'), findsOneWidget);
    expect(find.text('Home'), findsOneWidget);
    expect(find.text('Services'), findsOneWidget);
    expect(find.text('Profile'), findsOneWidget);
  });

  testWidgets('home tab shows the decorative mock and bridge demo entry', (
    tester,
  ) async {
    await pumpShell(tester);

    await tester.tap(find.text('Home'));
    await tester.pumpAndSettle();
    expect(find.text('Search hotel services'), findsOneWidget);
    expect(find.text('Hotel services'), findsOneWidget);

    await tester.tap(find.text('Search hotel services'));
    await tester.pump();
    expect(find.text('This feature is not available yet.'), findsOneWidget);

    expect(find.text('Open bridge demo'), findsOneWidget);
  });

  testWidgets('profile tab shows the decorative mock and placeholder toast', (
    tester,
  ) async {
    await pumpShell(tester);

    await tester.tap(find.text('Profile'));
    await tester.pumpAndSettle();

    expect(find.text('Mr. Zhang'), findsOneWidget);
    expect(find.text('Shell Plus'), findsOneWidget);

    // The mock profile page is purely decorative: tapping anywhere on it
    // (here the member banner) shows the global placeholder toast.
    await tester.tap(find.text('Shell Plus'));
    await tester.pump();
    expect(find.text('This feature is not available yet.'), findsOneWidget);
  });

  testWidgets('chat input sends a guest message bubble', (tester) async {
    await pumpShell(tester);

    await tester.enterText(find.byType(TextField), 'Hello there');
    // The send button only exists while the input is non-empty, so a frame
    // must pass before the tooltip finder can resolve.
    await tester.pump();
    await tester.tap(find.byTooltip('Send'));
    await pumpReply(tester);

    expect(find.text('Hello there'), findsOneWidget);
  });

  testWidgets('quick panel opens from the + button and sends presets', (
    tester,
  ) async {
    await pumpShell(tester);

    await tester.tap(find.byTooltip('Quick services'));
    await tester.pumpAndSettle();

    expect(find.text('Slippers'), findsOneWidget);
    expect(find.text('Wake-up call'), findsOneWidget);

    await tester.tap(find.text('Slippers'));
    await pumpReply(tester);

    expect(
      find.text('I need some disposable slippers delivered to my room.'),
      findsOneWidget,
    );
  });
}
