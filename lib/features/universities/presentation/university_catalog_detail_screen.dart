// Richer KZ university detail page (redesign, 2026-06-29).
//
// The previous layout is preserved verbatim in
// `university_catalog_detail_screen_legacy.dart` as
// `UniversityCatalogDetailScreenLegacy` — to revert, point the `/uni-kz/:id`
// route there.
//
// Honesty rule (CLAUDE.md): scores are surfaced with their exact
// [grantMetricLabel]; a `competition_min` is shown as "минимум для участия в
// конкурсе", never as a проходной балл. Nothing is synthesised.

import 'dart:async';

import 'package:admity/core/config/app_config.dart';
import 'package:admity/core/theme/app_colors.dart';
import 'package:admity/core/theme/app_tokens.dart';
import 'package:admity/core/utils/external_link.dart';
import 'package:admity/features/profile/application/profile_notifier.dart';
import 'package:admity/features/profile/domain/profile_model.dart';
import 'package:admity/features/universities/data/university_catalog_providers.dart';
import 'package:admity/features/universities/domain/university_catalog.dart';
import 'package:admity/shared/widgets/app_card.dart';
import 'package:admity/shared/widgets/app_scaffold.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

/// Detail page for one catalog university: an at-a-glance profile (hero, key
/// stats, about) plus the programs (ГОП) with their ЕНТ profile subjects,
/// languages, tuition and honest grant figures.
class UniversityCatalogDetailScreen extends ConsumerWidget {
  /// Creates the detail screen for [universityId].
  const UniversityCatalogDetailScreen({required this.universityId, super.key});

  /// The [UniversityRecord.id] to show.
  final String universityId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tokens =
        Theme.of(context).extension<AppTokens>() ?? AppTokens.defaults();
    final catalogAsync = ref.watch(universityCatalogProvider);

    return AppScaffold(
      body: Stack(
        children: [
          catalogAsync.when(
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (_, _) => const _MessageState(
              icon: Icons.cloud_off_rounded,
              message: 'Не удалось загрузить вуз',
            ),
            data: (catalog) {
              final uni = catalog.universityById(universityId);
              if (uni == null) {
                return const _MessageState(
                  icon: Icons.school_outlined,
                  message: 'Вуз не найден',
                );
              }
              return _DetailView(catalog: catalog, uni: uni, tokens: tokens);
            },
          ),
          // Floating back button over the hero.
          Positioned(
            top: tokens.gapSm,
            left: tokens.gapSm,
            child: const _CircleBackButton(),
          ),
        ],
      ),
    );
  }
}

// ── Body ─────────────────────────────────────────────────────────────────────

class _DetailView extends ConsumerWidget {
  const _DetailView({
    required this.catalog,
    required this.uni,
    required this.tokens,
  });

  final UniversityCatalog catalog;
  final UniversityRecord uni;
  final AppTokens tokens;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final programs = catalog.programsForUniversity(uni.id)
      ..sort((a, b) => a.code.compareTo(b.code));
    final minScore = catalog.minCompetitionScoreFor(uni.id);
    final sources = _collectSources(catalog, uni, programs);
    final profileState = ref.watch(profileProvider);

    return ListView(
      padding: EdgeInsets.zero,
      children: [
        _HeroHeader(uni: uni, tokens: tokens).animate().fadeIn(
          duration: 300.ms,
        ),
        // ── Action buttons ───────────────────────────────────────────────
        Padding(
          padding: EdgeInsets.fromLTRB(
            tokens.screenPadding,
            tokens.gapMd,
            tokens.screenPadding,
            0,
          ),
          child: IntrinsicHeight(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Expanded(
                  child: _ActionButton(
                    icon: Icons.analytics_outlined,
                    label: 'Мои шансы',
                    color: AppColors.primary,
                    onTap: () => _showChancesSheet(context, ref, programs),
                  ),
                ),
                SizedBox(width: tokens.gapSm),
                Expanded(
                  child: _ActionButton(
                    icon: Icons.folder_outlined,
                    label: 'Документы',
                    color: AppColors.successGreen,
                    onTap: () =>
                        _showDocumentsSheet(context, profileState),
                  ),
                ),
              ],
            ),
          ),
        ),
        Padding(
          padding: EdgeInsets.fromLTRB(
            tokens.screenPadding,
            tokens.gapLg,
            tokens.screenPadding,
            tokens.screenPadding,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ── Quick stats ─────────────────────────────────────────────
              _StatsRow(
                programCount: programs.length,
                minCompetition: minScore,
                hasDormitory: uni.hasDormitory,
                tokens: tokens,
              ).animate().fadeIn(delay: 80.ms, duration: 300.ms),

              // ── About ───────────────────────────────────────────────────
              if (uni.description != null &&
                  uni.description!.trim().isNotEmpty) ...[
                SizedBox(height: tokens.gapXl),
                _SectionTitle(title: 'О вузе', tokens: tokens),
                SizedBox(height: tokens.gapSm),
                Text(
                  uni.description!,
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    color: AppColors.inkSecondary,
                    height: 1.5,
                  ),
                ),
              ],

              // ── Contacts / links ────────────────────────────────────────
              if (uni.website != null || uni.nameKz != null) ...[
                SizedBox(height: tokens.gapXl),
                _SectionTitle(title: 'Информация', tokens: tokens),
                SizedBox(height: tokens.gapSm),
                _InfoCard(uni: uni, tokens: tokens),
              ],

              // ── Dormitory photo ─────────────────────────────────────────
              if (uni.dormImageUrl != null) ...[
                SizedBox(height: tokens.gapXl),
                _SectionTitle(title: 'Общежитие', tokens: tokens),
                SizedBox(height: tokens.gapSm),
                ClipRRect(
                  borderRadius: BorderRadius.circular(tokens.radiusMd),
                  child: Image.network(
                    uni.dormImageUrl!,
                    height: 160,
                    width: double.infinity,
                    fit: BoxFit.cover,
                    // Broken URL → collapse silently, never break the screen.
                    errorBuilder: (_, _, _) => const SizedBox.shrink(),
                  ),
                ),
              ],

              // ── Programs ────────────────────────────────────────────────
              SizedBox(height: tokens.gapXl),
              if (programs.isEmpty)
                _EmptyPrograms(tokens: tokens)
              else ...[
                _SectionTitle(
                  title: 'Программы (${programs.length})',
                  tokens: tokens,
                ),
                SizedBox(height: tokens.gapXs),
                Text(
                  'Балл — минимум для участия в конкурсе на грант (НЦТ). '
                  'Это не проходной балл. Нажми на программу, чтобы раскрыть '
                  'детали.',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: AppColors.inkSecondary,
                  ),
                ),
                SizedBox(height: tokens.gapMd),
                ...programs.map(
                  (p) => Padding(
                    padding: EdgeInsets.only(bottom: tokens.gapMd),
                    child: _ProgramCard(
                      program: p,
                      offering: _offeringFor(catalog, uni.id, p.code),
                      thresholds: catalog.thresholdsFor(uni.id, p.code),
                      tokens: tokens,
                    ),
                  ),
                ),
              ],

