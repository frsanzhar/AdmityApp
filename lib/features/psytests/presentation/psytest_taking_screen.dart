/// Screen for taking a single psychological test and viewing its result.
library;

import 'dart:async';

import 'package:admity/core/theme/app_colors.dart';
import 'package:admity/core/theme/app_tokens.dart';
import 'package:admity/features/psytests/application/psytests_notifier.dart';
import 'package:admity/features/psytests/data/psytests_seed.dart';
import 'package:admity/features/psytests/domain/psytest_engine.dart';
import 'package:admity/features/psytests/domain/psytest_models.dart';
import 'package:admity/shared/widgets/app_card.dart';
import 'package:admity/shared/widgets/app_scaffold.dart';
import 'package:admity/shared/widgets/featured_button.dart';
import 'package:admity/shared/widgets/mascot_slot.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

/// Question-by-question test screen with inline result view.
///
/// [testId] must match one of the ids in [psytestsDefs].
class PsytestTakingScreen extends ConsumerStatefulWidget {
  const PsytestTakingScreen({required this.testId, super.key});

  final String testId;

  @override
  ConsumerState<PsytestTakingScreen> createState() =>
      _PsytestTakingScreenState();
}

class _PsytestTakingScreenState extends ConsumerState<PsytestTakingScreen> {
  late final PsyTestDef _def;
  late final List<int?> _answers;
  int _current = 0;
  bool _showResult = false;
  PsyTestResult? _result;

  @override
  void initState() {
    super.initState();
    final matching = psytestsDefs.where((d) => d.id == widget.testId);
    _def = matching.isNotEmpty
        ? matching.first
        : psytestsDefs.first; // fallback
    _answers = List.filled(_def.questions.length, null);
  }

  void _selectOption(int optionIndex) {
    if (_answers[_current] == optionIndex) return;
    setState(() => _answers[_current] = optionIndex);
    // Auto-advance after a brief pause so user sees their selection.
    unawaited(
      Future<void>.delayed(const Duration(milliseconds: 250), () {
        if (!mounted) return;
        if (_current < _def.questions.length - 1) {
          setState(() => _current++);
        } else {
          _finishTest();
        }
      }),
    );
  }

