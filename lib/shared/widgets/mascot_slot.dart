import 'dart:async';
import 'dart:math' as math;

import 'package:admity/core/theme/app_colors.dart';
import 'package:admity/shared/rive/rive_assets.dart';
import 'package:admity/shared/rive/rive_state_machine_slot.dart';
import 'package:admity/shared/widgets/mascot_painter.dart';
import 'package:flutter/animation.dart' as flutter_anim;
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:rive/rive.dart' hide Animation;

// TODO(mascot): Replace the CustomPaint blob fallback with the final
// designer Rive asset once delivered.  Search "MascotSlot" to find every
// placement in the app.
//
// TODO(rive-asset): Wire to assets/rive/mascot.riv once delivered.
// State Machine contract: machine='MascotSM'
//   inputs  — isIdle (bool), isHappy (bool)
//   triggers — flyDown, celebrate
// Until the asset lands the blob CustomPaint renders as the animated fallback.

/// Slot for the Admity green blob mascot.
///
/// ### Public API (additive — no breaking changes to existing callers)
///
/// ```dart
/// MascotSlot(size: 120, tag: 'home')                    // idle blob
/// MascotSlot(size: 80, state: MascotState.celebrate)    // Rive celebrate
/// MascotSlot(size: 80, mood: MascotMood.celebrate)      // painted expression
/// MascotSlot(size: 120, flyIn: true)                    // fly-up entrance
/// ```
///
/// [state] drives the **Rive State Machine** (Phase 7 motion).
/// [mood]  drives the **painted blob expression** (always visible as fallback;
///         also meaningful when Rive isn't available).
/// [flyIn] when true (and motion is allowed) plays a fly-up entrance: the
///         figure rises from below and settles into position. Safe to use
///         on onboarding screens.
/// Both [state] and [mood] are independent so screens can set each to match
/// their context.
///
/// ### reduceMotion
/// When `MediaQuery.disableAnimations` is true the static blob always renders
/// regardless of [state] or [flyIn]. Micro-animations are also suppressed.
///
/// ### Missing Rive asset
/// When assets/rive/mascot.riv is absent the blob [CustomPaint] renders with
/// procedural animations.
class MascotSlot extends StatefulWidget {
  const MascotSlot({
    super.key,
    this.size = 120,
    this.tag,
    this.state = MascotState.idle,
    this.mood = MascotMood.idle,
    this.flyIn = false,
  });

  /// Bounding box dimension (width = height = [size]).
  final double size;

  /// Optional context label shown under the mascot (e.g. "home" / "lesson").
  final String? tag;

  /// Drives the Rive State Machine inputs/triggers (Phase 7 motion).
  final MascotState state;

  /// Drives the painted blob expression.
  ///
  /// Defaults to [MascotMood.idle]. Independent of [state] — screens may
  /// set [mood] to [MascotMood.celebrate] while [state] stays at
  /// [MascotState.idle] if the Rive animation is not yet active.
  final MascotMood mood;

  /// When true (and `MediaQuery.disableAnimations` is false), the mascot plays
  /// a fly-up entrance: rises from below its natural position and settles in
  /// place with a gentle overshoot bounce. Intended for onboarding and
  /// lesson-complete screens.
  final bool flyIn;

  @override
  State<MascotSlot> createState() => _MascotSlotState();
}

/// The logical state that maps to Rive State Machine inputs/triggers.
enum MascotState {
  /// Default: idle looping animation.
  idle,

  /// Happy face — e.g. shown when user loads the home screen.
  happy,

  /// Mascot flies down from above — triggered on "Start Lesson" tap.
  flyDown,

  /// Confetti celebration — lesson complete screen.
  celebrate,
}

class _MascotSlotState extends State<MascotSlot> {
  RiveWidgetController? _ctrl;
  MascotState? _previousState;

  void _onController(RiveWidgetController ctrl) {
    _ctrl = ctrl;
    _applyState(widget.state);
  }

