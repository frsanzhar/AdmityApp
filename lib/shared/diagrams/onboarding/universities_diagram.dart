import 'dart:async';
import 'dart:math' as math;

import 'package:admity/core/theme/app_colors.dart';
import 'package:flutter/material.dart';

/// Abstract "world-class / built with top institutions" visual for onboarding.
///
/// Original art — no real logos or wordmarks. Renders a stylized orbital
/// ring system: a glowing hub surrounded by three concentric elliptical
/// rings, each carrying a small colored "satellite" badge.
///
/// Badges pulse with a staggered entry animation. The widget respects
/// `MediaQuery.disableAnimations`.
///
/// Usage:
/// ```dart
/// UniversitiesDiagram()           // defaults — auto-animates
/// UniversitiesDiagram(loop: false) // play once, stay revealed
/// ```
class UniversitiesDiagram extends StatefulWidget {
  const UniversitiesDiagram({
    super.key,
    this.loop = true,
  });

  /// When true the satellite orbit animation loops continuously.
  final bool loop;

  @override
  State<UniversitiesDiagram> createState() => _UniversitiesDiagramState();
}

class _UniversitiesDiagramState extends State<UniversitiesDiagram>
    with TickerProviderStateMixin {
  late AnimationController _orbitCtrl;
  late AnimationController _entryCtrl;

  @override
  void initState() {
    super.initState();
    _orbitCtrl = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 12),
    );
    _entryCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1400),
    );

    WidgetsBinding.instance.addPostFrameCallback((_) {
      final disableAnim =
          MediaQuery.maybeOf(context)?.disableAnimations ?? false;
      if (disableAnim) {
        _entryCtrl.value = 1.0;
        _orbitCtrl.value = 0.0;
      } else {
        unawaited(_entryCtrl.forward());
        if (widget.loop) {
          unawaited(_orbitCtrl.repeat());
        } else {
          unawaited(_orbitCtrl.forward());
        }
      }
    });
  }

  @override
  void dispose() {
    _orbitCtrl.dispose();
    _entryCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: Listenable.merge([_orbitCtrl, _entryCtrl]),
      builder: (context, _) => CustomPaint(
        painter: _UniversitiesPainter(
          orbitT: _orbitCtrl.value,
          entryProgress: CurvedAnimation(
            parent: _entryCtrl,
            curve: Curves.easeOutBack,
          ).value,
        ),
        size: Size.infinite,
      ),
    );
  }
}

// Satellite specification: ring index (0–2), color, label glyph chars,
// angle offset within ring.
class _Satellite {
  const _Satellite({
    required this.ring,
    required this.color,
    required this.glyphs,
    required this.phaseOffset,
  });
  final int ring;
  final Color color;
  final String glyphs; // decorative short label (original, not real logos)
  final double phaseOffset; // 0-1 around the ring
}

final List<_Satellite> _satellites = [
  // Ring 0 — innermost
  const _Satellite(
    ring: 0,
    color: AppColors.primary,
    glyphs: 'Σ',
    phaseOffset: 0,
  ),
  const _Satellite(
    ring: 0,
    color: AppColors.accentLime,
    glyphs: '∇',
    phaseOffset: 0.5,
  ),
  // Ring 1
  const _Satellite(
    ring: 1,
    color: AppColors.goldKey,
    glyphs: '⬡',
    phaseOffset: 0,
  ),
  _Satellite(
    ring: 1,
    color: AppColors.ctaGradient[1],
    glyphs: 'Δ',
    phaseOffset: 0.33,
  ),
  const _Satellite(
    ring: 1,
    color: AppColors.successGreen,
    glyphs: 'π',
    phaseOffset: 0.66,
  ),
  // Ring 2 — outermost
  _Satellite(
    ring: 2,
    color: AppColors.ctaGradient[2],
    glyphs: '∞',
    phaseOffset: 0,
  ),
  const _Satellite(
    ring: 2,
    color: AppColors.errorRed,
    glyphs: '✦',
    phaseOffset: 0.28,
  ),
  _Satellite(
    ring: 2,
    color: AppColors.ctaGradient[3],
    glyphs: 'λ',
    phaseOffset: 0.56,
  ),
  _Satellite(
    ring: 2,
    color: AppColors.navyDeep.withValues(alpha: 0.7),
    glyphs: 'Ω',
    phaseOffset: 0.82,
  ),
];

class _UniversitiesPainter extends CustomPainter {
  _UniversitiesPainter({
    required this.orbitT,
    required this.entryProgress,
  });

  final double orbitT; // 0-1 looping orbit phase
  final double entryProgress; // 0-1 reveal