              // ── Sources ─────────────────────────────────────────────────
              if (sources.isNotEmpty) ...[
                SizedBox(height: tokens.gapLg),
                _SourcesNote(sources: sources, tokens: tokens),
              ],
            ],
          ),
        ),
      ],
    );
  }

  // ── Sheet launchers ─────────────────────────────────────────────────────────

  void _showChancesSheet(
    BuildContext context,
    WidgetRef ref,
    List<EducationProgram> programs,
  ) {
    unawaited(
      showModalBottomSheet<void>(
        context: context,
        isScrollControlled: true,
        useSafeArea: true,
        builder: (ctx) => _ChancesSheet(
          uni: uni,
          catalog: catalog,
          programs: programs,
          profileState: ref.read(profileProvider),
        ),
      ),
    );
  }

  void _showDocumentsSheet(BuildContext context, ProfileState profileState) {
    unawaited(
      showModalBottomSheet<void>(
        context: context,
        isScrollControlled: true,
        useSafeArea: true,
        builder: (ctx) => _DocumentsSheet(
          uni: uni,
          profileState: profileState,
        ),
      ),
    );
  }
}

// ── Action button ─────────────────────────────────────────────────────────────

class _ActionButton extends StatelessWidget {
  const _ActionButton({
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final tokens =
        Theme.of(context).extension<AppTokens>() ?? AppTokens.defaults();
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(
          vertical: tokens.gapMd,
          horizontal: tokens.gapSm,
        ),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(tokens.radiusMd),
          border: Border.all(color: color.withValues(alpha: 0.25)),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 18, color: color),
            SizedBox(width: tokens.gapXs),
            Text(
              label,
              style: Theme.of(context).textTheme.labelLarge?.copyWith(
                color: color,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Hero ─────────────────────────────────────────────────────────────────────

class _HeroHeader extends StatelessWidget {
  const _HeroHeader({required this.uni, required this.tokens});

  final UniversityRecord uni;
  final AppTokens tokens;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final colors = _heroGradient(uni.type);
    final subtitle = uni.nameEn ?? uni.nameKz;
    final hasImage = uni.imageUrl != null;

    return SizedBox(
      width: double.infinity,
      child: Stack(
        children: [
          // ── Background: image (when available) or gradient ───────────────
          if (hasImage)
            Positioned.fill(
              child: ClipRRect(
                borderRadius: BorderRadius.vertical(
                  bottom: Radius.circular(tokens.radiusLg),
                ),
                child: ColorFiltered(
                  colorFilter: const ColorFilter.mode(
                    Color(0x80000000),
                    BlendMode.srcOver,
                  ),
                  child: Image.network(
                    uni.imageUrl!,
                    fit: BoxFit.cover,
                    frameBuilder:
                        (context, child, frame, wasSynchronouslyLoaded) {
                      if (wasSynchronouslyLoaded || frame != null) return child;
                      return AnimatedOpacity(
                        opacity: frame == null ? 0 : 1,
                        duration: const Duration(milliseconds: 400),
                        child: child,
                      );
                    },
                    errorBuilder: (ctx, e, s) => Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: colors,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            )
          else
            Positioned.fill(
              child: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: colors,
                  ),
                  borderRadius: BorderRadius.vertical(
                    bottom: Radius.circular(tokens.radiusLg),
                  ),
                ),
              ),
            ),
          // ── Text overlay ─────────────────────────────────────────────────
          Container(
            width: double.infinity,
            decoration: BoxDecoration(
              gradient: hasImage
                  ? LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Colors.transparent,
                        Colors.black.withValues(alpha: 0.55),
                      ],
                    )
                  : null,
              borderRadius: BorderRadius.vertical(
                bottom: Radius.circular(tokens.radiusLg),
              ),
            ),
            padding: EdgeInsets.fromLTRB(
              tokens.screenPadding,
              tokens.gapXxl + tokens.gapLg,
              tokens.screenPadding,
              tokens.gapXl,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    if (!hasImage)
                      Container(
                        width: 60,
                        height: 60,
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.2),
                          borderRadius:
                              BorderRadius.circular(tokens.radiusMd),
                          border: Border.all(
                            color: Colors.white.withValues(alpha: 0.35),
                          ),
                        ),
                        child: Text(
                          uni.nameRu.trim().isNotEmpty
                              ? uni.nameRu.trim().substring(0, 1).toUpperCase()
                              : '?',
                          style: textTheme.headlineMedium?.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    if (!hasImage) SizedBox(width: tokens.gapMd),
                    Expanded(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          if (uni.type != null)
                            Text(
                              universityTypeLabel(uni.type!).toUpperCase(),
                              style: textTheme.labelLarge?.copyWith(
                                color: Colors.white.withValues(alpha: 0.85),
                                letterSpacing: 0.6,
                                fontSize: 11,
                              ),
                            ),
                          const SizedBox(height: 2),
                          Text(
                            uni.nameRu,
                            style: textTheme.headlineMedium?.copyWith(
                              color: Colors.white,
                              fontWeight: FontWeight.w700,
                              height: 1.1,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                if (subtitle != null && subtitle.trim().isNotEmpty) ...[
                  SizedBox(height: tokens.gapSm),
                  Text(
                    subtitle,
                    style: textTheme.bodyLarge?.copyWith(
                      color: Colors.white.withValues(alpha: 0.85),
                    ),
                  ),
                ],
                SizedBox(height: tokens.gapMd),
                Wrap(
                  spacing: tokens.gapSm,
                  runSpacing: tokens.gapXs,
                  children: [
                    _HeroPill(icon: Icons.location_on_rounded, label: uni.city),
                    if (uni.website != null)
                      _HeroPill(
                        icon: Icons.language_rounded,
                        label: uni.website!,
                      ),
                    if (uni.hasDormitory ?? false)
                      const _HeroPill(
                        icon: Icons.bed_rounded,
                        label: 'Есть общежитие',
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
}

class _HeroPill extends StatelessWidget {
  const _HeroPill({required this.icon, required this.label});

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.18),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 13, color: Colors.white),
          const SizedBox(width: 5),
          Text(
            label,
            style: Theme.of(context).textTheme.labelLarge?.copyWith(
              color: Colors.white,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }
}

// ── Stats row ────────────────────────────────────────────────────────────────

class _StatsRow extends StatelessWidget {
  const _StatsRow({
    required this.programCount,
    required this.minCompetition,
    required this.hasDormitory,
    required this.tokens,
  });

  final int programCount;
  final int? minCompetition;
  final bool? hasDormitory;
  final AppTokens tokens;

  @override
  Widget build(BuildContext context) {
    // IntrinsicHeight bounds the Row's cross-axis extent so the stretch below
    // is safe inside a scroll view (see CLAUDE.md blank-screen pitfall).
    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Expanded(
            child: _StatCard(
              value: '$programCount',
              label: 'программ',
              color: AppColors.primary,
              tokens: tokens,
            ),
          ),
          SizedBox(width: tokens.gapSm),
          Expanded(
            child: _StatCard(
              value: minCompetition != null ? '$minCompetition' : '—',
              label: 'конкурс от, б.',
              color: AppColors.successGreen,
              tokens: tokens,
            ),
          ),
          SizedBox(width: tokens.gapSm),
          Expanded(
            child: _StatCard(
              value: hasDormitory == null
                  ? '—'
                  : (hasDormitory! ? 'Да' : 'Нет'),
              label: 'общежитие',
              color: AppColors.goldKey,
              tokens: tokens,
            ),
          ),
        ],
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  const _StatCard({
    required this.value,
    required this.label,
    required this.color,
    required this.tokens,
  });

  final String value;
  final String label;
  final Color color;
  final AppTokens tokens;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: tokens.gapSm,
        vertical: tokens.gapMd,
      ),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(tokens.radiusMd),
        border: Border.all(color: color.withValues(alpha: 0.18)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            value,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: textTheme.headlineMedium?.copyWith(
              color: color,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            textAlign: TextAlign.center,
            style: textTheme.bodySmall?.copyWith(color: AppColors.inkSecondary),
          ),
        ],
      ),
    );
  }
}

// ── Info card ────────────────────────────────────────────────────────────────

class _InfoCard extends StatelessWidget {
  const _InfoCard({required this.uni, required this.tokens});

  final UniversityRecord uni;
  final AppTokens tokens;

  @override
  Widget build(BuildContext context) {
    final rows = <Widget>[];
    if (uni.nameKz != null && uni.nameKz!.trim().isNotEmpty) {
      rows.add(_InfoRow(icon: Icons.translate_rounded, label: uni.nameKz!));
    }
    if (uni.website != null) {
      rows.add(
        _InfoRow(
          icon: Icons.language_rounded,
          label: uni.website!,
          onTap: () => openExternalLink(context, uni.website!),
        ),
      );
    }

    return AppCard(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          for (var i = 0; i < rows.length; i++) ...[
            if (i > 0) Divider(height: tokens.gapLg, color: AppColors.border),
            rows[i],
          ],
        ],
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  const _InfoRow({required this.icon, required this.label, this.onTap});

  final IconData icon;
  final String label;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final isLink = onTap != null;
    final row = Row(
      children: [
        Icon(
          icon,
          size: 18,
          color: isLink ? AppColors.primary : AppColors.inkSecondary,
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Text(
            label,
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
              color: isLink ? AppColors.primary : AppColors.ink,
              decoration: isLink ? TextDecoration.underline : null,
              decorationColor: isLink ? AppColors.primary : null,
            ),
          ),
        ),
        if (isLink)
          const Icon(
            Icons.open_in_new_rounded,
            size: 16,
            color: AppColors.primary,
          ),
      ],
    );
    if (!isLink) return row;
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 2),
        child: row,
      ),
    );
  }
}

// ── Program card (expandable) ────────────────────────────────────────────────

class _ProgramCard extends StatefulWidget {
  const _ProgramCard({
    required this.program,
    required this.offering,
    required this.thresholds,
    required this.tokens,
  });

  final EducationProgram program;
  final UniversityProgram? offering;
  final List<GrantThreshold> thresholds;
  final AppTokens tokens;

  @override
  State<_ProgramCard> createState() => _ProgramCardState();
}

class _ProgramCardState extends State<_ProgramCard> {
  bool _expanded = false;

  @override
  Widget build(BuildContext context) {
    final tokens = widget.tokens;
    final p = widget.program;
    final textTheme = Theme.of(context).textTheme;

    final subjects = [p.entSubject1, p.entSubject2]
        .whereType<String>()
        .where((s) => s.isNotEmpty)
        .toList();
    final competitionMin = widget.thresholds
        .where(
          (t) => t.metric == GrantMetric.competitionMin && t.minScore != null,
        )
        .toList();
    final topScore = competitionMin.isNotEmpty
        ? competitionMin
              .map((t) => t.minScore!)
              .reduce((a, b) => a < b ? a : b)
        : null;

    return AppCard(
      padding: EdgeInsets.all(tokens.cardPadding),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header (tap to expand)
          GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: () => setState(() => _expanded = !_expanded),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Text(
                        p.nameRu,
                        style: textTheme.titleMedium?.copyWith(
                          color: AppColors.ink,
                        ),
                      ),
                    ),
                    SizedBox(width: tokens.gapSm),
                    _CodeBadge(code: p.code, tokens: tokens),
                    SizedBox(width: tokens.gapXs),
                    AnimatedRotation(
                      turns: _expanded ? 0.5 : 0,
                      duration: const Duration(milliseconds: 180),
                      child: const Icon(
                        Icons.keyboard_arrow_down_rounded,
                        color: AppColors.inkSecondary,
                      ),
                    ),
                  ],
                ),
                if (subjects.isNotEmpty) ...[
                  SizedBox(height: tokens.gapSm),
                  Wrap(
                    spacing: tokens.gapXs,
                    runSpacing: tokens.gapXs,
                    children: [
                      for (final s in subjects) _SubjectChip(label: s),
                    ],
                  ),
                ],
                if (topScore != null) ...[
                  SizedBox(height: tokens.gapSm),
                  Row(
                    children: [
                      const Icon(
                        Icons.emoji_events_outlined,
                        size: 16,
                        color: AppColors.successGreen,
                      ),
                      const SizedBox(width: 6),
                      Text(
                        'Конкурс от $topScore б.',
                        style: textTheme.labelLarge?.copyWith(
                          color: AppColors.successGreen,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ],
              ],
            ),
          ),

          // Expanded details
          AnimatedSize(
            duration: const Duration(milliseconds: 200),
            curve: Curves.easeOut,
            alignment: Alignment.topCenter,
            child: _expanded
                ? _ProgramDetails(
                    program: p,
                    offering: widget.offering,
                    thresholds: widget.thresholds,
                    tokens: tokens,
                  )
                : const SizedBox(width: double.infinity),
          ),
        ],
      ),
    );
  }
}

