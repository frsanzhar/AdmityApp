/// LessonScreen — Brilliant-style multi-step lesson flow (DESIGN_SYSTEM.md §7.4).
///
/// ## Step flow (requirement 3)
/// intro → THEORY (explanatory cards) → questions → feedback → complete
///
/// ## Question types (R7)
/// - multipleChoice: tap option, then «Проверить»
/// - trueFalse: tap «Верно»/«Неверно» → immediate check (no separate «Проверить»)
/// - tapToSelect: blank sentence + word chips, tap chip → «Проверить»
///
/// ## Layout rules (CLAUDE.md)
/// AppScaffold > Column(.min for top bar) > Expanded > SingleChildScrollView
/// > Column(mainAxisSize: .min).
/// Never uses CrossAxisAlignment.stretch inside a scroll.
///
/// ## Intro diagram (R8)
/// Uses LessonTopicDiagram(variant: TopicVariant.fractions) instead of TopicDiagramSlot.
library;

import 'package:admity/core/theme/app_colors.dart';
import 'package:admity/core/theme/app_tokens.dart';
import 'package:admity/shared/diagrams/courses/lesson_topic_diagram.dart';
import 'package:admity/shared/rive/rive_assets.dart';
import 'package:admity/shared/rive/rive_state_machine_slot.dart';
import 'package:admity/shared/widgets/app_card.dart';
import 'package:admity/shared/widgets/app_scaffold.dart';
import 'package:admity/shared/widgets/featured_button.dart';
import 'package:admity/shared/widgets/mascot_slot.dart';
import 'package:admity/shared/widgets/primary_button.dart';
import 'package:admity/shared/widgets/progress_ring.dart';
// ignore: unused_import -- kept for backwards-compat in test imports
import 'package:admity/shared/widgets/topic_diagram_slot.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:rive/rive.dart';

// ── Domain models ─────────────────────────────────────────────────────────────

/// A single theory card shown in the THEORY step.
class TheoryCardData {
  const TheoryCardData({
    required this.headline,
    required this.body,
    this.emoji,
  });

  final String headline;
  final String body;
  final String? emoji;
}

/// Which interaction type a [LessonQuestion] uses.
enum QuestionType {
  /// Standard multiple choice — tap option, then «Проверить».
  multipleChoice,

  /// Two buttons «Верно» / «Неверно» — immediate feedback on tap.
  trueFalse,

  /// Sentence with ____ blank + word chips — tap chip then «Проверить».
  tapToSelect,
}

/// A single question in the lesson.
class LessonQuestion {
  const LessonQuestion({
    required this.question,
    required this.options,
    required this.correctIndex,
    required this.explanation,
    this.type = QuestionType.multipleChoice,
  });

  final String question;
  final List<String> options;
  final int correctIndex;
  final String explanation;
  final QuestionType type;
}

/// Which high-level step the lesson is currently on.
///
/// Step order: intro → theory → question → feedback → complete.
enum LessonStepKind { intro, theory, question, feedback, complete }

/// Immutable lesson state — all transitions are pure.
class LessonState {
  const LessonState({
    required this.currentQuestionIndex,
    required this.selectedOptionIndex,
    required this.isChecked,
    required this.correctCount,
    required this.xp,
    required this.stepKind,
    required this.isExplanationExpanded,
    required this.currentTheoryCardIndex,
  });

  factory LessonState.initial() => const LessonState(
    currentQuestionIndex: 0,
    selectedOptionIndex: -1,
    isChecked: false,
    correctCount: 0,
    xp: 0,
    stepKind: LessonStepKind.intro,
    isExplanationExpanded: false,
    currentTheoryCardIndex: 0,
  );

  final int currentQuestionIndex;

  /// -1 = nothing selected yet.
  final int selectedOptionIndex;
  final bool isChecked;
  final int correctCount;

  /// XP accumulated so far.
  final int xp;
  final LessonStepKind stepKind;
  final bool isExplanationExpanded;

  /// Index of the currently shown theory card (0-based).
  final int currentTheoryCardIndex;

  bool get hasSelection => selectedOptionIndex >= 0;

  LessonState copyWith({
    int? currentQuestionIndex,
    int? selectedOptionIndex,
    bool? isChecked,
    int? correctCount,
    int? xp,
    LessonStepKind? stepKind,
    bool? isExplanationExpanded,
    int? currentTheoryCardIndex,
  }) {
    return LessonState(
      currentQuestionIndex: currentQuestionIndex ?? this.currentQuestionIndex,
      selectedOptionIndex: selectedOptionIndex ?? this.selectedOptionIndex,
      isChecked: isChecked ?? this.isChecked,
      correctCount: correctCount ?? this.correctCount,
      xp: xp ?? this.xp,
      stepKind: stepKind ?? this.stepKind,
      isExplanationExpanded:
          isExplanationExpanded ?? this.isExplanationExpanded,
      currentTheoryCardIndex:
          currentTheoryCardIndex ?? this.currentTheoryCardIndex,
    );
  }
}

// ── Seeded theory cards ───────────────────────────────────────────────────────

