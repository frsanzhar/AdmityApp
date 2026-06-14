import 'package:flutter/material.dart';

/// Raw brand color tokens.
///
/// Deliberately warm and earthy — a Kazakh-steppe identity that avoids the
/// generic purple→blue "AI gradient". Semantic roles (primary, surface, XP,
/// streak, chancing categories) are assigned in `AppTokens` / `AppTheme`.
abstract final class AppColors {
  // ── Brand ────────────────────────────────────────────────────────────────
  /// Primary action — terracotta.
  static const Color terracotta = Color(0xFFC8633B);
  static const Color terracottaDark = Color(0xFFA34E2C);
  static const Color terracottaSoft = Color(0xFFE89B7C);

  /// Secondary accent — deep teal-green (growth / path).
  static const Color teal = Color(0xFF1E6E62);
  static const Color tealSoft = Color(0xFF5DA89B);

  /// XP / streak accent — warm amber.
  static const Color amber = Color(0xFFE8A93C);
  static const Color amberSoft = Color(0xFFF3CD86);

  /// Success — olive green.
  static const Color olive = Color(0xFF6E8B3D);

  /// Warning / at-risk — burnt orange.
  static const Color burntOrange = Color(0xFFD98A2B);

  /// Danger / below-threshold — clay red.
  static const Color clay = Color(0xFFB4452F);

  // ── Light surfaces ─────────────────────────────────────────────────────────
  static const Color sand = Color(0xFFF6F1E7); // background
  static const Color cream = Color(0xFFFFFBF3); // raised card
  static const Color sandAlt = Color(0xFFEDE6D6); // sunken / variant
  static const Color inkLight = Color(0xFF231F1A); // primary text on light
  static const Color inkMutedLight = Color(0xFF6B6358);

  // ── Dark surfaces (warm, not pure black) ────────────────────────────────────
  static const Color graphite = Color(0xFF1C1A17); // background
  static const Color graphiteRaised = Color(0xFF262320); // card
  static const Color graphiteAlt = Color(0xFF322E29); // variant
  static const Color inkDark = Color(0xFFF4EEE3); // primary text on dark
  static const Color inkMutedDark = Color(0xFFB3A99B);
}
