import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fluttershell/features/hotel/presentation/reply_text.dart';

Widget _wrap(Widget child) {
  return MaterialApp(home: Scaffold(body: child));
}

void main() {
  testWidgets('reveals one character per interval until complete', (
    tester,
  ) async {
    final completed = <int>[];
    await tester.pumpWidget(
      _wrap(
        ReplyTypewriter(text: 'abcdef', onCompleted: () => completed.add(1)),
      ),
    );
    expect(find.text(''), findsOneWidget);

    await tester.pump(const Duration(milliseconds: 30));
    expect(find.text('a'), findsOneWidget);

    await tester.pump(const Duration(milliseconds: 30));
    expect(find.text('ab'), findsOneWidget);
    expect(completed, isEmpty);

    await tester.pump(const Duration(milliseconds: 120));
    expect(find.text('abcdef'), findsOneWidget);
    expect(completed, hasLength(1));
  });

  testWidgets('pauses longer after a punctuation character', (tester) async {
    await tester.pumpWidget(_wrap(const ReplyTypewriter(text: 'a。b')));
    expect(find.text(''), findsOneWidget);

    await tester.pump(const Duration(milliseconds: 30));
    expect(find.text('a'), findsOneWidget);

    await tester.pump(const Duration(milliseconds: 30));
    expect(find.text('a。'), findsOneWidget);

    // Default pause factor 3x: next character needs 90 ms, not 30 ms.
    await tester.pump(const Duration(milliseconds: 30));
    expect(find.text('a。b'), findsNothing);

    await tester.pump(const Duration(milliseconds: 60));
    expect(find.text('a。b'), findsOneWidget);
  });

  testWidgets('reports progress with the visible substring', (tester) async {
    final progress = <String>[];
    await tester.pumpWidget(
      _wrap(ReplyTypewriter(text: 'hi', onProgress: progress.add)),
    );

    await tester.pump(const Duration(milliseconds: 30));
    await tester.pump(const Duration(milliseconds: 30));
    expect(progress, <String>['h', 'hi']);
  });

  testWidgets('restarts from zero when text changes externally', (
    tester,
  ) async {
    await tester.pumpWidget(_wrap(const ReplyTypewriter(text: 'one')));
    await tester.pump(const Duration(milliseconds: 90));
    expect(find.text('one'), findsOneWidget);

    await tester.pumpWidget(_wrap(const ReplyTypewriter(text: 'two')));
    expect(find.text('two'), findsNothing);
    expect(find.text(''), findsOneWidget);

    await tester.pump(const Duration(milliseconds: 30));
    expect(find.text('t'), findsOneWidget);

    await tester.pump(const Duration(milliseconds: 60));
    expect(find.text('two'), findsOneWidget);
  });

  testWidgets('completes immediately for empty text', (tester) async {
    final completed = <int>[];
    await tester.pumpWidget(
      _wrap(ReplyTypewriter(text: '', onCompleted: () => completed.add(1))),
    );
    expect(find.text(''), findsOneWidget);
    expect(completed, hasLength(1));
  });

  testWidgets('cancels its timer when disposed mid-animation', (tester) async {
    await tester.pumpWidget(
      _wrap(const ReplyTypewriter(text: 'still typing here')),
    );
    await tester.pump(const Duration(milliseconds: 30));

    await tester.pumpWidget(_wrap(const SizedBox.shrink()));
    await tester.pump(const Duration(milliseconds: 500));

    expect(tester.takeException(), isNull);
  });
}
