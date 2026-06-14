import 'package:admity/core/theme/app_spacing.dart';
import 'package:admity/core/theme/app_theme_extension.dart';
import 'package:admity/shared/widgets/bento_card.dart';
import 'package:flutter/material.dart';

/// A standard tappable row card (icon · title/subtitle · chevron) used in hub
/// screens.
class NavCard extends StatelessWidget {
  const NavCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
    this.accent,
    this.trailing,
    super.key,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;
  final Color? accent;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;
    return BentoCard(
      onTap: onTap,
      accent: accent,
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: (accent ?? context.colors.primary).withValues(alpha: 0.14),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: accent ?? context.colors.primary),
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: context.text.titleMedium),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  style: context.text.bodySmall
                      ?.copyWith(color: tokens.textMuted),
                ),
              ],
            ),
          ),
          trailing ??
              Icon(Icons.chevron_right_rounded, color: tokens.textMuted),
        ],
      ),
    );
  }
}
