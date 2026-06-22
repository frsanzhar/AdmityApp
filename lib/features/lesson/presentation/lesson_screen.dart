import 'package:admity/core/theme/app_colors.dart';
import 'package:admity/core/theme/app_tokens.dart';
import 'package:admity/shared/widgets/app_card.dart';
import 'package:admity/shared/widgets/app_scaffold.dart';
import 'package:admity/shared/widgets/featured_button.dart';
import 'package:admity/shared/widgets/mascot_slot.dart';
import 'package:admity/shared/widgets/primary_button.dart';
import 'package:admity/shared/widgets/progress_ring.dart';
import 'package:admity/shared/widgets/topic_diagram_slot.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

// ── Domain models ─────────────────────────────────────────────────────────────

/// A single multiple-choice question in the lesson.
class LessonQuestion {
  const LessonQuestion({
    required this.question,
    required this.options,
    required this.correctIndex,
    required this.explanation,
  });

  final String question;
  final List<String> options;
  final int correctIndex;
  final String explanation;
}

/// Which high-level step the lesson is currently on.
enum LessonStepKind { intro, question, feedback, complete }

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
  });

  factory LessonState.initial() => const LessonState(
        currentQuestionIndex: 0,
        selectedOptionIndex: -1,
        isChecked: false,
        correctCount: 0,
        xp: 0,
        stepKind: LessonStepKind.intro,
        isExplanationExpanded: false,
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

  bool get hasSelection => selectedOptionIndex >= 0;

  LessonState copyWith({
    int? currentQuestionIndex,
    int? selectedOptionIndex,
    bool? isChecked,
    int? correctCount,
    int? xp,
    LessonStepKind? stepKind,
    bool? isExplanationExpanded,
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
    );
  }
}

// ── Seeded questions ──────────────────────────────────────────────────────────

