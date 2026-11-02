import 'package:flutter/material.dart';

/// Hotel demo palette (docs/06 §2.1, restyled to the reference design:
/// blue-purple primary on a cool grey background with pure white surfaces).
///
/// Pages must reference these tokens instead of hardcoding colors inline.
/// The status tokens are shared by the chat order card and the order sheet
/// through `hotelOrderSheetStatusColor` so both surfaces stay in sync.
abstract final class HotelColors {
  /// Primary purple: guest bubbles, CTAs, selected states, navigation.
  static const Color primary = Color(0xFF5747C6);

  /// Deep purple: CTA gradient end, pressed states.
  static const Color primaryDeep = Color(0xFF4638AC);

  /// Soft purple: selected chip background, icon soft fills.
  static const Color primarySoft = Color(0xFFECE8FB);

  /// Page and chat area background (cool grey, no purple tint).
  static const Color bg = Color(0xFFF4F5F7);

  /// Cards, bubbles, panels and the order sheet.
  static const Color surface = Color(0xFFFFFFFF);

  /// Titles and body copy.
  static const Color textPrimary = Color(0xFF191B20);

  /// Secondary copy, timestamps, unselected navigation.
  static const Color textSecondary = Color(0xFF9AA0A8);

  /// Input placeholder text.
  static const Color textHint = Color(0xFFB9BDC6);

  /// 0.5px dividers and the app-bar bottom hairline.
  static const Color divider = Color(0xFFEEEEF1);

  /// Placed / reserved status accent.
  static const Color statusPlaced = Color(0xFF5747C6);

  /// Delivering status accent.
  static const Color statusDelivering = Color(0xFFF5A623);

  /// Delivered status accent.
  static const Color statusDelivered = Color(0xFF34B36B);

  /// Pending / rated neutral status accent.
  static const Color statusNeutral = Color(0xFF8E939C);

  /// Red accents: badges and dot markers.
  static const Color promoRed = Color(0xFFFF5148);

  /// Filled star color on white cards.
  static const Color starGold = Color(0xFFF0A835);

  /// Unfilled star outline.
  static const Color starEmpty = Color(0xFFC7C7CC);

  /// Input capsule background.
  static const Color inputPill = Color(0xFFF2F3F5);

  /// Icon blocks and panel tile backgrounds.
  static const Color tileGray = Color(0xFFF4F5F7);

  /// Supreme-VIP gold gradient (profile member banner): champagne highlight
  /// to deep gold.
  static const Color vipGoldLight = Color(0xFFF9E7B6);

  /// Mid gold stop of the VIP banner gradient.
  static const Color vipGold = Color(0xFFE7C25E);

  /// Deep gold end of the VIP banner gradient.
  static const Color vipGoldDeep = Color(0xFFB9891F);

  /// Dark bronze ink that stays legible on the gold banner.
  static const Color vipInk = Color(0xFF3B2A05);
}
