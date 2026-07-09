import 'dart:async';
import 'dart:math' as math;

import 'package:admity/shared/widgets/mascot_painter.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

/// Admity mascot — a friendly green "sprout buddy" drawn and animated in pure
/// Flutter (no Rive dependency). Gentle float + breathing, periodic blink, and
/// a mood-driven smile.
///
/// The public API ([size], [tag], [state], [mood], [flyIn]) is unchanged so all
/// existing callers keep working. When `MediaQuery.disableAnimations` is true it
/// renders a calm static pose.
class MascotSlot extends StatelessWidget {
  /// Creates a mascot of [size]×[size] logical pixels.
  const MascotSlot({
    super.key,
    this.size = 120,
    this.tag,
    this.state = MascotState.idle,
    this.mood = MascotMood.idle,
    this.flyIn = false,
  });

  /// Diameter of the mascot (width = height = [size]).
  final double size;

  /// Optional context label rendered under the mascot.
  final String? tag;

  /// Retained for API compatibility — mapped onto [mood]-style expression.
  final MascotState state;

  /// Facial expression.
  final MascotMood mood;

  /// When true (and motion is allowed), plays a fade + rise entrance.
  final bool flyIn;

  @override
  Widget build(BuildContext context) {
    final reduceMotion = MediaQuery.disableAnimationsOf(context);

    Widget figure = _AnimatedMascot(
      size: size,
      mood: _effectiveMood,
      reduceMotion: reduceMotion,
    );

    if (flyIn && !reduceMotion) {
      figure = figure
          .animate()
          .fadeIn(duration: 360.ms)
          .slideY(begin: 0.28, end: 0, duration: 420.ms, curve: Curves.easeOut);
    }

    // [tag] is intentionally NOT rendered — it used to show a small caption
    // under the mascot ("home", "profile_header", …) which read as debug text.
    // The param stays for API compatibility and identification in tests.
    return figure;
  }

  /// Celebration/happy states map to a happy face.
  MascotMood get _effectiveMood {
    if (mood != MascotMood.idle) return mood;
    switch (state) {
      case MascotState.celebrate:
        return MascotMood.celebrate;
      case MascotState.happy:
        return MascotMood.happy;
      case MascotState.idle:
      case MascotState.flyDown:
        return MascotMood.idle;
    }
  }
}

/// Retained for API compatibility with existing callers.
enum MascotState {
  /// Default idle.
  idle,

  /// Happy.
  happy,

  /// Fly-down entrance.
  flyDown,

  /// Celebration.
  celebrate,
}

// ── Animated figure ───────────────────────────────────────────────────────────

class _AnimatedMascot extends StatefulWidget {
  const _AnimatedMascot({
    required this.size,
    required this.mood,
    required this.reduceMotion,
  });

  final double size;
  final MascotMood mood;
  final bool reduceMotion;

  @override
  State<_AnimatedMascot> createState() => _AnimatedMascotState();
}

class _AnimatedMascotState extends State<_AnimatedMascot>
    with TickerProviderStateMixin {
  late final AnimationController _floatCtrl;
  late final AnimationController _blinkCtrl;
  Timer? _blinkTimer;
  final _rng = math.Random();

  @override
  void initState() {
    super.initState();
    _floatCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2600),
    );
    _blinkCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 150),
    );
    if (!widget.reduceMotion) {
      unawaited(_floatCtrl.repeat());
      _scheduleBlink();
    }
  }

  void _scheduleBlink() {
    _blinkTimer = Timer(Duration(milliseconds: 2600 + _rng.nextInt(2600)), () {
      if (!mounted) return;
      unawaited(
        _blinkCtrl.forward().then((_) {
          if (mounted) unawaited(_blinkCtrl.reverse());
        }),
      );
      _scheduleBlink();
    });
  }

  @override
  void dispose() {
    _blinkTimer?.cancel();
    _floatCtrl.dispose();
    _blinkCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox.square(
      dimension: widget.size,
      child: AnimatedBuilder(
        animation: Listenable.merge([_floatCtrl, _blinkCtrl]),
        builder: (context, _) {
          return CustomPaint(
            painter: _MascotPainter(
              floatT: _floatCtrl.value,
              blinkT: _blinkCtrl.value,
              mood: widget.mood,
              reduceMotion: widget.reduceMotion,
            ),
          );
        },
      ),
    );
  }
}

