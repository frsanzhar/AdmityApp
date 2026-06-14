import 'package:admity/core/theme/app_colors.dart';
import 'package:admity/core/theme/app_radii.dart';
import 'package:admity/core/theme/app_spacing.dart';
import 'package:admity/core/theme/app_theme_extension.dart';
import 'package:admity/features/chancing_world/domain/cds_chancing.dart';
import 'package:admity/features/chancing_world/presentation/cds_providers.dart';
import 'package:admity/features/universities/domain/university.dart';
import 'package:admity/features/universities/presentation/universities_providers.dart';
import 'package:admity/shared/widgets/bento_card.dart';
import 'package:admity/shared/widgets/chance_pill.dart';
import 'package:admity/shared/widgets/primary_button.dart';
import 'package:admity/shared/widgets/progress_ring.dart';
import 'package:admity/shared/widgets/section_header.dart';
import 'package:admity/shared/widgets/source_note.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:url_launcher/url_launcher.dart';

/// Full detail for one university: overview, acceptance rate, mission and
/// values, programs, cost and aid, and illustrative admitted-student cases.
class UniversityDetailScreen extends ConsumerWidget {
  /// Creates the detail screen for the university with this [slug].
  const UniversityDetailScreen({required this.slug, super.key});

  /// The university slug to display.
  final String slug;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final uni =
        ref.watch(universitiesProvider).where((u) => u.slug == slug).firstOrNull;
    if (uni == null) {
      return const Scaffold(body: Center(child: Text('Не найдено')));
    }

    final saved = ref.watch(collegeListProvider).contains(slug);
    final sat = ref.watch(satScoreProvider);
    final cds = uni.cdsUniversityKey == null
        ? null
        : ref.watch(cdsByKeyProvider(uni.cdsUniversityKey!));
    final chancing = (cds != null)
        ? CdsChancing.evaluate(snapshot: cds, satComposite: sat ?? 1300)
        : null;

    return Scaffold(
      appBar: AppBar(title: Text(uni.name)),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(AppSpacing.screen),
          children: [
            _Header(uni: uni, chancing: chancing),
            const SizedBox(height: AppSpacing.lg),
            if (uni.isNeedBlindFullNeed) ...[
              _NeedBlindBanner(),
              const SizedBox(height: AppSpacing.lg),
            ],
            _OverviewSection(uni: uni),
            const SizedBox(height: AppSpacing.lg),
            if (uni.acceptanceRate != null) ...[
              _AcceptanceSection(uni: uni),
              const SizedBox(height: AppSpacing.lg),
            ],
            if (uni.mission != null || uni.values.isNotEmpty) ...[
              _MissionSection(uni: uni),
              const SizedBox(height: AppSpacing.lg),
            ],
            _ProgramsSection(uni: uni),
            const SizedBox(height: AppSpacing.lg),
            _CostSection(uni: uni),
            const SizedBox(height: AppSpacing.lg),
            if (uni.admittedCases.isNotEmpty) ...[
              _AdmittedCasesSection(cases: uni.admittedCases),
              const SizedBox(height: AppSpacing.lg),
            ],
            PrimaryButton(
              label: saved ? 'В моём списке ✓' : 'Добавить в список',
              icon: saved ? Icons.check_rounded : Icons.add_rounded,
              onPressed: () =>
                  ref.read(collegeListProvider.notifier).toggle(slug),
            ),
            if (uni.website != null) ...[
              const SizedBox(height: AppSpacing.sm),
              _WebsiteButton(website: uni.website!),
            ],
            const SizedBox(height: AppSpacing.lg),
            if (uni.scope == UniScope.world)
              const SourceNote(
                text: 'Стоимость, помощь и проценты приёма меняются ежегодно — '
                    'проверь на admissions-странице вуза.',
              )
            else
              const SourceNote(
                text: 'Поступление по сертификату ЕНТ; пороги вузов меняются.',
              ),
            const SizedBox(height: AppSpacing.xl),
          ],
        ),
      ),
    );
  }
}

/// Top header: country, ranking, languages and chancing pill.
class _Header extends StatelessWidget {
  const _Header({required this.uni, required this.chancing});

  final University uni;
  final WorldChancingResult? chancing;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: Text(uni.country, style: context.text.titleMedium),
            ),
            if (uni.ranking != null)
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 5,
                ),
                decoration: BoxDecoration(
                  color: context.tokens.info.withValues(alpha: 0.12),
                  borderRadius: AppRadii.brPill,
                ),
                child: Text(
                  '#${uni.ranking}',
                  style: context.text.labelMedium?.copyWith(
                    color: context.tokens.info,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            if (chancing != null) ...[
              const SizedBox(width: AppSpacing.xs),
              ChancePill.world(chancing!.category),
            ],
          ],
        ),
        const SizedBox(height: AppSpacing.xs),
        Wrap(
          spacing: AppSpacing.xs,
          runSpacing: AppSpacing.xxs,
          children: [
            for (final lang in uni.languages)
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: context.tokens.surfaceSunken,
                  borderRadius: AppRadii.brPill,
                ),
                child: Text(lang, style: context.text.labelSmall),
              ),
          ],
        ),
      ],
    );
  }
}

