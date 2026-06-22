import 'package:flutter/material.dart';

/// Brand color constants for Admity (DESIGN_SYSTEM.md §1).
///
/// All colors must be referenced from this class — never use
/// [Colors.deepPurple] or ad-hoc literals anywhere in the app.
abstract final class AppColors {
  // ── Brand ──────────────────────────────────────────────────────────────────

  /// Cobalt — primary accent, active tab indicator.
  static const primary = Color(0xFF4255FF);

  /// Pressed / dark variant of [primary].
  static const primaryDark = Color(0xFF2B3CC9);

  /// Dark navy — used for 3D illustration edges.
  static const navyDeep = Color(0xFF14246B);

  // ── Accent ─────────────────────────────────────────────────────────────────

  /// Yellow-green — streak lightning badge.
  static const accentLime = Color(0xFFC2F03C);

  /// Progress / "correct" green.
  static const successGreen = Color(0xFF1FD65F);

  /// Mascot placeholder silhouette colour.
  static const mascotGreen = Color(0xFF35D24A);

  /// Keys / in-app currency.
  static const goldKey = Color(0xFFFFB020);

  /// "Wrong answer" / error state.
  static const errorRed = Color(0xFFE5484D);

  // ── Text ───────────────────────────────────────────────────────────────────

  /// Near-black — headings, dark buttons.
  static const ink = Color(0xFF16161D);

  /// Muted grey — captions, secondary labels.
  static const inkSecondary = Color(0xFF5B5F6B);

  // ── Surfaces ───────────────────────────────────────────────────────────────

  static const white = Color(0xFFFFFFFF);

  /// Light blue-tinted background for tabs / sections.
  static const surfaceTint = Color(0xFFF4F6FB);

  /// Dividers and card strokes.
  static const border = Color(0xFFE7E9F0);

  /// Soft drop-shadow for cards — 8 % opacity dark.
  static const cardShadow = Color(0x14101828);

  // ── Gradients ──────────────────────────────────────────────────────────────

  /// Four-stop gradient for featured CTA buttons
  /// (Jump ahead / Start the Lesson / lesson completion).
  /// Direction: left → right (blue → purple → pink → orange).
  static const ctaGradient = <Color>[
    Color(0xFF6E8BFF),
    Color(0xFFB07BFF),
    Color(0xFFFF7BC4),
    Color(0xFFFFB14E),
  ];
}
