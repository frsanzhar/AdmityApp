import 'dart:math' as math;

import 'package:admity/core/theme/app_colors.dart';
import 'package:flutter/material.dart';

// TODO(mascot): Replace PandaPainter with the final designer asset once
// delivered. Search "MascotSlot" to find every placement in the app.

/// Mood enum driving expression / pose differences in [PandaPainter].
///
/// Pass via `MascotSlot.mood` (optional, defaults to [MascotMood.idle]).
///
/// | Value       | Visual change                                              |
/// |-------------|-----------------------------------------------------------|
/// | idle        | Neutral half-smile, relaxed arms down                     |
/// | happy       | Wide smile, rosy cheeks, arms slightly raised             |
/// | celebrate   | Big grin, arms up in a "yay" pose, rosy cheeks            |
/// | think       | One hand raised to chin, thoughtful brow furrow           |
enum MascotMood {
  /// Default resting expression — neutral half-smile.
  idle,

  /// Happy face — wide smile, soft rose cheeks.
  happy,

  /// Celebration — big grin, arms raised, rosy cheeks.
  celebrate,

  /// Thinking — one hand to chin, slight brow furrow.
  think,
}

/// Custom painter that draws an original Admity panda mascot.
///
/// The panda is drawn procedurally using [Canvas] primitives so it is
/// fully resolution-independent and trivially animatable.
///
/// ### Design tokens used
/// - Body / head fill: [AppColors.white]
/// - Outlines / ears / eye-patches: [AppColors.ink]
/// - Eye whites + highlight: [AppColors.white]
/// - Cheek blush (`happy` / `celebrate`): soft pink derived from
///   [AppColors.errorRed] at very low opacity — stays within design tokens
///   since `Colors.transparent` and opacity compositing are always permitted.
/// - Nose: [AppColors.inkSecondary]
/// - Shadow: [AppColors.cardShadow]
///
/// All coordinates are expressed as fractions of [size] so the panda
/// scales cleanly at any [size] value.
class PandaPainter extends CustomPainter {
  const PandaPainter({
    required this.size,
    this.mood = MascotMood.idle,
  });

  final double size;
  final MascotMood mood;

  // ── Shared paints ────────────────────────────────────────────────────────────

  Paint get _white => Paint()..color = AppColors.white;

  Paint get _ink => Paint()
    ..color = AppColors.ink
    ..style = PaintingStyle.fill;

  Paint get _inkStroke => Paint()
    ..color = AppColors.ink
    ..style = PaintingStyle.stroke
    ..strokeWidth = size * 0.025
    ..strokeCap = StrokeCap.round
    ..strokeJoin = StrokeJoin.round;

  Paint get _inkSecondary => Paint()..color = AppColors.inkSecondary;