/// Theory cards for «Сравнение вероятностей».
const _theoryCards = <TheoryCardData>[
  TheoryCardData(
    headline: 'Что такое вероятность?',
    emoji: '🎲',
    body:
        'Вероятность — это число от 0 до 1, которое описывает, насколько '
        'вероятно наступление события. Число 0 означает, что событие '
        'невозможно, а число 1 означает, что оно обязательно произойдёт. '
        'Все события «между» имеют вероятность строго больше 0 и меньше 1.',
  ),
  TheoryCardData(
    headline: 'Классическая формула',
    emoji: '📐',
    body:
        'P(A) = m / n, где m — количество благоприятных исходов, '
        'n — общее количество равновозможных исходов. '
        'Пример: бросаем монету. n = 2 (орёл и решка), m = 1 (орёл). '
        'Значит P(орёл) = 1/2 = 0,5.',
  ),
  TheoryCardData(
    headline: 'Сравнение вероятностей',
    emoji: '⚖️',
    body:
        'Вероятности сравниваются так же, как обычные дроби. '
        'P(A) > P(B) значит, что событие A произойдёт чаще, чем B. '
        'Например: вероятность вытащить красный шар из мешка (3 красных '
        'из 10) = 3/10 = 0,3, а синий = 7/10 = 0,7. Синий вероятнее.',
  ),
  TheoryCardData(
    headline: 'Достоверные и невозможные события',
    emoji: '🎯',
    body:
        'Достоверное событие происходит всегда (P = 1). '
        'Пример: при броске кубика выпадет число от 1 до 6 — это достоверно. '
        'Невозможное событие не происходит никогда (P = 0). '
        'Пример: на том же кубике выпадет 7.',
  ),
];

// ── Seeded questions (R7) ─────────────────────────────────────────────────────
//
// Q0: multipleChoice — coin flip (correctIndex: 1 → '1/2')
// Q1: trueFalse — достоверное событие (correctIndex: 0 → 'Верно')
// Q2: tapToSelect — blank fill (correctIndex: 1 → '0')

const _lessonQuestions = <LessonQuestion>[
  // Q0: multipleChoice (default type) — kept exactly as before for test compat
  LessonQuestion(
    question: 'Бросают монету. Какова вероятность выпадения орла?',
    options: ['1/4', '1/2', '3/4', '1'],
    correctIndex: 1,
    explanation:
        'Монета имеет два равновероятных исхода: орёл и решка. '
        'Поэтому вероятность орла = 1/2 = 0.5.',
  ),
  // Q1: trueFalse — correctIndex: 0 = 'Верно'
  LessonQuestion(
    type: QuestionType.trueFalse,
    question: 'Вероятность достоверного события равна 1.',
    options: ['Верно', 'Неверно'],
    correctIndex: 0,
    explanation:
        'Достоверное событие — то, которое обязательно произойдёт. '
        'По определению, его вероятность равна 1.',
  ),
  // Q2: tapToSelect — blank sentence, correctIndex: 1 → '0'
  // options: ['1', '0', '1/2', '100%'] → index 1 = '0'
  LessonQuestion(
    type: QuestionType.tapToSelect,
    question: 'Вероятность невозможного события равна ____.',
    options: ['1', '0', '1/2', '100%'],
    correctIndex: 1,
    explanation:
        'Невозможное событие не может произойти никогда. '
        'Его вероятность равна 0 по определению.',
  ),
];

/// XP awarded per correct answer (visible for tests).
const lessonXpPerCorrect = 15;

/// Bonus XP awarded on lesson completion (visible for tests).
const lessonCompletionBonus = 5;

// ── State notifier ─────────────────────────────────────────────────────────────

class LessonNotifier extends Notifier<LessonState> {
  @override
  LessonState build() => LessonState.initial();

  /// Start the lesson (intro → theory step, card 0).
  void beginLesson() {
    state = state.copyWith(
      stepKind: LessonStepKind.theory,
      currentTheoryCardIndex: 0,
    );
  }

  /// Advance to the next theory card or, after the last card, to questions.
  void advanceTheory() {
    final nextCard = state.currentTheoryCardIndex + 1;
    if (nextCard >= _theoryCards.length) {
      state = state.copyWith(stepKind: LessonStepKind.question);
    } else {
      state = state.copyWith(currentTheoryCardIndex: nextCard);
    }
  }

  /// Select an answer option before checking.
  void selectOption(int index) {
    if (state.isChecked) return; // locked after check
    state = state.copyWith(selectedOptionIndex: index);
  }

  /// Check the selected answer. Pure: correctness is derived from seed data.
  void checkAnswer() {
    if (!state.hasSelection || state.isChecked) return;
    final question = _lessonQuestions[state.currentQuestionIndex];
    final isCorrect = state.selectedOptionIndex == question.correctIndex;
    final newCorrect = state.correctCount + (isCorrect ? 1 : 0);
    final newXp = state.xp + (isCorrect ? lessonXpPerCorrect : 0);
    state = state.copyWith(
      isChecked: true,
      correctCount: newCorrect,
      xp: newXp,
      stepKind: LessonStepKind.feedback,
    );
  }

  /// Advance to the next question or complete screen.
  void continueLesson() {
    final nextIndex = state.currentQuestionIndex + 1;
    if (nextIndex >= _lessonQuestions.length) {
      state = state.copyWith(
        xp: state.xp + lessonCompletionBonus,
        stepKind: LessonStepKind.complete,
      );
    } else {
      state = state.copyWith(
        currentQuestionIndex: nextIndex,
        selectedOptionIndex: -1,
        isChecked: false,
        stepKind: LessonStepKind.question,
        isExplanationExpanded: false,
      );
    }
  }

  /// Toggle the "Почему?" explanation panel.
  void toggleExplanation() {
    state = state.copyWith(
      isExplanationExpanded: !state.isExplanationExpanded,
    );
  }
}

final lessonProvider = NotifierProvider<LessonNotifier, LessonState>(
  LessonNotifier.new,
);

// ── Screen ─────────────────────────────────────────────────────────────────────

/// LessonScreen — Brilliant-style multi-step flow.
///
/// Step flow: intro → theory → questions → feedback → complete.
/// Layout: AppScaffold > Column > [top bar] > Expanded > SingleChildScrollView
///   > Column(mainAxisSize: .min).
class LessonScreen extends ConsumerWidget {
  const LessonScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(lessonProvider);

