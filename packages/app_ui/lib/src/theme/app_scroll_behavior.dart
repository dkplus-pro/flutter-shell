import 'package:flutter/material.dart';

/// App-wide scroll feel: keep content anchored while the finger drags past
/// the edge. Flutter's Android 12+ default is a stretch indicator, which
/// visually drags the whole transcript/card stack; the hotel demo wants the
/// calm, non-elastic behaviour instead (glow and stretch both disabled).
class AppScrollBehavior extends MaterialScrollBehavior {
  const new();

  @override
  Widget buildOverscrollIndicator(
    BuildContext context,
    Widget child,
    ScrollableDetails details,
  ) {
    return child;
  }
}
