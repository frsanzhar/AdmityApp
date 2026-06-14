import 'package:flutter/material.dart';

/// Typographic scale.
///
/// Until the bundled display/body `.ttf` files land (see commented `fonts:`
/// block in pubspec), this uses the platform default family but locks in the
/// editorial scale and weights. Swap [displayFamily] / [bodyFamily] to the real
/// families in one place when the fonts are added.
abstract final class AppTypography {
  /// Expressive editorial display family (e.g. Clash Display) — set when bundled.
  static const String? displayFamily = null;

  /// Humanist body family with Cyrillic + Kazakh glyphs (e.g. Inter).
  static const String? bodyFamily = null;

  /// Builds the app [TextTheme] for the given [onSurface] text color.
  static TextTheme textTheme(Color onSurface) {
    final muted = onSurface;
    return TextTheme(
      displayLarge: _d(57, FontWeight.w700, onSurface, -0.5),
      displayMedium: _d(45, FontWeight.w700, onSurface, -0.5),
      displaySmall: _d(36, FontWeight.w600, onSurface, -0.25),
      headlineLarge: _d(32, FontWeight.w700, onSurface, -0.25),
      headlineMedium: _d(28, FontWeight.w700, onSurface, -0.25),
      headlineSmall: _d(24, FontWeight.w600, onSurface, 0),
      titleLarge: _b(22, FontWeight.w600, onSurface),
      titleMedium: _b(16, FontWeight.w600, onSurface),
      titleSmall: _b(14, FontWeight.w600, onSurface),
      bodyLarge: _b(16, FontWeight.w400, onSurface),
      bodyMedium: _b(14, FontWeight.w400, onSurface),
      bodySmall: _b(12, FontWeight.w400, muted),
      labelLarge: _b(14, FontWeight.w600, onSurface),
      labelMedium: _b(12, FontWeight.w600, onSurface),
      labelSmall: _b(11, FontWeight.w500, muted),
    );
  }

  // Note: [displayFamily] / [bodyFamily] are applied app-wide in `AppTheme`
  // (via `TextTheme.apply`) once the bundled `.ttf` files land, so individual
  // styles don't hard-code a family.
  static TextStyle _d(
    double size,
    FontWeight weight,
    Color color,
    double spacing,
  ) =>
      TextStyle(
        fontSize: size,
        fontWeight: weight,
        letterSpacing: spacing,
        height: 1.1,
        color: color,
      );

  static TextStyle _b(double size, FontWeight weight, Color color) => TextStyle(
        fontSize: size,
        fontWeight: weight,
        height: 1.35,
        color: color,
      );
}
