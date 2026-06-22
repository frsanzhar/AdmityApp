import 'package:admity/core/theme/app_colors.dart';
import 'package:admity/core/theme/app_tokens.dart';
import 'package:admity/features/opportunities/data/opportunity_seed.dart';
import 'package:admity/features/opportunities/domain/opportunity_models.dart';
import 'package:admity/shared/widgets/app_card.dart';
import 'package:admity/shared/widgets/app_scaffold.dart';
import 'package:admity/shared/widgets/featured_button.dart';
import 'package:admity/shared/widgets/mascot_slot.dart';
import 'package:admity/shared/widgets/progress_ring.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';

/// Full-screen detail for a Университет.
///
/// Shows: about/mission, city+field, programmes, acceptance rate (ProgressRing),
/// requirements, cost + scholarships, step-by-step admission guide ("как поступить").
/// Featured CTA: "Узнать о поступлении" (scrolls to the steps section / highlights it).
///
/// Layout: AppScaffold + fixed AppBar + SafeArea > SingleChildScrollView > Column(.min).
/// Accent: AppColors.primary.  FeaturedButton for the admission CTA.
class UniversityDetailScreen extends StatelessWidget {
  const UniversityDetailScreen({required this.universityId, super.key});

  final String universityId;

  @override
  Widget build(BuildContext context) {
    final university = seedUniversities
        .where((u) => u.id == universityId)
        .firstOrNull;

    if (university == null) {
      return AppScaffold(
        appBar: AppBar(
          backgroundColor: AppColors.white,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_rounded, color: AppColors.ink),
            onPressed: () => context.go('/opportunities'),
          ),
          title: Text(
            'Университет',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              color: AppColors.ink,
            ),
          ),
          elevation: 0,
        ),
        body: const Center(
          child: Text('Университет не найден'),
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
          university.name,
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
            color: AppColors.ink,
          ),
          overflow: TextOverflow.ellipsis,
        ),
        elevation: 0,
        surfaceTintColor: AppColors.white,
      ),
      body: _UniversityDetailBody(university: university),
    );
  }
}

class _UniversityDetailBody extends StatelessWidget {
  const _UniversityDetailBody({required this.university});

