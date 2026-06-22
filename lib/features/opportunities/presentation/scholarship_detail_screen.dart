import 'package:admity/core/theme/app_colors.dart';
import 'package:admity/core/theme/app_tokens.dart';
import 'package:admity/features/opportunities/data/opportunity_seed.dart';
import 'package:admity/features/opportunities/domain/opportunity_models.dart';
import 'package:admity/shared/widgets/app_card.dart';
import 'package:admity/shared/widgets/app_scaffold.dart';
import 'package:admity/shared/widgets/featured_button.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

/// Full-screen scholarship detail screen.
///
/// Accepts the scholarship [scholarshipId] via go_router path parameter.
/// Layout: AppScaffold with fixed AppBar + scrollable body.
/// Accent: AppColors.primary (section headings).
/// FeaturedButton "Подать заявку" — featured CTA.
class ScholarshipDetailScreen extends StatelessWidget {
  const ScholarshipDetailScreen({required this.scholarshipId, super.key});

  final String scholarshipId;

  @override
  Widget build(BuildContext context) {
    final scholarship = seedScholarships
        .where((s) => s.id == scholarshipId)
        .firstOrNull;

    if (scholarship == null) {
      return AppScaffold(
        appBar: AppBar(
          backgroundColor: AppColors.white,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_rounded, color: AppColors.ink),
            onPressed: () => context.go('/opportunities'),
          ),
          title: Text(
            'Стипендия',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              color: AppColors.ink,
            ),
          ),
          elevation: 0,
        ),
        body: const Center(
          child: Text('Стипендия не найдена'),
        ),
      );
    }

    return AppScaffold(
      appBar: AppBar(
        backgroundColor: AppColors.white,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded, color: AppColors.ink),
          onPressed: () => context.go('/opportunities'),
        ),
        title: Text(
          scholarship.name,
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
            color: AppColors.ink,
          ),
        ),
        elevation: 0,
        surfaceTintColor: AppColors.white,
      ),
      body: _ScholarshipDetailBody(scholarship: scholarship),
    );
  }
}

class _ScholarshipDetailBody extends StatelessWidget {
  const _ScholarshipDetailBody({required this.scholarship});

  final Scholarship scholarship;

  @override
  Widget build(BuildContext context) {
    final tokens =
        Theme.of(context).extension<AppTokens>() ?? AppTokens.defaults();

    return SingleChildScrollView(
      padding: EdgeInsets.all(tokens.screenPadding),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Meta row ─────────────────────────────────────────────────────
          Wrap(
            spacing: tokens.gapSm,
            runSpacing: tokens.gapSm,
            children: [
              _MetaChip(
                icon: Icons.location_on_outlined,
                label: scholarship.city,
              ),
              _MetaChip(
                icon: Icons.school_outlined,
                label: academicFieldLabel(scholarship.field),
              ),
              _MetaChip(
                icon: Icons.verified_outlined,
                label: accessibilityLabel(scholarship.accessibility),
                color: _accessibilityColor(scholarship.accessibility),
              ),
            ],
          ),
          SizedBox(height: tokens.gapXl),

          // ── Coverage ─────────────────────────────────────────────────────
          _SectionCard(
            icon: Icons.monetization_on_outlined,
            title: 'Что покрывает',
            accentColor: AppColors.successGreen,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  scholarship.coverageLabel,
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    color: AppColors.successGreen,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                if (scholarship.priceLabel != null) ...[
                  SizedBox(height: tokens.gapXs),
                  Text(
                    scholarship.priceLabel!,
                    style: Theme.of(
                      context,
                    ).textTheme.labelLarge?.copyWith(color: AppColors.goldKey),
                  ),
                ],
                SizedBox(height: tokens.gapMd),
                Text(
                  scholarship.whatItCovers,
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    color: AppColors.inkSecondary,
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: tokens.gapMd),

          // ── How to get ───────────────────────────────────────────────────
          _SectionCard(
            icon: Icons.route_outlined,
            title: 'Как получить',
            accentColor: AppColors.primary,
            child: Text(
              scholarship.howToGet,
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                color: AppColors.inkSecondary,
              ),
            ),
          ),
          SizedBox(height: tokens.gapMd),

          // ── Required stats ───────────────────────────────────────────────
          _SectionCard(
            icon: Icons.bar_chart_rounded,
            title: 'Нужные показатели',
            accentColor: AppColors.primary,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  scholarship.requiredStats,
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    color: AppColors.ink,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                SizedBox(height: tokens.gapMd),
                Text(
                  'Как их добить:',
                  style: Theme.of(context).textTheme.labelLarge?.copyWith(
                    color: AppColors.ink,
                  ),
                ),
                SizedBox(height: tokens.gapSm),
                Text(
                  scholarship.howToBoostStats,
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    color: AppColors.inkSecondary,
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: tokens.gapMd),

          // ── Required documents ───────────────────────────────────────────
          _SectionCard(
            icon: Icons.description_outlined,
            title: 'Требуемые документы',
            accentColor: AppColors.goldKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: scholarship.requiredDocuments
                  .map(
                    (doc) => Padding(
                      padding: EdgeInsets.only(bottom: tokens.gapSm),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Icon(
                            Icons.check_circle_outline_rounded,
                            size: 16,
                            color: AppColors.successGreen,
                          ),
                          SizedBox(width: tokens.gapSm),
                          Expanded(
                            child: Text(
                              doc,
                              style: Theme.of(context).textTheme.bodyLarge
                                  ?.copyWith(color: AppColors.ink),
                            ),
                          ),
                        ],
                      ),
                    ),
                  )
                  .toList(),
            ),
          ),
          SizedBox(height: tokens.gapXxl),

