import 'package:admity/core/theme/app_colors.dart';
import 'package:admity/shared/rive/rive_assets.dart';
import 'package:admity/shared/rive/rive_state_machine_slot.dart';
import 'package:admity/shared/widgets/mascot_painter.dart';
import 'package:flutter/material.dart';
import 'package:rive/rive.dart';

// TODO(mascot): Replace the CustomPaint panda fallback with the final
// designer Rive asset once delivered.  Search "MascotSlot" to find every
// placement in the app.
//
// TODO(rive-asset): Wire to assets/rive/mascot.riv once delivered.
// State Machine contract: machine='MascotSM'
//   inputs  — isIdle (bool), isHappy (bool)
//   triggers — flyDown, celebrate
// Until the asset lands the panda CustomPaint renders as a static fallback.

/// Slot for the Admity panda mascot.
///
/// ### Public API (additive — no breaking changes to existing callers)
///
/// ```dart
/// MascotSlot(size: 120, tag: 'home')                    // idle panda
/// MascotSlot(size: 80, state: MascotState.celebrate)    // Rive celebrate
/// MascotSlot(size: 80, mood: MascotMood.celebrate)      // painted expression
/// ```
///
/// [state] drives the **Rive State Machine** (Phase 7 motion).
/// [mood]  drives the **painted panda expression** (always visible as
///         static fallback; also meaningful when Rive isn't available).
/// Both params are independent so screens can set each to match their context.
///
/// ### reduceMotion
/// When `MediaQuery.disableAnimations` is true the static panda always
/// renders regardless of [state].
///
/// ### Missing Rive asset
/// When assets/rive/mascot.riv is absent the panda [CustomPaint] renders.
class MascotSlot extends StatefulWidget {
  const MascotSlot({
    super.key,
    this.size = 120,
    this.tag,
    this.state = MascotState.idle,
    this.mood = MascotMood.idle,
  });

  /// Bounding box dimension (width = height = [size]).
  final double size;

  /// Optional context label shown under the mascot (e.g. "home" / "lesson").
  final String? tag;

  /// Drives the Rive State Machine inputs/triggers (Phase 7 motion).
  final MascotState state;

  /// Drives the painted panda expression differences.
  ///
  /// Defaults to [MascotMood.idle]. Independent of [state] — screens may
  /// set [mood] to [MascotMood.celebrate] while [state] stays at
  /// [MascotState.idle] if the Rive animation is not yet active.
  final MascotMood mood;

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
    // Static panda fallback — also used when reduceMotion is requested.
    final panda = _PandaFallback(size: widget.size, mood: widget.mood);

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        RiveStateMachineSlot(
          assetPath: kMascotRivAsset,
          machineName: kMascotMachineName,
          staticFallback: panda,
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

// ── Painted panda fallback ────────────────────────────────────────────────────

/// Renders the custom panda character via [PandaPainter].
///
/// Used as the static fallback while assets/rive/mascot.riv is not yet
/// available, and always when `MediaQuery.disableAnimations` is true.
class _PandaFallback extends StatelessWidget {
  const _PandaFallback({required this.size, this.mood = MascotMood.idle});

  final double size;
  final MascotMood mood;

  @override
  Widget build(BuildContext context) {
    // Respect the system reduce-motion preference — static painter already is
    // static, but we gate here explicitly so future animatable variants respect
    // the preference too.
    final effectiveMood = MediaQuery.disableAnimationsOf(context)
        ? MascotMood.idle
        : mood;

    return SizedBox.square(
      dimension: size,
      child: CustomPaint(
        painter: PandaPainter(size: size, mood: effectiveMood),
      ),
    );
  }
}
