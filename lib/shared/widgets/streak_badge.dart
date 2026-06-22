import 'package:admity/core/theme/app_colors.dart';
import 'package:admity/shared/rive/rive_assets.dart';
import 'package:admity/shared/rive/rive_state_machine_slot.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:rive/rive.dart';

// TODO(rive-asset): Wire to assets/rive/streak_badge.riv once delivered.
// State Machine contract: machine='StreakSM'
//   inputs  — days (number)
//   triggers — pulse   (bolt flash on streak increment)
// Until the asset lands the static bolt icon renders as fallback.

/// Pill badge showing the user's current streak with a lime lightning bolt.
///
/// Phase 7 wiring: the bolt icon area is replaced by a Rive State Machine
/// that animates a pulse when the streak day count increments.
///
/// ## Animation (non-breaking addition)
/// When [days] increments the count text pops (scale bounce) and the static
/// bolt icon briefly pulses (brightness flash) as a pure-Flutter fallback until
/// the Rive asset is available.  Both animations are suppressed when
/// `MediaQuery.disableAnimations` is true.
///
/// ### reduceMotion
/// When `MediaQuery.disableAnimations` is true the static bolt icon renders.
///
/// ### Missing asset
/// When assets/rive/streak_badge.riv is absent the static icon renders.
///
/// Placed in the top-right area of the home screen header per §5.
class StreakBadge extends StatefulWidget {
  const StreakBadge({
    required this.days,
    super.key,
  });

  final int days;

  @override
  State<StreakBadge> createState() => _StreakBadgeState();
}

class _StreakBadgeState extends State<StreakBadge> {
  RiveWidgetController? _ctrl;
  int? _previousDays;

  // Key to re-trigger the flutter_animate count pop.
  late int _animKey;

  @override
  void initState() {
    super.initState();
    _animKey = widget.days;
  }

  void _onController(RiveWidgetController ctrl) {
    _ctrl = ctrl;
    _applyDays(widget.days, firePulse: false);
    _previousDays = widget.days;
  }

  void _applyDays(int days, {required bool firePulse}) {
    final ctrl = _ctrl;
    if (ctrl == null) return;
    final sm = ctrl.stateMachine;
    // ignore: deprecated_member_use // SMI inputs deprecated in rive 0.14.x; assets not yet migrated to Data Binding.
    sm.number(kStreakBadgeInputDays)?.value = days.toDouble();
    if (firePulse) {
      // ignore: deprecated_member_use // Assets not yet migrated to Data Binding.
      sm.trigger(kStreakBadgeTriggerPulse)?.fire();
    }
  }

  @override
  void didUpdateWidget(StreakBadge oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.days != widget.days) {
      if (_ctrl != null) {
        _applyDays(
          widget.days,
          firePulse: widget.days > (_previousDays ?? widget.days),
        );
      }
      _previousDays = widget.days;
      // Bump key to retrigger flutter_animate count pop.
      setState(() => _animKey = widget.days);
    }
  }

  Widget _staticBolt({bool animatePulse = false}) {
    final disableAnim = MediaQuery.of(context).disableAnimations;
    const bolt = Icon(
      Icons.bolt,
      color: AppColors.accentLime,
      size: 16,
    );

    if (animatePulse && !disableAnim) {
      // Brief brightness-up pulse as a fallback for the Rive bolt animation.
      return bolt
          .animate(key: ValueKey<int>(_animKey))
          .scale(
            begin: const Offset(0.7, 0.7),
            end: const Offset(1, 1),
            duration: const Duration(milliseconds: 220),
            curve: Curves.easeOutBack,
          );
    }
    return bolt;
  }

  Widget _countText() {
    final disableAnim = MediaQuery.of(context).disableAnimations;
    final text = Text(
      '${widget.days}',
      style: const TextStyle(
        color: AppColors.white,
        fontSize: 14,
        fontWeight: FontWeight.w700,
        height: 1,
      ),
    );

    if (!disableAnim) {
      return text
          .animate(key: ValueKey<int>(_animKey))
          .scale(
            begin: const Offset(0.75, 0.75),
            end: const Offset(1, 1),
            duration: const Duration(milliseconds: 260),
            curve: Curves.easeOutBack,
          );
    }
    return text;
  }

  @override
  Widget build(BuildContext context) {
    final reduceMotion = MediaQuery.of(context).disableAnimations;
    // Whether we have a Rive controller live — determines fallback bolt style.
    final riveActive = _ctrl != null;

    return DecoratedBox(
      decoration: BoxDecoration(
        color: AppColors.ink,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Bolt area: Rive when available, animated static Icon otherwise.
            if (reduceMotion)
              _staticBolt()
            else
              RiveStateMachineSlot(
                assetPath: kStreakBadgeRivAsset,
                machineName: kStreakBadgeMachineName,
                staticFallback: _staticBolt(animatePulse: !riveActive),
                onController: _onController,
                width: 16,
                height: 16,
              ),
            const SizedBox(width: 4),
            _countText(),
          ],
        ),
      ),
    );
  }
}
