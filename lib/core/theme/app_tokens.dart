import 'package:flutter/material.dart';

/// Design tokens exposed via [ThemeExtension] so widgets read
/// `Theme.of(context).extension<AppTokens>()!` instead of hard-coding values.
@immutable
class AppTokens extends ThemeExtension<AppTokens> {
  const AppTokens({
    required this.brand,
    required this.accent,
    required this.surfaceMuted,
    required this.gapSm,
    required this.gapMd,
    required this.gapLg,
    required this.radius,
  });

  /// Default light token set. Tune freely as the brand evolves.
  factory AppTokens.light() => const AppTokens(
        brand: Color(0xFF1F4FFF),
        accent: Color(0xFFE2603A), // terracotta
        surfaceMuted: Color(0xFFF2F4F8),
        gapSm: 8,
        gapMd: 16,
        gapLg: 24,
        radius: 16,
      );

  final Color brand;
  final Color accent;
  final Color surfaceMuted;
  final double gapSm;
  final double gapMd;
  final double gapLg;
  final double radius;

  @override
  AppTokens copyWith({
    Color? brand,
    Color? accent,
    Color? surfaceMuted,
    double? gapSm,
    double? gapMd,
    double? gapLg,
    double? radius,
  }) {
    return AppTokens(
      brand: brand ?? this.brand,
      accent: accent ?? this.accent,
      surfaceMuted: surfaceMuted ?? this.surfaceMuted,
      gapSm: gapSm ?? this.gapSm,
      gapMd: gapMd ?? this.gapMd,
      gapLg: gapLg ?? this.gapLg,
      radius: radius ?? this.radius,
    );
  }

  @override
  AppTokens lerp(ThemeExtension<AppTokens>? other, double t) {
    if (other is! AppTokens) return this;
    return AppTokens(
      brand: Color.lerp(brand, other.brand, t)!,
      accent: Color.lerp(accent, other.accent, t)!,
      surfaceMuted: Color.lerp(surfaceMuted, other.surfaceMuted, t)!,
      gapSm: lerpDouble(gapSm, other.gapSm, t),
      gapMd: lerpDouble(gapMd, other.gapMd, t),
      gapLg: lerpDouble(gapLg, other.gapLg, t),
      radius: lerpDouble(radius, other.radius, t),
    );
  }

  static double lerpDouble(double a, double b, double t) => a + (b - a) * t;
}

/// Builds the app [ThemeData] with [AppTokens] attached.
ThemeData buildAppTheme() {
  final tokens = AppTokens.light();
  final scheme = ColorScheme.fromSeed(seedColor: tokens.brand);
  return ThemeData(
    colorScheme: scheme,
    useMaterial3: true,
    scaffoldBackgroundColor: Colors.white,
    extensions: <ThemeExtension<dynamic>>[tokens],
  );
}
