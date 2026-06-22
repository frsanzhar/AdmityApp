import 'dart:math' as math;

import 'package:admity/core/theme/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

/// Bright "easel / art board" header illustration for a course card.
///
/// Fills its parent.  Use inside a [SizedBox] or [AspectRatio] to set
/// the desired dimensions.
///
/// A single fade+slide entrance animation plays on first build unless
/// `MediaQuery.disableAnimations` is true.
class CourseHeaderArt extends StatelessWidget {
  const CourseHeaderArt({super.key});

  @override
  Widget build(BuildContext context) {
    final reduce = MediaQuery.of(context).disableAnimations;

    Widget art = const CustomPaint(
      painter: _CourseHeaderPainter(),
      child: SizedBox.expand(),
    );

    if (!reduce) {
      art = art
          .animate()
          .fadeIn(duration: const Duration(milliseconds: 500))
          .slideY(
            begin: 0.06,
            end: 0,
            duration: const Duration(milliseconds: 600),
            curve: Curves.easeOutCubic,
          );
    }

    return art;
  }
}

// ─── Painter ────────────────────────────────────────────────────────────────

class _CourseHeaderPainter extends CustomPainter {
  const _CourseHeaderPainter();

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;

    // ── Background: light blue-tinted gradient ────────────────────────────
    canvas.drawRect(
      Offset.zero & size,
      Paint()
        ..shader = LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppColors.surfaceTint,
            AppColors.primary.withValues(alpha: 0.06),
          ],
        ).createShader(Offset.zero & size),
    );

    // ── Decorative curved band (upper-right accent) ───────────────────────
    final bandPath = Path()
      ..moveTo(w * 0.55, 0)
      ..quadraticBezierTo(w * 1.1, h * 0.2, w * 0.9, h * 0.85)
      ..lineTo(w, h)
      ..lineTo(w, 0)
      ..close();
    canvas.drawPath(
      bandPath,
      Paint()
        ..shader = LinearGradient(
          begin: Alignment.topRight,
          end: Alignment.bottomLeft,
          colors: [
            AppColors.ctaGradient[0].withValues(alpha: 0.18),
            AppColors.ctaGradient[1].withValues(alpha: 0.10),
          ],
        ).createShader(Offset.zero & size),
    );

    // ── Easel legs ────────────────────────────────────────────────────────
    final legPaint = Paint()
      ..color =
          const Color(0xFFD4A96A) // warm wood tone built from goldKey hue
      ..strokeWidth = 3.5
      ..strokeCap = StrokeCap.round;

    final boardCx = w * 0.48;
    final boardCy = h * 0.42;
    final boardW = w * 0.50;
    final boardH = h * 0.46;
    final boardBottom = boardCy + boardH / 2;

    // Left leg, right leg, cross-brace.
    canvas
      ..drawLine(
        Offset(boardCx - boardW * 0.3, boardBottom),
        Offset(boardCx - boardW * 0.16, h * 0.94),
        legPaint,
      )
      ..drawLine(
        Offset(boardCx + boardW * 0.3, boardBottom),
        Offset(boardCx + boardW * 0.18, h * 0.94),
        legPaint,
      )
      ..drawLine(
        Offset(boardCx - boardW * 0.18, h * 0.80),
        Offset(boardCx + boardW * 0.13, h * 0.80),
        legPaint..strokeWidth = 2.5,
      );

    // ── Canvas board (white card) ─────────────────────────────────────────
    final boardRect = RRect.fromRectAndRadius(
      Rect.fromCenter(
        center: Offset(boardCx, boardCy),
        width: boardW,
        height: boardH,
      ),
      const Radius.circular(10),
    );
    canvas
      ..drawRRect(boardRect, Paint()..color = AppColors.white)
      ..drawRRect(
        boardRect,
        Paint()
          ..color = AppColors.border
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1.5,
      );

    // ── Mini illustration on the board: parabola + axes ───────────────────
    final bx = boardCx;
    final by = boardCy + boardH * 0.05;
    final ax = boardW * 0.35; // axis half-length on board

    final boardAxisPaint = Paint()
      ..color = AppColors.inkSecondary.withValues(alpha: 0.5)
      ..strokeWidth = 1.2;
    canvas
      ..drawLine(Offset(bx - ax, by), Offset(bx + ax, by), boardAxisPaint)
      ..drawLine(
        Offset(bx, by - boardH * 0.34),
        Offset(bx, by + boardH * 0.18),
        boardAxisPaint,
      );

    // Curve.
    final curvePath = Path();
    for (var i = 0; i <= 40; i++) {
      final t = (i / 40 - 0.5) * ax * 1.7;
      final px = bx + t;
      final py = by - (t * t) / (ax * 1.3) + boardH * 0.04;
      if (i == 0) {
        curvePath.moveTo(px, py);
      } else {
        curvePath.lineTo(px, py);
      }
    }
    canvas.drawPath(
      curvePath,
      Paint()
        ..color = AppColors.primary
        ..strokeWidth = 2.2
        ..style = PaintingStyle.stroke
        ..strokeCap = StrokeCap.round,
    );

    // Two data points.
    for (final t in [-ax * 0.7, ax * 0.7]) {
      final px = bx + t;
      final py = by - (t * t) / (ax * 1.3) + boardH * 0.04;
      canvas
        ..drawCircle(Offset(px, py), 4, Paint()..color = AppColors.primary)
        ..drawCircle(
          Offset(px, py),
          4,
          Paint()
            ..color = AppColors.white
            ..style = PaintingStyle.stroke
            ..strokeWidth = 1.5,
        );
    }

    // ── Floating accent shapes ────────────────────────────────────────────
    // Star / sparkle — top right of board.
    _paintSparkle(
      canvas,
      Offset(boardCx + boardW * 0.58, boardCy - boardH * 0.28),
      w * 0.045,
      AppColors.goldKey,
    );

    // Small circle — bottom left.
    canvas.drawCircle(
      Offset(boardCx - boardW * 0.55, boardCy + boardH * 0.25),
      w * 0.038,
      Paint()..color = AppColors.accentLime.withValues(alpha: 0.80),
    );

    // Tiny triangle — upper left.
    _paintTriangle(
      canvas,
      Offset(boardCx - boardW * 0.42, boardCy - boardH * 0.38),
      w * 0.048,
      AppColors.ctaGradient[2].withValues(alpha: 0.75),
    );

    // ── Pencil ────────────────────────────────────────────────────────────
    _paintPencil(
      canvas,
      Offset(boardCx + boardW * 0.38, boardCy + boardH * 0.4),
      w,
    );
  }

  void _paintSparkle(Canvas canvas, Offset center, double r, Color color) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = 2
      ..strokeCap = StrokeCap.round;
    for (var i = 0; i < 4; i++) {
      final angle = i * math.pi / 4;
      canvas.drawLine(
        Offset(
          center.dx + r * 0.4 * math.cos(angle),
          center.dy + r * 0.4 * math.sin(angle),
        ),
        Offset(
          center.dx + r * math.cos(angle),
          center.dy + r * math.sin(angle),
        ),
        paint,
      );
    }
    canvas.drawCircle(center, r * 0.28, Paint()..color = color);
  }

  void _paintTriangle(Canvas canvas, Offset center, double r, Color color) {
    final path = Path();
    for (var i = 0; i < 3; i++) {
      final angle = -math.pi / 2 + i * 2 * math.pi / 3;
      final px = center.dx + r * math.cos(angle);
      final py = center.dy + r * math.sin(angle);
      if (i == 0) {
        path.moveTo(px, py);
      } else {
        path.lineTo(px, py);
      }
    }
    path.close();
    canvas.drawPath(path, Paint()..color = color);
  }

  void _paintPencil(Canvas canvas, Offset tip, double w) {
    // Pencil body — rotated ~-45°.
    const angle = -math.pi * 0.30;
    final len = w * 0.13;
    final thick = w * 0.025;

    canvas
      ..save()
      ..translate(tip.dx, tip.dy)
      ..rotate(angle);

    // Body.
    final bodyRect = RRect.fromRectAndRadius(
      Rect.fromLTWH(-thick / 2, 0, thick, len),
      Radius.circular(thick * 0.2),
    );
    canvas.drawRRect(bodyRect, Paint()..color = AppColors.goldKey);

    // Tip triangle.
    final tipPath = Path()
      ..moveTo(-thick / 2, len)
      ..lineTo(thick / 2, len)
      ..lineTo(0, len + thick * 1.4)
      ..close();
    canvas
      ..drawPath(tipPath, Paint()..color = AppColors.ink)
      // Eraser end.
      ..drawRect(
        Rect.fromLTWH(-thick / 2, -thick * 0.8, thick, thick * 0.8),
        Paint()..color = AppColors.ctaGradient[2],
      )
      ..restore();
  }

  @override
  bool shouldRepaint(_CourseHeaderPainter old) => false;
}
