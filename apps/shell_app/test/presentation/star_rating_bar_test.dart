import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fluttershell/features/hotel/presentation/star_rating_bar.dart';

Widget _wrap({
  required int rating,
  required bool enabled,
  required ValueChanged<int> onRated,
}) {
  return MaterialApp(
    home: Scaffold(
      body: Center(
        child: StarRatingBar(
          rating: rating,
          enabled: enabled,
          onRated: onRated,
          semanticsLabel: 'Rate your stay',
        ),
      ),
    ),
  );
}

void main() {
  testWidgets('tapping the fourth star reports onRated(4) exactly once', (
    tester,
  ) async {
    final rated = <int>[];
    await tester.pumpWidget(
      _wrap(rating: 0, enabled: true, onRated: rated.add),
    );

    await tester.tap(find.byIcon(Icons.star_border).at(3));
    await tester.pumpAndSettle();

    expect(rated, <int>[4]);
  });

  testWidgets('ignores taps while disabled', (tester) async {
    final rated = <int>[];
    await tester.pumpWidget(
      _wrap(rating: 0, enabled: false, onRated: rated.add),
    );

    await tester.tap(find.byIcon(Icons.star_border).at(3));
    await tester.pumpAndSettle();

    expect(rated, isEmpty);
  });

  testWidgets('exposes the semantics label and current fill state', (
    tester,
  ) async {
    final handle = tester.ensureSemantics();
    await tester.pumpWidget(_wrap(rating: 2, enabled: true, onRated: (_) {}));

    expect(find.bySemanticsLabel('Rate your stay'), findsOneWidget);
    expect(find.byIcon(Icons.star), findsNWidgets(2));
    expect(find.byIcon(Icons.star_border), findsNWidgets(3));
    handle.dispose();
  });
}