class _ProgramDetails extends StatelessWidget {
  const _ProgramDetails({
    required this.program,
    required this.offering,
    required this.thresholds,
    required this.tokens,
  });

  final EducationProgram program;
  final UniversityProgram? offering;
  final List<GrantThreshold> thresholds;
  final AppTokens tokens;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final o = offering;
    final facts = <Widget>[];

    if (o != null && o.languages.isNotEmpty) {
      facts.add(
        _FactRow(
          label: 'Языки обучения',
          value: o.languages.map(_languageLabel).join(', '),
        ),
      );
    }
    if (o?.grantPlaces != null) {
      facts.add(_FactRow(label: 'Грантовых мест', value: '${o!.grantPlaces}'));
    }
    if (o?.tuitionPerYearKzt != null) {
      facts.add(
        _FactRow(
          label: 'Стоимость в год',
          value: '${_formatKzt(o!.tuitionPerYearKzt!)} ₸',
        ),
      );
    }

    return Padding(
      padding: EdgeInsets.only(top: tokens.gapMd),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Divider(height: 1, color: AppColors.border),
          SizedBox(height: tokens.gapMd),
          if (facts.isNotEmpty) ...[
            ...facts,
            SizedBox(height: tokens.gapSm),
          ],
          // Thresholds
          if (thresholds.isEmpty)
            Text(
              'Данных по баллам пока нет.',
              style: textTheme.bodySmall?.copyWith(
                color: AppColors.inkSecondary,
              ),
            )
          else ...[
            Text(
              'Баллы по годам',
              style: textTheme.labelLarge?.copyWith(color: AppColors.ink),
            ),
            SizedBox(height: tokens.gapXs),
            ...thresholds.map(
              (t) => _ThresholdRow(threshold: t, tokens: tokens),
            ),
          ],
        ],
      ),
    );
  }
}

