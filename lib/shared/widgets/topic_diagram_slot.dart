import 'dart:math' as math;

import 'package:admity/core/theme/app_colors.dart';
import 'package:flutter/material.dart';

// TODO(3d): Replace this geometric placeholder with the real 3D isometric
// diagram when the designer delivers the assets.  Search for "TopicDiagramSlot"
// to find every placement in the app.

/// Placeholder widget for the per-topic 3D diagram (§6, §7.3).
///
/// Renders a rounded square with a [AppColors.primary] → [AppColors.navyDeep]
/// gradient and a simple isometric cube/sphere sketch inside.
///
/// [size] controls the bounding box; [label] is displayed below.
class TopicDiagramSlot extends StatelessWidget {
  const TopicDiagramSlot({
    super.key,
    this.size = 120,
    this.label,
  });

  final double size;
  final String? label;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: size,
          height: size,
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [AppColors.primary, AppColors.navyDeep],
            ),
            borderRadius: BorderRadius.circular(size * 0.2),
            boxShadow: [
              BoxShadow(
                color: AppColors.primary.withValues(alpha: 0.3),
                blurRadius: 16,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: CustomPaint(
            painter: _IsoCubePainter(size: size),
          ),
        ),
        if (label != null) ...[
          const SizedBox(height: 6),
          Text(
            label!,
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: AppColors.inkSecondary,
            ),
          ),
        ],
      ],
    );
  }
}

/// Draws a simple isometric cube outline in white on the gradient background.
class _IsoCubePainter extends CustomPainter {
  const _IsoCubePainter({required this.size});

  final double size;

  @override
  void paint(Canvas canvas, Size canvasSize) {
    final w = canvasSize.width;
    final h = canvasSize.height;
    final cx = w / 2;
    final cy = h / 2;
    final s = size * 0.28; // half-edge length

    final paint = Paint()
      ..color = AppColors.white.withValues(alpha: 0.85)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.8
      ..strokeJoin = StrokeJoin.round;

    final fillTop = Paint()
      ..color = AppColors.white.withValues(alpha: 0.18)
      ..style = PaintingStyle.fill;

    final fillLeft = Paint()
      ..color = AppColors.white.withValues(alpha: 0.08)
      ..style = PaintingStyle.fill;

    final fillRight = Paint()
      ..color = AppColors.white.withValues(alpha: 0.04)
      ..style = PaintingStyle.fill;

    // Isometric cube vertices (simplified flat projection)
    // Top face — diamond
    final top = Offset(cx, cy - s * 1.0);
    final right = Offset(cx + s * math.cos(math.pi / 6) * 1.6, cy);
    final bottom = Offset(cx, cy + s * 1.0);
    final left = Offset(cx - s * math.cos(math.pi / 6) * 1.6, cy);
    final topRight = Offset(right.dx, right.dy - s * 1.0);
    final topLeft = Offset(left.dx, left.dy - s * 1.0);
    final bottomRight = Offset(right.dx, right.dy + s * 0.6);
    final bottomLeft = Offset(left.dx, left.dy + s * 0.6);

    // Top face
    final topPath = Path()
      ..moveTo(top.dx, top.dy)
      ..lineTo(topRight.dx, topRight.dy)
      ..lineTo(right.dx, right.dy)
      ..lineTo(left.dx, left.dy)
      ..lineTo(topLeft.dx, topLeft.dy)
      ..lineTo(top.dx, top.dy)
      ..close();

    // Right face
    final rightPath = Path()
      ..moveTo(right.dx, right.dy)
      ..lineTo(topRight.dx, topRight.dy)
      ..lineTo(bottomRight.dx, bottomRight.dy)
      ..lineTo(bottom.dx, bottom.dy)
      ..close();

    // Left face
    final leftPath = Path()
      ..moveTo(left.dx, left.dy)
      ..lineTo(right.dx, right.dy)
      ..lineTo(bottom.dx, bottom.dy)
      ..lineTo(bottomLeft.dx, bottomLeft.dy)
      ..lineTo(topLeft.dx, topLeft.dy)
      ..close();

    canvas
      ..drawPath(topPath, fillTop)
      ..drawPath(rightPath, fillRight)
      ..drawPath(leftPath, fillLeft)
      ..drawPath(topPath, paint)
      ..drawPath(rightPath, paint)
      ..drawPath(leftPath, paint)
      // Small sphere hint
      ..drawCircle(
        Offset(cx, cy - s * 0.1),
        s * 0.22,
        Paint()..color = AppColors.white.withValues(alpha: 0.25),
      );
  }

  @override
  bool shouldRepaint(_IsoCubePainter oldDelegate) => oldDelegate.size != size;
}