  // Ring semi-axes as fractions of canvas size
  static const List<_RingSpec> _rings = [
    _RingSpec(rxFrac: 0.20, ryFrac: 0.09, tiltRad: 0.30, speed: 1),
    _RingSpec(rxFrac: 0.35, ryFrac: 0.15, tiltRad: -0.20, speed: 0.65),
    _RingSpec(rxFrac: 0.46, ryFrac: 0.20, tiltRad: 0.10, speed: 0.40),
  ];

  @override
  void paint(Canvas canvas, Size size) {
    final cx = size.width * 0.5;
    final cy = size.height * 0.52;
    final center = Offset(cx, cy);

    // Hub glow
    final hubGlowPaint = Paint()
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 28)
      ..color = AppColors.primary.withValues(alpha: 0.22 * entryProgress);
    canvas.drawCircle(center, 36, hubGlowPaint);

    // Hub rings (decorative concentric static circles)
    for (var i = 0; i < 3; i++) {
      canvas.drawCircle(
        center,
        (14 + i * 8).toDouble(),
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1.0
          ..color = AppColors.primary.withValues(
            alpha: (0.18 + i * 0.07) * entryProgress,
          ),
      );
    }

    // Hub fill
    canvas.drawCircle(
      center,
      14,
      Paint()
        ..shader = const RadialGradient(
          colors: [
            AppColors.primary,
            AppColors.navyDeep,
          ],
        ).createShader(Rect.fromCircle(center: center, radius: 14))
        ..color = AppColors.primary,
    );
    // Hub star
    canvas.drawCircle(
      center,
      4.5,
      Paint()..color = AppColors.white.withValues(alpha: 0.9),
    );

    // Draw elliptical rings & satellites
    for (var ri = 0; ri < _rings.length; ri++) {
      final spec = _rings[ri];
      final rx = spec.rxFrac * size.width;
      final ry = spec.ryFrac * size.height;

      // Ring ellipse
      final ringPaint = Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.0
        ..color = AppColors.border.withValues(alpha: 0.55 * entryProgress);

      canvas.save();
      canvas.translate(cx, cy);
      canvas.rotate(spec.tiltRad);
      canvas.drawOval(
        Rect.fromCenter(center: Offset.zero, width: rx * 2, height: ry * 2),
        ringPaint,
      );
      canvas.restore();

      // Satellites on this ring
      final ringSatellites = _satellites.where((s) => s.ring == ri).toList();
      for (var si = 0; si < ringSatellites.length; si++) {
        final sat = ringSatellites[si];
        // Stagger entry per satellite
        final stagger = (ri * 3 + si) * 0.07;
        final satEntry = ((entryProgress - stagger) / (1.0 - stagger)).clamp(
          0.0,
          1.0,
        );
        if (satEntry <= 0) continue;

        // Orbit angle
        final angle = (sat.phaseOffset + orbitT * spec.speed) * 2 * math.pi;
        // Ellipse position + tilt
        final rawX = math.cos(angle) * rx;
        final rawY = math.sin(angle) * ry;
        // Apply tilt rotation
        final cosT = math.cos(spec.tiltRad);
        final sinT = math.sin(spec.tiltRad);
        final satPos = Offset(
          cx + rawX * cosT - rawY * sinT,
          cy + rawX * sinT + rawY * cosT,
        );

        _drawSatellite(
          canvas,
          satPos,
          sat.color,
          sat.glyphs,
          satEntry,
        );
      }
    }
  }

  void _drawSatellite(
    Canvas canvas,
    Offset pos,
    Color color,
    String glyph,
    double alpha,
  ) {
    const r = 13.0;

    // Glow
    canvas.drawCircle(
      pos,
      r * 1.6,
      Paint()
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 8)
        ..color = color.withValues(alpha: 0.28 * alpha),
    );

    // Badge circle
    canvas.drawCircle(
      pos,
      r * alpha,
      Paint()..color = color.withValues(alpha: alpha),
    );
    canvas.drawCircle(
      pos,
      r * alpha,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.2
        ..color = AppColors.white.withValues(alpha: 0.35 * alpha),
    );

    // Glyph text
    final tp = TextPainter(
      text: TextSpan(
        text: glyph,
        style: TextStyle(
          fontSize: 9,
          color: AppColors.white.withValues(alpha: alpha),
          fontWeight: FontWeight.w700,
        ),
      ),
      textDirection: TextDirection.ltr,
    )..layout();
    tp.paint(
      canvas,
      pos - Offset(tp.width / 2, tp.height / 2),
    );
  }

  @override
  bool shouldRepaint(_UniversitiesPainter old) =>
      old.orbitT != orbitT || old.entryProgress != entryProgress;
}

class _RingSpec {
  const _RingSpec({
    required this.rxFrac,
    required this.ryFrac,
    required this.tiltRad,
    required this.speed,
  });
  final double rxFrac;
  final double ryFrac;
  final double tiltRad;
  final double speed; // relative orbit speed multiplier
}