  void _applyState(MascotState st) {
    final ctrl = _ctrl;
    if (ctrl == null) return;
    final sm = ctrl.stateMachine;

    // ignore: deprecated_member_use // SMI inputs deprecated in rive 0.14.x; assets not yet migrated to Data Binding.
    sm.boolean(kMascotInputIdle)?.value = st == MascotState.idle;
    // ignore: deprecated_member_use // Same: assets not yet migrated.
    sm.boolean(kMascotInputHappy)?.value = st == MascotState.happy;

    if (st == MascotState.flyDown && _previousState != MascotState.flyDown) {
      // ignore: deprecated_member_use // Assets not yet migrated to Data Binding.
      sm.trigger(kMascotTriggerFlyDown)?.fire();
    }
    if (st == MascotState.celebrate &&
        _previousState != MascotState.celebrate) {
      // ignore: deprecated_member_use // Assets not yet migrated to Data Binding.
      sm.trigger(kMascotTriggerCelebrate)?.fire();
    }
    _previousState = st;
  }

  @override
  void didUpdateWidget(MascotSlot oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.state != widget.state && _ctrl != null) {
      _applyState(widget.state);
    }
  }

  @override
  Widget build(BuildContext context) {
    final reduceMotion = MediaQuery.disableAnimationsOf(context);

    // Animated blob fallback — used when Rive asset isn't available or when
    // reduceMotion is true (in which case the blob is static).
    final blobFallback = _BlobFallback(
      size: widget.size,
      mood: widget.mood,
      flyIn: widget.flyIn,
      reduceMotion: reduceMotion,
    );

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        RiveStateMachineSlot(
          assetPath: kMascotRivAsset,
          machineName: kMascotMachineName,
          staticFallback: blobFallback,
          onController: _onController,
          width: widget.size,
          height: widget.size,
        ),
        if (widget.tag != null) ...[
          const SizedBox(height: 4),
          Text(
            widget.tag!,
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

// ── Animated blob fallback ────────────────────────────────────────────────────

/// Renders the animated green blob mascot via [BlobMascotPainter].
///
/// Provides layered micro-animation (all suppressed when [reduceMotion] is
/// true):
///   1. **Breathing**: a gentle sine-wave vertical bob (~3.8 s period).
///   2. **Blink**: eyes close quickly every 3–5 s and reopen (140 ms).
///   3. **Glance**: pupils drift left/right subtly every 6–10 s.
///   4. **Arm wave**: oscillation synced to the breathing controller.
///   5. **Fly-in entrance**: [flyIn]=true plays a rise-and-settle animation
///      via flutter_animate when the widget first mounts.
class _BlobFallback extends StatefulWidget {
  const _BlobFallback({
    required this.size,
    required this.mood,
    required this.flyIn,
    required this.reduceMotion,
  });

  final double size;
  final MascotMood mood;
  final bool flyIn;
  final bool reduceMotion;

  @override
  State<_BlobFallback> createState() => _BlobFallbackState();
}

class _BlobFallbackState extends State<_BlobFallback>
    with TickerProviderStateMixin {
  // ── Controllers ──────────────────────────────────────────────────────────────

  /// Breathing + arm-wave: slow continuous oscillation.
  late final AnimationController _breathCtrl;

  /// Blink: drives blinkT 0→1→0 per blink event.
  late final AnimationController _blinkCtrl;

  /// Glance: drives glanceX between positions.
  late final AnimationController _glanceCtrl;

  // Explicit flutter_anim.Animation<double> avoids the ambiguous 'Animation'
  // name exported by both flutter/animation.dart and rive/rive.dart.
  late flutter_anim.Animation<double> _glanceAnim;

  Timer? _blinkTimer;
  Timer? _glanceTimer;
  final _rng = math.Random();

  // ── Animated values ──────────────────────────────────────────────────────────

  double get _breathT {
    // Sine wave → positive half only, so the bob goes in one direction.
    return (math.sin(_breathCtrl.value * math.pi * 2) + 1) / 2;
  }

  double get _blinkT => _blinkCtrl.value;

  // _glanceAnim.value is a double; map 0..1 → -1..+1 for the painter.
  double get _glanceX => (_glanceAnim.value - 0.5) * 2;

  double get _armWave => _breathCtrl.value;

  // ── Lifecycle ────────────────────────────────────────────────────────────────

  @override
  void initState() {
    super.initState();

    _breathCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 3800),
    );

    _blinkCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 140),
    );

    _glanceCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _glanceAnim = flutter_anim.Tween<double>(
      begin: 0.5,
      end: 0.5,
    ).animate(_glanceCtrl);

    if (!widget.reduceMotion) {
      _startMicroAnimations();
    }
  }

  void _startMicroAnimations() {
    unawaited(_breathCtrl.repeat());
    _scheduleBlink();
    _scheduleGlance();
  }

  void _scheduleBlink() {
    // Blink every 3–5 seconds.
    final delayMs = 3000 + _rng.nextInt(2000);
    _blinkTimer = Timer(Duration(milliseconds: delayMs), () {
      if (!mounted) return;
      // Forward (close eyes) then reverse (open eyes).
      unawaited(
        _blinkCtrl.forward().then((_) {
          if (mounted) unawaited(_blinkCtrl.reverse());
        }),
      );
      _scheduleBlink();
    });
  }

  void _scheduleGlance() {
    // Glance every 6–10 seconds.
    final delayMs = 6000 + _rng.nextInt(4000);
    _glanceTimer = Timer(Duration(milliseconds: delayMs), () {
      if (!mounted) return;
      // Pick a random glance direction.
      final target = _rng.nextDouble();
      _glanceAnim =
          flutter_anim.Tween<double>(
            begin: _glanceAnim.value,
            end: target,
          ).animate(
            CurvedAnimation(parent: _glanceCtrl, curve: Curves.easeInOut),
          );
      _glanceCtrl.reset();
      unawaited(
        _glanceCtrl.forward().then((_) {
          if (!mounted) return;
          // Return to centre after a short pause.
          Timer(const Duration(milliseconds: 800), () {
            if (!mounted) return;
            _glanceAnim =
                flutter_anim.Tween<double>(
                  begin: _glanceAnim.value,
                  end: 0.5,
                ).animate(
                  CurvedAnimation(parent: _glanceCtrl, curve: Curves.easeInOut),
                );
            _glanceCtrl.reset();
            unawaited(_glanceCtrl.forward());
          });
        }),
      );
      _scheduleGlance();
    });
  }

  @override
  void dispose() {
    _breathCtrl.dispose();
    _blinkCtrl.dispose();
    _glanceCtrl.dispose();
    _blinkTimer?.cancel();
    _glanceTimer?.cancel();
    super.dispose();
  }

  // ── Build ────────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    Widget painter = AnimatedBuilder(
      animation: Listenable.merge([_breathCtrl, _blinkCtrl, _glanceCtrl]),
      builder: (context, _) {
        return SizedBox.square(
          dimension: widget.size,
          child: CustomPaint(
            painter: BlobMascotPainter(
              size: widget.size,
              mood: widget.mood,
              blinkT: widget.reduceMotion ? 0 : _blinkT,
              glanceX: widget.reduceMotion ? 0 : _glanceX,
              armWave: widget.reduceMotion ? 0 : _armWave,
              breathT: widget.reduceMotion ? 0 : _breathT,
            ),
          ),
        );
      },
    );

    // Fly-in entrance animation (only when enabled and motion allowed).
    if (widget.flyIn && !widget.reduceMotion) {
      painter = painter
          .animate()
          .slideY(
            begin: 0.40,
            end: 0,
            duration: 520.ms,
            curve: Curves.easeOut,
          )
          .then()
          .slideY(
            begin: 0,
            end: -0.05,
            duration: 160.ms,
            curve: Curves.easeOut,
          )
          .then()
          .slideY(
            begin: -0.05,
            end: 0,
            duration: 200.ms,
            curve: Curves.easeIn,
          )
          .fadeIn(duration: 280.ms, curve: Curves.easeIn);
    }

    return painter;
  }
}