    return AppScaffold(
      body: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // ── Top bar: progress + close ─────────────────────────────────────
          _LessonTopBar(state: state),

          // ── Step content ─────────────────────────────────────────────────
          Expanded(
            child: SingleChildScrollView(
              child: _buildStepContent(context, ref, state),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStepContent(
    BuildContext context,
    WidgetRef ref,
    LessonState state,
  ) {
    switch (state.stepKind) {
      case LessonStepKind.intro:
        return _IntroStep(state: state, ref: ref);
      case LessonStepKind.theory:
        return _TheoryStep(state: state, ref: ref);
      case LessonStepKind.question:
        return _QuestionStep(state: state, ref: ref);
      case LessonStepKind.feedback:
        return _FeedbackStep(state: state, ref: ref);
      case LessonStepKind.complete:
        return _CompleteStep(state: state);
    }
  }
}

// ── Top bar ───────────────────────────────────────────────────────────────────

class _LessonTopBar extends ConsumerWidget {
  const _LessonTopBar({required this.state});

  final LessonState state;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tokens =
        Theme.of(context).extension<AppTokens>() ?? AppTokens.defaults();

    // Progress counts theory cards + questions.
    final totalTheory = _theoryCards.length;
    final totalQuestions = _lessonQuestions.length;
    final totalSteps = totalTheory + totalQuestions;

    int completedSteps;
    switch (state.stepKind) {
      case LessonStepKind.intro:
        completedSteps = 0;
      case LessonStepKind.theory:
        completedSteps = state.currentTheoryCardIndex;
      case LessonStepKind.question:
      case LessonStepKind.feedback:
        completedSteps = totalTheory + state.currentQuestionIndex;
      case LessonStepKind.complete:
        completedSteps = totalSteps;
    }

    final progress = totalSteps > 0 ? completedSteps / totalSteps : 0.0;

    return Padding(
      padding: EdgeInsets.symmetric(
        horizontal: tokens.screenPadding,
        vertical: tokens.gapMd,
      ),
      child: Row(
        children: [
          GestureDetector(
            onTap: () => context.go('/home'),
            behavior: HitTestBehavior.opaque,
            child: Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: AppColors.surfaceTint,
                borderRadius: BorderRadius.circular(tokens.radiusSm),
              ),
              child: const Icon(
                Icons.close_rounded,
                color: AppColors.inkSecondary,
                size: 20,
              ),
            ),
          ),
          SizedBox(width: tokens.gapMd),
          Expanded(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: LinearProgressIndicator(
                value: progress.clamp(0.0, 1.0),
                minHeight: 6,
                backgroundColor: AppColors.border,
                valueColor: const AlwaysStoppedAnimation<Color>(
                  AppColors.primary,
                ),
              ),
            ),
          ),
          SizedBox(width: tokens.gapMd),
          Text(
            state.stepKind == LessonStepKind.complete
                ? '$totalSteps/$totalSteps'
                : '$completedSteps/$totalSteps',
            style: Theme.of(context).textTheme.labelLarge?.copyWith(
              color: AppColors.inkSecondary,
            ),
          ),
        ],
      ),
    );
  }
}

// ── Step 1: Intro ─────────────────────────────────────────────────────────────

class _IntroStep extends StatelessWidget {
  const _IntroStep({required this.state, required this.ref});

  final LessonState state;
  final WidgetRef ref;

  @override
  Widget build(BuildContext context) {
    final tokens =
        Theme.of(context).extension<AppTokens>() ?? AppTokens.defaults();

    return Padding(
      padding: EdgeInsets.symmetric(
        horizontal: tokens.screenPadding,
        vertical: tokens.gapLg,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(height: tokens.gapXl),
          Text(
            'Сравнение вероятностей',
            style: Theme.of(context).textTheme.displayLarge?.copyWith(
              color: AppColors.ink,
            ),
            textAlign: TextAlign.center,
          ).animate().fadeIn(duration: 350.ms).slideY(begin: -0.06, end: 0),
          SizedBox(height: tokens.gapSm),
          Text(
            'Научись сравнивать шансы событий и понимать, '
            'что является достоверным, невозможным или случайным.',
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
              color: AppColors.inkSecondary,
            ),
            textAlign: TextAlign.center,
          ).animate().fadeIn(
            delay: 80.ms,
            duration: 300.ms,
          ),
          SizedBox(height: tokens.gapXxl),
          // R8: LessonTopicDiagram instead of TopicDiagramSlot
          const SizedBox(
                width: 160,
                height: 160,
                child: LessonTopicDiagram(variant: TopicVariant.fractions),
              )
              .animate()
              .fadeIn(delay: 120.ms, duration: 350.ms)
              .scale(
                begin: const Offset(0.9, 0.9),
                end: const Offset(1, 1),
                delay: 120.ms,
                duration: 350.ms,
              ),
          SizedBox(height: tokens.gapXxl),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              _StatPill(
                icon: Icons.menu_book_outlined,
                label: '${_theoryCards.length} карточки теории',
              ),
              SizedBox(width: tokens.gapMd),
              _StatPill(
                icon: Icons.quiz_outlined,
                label: '${_lessonQuestions.length} вопроса',
              ),
              SizedBox(width: tokens.gapMd),
              const _StatPill(
                icon: Icons.star_outline_rounded,
                label: '+50 XP',
              ),
            ],
          ).animate().fadeIn(delay: 200.ms, duration: 250.ms),
          SizedBox(height: tokens.gapXxl),
          // Featured CTA — begin the lesson (intro is featured action)
          FeaturedButton(
            label: 'Начать урок',
            onPressed: () => ref.read(lessonProvider.notifier).beginLesson(),
          ).animate().fadeIn(delay: 260.ms, duration: 250.ms),
          SizedBox(height: tokens.gapXl),
        ],
      ),
    );
  }
}

