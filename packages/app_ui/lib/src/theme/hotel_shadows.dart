import 'package:flutter/material.dart';

/// Subtle elevation for the hotel demo (docs/06 §2.2): surfaces stay flat in
/// color, but a soft shadow carries the hierarchy so white cards separate
/// from the cool grey page without the heavy Material 3 template look.
abstract final class HotelShadows {
  /// Concierge / guest chat bubbles: the lightest lift in the transcript.
  static const List<BoxShadow> bubble = <BoxShadow>[
    BoxShadow(color: Color(0x0D101828), blurRadius: 6, offset: Offset(0, 2)),
  ];

  /// Cards: guess-question card, order card, small tiles.
  static const List<BoxShadow> card = <BoxShadow>[
    BoxShadow(color: Color(0x0F101828), blurRadius: 14, offset: Offset(0, 4)),
    BoxShadow(color: Color(0x08000000), blurRadius: 2, offset: Offset(0, 1)),
  ];

  /// Quick-panel tiles: one step below [card] so the panel reads as a layer.
  static const List<BoxShadow> tile = <BoxShadow>[
    BoxShadow(color: Color(0x0A101828), blurRadius: 6, offset: Offset(0, 2)),
  ];

  /// Quick panel / order sheet: a raised surface above the page.
  static const List<BoxShadow> raised = <BoxShadow>[
    BoxShadow(color: Color(0x14101828), blurRadius: 24, offset: Offset(0, 8)),
  ];

  /// Top edge of surfaces that sit above the page (bottom nav, input bar).
  static const List<BoxShadow> edgeTop = <BoxShadow>[
    BoxShadow(color: Color(0x0F101828), blurRadius: 12, offset: Offset(0, -2)),
  ];
}
