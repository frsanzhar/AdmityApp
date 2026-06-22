import 'dart:async';
import 'dart:math';

import 'package:admity/core/theme/app_colors.dart';
import 'package:admity/core/theme/app_tokens.dart';
import 'package:admity/shared/widgets/app_card.dart';
import 'package:admity/shared/widgets/app_scaffold.dart';
import 'package:admity/shared/widgets/mascot_painter.dart';
import 'package:admity/shared/widgets/mascot_slot.dart';
import 'package:admity/shared/widgets/primary_button.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

// ── Question bank ─────────────────────────────────────────────────────────────

class _CareerQuestion {
  const _CareerQuestion({
    required this.text,
    required this.options,
    required this.category,
  });

  final String text;
  final List<String> options;
  final String category;
}

const _kYesNoSometimes = ['Да', 'Нет', 'Иногда'];
const _kYesNoMaybe = ['Да', 'Нет', 'Возможно'];

const _allQuestions = <_CareerQuestion>[
  // ── Social (работа с людьми) ──────────────────────────────────────────────
  _CareerQuestion(
    text: 'Тебе нравится помогать одноклассникам разбираться в сложных темах?',
    options: _kYesNoSometimes,
    category: 'social',
  ),
  _CareerQuestion(
    text: 'Ты легко заводишь новые знакомства на мероприятиях или в лагерях?',
    options: _kYesNoSometimes,
    category: 'social',
  ),
  _CareerQuestion(
    text:
        'Тебе важно, чтобы твоя будущая работа напрямую улучшала жизнь людей?',
    options: _kYesNoMaybe,
    category: 'social',
  ),
  _CareerQuestion(
    text:
        'Ты получаешь удовольствие от командных проектов, а не от работы в одиночку?',
    options: _kYesNoSometimes,
    category: 'social',
  ),
  _CareerQuestion(
    text:
        'Тебя привлекают профессии, где нужно выступать перед аудиторией или вести переговоры?',
    options: _kYesNoMaybe,
    category: 'social',
  ),
  // ── Analytical (анализ/данные) ────────────────────────────────────────────
  _CareerQuestion(
    text: 'Тебе нравится искать закономерности в числах и графиках?',
    options: _kYesNoSometimes,
    category: 'analytical',
  ),
  _CareerQuestion(
    text: 'Ты любишь решать логические задачи и головоломки в свободное время?',
    options: _kYesNoSometimes,
    category: 'analytical',
  ),
  _CareerQuestion(
    text:
        'Перед тем как принять решение, ты стараешься собрать и проверить все факты?',
    options: _kYesNoSometimes,
    category: 'analytical',
  ),
  _CareerQuestion(
    text: 'Тебе интересно, как работают экономика и рынки?',
    options: _kYesNoMaybe,
    category: 'analytical',
  ),
  _CareerQuestion(
    text:
        'Математика и статистика даются тебе легче, чем большинству одноклассников?',
    options: _kYesNoSometimes,
    category: 'analytical',
  ),
  // ── Creative (творчество) ─────────────────────────────────────────────────
  _CareerQuestion(
    text:
        'Ты часто придумываешь новые идеи, даже когда тебя об этом не просят?',
    options: _kYesNoSometimes,
    category: 'creative',
  ),
  _CareerQuestion(
    text: 'Тебя вдохновляет рисование, музыка, фото или видео?',
    options: _kYesNoSometimes,
    category: 'creative',
  ),
  _CareerQuestion(
    text:
        'Ты предпочитаешь придумать что-то своё, а не следовать чужим инструкциям?',
    options: _kYesNoSometimes,
    category: 'creative',
  ),
  _CareerQuestion(
    text: 'Тебе важно, чтобы твои проекты выглядели красиво и привлекательно?',
    options: _kYesNoMaybe,
    category: 'creative',
  ),
  _CareerQuestion(
    text:
        'Ты часто замечаешь детали дизайна: шрифты, цвета, композицию в рекламе или приложениях?',
    options: _kYesNoSometimes,
    category: 'creative',
  ),
  // ── Technical (техника/инженерия) ─────────────────────────────────────────
  _CareerQuestion(
    text: 'Тебе нравится разбирать устройства и понимать, как они устроены?',
    options: _kYesNoSometimes,
    category: 'technical',
  ),
  _CareerQuestion(
    text: 'Ты когда-нибудь пробовал программировать или хотел бы научиться?',
    options: _kYesNoMaybe,
    category: 'technical',
  ),
  _CareerQuestion(
    text: 'Физика и химия кажутся тебе интересными предметами, а не скучными?',
    options: _kYesNoSometimes,
    category: 'technical',
  ),
  _CareerQuestion(
    text:
        'Тебя привлекают профессии, где нужно работать с машинами, роботами или технологиями?',
    options: _kYesNoMaybe,
    category: 'technical',
  ),
  _CareerQuestion(
    text:
        'Ты предпочитаешь решать конкретные технические задачи, а не общаться с клиентами?',
    options: _kYesNoSometimes,
    category: 'technical',
  ),
  // ── Leadership (управление/организация) ──────────────────────────────────
  _CareerQuestion(
    text:
        'Друзья или одноклассники часто просят тебя организовать мероприятие или проект?',
    options: _kYesNoSometimes,
    category: 'leadership',
  ),
  _CareerQuestion(
    text:
        'Тебе важно не просто участвовать, но и влиять на конечный результат?',
    options: _kYesNoMaybe,
    category: 'leadership',
  ),
  _CareerQuestion(
    text: 'Ты умеешь убеждать других принять твою точку зрения?',
    options: _kYesNoSometimes,
    category: 'leadership',
  ),
  _CareerQuestion(
    text:
        'Ты хотел бы однажды открыть собственный бизнес или возглавить организацию?',
    options: _kYesNoMaybe,
    category: 'leadership',
  ),
  _CareerQuestion(
    text:
        'Планирование, распределение задач и контроль сроков даются тебе легко?',
    options: _kYesNoSometimes,
    category: 'leadership',
  ),
];

