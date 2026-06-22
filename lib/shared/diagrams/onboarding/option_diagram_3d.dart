import 'dart:math' as math;

import 'package:admity/core/theme/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

/// Isometric 3D tile for answer-choice cards in onboarding.
///
/// Four visual variants are available via [OptionDiagram3DVariant]:
/// - [OptionDiagram3DVariant.motivation] — golden star tower
/// - [OptionDiagram3DVariant.beginner]   — soft blue platform
/// - [OptionDiagram3DVariant.advanced]   — purple-to-cobalt stack
/// - [OptionDiagram3DVariant.explorer]   — lime-green compass tile
///
/// The tile breathes with a subtle float animation on mount.
/// `MediaQuery.disableAnimations` disables the float.
///
/// Usage:
/// ```dart
/// OptionDiagram3D(variant: OptionDiagram3DVariant.motivation)
/// ```
enum OptionDiagram3DVariant { motivation, beginner, advanced, explorer }

class OptionDiagram3D extends StatelessWidget {
  const OptionDiagram3D({
    super.key,
    this.variant = OptionDiagram3DVariant.motivation,
  });

  final OptionDiagram3DVariant variant;

  @override
  Widget build(BuildContext context) {
    final disableAnim = MediaQuery.maybeOf(context)?.disableAnimations ?? false;

    Widget tile = CustomPaint(
      painter: _IsoTilePainter(variant: variant),
      size: Size.infinite,
    );

    if (!disableAnim) {
      tile = tile
          .animate(onPlay: (c) => c.repeat(reverse: true))
          .moveY(
            begin: 0,
            end: -6,
            duration: const Duration(milliseconds: 1800),
            curve: Curves.easeInOut,
          );
    }

    return tile;
  }
}

class _IsoTilePainter extends CustomPainter {
  const _IsoTilePainter({required this.variant});

  final OptionDiagram3DVariant variant;

  // Isometric projection helpers
  static Offset _iso(double x, double y, double z, Size s) {
    const tileW = 0.52; // fraction of size
    const tileH = 0.30;
    final cx = s.width * 0.5;
    final cy = s.height * 0.55;
    return Offset(
      cx + (x - y) * s.width * tileW * 0.5,
      cy + (x + y) * s.height * tileH * 0.5 - z * s.height * 0.24,
    );
  }

  void _drawBlock({
    required Canvas canvas,
    required Size size,
    required double x,
    required double y,
    required double z,
    required double w, // width in iso units
    required double d, // depth in iso units
    required double h, // height in iso units
    required Color top,
    required Color left,
    required Color right,
  }) {
    // Top face
    final topPath = Path()
      ..moveTo(_iso(x, y, z + h, size).dx, _iso(x, y, z + h, size).dy)
      ..lineTo(_iso(x + w, y, z + h, size).dx, _iso(x + w, y, z + h, size).dy)
      ..lineTo(
        _iso(x + w, y + d, z + h, size).dx,
        _iso(x + w, y + d, z + h, size).dy,
      )
      ..lineTo(_iso(x, y + d, z + h, size).dx, _iso(x, y + d, z + h, size).dy)
      ..close();
    canvas.drawPath(topPath, Paint()..color = top);

    // Left face
    final leftPath = Path()
      ..moveTo(_iso(x, y + d, z + h, size).dx, _iso(x, y + d, z + h, size).dy)
      ..lineTo(
        _iso(x + w, y + d, z + h, size).dx,
        _iso(x + w, y + d, z + h, size).dy,
      )
      ..lineTo(_iso(x + w, y + d, z, size).dx, _iso(x + w, y + d, z, size).dy)
      ..lineTo(_iso(x, y + d, z, size).dx, _iso(x, y + d, z, size).dy)
      ..close();
    canvas.drawPath(leftPath, Paint()..color = left);

    // Right face
    final rightPath = Path()
      ..moveTo(_iso(x + w, y, z + h, size).dx, _iso(x + w, y, z + h, size).dy)
      ..lineTo(
        _iso(x + w, y + d, z + h, size).dx,
        _iso(x + w, y + d, z + h, size).dy,
      )
      ..lineTo(_iso(x + w, y + d, z, size).dx, _iso(x + w, y + d, z, size).dy)
      ..lineTo(_iso(x + w, y, z, size).dx, _iso(x + w, y, z, size).dy)
      ..close();
    canvas.drawPath(rightPath, Paint()..color = right);

    // Edge lines
    final edgePaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 0.8
      ..color = AppColors.navyDeep.withValues(alpha: 0.12);
    canvas.drawPath(topPath, edgePaint);
    canvas.drawPath(leftPath, edgePaint);
    canvas.drawPath(rightPath, edgePaint);
  }

