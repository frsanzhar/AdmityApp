import 'package:admity/core/theme/app_colors.dart';
import 'package:flutter/material.dart';

/// Pill badge showing the user's current streak with a lime lightning bolt.
///
/// Placed in the top-right area of the home screen header per §5.
class StreakBadge extends StatelessWidget {
  const StreakBadge({
    required this.days,
    super.key,
  });

  final int days;

  @override
  Widget build(BuildContext context) {
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
            const Icon(
              Icons.bolt,
              color: AppColors.accentLime,
              size: 16,
            ),
            const SizedBox(width: 4),
            Text(
              '$days',
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
