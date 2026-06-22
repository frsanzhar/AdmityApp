/// Career-orientation test (RIASEC-style).
///
/// 30 questions across 6 RIASEC dimensions (5 per dimension).
/// Each answer: Нет=0 / Нейтрально=1 / Да=2.
/// Top-2 dimensions determine result label, saved to StudentProfile.careerResult.
library;

import 'dart:async';

import 'package:admity/core/theme/app_colors.dart';
import 'package:admity/core/theme/app_tokens.dart';
import 'package:admity/features/profile/application/profile_notifier.dart';
import 'package:admity/shared/widgets/app_card.dart';
import 'package:admity/shared/widgets/app_scaffold.dart';
import 'package:admity/shared/widgets/featured_button.dart';
import 'package:admity/shared/widgets/mascot_slot.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

// ── RIASEC data ───────────────────────────────────────────────────────────────

enum _Dimension { r, i, a, s, e, c }

class _Question {
  const _Question(this.text, this.dimension);
  final String text;
  final _Dimension dimension;
}

const _questions = <_Question>[
  // Realistic
  _Question('Мне нравится собирать и чинить вещи своими руками', _Dimension.r),
  _Question('Я предпочитаю работу на свежем воздухе', _Dimension.r),
  _Question('Мне интересны технические устройства и механизмы', _Dimension.r),
  _Question('Я люблю физический труд', _Dimension.r),
  _Question(
    'Мне нравится работать с инструментами и оборудованием',
    _Dimension.r,
  ),
  // Investigative
  _Question('Мне нравится решать сложные задачи и головоломки', _Dimension.i),
  _Question(
    'Я с удовольствием провожу время за чтением научных статей',
    _Dimension.i,
  ),
  _Question('Мне интересно изучать, как устроен мир вокруг нас', _Dimension.i),
  _Question(
    'Я люблю анализировать данные и искать закономерности',
    _Dimension.i,
  ),
  _Question('Мне нравится проводить эксперименты', _Dimension.i),
  // Artistic
  _Question('Я люблю рисовать, писать или музицировать', _Dimension.a),
  _Question(
    'Мне нравится создавать что-то красивое или оригинальное',
    _Dimension.a,
  ),
  _Question('Я часто нахожу нестандартные решения', _Dimension.a),
  _Question('Творческое самовыражение важно для меня', _Dimension.a),
  _Question('Мне нравится дизайн и эстетика', _Dimension.a),
  // Social
  _Question('Мне нравится помогать другим людям', _Dimension.s),
  _Question('Я хорошо чувствую настроение и эмоции других', _Dimension.s),
  _Question('Мне нравится работать в команде', _Dimension.s),
  _Question('Я с удовольствием обучаю других', _Dimension.s),
  _Question('Волонтёрство и помощь обществу важны для меня', _Dimension.s),
  // Enterprising
  _Question('Мне нравится убеждать людей и вести переговоры', _Dimension.e),
  _Question('Я готов брать на себя ответственность и руководить', _Dimension.e),
  _Question('Меня привлекает создание бизнеса', _Dimension.e),
  _Question('Мне нравится соревноваться и побеждать', _Dimension.e),
  _Question('Я умею продавать идеи и продукты', _Dimension.e),
  // Conventional
  _Question('Мне нравится работать с цифрами и документами', _Dimension.c),
  _Question('Я ценю порядок и организованность', _Dimension.c),
  _Question(
    'Мне нравится следовать чётким правилам и инструкциям',
    _Dimension.c,
  ),
  _Question(
    'Мне интересна бухгалтерия, финансы или управление данными',
    _Dimension.c,
  ),
  _Question(
    'Я люблю систематизировать и классифицировать информацию',
    _Dimension.c,
  ),
];

String _computeResult(List<int?> answers) {
  final scores = <_Dimension, int>{
    for (final d in _Dimension.values) d: 0,
  };
  for (var i = 0; i < _questions.length; i++) {
    final ans = i < answers.length ? answers[i] : null;
    if (ans != null) {
      scores[_questions[i].dimension] = scores[_questions[i].dimension]! + ans;
    }
  }

  final sorted = scores.entries.toList()
    ..sort((a, b) => b.value.compareTo(a.value));
  final top1 = sorted[0].key;
  final top2 = sorted[1].key;

  // Combinations
  final pair = {top1, top2};
  if (pair.containsAll({_Dimension.r, _Dimension.i})) {
    return 'Инженер-исследователь';
  }
  if (pair.containsAll({_Dimension.r, _Dimension.a})) {
    return 'Архитектор / Дизайнер продуктов';
  }
  if (pair.containsAll({_Dimension.i, _Dimension.a})) {
    return 'Учёный-новатор';
  }
  if (pair.containsAll({_Dimension.s, _Dimension.e})) {
    return 'HR-менеджер / Тренер';
  }
  if (pair.containsAll({_Dimension.e, _Dimension.c})) {
    return 'Финансовый директор';
  }
  if (pair.containsAll({_Dimension.s, _Dimension.a})) {
    return 'Арт-терапевт / Педагог-творец';
  }

  // Single dominant
  return switch (top1) {
    _Dimension.r => 'Инженер / Технолог',
    _Dimension.i => 'Учёный / Аналитик',
    _Dimension.a => 'Творческий деятель / Дизайнер',
    _Dimension.s => 'Педагог / Психолог',
    _Dimension.e => 'Предприниматель / Менеджер',
    _Dimension.c => 'Финансист / Администратор',
  };
}