class _ThresholdRow extends StatelessWidget {
  const _ThresholdRow({required this.threshold, required this.tokens});

  final GrantThreshold threshold;
  final AppTokens tokens;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final t = threshold;
    final score = t.minScore == null
        ? '—'
        : (t.maxScore != null ? '${t.minScore}–${t.maxScore}' : '${t.minScore}');
    final quota = t.quotaType == QuotaType.general
        ? ''
        : ' · ${quotaTypeLabel(t.quotaType)}';

    return Padding(
      padding: EdgeInsets.symmetric(vertical: tokens.gapXs),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${grantMetricLabel(t.metric)} · ${t.year}$quota',
                  style: textTheme.bodySmall?.copyWith(color: AppColors.ink),
                ),
                if (!t.isVerified)
                  Text(
                    'не подтверждено',
                    style: textTheme.bodySmall?.copyWith(
                      color: AppColors.goldKey,
                      fontSize: 11,
                    ),
                  ),
              ],
            ),
          ),
          SizedBox(width: tokens.gapSm),
          Text(
            score,
            style: textTheme.titleMedium?.copyWith(
              color: AppColors.ink,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}

// ── "Спросить шансы" bottom sheet ───────────────────────────────────────────

/// Mini-form + AI/offline evaluation for the student's admission chances.
class _ChancesSheet extends StatefulWidget {
  const _ChancesSheet({
    required this.uni,
    required this.catalog,
    required this.programs,
    required this.profileState,
  });

  final UniversityRecord uni;
  final UniversityCatalog catalog;
  final List<EducationProgram> programs;
  final ProfileState profileState;

  @override
  State<_ChancesSheet> createState() => _ChancesSheetState();
}

class _ChancesSheetState extends State<_ChancesSheet> {
  final _entController = TextEditingController();
  String? _result;
  bool _loading = false;

  @override
  void initState() {
    super.initState();
    // Pre-fill ENT if the student entered SAT/IELTS (no dedicated ENT field —
    // they will type it manually in the sheet).
  }

  @override
  void dispose() {
    _entController.dispose();
    super.dispose();
  }

  Future<void> _evaluate() async {
    setState(() {
      _loading = true;
      _result = null;
    });

    final entRaw = _entController.text.trim();
    final entScore = int.tryParse(entRaw);
    final profile = widget.profileState.profile;

    // Build the anonymised student object (no PII).
    final studentPayload = {
      'gpaBand': profile.gpaBand,
      'ent': entScore,
      'ielts': profile.ieltsScore,
      'sat': profile.satScore,
      'majors': profile.targetMajors,
    };

    final programsPayload = widget.programs
        .map((p) {
          final thresholds = widget.catalog.thresholdsFor(
            widget.uni.id,
            p.code,
          );
          final minScore = thresholds
              .where(
                (t) =>
                    t.metric == GrantMetric.competitionMin &&
                    t.minScore != null,
              )
              .map((t) => t.minScore!)
              .fold<int?>(null, (best, s) => best == null || s < best ? s : best);
          return {'name': p.nameRu, 'minScore': minScore};
        })
        .toList();

    // Try the Edge Function first; fall back to local evaluation.
    if (AppConfig.hasSupabase) {
      try {
        final response = await Supabase.instance.client.functions.invoke(
          'chances',
          body: {
            'university': {
              'id': widget.uni.id,
              'name_ru': widget.uni.nameRu,
            },
            'programs': programsPayload,
            'student': studentPayload,
          },
        );
        final data = response.data;
        if (data is Map && data['result'] is String) {
          if (mounted) {
            setState(() {
              _result = data['result'] as String;
              _loading = false;
            });
          }
          return;
        }
      } on Object {
        // Fall through to local evaluation.
      }
    }

    // Local evaluation — compare ENT against the lowest competition min
    // across all programs.
    final localResult = _localEvaluate(
      entScore: entScore,
      programs: widget.programs,
      catalog: widget.catalog,
      universityId: widget.uni.id,
      profile: profile,
    );

    if (mounted) {
      setState(() {
        _result = localResult;
        _loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final tokens =
        Theme.of(context).extension<AppTokens>() ?? AppTokens.defaults();
    final textTheme = Theme.of(context).textTheme;
    final profile = widget.profileState.profile;

    return DraggableScrollableSheet(
      expand: false,
      initialChildSize: 0.9,
      minChildSize: 0.5,
      maxChildSize: 0.95,
      builder: (ctx, scrollController) {
        return Container(
          decoration: BoxDecoration(
            color: Theme.of(context).scaffoldBackgroundColor,
            borderRadius: const BorderRadius.vertical(
              top: Radius.circular(20),
            ),
          ),
          child: ListView(
            controller: scrollController,
            padding: EdgeInsets.all(tokens.screenPadding),
            children: [
              // Handle
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  margin: EdgeInsets.only(bottom: tokens.gapMd),
                  decoration: BoxDecoration(
                    color: AppColors.border,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              Text(
                'Мои шансы',
                style: textTheme.headlineMedium?.copyWith(
                  color: AppColors.ink,
                ),
              ),
              SizedBox(height: tokens.gapXs),
              Text(
                widget.uni.nameRu,
                style: textTheme.bodyLarge?.copyWith(
                  color: AppColors.inkSecondary,
                ),
              ),
              SizedBox(height: tokens.gapLg),

              // ── Profile data ───────────────────────────────────────────
              if (profile.gpaBand != null || profile.ieltsScore != null) ...[
                Text(
                  'Данные из профиля',
                  style: textTheme.labelLarge?.copyWith(
                    color: AppColors.ink,
                  ),
                ),
                SizedBox(height: tokens.gapSm),
                AppCard(
                  child: Wrap(
                    spacing: tokens.gapMd,
                    runSpacing: tokens.gapXs,
                    children: [
                      if (profile.gpaBand != null)
                        _InfoChip(
                          label: 'ГПА ${profile.gpaBand}',
                        ),
                      if (profile.ieltsScore != null)
                        _InfoChip(
                          label: 'IELTS ${profile.ieltsScore}',
                        ),
                      if (profile.satScore != null)
                        _InfoChip(
                          label: 'SAT ${profile.satScore}',
                        ),
                    ],
                  ),
                ),
                SizedBox(height: tokens.gapMd),
              ],

              // ── ENT score input ────────────────────────────────────────
              Text(
                'Твой балл ЕНТ',
                style: textTheme.labelLarge?.copyWith(color: AppColors.ink),
              ),
              SizedBox(height: tokens.gapSm),
              TextField(
                controller: _entController,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  hintText: 'Например, 110',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(tokens.radiusMd),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(tokens.radiusMd),
                    borderSide: const BorderSide(color: AppColors.border),
                  ),
                  contentPadding: EdgeInsets.symmetric(
                    horizontal: tokens.gapMd,
                    vertical: tokens.gapSm,
                  ),
                ),
              ),
              SizedBox(height: tokens.gapLg),

              // ── Evaluate button ────────────────────────────────────────
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _loading ? null : _evaluate,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                    padding: EdgeInsets.symmetric(vertical: tokens.gapMd),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(tokens.radiusMd),
                    ),
                  ),
                  child: _loading
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : const Text('Оценить шансы'),
                ),
              ),

              // ── Result ────────────────────────────────────────────────
              if (_result != null) ...[
                SizedBox(height: tokens.gapLg),
                const Divider(color: AppColors.border),
                SizedBox(height: tokens.gapMd),
                Text(
                  'Оценка',
                  style: textTheme.titleLarge?.copyWith(color: AppColors.ink),
                ),
                SizedBox(height: tokens.gapSm),
                Text(
                  _result!,
                  style: textTheme.bodyLarge?.copyWith(
                    color: AppColors.ink,
                    height: 1.6,
                  ),
                ),
                SizedBox(height: tokens.gapXl),
                Text(
                  'Это оценочный расчёт, а не гарантия. Проверяй актуальные '
                  'конкурсные баллы на сайте вуза.',
                  style: textTheme.bodySmall?.copyWith(
                    color: AppColors.inkSecondary,
                    fontStyle: FontStyle.italic,
                  ),
                ),
              ],
            ],
          ),
        );
      },
    );
  }
}

