import 'package:admity/core/theme/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

/// Small bright 3-step plan diagram for onboarding plan-cards.
///
/// Three variants map to different plan stages:
/// - [PlanStepVariant.start]   — rocketship launch tile (primary blue)
/// - [PlanStepVariant.improve] — growing bar-chart tile (lime green)
/// - [PlanStepVariant.test]    — checkmark target tile  (gold)
///
/// Each variant draws a compact isometric-style icon on a soft rounded
/// platform. An entry scale+fade animation plays on mount.
/// `MediaQuery.disableAnimations` disables the entry animation.
///
/// Usage:
/// ```dart
/// PlanStepDiagram(variant: PlanStepVariant.start)
/// PlanStepDiagram(variant: PlanStepVariant.improve)
/// PlanStepDiagram(variant: PlanStepVariant.test)
/// ```
enum PlanStepVariant { start, improve, test }

class PlanStepDiagram extends StatelessWidget {
  const PlanStepDiagram({
    super.key,
    this.variant = PlanStepVariant.start,
  });

  final PlanStepVariant variant;

  @override
  Widget build(BuildContext context) {
    final disableAnim = MediaQuery.maybeOf(context)?.disableAnimations ?? false;

    Widget diagram = CustomPaint(
      painter: _PlanStepPainter(variant: variant),
      size: Size.infinite,
    );

    if (!disableAnim) {
      diagram = diagram
          .animate()
          .scale(
            begin: const Offset(0.6, 0.6),
            end: const Offset(1, 1),
            duration: const Duration(milliseconds: 600),
            curve: Curves.easeOutBack,
          )
          .fadeIn(
            duration: const Duration(milliseconds: 400),
            curve: Curves.easeOut,
          );
    }

    return diagram;
  }
}

class _PlanStepPainter extends CustomPainter {
  const _PlanStepPainter({required this.variant});

  final PlanStepVariant variant;

  @override
  void paint(Canvas canvas, Size size) {
    switch (variant) {
      case PlanStepVariant.start:
        _paintStart(canvas, size);
      case PlanStepVariant.improve:
        _paintImprove(canvas, size);
      case PlanStepVariant.test:
        _paintTest(canvas, size);
    }
  }

  // Shared platform disc
  void _drawPlatform(Canvas canvas, Size size, Color color) {
    final cx = size.width * 0.5;
    final cy = size.height * 0.62;
    final rx = size.width * 0.40;
    final ry = size.height * 0.14;

    // Shadow
    canvas.drawOval(
      Rect.fromCenter(
        center: Offset(cx, cy + ry * 0.5),
        width: rx * 1.6,
        height: ry,
      ),
      Paint()
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 10)
        ..color = color.withValues(alpha: 0.18),
    );

