import 'dart:math' as math;

import 'package:admity/core/theme/app_colors.dart';
import 'package:admity/shared/rive/rive_assets.dart';
import 'package:admity/shared/rive/rive_state_machine_slot.dart';
import 'package:flutter/material.dart';
import 'package:rive/rive.dart';

// TODO(mascot): Replace this geometric placeholder with the real mascot
// asset when the designer delivers it.  Search for "MascotSlot" to find
// every placement in the app.
//
// TODO(rive-asset): Wire to assets/rive/mascot.riv once delivered.
// State Machine contract: machine='MascotSM'
//   inputs  — isIdle (bool), isHappy (bool)
//   triggers — flyDown, celebrate
// Until the asset lands the green blob renders as a static fallback.

/// Slot for the Admity mascot figure.
///
/// Phase 7 wiring: drives Rive State Machine [kMascotMachineName] via
/// [state].
///
/// ### reduceMotion
/// When `MediaQuery.disableAnimations` is true the static blob always renders.
///
/// ### Missing asset
/// When assets/rive/mascot.riv is absent the green blob renders instead.
///
/// API is additive-only — [size], [tag], [state] — no breaking change to
/// callers that only pass [size] and [tag].
class MascotSlot extends StatefulWidget {
  const MascotSlot({
    super.key,
    this.size = 120,
    this.tag,
    this.state = MascotState.idle,
  });

  /// Bounding box dimension (width = height = [size]).
  final double size;

  /// Optional context label shown under the mascot (e.g. "home" / "lesson").
  final String? tag;

  /// Drives the Rive State Machine state.
  final MascotState state;

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
    final blob = _BlobFallback(size: widget.size);

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        RiveStateMachineSlot(
          assetPath: kMascotRivAsset,
          machineName: kMascotMachineName,
          staticFallback: blob,
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

// ── Static fallback ───────────────────────────────────────────────────────────

/// The original green blob, now used as the static fallback for MascotSlot.
class _BlobFallback extends StatelessWidget {
  const _BlobFallback({required this.size});

  final double size;

  @override
  Widget build(BuildContext context) {
    return SizedBox.square(
      dimension: size,
      child: CustomPaint(
        painter: _BlobPainter(size: size),
      ),
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
