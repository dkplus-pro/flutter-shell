import 'package:flutter/material.dart';

/// Hotel demo palette (PRD 05 §9, D9: purple-gold accent on grey-white).
///
/// Starting values from the PRD; pages must reference these tokens instead
/// of hardcoding colors inline.
abstract final class HotelColors {
  /// Primary purple: guest bubbles, primary actions, selected states.
  static const Color primary = Color(0xFF4C3B8F);

  /// Gold accent: room badge, status badges, stars, separators.
  static const Color gold = Color(0xFFC9A25E);

  /// Chat area background (grey-white).
  static const Color chatBackground = Color(0xFFF5F6F8);

  /// Cards and concierge bubbles.
  static const Color surface = Color(0xFFFFFFFF);

  /// Title/body text.
  static const Color textPrimary = Color(0xFF1F2126);

  /// Secondary/hint text.
  static const Color textSecondary = Color(0xFF8A8F99);
}