// ── Painter ───────────────────────────────────────────────────────────────────

class _MascotPainter extends CustomPainter {
  _MascotPainter({
    required this.floatT,
    required this.blinkT,
    required this.mood,
    required this.reduceMotion,
  });

  final double floatT;
  final double blinkT;
  final MascotMood mood;
  final bool reduceMotion;

  static const _bodyTop = Color(0xFF5AE577);
  static const _bodyBottom = Color(0xFF2FC24C);
  static const _rim = Color(0xFF1FA83E);
  static const _leaf = Color(0xFF41C85C);
  static const _leafDark = Color(0xFF2AA847);
  static const _pupil = Color(0xFF20372E);
  static const _cheek = Color(0xFFFF8FA8);
  static const _mouth = Color(0xFF176B33);

  @override
  void paint(Canvas canvas, Size size) {
    final s = size.shortestSide;
    final cx = s / 2;

    final phase = reduceMotion ? 0.0 : math.sin(floatT * 2 * math.pi);
    final offsetY = -phase * s * 0.03;
    final sx = 1 + 0.028 * phase;
    final sy = 1 - 0.028 * phase;
    final eyeOpen = reduceMotion ? 1.0 : (1 - blinkT).clamp(0.10, 1.0);
    final happy = mood == MascotMood.happy || mood == MascotMood.celebrate;

    // ── Ground shadow ──────────────────────────────────────────────────────
    final shadowScale = 1 - phase * 0.12;
    canvas.drawOval(
      Rect.fromCenter(
        center: Offset(cx, s * 0.92),
        width: s * 0.46 * shadowScale,
        height: s * 0.07 * shadowScale,
      ),
      Paint()..color = Colors.black.withValues(alpha: 0.12),
    );

    canvas
      ..save()
      ..translate(0, offsetY);

    final bodyCenter = Offset(cx, s * 0.56);
    canvas
      ..save()
      ..translate(bodyCenter.dx, bodyCenter.dy)
      ..scale(sx, sy)
      ..translate(-bodyCenter.dx, -bodyCenter.dy);

    // ── Body ───────────────────────────────────────────────────────────────
    final bodyRect = Rect.fromCenter(
      center: bodyCenter,
      width: s * 0.66,
      height: s * 0.68,
    );
    final bodyPaint = Paint()
      ..shader = const LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [_bodyTop, _bodyBottom],
      ).createShader(bodyRect);
    canvas
      ..drawOval(bodyRect, Paint()..color = _rim)
      ..drawOval(bodyRect.deflate(s * 0.012), bodyPaint);

    // Soft top highlight.
    canvas.drawOval(
      Rect.fromCenter(
        center: Offset(cx - s * 0.10, s * 0.40),
        width: s * 0.22,
        height: s * 0.13,
      ),
      Paint()..color = Colors.white.withValues(alpha: 0.18),
    );

    // ── Sprout (stem + two leaves) ─────────────────────────────────────────
    final stem = Path()
      ..moveTo(cx, s * 0.26)
      ..quadraticBezierTo(cx + s * 0.01, s * 0.17, cx, s * 0.12);
    canvas.drawPath(
      stem,
      Paint()
        ..color = _leafDark
        ..style = PaintingStyle.stroke
        ..strokeWidth = s * 0.022
        ..strokeCap = StrokeCap.round,
    );
    _leafShape(canvas, Offset(cx - s * 0.005, s * 0.14), s, left: true);
    _leafShape(canvas, Offset(cx + s * 0.005, s * 0.16), s, left: false);

    // ── Eyes ───────────────────────────────────────────────────────────────
    final eyeY = s * 0.545;
    final eyeDx = s * 0.135;
    _eye(canvas, Offset(cx - eyeDx, eyeY), s, eyeOpen);
    _eye(canvas, Offset(cx + eyeDx, eyeY), s, eyeOpen);

