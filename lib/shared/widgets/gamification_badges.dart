import 'package:admity/core/theme/app_radii.dart';
import 'package:admity/core/theme/app_theme_extension.dart';
import 'package:flutter/material.dart';

/// A small pill showing accumulated XP.
class XpChip extends StatelessWidget {
  const XpChip({required this.xp, this.compact = false, super.key});

  final int xp;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: compact ? 8 : 12,
        vertical: compact ? 4 : 6,
      ),
      decoration: BoxDecoration(
        color: tokens.xp.withValues(alpha: 0.16),
        borderRadius: AppRadii.brPill,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.bolt_rounded, size: compact ? 14 : 16, color: tokens.xp),
          const SizedBox(width: 4),
          Text(
            '$xp XP',
            style: context.text.labelMedium?.copyWith(color: tokens.xp),
          ),
        ],
      ),
    );
  }
}

/// A streak badge (flame + day count). Shows a frost tint when a streak-freeze
/// is active.
class StreakBadge extends StatelessWidget {
  const StreakBadge({
    required this.days,
    this.frozen = false,
    super.key,
  });

  final int days;
  final bool frozen;

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;
    final color = frozen ? tokens.info : tokens.streak;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.16),
        borderRadius: AppRadii.brPill,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            frozen ? Icons.ac_unit_rounded : Icons.local_fire_department_rounded,
            size: 16,
            color: color,
          ),
          const SizedBox(width: 4),
          Text(
            '$days',
            style: context.text.labelMedium?.copyWith(color: color),
          ),
        ],
      ),
    );
  }
}
