import 'package:admity/core/theme/app_colors.dart';
import 'package:admity/core/theme/app_durations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

/// The emotional states Eraly can display. These map 1:1 to the Rive state
/// machine inputs that replace this placeholder once the `.riv` asset ships.
enum EralyState {
  /// Calm, attentive default.
  idle,

  /// Streak closed / goal reached.
  celebrate,

  /// Rubric check failed / a setback — warm encouragement.
  encourage,

  /// Working / waiting on a sub-agent.
  thinking,
}

/// Placeholder mascot for Eraly with the same public API the Rive widget will
/// expose (`EralyAvatar(state: ...)`), so feature code never changes when the
/// real `.riv` lands. Custom-painted — intentionally not an emoji or Material
/// icon — so it reads as a brand character.
class EralyAvatar extends StatelessWidget {
  const EralyAvatar({
    this.state = EralyState.idle,
    this.size = 72,
    super.key,
  });

  final EralyState state;
  final double size;

  @override
  Widget build(BuildContext context) {
    final avatar = CustomPaint(
      size: Size.square(size),
      painter: _EralyPainter(state),
    );

    return switch (state) {
      EralyState.celebrate => avatar
          .animate(onPlay: (c) => c.repeat(reverse: true))
          .moveY(begin: 0, end: -6, duration: AppDurations.medium)
          .then()
          .shake(hz: 3, rotation: 0.04),
      EralyState.thinking => avatar
          .animate(onPlay: (c) => c.repeat(reverse: true))
          .fadeIn()
          .moveY(begin: 0, end: -2, duration: AppDurations.slow),
      EralyState.encourage =>
        avatar.animate().scale(begin: const Offset(0.96, 0.96)),
      EralyState.idle => avatar,
    };
  }
}

class _EralyPainter extends CustomPainter {
  _EralyPainter(this.state);

  final EralyState state;

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;
    final c = Offset(w / 2, h / 2);

    // Body — a warm rounded shield/feather shape.
    final body = Paint()..color = AppColors.terracotta;
    final bodyRect = RRect.fromRectAndRadius(
      Rect.fromCircle(center: c, radius: w * 0.46),
      Radius.circular(w * 0.42),
    );
    canvas.drawRRect(bodyRect, body);

    // Crest accent (steppe-bird feather) on top.
    final crest = Paint()..color = AppColors.terracottaDark;
    final crestPath = Path()
      ..moveTo(c.dx, h * 0.06)
      ..quadraticBezierTo(w * 0.72, h * 0.12, c.dx + w * 0.04, h * 0.3)
      ..quadraticBezierTo(w * 0.5, h * 0.16, c.dx, h * 0.06)
      ..close();
    canvas.drawPath(crestPath, crest);

    // Face plate.
    final face = Paint()..color = AppColors.cream;
    canvas.drawCircle(Offset(c.dx, c.dy + h * 0.04), w * 0.3, face);

    // Eyes.
    final eye = Paint()..color = AppColors.inkLight;
    final eyeDy = c.dy + h * (state == EralyState.thinking ? 0.0 : 0.02);
    final eyeR = w * 0.045;
    if (state == EralyState.celebrate) {
      // Happy arcs.
      final arc = Paint()
        ..color = AppColors.inkLight
        ..style = PaintingStyle.stroke
        ..strokeWidth = w * 0.03
        ..strokeCap = StrokeCap.round;
      for (final dx in [-0.11, 0.11]) {
        final rect = Rect.fromCircle(
          center: Offset(c.dx + w * dx, eyeDy),
          radius: w * 0.05,
        );
        canvas.drawArc(rect, 3.6, 1.9, false, arc);
      }
    } else {
      canvas
        ..drawCircle(Offset(c.dx - w * 0.11, eyeDy), eyeR, eye)
        ..drawCircle(Offset(c.dx + w * 0.11, eyeDy), eyeR, eye);
    }

    // Mouth — expression by state.
    final mouth = Paint()
      ..color = AppColors.terracottaDark
      ..style = PaintingStyle.stroke
      ..strokeWidth = w * 0.03
      ..strokeCap = StrokeCap.round;
    final mouthRect = Rect.fromCircle(
      center: Offset(c.dx, c.dy + h * 0.13),
      radius: w * 0.09,
    );
    switch (state) {
      case EralyState.celebrate:
        canvas.drawArc(mouthRect, 0.2, 2.7, false, mouth);
      case EralyState.idle:
      case EralyState.thinking:
        canvas.drawArc(mouthRect, 0.5, 2.1, false, mouth);
      case EralyState.encourage:
        // Gentle, supportive small smile.
        canvas.drawArc(mouthRect, 0.7, 1.7, false, mouth);
    }
  }

  @override
  bool shouldRepaint(_EralyPainter oldDelegate) => oldDelegate.state != state;
}
