import 'package:flutter/material.dart';

import 'hotel_colors.dart';
import 'hotel_dimens.dart';
import 'hotel_typography.dart';

/// App themes.
///
/// Light theme (docs/06 §3.1): an explicitly constructed color scheme built
/// from the hotel tokens — no `fromSeed` surface tinting — with pure white
/// cards on the cool grey background and zero elevation everywhere.
abstract final class AppTheme {
  static ThemeData light() => _base(_lightScheme());

  static ThemeData dark() {
    return _base(
      ColorScheme.fromSeed(
        seedColor: HotelColors.primary,
        brightness: Brightness.dark,
      ),
    );
  }

  static ColorScheme _lightScheme() {
    return const ColorScheme.light(
      primary: HotelColors.primary,
      onPrimary: Colors.white,
      secondary: HotelColors.primary,
      onSecondary: Colors.white,
      error: HotelColors.promoRed,
      onError: Colors.white,
      surface: HotelColors.surface,
      onSurface: HotelColors.textPrimary,
    );
  }

  static ThemeData _base(ColorScheme scheme) {
    return ThemeData(
      useMaterial3: true,
      colorScheme: scheme,
      scaffoldBackgroundColor: HotelColors.bg,
      splashFactory: InkSparkle.splashFactory,
      appBarTheme: const AppBarTheme(
        backgroundColor: HotelColors.surface,
        foregroundColor: HotelColors.textPrimary,
        centerTitle: true,
        elevation: 0,
        scrolledUnderElevation: 0,
        titleTextStyle: HotelTypography.title,
        shape: Border(
          bottom: BorderSide(color: HotelColors.divider, width: 0.5),
        ),
      ),
      cardTheme: CardThemeData(
        color: HotelColors.surface,
        elevation: 0,
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(HotelDimens.cardRadius),
        ),
      ),
      dividerTheme: const DividerThemeData(
        color: HotelColors.divider,
        thickness: HotelDimens.hairline,
        space: HotelDimens.hairline,
      ),
    );
  }
}
