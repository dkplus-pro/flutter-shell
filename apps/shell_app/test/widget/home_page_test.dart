import 'package:app_ui/app_ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fluttershell/features/home/presentation/home_page.dart';
import 'package:fluttershell/l10n/generated/app_localizations.dart';

Widget _wrap(Locale locale) {
  return MaterialApp(
    locale: locale,
    localizationsDelegates: const [
      AppLocalizations.delegate,
      GlobalMaterialLocalizations.delegate,
      GlobalWidgetsLocalizations.delegate,
      GlobalCupertinoLocalizations.delegate,
    ],
    supportedLocales: AppLocalizations.supportedLocales,
    theme: AppTheme.light(),
    home: const HomePage(),
  );
}

void main() {
  testWidgets('home shows English hello copy for locale en', (tester) async {
    await tester.pumpWidget(_wrap(const Locale('en')));
    expect(find.text('Hello World'), findsOneWidget);
    expect(find.text('Flutter shell baseline page'), findsOneWidget);
  });

  testWidgets('home shows Chinese hello copy for locale zh', (tester) async {
    await tester.pumpWidget(_wrap(const Locale('zh')));
    expect(find.text('你好，世界'), findsOneWidget);
    expect(find.text('Flutter 壳工程基线页面'), findsOneWidget);
  });
}
