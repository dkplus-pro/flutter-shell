import 'package:app_core/app_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fluttershell/app.dart';
import 'package:fluttershell/core/logging/log_providers.dart';
import 'package:fluttershell/core/storage/storage_providers.dart';
import 'package:fluttershell/features/hotel/presentation/order_card.dart';
import 'package:fluttershell/features/hotel/presentation/star_rating_bar.dart';

import '../hotel/fake_key_value_store.dart';

/// Chat main-path widget tests (PRD 12 item 2): scripted slot flow, order
/// card lifecycle and the app-bar order sheet mapping.
///
/// The session provider is keepAlive and bootstrap does not run here, so the
/// logger and store are overridden; the clock stays real (fake-async timers
/// driven by [WidgetTester.pump]).
Widget _wrap() {
  return ProviderScope(
    overrides: [
      keyValueStoreProvider.overrideWithValue(FakeKeyValueStore()),
      appLoggerProvider.overrideWithValue(AppLogger.create(isProd: true)),
    ],
    child: const ShellApp(),
  );
}

Future<void> _pumpShell(WidgetTester tester) async {
  await tester.pumpWidget(_wrap());
  await tester.pump();
  await tester.pump(const Duration(seconds: 1));
}

/// Advances past the typing delay (800-1500ms) and lets the reply apply.
Future<void> _pumpReply(WidgetTester tester) async {
  await tester.pump();
  await tester.pump(const Duration(seconds: 2));
}

Future<void> _send(WidgetTester tester, String text) async {
  await tester.enterText(find.byType(TextField), text);
  // Let the ValueListenableBuilder enable the send button first.
  await tester.pump();
  await tester.tap(find.byTooltip('Send'));
  await _pumpReply(tester);
}

/// Brings the tail of the transcript into the hit-testable area: the newest
/// messages sit behind the input bar until the list is scrolled.
Future<void> _revealTail(WidgetTester tester) async {
  await tester.drag(find.byType(Scrollable).first, const Offset(0, -220));
  await tester.pumpAndSettle();
}

void main() {
  testWidgets('S1 main path: slots, card, status flow and one rating', (
    tester,
  ) async {
    await _pumpShell(tester);

    await _send(tester, '我需要两双拖鞋');
    expect(find.byType(OrderCard), findsNothing);

    await _send(tester, '2 双');
    expect(find.byType(OrderCard), findsOneWidget);
    await _revealTail(tester);
    expect(find.text('Confirm order'), findsOneWidget);

    // Only the first confirmation counts (PRD 6.3).
    await tester.tap(find.text('Confirm order'));
    await tester.pump(const Duration(milliseconds: 300));
    expect(find.text('Confirm order'), findsNothing);
    expect(find.text('Placed'), findsOneWidget);

    await tester.pump(const Duration(seconds: 2));
    expect(find.text('Placed'), findsOneWidget, reason: '~3s to delivering');

    await tester.pump(const Duration(seconds: 3));
    expect(find.text('Delivering'), findsOneWidget);

    await tester.pump(const Duration(seconds: 8));
    expect(find.text('Delivered'), findsOneWidget);
    expect(find.byType(StarRatingBar), findsOneWidget);

    await _revealTail(tester);
    await tester.tap(find.byType(StarRatingBar));
    await tester.pump(const Duration(milliseconds: 300));
    expect(find.byType(StarRatingBar), findsNothing);
    // The label shows on the status badge and on the rated row.
    expect(find.text('Rated · 3 stars'), findsNWidgets(2));
  });

  testWidgets('app-bar icon opens the order sheet with mapped rows', (
    tester,
  ) async {
    await _pumpShell(tester);

    await _send(tester, '我需要两双拖鞋');
    await _send(tester, '2 双');
    await _revealTail(tester);
    await tester.tap(find.text('Confirm order'));
    await tester.pump(const Duration(milliseconds: 300));

    await tester.tap(find.byTooltip('View orders'));
    await tester.pumpAndSettle();

    expect(find.textContaining('Current orders'), findsOneWidget);
    expect(find.text('Disposable slippers ×2'), findsOneWidget);
    // The same copy renders in the chat card behind the sheet.
    expect(find.text('Deliver to room 1208'), findsNWidgets(2));
    expect(find.text('Placed'), findsNWidgets(2));
  });

  testWidgets('order sheet shows the empty state before any order', (
    tester,
  ) async {
    await _pumpShell(tester);

    await tester.tap(find.byTooltip('View orders'));
    await tester.pumpAndSettle();

    expect(find.textContaining('Current orders'), findsOneWidget);
    expect(find.text('No orders yet'), findsOneWidget);
  });
}
