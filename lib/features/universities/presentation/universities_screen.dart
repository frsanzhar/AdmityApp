import 'dart:async';

import 'package:admity/core/theme/app_colors.dart';
import 'package:admity/core/theme/app_tokens.dart';
import 'package:admity/features/opportunities/data/opportunity_seed.dart';
import 'package:admity/features/opportunities/domain/opportunity_models.dart';
import 'package:admity/features/opportunities/presentation/opportunities_providers.dart';
import 'package:admity/shared/widgets/app_card.dart';
import 'package:admity/shared/widgets/app_scaffold.dart';
import 'package:admity/shared/widgets/mascot_slot.dart';
import 'package:admity/shared/widgets/progress_ring.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

// ── Screen ─────────────────────────────────────────────────────────────────────

/// Full "Вузы" page — university list with filters.
///
/// Pulled out of Возможности into its own top-level route (/universities).
///
/// Layout: AppScaffold > Column > fixed header (title + MascotSlot + filter row)
///         + Expanded > ListView (university cards).
/// Accent: AppColors.primary (cobalt). One accent per screen.
class UniversitiesScreen extends ConsumerWidget {
  const UniversitiesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tokens =
        Theme.of(context).extension<AppTokens>() ?? AppTokens.defaults();
    final filter = ref.watch(opportunityFilterProvider);

    return AppScaffold(
      body: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // ── Fixed header ───────────────────────────────────────────────────
          _UniversitiesHeader(filter: filter, tokens: tokens),
          // ── Scrollable list ────────────────────────────────────────────────
          Expanded(
            child: _UniversitiesList(tokens: tokens),
          ),
        ],
      ),
    );
  }
}

// ── Header ─────────────────────────────────────────────────────────────────────

class _UniversitiesHeader extends ConsumerWidget {
  const _UniversitiesHeader({
    required this.filter,
    required this.tokens,
  });

  final OpportunityFilter filter;
  final AppTokens tokens;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return ColoredBox(
      color: AppColors.white,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // ── Title row + MascotSlot ──────────────────────────────────────────
          Padding(
            padding: EdgeInsets.fromLTRB(
              tokens.screenPadding,
              tokens.gapLg,
              tokens.screenPadding,
              tokens.gapMd,
            ),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Вузы',
                        style: Theme.of(context).textTheme.headlineLarge
                            ?.copyWith(color: AppColors.ink),
                      ),
                      SizedBox(height: tokens.gapXs),
                      Text(
                        'Найди университет, который подходит тебе',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: AppColors.inkSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(width: tokens.gapMd),
                // TODO(mascot): Replace with real university mascot asset.
                const MascotSlot(size: 64, tag: 'universities'),
              ],
            ),
          ),
          // ── Filter row ──────────────────────────────────────────────────────
          _FilterRow(filter: filter, tokens: tokens),
          // ── Divider ─────────────────────────────────────────────────────────
          const Divider(height: 1, color: AppColors.border),
        ],
      ),
    );
  }
}

// ── Filter row ─────────────────────────────────────────────────────────────────

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
      ...{...seedUniversities.map((u) => u.city)},
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

// ── Filter chip ────────────────────────────────────────────────────────────────

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
            if (selected != null) ...[
              GestureDetector(
                onTap: () {
                  Navigator.of(context).pop();
                  onClear();
                },
                child: Container(
                  padding: EdgeInsets.symmetric(
                    vertical: tokens.gapMd,
                    horizontal: tokens.gapLg,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.ink,
                    borderRadius: BorderRadius.circular(tokens.radiusMd),
                  ),
                  alignment: Alignment.center,
                  child: Text(
                    'Сбросить фильтр',
                    style: Theme.of(context).textTheme.labelLarge?.copyWith(
                      color: AppColors.white,
                    ),
                  ),
                ),
              ),
              SizedBox(height: tokens.gapMd),
            ],
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

// ── Universities list ──────────────────────────────────────────────────────────

class _UniversitiesList extends ConsumerWidget {
  const _UniversitiesList({required this.tokens});

  final AppTokens tokens;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final universities = ref.watch(filteredUniversitiesProvider);

    if (universities.isEmpty) {
      return _EmptyState(tokens: tokens);
    }

