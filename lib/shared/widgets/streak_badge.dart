import 'package:admity/core/theme/app_colors.dart';
import 'package:admity/shared/rive/rive_assets.dart';
import 'package:admity/shared/rive/rive_state_machine_slot.dart';
import 'package:flutter/material.dart';
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
    if (oldWidget.days != widget.days && _ctrl != null) {
      _applyDays(
        widget.days,
        firePulse: widget.days > (_previousDays ?? widget.days),
      );
      _previousDays = widget.days;
    }
  }

  Widget _staticBolt() {
    return const Icon(
      Icons.bolt,
      color: AppColors.accentLime,
      size: 16,
    );
  }

  @override
  Widget build(BuildContext context) {
    final reduceMotion = MediaQuery.of(context).disableAnimations;

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
            // Bolt area: Rive when available, static Icon otherwise.
            if (reduceMotion)
              _staticBolt()
            else
              RiveStateMachineSlot(
                assetPath: kStreakBadgeRivAsset,
                machineName: kStreakBadgeMachineName,
                staticFallback: _staticBolt(),
                onController: _onController,
                width: 16,
                height: 16,
              ),
            const SizedBox(width: 4),
            Text(
              '${widget.days}',
              style: const TextStyle(
                color: AppColors.white,
                fontSize: 14,
                fontWeight: FontWeight.w700,
                height: 1,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
