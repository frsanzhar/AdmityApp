import 'package:admity/core/theme/app_colors.dart';
import 'package:admity/core/theme/app_tokens.dart';
import 'package:admity/features/universities/data/university_catalog_providers.dart';
import 'package:admity/features/universities/domain/university_catalog.dart';
import 'package:admity/shared/widgets/app_card.dart';
import 'package:admity/shared/widgets/app_scaffold.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Detail page for one catalog university: programs (ГОП) with their ЕНТ
/// profile subjects and the honest grant figures.
///
/// Honesty: scores shown are `competition_min` (минимум для допуска к конкурсу),
/// explicitly labelled — never presented as a проходной балл.
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
      body: catalogAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (_, _) => _back(
          context,
          tokens,
          const Center(child: Text('Не удалось загрузить вуз')),
        ),
        data: (catalog) {
          final uni = catalog.universityById(universityId);
          if (uni == null) {
            return _back(
              context,
              tokens,
              const Center(child: Text('Вуз не найден')),
            );
          }
          return _Content(catalog: catalog, uni: uni, tokens: tokens);
        },
      ),
    );
  }

  Widget _back(BuildContext context, AppTokens tokens, Widget child) {
    return Column(
      children: [
        _BackBar(tokens: tokens),
        Expanded(child: child),
      ],
    );
  }
}

class _Content extends StatelessWidget {
  const _Content({
    required this.catalog,
    required this.uni,
    required this.tokens,
  });

  final UniversityCatalog catalog;
  final UniversityRecord uni;
  final AppTokens tokens;

  @override
  Widget build(BuildContext context) {
    final programs = catalog.programsForUniversity(uni.id)
      ..sort((a, b) => a.code.compareTo(b.code));

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        _BackBar(tokens: tokens),
        Expanded(
          child: ListView(
            padding: EdgeInsets.fromLTRB(
              tokens.screenPadding,
              0,
              tokens.screenPadding,
              tokens.screenPadding,
            ),
            children: [
              // ── Header ──────────────────────────────────────────────────────
              Text(
                uni.nameRu,
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  color: AppColors.ink,
                ),
              ),
              SizedBox(height: tokens.gapSm),
              Wrap(
                spacing: tokens.gapSm,
                runSpacing: tokens.gapXs,
                children: [
                  _chip(context, Icons.location_on_outlined, uni.city),
                  if (uni.type != null)
                    _chip(context, Icons.account_balance_outlined,
                        universityTypeLabel(uni.type!)),
                  if (uni.website != null)
                    _chip(context, Icons.language_rounded, uni.website!),
                ],
              ),
              SizedBox(height: tokens.gapLg),

              // ── Programs ────────────────────────────────────────────────────
              if (programs.isEmpty)
                Text(
                  'Для этого вуза пока нет данных по программам и грантам.',
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    color: AppColors.inkSecondary,
                  ),
                )
              else ...[
                Text(
                  'Программы (${programs.length})',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    color: AppColors.ink,
                  ),
                ),
                SizedBox(height: tokens.gapXs),
                Text(
                  'Балл — минимум для участия в конкурсе на грант (НЦТ, 2024). '
                  'Это не проходной балл.',
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
                      thresholds: catalog.thresholdsFor(uni.id, p.code),
                      tokens: tokens,
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ],
    );
  }

  Widget _chip(BuildContext context, IconData icon, String label) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 14, color: AppColors.inkSecondary),
        const SizedBox(width: 4),
        Text(label, style: Theme.of(context).textTheme.bodySmall),
      ],
    );
  }
}

class _ProgramCard extends StatelessWidget {
  const _ProgramCard({
    required this.program,
    required this.thresholds,
    required this.tokens,
  });

  final EducationProgram program;
  final List<GrantThreshold> thresholds;
  final AppTokens tokens;

  @override
  Widget build(BuildContext context) {
    final subjects = [program.entSubject1, program.entSubject2]
        .whereType<String>()
        .where((s) => s.isNotEmpty)
        .toList();
    final competition = thresholds
        .where((t) =>
            t.metric == GrantMetric.competitionMin && t.minScore != null)
        .toList();

    return AppCard(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Text(
                  program.nameRu,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: AppColors.ink,
                  ),
                ),
              ),
              SizedBox(width: tokens.gapSm),
              Text(
                program.code,
                style: Theme.of(context).textTheme.labelLarge?.copyWith(
                  color: AppColors.inkSecondary,
                ),
              ),
            ],
          ),
          if (subjects.isNotEmpty) ...[
            SizedBox(height: tokens.gapXs),
            Text(
              'ЕНТ: ${subjects.join(' · ')}',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: AppColors.inkSecondary,
              ),
            ),
          ],
          if (competition.isNotEmpty) ...[
            SizedBox(height: tokens.gapSm),
            for (final t in competition)
              Text(
                '${grantMetricLabel(t.metric)} (${t.year}): ${t.minScore}',
                style: Theme.of(context).textTheme.labelLarge?.copyWith(
                  color: AppColors.ink,
                ),
              ),
          ],
        ],
      ),
    );
  }
}

class _BackBar extends StatelessWidget {
  const _BackBar({required this.tokens});

  final AppTokens tokens;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.fromLTRB(
        tokens.gapSm,
        tokens.gapSm,
        tokens.screenPadding,
        tokens.gapSm,
      ),
      child: Row(
        children: [
          IconButton(
            icon: const Icon(Icons.arrow_back_rounded, color: AppColors.ink),
            onPressed: () => Navigator.of(context).maybePop(),
          ),
        ],
      ),
    );
  }
}