// ── Category metadata ─────────────────────────────────────────────────────────

const _categoryLabels = {
  'social': 'Работа с людьми',
  'analytical': 'Аналитика',
  'creative': 'Творчество',
  'technical': 'Технологии',
  'leadership': 'Управление',
};

const _categoryInsights = {
  'social':
      'Ты прирождённый коммуникатор! Твои сильные стороны — эмпатия и умение находить общий язык. '
      'Тебе подойдут профессии: педагог, психолог, HR-менеджер, социальный работник, PR-специалист.',
  'analytical':
      'Ты мыслишь системно и любишь разбираться в данных. '
      'Обрати внимание на: аналитик данных, финансист, учёный, программист, экономист.',
  'creative':
      'Ты видишь мир иначе и умеешь создавать что-то новое. '
      'Твои направления: дизайнер, художник, архитектор, режиссёр, UX-специалист, маркетолог.',
  'technical':
      'Ты любишь разбираться в том, как всё устроено, и создавать реальные решения. '
      'Профессии для тебя: инженер, программист, IT-специалист, учёный, исследователь.',
  'leadership':
      'Ты умеешь вести за собой людей и достигать целей через команду. '
      'Тебе подойдут: менеджер, предприниматель, государственный деятель, топ-менеджер, стратег.',
};

// ── Daily question picker (deterministic by day) ──────────────────────────────

List<_CareerQuestion> _pickDailyQuestions(DateTime date) {
  final dayOfYear = date.difference(DateTime(date.year)).inDays;
  final seed = date.year * 1000 + dayOfYear;
  final rng = Random(seed);
  final shuffled = List.of(_allQuestions)..shuffle(rng);
  return shuffled.take(5).toList();
}

// ── State ─────────────────────────────────────────────────────────────────────

enum _TestPhase { answering, result }

class _DailyTestState {
  const _DailyTestState({
    required this.questions,
    required this.currentIndex,
    required this.answers,
    required this.phase,
  });

  final List<_CareerQuestion> questions;
  final int currentIndex;
  final Map<int, int> answers;
  final _TestPhase phase;

  bool get isDone => currentIndex >= questions.length;

  _DailyTestState copyWith({
    List<_CareerQuestion>? questions,
    int? currentIndex,
    Map<int, int>? answers,
    _TestPhase? phase,
  }) => _DailyTestState(
    questions: questions ?? this.questions,
    currentIndex: currentIndex ?? this.currentIndex,
    answers: answers ?? this.answers,
    phase: phase ?? this.phase,
  );
}

class _DailyTestNotifier extends Notifier<_DailyTestState> {
  @override
  _DailyTestState build() => _DailyTestState(
    questions: _pickDailyQuestions(DateTime.now()),
    currentIndex: 0,
    answers: const {},
    phase: _TestPhase.answering,
  );

  void answer(int optionIndex) {
    final newAnswers = Map<int, int>.from(state.answers)
      ..[state.currentIndex] = optionIndex;
    final newIndex = state.currentIndex + 1;
    final isDone = newIndex >= state.questions.length;
    state = state.copyWith(
      answers: newAnswers,
      currentIndex: newIndex,
      phase: isDone ? _TestPhase.result : _TestPhase.answering,
    );
  }