          // ── Featured CTA — Подать заявку ──────────────────────────────────
          FeaturedButton(
            label: 'Подать заявку',
            onPressed: () => context.go(
              '/opportunities/scholarship/${scholarship.id}/apply',
            ),
          ),
          SizedBox(height: tokens.gapXl),
        ],
      ),
    );
  }

  Color _accessibilityColor(Accessibility a) {
    switch (a) {
      case Accessibility.easy:
        return AppColors.successGreen;
      case Accessibility.medium:
        return AppColors.goldKey;
      case Accessibility.hard:
        return AppColors.errorRed;
    }
  }
}

class _SectionCard extends StatelessWidget {
  const _SectionCard({
    required this.icon,
    required this.title,
    required this.accentColor,
    required this.child,
  });

  final IconData icon;
  final String title;
  final Color accentColor;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final tokens =
        Theme.of(context).extension<AppTokens>() ?? AppTokens.defaults();

    return AppCard(
      padding: EdgeInsets.zero,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: EdgeInsets.all(tokens.cardPadding),
            child: Row(
              children: [
                Icon(icon, size: 18, color: accentColor),
                SizedBox(width: tokens.gapSm),
                Text(
                  title,
                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    color: AppColors.ink,
                  ),
                ),
              ],
            ),
          ),
          const Divider(height: 1, color: AppColors.border),
          Padding(
            padding: EdgeInsets.all(tokens.cardPadding),
            child: child,
          ),
        ],
      ),
    );
  }
}

class _MetaChip extends StatelessWidget {
  const _MetaChip({
    required this.icon,
    required this.label,
    this.color = AppColors.inkSecondary,
  });

  final IconData icon;
  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final tokens =
        Theme.of(context).extension<AppTokens>() ?? AppTokens.defaults();

    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: tokens.gapMd,
        vertical: tokens.gapXs,
      ),
      decoration: BoxDecoration(
        color: AppColors.surfaceTint,
        borderRadius: BorderRadius.circular(tokens.radiusSm),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: color),
          SizedBox(width: tokens.gapXs),
          Text(
            label,
            style: Theme.of(
              context,
            ).textTheme.labelLarge?.copyWith(color: color),
          ),
        ],
      ),
    );
  }
}