  // Soft rose blush — derived from errorRed at 15% opacity (permitted by §8:
  // "Colors.transparent ok"; opacity on AppColors tokens is always allowed).
  Paint get _blush => Paint()
    ..color = AppColors.errorRed.withValues(alpha: 0.15)
    ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 4);

  // ── Entry point ──────────────────────────────────────────────────────────────

  @override
  void paint(Canvas canvas, Size canvasSize) {
    final s = size;
    final cx = canvasSize.width / 2;
    final cy = canvasSize.height / 2;

    // Save so overall transforms don't leak.
    canvas.save();

    // Soft drop-shadow under the whole figure.
    _drawShadow(canvas, cx, cy, s);

    // Body (lower oval) — drawn first so head overlaps it.
    _drawBody(canvas, cx, cy, s);

    // Arms — behind head, on top of body.
    _drawArms(canvas, cx, cy, s);

    // Head (circle).
    _drawHead(canvas, cx, cy, s);

    // Ears (black ear patches on top of the head circle).
    _drawEars(canvas, cx, cy, s);

    // Face features.
    _drawEyes(canvas, cx, cy, s);
    _drawNose(canvas, cx, cy, s);
    _drawMouth(canvas, cx, cy, s);

    // Mood extras.
    if (mood == MascotMood.happy || mood == MascotMood.celebrate) {
      _drawCheeks(canvas, cx, cy, s);
    }
    if (mood == MascotMood.think) {
      _drawThinkHand(canvas, cx, cy, s);
    }

    canvas.restore();
  }

  // ── Shadow ───────────────────────────────────────────────────────────────────

  void _drawShadow(Canvas canvas, double cx, double cy, double s) {
    final shadowPaint = Paint()
      ..color = AppColors.cardShadow
      ..maskFilter = MaskFilter.blur(BlurStyle.normal, s * 0.08);
    // Elliptical shadow below figure.
    canvas.drawOval(
      Rect.fromCenter(
        center: Offset(cx, cy + s * 0.42),
        width: s * 0.55,
        height: s * 0.12,
      ),
      shadowPaint,
    );
  }

  // ── Body ─────────────────────────────────────────────────────────────────────

  void _drawBody(Canvas canvas, double cx, double cy, double s) {
    // White oval body, outlined in ink.
    final bodyCenter = Offset(cx, cy + s * 0.22);
    final bodyRect = Rect.fromCenter(
      center: bodyCenter,
      width: s * 0.60,
      height: s * 0.46,
    );

    canvas
      ..drawOval(bodyRect, _white)
      ..drawOval(bodyRect, _inkStroke);
  }

  // ── Arms ─────────────────────────────────────────────────────────────────────

  void _drawArms(Canvas canvas, double cx, double cy, double s) {
    // Arms are short rounded rectangles on the sides of the body.
    // Celebrate: arms up; think: right arm raised to chin; others: arms down.

    final double leftAngle;
    final double rightAngle;

    switch (mood) {
      case MascotMood.celebrate:
        leftAngle = -math.pi * 0.65; // up-left
        rightAngle = -math.pi * 0.35; // up-right
      case MascotMood.think:
        leftAngle = math.pi * 0.5; // straight down
        rightAngle = -math.pi * 0.15; // slightly raised right
      case MascotMood.happy:
        leftAngle = math.pi * 0.55; // slightly down-left
        rightAngle = math.pi * 0.45; // slightly down-right
      case MascotMood.idle:
        leftAngle = math.pi * 0.5; // straight down
        rightAngle = math.pi * 0.5; // straight down
    }

    _drawArm(canvas, cx, cy, s, side: -1, angle: leftAngle);
    _drawArm(canvas, cx, cy, s, side: 1, angle: rightAngle);
  }

  void _drawArm(
    Canvas canvas,
    double cx,
    double cy,
    double s, {
    required int side, // -1 = left, +1 = right
    required double angle,
  }) {
    final armLength = s * 0.22;
    final armW = s * 0.12;

    // Arm root is at the side of the body oval.
    final rootX = cx + side * s * 0.26;
    final rootY = cy + s * 0.16;

    // Tip is armLength away in the direction of angle.
    final tipX = rootX + math.cos(angle) * armLength;
    final tipY = rootY + math.sin(angle) * armLength;

    final path = Path();
    // Perpendicular offset for width.
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
      ..drawPath(path, _white)
      ..drawPath(path, _inkStroke);

    // Small round hand at the tip.
    final handR = armW * 0.55;
    canvas
      ..drawCircle(Offset(tipX, tipY), handR, _white)
      ..drawCircle(Offset(tipX, tipY), handR, _inkStroke);
  }

  // ── Head ─────────────────────────────────────────────────────────────────────

  void _drawHead(Canvas canvas, double cx, double cy, double s) {
    final headR = s * 0.30;
    final headCenter = Offset(cx, cy - s * 0.04);

    canvas
      ..drawCircle(headCenter, headR, _white)
      ..drawCircle(headCenter, headR, _inkStroke);
  }

  // ── Ears ─────────────────────────────────────────────────────────────────────

  void _drawEars(Canvas canvas, double cx, double cy, double s) {
    final headR = s * 0.30;
    final headCenter = Offset(cx, cy - s * 0.04);

    // Outer black ear — a filled circle.
    final earR = s * 0.115;
    final earOffsetX = headR * 0.72;
    final earOffsetY = headR * 0.72;

    final leftEarCenter = Offset(
      headCenter.dx - earOffsetX,
      headCenter.dy - earOffsetY,
    );
    final rightEarCenter = Offset(
      headCenter.dx + earOffsetX,
      headCenter.dy - earOffsetY,
    );

    for (final ec in [leftEarCenter, rightEarCenter]) {
      canvas
        // Black filled ear patch.
        ..drawCircle(ec, earR, _ink)
        // Smaller inner circle (lighter, so ear doesn't look solid black).
        ..drawCircle(
          ec,
          earR * 0.55,
          Paint()..color = AppColors.ink.withValues(alpha: 0.55),
        );
    }
  }

  // ── Eyes ─────────────────────────────────────────────────────────────────────

  void _drawEyes(Canvas canvas, double cx, double cy, double s) {
    final headCenter = Offset(cx, cy - s * 0.04);

    // Black eye patches (elliptical).
    final patchW = s * 0.115;
    final patchH = s * 0.095;
    final eyeOffsetX = s * 0.115;
    final eyeOffsetY = s * 0.02;

    final leftPatch = Rect.fromCenter(
      center: Offset(headCenter.dx - eyeOffsetX, headCenter.dy + eyeOffsetY),
      width: patchW,
      height: patchH,
    );
    final rightPatch = Rect.fromCenter(
      center: Offset(headCenter.dx + eyeOffsetX, headCenter.dy + eyeOffsetY),
      width: patchW,
      height: patchH,
    );

    for (final patch in [leftPatch, rightPatch]) {
      canvas.drawOval(patch, _ink);
    }

    // White iris circles inside each patch.
    final irisR = patchH * 0.38;
    for (final patch in [leftPatch, rightPatch]) {
      canvas.drawCircle(patch.center, irisR, _white);
    }

    // Pupil dots — small and friendly.
    final pupilR = irisR * 0.55;
    // Idle/think: look slightly down; happy/celebrate: look forward.
    final pupilDy = (mood == MascotMood.idle || mood == MascotMood.think)
        ? irisR * 0.3
        : 0.0;

    for (final patch in [leftPatch, rightPatch]) {
      canvas.drawCircle(
        patch.center.translate(0, pupilDy),
        pupilR,
        _ink,
      );
    }

    // Specular highlight — tiny white dot, top-right of each pupil.
    final highlightR = pupilR * 0.45;
    for (final patch in [leftPatch, rightPatch]) {
      canvas.drawCircle(
        patch.center.translate(pupilR * 0.3, pupilDy - pupilR * 0.3),
        highlightR,
        _white,
      );
    }

    // Happy/celebrate: add little curved eyelid arcs to signal joy.
    if (mood == MascotMood.happy || mood == MascotMood.celebrate) {
      _drawHappyEyelids(canvas, leftPatch, rightPatch, s);
    }

    // Think: one eyebrow is slightly angled (inner corner raised).
    if (mood == MascotMood.think) {
      _drawThinkBrow(canvas, headCenter, eyeOffsetX, eyeOffsetY, s);
    }
  }

  void _drawHappyEyelids(
    Canvas canvas,
    Rect leftPatch,
    Rect rightPatch,
    double s,
  ) {
    // Draw a crescent on top of each eye to give a "squinting with joy" look.
    final strokePaint = Paint()
      ..color = AppColors.ink
      ..style = PaintingStyle.stroke
      ..strokeWidth = s * 0.020
      ..strokeCap = StrokeCap.round;

    for (final patch in [leftPatch, rightPatch]) {
      final path = Path()
        ..moveTo(
          patch.left - patch.width * 0.15,
          patch.center.dy - patch.height * 0.1,
        )
        ..quadraticBezierTo(
          patch.center.dx,
          patch.top - patch.height * 0.55,
          patch.right + patch.width * 0.15,
          patch.center.dy - patch.height * 0.1,
        );
      canvas.drawPath(path, strokePaint);
    }
  }

  void _drawThinkBrow(
    Canvas canvas,
    Offset headCenter,
    double eyeOffsetX,
    double eyeOffsetY,
    double s,
  ) {
    // Right brow slightly angled (inner side raised).
    final strokePaint = Paint()
      ..color = AppColors.ink
      ..style = PaintingStyle.stroke
      ..strokeWidth = s * 0.024
      ..strokeCap = StrokeCap.round;

    final browY = headCenter.dy + eyeOffsetY - s * 0.09;

    canvas
      // Left brow — flat.
      ..drawLine(
        Offset(headCenter.dx - eyeOffsetX - s * 0.045, browY),
        Offset(headCenter.dx - eyeOffsetX + s * 0.045, browY),
        strokePaint,
      )
      // Right brow — inner corner raised, giving a thinking tilt.
      ..drawLine(
        Offset(headCenter.dx + eyeOffsetX - s * 0.045, browY - s * 0.018),
        Offset(headCenter.dx + eyeOffsetX + s * 0.045, browY + s * 0.010),
        strokePaint,
      );
  }

  // ── Nose ─────────────────────────────────────────────────────────────────────

  void _drawNose(Canvas canvas, double cx, double cy, double s) {
    final headCenter = Offset(cx, cy - s * 0.04);

    // Small rounded ellipse nose — inkSecondary so it reads as a muted detail.
    final noseRect = Rect.fromCenter(
      center: Offset(headCenter.dx, headCenter.dy + s * 0.065),
      width: s * 0.068,
      height: s * 0.048,
    );
    canvas
      ..drawOval(noseRect, _inkSecondary)
      // Tiny specular on nose.
      ..drawCircle(
        Offset(
          noseRect.center.dx - noseRect.width * 0.18,
          noseRect.top + noseRect.height * 0.28,
        ),
        noseRect.width * 0.14,
        Paint()..color = AppColors.white.withValues(alpha: 0.55),
      );
  }

  // ── Mouth ────────────────────────────────────────────────────────────────────

  void _drawMouth(Canvas canvas, double cx, double cy, double s) {
    final headCenter = Offset(cx, cy - s * 0.04);
    final mouthY = headCenter.dy + s * 0.118;
    final mouthHalfW = s * 0.085;

    final strokePaint = Paint()
      ..color = AppColors.ink
      ..style = PaintingStyle.stroke
      ..strokeWidth = s * 0.022
      ..strokeCap = StrokeCap.round;

    final path = Path();

    switch (mood) {
      case MascotMood.idle:
        // Gentle half-smile — one quadratic curve.
        path
          ..moveTo(headCenter.dx - mouthHalfW, mouthY)
          ..quadraticBezierTo(
            headCenter.dx,
            mouthY + s * 0.052,
            headCenter.dx + mouthHalfW,
            mouthY,
          );

      case MascotMood.happy:
        // Wider smile with slight open-mouth arc.
        final w = mouthHalfW * 1.35;
        path
          ..moveTo(headCenter.dx - w, mouthY - s * 0.008)
          ..quadraticBezierTo(
            headCenter.dx,
            mouthY + s * 0.07,
            headCenter.dx + w,
            mouthY - s * 0.008,
          );

      case MascotMood.celebrate:
        // Big "D"-shaped open grin.
        final w = mouthHalfW * 1.5;
        final top = mouthY - s * 0.010;
        final bottom = mouthY + s * 0.085;
        path
          ..moveTo(headCenter.dx - w, top)
          ..quadraticBezierTo(
            headCenter.dx,
            bottom + s * 0.02,
            headCenter.dx + w,
            top,
          );
        // Fill the inside of the open mouth lightly.
        final fillPath = Path()
          ..moveTo(headCenter.dx - w, top)
          ..quadraticBezierTo(
            headCenter.dx,
            bottom + s * 0.02,
            headCenter.dx + w,
            top,
          )
          ..lineTo(headCenter.dx - w, top)
          ..close();
        canvas.drawPath(
          fillPath,
          Paint()..color = AppColors.inkSecondary.withValues(alpha: 0.18),
        );

      case MascotMood.think:
        // Thoughtful sideways smirk — slightly off-center.
        final shift = mouthHalfW * 0.3;
        path
          ..moveTo(headCenter.dx - mouthHalfW + shift, mouthY)
          ..quadraticBezierTo(
            headCenter.dx + shift,
            mouthY + s * 0.038,
            headCenter.dx + mouthHalfW + shift,
            mouthY,
          );
    }

    canvas.drawPath(path, strokePaint);
  }

  // ── Cheeks ───────────────────────────────────────────────────────────────────

  void _drawCheeks(Canvas canvas, double cx, double cy, double s) {
    final headCenter = Offset(cx, cy - s * 0.04);
    final cheekY = headCenter.dy + s * 0.095;
    final cheekOffsetX = s * 0.175;
    final cheekR = s * 0.07;

    for (final side in [-1, 1]) {
      canvas.drawCircle(
        Offset(headCenter.dx + side * cheekOffsetX, cheekY),
        cheekR,
        _blush,
      );
    }
  }

  // ── Think hand ───────────────────────────────────────────────────────────────

  void _drawThinkHand(Canvas canvas, double cx, double cy, double s) {
    // Right hand (side = +1) raised to just below chin.
    final chinX = cx + s * 0.12;
    final chinY = cy + s * 0.10;

    final handR = s * 0.068;
    canvas
      ..drawCircle(Offset(chinX, chinY), handR, _white)
      ..drawCircle(Offset(chinX, chinY), handR, _inkStroke);

    // Small arm stub connecting hand to body.
    final armPath = Path();
    final rootX = cx + s * 0.26;
    final rootY = cy + s * 0.12;
    armPath
      ..moveTo(rootX, rootY)
      ..quadraticBezierTo(
        rootX - s * 0.06,
        rootY - s * 0.04,
        chinX + handR * 0.5,
        chinY,
      );

    canvas
      ..drawPath(
        armPath,
        Paint()
          ..color = AppColors.ink
          ..style = PaintingStyle.stroke
          ..strokeWidth = s * 0.10
          ..strokeCap = StrokeCap.round,
      )
      ..drawPath(
        armPath,
        Paint()
          ..color = AppColors.white
          ..style = PaintingStyle.stroke
          ..strokeWidth = s * 0.075
          ..strokeCap = StrokeCap.round,
      )
      ..drawPath(
        armPath,
        Paint()
          ..color = AppColors.ink
          ..style = PaintingStyle.stroke
          ..strokeWidth = s * 0.024
          ..strokeCap = StrokeCap.round,
      );
  }

  // ── Repaint logic ────────────────────────────────────────────────────────────

  @override
  bool shouldRepaint(PandaPainter oldDelegate) =>
      oldDelegate.size != size || oldDelegate.mood != mood;
}