class _InfoChip extends StatelessWidget {
  const _InfoChip({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: AppColors.primary.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        label,
        style: Theme.of(context).textTheme.labelLarge?.copyWith(
          color: AppColors.primary,
        ),
      ),
    );
  }
}

/// Offline/local admission-chances estimate.
///
/// Compares [entScore] against the lowest competition-entry minimum across the
/// university's programs. Never inflates: it explains the range honestly and
/// gives concrete improvement advice.
String _localEvaluate({
  required int? entScore,
  required List<EducationProgram> programs,
  required UniversityCatalog catalog,
  required String universityId,
  required StudentProfile profile,
}) {
  if (entScore == null) {
    return 'Введи балл ЕНТ, чтобы получить оценку.';
  }

  // Collect verified competition minimums across all programs.
  final scores = <int>[];
  for (final p in programs) {
    final ts = catalog.thresholdsFor(universityId, p.code);
    for (final t in ts) {
      if (t.metric == GrantMetric.competitionMin && t.minScore != null) {
        scores.add(t.minScore!);
      }
    }
  }

  final buffer = StringBuffer();

  if (scores.isEmpty) {
    buffer.writeln(
      'Данных о конкурсных баллах этого вуза пока нет. '
      'Уточни актуальный минимум на сайте вуза или НЦТ.',
    );
  } else {
    scores.sort();
    final minRequired = scores.first;
    final maxRequired = scores.last;
    final diff = entScore - minRequired;

    if (diff >= 15) {
      buffer
        ..writeln('✅ Твой балл ($entScore) значительно выше минимума для '
            'участия в конкурсе ($minRequired–$maxRequired б.). '
            'При прочих равных шансы попасть в конкурс — высокие.')
        ..writeln()
        ..writeln(
          'Дальнейший план:\n'
          '• Выбери 2–3 программы с наиболее близкими к тебе баллами.\n'
          '• Убедись, что сдавал нужные профильные предметы ЕНТ.\n'
          '• Подай документы как можно раньше.',
        );
    } else if (diff >= 0) {
      buffer
        ..writeln('⚠️ Твой балл ($entScore) позволяет участвовать в конкурсе '
            '(минимум $minRequired б.), но ты в зоне риска — проходной балл '
            'исторически выше минимума допуска.')
        ..writeln()
        ..writeln(
          'Что делать:\n'
          '• Рассмотри программы с более низким конкурсом внутри этого вуза.\n'
          '• Добавь 1–2 запасных вуза с более низким барьером.\n'
          '• Уточни, есть ли сельская или иная квота для твоей ситуации.',
        );
    } else {
      buffer
        ..writeln('❌ Твой балл ($entScore) ниже минимума для участия в '
            'конкурсе на грант ($minRequired б.) в этом вузе.')
        ..writeln()
        ..writeln(
          'Варианты:\n'
          '• Поищи вузы с более низким порогом — в каталоге есть фильтр '
          '"Балл до…".\n'
          '• Уточни условия поступления на платное: барьер может быть ниже.\n'
          '• Рассмотри возможность улучшить балл на следующий год.',
        );
    }
  }

  // Bonus: mention IELTS/SAT if available.
  final extras = <String>[];
  if (profile.ieltsScore != null) {
    extras.add('IELTS ${profile.ieltsScore}');
  }
  if (profile.satScore != null) {
    extras.add('SAT ${profile.satScore}');
  }
  if (extras.isNotEmpty) {
    buffer.writeln();
    buffer.writeln(
      'Международные сертификаты (${extras.join(', ')}) могут стать '
      'конкурентным преимуществом — уточни в приёмной комиссии.',
    );
  }

  return buffer.toString().trim();
}

