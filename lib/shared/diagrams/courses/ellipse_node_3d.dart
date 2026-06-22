import 'dart:math' as math;

import 'package:admity/core/theme/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

/// The visual state of an [EllipseNode3D] on the lesson path.
enum EllipseNodeState {
  /// Not yet unlocked — greyed platform, lock icon.
  locked,

  /// Currently active — cobalt platform, animated ring + float glow.
  active,

  /// Completed — filled gradient platform, white check.
  done,
}

/// A lesson-path node rendered as a **3D-perspective elliptical disc/platform**,
/// matching the Brilliant zigzag node-path aesthetic.
///
/// The disc is drawn with a top face (lighter) and a side extrusion (darker),
/// giving genuine depth without any 3-D engine.  The active state adds a
/// concentric glow ring and, when `MediaQuery.disableAnimations` is false,
/// a gentle floating animation (translateY + scale breathing).
///
/// ## Params
/// - [state]  — [EllipseNodeState.locked] / [EllipseNodeState.active] / [EllipseNodeState.done].
/// - [size]   — diameter of the conceptual bounding circle (default 72).
/// - [onTap]  — ignored when [state] is [EllipseNodeState.locked].
///
/// ## Color contract
/// Uses only [AppColors] constants + `AppColors.ctaGradient` + opacity.
/// `Colors.transparent` is used for inner glow halos.
class EllipseNode3D extends StatelessWidget {
  const EllipseNode3D({
    required this.state,
    super.key,
    this.size = 72,
    this.onTap,
  });

  final EllipseNodeState state;
  final double size;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final reduce = MediaQuery.of(context).disableAnimations;

    Widget node = GestureDetector(
      onTap: state == EllipseNodeState.locked ? null : onTap,
      child: SizedBox(
        width: size * 1.4,
        height: size * 1.1,
        child: CustomPaint(
          painter: _EllipseNode3DPainter(state: state, size: size),
        ),
      ),
    );

    if (state == EllipseNodeState.active && !reduce) {
      // Float: subtle vertical bob.
      node = node
          .animate(onPlay: (c) => c.repeat(reverse: true))
          .moveY(
            begin: 0,
            end: -6,
            duration: const Duration(milliseconds: 1400),
            curve: Curves.easeInOut,
          )
          .scale(
            begin: const Offset(1, 1),
            end: const Offset(1.03, 1.03),
            duration: const Duration(milliseconds: 1400),
            curve: Curves.easeInOut,
          );
    }

    return node;
  }
}

// ─── Painter ────────────────────────────────────────────────────────────────

class _EllipseNode3DPainter extends CustomPainter {
  const _EllipseNode3DPainter({required this.state, required this.size});

  final EllipseNodeState state;
  final double size;

  @override
  void paint(Canvas canvas, Size canvasSize) {
    final cx = canvasSize.width / 2;
    // Place the disc in the upper 70 % so the extrusion has room below.
    final cy = canvasSize.height * 0.42;

    final rx = size * 0.68; // horizontal radius
    final ry = size * 0.28; // vertical radius (perspective foreshortening)
    final depth = size * 0.18; // extrusion height

    // ── colour recipe ───────────────────────────────────────────────────────
    final (topLight, topDark, sideLight, sideDark, iconColor) = switch (state) {
      EllipseNodeState.locked => (
        const Color(0xFFD8DCE8), // light grey top
        const Color(0xFFB4BAC8), // mid grey top gradient end
        const Color(0xFF9EA4B4), // side lighter
        const Color(0xFF787E90), // side darker
        AppColors.inkSecondary,
      ),
      EllipseNodeState.active => (
        AppColors.primary, // cobalt top light
        AppColors.primaryDark, // cobalt top dark
        AppColors.navyDeep.withValues(alpha: 0.85), // navy side light
        AppColors.navyDeep, // navy side dark
        AppColors.white,
      ),
      EllipseNodeState.done => (
        AppColors.ctaGradient[0], // blue-purple top light
        AppColors.ctaGradient[1], // purple top dark
        AppColors.ctaGradient[2].withValues(alpha: 0.85), // pink side
        AppColors.navyDeep, // deep side bottom
        AppColors.white,
      ),
    };

    // ── 1. glow ring (active only) ───────────────────────────────────────
    if (state == EllipseNodeState.active) {
      _paintGlowRings(canvas, cx, cy, rx, ry);
    }

    // ── 2. side extrusion ───────────────────────────────────────────────
    _paintSide(canvas, cx, cy, rx, ry, depth, sideLight, sideDark);

    // ── 3. top face ─────────────────────────────────────────────────────
    _paintTopFace(canvas, cx, cy, rx, ry, topLight, topDark);

    // ── 4. top-face specular highlight ──────────────────────────────────
    _paintSpecular(canvas, cx, cy, rx, ry);

    // ── 5. icon ─────────────────────────────────────────────────────────
    _paintIcon(canvas, cx, cy, iconColor);
  }