class _StatPill extends StatelessWidget {
  const _StatPill({required this.icon, required this.label});

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    final tokens =
        Theme.of(context).extension<AppTokens>() ?? AppTokens.defaults();
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: tokens.gapMd,
        vertical: tokens.gapXs,
      ),
      decoration: BoxDecoration(
        color: AppColors.surfaceTint,
        borderRadius: BorderRadius.circular(tokens.radiusSm),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: AppColors.primary),
          SizedBox(width: tokens.gapXs),
          Text(
            label,
            style: Theme.of(context).textTheme.labelLarge?.copyWith(
              color: AppColors.ink,
            ),
          ),
        ],
      ),
    );
  }
}

// ── Step 2: Theory ─────────────────────────────────────────────────────────────

/// THEORY step: shows one card at a time with «Далее» to advance.
/// After the last card the button label changes to «К вопросам».
class _TheoryStep extends StatelessWidget {
  const _TheoryStep({required this.state, required this.ref});

  final LessonState state;
  final WidgetRef ref;

  @override
  Widget build(BuildContext context) {
    final tokens =
        Theme.of(context).extension<AppTokens>() ?? AppTokens.defaults();
    final card = _theoryCards[state.currentTheoryCardIndex];
    final isLast = state.currentTheoryCardIndex == _theoryCards.length - 1;

    return Padding(
      padding: EdgeInsets.symmetric(
        horizontal: tokens.screenPadding,
        vertical: tokens.gapLg,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(height: tokens.gapSm),

          // Card counter pill
          Container(
            padding: EdgeInsets.symmetric(
              horizontal: tokens.gapMd,
              vertical: tokens.gapXs,
            ),
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(tokens.radiusSm),
            ),
            child: Text(
              'Теория  ${state.currentTheoryCardIndex + 1} / ${_theoryCards.length}',
              style: Theme.of(context).textTheme.labelLarge?.copyWith(
                color: AppColors.primary,
              ),
            ),
          ).animate().fadeIn(duration: 200.ms),

          SizedBox(height: tokens.gapXl),

          // Theory card
          _TheoryCardWidget(card: card)
              .animate(key: ValueKey('theory_${state.currentTheoryCardIndex}'))
              .fadeIn(duration: 300.ms)
              .slideX(begin: 0.05, end: 0, duration: 300.ms),

          SizedBox(height: tokens.gapXxl),

          // Progress dots
          Row(
            mainAxisSize: MainAxisSize.min,
            children: List.generate(_theoryCards.length, (i) {
              final isActive = i == state.currentTheoryCardIndex;
              return AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                margin: const EdgeInsets.symmetric(horizontal: 3),
                width: isActive ? 20 : 8,
                height: 8,
                decoration: BoxDecoration(
                  color: isActive ? AppColors.primary : AppColors.border,
                  borderRadius: BorderRadius.circular(4),
                ),
              );
            }),
          ),

          SizedBox(height: tokens.gapXxl),

          // Advance button (PrimaryButton — normal action)
          PrimaryButton(
            label: isLast ? 'К вопросам' : 'Далее',
            onPressed: () => ref.read(lessonProvider.notifier).advanceTheory(),
          ).animate().fadeIn(delay: 100.ms, duration: 250.ms),

          SizedBox(height: tokens.gapXl),
        ],
      ),
    );
  }
}

/// A single theory card widget.
class _TheoryCardWidget extends StatelessWidget {
  const _TheoryCardWidget({required this.card});

  final TheoryCardData card;

  @override
  Widget build(BuildContext context) {
    final tokens =
        Theme.of(context).extension<AppTokens>() ?? AppTokens.defaults();

    return AppCard(
      color: AppColors.surfaceTint,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (card.emoji != null)
            Text(
              card.emoji!,
              style: const TextStyle(fontSize: 40),
            ),
          if (card.emoji != null) SizedBox(height: tokens.gapMd),
          Text(
            card.headline,
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
              color: AppColors.ink,
            ),
          ),
          SizedBox(height: tokens.gapMd),
          Text(
            card.body,
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
              color: AppColors.inkSecondary,
            ),
          ),
        ],
      ),
    );
  }
}

// ── Step 3: Question ──────────────────────────────────────────────────────────

/// Dispatches to the correct question UI based on [LessonQuestion.type].
class _QuestionStep extends StatelessWidget {
  const _QuestionStep({required this.state, required this.ref});

  final LessonState state;
  final WidgetRef ref;

  @override
  Widget build(BuildContext context) {
    final question = _lessonQuestions[state.currentQuestionIndex];
    switch (question.type) {
      case QuestionType.multipleChoice:
        return _MultipleChoiceStep(state: state, ref: ref, question: question);
      case QuestionType.trueFalse:
        return _TrueFalseStep(state: state, ref: ref, question: question);
      case QuestionType.tapToSelect:
        return _TapToSelectStep(state: state, ref: ref, question: question);
    }
  }
}

/// Standard multiple-choice question: option cards + «Проверить».
class _MultipleChoiceStep extends StatelessWidget {
  const _MultipleChoiceStep({
    required this.state,
    required this.ref,
    required this.question,
  });

  final LessonState state;
  final WidgetRef ref;
  final LessonQuestion question;

