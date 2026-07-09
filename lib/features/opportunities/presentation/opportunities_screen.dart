import 'dart:async';

import 'package:admity/core/theme/app_colors.dart';
import 'package:admity/core/theme/app_tokens.dart';
import 'package:admity/core/utils/external_link.dart';
import 'package:admity/features/opportunities/data/opportunity_seed.dart';
import 'package:admity/features/opportunities/domain/opportunity_models.dart';
import 'package:admity/features/opportunities/domain/study_material.dart';
import 'package:admity/features/opportunities/presentation/opportunities_providers.dart';
import 'package:admity/features/opportunities/presentation/study_materials_provider.dart';
import 'package:admity/shared/widgets/app_card.dart';
import 'package:admity/shared/widgets/app_scaffold.dart';
import 'package:admity/shared/widgets/primary_button.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

// ── Screen ─────────────────────────────────────────────────────────────────────

/// Opportunities screen — Scholarships + Events + Project Ideas
/// (DESIGN_SYSTEM.md §7.6).
/// Университеты pulled out into its own /universities route.
///
/// Layout: AppScaffold > Column > segmented tabs header + Expanded scroll body.
/// Accent: AppColors.primary (tab indicator + chip borders).
class OpportunitiesScreen extends ConsumerWidget {
  const OpportunitiesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tokens =
        Theme.of(context).extension<AppTokens>() ?? AppTokens.defaults();
    final section = ref.watch(opportunitiesSectionProvider);
    final filter = ref.watch(opportunityFilterProvider);

    return AppScaffold(
      body: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // ── Header ────────────────────────────────────────────────────────
          _OpportunitiesHeader(
            section: section,
            filter: filter,
            tokens: tokens,
          ),
          // ── Content (scrollable) ──────────────────────────────────────────
          Expanded(
            child: _OpportunitiesBody(section: section, tokens: tokens),
          ),
        ],
      ),
    );
  }
}

// ── Header (section tabs + filter row) ────────────────────────────────────────

class _OpportunitiesHeader extends ConsumerWidget {
  const _OpportunitiesHeader({
    required this.section,
    required this.filter,
    required this.tokens,
  });

  final OpportunitySection section;
  final OpportunityFilter filter;
  final AppTokens tokens;

  // Университеты pulled out into its own /universities screen (DESIGN_SYSTEM §7.6).
  static const List<(OpportunitySection, String)> _sections = [
    (OpportunitySection.scholarships, 'Стипендии'),
    (OpportunitySection.events, 'Мероприятия'),
    (OpportunitySection.projectIdeas, 'Идеи проектов'),
    (OpportunitySection.materials, 'Материалы'),
  ];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final notifier = ref.read(opportunitiesSectionProvider.notifier);
    final showFilter = section == OpportunitySection.scholarships;