// ── "Собрать документы" bottom sheet ─────────────────────────────────────────

/// Standard KZ university admission document checklist.
const _kzAdmissionDocs = [
  'Удостоверение личности / паспорт',
  'Аттестат о среднем образовании',
  'Сертификат ЕНТ',
  'Медицинская справка (форма 075-У)',
  'Справка об обязательном медосмотре',
  '6 фотографий 3×4 см',
  'Заявление о зачислении',
];

class _DocumentsSheet extends StatelessWidget {
  const _DocumentsSheet({
    required this.uni,
    required this.profileState,
  });

  final UniversityRecord uni;
  final ProfileState profileState;

  @override
  Widget build(BuildContext context) {
    final tokens =
        Theme.of(context).extension<AppTokens>() ?? AppTokens.defaults();
    final textTheme = Theme.of(context).textTheme;
    final attachedDocs = profileState.profile.attachedDocs.toSet();
    final packages = profileState.packages;

    // Build the checklist from the profile's existing document packages,
    // falling back to the standard KZ admission list.
    final List<_DocItem> items;
    if (packages.isNotEmpty) {
      items = packages
          .expand((pkg) => pkg.items)
          .map(
            (item) => _DocItem(
              label: item.label,
              isAttached: item.isAttached,
            ),
          )
          .toList();
    } else {
      items = _kzAdmissionDocs.map((label) {
        // Consider a doc attached if any attached-doc path contains the label
        // keyword (simple best-effort match).
        final attached = attachedDocs.any(
          (p) => p.toLowerCase().contains(label.split(' ').first.toLowerCase()),
        );
        return _DocItem(label: label, isAttached: attached);
      }).toList();
    }

    final missing = items.where((d) => !d.isAttached).length;

    return DraggableScrollableSheet(
      expand: false,
      initialChildSize: 0.7,
      minChildSize: 0.4,
      maxChildSize: 0.9,
      builder: (ctx, scrollController) {
        return Container(
          decoration: BoxDecoration(
            color: Theme.of(context).scaffoldBackgroundColor,
            borderRadius: const BorderRadius.vertical(
              top: Radius.circular(20),
            ),
          ),
          child: ListView(
            controller: scrollController,
            padding: EdgeInsets.all(tokens.screenPadding),
            children: [
              // Handle
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  margin: EdgeInsets.only(bottom: tokens.gapMd),
                  decoration: BoxDecoration(
                    color: AppColors.border,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              Text(
                'Документы для поступления',
                style: textTheme.headlineMedium?.copyWith(
                  color: AppColors.ink,
                ),
              ),
              SizedBox(height: tokens.gapXs),
              Text(
                uni.nameRu,
                style: textTheme.bodyLarge?.copyWith(
                  color: AppColors.inkSecondary,
                ),
              ),
              SizedBox(height: tokens.gapLg),

              // ── Checklist ─────────────────────────────────────────────
              ...items.map(
                (doc) => Padding(
                  padding: EdgeInsets.only(bottom: tokens.gapSm),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Icon(
                        doc.isAttached
                            ? Icons.check_circle_rounded
                            : Icons.radio_button_unchecked_rounded,
                        size: 22,
                        color: doc.isAttached
                            ? AppColors.successGreen
                            : AppColors.border,
                      ),
                      SizedBox(width: tokens.gapSm),
                      Expanded(
                        child: Text(
                          doc.label,
                          style: textTheme.bodyLarge?.copyWith(
                            color: doc.isAttached
                                ? AppColors.ink
                                : AppColors.inkSecondary,
                            decoration: doc.isAttached
                                ? TextDecoration.lineThrough
                                : null,
                            decorationColor: AppColors.inkSecondary,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              if (missing > 0) ...[
                SizedBox(height: tokens.gapMd),
                AppCard(
                  child: Row(
                    children: [
                      const Icon(
                        Icons.info_outline_rounded,
                        color: AppColors.goldKey,
                        size: 18,
                      ),
                      SizedBox(width: tokens.gapSm),
                      Expanded(
                        child: Text(
                          'Не хватает $missing ${_docWord(missing)}. '
                          'Добавь их в разделе «Профиль → Документы».',
                          style: textTheme.bodyLarge?.copyWith(
                            color: AppColors.ink,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],

              SizedBox(height: tokens.gapLg),

              // ── Qabylday button ───────────────────────────────────────
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () =>
                      openExternalLink(context, 'https://qabylday.kz'),
                  icon: const Icon(Icons.open_in_new_rounded, size: 18),
                  label: const Text('Подать документы через Qabylday'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                    padding: EdgeInsets.symmetric(
                      vertical: tokens.gapMd,
                      horizontal: tokens.gapLg,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(tokens.radiusMd),
                    ),
                  ),
                ),
              ),
              SizedBox(height: tokens.gapXl),
            ],
          ),
        );
      },
    );
  }

  String _docWord(int n) {
    final mod10 = n % 10;
    final mod100 = n % 100;
    if (mod10 == 1 && mod100 != 11) return 'документа';
    if (mod10 >= 2 && mod10 <= 4 && (mod100 < 12 || mod100 > 14)) {
      return 'документов';
    }
    return 'документов';
  }
}

class _DocItem {
  const _DocItem({required this.label, required this.isAttached});

  final String label;
  final bool isAttached;
}

// ── Small widgets ────────────────────────────────────────────────────────────

class _SectionTitle extends StatelessWidget {
  const _SectionTitle({required this.title, required this.tokens});

  final String title;
  final AppTokens tokens;

  @override
  Widget build(BuildContext context) {
    return Text(
      title,
      style: Theme.of(
        context,
      ).textTheme.titleLarge?.copyWith(color: AppColors.ink),
    );
  }
}

class _CodeBadge extends StatelessWidget {
  const _CodeBadge({required this.code, required this.tokens});

  final String code;
  final AppTokens tokens;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: AppColors.surfaceTint,
        borderRadius: BorderRadius.circular(tokens.radiusSm),
      ),
      child: Text(
        code,
        style: Theme.of(context).textTheme.labelLarge?.copyWith(
          color: AppColors.inkSecondary,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}

class _SubjectChip extends StatelessWidget {
  const _SubjectChip({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: AppColors.primary.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        label,
        style: Theme.of(context).textTheme.labelLarge?.copyWith(
          color: AppColors.primary,
          fontSize: 12,
        ),
      ),
    );
  }
}

class _FactRow extends StatelessWidget {
  const _FactRow({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Text(
              label,
              style: textTheme.bodyLarge?.copyWith(
                color: AppColors.inkSecondary,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Text(
            value,
            style: textTheme.bodyLarge?.copyWith(
              color: AppColors.ink,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

class _EmptyPrograms extends StatelessWidget {
  const _EmptyPrograms({required this.tokens});

  final AppTokens tokens;

  @override
  Widget build(BuildContext context) {
    return AppCard(
      child: Row(
        children: [
          const Icon(
            Icons.info_outline_rounded,
            color: AppColors.inkSecondary,
          ),
          SizedBox(width: tokens.gapSm),
          Expanded(
            child: Text(
              'Для этого вуза пока нет данных по программам и грантам.',
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                color: AppColors.inkSecondary,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _SourcesNote extends StatelessWidget {
  const _SourcesNote({required this.sources, required this.tokens});

  final List<String> sources;
  final AppTokens tokens;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Icon(
              Icons.verified_outlined,
              size: 14,
              color: AppColors.inkSecondary,
            ),
            const SizedBox(width: 6),
            Text(
              'Источники данных',
              style: textTheme.labelLarge?.copyWith(
                color: AppColors.inkSecondary,
              ),
            ),
          ],
        ),
        SizedBox(height: tokens.gapXs),
        for (final s in sources)
          Padding(
            padding: const EdgeInsets.only(bottom: 6),
            child: _SourceLink(url: s),
          ),
      ],
    );
  }
}

/// A tappable source citation that opens the URL in the browser.
class _SourceLink extends StatelessWidget {
  const _SourceLink({required this.url});

  final String url;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return InkWell(
      onTap: () => openExternalLink(context, url),
      borderRadius: BorderRadius.circular(8),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 4),
        child: Row(
          children: [
            const Icon(
              Icons.open_in_new_rounded,
              size: 14,
              color: AppColors.primary,
            ),
            const SizedBox(width: 6),
            Expanded(
              child: Text(
                url,
                style: textTheme.bodySmall?.copyWith(
                  color: AppColors.primary,
                  decoration: TextDecoration.underline,
                  decorationColor: AppColors.primary,
                  fontSize: 12,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _CircleBackButton extends StatelessWidget {
  const _CircleBackButton();

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.black.withValues(alpha: 0.25),
      shape: const CircleBorder(),
      child: InkWell(
        customBorder: const CircleBorder(),
        onTap: () => Navigator.of(context).maybePop(),
        child: const SizedBox(
          width: 40,
          height: 40,
          child: Icon(Icons.arrow_back_rounded, color: Colors.white, size: 22),
        ),
      ),
    );
  }
}

class _MessageState extends StatelessWidget {
  const _MessageState({required this.icon, required this.message});

  final IconData icon;
  final String message;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 48, color: AppColors.border),
            const SizedBox(height: 12),
            Text(
              message,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                color: AppColors.inkSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Helpers ──────────────────────────────────────────────────────────────────

/// Gradient colors for the hero, keyed off the university [type].
List<Color> _heroGradient(UniversityType? type) {
  switch (type) {
    case UniversityType.national:
      return const [Color(0xFF4255FF), Color(0xFF6E8BFF)];
    case UniversityType.autonomous:
      return const [Color(0xFF12B76A), Color(0xFF45D496)];
    case UniversityType.international:
      return const [Color(0xFFFF8A3D), Color(0xFFFF5DA2)];
    case UniversityType.private:
      return const [Color(0xFFEF5DA8), Color(0xFFA259FF)];
    case UniversityType.state:
    case null:
      return const [Color(0xFF3D4E81), Color(0xFF6E7BB8)];
  }
}

/// Russian label for an ЕНТ/instruction language code.
String _languageLabel(String code) {
  switch (code.toLowerCase()) {
    case 'kz':
      return 'каз';
    case 'ru':
      return 'рус';
    case 'en':
      return 'англ';
    default:
      return code;
  }
}

/// Formats a tenge amount with thin thousands separators, e.g. 1200000 →
/// "1 200 000".
String _formatKzt(int amount) {
  final digits = amount.toString();
  final buffer = StringBuffer();
  for (var i = 0; i < digits.length; i++) {
    if (i > 0 && (digits.length - i) % 3 == 0) buffer.write(' ');
    buffer.write(digits[i]);
  }
  return buffer.toString();
}

/// The university's offering of [code], or null when not present.
UniversityProgram? _offeringFor(
  UniversityCatalog catalog,
  String universityId,
  String code,
) {
  for (final o in catalog.offerings) {
    if (o.universityId == universityId && o.programCode == code) return o;
  }
  return null;
}

/// Distinct provenance URLs across the university, its programs and thresholds.
List<String> _collectSources(
  UniversityCatalog catalog,
  UniversityRecord uni,
  List<EducationProgram> programs,
) {
  final set = <String>{};
  if (uni.sourceUrl != null && uni.sourceUrl!.trim().isNotEmpty) {
    set.add(uni.sourceUrl!.trim());
  }
  for (final p in programs) {
    final list = catalog.thresholdsFor(uni.id, p.code);
    for (final t in list) {
      if (t.sourceUrl.trim().isNotEmpty) set.add(t.sourceUrl.trim());
    }
  }
  return set.toList();
}
