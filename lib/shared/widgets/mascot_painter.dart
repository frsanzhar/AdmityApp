import 'dart:math' as math;

import 'package:admity/core/theme/app_colors.dart';
import 'package:flutter/material.dart';

// TODO(mascot): Replace BlobMascotPainter with the final designer asset once
// delivered. Search "MascotSlot" to find every placement in the app.

/// Mood enum driving expression / pose differences in [BlobMascotPainter].
///
/// Pass via `MascotSlot.mood` (optional, defaults to [MascotMood.idle]).
///
/// | Value       | Visual change                                                |
/// |-------------|-------------------------------------------------------------|
/// | idle        | Neutral half-smile, arms gently at sides                    |
/// | happy       | Wide smile, rosy cheeks, arms slightly raised               |
/// | celebrate   | Big grin, arms raised in "yay" pose, rosy cheeks            |
/// | think       | One hand raised to chin, thoughtful smirk                   |
enum MascotMood {
  /// Default resting expression — neutral half-smile.
  idle,

  /// Happy face — wide smile, soft rose cheeks.
  happy,

  /// Celebration — big grin, arms raised, rosy cheeks.
  celebrate,

  /// Thinking — one hand to chin, slight smirk.
  think,
}

/// Custom painter that draws the Admity green blob mascot character.
///
/// The mascot is a soft rounded blob/diamond body in [AppColors.mascotGreen]
/// with a radial gradient for depth, expressive eyes, and arms whose poses
/// vary by [MascotMood].
///
/// Animation is driven externally by passing animated values:
/// - [blinkT]   0 = eye open, 1 = fully closed (driven by an AnimationController).
/// - [glanceX]  -1..+1 pupil horizontal offset fraction (driven externally).
/// - [armWave]  0..1 arm oscillation phase (driven by AnimationController).
/// - [breathT]  0..1 subtle vertical scale for breathing (driven externally).
///
/// All coordinates are expressed as fractions of [size] for resolution
/// independence.
///
/// ### Design tokens used
/// - Body fill gradient: [AppColors.mascotGreen] (center) → darker shade
/// - Eyes: [AppColors.ink] pupils on [AppColors.white] sclera
/// - Cheek blush: [AppColors.errorRed] at low opacity (permitted by §8)
/// - Shadow: [AppColors.cardShadow]
/// - Highlight: [AppColors.white] at reduced opacity
class BlobMascotPainter extends CustomPainter {
  const BlobMascotPainter({
    required this.size,
    this.mood = MascotMood.idle,
    this.blinkT = 0.0,
    this.glanceX = 0.0,
    this.armWave = 0.0,
    this.breathT = 0.0,
  });

  final double size;
  final MascotMood mood;

  /// 0 = eyes fully open, 1 = eyes fully closed.
  final double blinkT;

  /// Pupil horizontal offset, -1 (left) to +1 (right).
  final double glanceX;

  /// Arm oscillation phase 0..1 (used for subtle idle wave).
  final double armWave;

  /// Breathing offset 0..1 (adds tiny vertical translate to body).
  final double breathT;

  // ── Shared paints ────────────────────────────────────────────────────────────

  Paint get _inkFill => Paint()
    ..color = AppColors.ink
    ..style = PaintingStyle.fill;

  Paint get _white => Paint()
    ..color = AppColors.white
    ..style = PaintingStyle.fill;

