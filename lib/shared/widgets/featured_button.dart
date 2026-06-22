import 'dart:async';

import 'package:admity/core/theme/app_colors.dart';
import 'package:flutter/material.dart';

/// Multicolour gradient CTA for featured actions
/// (Jump ahead / Start the Lesson / lesson completion).
///
/// Design rule (DESIGN_SYSTEM.md §1): [AppColors.ctaGradient] fill (blue →
/// purple → pink → orange), white text, 16 px corner radius,
/// touch target ≥ 48 px tall.
///
/// ## Animation (non-breaking addition)
/// On tap-down the button scales to 0.97 and dims slightly, snapping back on
/// tap-up/cancel.  Suppressed when `MediaQuery.disableAnimations` is true.
///
/// All existing required/optional parameters are unchanged.
class FeaturedButton extends StatefulWidget {
  const FeaturedButton({
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
  State<FeaturedButton> createState() => _FeaturedButtonState();
}

class _FeaturedButtonState extends State<FeaturedButton>
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
    final minWidth = widget.width ?? double.infinity;

    return GestureDetector(
      onTapDown: _onTapDown,
      onTapUp: _onTapUp,
      onTapCancel: _onTapCancel,
      onTap: widget.isLoading ? null : widget.onPressed,
      child: AnimatedBuilder(
        animation: _ctrl,
        builder: (context, inner) => Transform.scale(
          scale: _scale.value,
          child: Opacity(
            opacity: _opacity.value,
            child: inner,
          ),
        ),
        child: Container(
          constraints: BoxConstraints(minWidth: minWidth, minHeight: 52),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: AppColors.ctaGradient,
            ),
            borderRadius: BorderRadius.all(Radius.circular(16)),
          ),
          alignment: Alignment.center,
          child: _buildChild(),
        ),
      ),
    );
  }

  Widget _buildChild() {
    if (widget.isLoading) {
      return const SizedBox.square(
        dimension: 22,
        child: CircularProgressIndicator(
          strokeWidth: 2,
          color: AppColors.white,
        ),
      );
    }

    if (widget.icon != null) {
      return Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          widget.icon!,
          const SizedBox(width: 8),
          Text(
            widget.label,
            style: const TextStyle(
              color: AppColors.white,
              fontWeight: FontWeight.w600,
              fontSize: 16,
            ),
          ),
        ],
      );
    }

    return Text(
      widget.label,
      style: const TextStyle(
        color: AppColors.white,
        fontWeight: FontWeight.w600,
        fontSize: 16,
      ),
    );
  }
}
