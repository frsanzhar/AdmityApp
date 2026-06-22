import 'dart:math' as math;

import 'package:admity/core/theme/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

/// Identifies which subject illustration to render.
enum TopicVariant {
  /// Fractions: bright orange/yellow — pie slices, ½ symbol.
  fractions,

  /// Functions: cobalt/teal — axes + parabola curve.
  functions,

  /// Geometry: purple — triangle, circle, intersecting forms.
  geometry,

  /// Logic: coral/pink — Venn diagram circles with glowing overlap.
  logic,

  /// Language: lime/green — speech bubbles with lines.
  language,

  /// Coding: navy/primary — terminal prompt + brackets.
  coding,
}

/// Colorful, per-topic course illustration widget.
///
/// Each variant uses a unique palette drawn exclusively from [AppColors]
/// (+ [AppColors.ctaGradient] + opacity).  The widget fills its parent
/// (use inside a [SizedBox] to constrain).
///
/// A subtle entrance animation (fade + scale in) plays once on first build
/// unless `MediaQuery.disableAnimations` is true.
class LessonTopicDiagram extends StatelessWidget {
  const LessonTopicDiagram({
    required this.variant,
    super.key,
  });

  final TopicVariant variant;

  @override
  Widget build(BuildContext context) {
    final reduce = MediaQuery.of(context).disableAnimations;

    Widget diagram = CustomPaint(
      painter: _TopicPainter(variant: variant),
      child: const SizedBox.expand(),
    );

    if (!reduce) {
      diagram = diagram
          .animate()
          .fadeIn(duration: const Duration(milliseconds: 400))
          .scaleXY(
            begin: 0.88,
            end: 1,
            duration: const Duration(milliseconds: 500),
            curve: Curves.easeOutBack,
          );
    }

    return diagram;
  }
}

// ─── Master painter (dispatches to topic sub-methods) ───────────────────────

class _TopicPainter extends CustomPainter {
  const _TopicPainter({required this.variant});

  final TopicVariant variant;

  @override
  void paint(Canvas canvas, Size size) {
    // Rounded clip so the illustration never bleeds outside its slot.
    final rrect = RRect.fromRectAndRadius(
      Offset.zero & size,
      const Radius.circular(20),
    );
    canvas.clipRRect(rrect);

    switch (variant) {
      case TopicVariant.fractions:
        _paintFractions(canvas, size);
      case TopicVariant.functions:
        _paintFunctions(canvas, size);
      case TopicVariant.geometry:
        _paintGeometry(canvas, size);
      case TopicVariant.logic:
        _paintLogic(canvas, size);
      case TopicVariant.language:
        _paintLanguage(canvas, size);
      case TopicVariant.coding:
        _paintCoding(canvas, size);
    }
  }

  // ── Fractions ────────────────────────────────────────────────────────────
  // Warm amber/orange background, large pie disc with coloured slices.
  void _paintFractions(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;

    // Background — warm cream.
    canvas.drawRect(
      Offset.zero & size,
      Paint()..color = const Color(0xFFFFF7E6),
    );

    // Decorative dots.
    _paintDots(canvas, size, AppColors.goldKey.withValues(alpha: 0.18));

    final cx = w * 0.52;
    final cy = h * 0.5;
    final r = math.min(w, h) * 0.32;

    // Pie slices — ½ gold, ¼ orange, ¼ cream.
    final slices = [
      (0.0, math.pi, AppColors.goldKey), // half
      (math.pi, math.pi / 2, AppColors.errorRed.withValues(alpha: 0.8)),
      (math.pi * 1.5, math.pi / 2, const Color(0xFFFFD580)),
    ];
    for (final (start, sweep, color) in slices) {
      canvas.drawArc(
        Rect.fromCircle(center: Offset(cx, cy), radius: r),
        start,
        sweep,
        true,
        Paint()..color = color,
      );
      // Divider line.
      final endX = cx + r * math.cos(start + sweep);
      final endY = cy + r * math.sin(start + sweep);
      canvas.drawLine(
        Offset(cx, cy),
        Offset(endX, endY),
        Paint()
          ..color = AppColors.white
          ..strokeWidth = 2.5,
      );
    }

    // Outer ring.
    canvas.drawCircle(
      Offset(cx, cy),
      r,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 3
        ..color = AppColors.goldKey.withValues(alpha: 0.6),
    );

    // "½" label.
    _drawText(
      canvas,
      '½',
      Offset(cx - r * 0.3, cy - r * 0.5),
      AppColors.white,
      w * 0.11,
      FontWeight.w800,
    );
  }