// ── Screen ────────────────────────────────────────────────────────────────────

/// Career orientation test — RIASEC-style, 30 questions, animated.
class CareerTestScreen extends ConsumerStatefulWidget {
  const CareerTestScreen({super.key});

  @override
  ConsumerState<CareerTestScreen> createState() => _CareerTestScreenState();
}

class _CareerTestScreenState extends ConsumerState<CareerTestScreen> {
  final List<int?> _answers = List.filled(_questions.length, null);
  int _current = 0;
  bool _showResult = false;
  String _result = '';

  void _answer(int value) {
    setState(() => _answers[_current] = value);
    if (_current < _questions.length - 1) {
      unawaited(
        Future<void>.delayed(const Duration(milliseconds: 200), () {
          if (mounted) setState(() => _current++);
        }),
      );
    } else {
      unawaited(
        Future<void>.delayed(const Duration(milliseconds: 200), () {
          if (mounted) unawaited(_finishTest());
        }),
      );
    }
  }

  Future<void> _finishTest() async {
    final result = _computeResult(_answers);
    final profile = ref.read(profileProvider).profile;
    await ref
        .read(profileProvider.notifier)
        .saveProfile(profile.copyWith(careerResult: result));
    if (mounted) {
      setState(() {
        _result = result;
        _showResult = true;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final tokens =
        Theme.of(context).extension<AppTokens>() ?? AppTokens.defaults();

    return AppScaffold(
      body: _showResult
          ? _ResultView(result: _result, tokens: tokens)
          : Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                _TestHeader(
                  current: _current,
                  total: _questions.length,
                  tokens: tokens,
                  onBack: () {
                    if (_current > 0) setState(() => _current--);
                  },
                ),
                Expanded(
                  child: SingleChildScrollView(
                    padding: EdgeInsets.symmetric(
                      horizontal: tokens.screenPadding,
                    ),
                    child: AnimatedSwitcher(
                      duration: const Duration(milliseconds: 300),
                      transitionBuilder: (child, animation) {
                        return FadeTransition(
                          opacity: animation,
                          child: SlideTransition(
                            position: Tween<Offset>(
                              begin: const Offset(0.05, 0),
                              end: Offset.zero,
                            ).animate(animation),
                            child: child,
                          ),
                        );
                      },
                      child: KeyedSubtree(
                        key: ValueKey(_current),
                        child: _QuestionCard(
                          questionNumber: _current + 1,
                          total: _questions.length,
                          text: _questions[_current].text,
                          selected: _answers[_current],
                          onAnswer: _answer,
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

// ── Header ────────────────────────────────────────────────────────────────────

class _TestHeader extends StatelessWidget {
  const _TestHeader({
    required this.current,
    required this.total,
    required this.tokens,
    required this.onBack,
  });

  final int current;
  final int total;
  final AppTokens tokens;
  final VoidCallback onBack;

  @override
  Widget build(BuildContext context) {
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
                  onPressed: current > 0 ? onBack : null,
                  icon: Icon(
                    Icons.arrow_back_rounded,
                    color: current > 0 ? AppColors.ink : AppColors.inkSecondary,
                  ),
                  padding: EdgeInsets.zero,
                ),
              ),
              Expanded(
                child: Text(
                  'Профориентация',
                  textAlign: TextAlign.center,
                  style: Theme.of(
                    context,
                  ).textTheme.titleLarge?.copyWith(color: AppColors.ink),
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
                  value: (current + 1) / total,
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

// ── Warning card ──────────────────────────────────────────────────────────────

class _WarningCard extends StatelessWidget {
  const _WarningCard({required this.tokens});
  final AppTokens tokens;

  @override
  Widget build(BuildContext context) {
    return AppCard(
      color: AppColors.goldKey.withValues(alpha: 0.08),
      child: Row(
        children: [
          const Icon(
            Icons.timer_outlined,
            color: AppColors.goldKey,
            size: 28,
          ),
          SizedBox(width: tokens.gapMd),
          Expanded(
            child: Text(
              'Тест займёт ~10–15 минут. Ответь честно — результат будет точнее.',
              style: Theme.of(
                context,
              ).textTheme.bodyLarge?.copyWith(color: AppColors.ink),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Question card ─────────────────────────────────────────────────────────────

class _QuestionCard extends StatelessWidget {
  const _QuestionCard({
    required this.questionNumber,
    required this.total,
    required this.text,
    required this.selected,
    required this.onAnswer,
    required this.tokens,
  });

  final int questionNumber;
  final int total;
  final String text;
  final int? selected;
  final ValueChanged<int> onAnswer;
  final AppTokens tokens;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(height: tokens.gapMd),

        // Show warning card for first question
        if (questionNumber == 1) ...[
          _WarningCard(tokens: tokens).animate().fadeIn(duration: 400.ms),
          SizedBox(height: tokens.gapLg),
        ],

        AppCard(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Вопрос $questionNumber',
                style: textTheme.labelLarge?.copyWith(
                  color: AppColors.inkSecondary,
                ),
              ),
              SizedBox(height: tokens.gapMd),
              Text(
                text,
                style: textTheme.titleLarge?.copyWith(color: AppColors.ink),
              ),
              SizedBox(height: tokens.gapXl),
              Row(
                children: [
                  Expanded(
                    child: _AnswerChip(
                      label: 'Нет',
                      value: 0,
                      selected: selected == 0,
                      color: AppColors.errorRed,
                      onTap: onAnswer,
                    ),
                  ),
                  SizedBox(width: tokens.gapSm),
                  Expanded(
                    child: _AnswerChip(
                      label: 'Нейтрально',
                      value: 1,
                      selected: selected == 1,
                      color: AppColors.inkSecondary,
                      onTap: onAnswer,
                    ),
                  ),
                  SizedBox(width: tokens.gapSm),
                  Expanded(
                    child: _AnswerChip(
                      label: 'Да',
                      value: 2,
                      selected: selected == 2,
                      color: AppColors.successGreen,
                      onTap: onAnswer,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ).animate().fadeIn(duration: 300.ms).slideY(begin: 0.05, end: 0),

        SizedBox(height: tokens.gapXxl),
      ],
    );
  }
}

class _AnswerChip extends StatelessWidget {
  const _AnswerChip({
    required this.label,
    required this.value,
    required this.selected,
    required this.color,
    required this.onTap,
  });

  final String label;
  final int value;
  final bool selected;
  final Color color;
  final ValueChanged<int> onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => onTap(value),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        height: 48,
        decoration: BoxDecoration(
          color: selected
              ? color.withValues(alpha: 0.15)
              : AppColors.surfaceTint,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: selected ? color : AppColors.border,
            width: selected ? 2 : 1,
          ),
        ),
        alignment: Alignment.center,
        child: Text(
          label,
          style: Theme.of(context).textTheme.labelLarge?.copyWith(
            color: selected ? color : AppColors.inkSecondary,
          ),
        ),
      ),
    );
  }
}

// ── Result view ───────────────────────────────────────────────────────────────

class _ResultView extends StatelessWidget {
  const _ResultView({required this.result, required this.tokens});
  final String result;
  final AppTokens tokens;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return SingleChildScrollView(
      padding: EdgeInsets.symmetric(
        horizontal: tokens.screenPadding,
        vertical: tokens.gapXxl,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const MascotSlot(
                size: 130,
                tag: 'career_result',
                state: MascotState.celebrate,
              )
              .animate()
              .scale(
                begin: const Offset(0.6, 0.6),
                duration: 600.ms,
                curve: Curves.easeOutBack,
              )
              .fadeIn(),
          SizedBox(height: tokens.gapXxl),
          Text(
                'Результат готов!',
                style: textTheme.headlineLarge?.copyWith(color: AppColors.ink),
              )
              .animate()
              .fadeIn(delay: 300.ms, duration: 400.ms)
              .slideY(begin: 0.1, end: 0),
          SizedBox(height: tokens.gapLg),
          AppCard(
                color: AppColors.primary.withValues(alpha: 0.05),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'Твой профиль',
                      style: textTheme.labelLarge?.copyWith(
                        color: AppColors.inkSecondary,
                      ),
                    ),
                    SizedBox(height: tokens.gapSm),
                    Text(
                      result,
                      textAlign: TextAlign.center,
                      style: textTheme.headlineLarge?.copyWith(
                        color: AppColors.primary,
                      ),
                    ),
                    SizedBox(height: tokens.gapMd),
                    Text(
                      'Результат сохранён в твоём профиле. Ты можешь пройти тест снова в любое время.',
                      textAlign: TextAlign.center,
                      style: textTheme.bodyLarge?.copyWith(
                        color: AppColors.inkSecondary,
                      ),
                    ),
                  ],
                ),
              )
              .animate()
              .fadeIn(delay: 500.ms, duration: 400.ms)
              .slideY(begin: 0.1, end: 0),
          SizedBox(height: tokens.gapXxl),
          FeaturedButton(
            label: 'Закрыть',
            onPressed: () => context.pop(),
          ).animate().fadeIn(delay: 700.ms, duration: 400.ms),
          SizedBox(height: tokens.gapXxl),
        ],
      ),
    );
  }
}
