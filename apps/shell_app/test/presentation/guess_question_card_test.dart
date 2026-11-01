import 'package:app_core/app_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fluttershell/core/logging/log_providers.dart';
import 'package:fluttershell/core/storage/storage_providers.dart';
import 'package:fluttershell/features/hotel/application/hotel_clock_provider.dart';
import 'package:fluttershell/features/hotel/data/amenity_catalog.dart';
import 'package:fluttershell/features/hotel/data/chat_message.dart';
import 'package:fluttershell/features/hotel/data/concierge_agent.dart';
import 'package:fluttershell/features/hotel/presentation/guess_question_card.dart';
import 'package:fluttershell/features/hotel/presentation/hotel_chat_page.dart';
import 'package:fluttershell/l10n/generated/app_localizations.dart';

import '../hotel/fake_key_value_store.dart';
import '../hotel/manual_schedule.dart';

Widget _wrap(Widget child, {Locale locale = const Locale('en')}) {
  return MaterialApp(
    localizationsDelegates: AppLocalizations.localizationsDelegates,
    supportedLocales: AppLocalizations.supportedLocales,
    locale: locale,
    home: Scaffold(body: SingleChildScrollView(child: child)),
  );
}

Future<AppLocalizations> _load(Locale locale) =>
    AppLocalizations.delegate.load(locale);

/// The FAQ row texts are the only 15pt texts in the card; chips, the title
/// and the refresh label use other sizes.
List<String> _rowTexts(WidgetTester tester) {
  return tester
      .widgetList<Text>(find.byType(Text))
      .map((text) => text.data)
      .whereType<String>()
      .where(
        (data) => tester
            .widgetList<Text>(find.text(data))
            .any((text) => text.style?.fontSize == 15),
      )
      .toSet()
      .toList();
}

void main() {
  testWidgets('renders title, three category chips, four rows and refresh', (
    tester,
  ) async {
    final l10n = await _load(const Locale('en'));
    await tester.pumpWidget(_wrap(GuessQuestionCard(onSelect: (_) {})));

    expect(find.text(l10n.guessCardTitle), findsOneWidget);
    expect(find.text(l10n.guessCategoryDelivery), findsOneWidget);
    expect(find.text(l10n.guessCategoryQa), findsOneWidget);
    expect(find.text(l10n.guessCategoryBooking), findsOneWidget);
    expect(find.text(l10n.guessRefresh), findsOneWidget);
    expect(find.byIcon(Icons.chevron_right), findsNWidgets(4));
    expect(_rowTexts(tester), hasLength(4));
  });

  testWidgets('refresh rotates the visible batch of the current category', (
    tester,
  ) async {
    await tester.pumpWidget(_wrap(GuessQuestionCard(onSelect: (_) {})));

    final before = _rowTexts(tester);
    await tester.tap(find.byIcon(Icons.refresh));
    await tester.pump();
    final after = _rowTexts(tester);

    expect(after, hasLength(4));
    expect(after, isNot(equals(before)));
    // Rotation walks the pool one slot at a time, so the batches overlap.
    expect(after.toSet().intersection(before.toSet()), isNotEmpty);
  });

  testWidgets('switching category swaps the question pool', (tester) async {
    final l10n = await _load(const Locale('en'));
    await tester.pumpWidget(_wrap(GuessQuestionCard(onSelect: (_) {})));
    expect(find.text(l10n.faqWifiPassword), findsNothing);

    await tester.tap(find.text(l10n.guessCategoryQa));
    await tester.pump();

    expect(find.text(l10n.faqWifiPassword), findsOneWidget);
    expect(find.byIcon(Icons.chevron_right), findsNWidgets(4));
  });

  testWidgets('tapping a row sends that preset text', (tester) async {
    final selected = <String>[];
    await tester.pumpWidget(_wrap(GuessQuestionCard(onSelect: selected.add)));

    final firstRow = _rowTexts(tester).first;
    await tester.tap(find.text(firstRow));
    await tester.pump();

    expect(selected, <String>[firstRow]);
  });

  testWidgets('every FAQ preset in both locales hits a non-fallback intent', (
    tester,
  ) async {
    const agent = ScriptedConciergeAgent();
    for (final locale in AppLocalizations.supportedLocales) {
      final l10n = await _load(locale);
      final presets = <String>[
        l10n.faqSlippersDeliver,
        l10n.faqToiletriesDeliver,
        l10n.faqTowelsDeliver,
        l10n.faqWaterDeliver,
        l10n.faqSlippersExchange,
        l10n.faqTowelsBath,
        l10n.faqWifiPassword,
        l10n.faqBreakfastTime,
        l10n.faqWifiConnect,
        l10n.faqBreakfastFloor,
        l10n.faqWakeupSetup,
        l10n.faqWakeupGeneral,
        l10n.faqLateCheckoutAsk,
        l10n.faqLateCheckoutTime,
      ];
      for (final preset in presets) {
        final response = agent.respond(
          AgentRequest(input: preset, pending: null, roomNo: '1208'),
        );
        final hitFallback = response.actions.whereType<SayAction>().any(
          (action) => action.reply == ScriptedReply.fallback,
        );
        expect(
          hitFallback,
          isFalse,
          reason: '"$preset" ($locale) must hit an intent, not the fallback',
        );
      }
      // Spot-check the flows the guess card is designed to open: the
      // slippers preset starts the amenity quantity flow for slippers.
      final slippers = agent.respond(
        AgentRequest(
          input: l10n.faqSlippersDeliver,
          pending: null,
          roomNo: '1208',
        ),
      );
      expect(slippers.nextPending?.amenity, Amenity.slippers);
      // The Wi-Fi preset answers directly instead of opening a flow.
      final wifi = agent.respond(
        AgentRequest(
          input: l10n.faqWifiPassword,
          pending: null,
          roomNo: '1208',
        ),
      );
      expect(
        wifi.actions.whereType<SayAction>().map((action) => action.reply),
        contains(ScriptedReply.wifiAnswer),
      );
    }
  });

  testWidgets('welcome guess card disappears after the first guest message', (
    tester,
  ) async {
    final schedule = ManualSchedule();
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          keyValueStoreProvider.overrideWithValue(FakeKeyValueStore()),
          appLoggerProvider.overrideWithValue(AppLogger.create(isProd: true)),
          hotelClockProvider.overrideWithValue(schedule.buildClock()),
        ],
        child: const MaterialApp(
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          locale: Locale('en'),
          home: HotelChatPage(),
        ),
      ),
    );
    // Controller build, welcome bubble and the typewriter reveal settle.
    await tester.pumpAndSettle();
    expect(find.byType(GuessQuestionCard), findsOneWidget);

    final firstRow = _rowTexts(tester).first;
    await tester.tap(find.text(firstRow));
    await tester.pump();

    // The guest bubble replaced the card in the transcript.
    expect(find.byType(GuessQuestionCard), findsNothing);
    expect(find.text(firstRow), findsOneWidget);

    // Drain the scripted typing delay, then let the reply reveal finish so
    // no timer survives the test.
    schedule.elapse(const Duration(seconds: 30));
    await tester.pumpAndSettle();
    expect(find.byType(GuessQuestionCard), findsNothing);
  });
}