  final University university;

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
          // ── Hero row: mascot slot + meta chips ───────────────────────────────
          Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // TODO(mascot): Replace with real university illustration.
                  const MascotSlot(size: 72, tag: 'university'),
                  SizedBox(width: tokens.gapLg),
                  Expanded(
                    child: Wrap(
                      spacing: tokens.gapSm,
                      runSpacing: tokens.gapSm,
                      children: [
                        _MetaChip(
                          icon: Icons.location_on_outlined,
                          label: university.city,
                        ),
                        _MetaChip(
                          icon: Icons.school_outlined,
                          label: academicFieldLabel(university.field),
                        ),
                        _MetaChip(
                          icon: Icons.verified_outlined,
                          label: accessibilityLabel(university.accessibility),
                          color: _accessibilityColor(university.accessibility),
                        ),
                      ],
                    ),
                  ),
                ],
              )
              .animate()
              .fadeIn(duration: const Duration(milliseconds: 300))
              .slideY(begin: 0.05, end: 0),
          SizedBox(height: tokens.gapXl),

          // ── About / mission ───────────────────────────────────────────────────
          if (university.mission != null)
            _SectionCard(
                  icon: Icons.info_outline_rounded,
                  title: 'О университете',
                  accentColor: AppColors.primary,
                  child: Text(
                    university.mission!,
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      color: AppColors.inkSecondary,
                    ),
                  ),
                )
                .animate()
                .fadeIn(
                  delay: const Duration(milliseconds: 80),
                  duration: const Duration(milliseconds: 280),
                )
                .slideY(begin: 0.04, end: 0),
          if (university.mission != null) SizedBox(height: tokens.gapMd),

          // ── Programmes ───────────────────────────────────────────────────────
          if (university.programs != null && university.programs!.isNotEmpty)
            _SectionCard(
                  icon: Icons.menu_book_rounded,
                  title: 'Направления',
                  accentColor: AppColors.primary,
                  child: Wrap(
                    spacing: tokens.gapSm,
                    runSpacing: tokens.gapSm,
                    children: university.programs!
                        .map(
                          (p) => Container(
                            padding: EdgeInsets.symmetric(
                              horizontal: tokens.gapMd,
                              vertical: tokens.gapXs,
                            ),
                            decoration: BoxDecoration(
                              color: AppColors.primary.withValues(alpha: 0.08),
                              borderRadius: BorderRadius.circular(
                                tokens.radiusSm,
                              ),
                            ),
                            child: Text(
                              p,
                              style: Theme.of(context).textTheme.labelLarge
                                  ?.copyWith(color: AppColors.primary),
                            ),
                          ),
                        )
                        .toList(),
                  ),
                )
                .animate()
                .fadeIn(
                  delay: const Duration(milliseconds: 120),
                  duration: const Duration(milliseconds: 280),
                )
                .slideY(begin: 0.04, end: 0),
          if (university.programs != null && university.programs!.isNotEmpty)
            SizedBox(height: tokens.gapMd),

          // ── Acceptance rate + ENT threshold ─────────────────────────────────
          _SectionCard(
                icon: Icons.bar_chart_rounded,
                title: 'Шансы поступления',
                accentColor: AppColors.successGreen,
                child: Row(
                  children: [
                    // Acceptance ring — honest, never inflated
                    if (university.acceptanceRate != null)
                      ProgressRing(
                        progress: university.acceptanceRate!,
                        size: 72,
                        strokeWidth: 7,
                        progressColor: AppColors.successGreen,
                        child: Text(
                          '${(university.acceptanceRate! * 100).round()}%',
                          style: Theme.of(context).textTheme.labelLarge
                              ?.copyWith(
                                color: AppColors.ink,
                                fontWeight: FontWeight.w700,
                              ),
                        ),
                      ),
                    if (university.acceptanceRate != null)
                      SizedBox(width: tokens.gapLg),
                    Expanded(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          if (university.acceptanceRate != null)
                            Text(
                              'Уровень приёма — реалистичная оценка',
                              style: Theme.of(context).textTheme.bodySmall
                                  ?.copyWith(color: AppColors.inkSecondary),
                            ),
                          if (university.acceptanceRate != null)
                            SizedBox(height: tokens.gapSm),
                          Container(
                            padding: EdgeInsets.symmetric(
                              horizontal: tokens.gapMd,
                              vertical: tokens.gapSm,
                            ),
                            decoration: BoxDecoration(
                              color: AppColors.surfaceTint,
                              borderRadius: BorderRadius.circular(
                                tokens.radiusSm,
                              ),
                            ),
                            child: Text(
                              'ЕНТ ≥ ${university.entThreshold} баллов',
                              style: Theme.of(context).textTheme.labelLarge
                                  ?.copyWith(color: AppColors.ink),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              )
              .animate()
              .fadeIn(
                delay: const Duration(milliseconds: 160),
                duration: const Duration(milliseconds: 280),
              )
              .slideY(begin: 0.04, end: 0),
          SizedBox(height: tokens.gapMd),

          // ── Requirements ─────────────────────────────────────────────────────
          if (university.requirements != null)
            _SectionCard(
                  icon: Icons.checklist_rounded,
                  title: 'Требования',
                  accentColor: AppColors.goldKey,
                  child: Text(
                    university.requirements!,
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      color: AppColors.inkSecondary,
                    ),
                  ),
                )
                .animate()
                .fadeIn(
                  delay: const Duration(milliseconds: 200),
                  duration: const Duration(milliseconds: 280),
                )
                .slideY(begin: 0.04, end: 0),
          if (university.requirements != null) SizedBox(height: tokens.gapMd),

          // ── Cost + scholarships ───────────────────────────────────────────────
          _SectionCard(
                icon: Icons.monetization_on_outlined,
                title: 'Стоимость и стипендии',
                accentColor: AppColors.successGreen,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      university.tuitionLabel,
                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        color: AppColors.successGreen,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    if (university.scholarshipInfo != null) ...[
                      SizedBox(height: tokens.gapMd),
                      Text(
                        university.scholarshipInfo!,
                        style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                          color: AppColors.inkSecondary,
                        ),
                      ),
                    ],
                  ],
                ),
              )
              .animate()
              .fadeIn(
                delay: const Duration(milliseconds: 240),
                duration: const Duration(milliseconds: 280),
              )
              .slideY(begin: 0.04, end: 0),
          SizedBox(height: tokens.gapMd),

          // ── Admission steps ───────────────────────────────────────────────────
          if (university.admissionSteps != null &&
              university.admissionSteps!.isNotEmpty)
            _SectionCard(
                  icon: Icons.route_outlined,
                  title: 'Как поступить',
                  accentColor: AppColors.primary,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: university.admissionSteps!
                        .asMap()
                        .entries
                        .map(
                          (entry) => Padding(
                            padding: EdgeInsets.only(bottom: tokens.gapMd),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Container(
                                  width: 24,
                                  height: 24,
                                  decoration: const BoxDecoration(
                                    color: AppColors.primary,
                                    shape: BoxShape.circle,
                                  ),
                                  alignment: Alignment.center,
                                  child: Text(
                                    '${entry.key + 1}',
                                    style: const TextStyle(
                                      color: AppColors.white,
                                      fontSize: 12,
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                ),
                                SizedBox(width: tokens.gapSm),
                                Expanded(
                                  child: Padding(
                                    padding: const EdgeInsets.only(top: 3),
                                    child: Text(
                                      entry.value,
                                      style: Theme.of(context)
                                          .textTheme
                                          .bodyLarge
                                          ?.copyWith(color: AppColors.ink),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        )
                        .toList(),
                  ),
                )
                .animate()
                .fadeIn(
                  delay: const Duration(milliseconds: 280),
                  duration: const Duration(milliseconds: 280),
                )
                .slideY(begin: 0.04, end: 0),
          if (university.admissionSteps != null &&
              university.admissionSteps!.isNotEmpty)
            SizedBox(height: tokens.gapXxl),

          // ── Featured CTA ─────────────────────────────────────────────────────
          if (university.websiteLabel != null)
            FeaturedButton(
              label: 'Открыть сайт: ${university.websiteLabel}',
              icon: const Icon(
                Icons.open_in_new_rounded,
                color: AppColors.white,
                size: 18,
              ),
              onPressed: () {
                // TODO(nav): launch url(university.websiteLabel) when url_launcher is available.
              },
            ).animate().fadeIn(
              delay: const Duration(milliseconds: 320),
              duration: const Duration(milliseconds: 280),
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

// ── Shared section card ────────────────────────────────────────────────────────

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

// ── Meta chip ─────────────────────────────────────────────────────────────────

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
