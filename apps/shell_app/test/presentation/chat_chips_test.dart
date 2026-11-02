import 'package:app_ui/app_ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fluttershell/features/hotel/presentation/chat_chips.dart';

Widget _wrap(Widget child) {
  return MaterialApp(
    home: Scaffold(body: Center(child: child)),
  );
}

Color _chipColor(WidgetTester tester) {
  final text = tester.widget<Text>(find.text('07:00'));
  return text.style!.color!;
}

void main() {
  testWidgets('enabled chips send the tapped option once', (tester) async {
    String? selected;
    await tester.pumpWidget(
      _wrap(
        ChatChips(
          options: const ['07:00', '08:00'],
          onSelect: (value) => selected = value,
        ),
      ),
    );

    expect(_chipColor(tester), HotelColors.primary);
    await tester.tap(find.text('07:00'));
    await tester.pump();

    expect(selected, '07:00');
  });

  testWidgets('spent chips ignore taps and render muted', (tester) async {
    var taps = 0;
    await tester.pumpWidget(
      _wrap(
        ChatChips(
          options: const ['07:00', '08:00'],
          enabled: false,
          onSelect: (_) => taps += 1,
        ),
      ),
    );

    expect(_chipColor(tester), HotelColors.textSecondary);
    await tester.tap(find.text('07:00'));
    await tester.pump();

    expect(taps, 0);
  });
}