  void _finishTest() {
    final result = scoreTest(_def, _answers);
    unawaited(
      ref.read(psytestsProvider.notifier).submitResult(result),
    );
    setState(() {
      _result = result;
      _showResult = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    final tokens =
        Theme.of(context).extension<AppTokens>() ?? AppTokens.defaults();

    if (_showResult && _result != null) {
      return _ResultScreen(def: _def, result: _result!, tokens: tokens);
    }

    return AppScaffold(
      body: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          _TestHeader(
            def: _def,
            current: _current,
            tokens: tokens,
            onBack: _current > 0
                ? () => setState(() {
                      _current--;
                      _answers[_current] = null;
                    })
                : null,
          ),
          Expanded(
            child: SingleChildScrollView(
              padding: EdgeInsets.symmetric(
                horizontal: tokens.screenPadding,
              ),
              child: AnimatedSwitcher(
                duration: const Duration(milliseconds: 280),
                transitionBuilder: (child, anim) => FadeTransition(
                  opacity: anim,
                  child: SlideTransition(
                    position: Tween<Offset>(
                      begin: const Offset(0.06, 0),
                      end: Offset.zero,
                    ).animate(anim),
                    child: child,
                  ),
                ),
                child: KeyedSubtree(
                  key: ValueKey(_current),
                  child: _QuestionCard(
                    def: _def,
                    questionIndex: _current,
                    selected: _answers[_current],
                    onSelect: _selectOption,
                    tokens: tokens,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Header ─────────────────────────────────────────────────────────────────────

class _TestHeader extends StatelessWidget {
  const _TestHeader({
    required this.def,
    required this.current,
    required this.tokens,
    required this.onBack,
  });

  final PsyTestDef def;
  final int current;
  final AppTokens tokens;
  final VoidCallback? onBack;

  @override
  Widget build(BuildContext context) {
    final total = def.questions.length;
    final progress = (current + 1) / total;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Padding(
          padding: EdgeInsets.fromLTRB(
            tokens.screenPadding,
            tokens.gapMd,
            tokens.screenPadding,
            0,
          ),
          child: Row(
            children: [
              SizedBox(
                width: 44,
                height: 44,
                child: IconButton(
                  onPressed: onBack,
                  padding: EdgeInsets.zero,
                  icon: Icon(
                    Icons.arrow_back_rounded,
                    color: onBack != null
                        ? AppColors.ink
                        : AppColors.inkSecondary,
                  ),
                ),
              ),
              Expanded(
                child: Text(
                  def.title,
                  textAlign: TextAlign.center,
                  style: Theme.of(context)
                      .textTheme
                      .titleLarge
                      ?.copyWith(color: AppColors.ink),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const SizedBox(width: 44),
            ],
          ),
        ),
        Padding(
          padding: EdgeInsets.symmetric(
            horizontal: tokens.screenPadding,
            vertical: tokens.gapSm,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(4),
                child: LinearProgressIndicator(
                  value: progress,
                  minHeight: 6,
                  backgroundColor: AppColors.border,
                  valueColor: const AlwaysStoppedAnimation<Color>(
                    AppColors.primary,
                  ),
                ),
              ),
              SizedBox(height: tokens.gapXs),
              Text(
                '${current + 1} / $total',
                style: Theme.of(context).textTheme.bodySmall,
              ),
            ],
          ),
        ),
      ],
    );
  }
}

// ── Question card ──────────────────────────────────────────────────────────────

class _QuestionCard extends StatelessWidget {
  const _QuestionCard({
    required this.def,
    required this.questionIndex,
    required this.selected,
    required this.onSelect,
    required this.tokens,
  });

  final PsyTestDef def;
  final int questionIndex;
  final int? selected;
  final ValueChanged<int> onSelect;
  final AppTokens tokens;

  @override
  Widget build(BuildContext context) {
    final q = def.questions[questionIndex];
    final textTheme = Theme.of(context).textTheme;

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(height: tokens.gapMd),
        AppCard(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Вопрос ${questionIndex + 1}',
                style: textTheme.labelLarge?.copyWith(
                  color: AppColors.inkSecondary,
                ),
              ),
              SizedBox(height: tokens.gapMd),
              Text(
                q.text,
                style: textTheme.titleLarge
                    ?.copyWith(color: AppColors.ink),
              ),
              SizedBox(height: tokens.gapXl),
              ...q.options.asMap().entries.map(
                (entry) => Padding(
                  padding: EdgeInsets.only(bottom: tokens.gapSm),
                  child: _OptionTile(
                    text: entry.value.text,
                    index: entry.key,
                    selected: selected == entry.key,
                    onTap: () => onSelect(entry.key),
                    tokens: tokens,
                  ),
                ),
              ),
            ],
          ),
        ).animate().fadeIn(duration: 300.ms).slideY(begin: 0.05, end: 0),
        SizedBox(height: tokens.gapXxl),
      ],
    );
  }
}

class _OptionTile extends StatelessWidget {
  const _OptionTile({
    required this.text,
    required this.index,
    required this.selected,
    required this.onTap,
    required this.tokens,
  });

  final String text;
  final int index;
  final bool selected;
  final VoidCallback onTap;
  final AppTokens tokens;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: EdgeInsets.symmetric(
          horizontal: tokens.gapMd,
          vertical: tokens.gapMd,
        ),
        decoration: BoxDecoration(
          color: selected
              ? AppColors.primary.withValues(alpha: 0.08)
              : AppColors.surfaceTint,
          borderRadius: BorderRadius.circular(tokens.radiusMd),
          border: Border.all(
            color: selected
                ? AppColors.primary
                : AppColors.border,
            width: selected ? 2 : 1,
          ),
        ),
        child: Row(
          children: [
            AnimatedContainer(
              duration: const Duration(milliseconds: 180),
              width: 20,
              height: 20,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: selected ? AppColors.primary : AppColors.white,
                border: Border.all(
                  color: selected
                      ? AppColors.primary
                      : AppColors.inkSecondary,
                  width: selected ? 0 : 1.5,
                ),
              ),
              child: selected
                  ? const Icon(
                      Icons.check_rounded,
                      size: 14,
                      color: AppColors.white,
                    )
                  : null,
            ),
            SizedBox(width: tokens.gapMd),
            Expanded(
              child: Text(
                text,
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  color: selected ? AppColors.primary : AppColors.ink,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Result screen ──────────────────────────────────────────────────────────────

class _ResultScreen extends StatelessWidget {
  const _ResultScreen({
    required this.def,
    required this.result,
    required this.tokens,
  });

  final PsyTestDef def;
  final PsyTestResult result;
  final AppTokens tokens;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final topKeys = result.topCategories;
    final topLabel = topKeys
        .map((k) => def.categoryLabels[k] ?? k)
        .join(' + ');
    final topDesc = topKeys.isNotEmpty
        ? (def.categoryDescriptions[topKeys.first] ?? '')
        : '';

    return AppScaffold(
      body: SingleChildScrollView(
        padding: EdgeInsets.symmetric(
          horizontal: tokens.screenPadding,
          vertical: tokens.gapXxl,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const MascotSlot(
                  tag: 'psytest_result',
                  state: MascotState.celebrate,
                )
                .animate()
                .scale(
                  begin: const Offset(0.6, 0.6),
                  duration: 600.ms,
                  curve: Curves.easeOutBack,
                )
                .fadeIn(),
            SizedBox(height: tokens.gapXl),
            Text(
                  'Тест пройден!',
                  style: textTheme.headlineLarge
                      ?.copyWith(color: AppColors.ink),
                )
                .animate()
                .fadeIn(delay: 250.ms, duration: 350.ms)
                .slideY(begin: 0.1, end: 0),
            SizedBox(height: tokens.gapLg),
            AppCard(
                  color: AppColors.primary.withValues(alpha: 0.05),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '${def.emoji} ${def.title}',
                        style: textTheme.labelLarge?.copyWith(
                          color: AppColors.inkSecondary,
                        ),
                      ),
                      SizedBox(height: tokens.gapSm),
                      Text(
                        topLabel,
                        style: textTheme.headlineMedium?.copyWith(
                          color: AppColors.primary,
                        ),
                      ),
                      SizedBox(height: tokens.gapMd),
                      Text(
                        topDesc,
                        style: textTheme.bodyLarge?.copyWith(
                          color: AppColors.ink,
                        ),
                      ),
                      if (topKeys.length > 1) ...[
                        SizedBox(height: tokens.gapMd),
                        _SecondaryResult(
                          def: def,
                          key2: topKeys[1],
                          tokens: tokens,
                        ),
                      ],
                    ],
                  ),
                )
                .animate()
                .fadeIn(delay: 400.ms, duration: 350.ms)
                .slideY(begin: 0.1, end: 0),
            SizedBox(height: tokens.gapLg),
            AppCard(
                  child: Row(
                    children: [
                      const Icon(
                        Icons.lightbulb_outline_rounded,
                        color: AppColors.goldKey,
                        size: 24,
                      ),
                      SizedBox(width: tokens.gapMd),
                      Expanded(
                        child: Text(
                          def.resultHint,
                          style: textTheme.bodyLarge?.copyWith(
                            color: AppColors.ink,
                          ),
                        ),
                      ),
                    ],
                  ),
                )
                .animate()
                .fadeIn(delay: 550.ms, duration: 350.ms),
            SizedBox(height: tokens.gapXxl),
            FeaturedButton(
              label: 'Готово',
              onPressed: () => context.pop(),
            ).animate().fadeIn(delay: 700.ms, duration: 350.ms),
            SizedBox(height: tokens.gapXxl),
          ],
        ),
      ),
    );
  }
}

class _SecondaryResult extends StatelessWidget {
  const _SecondaryResult({
    required this.def,
    required this.key2,
    required this.tokens,
  });

  final PsyTestDef def;
  final String key2;
  final AppTokens tokens;

  @override
  Widget build(BuildContext context) {
    final label = def.categoryLabels[key2] ?? key2;
    final desc = def.categoryDescriptions[key2] ?? '';
    final textTheme = Theme.of(context).textTheme;

    return Container(
      padding: EdgeInsets.all(tokens.gapMd),
      decoration: BoxDecoration(
        color: AppColors.surfaceTint,
        borderRadius: BorderRadius.circular(tokens.radiusMd),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Также выражено: $label',
            style: textTheme.labelLarge?.copyWith(
              color: AppColors.inkSecondary,
            ),
          ),
          if (desc.isNotEmpty) ...[
            SizedBox(height: tokens.gapXs),
            Text(
              desc,
              style: textTheme.bodySmall?.copyWith(
                color: AppColors.inkSecondary,
              ),
            ),
          ],
        ],
      ),
    );
  }
}