    return ColoredBox(
      color: AppColors.white,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Title
          Padding(
            padding: EdgeInsets.fromLTRB(
              tokens.screenPadding,
              tokens.gapLg,
              tokens.screenPadding,
              tokens.gapMd,
            ),
            child: Align(
              alignment: Alignment.centerLeft,
              child: Text(
                'Возможности',
                style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                  color: AppColors.ink,
                ),
              ),
            ),
          ),
          // Section tabs
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: EdgeInsets.symmetric(horizontal: tokens.screenPadding),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: _sections.map((entry) {
                final (s, label) = entry;
                final isSelected = s == section;
                return GestureDetector(
                  onTap: () => notifier.switchToSection(s),
                  behavior: HitTestBehavior.opaque,
                  child: Padding(
                    padding: EdgeInsets.only(right: tokens.gapLg),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Padding(
                          padding: EdgeInsets.symmetric(vertical: tokens.gapSm),
                          child: Text(
                            label,
                            style: Theme.of(context).textTheme.labelLarge
                                ?.copyWith(
                                  color: isSelected
                                      ? AppColors.primary
                                      : AppColors.inkSecondary,
                                ),
                          ),
                        ),
                        AnimatedContainer(
                          duration: const Duration(milliseconds: 180),
                          height: 2,
                          width: 48,
                          decoration: BoxDecoration(
                            color: isSelected
                                ? AppColors.primary
                                : Colors.transparent,
                            borderRadius: BorderRadius.circular(1),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
          // Divider
          const Divider(height: 1, color: AppColors.border),
          // Filter row (scholarships only)
          if (showFilter) _FilterRow(filter: filter, tokens: tokens),
        ],
      ),
    );
  }
}

// ── Filter row ────────────────────────────────────────────────────────────────

class _FilterRow extends ConsumerWidget {
  const _FilterRow({required this.filter, required this.tokens});

  final OpportunityFilter filter;
  final AppTokens tokens;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final notifier = ref.read(opportunityFilterProvider.notifier);
    final hasFilter = !filter.isEmpty;

    return Padding(
      padding: EdgeInsets.symmetric(
        horizontal: tokens.screenPadding,
        vertical: tokens.gapSm,
      ),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            _FilterChip(
              label: filter.city ?? 'Город',
              isActive: filter.city != null,
              onTap: () => _showCityPicker(context, ref),
            ),
            SizedBox(width: tokens.gapSm),
            _FilterChip(
              label: filter.field != null
                  ? academicFieldLabel(filter.field!)
                  : 'Направление',
              isActive: filter.field != null,
              onTap: () => _showFieldPicker(context, ref),
            ),
            SizedBox(width: tokens.gapSm),
            _FilterChip(
              label: filter.accessibility != null
                  ? accessibilityLabel(filter.accessibility!)
                  : 'Доступность',
              isActive: filter.accessibility != null,
              onTap: () => _showAccessibilityPicker(context, ref),
            ),
            if (hasFilter) ...[
              SizedBox(width: tokens.gapSm),
              GestureDetector(
                onTap: notifier.clearAll,
                child: Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: tokens.gapMd,
                    vertical: tokens.gapXs,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.errorRed.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(tokens.radiusSm),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(
                        Icons.close_rounded,
                        size: 14,
                        color: AppColors.errorRed,
                      ),
                      SizedBox(width: tokens.gapXs),
                      Text(
                        'Сбросить',
                        style: Theme.of(context).textTheme.labelLarge?.copyWith(
                          color: AppColors.errorRed,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  void _showCityPicker(BuildContext context, WidgetRef ref) {
    final cities = [
      ...{...seedScholarships.map((s) => s.city)},
    ]..sort();

    unawaited(
      showModalBottomSheet<void>(
        context: context,
        builder: (_) => _PickerSheet(
          title: 'Выбрать город',
          items: cities,
          selected: ref.read(opportunityFilterProvider).city,
          onSelect: (v) =>
              ref.read(opportunityFilterProvider.notifier).setCity(v),
          onClear: () =>
              ref.read(opportunityFilterProvider.notifier).setCity(null),
        ),
      ),
    );
  }

  void _showFieldPicker(BuildContext context, WidgetRef ref) {
    unawaited(
      showModalBottomSheet<void>(
        context: context,
        builder: (_) => _PickerSheet(
          title: 'Выбрать направление',
          items: AcademicField.values.map(academicFieldLabel).toList(),
          selected: ref.read(opportunityFilterProvider).field != null
              ? academicFieldLabel(ref.read(opportunityFilterProvider).field!)
              : null,
          onSelect: (v) {
            final field = AcademicField.values.firstWhere(
              (f) => academicFieldLabel(f) == v,
            );
            ref.read(opportunityFilterProvider.notifier).setField(field);
          },
          onClear: () =>
              ref.read(opportunityFilterProvider.notifier).setField(null),
        ),
      ),
    );
  }

  void _showAccessibilityPicker(BuildContext context, WidgetRef ref) {
    unawaited(
      showModalBottomSheet<void>(
        context: context,
        builder: (_) => _PickerSheet(
          title: 'Выбрать доступность',
          items: Accessibility.values.map(accessibilityLabel).toList(),
          selected: ref.read(opportunityFilterProvider).accessibility != null
              ? accessibilityLabel(
                  ref.read(opportunityFilterProvider).accessibility!,
                )
              : null,
          onSelect: (v) {
            final acc = Accessibility.values.firstWhere(
              (a) => accessibilityLabel(a) == v,
            );
            ref.read(opportunityFilterProvider.notifier).setAccessibility(acc);
          },
          onClear: () => ref
              .read(opportunityFilterProvider.notifier)
              .setAccessibility(null),
        ),
      ),
    );
  }
}

class _FilterChip extends StatelessWidget {
  const _FilterChip({
    required this.label,
    required this.isActive,
    required this.onTap,
  });

  final String label;
  final bool isActive;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final tokens =
        Theme.of(context).extension<AppTokens>() ?? AppTokens.defaults();
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(
          horizontal: tokens.gapMd,
          vertical: tokens.gapXs,
        ),
        decoration: BoxDecoration(
          color: isActive
              ? AppColors.primary.withValues(alpha: 0.08)
              : AppColors.surfaceTint,
          borderRadius: BorderRadius.circular(tokens.radiusSm),
          border: Border.all(
            color: isActive ? AppColors.primary : AppColors.border,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              label,
              style: Theme.of(context).textTheme.labelLarge?.copyWith(
                color: isActive ? AppColors.primary : AppColors.inkSecondary,
              ),
            ),
            SizedBox(width: tokens.gapXs),
            Icon(
              Icons.keyboard_arrow_down_rounded,
              size: 16,
              color: isActive ? AppColors.primary : AppColors.inkSecondary,
            ),
          ],
        ),
      ),
    );
  }
}

// ── Picker bottom sheet ────────────────────────────────────────────────────────

class _PickerSheet extends StatelessWidget {
  const _PickerSheet({
    required this.title,
    required this.items,
    required this.onSelect,
    required this.onClear,
    this.selected,
  });

  final String title;
  final List<String> items;
  final String? selected;
  final ValueChanged<String> onSelect;
  final VoidCallback onClear;

  @override
  Widget build(BuildContext context) {
    final tokens =
        Theme.of(context).extension<AppTokens>() ?? AppTokens.defaults();
    return SafeArea(
      child: Padding(
        padding: EdgeInsets.all(tokens.screenPadding),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              title,
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                color: AppColors.ink,
              ),
            ),
            SizedBox(height: tokens.gapLg),
            if (selected != null)
              PrimaryButton(
                label: 'Сбросить фильтр',
                onPressed: () {
                  Navigator.of(context).pop();
                  onClear();
                },
              ),
            if (selected != null) SizedBox(height: tokens.gapMd),
            ...items.map((item) {
              final isSelected = item == selected;
              return ListTile(
                contentPadding: EdgeInsets.symmetric(horizontal: tokens.gapSm),
                title: Text(
                  item,
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    color: isSelected ? AppColors.primary : AppColors.ink,
                    fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                  ),
                ),
                trailing: isSelected
                    ? const Icon(
                        Icons.check_rounded,
                        color: AppColors.primary,
                        size: 20,
                      )
                    : null,
                onTap: () {
                  Navigator.of(context).pop();
                  onSelect(item);
                },
              );
            }),
            SizedBox(height: tokens.gapMd),
          ],
        ),
      ),
    );
  }
}

