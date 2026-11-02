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
  testWidgets('home shows the decorative mock header for locale en', (
    tester,
  ) async {
    await tester.pumpWidget(_wrap(const Locale('en')));
    expect(find.text('Good afternoon, Mr. Zhang'), findsOneWidget);
    expect(find.text('Search hotel services'), findsOneWidget);
    expect(find.text('Hotel services'), findsOneWidget);
  });

  testWidgets('home shows the decorative mock header for locale zh', (
    tester,
  ) async {
    await tester.pumpWidget(_wrap(const Locale('zh')));
    expect(find.text('下午好，张先生'), findsOneWidget);
    expect(find.text('搜索酒店服务'), findsOneWidget);
    expect(find.text('酒店服务'), findsOneWidget);
  });
}
