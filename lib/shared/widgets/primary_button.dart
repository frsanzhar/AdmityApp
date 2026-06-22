import 'dart:async';

import 'package:admity/core/theme/app_colors.dart';
import 'package:flutter/material.dart';

/// Solid dark button for standard actions (Continue / Check / Save).
///
/// Design rule (DESIGN_SYSTEM.md §1): dark [AppColors.ink] fill, white text,
/// 16 px corner radius, touch target ≥ 48 px tall.
///
/// ## Animation (non-breaking addition)
/// On tap-down the button scales to 0.97 and dims slightly, snapping back on
/// tap-up/cancel.  This is suppressed when
/// `MediaQuery.disableAnimations` is true (reduceMotion).
///
/// All existing required/optional parameters are unchanged.
class PrimaryButton extends StatefulWidget {
  const PrimaryButton({
    required this.label,
    required this.onPressed,
    super.key,
    this.icon,
    this.isLoading = false,
    this.width,
  });

  final String label;
  final VoidCallback? onPressed;
  final Widget? icon;
  final bool isLoading;
  final double? width;

  @override
  State<PrimaryButton> createState() => _PrimaryButtonState();
}

class _PrimaryButtonState extends State<PrimaryButton>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  late final Animation<double> _scale;
  late final Animation<double> _opacity;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 90),
      reverseDuration: const Duration(milliseconds: 160),
    );
    _scale = Tween<double>(begin: 1, end: 0.97).animate(
      CurvedAnimation(parent: _ctrl, curve: Curves.easeInOut),
    );
    _opacity = Tween<double>(begin: 1, end: 0.82).animate(
      CurvedAnimation(parent: _ctrl, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  void _onTapDown(TapDownDetails _) {
    if (MediaQuery.of(context).disableAnimations) return;
    if (widget.isLoading || widget.onPressed == null) return;
    unawaited(_ctrl.forward());
  }

  void _onTapUp(TapUpDetails _) => unawaited(_ctrl.reverse());
  void _onTapCancel() => unawaited(_ctrl.reverse());

  @override
  Widget build(BuildContext context) {
    const radius = BorderRadius.all(Radius.circular(16));
    final style = ElevatedButton.styleFrom(
      backgroundColor: AppColors.ink,
      foregroundColor: AppColors.white,
      minimumSize: Size(widget.width ?? double.infinity, 52),
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
      shape: const RoundedRectangleBorder(borderRadius: radius),
      elevation: 0,
    );

    final child = widget.isLoading
        ? const SizedBox.square(
            dimension: 22,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              color: AppColors.white,
            ),
          )
        : widget.icon != null
        ? Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              widget.icon!,
              const SizedBox(width: 8),
              Text(widget.label),
            ],
          )
        : Text(widget.label);

    return GestureDetector(
      onTapDown: _onTapDown,
      onTapUp: _onTapUp,
      onTapCancel: _onTapCancel,
      // Use HitTestBehavior.translucent so the ElevatedButton ink still fires.
      behavior: HitTestBehavior.translucent,
      child: AnimatedBuilder(
        animation: _ctrl,
        builder: (context, buttonChild) => Transform.scale(
          scale: _scale.value,
          child: Opacity(
            opacity: _opacity.value,
            child: buttonChild,
          ),
        ),
        child: ElevatedButton(
          onPressed: widget.isLoading ? null : widget.onPressed,
          style: style,
          child: child,
        ),
      ),
    );
  }
}