// ── Body (content per section) ────────────────────────────────────────────────

class _OpportunitiesBody extends ConsumerWidget {
  const _OpportunitiesBody({
    required this.section,
    required this.tokens,
  });

  final OpportunitySection section;
  final AppTokens tokens;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // AnimatedSwitcher provides a fade+slide transition when section changes.
    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 220),
      switchInCurve: Curves.easeOut,
      switchOutCurve: Curves.easeIn,
      transitionBuilder: (child, animation) {
        return FadeTransition(
          opacity: animation,
          child: SlideTransition(
            position: Tween<Offset>(
              begin: const Offset(0, 0.04),
              end: Offset.zero,
            ).animate(animation),
            child: child,
          ),
        );
      },
      child: KeyedSubtree(
        key: ValueKey(section),
        // Университеты tab removed — lives at /universities now.
        child: switch (section) {
          OpportunitySection.scholarships => _ScholarshipsTab(tokens: tokens),
          // universities enum value unused in this screen; fall back to scholarships.
          OpportunitySection.universities => _ScholarshipsTab(tokens: tokens),
          OpportunitySection.events => _EventsTab(tokens: tokens),
          OpportunitySection.projectIdeas => _ProjectIdeasTab(tokens: tokens),
          OpportunitySection.materials => _MaterialsTab(tokens: tokens),
        },
      ),
    );
  }
}

// ── Scholarships tab ──────────────────────────────────────────────────────────

class _ScholarshipsTab extends ConsumerWidget {
  const _ScholarshipsTab({required this.tokens});

  final AppTokens tokens;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final scholarships = ref.watch(filteredScholarshipsProvider);

    if (scholarships.isEmpty) {
      return const _EmptyState(message: 'Нет стипендий по выбранным фильтрам');
    }

    return ListView.separated(
      padding: EdgeInsets.all(tokens.screenPadding),
      itemCount: scholarships.length,
      separatorBuilder: (context, i) => SizedBox(height: tokens.gapMd),
      itemBuilder: (context, i) {
        final s = scholarships[i];
        return _ScholarshipCard(
              scholarship: s,
              onTap: () => context.go('/opportunities/scholarship/${s.id}'),
            )
            .animate()
            .fadeIn(
              delay: Duration(milliseconds: 60 * i),
              duration: const Duration(milliseconds: 280),
              curve: Curves.easeOut,
            )
            .slideY(
              begin: 0.06,
              end: 0,
              delay: Duration(milliseconds: 60 * i),
              duration: const Duration(milliseconds: 280),
              curve: Curves.easeOut,
            );
      },
    );
  }
}

class _ScholarshipCard extends StatelessWidget {
  const _ScholarshipCard({
    required this.scholarship,
    required this.onTap,
  });

  final Scholarship scholarship;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final tokens =
        Theme.of(context).extension<AppTokens>() ?? AppTokens.defaults();