/// Need-blind / full-need reassurance banner.
class _NeedBlindBanner extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return BentoCard(
      accent: context.tokens.success,
      child: Row(
        children: [
          Icon(Icons.verified_rounded, color: context.tokens.success),
          const SizedBox(width: AppSpacing.sm),
          Expanded(
            child: Text(
              'Need-blind + full-need: заявка на финпомощь НЕ снижает '
              'шанс поступить.',
              style: context.text.bodyMedium,
            ),
          ),
        ],
      ),
    );
  }
}

/// Overview card: key facts and quick highlights.
class _OverviewSection extends StatelessWidget {
  const _OverviewSection({required this.uni});

  final University uni;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SectionHeader(title: 'Обзор'),
        const SizedBox(height: AppSpacing.sm),
        BentoCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _InfoRow(
                icon: Icons.public_rounded,
                label: 'Страна',
                value: uni.country,
              ),
              _InfoRow(
                icon: Icons.translate_rounded,
                label: 'Языки обучения',
                value: uni.languages.join(', '),
              ),
              if (uni.ranking != null)
                _InfoRow(
                  icon: Icons.emoji_events_rounded,
                  label: 'Рейтинг',
                  value: '#${uni.ranking}',
                ),
              for (final fact in uni.notableFacts)
                _InfoRow(
                  icon: Icons.star_rounded,
                  label: 'Факт',
                  value: fact,
                ),
            ],
          ),
        ),
      ],
    );
  }
}

/// Acceptance-rate section with a [ProgressRing] visual.
class _AcceptanceSection extends StatelessWidget {
  const _AcceptanceSection({required this.uni});

  final University uni;

  @override
  Widget build(BuildContext context) {
    final rate = uni.acceptanceRate!;
    final percent = (rate * 100).round();
    final color = rate <= 0.15
        ? context.tokens.chanceReach
        : rate <= 0.5
            ? context.tokens.chanceTarget
            : context.tokens.chanceLikely;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SectionHeader(title: 'Процент приёма'),
        const SizedBox(height: AppSpacing.sm),
        BentoCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  ProgressRing(
                    progress: rate.clamp(0.0, 1.0),
                    color: color,
                    label: '$percent%',
                  ),
                  const SizedBox(width: AppSpacing.md),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          uni.isAcceptanceRateEstimate
                              ? 'Принимают ~$percent% (оценка)'
                              : 'Принимают около $percent% абитуриентов',
                          style: context.text.titleSmall,
                        ),
                        const SizedBox(height: AppSpacing.xxs),
                        Text(
                          rate <= 0.15
                              ? 'Очень высокая селективность'
                              : rate <= 0.5
                                  ? 'Умеренная селективность'
                                  : 'Высокий процент приёма',
                          style: context.text.bodySmall?.copyWith(
                            color: context.tokens.textMuted,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.sm),
              SourceNote(
                text: uni.isAcceptanceRateEstimate
                    ? 'Это оценка: официальный процент приёма не публикуется'
                    : 'Процент приёма за последний доступный год',
                year: uni.acceptanceRateYear,
              ),
            ],
          ),
        ),
      ],
    );
  }
}

/// Mission and values section.
class _MissionSection extends StatelessWidget {
  const _MissionSection({required this.uni});

  final University uni;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SectionHeader(title: 'Миссия и ценности'),
        const SizedBox(height: AppSpacing.sm),
        BentoCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (uni.mission != null)
                Text(uni.mission!, style: context.text.bodyMedium),
              if (uni.mission != null && uni.values.isNotEmpty)
                const SizedBox(height: AppSpacing.md),
              if (uni.values.isNotEmpty)
                Wrap(
                  spacing: AppSpacing.xs,
                  runSpacing: AppSpacing.xs,
                  children: [
                    for (final value in uni.values)
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: AppSpacing.sm,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: context.tokens.info.withValues(alpha: 0.1),
                          borderRadius: AppRadii.brPill,
                        ),
                        child: Text(
                          value,
                          style: context.text.labelMedium?.copyWith(
                            color: context.tokens.info,
                          ),
                        ),
                      ),
                  ],
                ),
            ],
          ),
        ),
      ],
    );
  }
}

/// Programs section as chips.
class _ProgramsSection extends StatelessWidget {
  const _ProgramsSection({required this.uni});

