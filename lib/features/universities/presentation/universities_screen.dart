import 'dart:async';

import 'package:admity/core/theme/app_colors.dart';
import 'package:admity/core/theme/app_tokens.dart';
import 'package:admity/features/profile/application/profile_notifier.dart';
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
      appBar: AppBar(
        backgroundColor: AppColors.white,
        elevation: 0,
        surfaceTintColor: Colors.transparent,
        leading: const BackButton(color: AppColors.ink),
      ),
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
          final profile = ref.watch(profileProvider).profile;
          return _CatalogBody(
            catalog: catalog,
            tokens: tokens,
            profileCity: profile.city,
            profileMajors: profile.targetMajors,
          );
        },
      ),
    );
  }
}

// ── Body ───────────────────────────────────────────────────────────────────────

class _CatalogBody extends ConsumerWidget {
  const _CatalogBody({
    required this.catalog,
    required this.tokens,
    this.profileCity,
    this.profileMajors = const [],
  });

  final UniversityCatalog catalog;
  final AppTokens tokens;

  /// Student's current city from their profile — used to boost local unis.
  final String? profileCity;

  /// Student's target majors — used to boost matching universities.
  final List<String> profileMajors;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final filter = ref.watch(catalogFilterProvider);
    final filtered = applyCatalogFilter(catalog, filter);
    final universities = _sortedByProfile(
      filtered,
      profileCity: profileCity,
      profileMajors: profileMajors,
    );

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
        crossAxisAlignment: CrossAxisAlignment.start,
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
          // ── Filter row (left-aligned, horizontally scrollable) ────────────
          Padding(
            padding: EdgeInsets.only(
              left: tokens.screenPadding,
              bottom: tokens.gapSm,
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
                    label: filter.major != null
                        ? majorCategoryLabel(filter.major!)
                        : 'Направление',
                    isActive: filter.major != null,
                    onTap: () => _pickMajor(context, ref),
                  ),
                  SizedBox(width: tokens.gapSm),
                  _FilterChip(
                    label: filter.type != null
                        ? universityTypeLabel(filter.type!)
                        : 'Тип',
                    isActive: filter.type != null,
                    onTap: () => _pickType(context, ref),
                  ),
                  SizedBox(width: tokens.gapSm),
                  _ToggleChip(
                    label: 'Общежитие',
                    isActive: filter.hasDormitory == true,
                    onTap: () =>
                        ref.read(catalogFilterProvider.notifier).toggleDormitory(),
                  ),
                  SizedBox(width: tokens.gapSm),
                  _FilterChip(
                    label: filter.maxScore != null
                        ? 'Балл до ${filter.maxScore}'
                        : 'Балл до…',
                    isActive: filter.maxScore != null,
                    onTap: () => _pickScore(context, ref),
                  ),
                  if (!filter.isEmpty) ...[
                    SizedBox(width: tokens.gapSm),
                    _ResetChip(onTap: notifier.clearAll, tokens: tokens),
                  ],
                  // trailing scroll affordance
                  SizedBox(width: tokens.screenPadding),
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

  void _pickMajor(BuildContext context, WidgetRef ref) {
    final cats = catalog.majorCategoriesPresent;
    unawaited(
      showModalBottomSheet<void>(
        context: context,
        builder: (_) => _PickerSheet(
          title: 'Выбрать направление',
          items: cats.map(majorCategoryLabel).toList(),
          selected: ref.read(catalogFilterProvider).major != null
              ? majorCategoryLabel(ref.read(catalogFilterProvider).major!)
              : null,
          onSelect: (v) {
            final cat =
                cats.firstWhere((c) => majorCategoryLabel(c) == v);
            ref.read(catalogFilterProvider.notifier).setMajor(cat);
          },
          onClear: () =>
              ref.read(catalogFilterProvider.notifier).setMajor(null),
        ),
      ),
    );
  }

  void _pickScore(BuildContext context, WidgetRef ref) {
    unawaited(
      showModalBottomSheet<void>(
        context: context,
        builder: (_) => _ScorePickerSheet(
          selected: ref.read(catalogFilterProvider).maxScore,
          onSelect: (s) =>
              ref.read(catalogFilterProvider.notifier).setMaxScore(s),
          onClear: () =>
              ref.read(catalogFilterProvider.notifier).setMaxScore(null),
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
          onTap: () => context.push('/uni-kz/${u.id}'),
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
      padding: EdgeInsets.zero,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Photo (when available) ───────────────────────────────────────
          if (university.imageUrl != null)
            ClipRRect(
              borderRadius: BorderRadius.vertical(
                top: Radius.circular(tokens.radiusMd),
              ),
              child: _UniImage(url: university.imageUrl!, height: 110),
            ),
          // ── Text content ─────────────────────────────────────────────────
          Padding(
            padding: EdgeInsets.all(tokens.cardPadding),
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
                        style:
                            Theme.of(context).textTheme.titleLarge?.copyWith(
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
                    if (university.hasDormitory == true) ...[
                      const Icon(
                        Icons.bed_rounded,
                        size: 14,
                        color: AppColors.inkSecondary,
                      ),
                      SizedBox(width: tokens.gapXs),
                      Text(
                        'Общежитие',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: AppColors.inkSecondary,
                        ),
                      ),
                    ],
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

// ── University image ──────────────────────────────────────────────────────────

/// Loads a remote university photo with fade-in and a grey placeholder.
class _UniImage extends StatelessWidget {
  const _UniImage({required this.url, required this.height});

  final String url;
  final double height;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: height,
      child: Image.network(
        url,
        fit: BoxFit.cover,
        frameBuilder: (context, child, frame, wasSynchronouslyLoaded) {
          if (wasSynchronouslyLoaded || frame != null) return child;
          return AnimatedOpacity(
            opacity: frame == null ? 0 : 1,
            duration: const Duration(milliseconds: 350),
            child: child,
          );
        },
        loadingBuilder: (context, child, progress) {
          if (progress == null) return child;
          return _ImagePlaceholder(height: height);
        },
        errorBuilder: (context, e, s) => _ImagePlaceholder(height: height),
      ),
    );
  }
}

class _ImagePlaceholder extends StatelessWidget {
  const _ImagePlaceholder({required this.height});

  final double height;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: height,
      color: AppColors.surfaceTint,
      child: const Icon(
        Icons.school_outlined,
        size: 32,
        color: AppColors.border,
      ),
    );
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

/// A toggle chip — no dropdown arrow; tapping toggles the active state.
class _ToggleChip extends StatelessWidget {
  const _ToggleChip({
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
            if (isActive)
              Padding(
                padding: EdgeInsets.only(right: tokens.gapXs),
                child: const Icon(
                  Icons.check_rounded,
                  size: 14,
                  color: AppColors.primary,
                ),
              ),
            Text(
              label,
              style: Theme.of(context).textTheme.labelLarge?.copyWith(
                color: isActive ? AppColors.primary : AppColors.inkSecondary,
              ),
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
                          style:
                              Theme.of(context).textTheme.bodyLarge?.copyWith(
                            color:
                                isSelected ? AppColors.primary : AppColors.ink,
                            fontWeight: isSelected
                                ? FontWeight.w600
                                : FontWeight.w500,
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

/// Score-preset picker for the "Балл до N" filter.
class _ScorePickerSheet extends StatelessWidget {
  const _ScorePickerSheet({
    required this.onSelect,
    required this.onClear,
    this.selected,
  });

  final int? selected;
  final ValueChanged<int> onSelect;
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
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Максимальный конкурсный балл',
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                color: AppColors.ink,
              ),
            ),
            SizedBox(height: tokens.gapXs),
            Text(
              'Показать вузы с конкурсным минимумом не выше выбранного.',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: AppColors.inkSecondary,
              ),
            ),
            SizedBox(height: tokens.gapMd),
            if (selected != null)
              ListTile(
                leading: const Icon(
                  Icons.close_rounded,
                  color: AppColors.inkSecondary,
                ),
                title: const Text('Без ограничения'),
                onTap: () {
                  Navigator.of(context).pop();
                  onClear();
                },
              ),
            ...catalogScorePresets.map((score) {
              final isSelected = score == selected;
              return ListTile(
                title: Text(
                  '$score баллов',
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
                  onSelect(score);
                },
              );
            }),
          ],
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

// ── KZ catalog sorting ────────────────────────────────────────────────────────

/// Returns a sorted copy of [universities] most-suitable-first for the profile.
///
/// Sort key (stable, two-level):
/// 1. Universities in the student's city come first, then all others.
/// 2. Within each group: universities whose programs share tokens with
///    [profileMajors] precede those with no match.
///
/// Original order is preserved within equal-rank entries (stable sort).
List<UniversityRecord> _sortedByProfile(
  List<UniversityRecord> universities, {
  String? profileCity,
  List<String> profileMajors = const [],
}) {
  if (profileCity == null && profileMajors.isEmpty) return universities;

  final cityLower = profileCity?.toLowerCase().trim();
  final majorLower = profileMajors.map((m) => m.toLowerCase()).toSet();

  /// Lower = better.
  int rank(UniversityRecord u) {
    final inCity =
        cityLower != null && u.city.toLowerCase().trim() == cityLower ? 0 : 1;
    // We do not have per-university major data in UniversityRecord, so we
    // match the university description + nameRu loosely as a best-effort.
    final descText =
        '${u.nameRu} ${u.nameEn ?? ''} ${u.description ?? ''}'.toLowerCase();
    final hasMajorMatch = majorLower.any(descText.contains) ? 0 : 1;
    return inCity * 10 + hasMajorMatch;
  }

  final copy = [...universities];
  // Dart's sort is stable in practice (TimSort), so equal-rank entries keep
  // their original relative order.
  copy.sort((a, b) => rank(a).compareTo(rank(b)));
  return copy;
}