    return AppCard(
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  scholarship.name,
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    color: AppColors.ink,
                  ),
                ),
              ),
              _AccessibilityBadge(accessibility: scholarship.accessibility),
            ],
          ),
          SizedBox(height: tokens.gapSm),
          Row(
            children: [
              const Icon(
                Icons.location_on_outlined,
                size: 14,
                color: AppColors.inkSecondary,
              ),
              SizedBox(width: tokens.gapXs),
              Text(
                scholarship.city,
                style: Theme.of(context).textTheme.bodySmall,
              ),
              SizedBox(width: tokens.gapMd),
              const Icon(
                Icons.school_outlined,
                size: 14,
                color: AppColors.inkSecondary,
              ),
              SizedBox(width: tokens.gapXs),
              Text(
                academicFieldLabel(scholarship.field),
                style: Theme.of(context).textTheme.bodySmall,
              ),
            ],
          ),
          SizedBox(height: tokens.gapSm),
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
              style: Theme.of(context).textTheme.labelLarge?.copyWith(
                color: AppColors.goldKey,
              ),
            ),
          ],
          SizedBox(height: tokens.gapMd),
          Row(
            children: [
              const Icon(
                Icons.arrow_forward_rounded,
                size: 16,
                color: AppColors.primary,
              ),
              SizedBox(width: tokens.gapXs),
              Text(
                'Подробнее',
                style: Theme.of(context).textTheme.labelLarge?.copyWith(
                  color: AppColors.primary,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// ── Events tab ────────────────────────────────────────────────────────────────

class _EventsTab extends ConsumerWidget {
  const _EventsTab({required this.tokens});

  final AppTokens tokens;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final result = ref.watch(localEventsProvider);
    final city = result.profileCity;
    final events = result.events;

    return ListView(
      padding: EdgeInsets.all(tokens.screenPadding),
      children: [
        // ── Context banner ──────────────────────────────────────────────────
        if (city != null)
          _ContextBanner(
            icon: Icons.location_on_rounded,
            iconColor: AppColors.primary,
            message: 'рядом с тобой — $city',
          ).animate().fadeIn(duration: const Duration(milliseconds: 300))
        else
          const _ContextBanner(
            icon: Icons.public_rounded,
            iconColor: AppColors.inkSecondary,
            message:
                'Укажи свой город в профиле, чтобы видеть мероприятия рядом',
          ).animate().fadeIn(duration: const Duration(milliseconds: 300)),
        SizedBox(height: tokens.gapMd),
        // ── Event cards (staggered) ─────────────────────────────────────────
        ...events.asMap().entries.map((entry) {
          final i = entry.key;
          final e = entry.value;
          return Padding(
            padding: EdgeInsets.only(bottom: tokens.gapMd),
            child:
                _EventCard(
                      event: e,
                      isLocal:
                          city != null &&
                          e.city.toLowerCase().contains(city.toLowerCase()),
                      onTap: () => context.go('/opportunities/event/${e.id}'),
                    )
                    .animate()
                    .fadeIn(
                      delay: Duration(milliseconds: 60 * i),
                      duration: const Duration(milliseconds: 280),
                      curve: Curves.easeOut,
                    )
                    .slideY(
                      begin: 0.06,
                      end: 0,
                      delay: Duration(milliseconds: 60 * i),
                      duration: const Duration(milliseconds: 280),
                      curve: Curves.easeOut,
                    ),
          );
        }),
      ],
    );
  }
}

class _EventCard extends StatelessWidget {
  const _EventCard({
    required this.event,
    this.isLocal = false,
    this.onTap,
  });

  final OpportunityEvent event;

  /// Whether this event is in the student's city — shows a "Рядом" badge.
  final bool isLocal;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final tokens =
        Theme.of(context).extension<AppTokens>() ?? AppTokens.defaults();

    return AppCard(
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Text(
                  event.title,
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    color: AppColors.ink,
                  ),
                ),
              ),
              if (isLocal) ...[
                SizedBox(width: tokens.gapSm),
                _LocalBadge(),
              ],
            ],
          ),
          SizedBox(height: tokens.gapSm),
          Row(
            children: [
              const Icon(
                Icons.calendar_today_outlined,
                size: 14,
                color: AppColors.primary,
              ),
              SizedBox(width: tokens.gapXs),
              Text(
                event.dateLabel,
                style: Theme.of(context).textTheme.labelLarge?.copyWith(
                  color: AppColors.primary,
                ),
              ),
              SizedBox(width: tokens.gapMd),
              const Icon(
                Icons.location_on_outlined,
                size: 14,
                color: AppColors.inkSecondary,
              ),
              SizedBox(width: tokens.gapXs),
              Text(
                event.city,
                style: Theme.of(context).textTheme.bodySmall,
              ),
            ],
          ),
          SizedBox(height: tokens.gapSm),
          Text(
            event.description,
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
              color: AppColors.inkSecondary,
            ),
          ),
          SizedBox(height: tokens.gapMd),
          Row(
            children: [
              const Icon(
                Icons.arrow_forward_rounded,
                size: 16,
                color: AppColors.primary,
              ),
              SizedBox(width: tokens.gapXs),
              Text(
                'Подробнее',
                style: Theme.of(context).textTheme.labelLarge?.copyWith(
                  color: AppColors.primary,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _LocalBadge extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final tokens =
        Theme.of(context).extension<AppTokens>() ?? AppTokens.defaults();
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: tokens.gapSm,
        vertical: tokens.gapXs,
      ),
      decoration: BoxDecoration(
        color: AppColors.primary.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(tokens.radiusSm),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.near_me_rounded, size: 12, color: AppColors.primary),
          SizedBox(width: tokens.gapXs),
          Text(
            'Рядом',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: AppColors.primary,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

// ── Project ideas tab ─────────────────────────────────────────────────────────

class _ProjectIdeasTab extends ConsumerWidget {
  const _ProjectIdeasTab({required this.tokens});

  final AppTokens tokens;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final result = ref.watch(personalizedProjectIdeasProvider);
    final ideas = result.ideas;
    final interest = result.matchedInterest;
    final hasInterests = result.hasProfileInterests;

    return ListView(
      padding: EdgeInsets.all(tokens.screenPadding),
      children: [
        // ── Context banner ──────────────────────────────────────────────────
        if (interest != null)
          _ContextBanner(
            icon: Icons.interests_rounded,
            iconColor: AppColors.successGreen,
            message: 'по твоему интересу: $interest',
          ).animate().fadeIn(duration: const Duration(milliseconds: 300))
        else if (!hasInterests)
          const _ContextBanner(
            icon: Icons.lightbulb_outline_rounded,
            iconColor: AppColors.goldKey,
            message:
                'Добавь интересы в профиле — покажем идеи специально для тебя',
          ).animate().fadeIn(duration: const Duration(milliseconds: 300)),
        if (interest != null || !hasInterests) SizedBox(height: tokens.gapMd),
        // ── Idea cards (staggered) ──────────────────────────────────────────
        ...ideas.asMap().entries.map((entry) {
          final i = entry.key;
          final p = entry.value;
          return Padding(
            padding: EdgeInsets.only(bottom: tokens.gapMd),
            child:
                _ProjectIdeaCard(
                      idea: p,
                      onTap: () => context.go('/opportunities/idea/${p.id}'),
                    )
                    .animate()
                    .fadeIn(
                      delay: Duration(milliseconds: 60 * i),
                      duration: const Duration(milliseconds: 280),
                      curve: Curves.easeOut,
                    )
                    .slideY(
                      begin: 0.06,
                      end: 0,
                      delay: Duration(milliseconds: 60 * i),
                      duration: const Duration(milliseconds: 280),
                      curve: Curves.easeOut,
                    ),
          );
        }),
      ],
    );
  }
}

class _ProjectIdeaCard extends StatelessWidget {
  const _ProjectIdeaCard({required this.idea, this.onTap});

  final ProjectIdea idea;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final tokens =
        Theme.of(context).extension<AppTokens>() ?? AppTokens.defaults();

    return AppCard(
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  idea.title,
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    color: AppColors.ink,
                  ),
                ),
              ),
              _DifficultyBadge(difficulty: idea.difficulty),
            ],
          ),
          SizedBox(height: tokens.gapSm),
          Container(
            padding: EdgeInsets.symmetric(
              horizontal: tokens.gapMd,
              vertical: tokens.gapXs,
            ),
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(tokens.radiusSm),
            ),
            child: Text(
              academicFieldLabel(idea.field),
              style: Theme.of(context).textTheme.labelLarge?.copyWith(
                color: AppColors.primary,
              ),
            ),
          ),
          SizedBox(height: tokens.gapSm),
          Text(
            idea.description,
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
              color: AppColors.inkSecondary,
            ),
          ),
          SizedBox(height: tokens.gapMd),
          Row(
            children: [
              const Icon(
                Icons.arrow_forward_rounded,
                size: 16,
                color: AppColors.primary,
              ),
              SizedBox(width: tokens.gapXs),
              Text(
                'Подробнее',
                style: Theme.of(context).textTheme.labelLarge?.copyWith(
                  color: AppColors.primary,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// ── Shared badge widgets ───────────────────────────────────────────────────────

class _AccessibilityBadge extends StatelessWidget {
  const _AccessibilityBadge({required this.accessibility});

  final Accessibility accessibility;

  @override
  Widget build(BuildContext context) {
    final tokens =
        Theme.of(context).extension<AppTokens>() ?? AppTokens.defaults();

    final Color color;
    switch (accessibility) {
      case Accessibility.easy:
        color = AppColors.successGreen;
      case Accessibility.medium:
        color = AppColors.goldKey;
      case Accessibility.hard:
        color = AppColors.errorRed;
    }

    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: tokens.gapMd,
        vertical: tokens.gapXs,
      ),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(tokens.radiusSm),
      ),
      child: Text(
        accessibilityLabel(accessibility),
        style: Theme.of(context).textTheme.bodySmall?.copyWith(
          color: color,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}

class _DifficultyBadge extends StatelessWidget {
  const _DifficultyBadge({required this.difficulty});

  final String difficulty;

  @override
  Widget build(BuildContext context) {
    final tokens =
        Theme.of(context).extension<AppTokens>() ?? AppTokens.defaults();

    final color = difficulty == 'Легко'
        ? AppColors.successGreen
        : difficulty == 'Сложно'
        ? AppColors.errorRed
        : AppColors.goldKey;

    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: tokens.gapMd,
        vertical: tokens.gapXs,
      ),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(tokens.radiusSm),
      ),
      child: Text(
        difficulty,
        style: Theme.of(context).textTheme.bodySmall?.copyWith(
          color: color,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}

// ── Context banner (personalization label) ────────────────────────────────────

class _ContextBanner extends StatelessWidget {
  const _ContextBanner({
    required this.icon,
    required this.iconColor,
    required this.message,
  });

  final IconData icon;
  final Color iconColor;
  final String message;

  @override
  Widget build(BuildContext context) {
    final tokens =
        Theme.of(context).extension<AppTokens>() ?? AppTokens.defaults();
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: tokens.gapMd,
        vertical: tokens.gapSm,
      ),
      decoration: BoxDecoration(
        color: AppColors.surfaceTint,
        borderRadius: BorderRadius.circular(tokens.radiusMd),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: iconColor),
          SizedBox(width: tokens.gapSm),
          Expanded(
            child: Text(
              message,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: AppColors.inkSecondary,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Empty state ────────────────────────────────────────────────────────────────

class _EmptyState extends StatelessWidget {
  const _EmptyState({
    required this.message,
    this.icon = Icons.search_off_rounded,
    this.actionLabel,
    this.onAction,
  });

  final String message;
  final IconData icon;
  final String? actionLabel;
  final VoidCallback? onAction;

  @override
  Widget build(BuildContext context) {
    final tokens =
        Theme.of(context).extension<AppTokens>() ?? AppTokens.defaults();
    // Capture into locals so Dart flow-analysis can promote nullable fields.
    final label = actionLabel;
    final action = onAction;
    return Center(
      child: Padding(
        padding: EdgeInsets.all(tokens.screenPadding),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 48, color: AppColors.border),
            SizedBox(height: tokens.gapMd),
            Text(
              message,
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                color: AppColors.inkSecondary,
              ),
              textAlign: TextAlign.center,
            ),
            if (label != null && action != null) ...[
              SizedBox(height: tokens.gapMd),
              PrimaryButton(label: label, onPressed: action),
            ],
          ],
        ),
      ),
    );
  }
}

// ── Materials tab ──────────────────────────────────────────────────────────────

/// Study-materials tab: searchable, filterable list of downloadable resources.
class _MaterialsTab extends ConsumerStatefulWidget {
  const _MaterialsTab({required this.tokens});

  final AppTokens tokens;

  @override
  ConsumerState<_MaterialsTab> createState() => _MaterialsTabState();
}

class _MaterialsTabState extends ConsumerState<_MaterialsTab> {
  final TextEditingController _searchCtrl = TextEditingController();

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  void _clearFilters() {
    _searchCtrl.clear();
    ref.read(studyMaterialsFilterProvider.notifier).clearAll();
  }

  @override
  Widget build(BuildContext context) {
    final tokens = widget.tokens;
    final materialsAsync = ref.watch(studyMaterialsProvider);
    final filter = ref.watch(studyMaterialsFilterProvider);
    final filtered = ref.watch(filteredStudyMaterialsProvider);
    final majors = ref.watch(studyMaterialMajorsProvider);

    return Column(
      children: [
        // ── Search bar ────────────────────────────────────────────────────────
        Padding(
          padding: EdgeInsets.fromLTRB(
            tokens.screenPadding,
            tokens.gapMd,
            tokens.screenPadding,
            0,
          ),
          child: TextField(
            controller: _searchCtrl,
            onChanged: (v) =>
                ref.read(studyMaterialsFilterProvider.notifier).setQuery(v),
            decoration: InputDecoration(
              hintText: 'Поиск материалов...',
              prefixIcon: const Icon(Icons.search_rounded, size: 20),
              suffixIcon: filter.query.isNotEmpty
                  ? IconButton(
                      icon: const Icon(Icons.clear_rounded, size: 20),
                      onPressed: () {
                        _searchCtrl.clear();
                        ref
                            .read(studyMaterialsFilterProvider.notifier)
                            .setQuery('');
                      },
                    )
                  : null,
              isDense: true,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(tokens.radiusMd),
                borderSide: const BorderSide(color: AppColors.border),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(tokens.radiusMd),
                borderSide: const BorderSide(color: AppColors.border),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(tokens.radiusMd),
                borderSide: const BorderSide(color: AppColors.primary),
              ),
              filled: true,
              fillColor: AppColors.surfaceTint,
            ),
          ),
        ),
        // ── Filter + sort chips ───────────────────────────────────────────────
        _MaterialsFilterRow(
          filter: filter,
          majors: majors,
          tokens: tokens,
          onClearAll: _clearFilters,
        ),
        const Divider(height: 1, color: AppColors.border),
        // ── Content ───────────────────────────────────────────────────────────
        Expanded(
          child: _buildContent(
            context,
            materialsAsync: materialsAsync,
            filter: filter,
            filtered: filtered,
            tokens: tokens,
          ),
        ),
      ],
    );
  }

  Widget _buildContent(
    BuildContext context, {
    required AsyncValue<List<StudyMaterial>> materialsAsync,
    required StudyMaterialsFilter filter,
    required List<StudyMaterial> filtered,
    required AppTokens tokens,
  }) {
    if (materialsAsync.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (materialsAsync.hasError) {
      return const _EmptyState(message: 'Не удалось загрузить материалы');
    }

    final all = materialsAsync.value ?? const <StudyMaterial>[];

    if (all.isEmpty) {
      return const _EmptyState(
        icon: Icons.menu_book_rounded,
        message: 'Материалы скоро появятся',
      );
    }

    if (filtered.isEmpty) {
      return _EmptyState(
        message: 'Ничего не нашлось — сбрось фильтры',
        actionLabel: 'Сбросить фильтры',
        onAction: _clearFilters,
      );
    }

    return RefreshIndicator(
      onRefresh: () => ref.read(studyMaterialsProvider.notifier).refresh(),
      child: ListView.separated(
        padding: EdgeInsets.all(tokens.screenPadding),
        itemCount: filtered.length,
        separatorBuilder: (context, index) =>
            SizedBox(height: tokens.gapMd),
        itemBuilder: (context, i) {
          final m = filtered[i];
          return _MaterialCard(material: m, tokens: tokens)
              .animate()
              .fadeIn(
                delay: Duration(milliseconds: 60 * i),
                duration: const Duration(milliseconds: 280),
                curve: Curves.easeOut,
              )
              .slideY(
                begin: 0.06,
                end: 0,
                delay: Duration(milliseconds: 60 * i),
                duration: const Duration(milliseconds: 280),
                curve: Curves.easeOut,
              );
        },
      ),
    );
  }
}

// ── Materials filter + sort row ───────────────────────────────────────────────

class _MaterialsFilterRow extends ConsumerWidget {
  const _MaterialsFilterRow({
    required this.filter,
    required this.majors,
    required this.tokens,
    required this.onClearAll,
  });

  final StudyMaterialsFilter filter;
  final List<String> majors;
  final AppTokens tokens;
  final VoidCallback onClearAll;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final notifier = ref.read(studyMaterialsFilterProvider.notifier);

    return Padding(
      padding: EdgeInsets.symmetric(
        horizontal: tokens.screenPadding,
        vertical: tokens.gapSm,
      ),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            // "Все" chip — active when no exam or major filter is set.
            _ExamChip(
              label: 'Все',
              isActive: filter.exam == null && filter.major == null,
              onTap: () {
                notifier.setExam(null);
                notifier.setMajor(null);
              },
            ),
            SizedBox(width: tokens.gapSm),
            // One chip per exam type.
            ...StudyMaterialExam.values.map((exam) {
              return Padding(
                padding: EdgeInsets.only(right: tokens.gapSm),
                child: _ExamChip(
                  label: studyMaterialExamLabel(exam),
                  isActive: filter.exam == exam,
                  onTap: () =>
                      notifier.setExam(filter.exam == exam ? null : exam),
                ),
              );
            }),
            // Dynamic major chips (only visible when data contains majors).
            ...majors.map((major) {
              return Padding(
                padding: EdgeInsets.only(right: tokens.gapSm),
                child: _ExamChip(
                  label: major,
                  isActive: filter.major == major,
                  onTap: () =>
                      notifier.setMajor(filter.major == major ? null : major),
                ),
              );
            }),
            // Sort toggle.
            _SortToggleChip(
              newestFirst: filter.newestFirst,
              onTap: notifier.toggleSort,
              tokens: tokens,
            ),
            // "Сбросить" button — only visible when a filter is active.
            if (filter.hasActiveFilter) ...[
              SizedBox(width: tokens.gapSm),
              GestureDetector(
                onTap: onClearAll,
                child: Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: tokens.gapMd,
                    vertical: tokens.gapXs,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.errorRed.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(tokens.radiusSm),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(
                        Icons.close_rounded,
                        size: 14,
                        color: AppColors.errorRed,
                      ),
                      SizedBox(width: tokens.gapXs),
                      Text(
                        'Сбросить',
                        style: Theme.of(context).textTheme.labelLarge?.copyWith(
                          color: AppColors.errorRed,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

// ── Exam chip (toggle) ────────────────────────────────────────────────────────

class _ExamChip extends StatelessWidget {
  const _ExamChip({
    required this.label,
    required this.isActive,
    required this.onTap,
  });

  final String label;
  final bool isActive;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final tokens =
        Theme.of(context).extension<AppTokens>() ?? AppTokens.defaults();
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(
          horizontal: tokens.gapMd,
          vertical: tokens.gapXs,
        ),
        decoration: BoxDecoration(
          color: isActive
              ? AppColors.primary.withValues(alpha: 0.12)
              : AppColors.surfaceTint,
          borderRadius: BorderRadius.circular(tokens.radiusSm),
          border: Border.all(
            color: isActive ? AppColors.primary : AppColors.border,
          ),
        ),
        child: Text(
          label,
          style: Theme.of(context).textTheme.labelLarge?.copyWith(
            color: isActive ? AppColors.primary : AppColors.inkSecondary,
            fontWeight: isActive ? FontWeight.w600 : FontWeight.w500,
          ),
        ),
      ),
    );
  }
}

// ── Sort toggle chip ──────────────────────────────────────────────────────────

class _SortToggleChip extends StatelessWidget {
  const _SortToggleChip({
    required this.newestFirst,
    required this.onTap,
    required this.tokens,
  });

  final bool newestFirst;
  final VoidCallback onTap;
  final AppTokens tokens;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
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
            Icon(
              newestFirst
                  ? Icons.arrow_downward_rounded
                  : Icons.arrow_upward_rounded,
              size: 14,
              color: AppColors.inkSecondary,
            ),
            SizedBox(width: tokens.gapXs),
            Text(
              newestFirst ? 'Сначала новые' : 'Сначала старые',
              style: Theme.of(context).textTheme.labelLarge?.copyWith(
                color: AppColors.inkSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Material card ─────────────────────────────────────────────────────────────

class _MaterialCard extends StatelessWidget {
  const _MaterialCard({required this.material, required this.tokens});

  final StudyMaterial material;
  final AppTokens tokens;

  @override
  Widget build(BuildContext context) {
    return AppCard(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Header: icon + title + description ───────────────────────────
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(tokens.radiusSm),
                ),
                child: Icon(
                  _iconForExam(material.exam),
                  size: 22,
                  color: AppColors.primary,
                ),
              ),
              SizedBox(width: tokens.gapMd),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      material.title,
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        color: AppColors.ink,
                      ),
                    ),
                    if (material.description.isNotEmpty) ...[
                      SizedBox(height: tokens.gapXs),
                      Text(
                        material.description,
                        style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                          color: AppColors.inkSecondary,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
          SizedBox(height: tokens.gapMd),
          // ── Meta: exam badge + major + size + date ────────────────────────
          Wrap(
            spacing: tokens.gapSm,
            runSpacing: tokens.gapXs,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              _MaterialExamBadge(exam: material.exam, tokens: tokens),
              if (material.major != null)
                _MaterialMajorBadge(major: material.major!, tokens: tokens),
              if (material.sizeLabel != null)
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(
                      Icons.data_usage_rounded,
                      size: 12,
                      color: AppColors.inkSecondary,
                    ),
                    SizedBox(width: tokens.gapXs),
                    Text(
                      material.sizeLabel!,
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  ],
                ),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(
                    Icons.calendar_today_outlined,
                    size: 12,
                    color: AppColors.inkSecondary,
                  ),
                  SizedBox(width: tokens.gapXs),
                  Text(
                    _formatDate(material.createdAt),
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ],
              ),
            ],
          ),
          SizedBox(height: tokens.gapMd),
          // ── CTA: open / download ──────────────────────────────────────────
          GestureDetector(
            onTap: () => unawaited(openExternalLink(context, material.fileUrl)),
            child: Container(
              padding: EdgeInsets.symmetric(
                horizontal: tokens.gapMd,
                vertical: tokens.gapSm,
              ),
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(tokens.radiusSm),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(
                    Icons.download_rounded,
                    size: 16,
                    color: AppColors.primary,
                  ),
                  SizedBox(width: tokens.gapXs),
                  Text(
                    'Скачать',
                    style: Theme.of(context).textTheme.labelLarge?.copyWith(
                      color: AppColors.primary,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  static IconData _iconForExam(StudyMaterialExam exam) {
    switch (exam) {
      case StudyMaterialExam.ielts:
      case StudyMaterialExam.sat:
        return Icons.language_rounded;
      case StudyMaterialExam.ent:
        return Icons.school_rounded;
      case StudyMaterialExam.other:
        return Icons.menu_book_rounded;
    }
  }

  /// Hand-rolled RU date formatter — avoids initializeDateFormatting.
  static String _formatDate(DateTime dt) {
    const months = [
      'янв',
      'фев',
      'мар',
      'апр',
      'май',
      'июн',
      'июл',
      'авг',
      'сен',
      'окт',
      'ноя',
      'дек',
    ];
    return '${dt.day} ${months[dt.month - 1]} ${dt.year}';
  }
}

// ── Exam badge (on material card) ─────────────────────────────────────────────

class _MaterialExamBadge extends StatelessWidget {
  const _MaterialExamBadge({required this.exam, required this.tokens});

  final StudyMaterialExam exam;
  final AppTokens tokens;

  @override
  Widget build(BuildContext context) {
    final color = switch (exam) {
      StudyMaterialExam.ielts => AppColors.primary,
      StudyMaterialExam.sat => AppColors.goldKey,
      StudyMaterialExam.ent => AppColors.successGreen,
      StudyMaterialExam.other => AppColors.inkSecondary,
    };

    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: tokens.gapMd,
        vertical: tokens.gapXs,
      ),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(tokens.radiusSm),
      ),
      child: Text(
        studyMaterialExamLabel(exam),
        style: Theme.of(context).textTheme.bodySmall?.copyWith(
          color: color,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}

// ── Major badge (on material card) ────────────────────────────────────────────

class _MaterialMajorBadge extends StatelessWidget {
  const _MaterialMajorBadge({required this.major, required this.tokens});

  final String major;
  final AppTokens tokens;

  @override
  Widget build(BuildContext context) {
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
      child: Text(
        major,
        style: Theme.of(context).textTheme.bodySmall?.copyWith(
          color: AppColors.inkSecondary,
        ),
      ),
    );
  }
}
