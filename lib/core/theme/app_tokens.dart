import 'dart:ui';

import 'package:admity/core/theme/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Design tokens exposed via [ThemeExtension] so widgets read
/// `Theme.of(context).extension<AppTokens>()!` instead of hard-coding values.
///
/// Token values are specified in DESIGN_SYSTEM.md §3.
@immutable
class AppTokens extends ThemeExtension<AppTokens> {
  const AppTokens({
    // radii
    required this.radiusSm,
    required this.radiusMd,
    required this.radiusLg,
    required this.radiusXl,
    // gaps
    required this.gapXs,
    required this.gapSm,
    required this.gapMd,
    required this.gapLg,
    required this.gapXl,
    required this.gapXxl,
    // layout
    required this.cardPadding,
    required this.screenPadding,
    // shadow
    required this.cardShadow,
  });

  /// Full token set matching DESIGN_SYSTEM.md §3.
  factory AppTokens.defaults() => const AppTokens(
        radiusSm: 12,
        radiusMd: 16,
        radiusLg: 20,
        radiusXl: 28,
        gapXs: 4,
        gapSm: 8,
        gapMd: 12,
        gapLg: 16,
        gapXl: 24,
        gapXxl: 32,
        cardPadding: 16,
        screenPadding: 20,
        cardShadow: <BoxShadow>[
          BoxShadow(
            color: AppColors.cardShadow,
            blurRadius: 24,
            offset: Offset(0, 8),
          ),
        ],
      );

  // ── Radii ──────────────────────────────────────────────────────────────────
  final double radiusSm; // 12
  final double radiusMd; // 16
  final double radiusLg; // 20
  final double radiusXl; // 28

  // ── Gaps ───────────────────────────────────────────────────────────────────
  final double gapXs; // 4
  final double gapSm; // 8
  final double gapMd; // 12
  final double gapLg; // 16
  final double gapXl; // 24
  final double gapXxl; // 32

  // ── Layout ─────────────────────────────────────────────────────────────────
  final double cardPadding; // 16
  final double screenPadding; // 20

  // ── Shadow ─────────────────────────────────────────────────────────────────

  /// Soft card shadow: blur 24, y-offset 8, colour [AppColors.cardShadow].
  final List<BoxShadow> cardShadow;

  @override
  AppTokens copyWith({
    double? radiusSm,
    double? radiusMd,
    double? radiusLg,
    double? radiusXl,
    double? gapXs,
    double? gapSm,
    double? gapMd,
    double? gapLg,
    double? gapXl,
    double? gapXxl,
    double? cardPadding,
    double? screenPadding,
    List<BoxShadow>? cardShadow,
  }) {
    return AppTokens(
      radiusSm: radiusSm ?? this.radiusSm,
      radiusMd: radiusMd ?? this.radiusMd,
      radiusLg: radiusLg ?? this.radiusLg,
      radiusXl: radiusXl ?? this.radiusXl,
      gapXs: gapXs ?? this.gapXs,
      gapSm: gapSm ?? this.gapSm,
      gapMd: gapMd ?? this.gapMd,
      gapLg: gapLg ?? this.gapLg,
      gapXl: gapXl ?? this.gapXl,
      gapXxl: gapXxl ?? this.gapXxl,
      cardPadding: cardPadding ?? this.cardPadding,
      screenPadding: screenPadding ?? this.screenPadding,
      cardShadow: cardShadow ?? this.cardShadow,
    );
  }

  @override
  AppTokens lerp(ThemeExtension<AppTokens>? other, double t) {
    if (other is! AppTokens) return this;
    return AppTokens(
      radiusSm: lerpDouble(radiusSm, other.radiusSm, t)!,
      radiusMd: lerpDouble(radiusMd, other.radiusMd, t)!,
      radiusLg: lerpDouble(radiusLg, other.radiusLg, t)!,
      radiusXl: lerpDouble(radiusXl, other.radiusXl, t)!,
      gapXs: lerpDouble(gapXs, other.gapXs, t)!,
      gapSm: lerpDouble(gapSm, other.gapSm, t)!,
      gapMd: lerpDouble(gapMd, other.gapMd, t)!,
      gapLg: lerpDouble(gapLg, other.gapLg, t)!,
      gapXl: lerpDouble(gapXl, other.gapXl, t)!,
      gapXxl: lerpDouble(gapXxl, other.gapXxl, t)!,
      cardPadding: lerpDouble(cardPadding, other.cardPadding, t)!,
      screenPadding: lerpDouble(screenPadding, other.screenPadding, t)!,
      cardShadow: other.cardShadow, // shadows are not linearly interpolated
    );
  }
}

/// Builds the Onest text theme from the scale in DESIGN_SYSTEM.md §2.
///
/// Uses [GoogleFonts.onest] which includes full Cyrillic (KZ + RU).
/// Fallback: Manrope (also full Cyrillic), then system sans-serif.
TextTheme _buildOnestTextTheme() {
  TextStyle onest(
    double size, {
    FontWeight weight = FontWeight.w400,
    double? letterSpacing,
    Color? color,
  }) {
    return GoogleFonts.onest(
      fontSize: size,
      fontWeight: weight,
      letterSpacing: letterSpacing,
      color: color,
    );
  }

  return TextTheme(
    // display — 34 / w800 / -0.5 ls
    displayLarge: onest(34, weight: FontWeight.w800, letterSpacing: -0.5),
    // h1 — 26 / w800 / -0.3 ls
    headlineLarge: onest(26, weight: FontWeight.w800, letterSpacing: -0.3),
    // h2 — 20 / w700
    headlineMedium: onest(20, weight: FontWeight.w700),
    // title — 17 / w700
    titleLarge: onest(17, weight: FontWeight.w700),
    // body — 16 / w500
    bodyLarge: onest(16, weight: FontWeight.w500),
    // label — 14 / w600
    labelLarge: onest(14, weight: FontWeight.w600),
    // caption — 13 / w500 / inkSecondary
    bodySmall: onest(13, weight: FontWeight.w500, color: AppColors.inkSecondary),
  );
}

/// Builds the full app [ThemeData] with [AppTokens] and Onest typography.
///
/// Seeds [ColorScheme] from [AppColors.primary]; overrides scaffold background
/// to white; removes the default Material purple tint.
ThemeData buildAppTheme() {
  final tokens = AppTokens.defaults();
  final textTheme = _buildOnestTextTheme();

  final scheme = ColorScheme.fromSeed(
    seedColor: AppColors.primary,
    primary: AppColors.primary,
    onPrimary: AppColors.white,
    surface: AppColors.white,
    onSurface: AppColors.ink,
  );

  return ThemeData(
    useMaterial3: true,
    colorScheme: scheme,
    scaffoldBackgroundColor: AppColors.white,
    textTheme: textTheme,
    fontFamily: GoogleFonts.onest().fontFamily,
    extensions: <ThemeExtension<dynamic>>[tokens],
  );
}
