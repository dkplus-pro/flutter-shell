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
Future<void> pumpShell(WidgetTester tester) async {
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

  testWidgets('home tab shows the placeholder toast and bridge demo entry', (
    tester,
  ) async {
    await pumpShell(tester);

    await tester.tap(find.text('Home'));
    await tester.pumpAndSettle();
    expect(find.text('Hello World'), findsOneWidget);

    await tester.tap(find.text('Hello World'));
    await tester.pump();
    expect(find.text('This feature is not available yet.'), findsOneWidget);

    expect(find.text('Open bridge demo'), findsOneWidget);
  });

  testWidgets('profile tab shows the placeholder toast', (tester) async {
    await pumpShell(tester);

    await tester.tap(find.text('Profile'));
    await tester.pumpAndSettle();

    expect(
      find.text('Personal information will show up here later.'),
      findsOneWidget,
    );

    await tester.tap(find.text('Profile').first);
    await tester.pump();
    expect(find.text('This feature is not available yet.'), findsOneWidget);
  });

  testWidgets('chat input sends a guest message bubble', (tester) async {
    await pumpShell(tester);

    await tester.enterText(find.byType(TextField), 'Hello there');
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