  @override
  Widget build(BuildContext context) {
    final tokens =
        Theme.of(context).extension<AppTokens>() ?? AppTokens.defaults();

    return Padding(
      padding: EdgeInsets.symmetric(
        horizontal: tokens.screenPadding,
        vertical: tokens.gapLg,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(height: tokens.gapSm),
          _QuestionCounterPill(state: state),
          SizedBox(height: tokens.gapXl),
          Text(
                question.question,
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  color: AppColors.ink,
                ),
                textAlign: TextAlign.center,
              )
              .animate(key: ValueKey('q_${state.currentQuestionIndex}'))
              .fadeIn(duration: 280.ms)
              .slideY(begin: -0.04, end: 0),
          SizedBox(height: tokens.gapXxl),
          ...List.generate(question.options.length, (i) {
            return Padding(
              padding: EdgeInsets.only(bottom: tokens.gapMd),
              child:
                  _AnswerCard(
                    label: question.options[i],
                    isSelected: state.selectedOptionIndex == i,
                    isLocked: false,
                    onTap: () =>
                        ref.read(lessonProvider.notifier).selectOption(i),
                  ).animate().fadeIn(
                    delay: Duration(milliseconds: 40 + i * 50),
                    duration: 240.ms,
                  ),
            );
          }),
          SizedBox(height: tokens.gapLg),
          PrimaryButton(
            label: 'Проверить',
            onPressed: state.hasSelection
                ? () => ref.read(lessonProvider.notifier).checkAnswer()
                : null,
          ),
          SizedBox(height: tokens.gapXl),
        ],
      ),
    );
  }
}

/// True/False question: two buttons — tap immediately checks (no «Проверить»).
class _TrueFalseStep extends StatelessWidget {
  const _TrueFalseStep({
    required this.state,
    required this.ref,
    required this.question,
  });

  final LessonState state;
  final WidgetRef ref;
  final LessonQuestion question;

  @override
  Widget build(BuildContext context) {
    final tokens =
        Theme.of(context).extension<AppTokens>() ?? AppTokens.defaults();

    return Padding(
      padding: EdgeInsets.symmetric(
        horizontal: tokens.screenPadding,
        vertical: tokens.gapLg,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(height: tokens.gapSm),
          _QuestionCounterPill(state: state),
          SizedBox(height: tokens.gapXl),
          Text(
                question.question,
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  color: AppColors.ink,
                ),
                textAlign: TextAlign.center,
              )
              .animate(key: ValueKey('q_${state.currentQuestionIndex}'))
              .fadeIn(duration: 280.ms)
              .slideY(begin: -0.04, end: 0),
          SizedBox(height: tokens.gapXxl),
          // True/False buttons — tapping immediately selects AND checks
          Row(
            children: [
              Expanded(
                child: _TrueFalseButton(
                  label: question.options[0], // 'Верно'
                  icon: Icons.check_circle_outline_rounded,
                  color: AppColors.successGreen,
                  isSelected: state.selectedOptionIndex == 0,
                  onTap: () {
                    ref.read(lessonProvider.notifier).selectOption(0);
                    ref.read(lessonProvider.notifier).checkAnswer();
                  },
                ).animate().fadeIn(delay: 60.ms, duration: 240.ms),
              ),
              SizedBox(width: tokens.gapMd),
              Expanded(
                child: _TrueFalseButton(
                  label: question.options[1], // 'Неверно'
                  icon: Icons.cancel_outlined,
                  color: AppColors.errorRed,
                  isSelected: state.selectedOptionIndex == 1,
                  onTap: () {
                    ref.read(lessonProvider.notifier).selectOption(1);
                    ref.read(lessonProvider.notifier).checkAnswer();
                  },
                ).animate().fadeIn(delay: 100.ms, duration: 240.ms),
              ),
            ],
          ),
          SizedBox(height: tokens.gapXl),
        ],
      ),
    );
  }
}

/// A large Верно/Неверно button for trueFalse questions.
class _TrueFalseButton extends StatelessWidget {
  const _TrueFalseButton({
    required this.label,
    required this.icon,
    required this.color,
    required this.isSelected,
    required this.onTap,
  });

  final String label;
  final IconData icon;
  final Color color;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final tokens =
        Theme.of(context).extension<AppTokens>() ?? AppTokens.defaults();

    final bgColor = isSelected
        ? color.withValues(alpha: 0.12)
        : AppColors.surfaceTint;
    final borderColor = isSelected ? color : AppColors.border;

    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding: EdgeInsets.symmetric(
          vertical: tokens.gapLg,
          horizontal: tokens.gapMd,
        ),
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(tokens.radiusLg),
          border: Border.all(color: borderColor, width: isSelected ? 2 : 1),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: color, size: 32),
            SizedBox(height: tokens.gapSm),
            Text(
              label,
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
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

/// Tap-to-select question: sentence with ____ blank + word chips.
class _TapToSelectStep extends StatelessWidget {
  const _TapToSelectStep({
    required this.state,
    required this.ref,
    required this.question,
  });

  final LessonState state;
  final WidgetRef ref;
  final LessonQuestion question;

  @override
  Widget build(BuildContext context) {
    final tokens =
        Theme.of(context).extension<AppTokens>() ?? AppTokens.defaults();

    // The question text contains ____ as the blank marker.
    // If an option is selected, fill the blank with it.
    final selectedLabel = state.selectedOptionIndex >= 0
        ? question.options[state.selectedOptionIndex]
        : null;
    final displayText = selectedLabel != null
        ? question.question.replaceAll('____', selectedLabel)
        : question.question;

    return Padding(
      padding: EdgeInsets.symmetric(
        horizontal: tokens.screenPadding,
        vertical: tokens.gapLg,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(height: tokens.gapSm),
          _QuestionCounterPill(state: state),
          SizedBox(height: tokens.gapXl),
          Text(
                displayText,
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  color: AppColors.ink,
                ),
                textAlign: TextAlign.center,
              )
              .animate(key: ValueKey('q_${state.currentQuestionIndex}'))
              .fadeIn(duration: 280.ms)
              .slideY(begin: -0.04, end: 0),
          SizedBox(height: tokens.gapXxl),
          // Word chips
          Wrap(
            spacing: tokens.gapSm,
            runSpacing: tokens.gapSm,
            alignment: WrapAlignment.center,
            children: List.generate(question.options.length, (i) {
              final isSelected = state.selectedOptionIndex == i;
              return GestureDetector(
                onTap: () => ref.read(lessonProvider.notifier).selectOption(i),
                behavior: HitTestBehavior.opaque,
                child:
                    AnimatedContainer(
                      duration: const Duration(milliseconds: 150),
                      padding: EdgeInsets.symmetric(
                        horizontal: tokens.gapLg,
                        vertical: tokens.gapSm,
                      ),
                      decoration: BoxDecoration(
                        color: isSelected
                            ? AppColors.primary.withValues(alpha: 0.10)
                            : AppColors.surfaceTint,
                        borderRadius: BorderRadius.circular(tokens.radiusMd),
                        border: Border.all(
                          color: isSelected
                              ? AppColors.primary
                              : AppColors.border,
                          width: isSelected ? 2 : 1,
                        ),
                      ),
                      child: Text(
                        question.options[i],
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          color: isSelected ? AppColors.primary : AppColors.ink,
                          fontWeight: isSelected
                              ? FontWeight.w600
                              : FontWeight.w500,
                        ),
                      ),
                    ).animate().fadeIn(
                      delay: Duration(milliseconds: 40 + i * 50),
                      duration: 240.ms,
                    ),
              );
            }),
          ),
          SizedBox(height: tokens.gapXxl),
          PrimaryButton(
            label: 'Проверить',
            onPressed: state.hasSelection
                ? () => ref.read(lessonProvider.notifier).checkAnswer()
                : null,
          ),
          SizedBox(height: tokens.gapXl),
        ],
      ),
    );
  }
}

