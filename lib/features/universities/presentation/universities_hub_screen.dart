// Universities hub — entry point for the "Вузы" tab.
//
// Shows two large tappable cards letting the student choose between the
// Kazakhstan catalog (/uni-kz) and the abroad catalog (/uni-abroad).

import 'package:admity/core/theme/app_colors.dart';
import 'package:admity/core/theme/app_tokens.dart';
import 'package:admity/shared/widgets/app_card.dart';
import 'package:admity/shared/widgets/app_scaffold.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

// ── Screen ─────────────────────────────────────────────────────────────────────

/// Hub screen for the "Вузы" tab.
///
/// Presents two destination cards:
/// - "Вузы Казахстана" — navigates to [/uni-kz].
/// - "Вузы за рубежом" — navigates to [/uni-abroad].
///
/// Layout is a SafeArea > SingleChildScrollView > Column(mainAxisSize: .min)
/// per the CLAUDE.md layout rule to avoid swallowed infinite-height errors.
class UniversitiesHubScreen extends StatelessWidget {
  /// Creates the universities hub screen.
  const UniversitiesHubScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final tokens =
        Theme.of(context).extension<AppTokens>() ?? AppTokens.defaults();

    return AppScaffold(
      body: SingleChildScrollView(
        padding: EdgeInsets.symmetric(
          horizontal: tokens.screenPadding,
          vertical: tokens.gapXl,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Вузы',
              style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                color: AppColors.ink,
              ),
            ),
            SizedBox(height: tokens.gapXs),
            Text(
              'Выбери, какие вузы хочешь изучить',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: AppColors.inkSecondary,
              ),
            ),
            SizedBox(height: tokens.gapXxl),
            _HubCard(
              title: 'Вузы Казахстана',
              subtitle: 'Каталог 88+ вузов с конкурсными баллами и ГОП',
              icon: Icons.account_balance_rounded,
              iconColor: AppColors.primary,
              gradientColors: const [Color(0xFF4255FF), Color(0xFF6E8BFF)],
              onTap: () => context.push('/uni-kz'),
            ),
            SizedBox(height: tokens.gapLg),
            _HubCard(
              title: 'Вузы за рубежом',
              subtitle:
                  'Топ мировые университеты с финансовой помощью для иностранцев',
              icon: Icons.public_rounded,
              iconColor: AppColors.goldKey,
              gradientColors: const [Color(0xFFFFB020), Color(0xFFFF7BC4)],
              onTap: () => context.push('/uni-abroad'),
            ),
            SizedBox(height: tokens.gapXl),
          ],
        ),
      ),
    );
  }
}

// ── Hub card ───────────────────────────────────────────────────────────────────

/// A large tappable destination card used on the [UniversitiesHubScreen].
class _HubCard extends StatelessWidget {
  const _HubCard({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.iconColor,
    required this.gradientColors,
    required this.onTap,
  });

  final String title;
  final String subtitle;
  final IconData icon;
  final Color iconColor;
  final List<Color> gradientColors;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final tokens =
        Theme.of(context).extension<AppTokens>() ?? AppTokens.defaults();

    return AppCard(
      onTap: onTap,
      animateIn: true,
      padding: EdgeInsets.zero,
      child: Stack(
        children: [
          // Decorative gradient strip at the top of the card.
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            height: 6,
            child: DecoratedBox(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.vertical(
                  top: Radius.circular(tokens.radiusLg),
                ),
                gradient: LinearGradient(colors: gradientColors),
              ),
            ),
          ),
          Padding(
            padding: EdgeInsets.fromLTRB(
              tokens.cardPadding,
              tokens.cardPadding + 6,
              tokens.cardPadding,
              tokens.cardPadding,
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Icon circle.
                Container(
                  width: 52,
                  height: 52,
                  decoration: BoxDecoration(
                    color: iconColor.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(tokens.radiusMd),
                  ),
                  child: Icon(icon, color: iconColor, size: 28),
                ),
                SizedBox(width: tokens.gapMd),
                Expanded(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          color: AppColors.ink,
                        ),
                      ),
                      SizedBox(height: tokens.gapXs),
                      Text(
                        subtitle,
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: AppColors.inkSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(width: tokens.gapSm),
                const Icon(
                  Icons.arrow_forward_rounded,
                  color: AppColors.primary,
                  size: 20,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
