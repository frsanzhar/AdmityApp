import 'dart:math' as math;

import 'package:admity/core/theme/app_colors.dart';
import 'package:flutter/material.dart';

/// A circular progress indicator with a label in the middle — used for
/// intensive day-progress and score completeness.
class ProgressRing extends StatelessWidget {
  const ProgressRing({
    required this.progress,
    this.size = 88,
    this.strokeWidth = 9,
    this.color = AppColors.terracotta,
    this.label,
    this.sublabel,
    super.key,
  }) : assert(progress >= 0 && progress <= 1, 'progress must be 0..1');

  final double progress;
  final double size;
  final double strokeWidth;
  final Color color;
  final String? label;
  final String? sublabel;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: CustomPaint(
        painter: _RingPainter(
          progress: progress,
          color: color,
          track: Theme.of(context).colorScheme.outlineVariant,
          strokeWidth: strokeWidth,
        ),
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (label != null)
                Text(label!, style: Theme.of(context).textTheme.titleMedium),
              if (sublabel != null)
                Text(
                  sublabel!,
                  style: Theme.of(context).textTheme.labelSmall,
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class _RingPainter extends CustomPainter {
  _RingPainter({
    required this.progress,
    required this.color,
    required this.track,
    required this.strokeWidth,
  });

  final double progress;
  final Color color;
  final Color track;
  final double strokeWidth;

  @override
  void paint(Canvas canvas, Size size) {
    final center = size.center(Offset.zero);
    final radius = (size.width - strokeWidth) / 2;
    final trackPaint = Paint()
      ..color = track
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth;
    final progressPaint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeWidth = strokeWidth;

    canvas
      ..drawCircle(center, radius, trackPaint)
      ..drawArc(
        Rect.fromCircle(center: center, radius: radius),
        -math.pi / 2,
        2 * math.pi * progress,
        false,
        progressPaint,
      );
  }

  @override
  bool shouldRepaint(_RingPainter old) =>
      old.progress != progress || old.color != color;
}