/// Counter pill shown at the top of each question step.
class _QuestionCounterPill extends StatelessWidget {
  const _QuestionCounterPill({required this.state});

  final LessonState state;

  @override
  Widget build(BuildContext context) {
    final tokens =
        Theme.of(context).extension<AppTokens>() ?? AppTokens.defaults();
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: tokens.gapMd,
        vertical: tokens.gapXs,
      ),
      decoration: BoxDecoration(
        color: AppColors.primary.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(tokens.radiusSm),
      ),
      child: Text(
        'Вопрос ${state.currentQuestionIndex + 1} из ${_lessonQuestions.length}',
        style: Theme.of(context).textTheme.labelLarge?.copyWith(
          color: AppColors.primary,
        ),
      ),
    ).animate().fadeIn(duration: 200.ms);
  }
}

// ── Answer card ───────────────────────────────────────────────────────────────

class _AnswerCard extends StatelessWidget {
  const _AnswerCard({
    required this.label,
    required this.isSelected,
    required this.isLocked,
    required this.onTap,
  });

  final String label;
  final bool isSelected;
  final bool isLocked;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final tokens =
        Theme.of(context).extension<AppTokens>() ?? AppTokens.defaults();

    final borderColor = isSelected ? AppColors.primary : AppColors.border;
    final bgColor = isSelected
        ? AppColors.primary.withValues(alpha: 0.06)
        : AppColors.white;

    return GestureDetector(
      onTap: isLocked ? null : onTap,
      behavior: HitTestBehavior.opaque,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding: EdgeInsets.all(tokens.cardPadding),
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(tokens.radiusLg),
          border: Border.all(color: borderColor, width: isSelected ? 2 : 1),
          boxShadow: tokens.cardShadow,
        ),
        child: Row(
          children: [
            AnimatedContainer(
              duration: const Duration(milliseconds: 150),
              width: 22,
              height: 22,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: isSelected ? AppColors.primary : Colors.transparent,
                border: Border.all(
                  color: isSelected
                      ? AppColors.primary
                      : AppColors.inkSecondary,
                  width: 1.5,
                ),
              ),
              child: isSelected
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
                label,
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  color: isSelected ? AppColors.primary : AppColors.ink,
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Step 4: Feedback ──────────────────────────────────────────────────────────

class _FeedbackStep extends StatelessWidget {
  const _FeedbackStep({required this.state, required this.ref});

  final LessonState state;
  final WidgetRef ref;

  @override
  Widget build(BuildContext context) {
    final tokens =
        Theme.of(context).extension<AppTokens>() ?? AppTokens.defaults();
    final question = _lessonQuestions[state.currentQuestionIndex];
    final isCorrect = state.selectedOptionIndex == question.correctIndex;

    return Padding(
      padding: EdgeInsets.symmetric(
        horizontal: tokens.screenPadding,
        vertical: tokens.gapLg,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          _RiveFeedbackBurst(isCorrect: isCorrect),
          _FeedbackBanner(isCorrect: isCorrect),
          SizedBox(height: tokens.gapXl),
          Text(
            question.question,
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
              color: AppColors.ink,
            ),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: tokens.gapXl),
          ...List.generate(question.options.length, (i) {
            return Padding(
              padding: EdgeInsets.only(bottom: tokens.gapMd),
              child: _FeedbackAnswerCard(
                label: question.options[i],
                isSelected: state.selectedOptionIndex == i,
                isCorrect: i == question.correctIndex,
              ),
            );
          }),
          SizedBox(height: tokens.gapLg),
          _WhyExpander(
            explanation: question.explanation,
            isExpanded: state.isExplanationExpanded,
            onToggle: () =>
                ref.read(lessonProvider.notifier).toggleExplanation(),
          ),
          SizedBox(height: tokens.gapXl),
          PrimaryButton(
            label: 'Продолжить',
            onPressed: () => ref.read(lessonProvider.notifier).continueLesson(),
          ),
          SizedBox(height: tokens.gapXl),
        ],
      ),
    );
  }
}

class _FeedbackBanner extends StatelessWidget {
  const _FeedbackBanner({required this.isCorrect});

  final bool isCorrect;