  final University uni;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SectionHeader(title: 'Программы'),
        const SizedBox(height: AppSpacing.sm),
        BentoCard(
          child: Wrap(
            spacing: AppSpacing.xs,
            runSpacing: AppSpacing.xs,
            children: [
              for (final program in uni.programs)
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.sm,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: context.tokens.surfaceSunken,
                    borderRadius: AppRadii.brPill,
                  ),
                  child: Text(program, style: context.text.labelMedium),
                ),
            ],
          ),
        ),
      ],
    );
  }
}

/// Cost and financial-aid section.
class _CostSection extends StatelessWidget {
  const _CostSection({required this.uni});

  final University uni;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SectionHeader(title: 'Стоимость и финпомощь'),
        const SizedBox(height: AppSpacing.sm),
        BentoCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (uni.tuition != null)
                _InfoRow(
                  icon: Icons.payments_rounded,
                  label: 'Стоимость',
                  value: uni.tuition!,
                ),
              if (uni.finAidNotes != null)
                _InfoRow(
                  icon: Icons.volunteer_activism_rounded,
                  label: 'Финпомощь',
                  value: uni.finAidNotes!,
                ),
              if (uni.tuition == null && uni.finAidNotes == null)
                Text(
                  'Данных о стоимости пока нет — проверь на сайте вуза.',
                  style: context.text.bodyMedium?.copyWith(
                    color: context.tokens.textMuted,
                  ),
                ),
            ],
          ),
        ),
      ],
    );
  }
}

/// Dedicated, visually distinct section for illustrative admitted-student
/// cases. Always labelled «иллюстративный пример».
class _AdmittedCasesSection extends StatelessWidget {
  const _AdmittedCasesSection({required this.cases});

  final List<AdmittedCase> cases;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SectionHeader(
          title: 'Кейсы поступивших',
          subtitle: 'Собирательные профили — не реальные люди',
        ),
        const SizedBox(height: AppSpacing.sm),
        for (final c in cases) ...[
          _AdmittedCaseCard(item: c),
          const SizedBox(height: AppSpacing.sm),
        ],
      ],
    );
  }
}

/// A single illustrative admitted-student card.
class _AdmittedCaseCard extends StatelessWidget {
  const _AdmittedCaseCard({required this.item});

  final AdmittedCase item;

  @override
  Widget build(BuildContext context) {
    return BentoCard(
      color: AppColors.tealSoft.withValues(alpha: 0.16),
      accent: context.tokens.info,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (item.isIllustrative)
            Container(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.xs,
                vertical: 3,
              ),
              decoration: BoxDecoration(
                color: context.tokens.warning.withValues(alpha: 0.16),
                borderRadius: AppRadii.brPill,
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.lightbulb_outline_rounded,
                    size: 14,
                    color: context.tokens.warning,
                  ),
                  const SizedBox(width: AppSpacing.xxs),
                  Text(
                    'Иллюстративный пример',
                    style: context.text.labelSmall?.copyWith(
                      color: context.tokens.warning,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
            ),
          const SizedBox(height: AppSpacing.sm),
          Text(item.profileSummary, style: context.text.titleSmall),
          const SizedBox(height: AppSpacing.sm),
          _CaseLine(
            icon: Icons.check_circle_outline_rounded,
            label: 'Что сработало',
            value: item.whatWorked,
            color: context.tokens.success,
          ),
          const SizedBox(height: AppSpacing.xs),
          _CaseLine(
            icon: Icons.flag_outlined,
            label: 'Итог',
            value: item.outcome,
            color: context.tokens.info,
          ),
        ],
      ),
    );
  }
}

/// One labelled line inside an admitted-case card.
class _CaseLine extends StatelessWidget {
  const _CaseLine({
    required this.icon,
    required this.label,
    required this.value,
    required this.color,
  });

  final IconData icon;
  final String label;
  final String value;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 18, color: color),
        const SizedBox(width: AppSpacing.xs),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: context.text.labelSmall?.copyWith(
                  color: context.tokens.textMuted,
                ),
              ),
              Text(value, style: context.text.bodyMedium),
            ],
          ),
        ),
      ],
    );
  }
}

/// A labelled info row with a leading icon.
class _InfoRow extends StatelessWidget {
  const _InfoRow({
    required this.icon,
    required this.label,
    required this.value,
  });

  final IconData icon;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.sm),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 18, color: context.tokens.textMuted),
          const SizedBox(width: AppSpacing.xs),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: context.text.labelSmall?.copyWith(
                    color: context.tokens.textMuted,
                  ),
                ),
                const SizedBox(height: 2),
                Text(value, style: context.text.bodyMedium),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// Button that opens the university website in an external browser.
class _WebsiteButton extends StatelessWidget {
  const _WebsiteButton({required this.website});

  final String website;

  Future<void> _open() async {
    final uri = Uri.tryParse(website);
    if (uri != null) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  @override
  Widget build(BuildContext context) {
    return OutlinedButton.icon(
      onPressed: _open,
      icon: const Icon(Icons.open_in_new_rounded),
      label: const Text('Сайт вуза'),
    );
  }
}
