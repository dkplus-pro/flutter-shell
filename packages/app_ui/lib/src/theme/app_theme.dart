import 'package:flutter/material.dart';

/// Material 3 themes seeded from a fixed brand color.
abstract final class AppTheme {
  static const Color _seed = Color(0xFF3D5AFE);

  static ThemeData light() => _base(ColorScheme.fromSeed(seedColor: _seed));

  static ThemeData dark() => _base(ColorScheme.fromSeed(seedColor: _seed, brightness: Brightness.dark));

  static ThemeData _base(ColorScheme scheme) {
    return ThemeData(
      useMaterial3: true,
      colorScheme: scheme,
      appBarTheme: AppBarTheme(backgroundColor: scheme.surface, foregroundColor: scheme.onSurface),
    );
  }
}