  void reset() {
    state = _DailyTestState(
      questions: _pickDailyQuestions(DateTime.now()),
      currentIndex: 0,
      answers: const {},
      phase: _TestPhase.answering,
    );
  }
}

final _dailyTestProvider =
    NotifierProvider<_DailyTestNotifier, _DailyTestState>(
      _DailyTestNotifier.new,
    );

// ── Last result state ─────────────────────────────────────────────────────────

class _LastResult {
  const _LastResult({required this.date, required this.scores});
  final DateTime date;
  final Map<String, int> scores;
}

class _LastResultNotifier extends Notifier<_LastResult?> {
  @override
  _LastResult? build() => null;

  void save(Map<String, int> scores) {
    state = _LastResult(date: DateTime.now(), scores: scores);
  }
}

final _lastResultProvider = NotifierProvider<_LastResultNotifier, _LastResult?>(
  _LastResultNotifier.new,
);

// ── Screen ────────────────────────────────────────────────────────────────────

class DailyCareerTestScreen extends ConsumerStatefulWidget {
  const DailyCareerTestScreen({super.key});

  @override
  ConsumerState<DailyCareerTestScreen> createState() =>
      _DailyCareerTestScreenState();
}

class _DailyCareerTestScreenState extends ConsumerState<DailyCareerTestScreen> {
  int? _pendingAnswer;
  bool _advancing = false;

  Map<String, int> _computeScores(_DailyTestState test) {
    final scores = <String, int>{
      'social': 0,
      'analytical': 0,
      'creative': 0,
      'technical': 0,
      'leadership': 0,
    };
    for (final entry in test.answers.entries) {
      final q = test.questions[entry.key];
      // "Да" (index 0) = 2 pts, "Иногда"/"Возможно" (index 2) = 1 pt, "Нет" = 0
      final pts = entry.value == 0
          ? 2
          : entry.value == 2
          ? 1
          : 0;
      scores[q.category] = (scores[q.category] ?? 0) + pts;
    }
    return scores;
  }