    // Disc top
    canvas.drawOval(
      Rect.fromCenter(center: Offset(cx, cy), width: rx * 2, height: ry * 2),
      Paint()..color = color.withValues(alpha: 0.18),
    );
    canvas.drawOval(
      Rect.fromCenter(center: Offset(cx, cy), width: rx * 2, height: ry * 2),
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.2
        ..color = color.withValues(alpha: 0.40),
    );
  }

  // — Start variant: rocket —
  void _paintStart(Canvas canvas, Size size) {
    const blue = AppColors.primary;
    _drawPlatform(canvas, size, blue);

    final cx = size.width * 0.5;
    final cy = size.height * 0.5;
    final sc = size.width * 0.30; // scale reference

    // Rocket body
    final body = Path()
      ..moveTo(cx, cy - sc * 0.85)
      ..quadraticBezierTo(
        cx + sc * 0.30,
        cy - sc * 0.40,
        cx + sc * 0.28,
        cy + sc * 0.15,
      )
      ..lineTo(cx - sc * 0.28, cy + sc * 0.15)
      ..quadraticBezierTo(cx - sc * 0.30, cy - sc * 0.40, cx, cy - sc * 0.85)
      ..close();
    canvas.drawPath(
      body,
      Paint()
        ..shader =
            LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [AppColors.ctaGradient[0], AppColors.primary],
            ).createShader(
              Rect.fromLTWH(cx - sc * 0.3, cy - sc * 0.85, sc * 0.6, sc),
            ),
    );

    // Window
    canvas.drawCircle(
      Offset(cx, cy - sc * 0.22),
      sc * 0.14,
      Paint()..color = AppColors.white.withValues(alpha: 0.85),
    );
    canvas.drawCircle(
      Offset(cx, cy - sc * 0.22),
      sc * 0.08,
      Paint()..color = AppColors.surfaceTint,
    );

    // Fins
    final leftFin = Path()
      ..moveTo(cx - sc * 0.28, cy + sc * 0.12)
      ..lineTo(cx - sc * 0.50, cy + sc * 0.35)
      ..lineTo(cx - sc * 0.28, cy + sc * 0.30)
      ..close();
    final rightFin = Path()
      ..moveTo(cx + sc * 0.28, cy + sc * 0.12)
      ..lineTo(cx + sc * 0.50, cy + sc * 0.35)
      ..lineTo(cx + sc * 0.28, cy + sc * 0.30)
      ..close();
    final finColor = AppColors.navyDeep.withValues(alpha: 0.75);
    canvas.drawPath(leftFin, Paint()..color = finColor);
    canvas.drawPath(rightFin, Paint()..color = finColor);

    // Flame
    final flameColors = [
      AppColors.goldKey,
      AppColors.ctaGradient[3],
      AppColors.ctaGradient[3].withValues(alpha: 0),
    ];
    final flame = Path()
      ..moveTo(cx - sc * 0.14, cy + sc * 0.22)
      ..lineTo(cx, cy + sc * 0.62)
      ..lineTo(cx + sc * 0.14, cy + sc * 0.22)
      ..close();
    canvas.drawPath(
      flame,
      Paint()
        ..shader =
            LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: flameColors,
            ).createShader(
              Rect.fromLTWH(
                cx - sc * 0.14,
                cy + sc * 0.22,
                sc * 0.28,
                sc * 0.4,
              ),
            ),
    );
  }

  // — Improve variant: rising bar chart —
  void _paintImprove(Canvas canvas, Size size) {
    const lime = AppColors.accentLime;
    _drawPlatform(canvas, size, lime);

    final cx = size.width * 0.5;
    final baseY = size.height * 0.58;
    final sc = size.width * 0.10;

    // Three bars of increasing height
    final heights = [sc * 1.4, sc * 2.2, sc * 3.2];
    final barColors = [
      AppColors.successGreen.withValues(alpha: 0.55),
      AppColors.successGreen.withValues(alpha: 0.75),
      AppColors.accentLime,
    ];
    final barWidth = sc * 0.75;
    final gap = sc * 0.30;
    final totalW = barWidth * 3 + gap * 2;
    final startX = cx - totalW / 2;

    for (var i = 0; i < 3; i++) {
      final bx = startX + i * (barWidth + gap);
      final bh = heights[i];

      // Bar body
      final rrect = RRect.fromRectAndRadius(
        Rect.fromLTWH(bx, baseY - bh, barWidth, bh),
        Radius.circular(sc * 0.25),
      );
      canvas.drawRRect(rrect, Paint()..color = barColors[i]);

      // Highlight top edge
      canvas.drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromLTWH(bx, baseY - bh, barWidth, sc * 0.18),
          Radius.circular(sc * 0.25),
        ),
        Paint()..color = AppColors.white.withValues(alpha: 0.35),
      );
    }

    // Upward arrow accent
    final arrowX = cx + totalW / 2 + sc * 0.4;
    final arrowBot = baseY;
    final arrowTop = baseY - heights[2] - sc * 0.6;
    final arrowPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0
      ..color = AppColors.successGreen
      ..strokeCap = StrokeCap.round;
    canvas.drawLine(
      Offset(arrowX, arrowBot),
      Offset(arrowX, arrowTop),
      arrowPaint,
    );
    // Arrowhead
    final arrowPath = Path()
      ..moveTo(arrowX - sc * 0.28, arrowTop + sc * 0.30)
      ..lineTo(arrowX, arrowTop)
      ..lineTo(arrowX + sc * 0.28, arrowTop + sc * 0.30);
    canvas.drawPath(arrowPath, arrowPaint);
  }

  // — Test variant: target with checkmark —
  void _paintTest(Canvas canvas, Size size) {
    const gold = AppColors.goldKey;
    _drawPlatform(canvas, size, gold);

    final cx = size.width * 0.5;
    final cy = size.height * 0.44;
    final sc = size.width * 0.28;

    // Concentric rings (target)
    final ringColors = [
      AppColors.errorRed.withValues(alpha: 0.20),
      AppColors.goldKey.withValues(alpha: 0.35),
      AppColors.goldKey.withValues(alpha: 0.70),
    ];
    for (var i = 2; i >= 0; i--) {
      canvas.drawCircle(
        Offset(cx, cy),
        sc * (0.40 + i * 0.28),
        Paint()..color = ringColors[i],
      );
    }
    // Centre dot
    canvas.drawCircle(Offset(cx, cy), sc * 0.15, Paint()..color = gold);

    // Bold checkmark over center
    final checkPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = sc * 0.16
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round
      ..color = AppColors.white;
    final checkPath = Path()
      ..moveTo(cx - sc * 0.30, cy)
      ..lineTo(cx - sc * 0.08, cy + sc * 0.25)
      ..lineTo(cx + sc * 0.35, cy - sc * 0.28);
    canvas.drawPath(checkPath, checkPaint);

    // Gold glow on check
    canvas.drawPath(
      checkPath,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = sc * 0.04
        ..strokeCap = StrokeCap.round
        ..color = AppColors.accentLime.withValues(alpha: 0.55)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 4),
    );
  }

  @override
  bool shouldRepaint(_PlanStepPainter old) => old.variant != variant;
}