    return ListView.separated(
      padding: EdgeInsets.all(tokens.screenPadding),
      itemCount: universities.length,
      separatorBuilder: (context, i) => SizedBox(height: tokens.gapMd),
      itemBuilder: (context, i) {
        final u = universities[i];
        return _UniversityCard(
              university: u,
              onTap: () => context.push('/opportunities/university/${u.id}'),
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

// ── University card ────────────────────────────────────────────────────────────

class _UniversityCard extends StatelessWidget {
  const _UniversityCard({
    required this.university,
    required this.onTap,
  });

  final University university;
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
          // ── Name + accessibility badge ────────────────────────────────────
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Text(
                  university.name,
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    color: AppColors.ink,
                  ),
                ),
              ),
              SizedBox(width: tokens.gapSm),
              _AccessibilityBadge(accessibility: university.accessibility),
            ],
          ),
          SizedBox(height: tokens.gapSm),

          // ── City + field row ──────────────────────────────────────────────
          Row(
            children: [
              const Icon(
                Icons.location_on_outlined,
                size: 14,
                color: AppColors.inkSecondary,
              ),
              SizedBox(width: tokens.gapXs),
              Text(
                university.city,
                style: Theme.of(context).textTheme.bodySmall,
              ),
              SizedBox(width: tokens.gapMd),
              const Icon(
                Icons.school_outlined,
                size: 14,
                color: AppColors.inkSecondary,
              ),
              SizedBox(width: tokens.gapXs),
              Expanded(
                child: Text(
                  academicFieldLabel(university.field),
                  style: Theme.of(context).textTheme.bodySmall,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          SizedBox(height: tokens.gapSm),

          // ── Description ───────────────────────────────────────────────────
          Text(
            university.description,
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
              color: AppColors.inkSecondary,
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          SizedBox(height: tokens.gapMd),

          // ── Bottom row: ENT threshold + tuition + acceptance ring ─────────
          Row(
            children: [
              // ENT badge
              Container(
                padding: EdgeInsets.symmetric(
                  horizontal: tokens.gapMd,
                  vertical: tokens.gapXs,
                ),
                decoration: BoxDecoration(
                  color: AppColors.surfaceTint,
                  borderRadius: BorderRadius.circular(tokens.radiusSm),
                ),
                child: Text(
                  'ЕНТ ≥ ${university.entThreshold}',
                  style: Theme.of(context).textTheme.labelLarge?.copyWith(
                    color: AppColors.ink,
                  ),
                ),
              ),
              SizedBox(width: tokens.gapSm),
              // Tuition badge
              Container(
                padding: EdgeInsets.symmetric(
                  horizontal: tokens.gapMd,
                  vertical: tokens.gapXs,
                ),
                decoration: BoxDecoration(
                  color: AppColors.surfaceTint,
                  borderRadius: BorderRadius.circular(tokens.radiusSm),
                ),
                child: Text(
                  university.tuitionLabel,
                  style: Theme.of(context).textTheme.labelLarge?.copyWith(
                    color: AppColors.ink,
                  ),
                ),
              ),
              const Spacer(),
              // Acceptance rate ring — honest, never inflated
              if (university.acceptanceRate != null)
                _AcceptanceRing(rate: university.acceptanceRate!)
              else
                const Icon(
                  Icons.arrow_forward_rounded,
                  size: 16,
                  color: AppColors.primary,
                ),
            ],
          ),
        ],
      ),
    );
  }
}

// ── Acceptance rate ring ───────────────────────────────────────────────────────

/// Compact ProgressRing showing the honest acceptance rate.
class _AcceptanceRing extends StatelessWidget {
  const _AcceptanceRing({required this.rate});

  final double rate;

  @override
  Widget build(BuildContext context) {
    return ProgressRing(
      progress: rate,
      size: 44,
      strokeWidth: 5,
      progressColor: AppColors.successGreen,
      child: Text(
        '${(rate * 100).round()}%',
        style: const TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.w700,
          color: AppColors.ink,
        ),
      ),
    );
  }
}

// ── Accessibility badge ────────────────────────────────────────────────────────

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

// ── Empty state ────────────────────────────────────────────────────────────────

class _EmptyState extends StatelessWidget {
  const _EmptyState({required this.tokens});

  final AppTokens tokens;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: EdgeInsets.all(tokens.screenPadding),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.search_off_rounded,
              size: 48,
              color: AppColors.border,
            ),
            SizedBox(height: tokens.gapMd),
            Text(
              'Нет университетов по выбранным фильтрам',
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                color: AppColors.inkSecondary,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