  void _handleAnswer(int optionIndex) {
    if (_advancing) return;
    setState(() {
      _pendingAnswer = optionIndex;
      _advancing = true;
    });
    Future.delayed(const Duration(milliseconds: 320), () {
      if (!mounted) return;
      setState(() {
        _pendingAnswer = null;
        _advancing = false;
      });
      final notifier = ref.read(_dailyTestProvider.notifier);
      notifier.answer(optionIndex);
      // After final answer save result
      final state = ref.read(_dailyTestProvider);
      if (state.phase == _TestPhase.result) {
        final scores = _computeScores(state);
        ref.read(_lastResultProvider.notifier).save(scores);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final tokens =
        Theme.of(context).extension<AppTokens>() ?? AppTokens.defaults();
    final test = ref.watch(_dailyTestProvider);
    final lastResult = ref.watch(_lastResultProvider);

    // Already done today guard
    final now = DateTime.now();
    final alreadyDone =
        lastResult != null &&
        lastResult.date.year == now.year &&
        lastResult.date.month == now.month &&
        lastResult.date.day == now.day;

    if (alreadyDone && test.phase == _TestPhase.answering) {
      return _ResultView(
        tokens: tokens,
        scores: lastResult.scores,
        alreadyDone: true,
      );
    }

    return AppScaffold(
      body: SingleChildScrollView(
        padding: EdgeInsets.symmetric(
          horizontal: tokens.screenPadding,
          vertical: tokens.gapXl,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Row(
              children: [
                GestureDetector(
                  onTap: () => context.pop(),
                  behavior: HitTestBehavior.opaque,
                  child: const SizedBox(
                    width: 48,
                    height: 48,
                    child: Icon(
                      Icons.arrow_back_ios,
                      color: AppColors.ink,
                      size: 20,
                    ),
                  ),
                ),
                Expanded(
                  child: Text(
                    'Узнай свою профессию',
                    style: Theme.of(
                      context,
                    ).textTheme.titleLarge?.copyWith(color: AppColors.ink),
                    textAlign: TextAlign.center,
                  ),
                ),
                const SizedBox(width: 48),
              ],
            ),

            SizedBox(height: tokens.gapXl),

            if (test.phase == _TestPhase.answering) ...[
              _AnsweringView(
                test: test,
                tokens: tokens,
                pendingAnswer: _pendingAnswer,
                onAnswer: _handleAnswer,
              ),
            ] else ...[
              _ResultView(
                tokens: tokens,
                scores: _computeScores(test),
                alreadyDone: false,
              ).animate().fadeIn(duration: 400.ms),
            ],
          ],
        ),
      ),
    );
  }
}

// ── Answering phase ───────────────────────────────────────────────────────────

class _AnsweringView extends StatelessWidget {
  const _AnsweringView({
    required this.test,
    required this.tokens,
    required this.pendingAnswer,
    required this.onAnswer,
  });

  final _DailyTestState test;
  final AppTokens tokens;
  final int? pendingAnswer;
  final void Function(int) onAnswer;

  @override
  Widget build(BuildContext context) {
    final q = test.questions[test.currentIndex];
    final progress = (test.currentIndex + 1) / test.questions.length;

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Progress
        Row(
          children: [
            Expanded(
              child: ClipRRect(
                borderRadius: BorderRadius.circular(999),
                child: LinearProgressIndicator(
                  value: progress,
                  minHeight: 6,
                  backgroundColor: AppColors.border,
                  valueColor: const AlwaysStoppedAnimation(AppColors.primary),
                ),
              ),
            ),
            SizedBox(width: tokens.gapMd),
            Text(
              '${test.currentIndex + 1} / ${test.questions.length}',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: AppColors.inkSecondary,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),

        SizedBox(height: tokens.gapXl),

        // Mascot
        Center(
          child: const MascotSlot(size: 80)
              .animate()
              .fadeIn(duration: 300.ms)
              .slideY(begin: 0.2, end: 0, duration: 300.ms),
        ),

        SizedBox(height: tokens.gapLg),

        // Question card
        AppCard(
              key: ValueKey(test.currentIndex),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: tokens.gapMd,
                      vertical: tokens.gapXs,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withValues(alpha: 0.10),
                      borderRadius: BorderRadius.circular(999),
                    ),
                    child: Text(
                      _categoryLabels[q.category] ?? q.category,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: AppColors.primary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  SizedBox(height: tokens.gapMd),
                  Text(
                    q.text,
                    style: Theme.of(
                      context,
                    ).textTheme.titleLarge?.copyWith(color: AppColors.ink),
                  ),
                ],
              ),
            )
            .animate(key: ValueKey('q_${test.currentIndex}'))
            .fadeIn(duration: 260.ms)
            .slideX(
              begin: 0.08,
              end: 0,
              duration: 260.ms,
              curve: Curves.easeOutCubic,
            ),

        SizedBox(height: tokens.gapLg),

        // Answer options
        ...List.generate(q.options.length, (i) {
          final isSelected = pendingAnswer == i;
          return Padding(
            padding: EdgeInsets.only(bottom: tokens.gapSm),
            child:
                GestureDetector(
                      onTap: () => onAnswer(i),
                      behavior: HitTestBehavior.opaque,
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 180),
                        decoration: BoxDecoration(
                          color: isSelected
                              ? AppColors.primary.withValues(alpha: 0.12)
                              : AppColors.white,
                          borderRadius: BorderRadius.circular(tokens.radiusLg),
                          border: Border.all(
                            color: isSelected
                                ? AppColors.primary
                                : AppColors.border,
                            width: isSelected ? 2 : 1.5,
                          ),
                          boxShadow: const [
                            BoxShadow(
                              color: AppColors.cardShadow,
                              blurRadius: 12,
                              offset: Offset(0, 4),
                            ),
                          ],
                        ),
                        padding: EdgeInsets.all(tokens.cardPadding),
                        child: Row(
                          children: [
                            Expanded(
                              child: Text(
                                q.options[i],
                                style: Theme.of(context).textTheme.bodyLarge
                                    ?.copyWith(
                                      color: isSelected
                                          ? AppColors.primary
                                          : AppColors.ink,
                                      fontWeight: isSelected
                                          ? FontWeight.w700
                                          : FontWeight.w500,
                                    ),
                              ),
                            ),
                            if (isSelected)
                              const Icon(
                                Icons.check_circle,
                                color: AppColors.primary,
                                size: 20,
                              ),
                          ],
                        ),
                      ),
                    )
                    .animate(key: ValueKey('opt_${test.currentIndex}_$i'))
                    .fadeIn(
                      delay: Duration(milliseconds: 60 * i),
                      duration: 220.ms,
                    )
                    .slideX(
                      begin: 0.05,
                      end: 0,
                      delay: Duration(milliseconds: 60 * i),
                      duration: 220.ms,
                    ),
          );
        }),
      ],
    );
  }
}

