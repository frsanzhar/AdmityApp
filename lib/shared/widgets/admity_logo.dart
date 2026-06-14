import 'package:admity/core/theme/app_colors.dart';
import 'package:flutter/material.dart';

/// The Admity brand mark — the Eraly steppe-bird on a terracotta tile.
///
/// A crisp, resolution-independent vector version of `assets/brand/admity_icon.png`,
/// so it scales perfectly inside the launch animation and anywhere in-app. Pure
/// painting (no images, no Rive dependency), so it can animate freely.
class AdmityLogo extends StatelessWidget {
  /// Creates the Admity logo mark at [size] logical pixels.
  const AdmityLogo({this.size = 120, this.tile = true, super.key});

  /// Edge length of the square mark.
  final double size;

  /// Whether to draw the rounded terracotta tile behind the mascot. When
  /// `false`, only the steppe-bird mascot is painted (transparent background).
  final bool tile;

  @override
  Widget build(BuildContext context) {
    return SizedBox.square(
      dimension: size,
      child: CustomPaint(painter: _AdmityLogoPainter(tile: tile)),
    );
  }
}

class _AdmityLogoPainter extends CustomPainter {
  _AdmityLogoPainter({required this.tile});

  final bool tile;

  @override
  void paint(Canvas canvas, Size size) {
    final s = size.width;
    final cx = s / 2;
    final cy = s / 2;

    // Terracotta rounded tile.
    if (tile) {
      final tileRect = RRect.fromRectAndRadius(
        Rect.fromLTWH(0, 0, s, s),
        Radius.circular(s * 0.225),
      );
      canvas.drawRRect(tileRect, Paint()..color = AppColors.terracotta);
    }

    final w = s * (tile ? 0.64 : 1.0);
    final br = w * 0.34;

    // Crest — steppe-bird feather rising from the head.
    final crest = Path()
      ..moveTo(cx, cy - br * 1.55)
      ..lineTo(cx + w * 0.16, cy - br * 0.78)
      ..lineTo(cx - w * 0.02, cy - br * 0.55)
      ..lineTo(cx - w * 0.13, cy - br * 0.86)
      ..close();
    canvas.drawPath(crest, Paint()..color = AppColors.terracottaDark);

    // Body / face — warm cream rounded shield.
    final bodyRect = RRect.fromRectAndRadius(
      Rect.fromLTRB(
        cx - br,
        cy - br * 0.92,
        cx + br,
        cy + br * 1.08,
      ),
      Radius.circular(br * 0.9),
    );
    canvas.drawRRect(bodyRect, Paint()..color = AppColors.cream);

    // Eyes.
    final eye = Paint()..color = AppColors.inkLight;
    final eyeR = w * 0.038;
    for (final dx in [-0.105, 0.105]) {
      canvas.drawCircle(Offset(cx + w * dx, cy - br * 0.02), eyeR, eye);
    }

    // Smile.
    final smile = Paint()
      ..color = AppColors.terracotta
      ..style = PaintingStyle.stroke
      ..strokeWidth = w * 0.028
      ..strokeCap = StrokeCap.round;
    final mw = w * 0.17;
    final my = cy + br * 0.42;
    canvas.drawArc(
      Rect.fromCircle(center: Offset(cx, my), radius: mw),
      0.35,
      2.44,
      false,
      smile,
    );
  }

  @override
  bool shouldRepaint(_AdmityLogoPainter oldDelegate) => oldDelegate.tile != tile;
}
