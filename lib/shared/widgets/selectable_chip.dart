import 'dart:async';

import 'package:admity/core/theme/app_colors.dart';
import 'package:admity/core/theme/app_durations.dart';
import 'package:admity/core/theme/app_radii.dart';
import 'package:admity/core/theme/app_theme_extension.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// A tactile, toggleable chip used for interests, answers and filters.
class SelectableChip extends StatelessWidget {
  const SelectableChip({
    required this.label,
    required this.selected,
    required this.onTap,
    this.icon,
    super.key,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;
  final IconData? icon;

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;
    final fg = selected ? Colors.white : context.colors.onSurface;
    return GestureDetector(
      onTap: () {
        unawaited(HapticFeedback.selectionClick());
        onTap();
      },
      child: AnimatedContainer(
        duration: AppDurations.fast,
        curve: Curves.easeOut,
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: BoxDecoration(
          color: selected ? AppColors.terracotta : tokens.surfaceRaised,
          borderRadius: AppRadii.brPill,
          border: Border.all(
            color: selected
                ? AppColors.terracotta
                : context.colors.outlineVariant,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (icon != null) ...[
              Icon(icon, size: 16, color: fg),
              const SizedBox(width: 6),
            ],
            Text(
              label,
              style: context.text.labelMedium?.copyWith(color: fg),
            ),
          ],
        ),
      ),
    );
  }
}