  @override
  void paint(Canvas canvas, Size size) {
    switch (variant) {
      case OptionDiagram3DVariant.motivation:
        _paintMotivation(canvas, size);
      case OptionDiagram3DVariant.beginner:
        _paintBeginner(canvas, size);
      case OptionDiagram3DVariant.advanced:
        _paintAdvanced(canvas, size);
      case OptionDiagram3DVariant.explorer:
        _paintExplorer(canvas, size);
    }
  }

  // Golden star tower
  void _paintMotivation(Canvas canvas, Size size) {
    const gold = AppColors.goldKey;
    final goldMid = AppColors.goldKey.withValues(alpha: 0.72);
    const goldDark = Color(0xFFB87800);

    // Base platform
    _drawBlock(
      canvas: canvas,
      size: size,
      x: -0.6,
      y: -0.6,
      z: 0,
      w: 1.2,
      d: 1.2,
      h: 0.18,
      top: goldMid,
      left: goldDark,
      right: goldDark.withValues(alpha: 0.8),
    );
    // Mid block
    _drawBlock(
      canvas: canvas,
      size: size,
      x: -0.35,
      y: -0.35,
      z: 0.18,
      w: 0.7,
      d: 0.7,
      h: 0.22,
      top: gold,
      left: goldDark,
      right: goldDark.withValues(alpha: 0.85),
    );
    // Top gem
    _drawBlock(
      canvas: canvas,
      size: size,
      x: -0.18,
      y: -0.18,
      z: 0.40,
      w: 0.36,
      d: 0.36,
      h: 0.32,
      top: const Color(0xFFFFD060),
      left: goldDark,
      right: goldDark.withValues(alpha: 0.9),
    );

    // Star accent on top
    final starCenter = _iso(0, 0, 0.72, size);
    _drawStar(
      canvas,
      starCenter,
      size.width * 0.07,
      AppColors.white.withValues(alpha: 0.9),
    );
  }

  // Soft blue platform
  void _paintBeginner(Canvas canvas, Size size) {
    const blue = AppColors.primary;
    final blueMid = AppColors.primary.withValues(alpha: 0.7);
    const blueDark = AppColors.navyDeep;

    _drawBlock(
      canvas: canvas,
      size: size,
      x: -0.65,
      y: -0.65,
      z: 0,
      w: 1.3,
      d: 1.3,
      h: 0.14,
      top: blueMid,
      left: blueDark,
      right: blueDark.withValues(alpha: 0.8),
    );
    _drawBlock(
      canvas: canvas,
      size: size,
      x: -0.4,
      y: -0.4,
      z: 0.14,
      w: 0.8,
      d: 0.8,
      h: 0.25,
      top: blue,
      left: blueDark,
      right: blueDark.withValues(alpha: 0.85),
    );
    // Dot grid on top
    final dotPaint = Paint()..color = AppColors.white.withValues(alpha: 0.5);
    for (var row = -1; row <= 1; row++) {
      for (var col = -1; col <= 1; col++) {
        final dot = _iso(col * 0.22, row * 0.22, 0.39, size);
        canvas.drawCircle(dot, 2.5, dotPaint);
      }
    }
  }