  // ── Functions ─────────────────────────────────────────────────────────────
  // Cobalt/teal background, axes + smooth parabola curve.
  void _paintFunctions(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;

    canvas.drawRect(
      Offset.zero & size,
      Paint()
        ..shader = LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppColors.surfaceTint,
            AppColors.primary.withValues(alpha: 0.08),
          ],
        ).createShader(Offset.zero & size),
    );

    _paintDots(canvas, size, AppColors.primary.withValues(alpha: 0.10));

    final midX = w * 0.5;
    final midY = h * 0.54;
    final axisLen = math.min(w, h) * 0.38;

    // Axes.
    final axisPaint = Paint()
      ..color = AppColors.inkSecondary.withValues(alpha: 0.45)
      ..strokeWidth = 1.8
      ..strokeCap = StrokeCap.round;
    canvas
      ..drawLine(
        Offset(midX - axisLen, midY),
        Offset(midX + axisLen, midY),
        axisPaint,
      )
      ..drawLine(
        Offset(midX, midY - axisLen),
        Offset(midX, midY + axisLen * 0.5),
        axisPaint,
      );

    // Arrow heads.
    _arrowHead(canvas, Offset(midX + axisLen, midY), 0, axisPaint.color);
    _arrowHead(
      canvas,
      Offset(midX, midY - axisLen),
      -math.pi / 2,
      axisPaint.color,
    );

    // Parabola.
    final curvePaint = Paint()
      ..color = AppColors.primary
      ..strokeWidth = 2.8
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    final path = Path();
    for (var i = 0; i <= 60; i++) {
      final t = (i / 60 - 0.5) * axisLen * 1.8;
      final px = midX + t;
      final py = midY - (t * t) / (axisLen * 1.4);
      if (i == 0) {
        path.moveTo(px, py);
      } else {
        path.lineTo(px, py);
      }
    }
    // Draw curve then vertex dot.
    canvas
      ..drawPath(path, curvePaint)
      ..drawCircle(
        Offset(midX, midY),
        5,
        Paint()..color = AppColors.primary,
      )
      ..drawCircle(
        Offset(midX, midY),
        5,
        Paint()
          ..color = AppColors.white
          ..style = PaintingStyle.stroke
          ..strokeWidth = 2,
      );

    // f(x) label.
    _drawText(
      canvas,
      'f(x)',
      Offset(midX + axisLen * 0.5, midY - axisLen * 0.85),
      AppColors.primary,
      w * 0.08,
      FontWeight.w700,
    );
  }

  // ── Geometry ──────────────────────────────────────────────────────────────
  // Soft purple background, triangle + circle + intersection accent.
  void _paintGeometry(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;

    canvas.drawRect(
      Offset.zero & size,
      Paint()
        ..shader = const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFFF5F0FF),
            Color(0xFFEDE5FF),
          ],
        ).createShader(Offset.zero & size),
    );

    _paintDots(canvas, size, AppColors.ctaGradient[1].withValues(alpha: 0.12));

    final cx = w * 0.5;
    final cy = h * 0.52;
    final r = math.min(w, h) * 0.28;

    // Large circle.
    canvas
      ..drawCircle(
        Offset(cx, cy),
        r,
        Paint()
          ..color = AppColors.ctaGradient[1].withValues(alpha: 0.22)
          ..style = PaintingStyle.fill,
      )
      ..drawCircle(
        Offset(cx, cy),
        r,
        Paint()
          ..color = AppColors.ctaGradient[1].withValues(alpha: 0.7)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 2.5,
      );

    // Triangle inscribed.
    final tPath = Path();
    for (var i = 0; i < 3; i++) {
      final angle = -math.pi / 2 + i * 2 * math.pi / 3;
      final px = cx + r * math.cos(angle);
      final py = cy + r * math.sin(angle);
      if (i == 0) {
        tPath.moveTo(px, py);
      } else {
        tPath.lineTo(px, py);
      }
    }
    tPath.close();
    canvas
      ..drawPath(
        tPath,
        Paint()
          ..color = AppColors.ctaGradient[1].withValues(alpha: 0.35)
          ..style = PaintingStyle.fill,
      )
      ..drawPath(
        tPath,
        Paint()
          ..color = AppColors.ctaGradient[1]
          ..style = PaintingStyle.stroke
          ..strokeWidth = 2.5
          ..strokeJoin = StrokeJoin.round,
      )
      // Small accent circle at bottom-right, then angle arc at apex.
      ..drawCircle(
        Offset(cx + r * 0.7, cy + r * 0.55),
        r * 0.28,
        Paint()..color = AppColors.accentLime.withValues(alpha: 0.75),
      )
      ..drawArc(
        Rect.fromCircle(center: Offset(cx, cy - r), radius: r * 0.22),
        math.pi / 4,
        math.pi / 2,
        false,
        Paint()
          ..color = AppColors.goldKey
          ..style = PaintingStyle.stroke
          ..strokeWidth = 2,
      );
  }

  // ── Logic ─────────────────────────────────────────────────────────────────
  // Coral/pink Venn diagram — two circles, glowing intersection.
  void _paintLogic(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;

    canvas.drawRect(
      Offset.zero & size,
      Paint()..color = const Color(0xFFFFF0F3),
    );

    _paintDots(canvas, size, AppColors.errorRed.withValues(alpha: 0.10));

    final cy = h * 0.5;
    final r = math.min(w, h) * 0.27;
    final offset = r * 0.75;
    final cx1 = w / 2 - offset * 0.7;
    final cx2 = w / 2 + offset * 0.7;

    // Left circle.
    // Left circle, right circle, glowing intersection.
    canvas
      ..drawCircle(
        Offset(cx1, cy),
        r,
        Paint()..color = AppColors.errorRed.withValues(alpha: 0.28),
      )
      ..drawCircle(
        Offset(cx1, cy),
        r,
        Paint()
          ..color = AppColors.errorRed.withValues(alpha: 0.7)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 2.5,
      )
      ..drawCircle(
        Offset(cx2, cy),
        r,
        Paint()..color = AppColors.ctaGradient[2].withValues(alpha: 0.28),
      )
      ..drawCircle(
        Offset(cx2, cy),
        r,
        Paint()
          ..color = AppColors.ctaGradient[2].withValues(alpha: 0.7)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 2.5,
      )
      ..saveLayer(Offset.zero & size, Paint())
      ..drawCircle(Offset(cx1, cy), r, Paint()..color = AppColors.white)
      ..drawCircle(
        Offset(cx2, cy),
        r,
        Paint()
          ..color = AppColors.ctaGradient[2].withValues(alpha: 0.55)
          ..blendMode = BlendMode.srcIn,
      )
      ..restore();

    // "A" / "B" labels.
    _drawText(
      canvas,
      'A',
      Offset(cx1 - r * 0.52, cy - r * 0.2),
      AppColors.errorRed,
      w * 0.09,
      FontWeight.w800,
    );
    _drawText(
      canvas,
      'B',
      Offset(cx2 + r * 0.22, cy - r * 0.2),
      AppColors.ctaGradient[2],
      w * 0.09,
      FontWeight.w800,
    );

    // "∩" in intersection.
    _drawText(
      canvas,
      '∩',
      Offset((cx1 + cx2) / 2 - w * 0.045, cy - r * 0.22),
      AppColors.ink,
      w * 0.09,
      FontWeight.w700,
    );
  }

  // ── Language ──────────────────────────────────────────────────────────────
  // Lime/mint green — speech bubbles.
  void _paintLanguage(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;

    canvas.drawRect(
      Offset.zero & size,
      Paint()
        ..shader = const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFFF0FFF6),
            Color(0xFFE2FFF0),
          ],
        ).createShader(Offset.zero & size),
    );

    _paintDots(canvas, size, AppColors.successGreen.withValues(alpha: 0.12));

    // Bubble 1 — upper left, larger.
    _paintBubble(
      canvas,
      Rect.fromCenter(
        center: Offset(w * 0.38, h * 0.38),
        width: w * 0.52,
        height: h * 0.28,
      ),
      AppColors.successGreen.withValues(alpha: 0.18),
      AppColors.successGreen.withValues(alpha: 0.65),
      tailLeft: true,
    );

    // Bubble 2 — lower right, smaller.
    _paintBubble(
      canvas,
      Rect.fromCenter(
        center: Offset(w * 0.60, h * 0.65),
        width: w * 0.40,
        height: h * 0.22,
      ),
      AppColors.accentLime.withValues(alpha: 0.22),
      AppColors.accentLime.withValues(alpha: 0.70),
      tailLeft: false,
    );

    // Text lines inside bubbles.
    _paintTextLines(
      canvas,
      Offset(w * 0.18, h * 0.32),
      w * 0.42,
      h * 0.06,
      AppColors.successGreen.withValues(alpha: 0.55),
    );
    _paintTextLines(
      canvas,
      Offset(w * 0.43, h * 0.60),
      w * 0.32,
      h * 0.05,
      AppColors.accentLime.withValues(alpha: 0.65),
    );
  }

  void _paintBubble(
    Canvas canvas,
    Rect rect,
    Color fill,
    Color stroke, {
    required bool tailLeft,
  }) {
    final rr = RRect.fromRectAndRadius(
      rect,
      Radius.circular(rect.height * 0.4),
    );
    canvas
      ..drawRRect(rr, Paint()..color = fill)
      ..drawRRect(
        rr,
        Paint()
          ..color = stroke
          ..style = PaintingStyle.stroke
          ..strokeWidth = 2,
      );

    // Tail triangle.
    final tx = tailLeft
        ? rect.left + rect.width * 0.2
        : rect.right - rect.width * 0.2;
    final tailPath = Path()
      ..moveTo(tx - 8, rect.bottom - 1)
      ..lineTo(tx + 8, rect.bottom - 1)
      ..lineTo(tx + (tailLeft ? -4 : 4), rect.bottom + 10)
      ..close();
    canvas
      ..drawPath(tailPath, Paint()..color = fill)
      ..drawPath(
        tailPath,
        Paint()
          ..color = stroke
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1.5,
      );
  }

  void _paintTextLines(
    Canvas canvas,
    Offset origin,
    double w,
    double lineH,
    Color color,
  ) {
    for (var i = 0; i < 2; i++) {
      final paint = Paint()
        ..color = color
        ..strokeWidth = lineH * 0.45
        ..strokeCap = StrokeCap.round;
      final lineW = i == 0 ? w : w * 0.65;
      canvas.drawLine(
        Offset(origin.dx, origin.dy + i * lineH * 1.5),
        Offset(origin.dx + lineW, origin.dy + i * lineH * 1.5),
        paint,
      );
    }
  }

  // ── Coding ────────────────────────────────────────────────────────────────
  // Navy/cobalt terminal aesthetic — brackets, prompt, code lines.
  void _paintCoding(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;

    // Dark terminal background.
    canvas.drawRect(
      Offset.zero & size,
      Paint()
        ..shader = const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [AppColors.navyDeep, AppColors.ink],
        ).createShader(Offset.zero & size),
    );

    // Subtle grid.
    _paintGrid(canvas, size);

    // Terminal "window" card.
    final cardRect = RRect.fromRectAndRadius(
      Rect.fromCenter(
        center: Offset(w / 2, h * 0.52),
        width: w * 0.82,
        height: h * 0.70,
      ),
      const Radius.circular(12),
    );
    canvas
      ..drawRRect(
        cardRect,
        Paint()..color = AppColors.ink.withValues(alpha: 0.85),
      )
      ..drawRRect(
        cardRect,
        Paint()
          ..color = AppColors.primary.withValues(alpha: 0.45)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1.5,
      );

    // Traffic-light dots.
    final dotY = h * 0.52 - h * 0.35 + 16;
    final dotColors = [
      AppColors.errorRed,
      AppColors.goldKey,
      AppColors.successGreen,
    ];
    for (var i = 0; i < 3; i++) {
      canvas.drawCircle(
        Offset(w * 0.24 + i * 18, dotY),
        5,
        Paint()..color = dotColors[i],
      );
    }

    // Code lines.
    final lineColors = [
      AppColors.accentLime,
      AppColors.ctaGradient[0],
      AppColors.ctaGradient[2].withValues(alpha: 0.9),
      AppColors.white.withValues(alpha: 0.5),
      AppColors.accentLime.withValues(alpha: 0.7),
    ];
    final lineWidths = [0.55, 0.72, 0.48, 0.62, 0.38];
    for (var i = 0; i < 5; i++) {
      final y = h * 0.52 - h * 0.35 + 44 + i * (h * 0.085);
      canvas.drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromLTWH(w * 0.19, y, w * lineWidths[i] * 0.70, h * 0.048),
          const Radius.circular(3),
        ),
        Paint()..color = lineColors[i % lineColors.length],
      );
    }

    // ">" prompt glyph.
    _drawText(
      canvas,
      '>',
      Offset(w * 0.145, h * 0.52 - h * 0.35 + 38),
      AppColors.accentLime,
      w * 0.085,
      FontWeight.w700,
    );
  }

  void _paintGrid(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = AppColors.primary.withValues(alpha: 0.07)
      ..strokeWidth = 0.8;
    const step = 20.0;
    for (var x = 0.0; x < size.width; x += step) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), paint);
    }
    for (var y = 0.0; y < size.height; y += step) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), paint);
    }
  }

  // ── Shared helpers ───────────────────────────────────────────────────────

  void _paintDots(Canvas canvas, Size size, Color color) {
    final rng = math.Random(42); // seeded → deterministic layout
    for (var i = 0; i < 18; i++) {
      canvas.drawCircle(
        Offset(rng.nextDouble() * size.width, rng.nextDouble() * size.height),
        rng.nextDouble() * 3 + 1.5,
        Paint()..color = color,
      );
    }
  }

  void _arrowHead(Canvas canvas, Offset tip, double angle, Color color) {
    final p = Paint()
      ..color = color
      ..strokeWidth = 1.8
      ..strokeCap = StrokeCap.round;
    const len = 7.0;
    final a1 = angle + math.pi * 0.8;
    final a2 = angle - math.pi * 0.8;
    canvas
      ..drawLine(
        tip,
        Offset(tip.dx + len * math.cos(a1), tip.dy + len * math.sin(a1)),
        p,
      )
      ..drawLine(
        tip,
        Offset(tip.dx + len * math.cos(a2), tip.dy + len * math.sin(a2)),
        p,
      );
  }

  void _drawText(
    Canvas canvas,
    String text,
    Offset offset,
    Color color,
    double fontSize,
    FontWeight weight,
  ) {
    TextPainter(
        textDirection: TextDirection.ltr,
        text: TextSpan(
          text: text,
          style: TextStyle(
            fontSize: fontSize,
            color: color,
            fontWeight: weight,
            fontFamily: 'Onest',
          ),
        ),
      )
      ..layout()
      ..paint(canvas, offset);
  }

  @override
  bool shouldRepaint(_TopicPainter old) => old.variant != variant;
}