  Paint get _blush => Paint()
    ..color = AppColors.errorRed.withValues(alpha: 0.18)
    ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 5);

  Paint get _shadowPaint => Paint()
    ..color = AppColors.cardShadow
    ..maskFilter = MaskFilter.blur(BlurStyle.normal, size * 0.07);

  // ── Entry point ──────────────────────────────────────────────────────────────

  @override
  void paint(Canvas canvas, Size canvasSize) {
    final s = size;
    final cx = canvasSize.width / 2;
    // Breathing: shift centre up by breathT * small amount
    final breathShift = breathT * s * 0.012;
    final cy = canvasSize.height / 2 - breathShift;

    canvas.save();

    _drawShadow(canvas, cx, cy, s);
    _drawBody(canvas, cx, cy, s);
    _drawArms(canvas, cx, cy, s);
    _drawFace(canvas, cx, cy, s);

    if (mood == MascotMood.happy || mood == MascotMood.celebrate) {
      _drawCheeks(canvas, cx, cy, s);
    }

    canvas.restore();
  }

  // ── Shadow ───────────────────────────────────────────────────────────────────

  void _drawShadow(Canvas canvas, double cx, double cy, double s) {
    canvas.drawOval(
      Rect.fromCenter(
        center: Offset(cx, cy + s * 0.46),
        width: s * 0.52,
        height: s * 0.10,
      ),
      _shadowPaint,
    );
  }

  // ── Body — soft rounded blob ──────────────────────────────────────────────────

  void _drawBody(Canvas canvas, double cx, double cy, double s) {
    // The blob is a superellipse-like shape: start with a rounded rect that is
    // taller than wide and use a large corner radius for that "melted diamond"
    // soft look described in §6 ("мягкий ромб/блоб").
    final bodyW = s * 0.68;
    final bodyH = s * 0.80;
    final bodyRect = Rect.fromCenter(
      center: Offset(cx, cy + s * 0.04),
      width: bodyW,
      height: bodyH,
    );
    final bodyRR = RRect.fromRectAndRadius(bodyRect, Radius.circular(s * 0.30));

    // Radial gradient: light mascotGreen centre → deeper green edge.
    final bodyGradientPaint = Paint()
      ..shader = RadialGradient(
        center: const Alignment(-0.25, -0.35),
        radius: 0.72,
        colors: [
          AppColors.mascotGreen.withValues(alpha: 1),
          Color.lerp(AppColors.mascotGreen, AppColors.ink, 0.22)!,
        ],
      ).createShader(bodyRect);

    canvas.drawRRect(bodyRR, bodyGradientPaint);

    // Soft specular highlight — top-left inner glow.
    final highlightPaint = Paint()
      ..color = AppColors.white.withValues(alpha: 0.22)
      ..maskFilter = MaskFilter.blur(BlurStyle.normal, s * 0.06);
    canvas.drawOval(
      Rect.fromCenter(
        center: Offset(cx - s * 0.10, cy - s * 0.14),
        width: s * 0.28,
        height: s * 0.20,
      ),
      highlightPaint,
    );
  }

  // ── Arms / hands ─────────────────────────────────────────────────────────────

  void _drawArms(Canvas canvas, double cx, double cy, double s) {
    // Wave oscillation: ±armWave * small angle offset for idle breathing feel.
    // For idle: arms gently sway. For celebrate: arms up. Etc.
    final waveOffset = math.sin(armWave * math.pi * 2) * 0.06;

    double leftAngle;
    double rightAngle;

    switch (mood) {
      case MascotMood.celebrate:
        // Arms raised in a "yay" pose, with a little wave oscillation.
        leftAngle = -math.pi * 0.62 + waveOffset;
        rightAngle = -math.pi * 0.38 - waveOffset;
      case MascotMood.happy:
        // Arms slightly raised, happy bounce.
        leftAngle = math.pi * 0.60 + waveOffset * 0.5;
        rightAngle = math.pi * 0.40 - waveOffset * 0.5;
      case MascotMood.think:
        // Left arm down, right arm angled up toward chin.
        leftAngle = math.pi * 0.52;
        rightAngle = -math.pi * 0.12 + waveOffset * 0.3;
      case MascotMood.idle:
        // Gentle idle sway.
        leftAngle = math.pi * 0.52 + waveOffset * 0.4;
        rightAngle = math.pi * 0.48 - waveOffset * 0.4;
    }

    _drawArm(canvas, cx, cy, s, side: -1, angle: leftAngle);
    _drawArm(canvas, cx, cy, s, side: 1, angle: rightAngle);

    // For think mood, draw a small hand near the chin.
    if (mood == MascotMood.think) {
      _drawThinkHand(canvas, cx, cy, s);
    }
  }

  void _drawArm(
    Canvas canvas,
    double cx,
    double cy,
    double s, {
    required int side,
    required double angle,
  }) {
    final armLength = s * 0.20;
    final armW = s * 0.11;

    // Root: side of the blob body, roughly mid-height.
    final rootX = cx + side * s * 0.29;
    final rootY = cy + s * 0.10;

    final tipX = rootX + math.cos(angle) * armLength;
    final tipY = rootY + math.sin(angle) * armLength;

    // Arm fill: slightly lighter than the body green for depth.
    final armFill = Paint()
      ..color = Color.lerp(AppColors.mascotGreen, AppColors.white, 0.12)!;

    final armOutline = Paint()
      ..color = Color.lerp(AppColors.mascotGreen, AppColors.ink, 0.30)!
      ..style = PaintingStyle.stroke
      ..strokeWidth = s * 0.018
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    final path = Path();
    final perp = Offset(-math.sin(angle), math.cos(angle)) * (armW / 2);

    path
      ..moveTo(rootX + perp.dx, rootY + perp.dy)
      ..lineTo(tipX + perp.dx, tipY + perp.dy)
      ..arcToPoint(
        Offset(tipX - perp.dx, tipY - perp.dy),
        radius: Radius.circular(armW / 2),
      )
      ..lineTo(rootX - perp.dx, rootY - perp.dy)
      ..arcToPoint(
        Offset(rootX + perp.dx, rootY + perp.dy),
        radius: Radius.circular(armW / 2),
      )
      ..close();

    canvas
      ..drawPath(path, armFill)
      ..drawPath(path, armOutline);

    // Rounded hand at tip.
    final handR = armW * 0.52;
    canvas
      ..drawCircle(Offset(tipX, tipY), handR, armFill)
      ..drawCircle(Offset(tipX, tipY), handR, armOutline);
  }

  void _drawThinkHand(Canvas canvas, double cx, double cy, double s) {
    final chinX = cx + s * 0.14;
    final chinY = cy - s * 0.06;
    final handR = s * 0.065;

    final armFill = Paint()
      ..color = Color.lerp(AppColors.mascotGreen, AppColors.white, 0.12)!;
    final armOutline = Paint()
      ..color = Color.lerp(AppColors.mascotGreen, AppColors.ink, 0.30)!
      ..style = PaintingStyle.stroke
      ..strokeWidth = s * 0.018
      ..strokeCap = StrokeCap.round;

    // Stub arm from body to hand.
    final armPath = Path();
    final rootX = cx + s * 0.28;
    final rootY = cy + s * 0.08;
    armPath
      ..moveTo(rootX, rootY)
      ..quadraticBezierTo(
        rootX - s * 0.08,
        rootY - s * 0.06,
        chinX + handR * 0.6,
        chinY,
      );

    // Wide stroke for fill, narrower for outline.
    canvas
      ..drawPath(
        armPath,
        Paint()
          ..color = Color.lerp(AppColors.mascotGreen, AppColors.white, 0.12)!
          ..style = PaintingStyle.stroke
          ..strokeWidth = s * 0.10
          ..strokeCap = StrokeCap.round,
      )
      ..drawPath(armPath, armOutline)
      ..drawCircle(Offset(chinX, chinY), handR, armFill)
      ..drawCircle(Offset(chinX, chinY), handR, armOutline);
  }

  // ── Face ─────────────────────────────────────────────────────────────────────

  void _drawFace(Canvas canvas, double cx, double cy, double s) {
    // Face sits in upper-centre of the blob body.
    final faceCx = cx;
    final faceCy = cy - s * 0.10;

    _drawEyes(canvas, faceCx, faceCy, s);
    _drawMouth(canvas, faceCx, faceCy, s);
  }

  // ── Eyes ─────────────────────────────────────────────────────────────────────

  void _drawEyes(Canvas canvas, double cx, double cy, double s) {
    final eyeOffsetX = s * 0.105;

    final leftCenter = Offset(cx - eyeOffsetX, cy);
    final rightCenter = Offset(cx + eyeOffsetX, cy);

    for (final ec in [leftCenter, rightCenter]) {
      _drawSingleEye(canvas, ec, s);
    }
  }

  void _drawSingleEye(Canvas canvas, Offset center, double s) {
    final scleraR = s * 0.072;
    // blinkT = 0 → full open; 1 → closed (scale y to ~0).
    final scaleY = 1.0 - blinkT * 0.92;

    // Scale vertically around the eye centre to simulate a blink.
    canvas
      ..save()
      ..translate(center.dx, center.dy)
      ..scale(1, scaleY)
      ..translate(-center.dx, -center.dy)
      // Sclera (white of the eye).
      ..drawCircle(center, scleraR, _white);

    // Iris — slightly smaller, dark green-ish tint (using ink at opacity).
    final irisR = scleraR * 0.62;
    // Pupil — solid ink.
    final pupilR = irisR * 0.58;
    // Glance: shift pupil horizontally by glanceX * fraction of sclera radius.
    final maxGlance = (scleraR - pupilR) * 0.55;
    final pupilCenter = center.translate(glanceX * maxGlance, 0);

    canvas
      ..drawCircle(
        center,
        irisR,
        Paint()
          ..color = Color.lerp(AppColors.mascotGreen, AppColors.ink, 0.70)!,
      )
      ..drawCircle(pupilCenter, pupilR, _inkFill)
      // Specular highlight.
      ..drawCircle(
        pupilCenter.translate(-pupilR * 0.28, -pupilR * 0.32),
        pupilR * 0.38,
        Paint()..color = AppColors.white.withValues(alpha: 0.85),
      )
      ..restore();

    // Eyelid curve for happy/celebrate (drawn outside the scaled block so it
    // stays positioned correctly).
    if (!_isBlinking &&
        (mood == MascotMood.happy || mood == MascotMood.celebrate)) {
      _drawHappyLid(canvas, center, scleraR, s);
    }
  }

  bool get _isBlinking => blinkT > 0.5;

  void _drawHappyLid(
    Canvas canvas,
    Offset center,
    double scleraR,
    double s,
  ) {
    final lidPaint = Paint()
      ..color = Color.lerp(AppColors.mascotGreen, AppColors.ink, 0.18)!
      ..style = PaintingStyle.stroke
      ..strokeWidth = s * 0.018
      ..strokeCap = StrokeCap.round;

    final path = Path()
      ..moveTo(center.dx - scleraR * 1.05, center.dy - scleraR * 0.15)
      ..quadraticBezierTo(
        center.dx,
        center.dy - scleraR * 1.05,
        center.dx + scleraR * 1.05,
        center.dy - scleraR * 0.15,
      );
    canvas.drawPath(path, lidPaint);
  }

  // ── Mouth ────────────────────────────────────────────────────────────────────

  void _drawMouth(Canvas canvas, double cx, double cy, double s) {
    final mouthY = cy + s * 0.115;
    final mouthHalfW = s * 0.080;

    final strokePaint = Paint()
      ..color = Color.lerp(AppColors.mascotGreen, AppColors.ink, 0.55)!
      ..style = PaintingStyle.stroke
      ..strokeWidth = s * 0.022
      ..strokeCap = StrokeCap.round;

    final path = Path();

    switch (mood) {
      case MascotMood.idle:
        path
          ..moveTo(cx - mouthHalfW, mouthY)
          ..quadraticBezierTo(cx, mouthY + s * 0.048, cx + mouthHalfW, mouthY);

      case MascotMood.happy:
        final w = mouthHalfW * 1.35;
        path
          ..moveTo(cx - w, mouthY - s * 0.006)
          ..quadraticBezierTo(
            cx,
            mouthY + s * 0.065,
            cx + w,
            mouthY - s * 0.006,
          );

      case MascotMood.celebrate:
        final w = mouthHalfW * 1.55;
        final top = mouthY - s * 0.008;
        final bottom = mouthY + s * 0.080;
        // Filled open-mouth grin.
        final fillPath = Path()
          ..moveTo(cx - w, top)
          ..quadraticBezierTo(cx, bottom + s * 0.018, cx + w, top)
          ..lineTo(cx - w, top)
          ..close();
        canvas.drawPath(
          fillPath,
          Paint()
            ..color = Color.lerp(
              AppColors.mascotGreen,
              AppColors.ink,
              0.25,
            )!.withValues(alpha: 0.45),
        );
        path
          ..moveTo(cx - w, top)
          ..quadraticBezierTo(cx, bottom + s * 0.018, cx + w, top);

      case MascotMood.think:
        final shift = mouthHalfW * 0.28;
        path
          ..moveTo(cx - mouthHalfW + shift, mouthY)
          ..quadraticBezierTo(
            cx + shift,
            mouthY + s * 0.036,
            cx + mouthHalfW + shift,
            mouthY,
          );
    }

    canvas.drawPath(path, strokePaint);
  }

  // ── Cheeks ───────────────────────────────────────────────────────────────────

  void _drawCheeks(Canvas canvas, double cx, double cy, double s) {
    final cheekY = cy + s * 0.090;
    final cheekOffsetX = s * 0.155;
    final cheekR = s * 0.062;

    for (final side in [-1, 1]) {
      canvas.drawCircle(
        Offset(cx + side * cheekOffsetX, cheekY),
        cheekR,
        _blush,
      );
    }
  }

  // ── Repaint logic ────────────────────────────────────────────────────────────

  @override
  bool shouldRepaint(BlobMascotPainter oldDelegate) {
    return oldDelegate.size != size ||
        oldDelegate.mood != mood ||
        oldDelegate.blinkT != blinkT ||
        oldDelegate.glanceX != glanceX ||
        oldDelegate.armWave != armWave ||
        oldDelegate.breathT != breathT;
  }
}