  void _paintGlowRings(
    Canvas canvas,
    double cx,
    double cy,
    double rx,
    double ry,
  ) {
    // Three concentric halos, outermost first.
    for (var i = 3; i >= 1; i--) {
      final f = 1 + i * 0.18;
      final paint = Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2.5 - i * 0.5
        ..color = AppColors.primary.withValues(alpha: 0.12 * i);
      canvas.drawOval(
        Rect.fromCenter(
          center: Offset(cx, cy),
          width: rx * 2 * f,
          height: ry * 2 * f,
        ),
        paint,
      );
    }
    // Inner solid ring.
    final ringPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.8
      ..color = AppColors.primary.withValues(alpha: 0.55);
    canvas.drawOval(
      Rect.fromCenter(
        center: Offset(cx, cy),
        width: rx * 2 * 1.12,
        height: ry * 2 * 1.12,
      ),
      ringPaint,
    );
  }

  void _paintSide(
    Canvas canvas,
    double cx,
    double cy,
    double rx,
    double ry,
    double depth,
    Color sideLight,
    Color sideDark,
  ) {
    // The side is the area between the top-face ellipse and a copy
    // shifted down by [depth].  We draw it as a closed path.
    final sidePaint = Paint()
      ..shader =
          LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [sideLight, sideDark],
          ).createShader(
            Rect.fromCenter(
              center: Offset(cx, cy + depth / 2),
              width: rx * 2,
              height: depth + ry,
            ),
          );

    final path = Path()
      ..moveTo(cx - rx, cy) // left edge of top ellipse
      ..lineTo(cx - rx, cy + depth) // left edge of bottom ellipse
      ..arcTo(
        Rect.fromCenter(
          center: Offset(cx, cy + depth),
          width: rx * 2,
          height: ry * 2,
        ),
        math.pi, // start at left
        math.pi, // sweep to right (bottom arc)
        false,
      )
      ..lineTo(cx + rx, cy) // right edge of top ellipse
      ..arcTo(
        Rect.fromCenter(center: Offset(cx, cy), width: rx * 2, height: ry * 2),
        0, // start at right
        math.pi, // sweep to left (top arc, reverse)
        false,
      )
      ..close();

    canvas.drawPath(path, sidePaint);
  }

  void _paintTopFace(
    Canvas canvas,
    double cx,
    double cy,
    double rx,
    double ry,
    Color light,
    Color dark,
  ) {
    final rect = Rect.fromCenter(
      center: Offset(cx, cy),
      width: rx * 2,
      height: ry * 2,
    );

    // Radial gradient: lighter at top-left (light source), darker at bottom-right.
    final paint = Paint()
      ..shader = RadialGradient(
        center: const Alignment(-0.35, -0.45),
        radius: 0.9,
        colors: [light, dark],
      ).createShader(rect);

    canvas.drawOval(rect, paint);
  }

  void _paintSpecular(
    Canvas canvas,
    double cx,
    double cy,
    double rx,
    double ry,
  ) {
    // Small bright oval at top-left to simulate light bounce.
    final specRect = Rect.fromCenter(
      center: Offset(cx - rx * 0.28, cy - ry * 0.3),
      width: rx * 0.55,
      height: ry * 0.38,
    );
    final paint = Paint()
      ..shader = RadialGradient(
        colors: [
          AppColors.white.withValues(alpha: 0.45),
          Colors.transparent,
        ],
      ).createShader(specRect);
    canvas.drawOval(specRect, paint);
  }

  void _paintIcon(Canvas canvas, double cx, double cy, Color color) {
    final iconSize = size * 0.30;
    final iconData = switch (state) {
      EllipseNodeState.locked => Icons.lock_rounded,
      EllipseNodeState.active => Icons.play_arrow_rounded,
      EllipseNodeState.done => Icons.check_rounded,
    };

    // Draw icon via TextPainter with the Material Icons font.
    final tp = TextPainter(
      textDirection: TextDirection.ltr,
      text: TextSpan(
        text: String.fromCharCode(iconData.codePoint),
        style: TextStyle(
          fontSize: iconSize,
          color: color,
          fontFamily: iconData.fontFamily,
          package: iconData.fontPackage,
        ),
      ),
    )..layout();

    tp.paint(
      canvas,
      Offset(cx - tp.width / 2, cy - tp.height / 2),
    );
  }

  @override
  bool shouldRepaint(_EllipseNode3DPainter old) =>
      old.state != state || old.size != size;
}
