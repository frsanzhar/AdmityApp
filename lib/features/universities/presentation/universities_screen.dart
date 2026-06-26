import 'dart:async';

import 'package:admity/core/theme/app_colors.dart';
import 'package:admity/core/theme/app_tokens.dart';
import 'package:admity/features/universities/data/university_catalog_providers.dart';
import 'package:admity/features/universities/domain/university_catalog.dart';
import 'package:admity/shared/widgets/app_card.dart';
import 'package:admity/shared/widgets/app_scaffold.dart';
import 'package:admity/shared/widgets/mascot_slot.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

// ── Screen ─────────────────────────────────────────────────────────────────────

/// Full "Вузы" page — the universities catalog (offline JSON, 100+ вузов).
///
/// Layout: AppScaffold > Column > fixed header (title + MascotSlot + filters)
///         + Expanded > ListView. Async catalog is resolved with `.when` so a
///         load/parse failure shows a message, never a blank viewport.
class UniversitiesScreen extends ConsumerWidget {
  /// Creates the universities screen.
  const UniversitiesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tokens =
        Theme.of(context).extension<AppTokens>() ?? AppTokens.defaults();
    final catalogAsync = ref.watch(universityCatalogProvider);

    return AppScaffold(
      body: catalogAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (_, _) => _MessageState(
          tokens: tokens,
          icon: Icons.cloud_off_rounded,
          message: 'Не удалось загрузить список вузов',
        ),
        data: (catalog) {
          if (catalog.universities.isEmpty) {
            return _MessageState(
              tokens: tokens,
              icon: Icons.school_outlined,
              message: 'Список вузов пуст',
            );
          }
          return _CatalogBody(catalog: catalog, tokens: tokens);
        },
      ),
    );
  }
}

// ── Body ───────────────────────────────────────────────────────────────────────

class _CatalogBody extends ConsumerWidget {
  const _CatalogBody({required this.catalog, required this.tokens});

  final UniversityCatalog catalog;
  final AppTokens tokens;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final filter = ref.watch(catalogFilterProvider);
    final universities = applyCatalogFilter(catalog.universities, filter);

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        _Header(catalog: catalog, filter: filter, tokens: tokens),
        Expanded(
          child: universities.isEmpty
              ? _MessageState(
                  tokens: tokens,
                  icon: Icons.search_off_rounded,
                  message: 'Нет вузов по выбранным фильтрам',
                )
              : _UniversitiesList(
                  catalog: catalog,
                  universities: universities,
                  tokens: tokens,
                ),
        ),
      ],
    );
  }
}

// ── Header ─────────────────────────────────────────────────────────────────────

class _Header extends ConsumerWidget {
  const _Header({
    required this.catalog,
    required this.filter,
    required this.tokens,
  });

  final UniversityCatalog catalog;
  final CatalogFilter filter;
  final AppTokens tokens;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final notifier = ref.read(catalogFilterProvider.notifier);
    return ColoredBox(
      color: AppColors.white,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
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
                        '${catalog.universities.length} вузов Казахстана',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: AppColors.inkSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(width: tokens.gapMd),
                const MascotSlot(size: 64, tag: 'universities'),
              ],
            ),
          ),
          // ── Filter row ──────────────────────────────────────────────────────
          Padding(
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
                    onTap: () => _pickCity(context, ref),
                  ),
                  SizedBox(width: tokens.gapSm),
                  _FilterChip(
                    label: filter.type != null
                        ? universityTypeLabel(filter.type!)
                        : 'Тип',
                    isActive: filter.type != null,
                    onTap: () => _pickType(context, ref),
                  ),
                  if (!filter.isEmpty) ...[
                    SizedBox(width: tokens.gapSm),
                    _ResetChip(onTap: notifier.clearAll, tokens: tokens),
                  ],
                ],
              ),
            ),
          ),
          const Divider(height: 1, color: AppColors.border),
        ],
      ),
    );
  }

  void _pickCity(BuildContext context, WidgetRef ref) {
    unawaited(
      showModalBottomSheet<void>(
        context: context,
        builder: (_) => _PickerSheet(
          title: 'Выбрать город',
          items: catalog.cities,
          selected: ref.read(catalogFilterProvider).city,
          onSelect: (v) => ref.read(catalogFilterProvider.notifier).setCity(v),
          onClear: () =>
              ref.read(catalogFilterProvider.notifier).setCity(null),
        ),
      ),
    );
  }

  void _pickType(BuildContext context, WidgetRef ref) {
    final types = catalog.typesPresent;
    unawaited(
      showModalBottomSheet<void>(
        context: context,
        builder: (_) => _PickerSheet(
          title: 'Выбрать тип',
          items: types.map(universityTypeLabel).toList(),
          selected: ref.read(catalogFilterProvider).type != null
              ? universityTypeLabel(ref.read(catalogFilterProvider).type!)
              : null,
          onSelect: (v) {
            final type = types.firstWhere((t) => universityTypeLabel(t) == v);
            ref.read(catalogFilterProvider.notifier).setType(type);
          },
          onClear: () =>
              ref.read(catalogFilterProvider.notifier).setType(null),
        ),
      ),
    );
  }
}