  @override
  Widget build(BuildContext context) {
    final tokens =
        Theme.of(context).extension<AppTokens>() ?? AppTokens.defaults();
    final color = isCorrect ? AppColors.successGreen : AppColors.errorRed;
    final bgColor = isCorrect
        ? AppColors.successGreen.withValues(alpha: 0.1)
        : AppColors.errorRed.withValues(alpha: 0.1);
    final icon = isCorrect ? Icons.check_circle_rounded : Icons.cancel_rounded;
    final label = isCorrect ? 'Верно!' : 'Неверно';

    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(
        horizontal: tokens.cardPadding,
        vertical: tokens.gapMd,
      ),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(tokens.radiusLg),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Row(
        children: [
          Icon(icon, color: color, size: 28),
          SizedBox(width: tokens.gapMd),
          Text(
            label,
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
              color: color,
            ),
          ),
          if (isCorrect) ...[
            const Spacer(),
            Container(
              padding: EdgeInsets.symmetric(
                horizontal: tokens.gapMd,
                vertical: tokens.gapXs,
              ),
              decoration: BoxDecoration(
                color: AppColors.successGreen,
                borderRadius: BorderRadius.circular(tokens.radiusSm),
              ),
              child: Text(
                '+$lessonXpPerCorrect XP',
                style: Theme.of(context).textTheme.labelLarge?.copyWith(
                  color: AppColors.white,
                ),
              ),
            ),
          ],
        ],
      ),
    ).animate().fadeIn(duration: 250.ms).slideY(begin: -0.04, end: 0);
  }
}

class _FeedbackAnswerCard extends StatelessWidget {
  const _FeedbackAnswerCard({
    required this.label,
    required this.isSelected,
    required this.isCorrect,
  });

  final String label;
  final bool isSelected;
  final bool isCorrect;

  @override
  Widget build(BuildContext context) {
    final tokens =
        Theme.of(context).extension<AppTokens>() ?? AppTokens.defaults();

    Color borderColor;
    Color bgColor;
    Color textColor;

    if (isCorrect) {
      borderColor = AppColors.successGreen;
      bgColor = AppColors.successGreen.withValues(alpha: 0.07);
      textColor = AppColors.successGreen;
    } else if (isSelected) {
      borderColor = AppColors.errorRed;
      bgColor = AppColors.errorRed.withValues(alpha: 0.07);
      textColor = AppColors.errorRed;
    } else {
      borderColor = AppColors.border;
      bgColor = AppColors.white;
      textColor = AppColors.inkSecondary;
    }

    Widget? trailingIcon;
    if (isCorrect) {
      trailingIcon = const Icon(
        Icons.check_circle_rounded,
        color: AppColors.successGreen,
        size: 20,
      );
    } else if (isSelected && !isCorrect) {
      trailingIcon = const Icon(
        Icons.cancel_rounded,
        color: AppColors.errorRed,
        size: 20,
      );
    }

    return Container(
      padding: EdgeInsets.all(tokens.cardPadding),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(tokens.radiusLg),
        border: Border.all(
          color: borderColor,
          width: isCorrect || isSelected ? 2 : 1,
        ),
        boxShadow: tokens.cardShadow,
      ),
      child: Row(
        children: [
          Expanded(
            child: Text(
              label,
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                color: textColor,
                fontWeight: (isCorrect || isSelected)
                    ? FontWeight.w600
                    : FontWeight.w500,
              ),
            ),
          ),
          if (trailingIcon != null) ...[
            SizedBox(width: tokens.gapSm),
            trailingIcon,
          ],
        ],
      ),
    );
  }
}

class _WhyExpander extends StatelessWidget {
  const _WhyExpander({
    required this.explanation,
    required this.isExpanded,
    required this.onToggle,
  });

  final String explanation;
  final bool isExpanded;
  final VoidCallback onToggle;

  @override
  Widget build(BuildContext context) {
    final tokens =
        Theme.of(context).extension<AppTokens>() ?? AppTokens.defaults();

    return AppCard(
      padding: EdgeInsets.zero,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          GestureDetector(
            onTap: onToggle,
            behavior: HitTestBehavior.opaque,
            child: Padding(
              padding: EdgeInsets.all(tokens.cardPadding),
              child: Row(
                children: [
                  const Icon(
                    Icons.lightbulb_outline_rounded,
                    color: AppColors.goldKey,
                    size: 20,
                  ),
                  SizedBox(width: tokens.gapSm),
                  Text(
                    'Почему?',
                    style: Theme.of(context).textTheme.labelLarge?.copyWith(
                      color: AppColors.ink,
                    ),
                  ),
                  const Spacer(),
                  Icon(
                    isExpanded
                        ? Icons.keyboard_arrow_up_rounded
                        : Icons.keyboard_arrow_down_rounded,
                    color: AppColors.inkSecondary,
                    size: 22,
                  ),
                ],
              ),
            ),
          ),
          if (isExpanded)
            Padding(
              padding: EdgeInsets.fromLTRB(
                tokens.cardPadding,
                0,
                tokens.cardPadding,
                tokens.cardPadding,
              ),
              child: Text(
                explanation,
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  color: AppColors.inkSecondary,
                ),
              ),
            ).animate().fadeIn(duration: 200.ms),
        ],
      ),
    );
  }
}

// ── Phase 7: Rive motion widgets ─────────────────────────────────────────────

/// Small Rive burst that plays correct/incorrect feedback once.
// TODO(rive-asset): assets/rive/lesson_feedback.riv
class _RiveFeedbackBurst extends StatefulWidget {
  const _RiveFeedbackBurst({required this.isCorrect});

  final bool isCorrect;

  @override
  State<_RiveFeedbackBurst> createState() => _RiveFeedbackBurstState();
}

class _RiveFeedbackBurstState extends State<_RiveFeedbackBurst> {
  void _onController(RiveWidgetController ctrl) {
    final sm = ctrl.stateMachine;
    if (widget.isCorrect) {
      // ignore: deprecated_member_use -- SMI inputs deprecated in Rive 0.14.x; assets not yet migrated
      sm.trigger(kFeedbackTriggerCorrect)?.fire();
    } else {
      // ignore: deprecated_member_use -- SMI inputs deprecated in Rive 0.14.x; assets not yet migrated
      sm.trigger(kFeedbackTriggerIncorrect)?.fire();
    }
  }