    // ── Cheeks ─────────────────────────────────────────────────────────────
    if (happy) {
      final cheekPaint = Paint()..color = _cheek.withValues(alpha: 0.55);
      canvas
        ..drawCircle(Offset(cx - s * 0.22, s * 0.63), s * 0.045, cheekPaint)
        ..drawCircle(Offset(cx + s * 0.22, s * 0.63), s * 0.045, cheekPaint);
    }

    // ── Mouth ──────────────────────────────────────────────────────────────
    _mouthShape(canvas, cx, s);

    canvas
      ..restore()
      ..restore();
  }

  void _leafShape(Canvas canvas, Offset tip, double s, {required bool left}) {
    final dir = left ? -1.0 : 1.0;
    final path = Path()
      ..moveTo(tip.dx, tip.dy + s * 0.02)
      ..quadraticBezierTo(
        tip.dx + dir * s * 0.11,
        tip.dy - s * 0.06,
        tip.dx + dir * s * 0.02,
        tip.dy - s * 0.08,
      )
      ..quadraticBezierTo(
        tip.dx - dir * s * 0.02,
        tip.dy - s * 0.03,
        tip.dx,
        tip.dy + s * 0.02,
      )
      ..close();
    canvas.drawPath(path, Paint()..color = _leaf);
  }

  void _eye(Canvas canvas, Offset center, double s, double open) {
    if (open < 0.22) {
      // Closed / blink — a gentle downward arc.
      final arc = Path()
        ..moveTo(center.dx - s * 0.05, center.dy)
        ..quadraticBezierTo(
          center.dx,
          center.dy + s * 0.03,
          center.dx + s * 0.05,
          center.dy,
        );
      canvas.drawPath(
        arc,
        Paint()
          ..color = _pupil
          ..style = PaintingStyle.stroke
          ..strokeWidth = s * 0.02
          ..strokeCap = StrokeCap.round,
      );
      return;
    }
    // Open eye: white sclera + pupil + highlight.
    final rx = s * 0.062;
    final ry = s * 0.085 * open;
    canvas.drawOval(
      Rect.fromCenter(center: center, width: rx * 2, height: ry * 2),
      Paint()..color = Colors.white,
    );
    final pupilC = Offset(center.dx, center.dy + ry * 0.15);
    canvas.drawCircle(pupilC, s * 0.036 * open, Paint()..color = _pupil);
    canvas.drawCircle(
      Offset(pupilC.dx - s * 0.014, pupilC.dy - s * 0.02),
      s * 0.014 * open,
      Paint()..color = Colors.white,
    );
  }

  void _mouthShape(Canvas canvas, double cx, double s) {
    final my = s * 0.66;
    if (mood == MascotMood.celebrate) {
      // Open happy mouth.
      final rect = Rect.fromCenter(
        center: Offset(cx, my + s * 0.01),
        width: s * 0.14,
        height: s * 0.11,
      );
      canvas.drawArc(rect, 0, math.pi, true, Paint()..color = _mouth);
      canvas.drawArc(
        Rect.fromCenter(
          center: Offset(cx, my + s * 0.035),
          width: s * 0.09,
          height: s * 0.06,
        ),
        0,
        math.pi,
        true,
        Paint()..color = _cheek,
      );
      return;
    }
    final width = mood == MascotMood.happy ? s * 0.19 : s * 0.13;
    final depth = mood == MascotMood.happy ? s * 0.055 : s * 0.035;
    final smile = Path()
      ..moveTo(cx - width / 2, my)
      ..quadraticBezierTo(cx, my + depth, cx + width / 2, my);
    canvas.drawPath(
      smile,
      Paint()
        ..color = _mouth
        ..style = PaintingStyle.stroke
        ..strokeWidth = s * 0.022
        ..strokeCap = StrokeCap.round,
    );
  }

  @override
  bool shouldRepaint(_MascotPainter old) =>
      old.floatT != floatT ||
      old.blinkT != blinkT ||
      old.mood != mood ||
      old.reduceMotion != reduceMotion;
}