const _lessonQuestions = <LessonQuestion>[
  LessonQuestion(
    question: 'Бросают монету. Какова вероятность выпадения орла?',
    options: ['1/4', '1/2', '3/4', '1'],
    correctIndex: 1,
    explanation:
        'Монета имеет два равновероятных исхода: орёл и решка. '
        'Поэтому вероятность орла = 1/2 = 0.5.',
  ),
  LessonQuestion(
    question: 'В мешке 3 красных и 7 синих шара. Какова вероятность '
        'вытащить красный?',
    options: ['3/10', '7/10', '1/3', '1/7'],
    correctIndex: 0,
    explanation:
        'Всего 10 шаров, 3 из которых красные. '
        'Вероятность = 3 / (3+7) = 3/10 = 0.3.',
  ),
  LessonQuestion(
    question: 'Какое событие является достоверным?',
    options: [
      'Бросок кубика даст 7',
      'Выпадет либо чётное, либо нечётное число',
      'Выпадет число больше 5',
      'Монета встанет на ребро',
    ],
    correctIndex: 1,
    explanation:
        'Достоверное событие — то, которое обязательно произойдёт. '
        'На игральном кубике любой результат — либо чётное, либо '
        'нечётное число, поэтому это событие достоверно (вероятность = 1).',
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

  /// Start the lesson (intro → first question).
  void beginLesson() {
    state = state.copyWith(stepKind: LessonStepKind.question);
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
      // Award completion bonus and move to complete screen.
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

final lessonProvider =
    NotifierProvider<LessonNotifier, LessonState>(LessonNotifier.new);

// ── Screen ─────────────────────────────────────────────────────────────────────

/// Lesson screen — Brilliant-style multi-step flow (DESIGN_SYSTEM.md §7.4).
///
/// Steps: intro → question(s) → feedback → complete.
/// Layout rule: AppScaffold > SingleChildScrollView > Column(mainAxisSize: .min).
/// Accent: AppColors.primary (progress ring + selected option border).
/// FeaturedButton used ONLY for intro begin CTA and lesson-complete «Готово».
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
    final tokens = Theme.of(context).extension<AppTokens>() ?? AppTokens.defaults();
    final totalSteps = _lessonQuestions.length;
    final completedSteps = state.stepKind == LessonStepKind.complete
        ? totalSteps
        : state.currentQuestionIndex;
    final progress = totalSteps > 0 ? completedSteps / totalSteps : 0.0;

    return Padding(
      padding: EdgeInsets.symmetric(
        horizontal: tokens.screenPadding,
        vertical: tokens.gapMd,
      ),
      child: Row(
        children: [
          // Close button
          GestureDetector(
            onTap: () => context.go('/courses'),
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
          // Linear progress bar
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
          // Step counter label
          Text(
            state.stepKind == LessonStepKind.complete
                ? '$totalSteps/$totalSteps'
                : '${state.currentQuestionIndex}/$totalSteps',
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
    final tokens = Theme.of(context).extension<AppTokens>() ?? AppTokens.defaults();

    return Padding(
      padding: EdgeInsets.symmetric(
        horizontal: tokens.screenPadding,
        vertical: tokens.gapLg,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(height: tokens.gapXl),
          // Display title
          Text(
            'Сравнение вероятностей',
            style: Theme.of(context).textTheme.displayLarge?.copyWith(
                  color: AppColors.ink,
                ),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: tokens.gapSm),
          Text(
            'Научись сравнивать шансы событий и понимать, '
            'что является достоверным, невозможным или случайным.',
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  color: AppColors.inkSecondary,
                ),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: tokens.gapXxl),
          // 3D illustration placeholder
          const TopicDiagramSlot(size: 160),
          SizedBox(height: tokens.gapXxl),
          // Lesson stats row
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
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
          ),
          SizedBox(height: tokens.gapXxl),
          // Featured CTA — only for intro begin
          FeaturedButton(
            label: 'Начать урок',
            onPressed: () => ref.read(lessonProvider.notifier).beginLesson(),
          ),
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
    final tokens = Theme.of(context).extension<AppTokens>() ?? AppTokens.defaults();
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

// ── Step 2: Question ──────────────────────────────────────────────────────────

class _QuestionStep extends StatelessWidget {
  const _QuestionStep({required this.state, required this.ref});

  final LessonState state;
  final WidgetRef ref;

  @override
  Widget build(BuildContext context) {
    final tokens = Theme.of(context).extension<AppTokens>() ?? AppTokens.defaults();
    final question = _lessonQuestions[state.currentQuestionIndex];

    return Padding(
      padding: EdgeInsets.symmetric(
        horizontal: tokens.screenPadding,
        vertical: tokens.gapLg,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(height: tokens.gapSm),
          // Question label
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
              'Вопрос ${state.currentQuestionIndex + 1} из ${_lessonQuestions.length}',
              style: Theme.of(context).textTheme.labelLarge?.copyWith(
                    color: AppColors.primary,
                  ),
            ),
          ),
          SizedBox(height: tokens.gapXl),
          // Question text
          Text(
            question.question,
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  color: AppColors.ink,
                ),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: tokens.gapXxl),
          // Answer option cards
          ...List.generate(question.options.length, (i) {
            return Padding(
              padding: EdgeInsets.only(bottom: tokens.gapMd),
              child: _AnswerCard(
                label: question.options[i],
                isSelected: state.selectedOptionIndex == i,
                isLocked: false,
                onTap: () =>
                    ref.read(lessonProvider.notifier).selectOption(i),
              ),
            );
          }),
          SizedBox(height: tokens.gapLg),
          // Check button — disabled until an option is selected
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
    final tokens = Theme.of(context).extension<AppTokens>() ?? AppTokens.defaults();

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
            // Selection indicator circle
            AnimatedContainer(
              duration: const Duration(milliseconds: 150),
              width: 22,
              height: 22,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: isSelected ? AppColors.primary : Colors.transparent,
                border: Border.all(
                  color:
                      isSelected ? AppColors.primary : AppColors.inkSecondary,
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
                      fontWeight:
                          isSelected ? FontWeight.w600 : FontWeight.w500,
                    ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Step 3: Feedback ──────────────────────────────────────────────────────────

class _FeedbackStep extends StatelessWidget {
  const _FeedbackStep({required this.state, required this.ref});

  final LessonState state;
  final WidgetRef ref;

  @override
  Widget build(BuildContext context) {
    final tokens = Theme.of(context).extension<AppTokens>() ?? AppTokens.defaults();
    final question = _lessonQuestions[state.currentQuestionIndex];
    final isCorrect = state.selectedOptionIndex == question.correctIndex;

    // TODO(motion): ✓/✗ feedback animation — Rive state machine in Phase 7.

    return Padding(
      padding: EdgeInsets.symmetric(
        horizontal: tokens.screenPadding,
        vertical: tokens.gapLg,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(height: tokens.gapSm),
          // ✓ / ✗ feedback banner
          _FeedbackBanner(isCorrect: isCorrect),
          SizedBox(height: tokens.gapXl),
          // Question text (recap)
          Text(
            question.question,
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  color: AppColors.ink,
                ),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: tokens.gapXl),
          // Answer options (locked, with correct highlighted)
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
          // "Почему?" expandable explanation
          _WhyExpander(
            explanation: question.explanation,
            isExpanded: state.isExplanationExpanded,
            onToggle: () =>
                ref.read(lessonProvider.notifier).toggleExplanation(),
          ),
          SizedBox(height: tokens.gapXl),
          // Continue button (dark primary — normal action)
          PrimaryButton(
            label: 'Продолжить',
            onPressed: () =>
                ref.read(lessonProvider.notifier).continueLesson(),
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
    final tokens = Theme.of(context).extension<AppTokens>() ?? AppTokens.defaults();
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
    );
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
    final tokens = Theme.of(context).extension<AppTokens>() ?? AppTokens.defaults();

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
        border: Border.all(color: borderColor, width: isCorrect || isSelected ? 2 : 1),
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
    final tokens = Theme.of(context).extension<AppTokens>() ?? AppTokens.defaults();

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
            ),
        ],
      ),
    );
  }
}

// ── Step 4: Complete ──────────────────────────────────────────────────────────

class _CompleteStep extends StatelessWidget {
  const _CompleteStep({required this.state});

  final LessonState state;

  @override
  Widget build(BuildContext context) {
    final tokens = Theme.of(context).extension<AppTokens>() ?? AppTokens.defaults();
    final totalQuestions = _lessonQuestions.length;

    // TODO(motion): lesson-complete celebration — Rive confetti in Phase 7.

    return Padding(
      padding: EdgeInsets.symmetric(
        horizontal: tokens.screenPadding,
        vertical: tokens.gapLg,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(height: tokens.gapXxl),
          // Mascot celebrating
          const MascotSlot(tag: 'lesson-complete'),
          SizedBox(height: tokens.gapXxl),
          // Headline
          Text(
            'Урок пройден!',
            style: Theme.of(context).textTheme.displayLarge?.copyWith(
                  color: AppColors.ink,
                ),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: tokens.gapMd),
          Text(
            'Отличная работа! Ты завершил урок о вероятностях.',
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  color: AppColors.inkSecondary,
                ),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: tokens.gapXxl),
          // XP earned — prominent display
          _XpCard(xp: state.xp),
          SizedBox(height: tokens.gapXl),
          // Score summary
          _ScoreSummary(
            correctCount: state.correctCount,
            totalCount: totalQuestions,
          ),
          SizedBox(height: tokens.gapXxl),
          // Featured CTA for lesson completion — the finish is a featured action
          FeaturedButton(
            label: 'Готово',
            onPressed: () => context.go('/courses'),
          ),
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
    final tokens = Theme.of(context).extension<AppTokens>() ?? AppTokens.defaults();

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
    final tokens = Theme.of(context).extension<AppTokens>() ?? AppTokens.defaults();
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