  @override
  Widget build(BuildContext context) {
    final reduceMotion = MediaQuery.of(context).disableAnimations;
    if (reduceMotion) return const SizedBox.shrink();

    return RiveStateMachineSlot(
      assetPath: kFeedbackRivAsset,
      machineName: kFeedbackMachineName,
      staticFallback: const SizedBox.shrink(),
      onController: _onController,
      width: double.infinity,
      height: 80,
    );
  }
}

/// Wraps [child] with a Rive confetti layer.
// TODO(rive-asset): assets/rive/lesson_complete.riv
class _RiveLessonComplete extends StatefulWidget {
  const _RiveLessonComplete({required this.child});

  final Widget child;

  @override
  State<_RiveLessonComplete> createState() => _RiveLessonCompleteState();
}

class _RiveLessonCompleteState extends State<_RiveLessonComplete> {
  void _onController(RiveWidgetController ctrl) {
    // ignore: deprecated_member_use -- SMI inputs deprecated in Rive 0.14.x; assets not yet migrated
    ctrl.stateMachine.trigger(kLessonCompleteTriggerCelebrate)?.fire();
  }

  @override
  Widget build(BuildContext context) {
    final reduceMotion = MediaQuery.of(context).disableAnimations;

    return SizedBox(
      height: 160,
      child: Stack(
        alignment: Alignment.center,
        children: [
          if (!reduceMotion)
            Positioned.fill(
              child: RiveStateMachineSlot(
                assetPath: kLessonCompleteRivAsset,
                machineName: kLessonCompleteMachineName,
                staticFallback: const SizedBox.shrink(),
                onController: _onController,
                width: double.infinity,
                height: 160,
                fit: Fit.cover,
              ),
            ),
          widget.child,
        ],
      ),
    );
  }
}

// ── Step 5: Complete ──────────────────────────────────────────────────────────

class _CompleteStep extends StatelessWidget {
  const _CompleteStep({required this.state});

  final LessonState state;

  @override
  Widget build(BuildContext context) {
    final tokens =
        Theme.of(context).extension<AppTokens>() ?? AppTokens.defaults();
    final totalQuestions = _lessonQuestions.length;

    return Padding(
      padding: EdgeInsets.symmetric(
        horizontal: tokens.screenPadding,
        vertical: tokens.gapLg,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(height: tokens.gapXxl),
          const _RiveLessonComplete(
            child: MascotSlot(
              tag: 'lesson-complete',
              state: MascotState.celebrate,
            ),
          ),
          SizedBox(height: tokens.gapXxl),
          Text(
            'Урок пройден!',
            style: Theme.of(context).textTheme.displayLarge?.copyWith(
              color: AppColors.ink,
            ),
            textAlign: TextAlign.center,
          ).animate().fadeIn(duration: 350.ms).slideY(begin: 0.06, end: 0),
          SizedBox(height: tokens.gapMd),
          Text(
            'Отличная работа! Ты завершил урок о вероятностях.',
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
              color: AppColors.inkSecondary,
            ),
            textAlign: TextAlign.center,
          ).animate().fadeIn(delay: 80.ms, duration: 300.ms),
          SizedBox(height: tokens.gapXxl),
          _XpCard(xp: state.xp),
          SizedBox(height: tokens.gapXl),
          _ScoreSummary(
            correctCount: state.correctCount,
            totalCount: totalQuestions,
          ),
          SizedBox(height: tokens.gapXxl),
          FeaturedButton(
            label: 'Готово',
            onPressed: () => context.go('/home'),
          ).animate().fadeIn(delay: 160.ms, duration: 250.ms),
          SizedBox(height: tokens.gapXl),
        ],
      ),
    );
  }
}

class _XpCard extends StatelessWidget {
  const _XpCard({required this.xp});

  final int xp;

  @override
  Widget build(BuildContext context) {
    final tokens =
        Theme.of(context).extension<AppTokens>() ?? AppTokens.defaults();

    return AppCard(
      child: Row(
        children: [
          const ProgressRing(
            progress: 1,
            size: 64,
            strokeWidth: 6,
            progressColor: AppColors.successGreen,
            child: Icon(
              Icons.star_rounded,
              color: AppColors.goldKey,
              size: 28,
            ),
          ),
          SizedBox(width: tokens.gapLg),
          Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Заработано XP',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: AppColors.inkSecondary,
                ),
              ),
              SizedBox(height: tokens.gapXs),
              Text(
                '+$xp XP',
                style: Theme.of(context).textTheme.displayLarge?.copyWith(
                  color: AppColors.successGreen,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _ScoreSummary extends StatelessWidget {
  const _ScoreSummary({
    required this.correctCount,
    required this.totalCount,
  });

  final int correctCount;
  final int totalCount;

  @override
  Widget build(BuildContext context) {
    final tokens =
        Theme.of(context).extension<AppTokens>() ?? AppTokens.defaults();
    final pct = totalCount > 0 ? correctCount / totalCount : 0.0;

    return AppCard(
      child: Row(
        children: [
          ProgressRing(
            progress: pct,
            size: 64,
            strokeWidth: 6,
            child: Text(
              '${(pct * 100).round()}%',
              style: Theme.of(context).textTheme.labelLarge?.copyWith(
                color: AppColors.primary,
                fontSize: 12,
              ),
            ),
          ),
          SizedBox(width: tokens.gapLg),
          Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Правильных ответов',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: AppColors.inkSecondary,
                ),
              ),
              SizedBox(height: tokens.gapXs),
              Text(
                '$correctCount из $totalCount',
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  color: AppColors.ink,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
