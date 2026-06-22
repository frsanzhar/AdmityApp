import 'dart:math' as math;

import 'package:admity/core/theme/app_colors.dart';
import 'package:flutter/material.dart';

/// Circular progress ring (0.0 → 1.0) using [CustomPainter].
///
/// Matches the "82%" progress ring style in the Brilliant references.
///
/// ## Animation (non-breaking addition)
/// The arc sweeps from the previous value to the new one using an implicit
/// [TweenAnimationBuilder].  When `MediaQuery.disableAnimations` is true the
/// value is applied instantly (no tween).
///
/// All existing constructor parameters are unchanged.
class ProgressRing extends StatelessWidget {
  const ProgressRing({
    required this.progress,
    super.key,
    this.size = 80,
    this.strokeWidth = 8,
    this.progressColor,
    this.trackColor,
    this.child,
  });

  /// Value between 0.0 and 1.0.
  final double progress;
  final double size;
  final double strokeWidth;
  final Color? progressColor;
  final Color? trackColor;

  /// Optional widget drawn in the centre of the ring (e.g. a percentage label).
  final Widget? child;

  @override
  Widget build(BuildContext context) {
    final effectiveProgress = progress.clamp(0.0, 1.0);
    final disableAnim = MediaQuery.of(context).disableAnimations;

    final effectiveProgressColor = progressColor ?? AppColors.primary;
    final effectiveTrackColor = trackColor ?? AppColors.border;

    if (disableAnim) {
      // Static path — no animation overhead.
      return SizedBox.square(
        dimension: size,
        child: CustomPaint(
          painter: _RingPainter(
            progress: effectiveProgress,
            strokeWidth: strokeWidth,
            progressColor: effectiveProgressColor,
            trackColor: effectiveTrackColor,
          ),
          child: child != null ? Center(child: child) : null,
        ),
      );
    }

    return TweenAnimationBuilder<double>(
      tween: Tween<double>(begin: 0, end: effectiveProgress),
      duration: const Duration(milliseconds: 700),
      curve: Curves.easeOutCubic,
      builder: (context, animatedProgress, innerChild) {
        return SizedBox.square(
          dimension: size,
          child: CustomPaint(
            painter: _RingPainter(
              progress: animatedProgress,
              strokeWidth: strokeWidth,
              progressColor: effectiveProgressColor,
              trackColor: effectiveTrackColor,
            ),
            child: innerChild,
          ),
        );
      },
      child: child != null ? Center(child: child) : null,
    );
  }
}

class _RingPainter extends CustomPainter {
  const _RingPainter({
    required this.progress,
    required this.strokeWidth,
    required this.progressColor,
    required this.trackColor,
  });

  final double progress;
  final double strokeWidth;
  final Color progressColor;
  final Color trackColor;

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = (size.width - strokeWidth) / 2;
    const startAngle = -math.pi / 2; // 12 o'clock

    // Track
    canvas.drawCircle(
      center,
      radius,
      Paint()
        ..color = trackColor
        ..style = PaintingStyle.stroke
        ..strokeWidth = strokeWidth
        ..strokeCap = StrokeCap.round,
    );

    // Progress arc
    if (progress > 0) {
      canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius),
        startAngle,
        2 * math.pi * progress,
        false,
        Paint()
          ..color = progressColor
          ..style = PaintingStyle.stroke
          ..strokeWidth = strokeWidth
          ..strokeCap = StrokeCap.round,
      );
    }
  }

  @override
  bool shouldRepaint(_RingPainter oldDelegate) =>
      oldDelegate.progress != progress ||
      oldDelegate.progressColor != progressColor ||
      oldDelegate.trackColor != trackColor ||
      oldDelegate.strokeWidth != strokeWidth;
}
