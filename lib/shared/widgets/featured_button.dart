import 'package:admity/core/theme/app_colors.dart';
import 'package:flutter/material.dart';

/// Multicolour gradient CTA for featured actions
/// (Jump ahead / Start the Lesson / lesson completion).
///
/// Design rule (DESIGN_SYSTEM.md §1): [AppColors.ctaGradient] fill (blue →
/// purple → pink → orange), white text, 16 px corner radius,
/// touch target ≥ 48 px tall.
class FeaturedButton extends StatelessWidget {
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
  Widget build(BuildContext context) {
    final minWidth = width ?? double.infinity;

    return GestureDetector(
      onTap: isLoading ? null : onPressed,
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
    );
  }

  Widget _buildChild() {
    if (isLoading) {
      return const SizedBox.square(
        dimension: 22,
        child: CircularProgressIndicator(
          strokeWidth: 2,
          color: AppColors.white,
        ),
      );
    }

    if (icon != null) {
      return Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          icon!,
          const SizedBox(width: 8),
          Text(
            label,
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
      label,
      style: const TextStyle(
        color: AppColors.white,
        fontWeight: FontWeight.w600,
        fontSize: 16,
      ),
    );
  }
}