  // Purple-to-cobalt stack
  void _paintAdvanced(Canvas canvas, Size size) {
    final purple = AppColors.ctaGradient[1];
    const purpleDark = Color(0xFF6B3FCC);
    const cobalt = AppColors.primary;
    const cobaltDark = AppColors.primaryDark;

    _drawBlock(
      canvas: canvas,
      size: size,
      x: -0.65,
      y: -0.65,
      z: 0,
      w: 1.3,
      d: 1.3,
      h: 0.12,
      top: purple.withValues(alpha: 0.6),
      left: purpleDark,
      right: purpleDark.withValues(alpha: 0.8),
    );
    _drawBlock(
      canvas: canvas,
      size: size,
      x: -0.45,
      y: -0.45,
      z: 0.12,
      w: 0.9,
      d: 0.9,
      h: 0.20,
      top: purple,
      left: purpleDark,
      right: purpleDark.withValues(alpha: 0.85),
    );
    _drawBlock(
      canvas: canvas,
      size: size,
      x: -0.25,
      y: -0.25,
      z: 0.32,
      w: 0.5,
      d: 0.5,
      h: 0.28,
      top: cobalt,
      left: cobaltDark,
      right: cobaltDark.withValues(alpha: 0.9),
    );
    // Lightning bolt icon on top
    final boltCenter = _iso(0, 0, 0.60, size);
    _drawBolt(canvas, boltCenter, size.width * 0.08, AppColors.accentLime);
  }

  // Lime-green compass tile
  void _paintExplorer(Canvas canvas, Size size) {
    const lime = AppColors.accentLime;
    const limeDeep = Color(0xFF7AAD00);
    const green = AppColors.successGreen;

    _drawBlock(
      canvas: canvas,
      size: size,
      x: -0.65,
      y: -0.65,
      z: 0,
      w: 1.3,
      d: 1.3,
      h: 0.16,
      top: lime.withValues(alpha: 0.65),
      left: limeDeep,
      right: limeDeep.withValues(alpha: 0.8),
    );
    _drawBlock(
      canvas: canvas,
      size: size,
      x: -0.4,
      y: -0.4,
      z: 0.16,
      w: 0.8,
      d: 0.8,
      h: 0.24,
      top: lime,
      left: limeDeep,
      right: limeDeep.withValues(alpha: 0.85),
    );
    // Compass rose on top
    final compassCenter = _iso(0, 0, 0.40, size);
    _drawCompass(canvas, compassCenter, size.width * 0.09, green);
  }

  void _drawStar(Canvas canvas, Offset center, double r, Color color) {
    final path = Path();
    for (var i = 0; i < 10; i++) {
      final angle = (i * math.pi / 5) - math.pi / 2;
      final radius = i.isEven ? r : r * 0.45;
      final x = center.dx + math.cos(angle) * radius;
      final y = center.dy + math.sin(angle) * radius;
      i == 0 ? path.moveTo(x, y) : path.lineTo(x, y);
    }
    path.close();
    canvas.drawPath(path, Paint()..color = color);
  }

  void _drawBolt(Canvas canvas, Offset center, double size, Color color) {
    final path = Path()
      ..moveTo(center.dx + size * 0.1, center.dy - size)
      ..lineTo(center.dx - size * 0.25, center.dy)
      ..lineTo(center.dx + size * 0.05, center.dy)
      ..lineTo(center.dx - size * 0.1, center.dy + size)
      ..lineTo(center.dx + size * 0.25, center.dy - 0.05)
      ..lineTo(center.dx - size * 0.05, center.dy - 0.05)
      ..close();
    canvas.drawPath(path, Paint()..color = color);
  }

  void _drawCompass(Canvas canvas, Offset center, double r, Color color) {
    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5
      ..color = color;
    canvas.drawCircle(center, r, paint);
    // Cross arms
    for (var i = 0; i < 4; i++) {
      final angle = i * math.pi / 2;
      final inner = Offset(
        center.dx + math.cos(angle) * r * 0.45,
        center.dy + math.sin(angle) * r * 0.45,
      );
      final outer = Offset(
        center.dx + math.cos(angle) * r * 0.85,
        center.dy + math.sin(angle) * r * 0.85,
      );
      canvas.drawLine(inner, outer, paint..strokeWidth = i.isEven ? 2.0 : 1.2);
    }
    canvas.drawCircle(center, 2.5, Paint()..color = color);
  }

  @override
  bool shouldRepaint(_IsoTilePainter old) => old.variant != variant;
}