// ── Result phase ──────────────────────────────────────────────────────────────

class _ResultView extends StatelessWidget {
  const _ResultView({
    required this.tokens,
    required this.scores,
    required this.alreadyDone,
  });

  final AppTokens tokens;
  final Map<String, int> scores;
  final bool alreadyDone;

  String _topCategory() {
    return scores.entries.reduce((a, b) => a.value >= b.value ? a : b).key;
  }

  @override
  Widget build(BuildContext context) {
    final top = _topCategory();
    final maxScore = scores.values.fold(0, (a, b) => a > b ? a : b);

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Mascot celebrate
        Center(
          child: alreadyDone
              ? const MascotSlot(mood: MascotMood.celebrate)
              : const MascotSlot(mood: MascotMood.celebrate, flyIn: true),
        ),

        SizedBox(height: tokens.gapLg),

        Text(
          alreadyDone ? 'Тест уже пройден!' : 'Ты прошёл тест!',
          style: Theme.of(
            context,
          ).textTheme.headlineLarge?.copyWith(color: AppColors.ink),
          textAlign: TextAlign.center,
        ),

        SizedBox(height: tokens.gapLg),

        // Result insight card
        AppCard(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Твоя сильная сторона:',
                style: Theme.of(
                  context,
                ).textTheme.bodySmall?.copyWith(color: AppColors.inkSecondary),
              ),
              SizedBox(height: tokens.gapXs),
              Text(
                _categoryLabels[top] ?? top,
                style: Theme.of(
                  context,
                ).textTheme.headlineMedium?.copyWith(color: AppColors.primary),
              ),
              SizedBox(height: tokens.gapMd),
              Text(
                _categoryInsights[top] ?? 'Продолжай развивать свои навыки!',
                style: Theme.of(
                  context,
                ).textTheme.bodyLarge?.copyWith(color: AppColors.ink),
              ),
              SizedBox(height: tokens.gapLg),
              Text(
                'Результаты по категориям:',
                style: Theme.of(
                  context,
                ).textTheme.labelLarge?.copyWith(color: AppColors.inkSecondary),
              ),
              SizedBox(height: tokens.gapSm),
              for (final entry in scores.entries) ...[
                Padding(
                  padding: EdgeInsets.only(bottom: tokens.gapSm),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              _categoryLabels[entry.key] ?? entry.key,
                              style: Theme.of(context).textTheme.bodySmall
                                  ?.copyWith(
                                    color: entry.key == top
                                        ? AppColors.primary
                                        : AppColors.inkSecondary,
                                    fontWeight: entry.key == top
                                        ? FontWeight.w700
                                        : FontWeight.w500,
                                  ),
                            ),
                          ),
                          Text(
                            '${entry.value}',
                            style: Theme.of(context).textTheme.bodySmall
                                ?.copyWith(
                                  color: entry.key == top
                                      ? AppColors.primary
                                      : AppColors.inkSecondary,
                                  fontWeight: FontWeight.w600,
                                ),
                          ),
                        ],
                      ),
                      SizedBox(height: tokens.gapXs),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(999),
                        child: LinearProgressIndicator(
                          value: maxScore == 0
                              ? 0
                              : entry.value / (maxScore == 0 ? 1 : 10),
                          minHeight: 6,
                          backgroundColor: AppColors.border,
                          valueColor: AlwaysStoppedAnimation(
                            entry.key == top
                                ? AppColors.primary
                                : AppColors.inkSecondary.withValues(alpha: 0.4),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ],
          ),
        ),

        SizedBox(height: tokens.gapLg),

        // Return tomorrow note
        Container(
          padding: EdgeInsets.all(tokens.cardPadding),
          decoration: BoxDecoration(
            color: AppColors.accentLime.withValues(alpha: 0.12),
            borderRadius: BorderRadius.circular(tokens.radiusLg),
            border: Border.all(
              color: AppColors.accentLime.withValues(alpha: 0.4),
            ),
          ),
          child: Row(
            children: [
              const Icon(Icons.bolt, color: AppColors.accentLime, size: 20),
              SizedBox(width: tokens.gapSm),
              Expanded(
                child: Text(
                  'Возвращайся завтра за новым тестом',
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    color: AppColors.ink,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
        ),

        SizedBox(height: tokens.gapXl),

        PrimaryButton(
          label: 'На главную',
          onPressed: () {
            if (context.canPop()) {
              context.pop();
            } else {
              context.go('/home');
            }
          },
        ),

        SizedBox(height: tokens.gapXl),
      ],
    );
  }
}
