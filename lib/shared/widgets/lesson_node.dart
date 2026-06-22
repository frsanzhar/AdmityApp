import 'package:admity/core/theme/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

/// State of a lesson node on the course path.
enum LessonNodeState {
  /// Currently active — highlighted with a [AppColors.primary] ring.
  active,

  /// Already completed — solid [AppColors.primary] fill.
  done,

  /// Not yet unlocked — grey and not interactive.
  locked,
}

/// Round disc node used in the Brilliant-style vertical lesson path
/// on the Courses screen (§4, §7.3).
///
/// - [LessonNodeState.active] → white fill + [AppColors.primary] ring + icon.
/// - [LessonNodeState.done]   → [AppColors.primary] fill + white check icon.
/// - [LessonNodeState.locked] → grey fill + lock icon.
///
/// ## Animation (non-breaking addition)
/// The [LessonNodeState.active] node pulses with a gentle repeating
/// scale + glow shimmer so it draws attention without being distracting.
/// Suppressed when `MediaQuery.disableAnimations` is true.
///
/// All existing constructor parameters are unchanged.
class LessonNode extends StatelessWidget {
  const LessonNode({
    required this.state,
    super.key,
    this.size = 64,
    this.onTap,
    this.label,
    this.icon,
  });

  final LessonNodeState state;
  final double size;
  final VoidCallback? onTap;
  final String? label;

  /// Custom icon to display inside the node.  Defaults to state-specific icon.
  final IconData? icon;

  @override
  Widget build(BuildContext context) {
    final (bg, border, iconColor, borderWidth) = switch (state) {
      LessonNodeState.active => (
        AppColors.white,
        AppColors.primary,
        AppColors.primary,
        3.0,
      ),
      LessonNodeState.done => (
        AppColors.primary,
        AppColors.primary,
        AppColors.white,
        0.0,
      ),
      LessonNodeState.locked => (
        AppColors.surfaceTint,
        AppColors.border,
        AppColors.inkSecondary,
        1.5,
      ),
    };

    final defaultIcon = switch (state) {
      LessonNodeState.active => Icons.play_arrow_rounded,
      LessonNodeState.done => Icons.check_rounded,
      LessonNodeState.locked => Icons.lock_rounded,
    };

    final disc = Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: bg,
        shape: BoxShape.circle,
        border: borderWidth > 0
            ? Border.all(color: border, width: borderWidth)
            : null,
        boxShadow: state == LessonNodeState.active
            ? [
                BoxShadow(
                  color: AppColors.primary.withValues(alpha: 0.25),
                  blurRadius: 16,
                  offset: const Offset(0, 4),
                ),
              ]
            : null,
      ),
      child: Icon(icon ?? defaultIcon, color: iconColor, size: size * 0.4),
    );

    final node = GestureDetector(
      onTap: state == LessonNodeState.locked ? null : onTap,
      child: _maybeAnimateActive(context, disc),
    );

    if (label != null) {
      return Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          node,
          const SizedBox(height: 6),
          Text(
            label!,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: state == LessonNodeState.locked
                  ? AppColors.inkSecondary
                  : AppColors.ink,
            ),
          ),
        ],
      );
    }

    return node;
  }

  /// Wraps [child] in a repeating scale pulse when [state] is active and
  /// the platform has not requested reduced motion.
  Widget _maybeAnimateActive(BuildContext context, Widget child) {
    if (state != LessonNodeState.active) return child;
    if (MediaQuery.of(context).disableAnimations) return child;

    // Gentle breathing: 1.0 → 1.04 → 1.0, 2-second cycle.
    return child
        .animate(onPlay: (ctrl) => ctrl.repeat(reverse: true))
        .scale(
          begin: const Offset(1, 1),
          end: const Offset(1.04, 1.04),
          duration: const Duration(milliseconds: 900),
          curve: Curves.easeInOut,
        );
  }
}
