import 'dart:math' as math;

import 'package:admity/core/theme/app_colors.dart';
import 'package:flutter/material.dart';

// TODO(mascot): Replace this geometric placeholder with the real mascot
// asset when the designer delivers it.  Search for "MascotSlot" to find
// every placement in the app.

/// Placeholder widget for the Admity mascot figure.
///
/// Renders a soft geometric blob (pentagon-like shape) in [AppColors.mascotGreen]
/// as a visual stand-in.  When the real mascot is ready, swap the
/// [CustomPainter] internals — the API ([size], [tag]) stays the same.
///
/// [tag] is used to label the placeholder so designers/devs can identify
/// the placement context in screenshots.
class MascotSlot extends StatelessWidget {
  const MascotSlot({
    super.key,
    this.size = 120,
    this.tag,
  });

  /// Bounding box dimension (width = height = [size]).
  final double size;

  /// Optional context label shown under the blob (e.g. "home" / "lesson").
  final String? tag;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        SizedBox.square(
          dimension: size,
          child: CustomPaint(
            painter: _BlobPainter(size: size),
          ),
        ),
        if (tag != null) ...[
          const SizedBox(height: 4),
          Text(
            tag!,
            style: const TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w500,
              color: AppColors.inkSecondary,
            ),
          ),
        ],
      ],
    );
  }
}

/// Draws a soft five-sided blob in [AppColors.mascotGreen].
class _BlobPainter extends CustomPainter {
  const _BlobPainter({required this.size});

  final double size;

  @override
  void paint(Canvas canvas, Size canvasSize) {
    final cx = canvasSize.width / 2;
    final cy = canvasSize.height / 2;
    final r = size * 0.38;

    // Build a 5-pointed "squircle blob" by interleaving outer and inner radii.
    final path = Path();
    const sides = 5;
    const innerRatio = 0.72; // softness factor (>0.5 = round, <0.5 = spiky)

    for (var i = 0; i < sides * 2; i++) {
      final angle = (math.pi * i / sides) - math.pi / 2;
      final radius = i.isEven ? r : r * innerRatio;
      final x = cx + radius * math.cos(angle);
      final y = cy + radius * math.sin(angle);
      if (i == 0) {
        path.moveTo(x, y);
      } else {
        path.lineTo(x, y);
      }
    }
    path.close();

    canvas
      // Soft shadow
      ..drawShadow(path, AppColors.mascotGreen.withValues(alpha: 0.35), 8, false)
      // Fill
      ..drawPath(path, Paint()..color = AppColors.mascotGreen)
      // Small neutral dot in centre
      ..drawCircle(
        Offset(cx, cy),
        size * 0.07,
        Paint()..color = AppColors.white.withValues(alpha: 0.7),
      );
  }

  @override
  bool shouldRepaint(_BlobPainter oldDelegate) => oldDelegate.size != size;
}