// ── List ───────────────────────────────────────────────────────────────────────

class _UniversitiesList extends StatelessWidget {
  const _UniversitiesList({
    required this.catalog,
    required this.universities,
    required this.tokens,
  });

  final UniversityCatalog catalog;
  final List<UniversityRecord> universities;
  final AppTokens tokens;

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      padding: EdgeInsets.all(tokens.screenPadding),
      itemCount: universities.length,
      separatorBuilder: (context, i) => SizedBox(height: tokens.gapMd),
      itemBuilder: (context, i) {
        final u = universities[i];
        return _UniversityCard(
          university: u,
          programCount: catalog.offeringCountFor(u.id),
          minCompetition: catalog.minCompetitionScoreFor(u.id),
          tokens: tokens,
          onTap: () => context.push('/universities/${u.id}'),
        ).animate().fadeIn(
          delay: Duration(milliseconds: 40 * (i % 12)),
          duration: const Duration(milliseconds: 260),
          curve: Curves.easeOut,
        );
      },
    );
  }
}

// ── Card ───────────────────────────────────────────────────────────────────────

class _UniversityCard extends StatelessWidget {
  const _UniversityCard({
    required this.university,
    required this.programCount,
    required this.minCompetition,
    required this.tokens,
    required this.onTap,
  });

  final UniversityRecord university;
  final int programCount;
  final int? minCompetition;
  final AppTokens tokens;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
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
                  university.nameRu,
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    color: AppColors.ink,
                  ),
                ),
              ),
              if (university.type != null) ...[
                SizedBox(width: tokens.gapSm),
                _TypeBadge(type: university.type!, tokens: tokens),
              ],
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
              Expanded(
                child: Text(
                  university.city,
                  style: Theme.of(context).textTheme.bodySmall,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          SizedBox(height: tokens.gapMd),
          Row(
            children: [
              if (programCount > 0)
                _InfoBadge(
                  label: '$programCount ${_programWord(programCount)}',
                  tokens: tokens,
                ),
              if (minCompetition != null) ...[
                SizedBox(width: tokens.gapSm),
                _InfoBadge(
                  label: 'конкурс от $minCompetition б.',
                  tokens: tokens,
                ),
              ],
              const Spacer(),
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

  String _programWord(int n) {
    final mod10 = n % 10;
    final mod100 = n % 100;
    if (mod10 == 1 && mod100 != 11) return 'программа';
    if (mod10 >= 2 && mod10 <= 4 && (mod100 < 12 || mod100 > 14)) {
      return 'программы';
    }
    return 'программ';
  }
}

// ── Small widgets ────────────────────────────────────────────────────────────

class _TypeBadge extends StatelessWidget {
  const _TypeBadge({required this.type, required this.tokens});

  final UniversityType type;
  final AppTokens tokens;

  @override
  Widget build(BuildContext context) {
    final Color color;
    switch (type) {
      case UniversityType.national:
        color = AppColors.primary;
      case UniversityType.autonomous:
        color = AppColors.successGreen;
      case UniversityType.international:
        color = AppColors.goldKey;
      case UniversityType.state:
        color = AppColors.inkSecondary;
      case UniversityType.private:
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
        universityTypeLabel(type),
        style: Theme.of(context).textTheme.bodySmall?.copyWith(
          color: color,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}

class _InfoBadge extends StatelessWidget {
  const _InfoBadge({required this.label, required this.tokens});

  final String label;
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
      ),
      child: Text(
        label,
        style: Theme.of(context).textTheme.labelLarge?.copyWith(
          color: AppColors.ink,
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

class _ResetChip extends StatelessWidget {
  const _ResetChip({required this.onTap, required this.tokens});

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
          color: AppColors.errorRed.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(tokens.radiusSm),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.close_rounded, size: 14, color: AppColors.errorRed),
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
    );
  }
}

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
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxHeight: MediaQuery.of(context).size.height * 0.7,
        ),
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
              SizedBox(height: tokens.gapMd),
              Flexible(
                child: ListView(
                  shrinkWrap: true,
                  children: [
                    if (selected != null)
                      ListTile(
                        leading: const Icon(
                          Icons.close_rounded,
                          color: AppColors.inkSecondary,
                        ),
                        title: const Text('Сбросить фильтр'),
                        onTap: () {
                          Navigator.of(context).pop();
                          onClear();
                        },
                      ),
                    ...items.map((item) {
                      final isSelected = item == selected;
                      return ListTile(
                        title: Text(
                          item,
                          style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                            color: isSelected ? AppColors.primary : AppColors.ink,
                            fontWeight:
                                isSelected ? FontWeight.w600 : FontWeight.w500,
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
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _MessageState extends StatelessWidget {
  const _MessageState({
    required this.tokens,
    required this.icon,
    required this.message,
  });

  final AppTokens tokens;
  final IconData icon;
  final String message;

  @override
  Widget build(BuildContext context) {
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
          ],
        ),
      ),
    );
  }
}
