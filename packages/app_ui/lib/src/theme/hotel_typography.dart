import 'package:app_ui/src/theme/hotel_colors.dart';
import 'package:flutter/material.dart';

/// Hotel demo type scale (docs/06 §2.2): system font, hierarchy expressed
/// through weight only — no custom font files in v0.
abstract final class HotelTypography {
  /// Section titles (guess-question card, order sheet, quick panel).
  static const TextStyle titleL = TextStyle(
    fontSize: 20,
    fontWeight: FontWeight.w700,
    color: HotelColors.textPrimary,
    height: 1.3,
  );

  /// App bars and card titles.
  static const TextStyle title = TextStyle(
    fontSize: 17,
    fontWeight: FontWeight.w700,
    color: HotelColors.textPrimary,
    height: 1.3,
  );

  /// Bubble and body copy.
  static const TextStyle body = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w400,
    color: HotelColors.textPrimary,
    height: 1.4,
  );

  /// Secondary copy and timestamps.
  static const TextStyle sub = TextStyle(
    fontSize: 13,
    fontWeight: FontWeight.w400,
    color: HotelColors.textSecondary,
    height: 1.4,
  );

  /// Bottom navigation labels.
  static const TextStyle navLabel = TextStyle(fontSize: 11, height: 1.2);
}
