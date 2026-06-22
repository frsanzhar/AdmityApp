/// CoursesScreen — Brilliant-style course path (DESIGN_SYSTEM.md §7.3).
///
/// ## Layout
/// `AppScaffold > Column > [indicator row] > PageView(physics: full-page swipe)`
/// Each page: `SingleChildScrollView > Column(mainAxisSize: .min)`.
/// Never uses CrossAxisAlignment.stretch inside a scroll — follows the
/// blank-screen gotcha rule from CLAUDE.md.
///
/// ## PageView (requirement 4)
/// Swiping left/right moves between whole course pages
/// (e.g. Математика → Логика → Английский).  A row of dot indicators at the
/// top reflects the current page.  The tab bar widget is kept as a companion
/// tappable chip row so users can also tap to jump to a course.
///
/// ## Profile-derived suggestions (requirement 1)
/// Reads `profileProvider` (read-only) to derive:
///   • gradeHint — "для 11 класса" shown under the course title
///   • interestHint — "по твоим интересам" for interest-matched courses
/// Falls back to sensible defaults when the profile is empty.
///
/// ## «Создать курс» (requirement 2)
/// A `PrimaryButton` opens a bottom sheet.  The user types a topic; on
/// confirm, `CoursesNotifier.createCourse(topic)` calls
/// `CourseGenerationService`, gets back a [Course], and prepends it to the
/// list.  The PageView animates to the new page.  A flutter_animate fade+slide
/// reveals the new course card.
///
/// ## Collapsed lessons (requirement 5)
/// Each [LessonNode] is rendered in a compact row.  Tapping a non-locked node
/// toggles an expansion card showing the lesson's title/detail.  The «Начать
/// урок» box is always visible below the node path without scrolling.
///
/// ## Animations (requirement 6)
/// • Page transitions: flutter_animate fade+slideX on page content.
/// • Node path: staggered fade+slideY entries for each node.
/// • Create-course: fade+scale reveal of the new course chip + page.
library;

import 'package:admity/core/theme/app_colors.dart';
import 'package:admity/core/theme/app_tokens.dart';
import 'package:admity/features/courses/data/course_generation_service.dart';
import 'package:admity/features/courses/domain/course_model.dart';
import 'package:admity/features/profile/application/profile_notifier.dart';
import 'package:admity/features/profile/domain/profile_model.dart';
import 'package:admity/shared/widgets/app_card.dart';
import 'package:admity/shared/widgets/app_scaffold.dart';
import 'package:admity/shared/widgets/featured_button.dart';
import 'package:admity/shared/widgets/lesson_node.dart';
import 'package:admity/shared/widgets/mascot_slot.dart';
import 'package:admity/shared/widgets/topic_diagram_slot.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

// ── Re-export LessonNodeState so tests can import it from here ─────────────

// ── Seed data ─────────────────────────────────────────────────────────────────

/// Converts a [StudentProfile] into the seed list of bundled courses,
/// annotating grade/interest hints where applicable.
List<Course> _seedCourses(StudentProfile profile) {
  final grade = profile.grade;
  final interests = profile.interests.map((s) => s.toLowerCase()).toSet();

  String? gradeHintFor(String _) => grade != null ? 'для $grade' : null;

  String? interestHintFor(List<String> tags) {
    for (final tag in tags) {
      if (interests.contains(tag)) return 'по твоим интересам';
    }
    return null;
  }

  return [
    Course(
      id: 'math',
      title: 'Математика',
      subjectLabel: 'Математика',
      level: 'Уровень 1',
      gradeHint: gradeHintFor('math'),
      interestHint: interestHintFor(['математика', 'math', 'физика']),
      modules: [
        const CourseModule(
          id: 'math_mod_0',
          title: 'Теория вероятностей',
          lessons: [
            CourseLesson(
              id: 'math_les_0',
              title: 'Введение в вероятность',
              isCompleted: true,
              theory: [
                TheoryCard(
                  headline: 'Что такое вероятность?',
                  body:
                      'Вероятность — это мера того, насколько вероятно наступление некоторого события. Она выражается числом от 0 до 1: 0 означает невозможное событие, 1 — достоверное.',
                  emoji: '🎲',
                ),
                TheoryCard(
                  headline: 'Классическое определение',
                  body:
                      'P(A) = m / n, где m — число благоприятных исходов, n — общее число равновозможных исходов. Например, при броске монеты n=2, m=1, P(орёл) = 1/2.',
                  emoji: '📐',
                ),
              ],
            ),
            CourseLesson(
              id: 'math_les_1',
              title: 'Сравнение вероятностей',
              theory: [
                TheoryCard(
                  headline: 'Как сравнивать вероятности?',
                  body:
                      'Вероятности сравниваются как обычные дроби. P(A) > P(B) означает, что событие A произойдёт чаще, чем событие B при одинаковых условиях. Это интуитивно: 1/2 > 1/4.',
                  emoji: '⚖️',
                ),
                TheoryCard(
                  headline: 'Достоверные и невозможные события',
                  body:
                      'Достоверное событие всегда происходит (P=1). Невозможное — никогда (P=0). Случайные события лежат в диапазоне (0; 1). Чем ближе P к 1, тем более вероятно событие.',
                  emoji: '🎯',
                ),
              ],
            ),
            CourseLesson(
              id: 'math_les_2',
              title: 'Комбинаторика',
              isLocked: true,
            ),
            CourseLesson(
              id: 'math_les_3',
              title: 'Независимые события',
              isLocked: true,
            ),
            CourseLesson(
              id: 'math_les_4',
              title: 'Формула Байеса',
              isLocked: true,
            ),
          ],
        ),
      ],
    ),
    Course(
      id: 'logic',
      title: 'Логика',
      subjectLabel: 'Логика',
      level: 'Уровень 1',
      gradeHint: gradeHintFor('logic'),
      interestHint: interestHintFor([
        'логика',
        'logic',
        'философия',
        'программирование',
      ]),
      modules: [
        const CourseModule(
          id: 'logic_mod_0',
          title: 'Основы логики',
          lessons: [
            CourseLesson(
              id: 'logic_les_0',
              title: 'Высказывания и суждения',
              theory: [
                TheoryCard(
                  headline: 'Что такое высказывание?',
                  body:
                      'Высказывание — утверждение, которое можно оценить как истинное или ложное. Например: «Солнце — звезда» (истина), «2 + 2 = 5» (ложь).',
                  emoji: '💬',
                ),
                TheoryCard(
                  headline: 'Логические связки',
                  body:
                      'Основные связки: И (конъюнкция), ИЛИ (дизъюнкция), НЕ (отрицание), ЕСЛИ…ТО (импликация). Они позволяют строить сложные суждения из простых.',
                  emoji: '🔗',
                ),
              ],
            ),
            CourseLesson(
              id: 'logic_les_1',
              title: 'Дедукция и индукция',
              isLocked: true,
            ),
            CourseLesson(
              id: 'logic_les_2',
              title: 'Логические задачи',
              isLocked: true,
            ),
          ],
        ),
      ],
    ),
    Course(
      id: 'english',
      title: 'Английский',
      subjectLabel: 'Английский',
      level: 'Уровень 1',
      gradeHint: gradeHintFor('english'),
      interestHint: interestHintFor([
        'английский',
        'english',
        'ielts',
        'toefl',
        'иностранные языки',
      ]),
      modules: [
        const CourseModule(
          id: 'eng_mod_0',
          title: 'Грамматика',
          lessons: [
            CourseLesson(
              id: 'eng_les_0',
              title: 'Present Tenses',
              theory: [
                TheoryCard(
                  headline: 'Present Simple vs Continuous',
                  body:
                      'Present Simple описывает факты, привычки и расписание: «I work every day.» Present Continuous — действие прямо сейчас: «I am working now.»',
                  emoji: '🕐',
                ),
                TheoryCard(
                  headline: 'Present Perfect',
                  body:
                      'Present Perfect связывает прошлое и настоящее: «I have finished my homework.» Используется, когда результат важен сейчас, а не время действия.',
                  emoji: '✅',
                ),
              ],
            ),
            CourseLesson(
              id: 'eng_les_1',
              title: 'Conditionals',
              isLocked: true,
            ),
            CourseLesson(
              id: 'eng_les_2',
              title: 'Vocabulary: IELTS',
              isLocked: true,
            ),
          ],
        ),
      ],
    ),
  ];
}

// ── State ─────────────────────────────────────────────────────────────────────

/// State for CoursesScreen.
class CoursesState {
  const CoursesState({
    required this.courses,
    required this.pageIndex,
    required this.expandedLessonId,
    this.isGenerating = false,
    this.generateError,
  });

  factory CoursesState.initial(StudentProfile profile) => CoursesState(
    courses: _seedCourses(profile),
    pageIndex: 0,
    expandedLessonId: null,
  );

  final List<Course> courses;
  final int pageIndex;

  /// The ID of the currently expanded lesson node (null = all collapsed).
  final String? expandedLessonId;

  final bool isGenerating;
  final String? generateError;

  CoursesState copyWith({
    List<Course>? courses,
    int? pageIndex,
    String? expandedLessonId,
    bool clearExpanded = false,
    bool? isGenerating,
    String? generateError,
    bool clearError = false,
  }) {
    return CoursesState(
      courses: courses ?? this.courses,
      pageIndex: pageIndex ?? this.pageIndex,
      expandedLessonId: clearExpanded
          ? null
          : (expandedLessonId ?? this.expandedLessonId),
      isGenerating: isGenerating ?? this.isGenerating,
      generateError: clearError ? null : (generateError ?? this.generateError),
    );
  }
}

class CoursesNotifier extends Notifier<CoursesState> {
  // Lazy — initialised in build(); accessed via _controller in the widget.
  // PageController lives in the widget (StatefulWidget), not here, because it
  // is a Flutter object tied to the widget tree lifecycle.

  final _service = const CourseGenerationService();

  @override
  CoursesState build() {
    // Read profile synchronously (may still be loading — we fall back to empty).
    final profile = ref.watch(profileProvider).profile;
    return CoursesState.initial(profile);
  }

  void setPageIndex(int index) {
    state = state.copyWith(pageIndex: index, clearExpanded: true);
  }

  void toggleLesson(String lessonId) {
    if (state.expandedLessonId == lessonId) {
      state = state.copyWith(clearExpanded: true);
    } else {
      state = state.copyWith(expandedLessonId: lessonId);
    }
  }

  Future<void> createCourse(String topic) async {
    if (topic.trim().isEmpty) return;
    state = state.copyWith(isGenerating: true, clearError: true);

    try {
      final profile = ref.read(profileProvider).profile;
      final course = await _service.generateCourse(topic, profile);
      // Prepend so the new course appears first (page 0).
      final updated = [course, ...state.courses];
      state = state.copyWith(
        courses: updated,
        pageIndex: 0,
        isGenerating: false,
        clearExpanded: true,
      );
    } on Object catch (e) {
      state = state.copyWith(
        isGenerating: false,
        generateError: 'Не удалось создать курс: $e',
      );
    }
  }
}

final coursesProvider = NotifierProvider<CoursesNotifier, CoursesState>(
  CoursesNotifier.new,
);

// ── Backwards-compat exports used by existing tests ───────────────────────────

/// Flat list of lessons for the first (math) seed course — used by existing
/// tests that reference `courseLessons` directly.
List<LessonItem> get courseLessons {
  final courses = _seedCourses(StudentProfile.empty);
  if (courses.isEmpty) return const [];
  final math = courses.first;
  final allLessons = math.allLessons;
  return allLessons.map((l) {
    LessonNodeState nodeState;
    if (l.isCompleted) {
      nodeState = LessonNodeState.done;
    } else if (l.isLocked) {
      nodeState = LessonNodeState.locked;
    } else {
      nodeState = LessonNodeState.active;
    }
    return LessonItem(id: l.id.hashCode, title: l.title, nodeState: nodeState);
  }).toList();
}

/// A legacy lesson item used by existing tests.
class LessonItem {
  const LessonItem({
    required this.id,
    required this.title,
    required this.nodeState,
  });

  final int id;
  final String title;
  final LessonNodeState nodeState;
}

// ── Screen ────────────────────────────────────────────────────────────────────

/// CoursesScreen — requirement compliance:
///
/// 1. Profile-derived course list with grade/interest hints.
/// 2. «Создать курс» → bottom sheet → CourseGenerationService → prepend + animate.
/// 3. Theory added to lesson model (implemented in LessonScreen).
/// 4. Full-page PageView horizontal swipe between courses.
/// 5. Lessons collapsed by default; tap to expand detail.
/// 6. flutter_animate: staggered node path, page fade-in, create-course reveal.
/// 7. Layout: AppScaffold > Column > indicators > Expanded > PageView
///    of scroll-view > Column(.min).
class CoursesScreen extends ConsumerStatefulWidget {
  const CoursesScreen({super.key});

  @override
  ConsumerState<CoursesScreen> createState() => _CoursesScreenState();
}

class _CoursesScreenState extends ConsumerState<CoursesScreen> {
  late final PageController _pageController;
  MascotState _mascotState = MascotState.idle;

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _onPageChanged(int index) {
    ref.read(coursesProvider.notifier).setPageIndex(index);
  }

  void _jumpToPage(int index) {
    // ignore: discarded_futures -- fire-and-forget animation; result not needed
    _pageController.animateToPage(
      index,
      duration: const Duration(milliseconds: 350),
      curve: Curves.easeInOut,
    );
  }

  void _onStartLesson() {
    final reduceMotion = MediaQuery.of(context).disableAnimations;
    if (!reduceMotion) {
      setState(() => _mascotState = MascotState.flyDown);
    }
    context.go('/lesson');
  }

  void _showCreateCourseSheet() {
    // ignore: discarded_futures -- sheet result (void) is not needed
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _CreateCourseSheet(
        onConfirm: (topic) async {
          Navigator.of(context).pop();
          await ref.read(coursesProvider.notifier).createCourse(topic);
          // Animate to the newly created course (index 0).
          if (_pageController.hasClients) {
            await _pageController.animateToPage(
              0,
              duration: const Duration(milliseconds: 400),
              curve: Curves.easeInOutCubic,
            );
          }
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(coursesProvider);
    final tokens =
        Theme.of(context).extension<AppTokens>() ?? AppTokens.defaults();

    // Keep page controller in sync when notifier changes page (e.g. after create).
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      if (_pageController.hasClients &&
          _pageController.page?.round() != state.pageIndex) {
        await _pageController.animateToPage(
          state.pageIndex,
          duration: const Duration(milliseconds: 350),
          curve: Curves.easeInOut,
        );
      }
    });

    final body = Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // ── Page indicator + chip tabs ─────────────────────────────────────
        _CourseIndicatorRow(
          courses: state.courses,
          selectedIndex: state.pageIndex,
          onTap: _jumpToPage,
        ),
        SizedBox(height: tokens.gapSm),

        // ── Full-page swipeable PageView ───────────────────────────────────
        Expanded(
          child: PageView.builder(
            controller: _pageController,
            onPageChanged: _onPageChanged,
            itemCount: state.courses.length,
            itemBuilder: (context, index) {
              final course = state.courses[index];
              return _CoursePage(
                key: ValueKey(course.id),
                course: course,
                onStartLesson: _onStartLesson,
                mascotState: _mascotState,
              );
            },
          ),
        ),
      ],
    );

    return AppScaffold(
      body: SafeArea(
        child: Column(
          children: [
            // ── Top action row: title + «Создать курс» ─────────────────────
            Padding(
              padding: EdgeInsets.symmetric(
                horizontal: tokens.screenPadding,
                vertical: tokens.gapMd,
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      'Учёба',
                      style: Theme.of(context).textTheme.headlineLarge
                          ?.copyWith(
                            color: AppColors.ink,
                          ),
                    ),
                  ),
                  // «Создать курс» — normal action (dark container, §8).
                  if (state.isGenerating)
                    const SizedBox(
                      width: 28,
                      height: 28,
                      child: CircularProgressIndicator(
                        strokeWidth: 2.5,
                        color: AppColors.primary,
                      ),
                    )
                  else
                    GestureDetector(
                      onTap: _showCreateCourseSheet,
                      child: Container(
                        constraints: const BoxConstraints(minHeight: 48),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 10,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.ink,
                          borderRadius: BorderRadius.circular(
                            tokens.radiusMd,
                          ),
                        ),
                        alignment: Alignment.center,
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(
                              Icons.add_rounded,
                              color: AppColors.white,
                              size: 18,
                            ),
                            const SizedBox(width: 6),
                            Text(
                              'Создать курс',
                              style: Theme.of(context).textTheme.labelLarge
                                  ?.copyWith(color: AppColors.white),
                            ),
                          ],
                        ),
                      ),
                    ),
                ],
              ),
            ),
            Expanded(child: body),
          ],
        ),
      ),
    );
  }
}

// ── Course indicator row ──────────────────────────────────────────────────────

/// Horizontal scrollable chip row showing course labels with dot indicators.
class _CourseIndicatorRow extends StatelessWidget {
  const _CourseIndicatorRow({
    required this.courses,
    required this.selectedIndex,
    required this.onTap,
  });

  final List<Course> courses;
  final int selectedIndex;
  final ValueChanged<int> onTap;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: List.generate(courses.length, (i) {
          final isSelected = i == selectedIndex;
          final course = courses[i];
          return GestureDetector(
            onTap: () => onTap(i),
            behavior: HitTestBehavior.opaque,
            child:
                AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      margin: const EdgeInsets.only(right: 8),
                      constraints: const BoxConstraints(minHeight: 48),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 14,
                        vertical: 8,
                      ),
                      decoration: BoxDecoration(
                        color: isSelected
                            ? AppColors.primary
                            : AppColors.surfaceTint,
                        borderRadius: BorderRadius.circular(999),
                        border: Border.all(
                          color: isSelected
                              ? AppColors.primary
                              : AppColors.border,
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          if (course.isGenerated) ...[
                            const Icon(
                              Icons.auto_awesome_rounded,
                              size: 12,
                              color: AppColors.white,
                            ),
                            const SizedBox(width: 4),
                          ],
                          Text(
                            course.subjectLabel,
                            style: Theme.of(context).textTheme.labelLarge
                                ?.copyWith(
                                  color: isSelected
                                      ? AppColors.white
                                      : AppColors.inkSecondary,
                                ),
                          ),
                        ],
                      ),
                    )
                    .animate(key: ValueKey('chip_$i'))
                    .fadeIn(
                      delay: Duration(milliseconds: i * 40),
                      duration: const Duration(milliseconds: 250),
                    ),
          );
        }),
      ),
    );
  }
}

// ── Single course page ────────────────────────────────────────────────────────

/// One page inside the PageView.
/// Layout: `SingleChildScrollView > Column(mainAxisSize: .min)`.
class _CoursePage extends ConsumerWidget {
  const _CoursePage({
    required this.course,
    required this.onStartLesson,
    required this.mascotState,
    super.key,
  });

  final Course course;
  final VoidCallback onStartLesson;
  final MascotState mascotState;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tokens =
        Theme.of(context).extension<AppTokens>() ?? AppTokens.defaults();
    final state = ref.watch(coursesProvider);
    final notifier = ref.read(coursesProvider.notifier);

    final activeLessons = course.allLessons
        .where((l) => !l.isCompleted && !l.isLocked)
        .toList();
    final activeLesson = activeLessons.isNotEmpty ? activeLessons.first : null;

    final scrollContent = SingleChildScrollView(
      padding: EdgeInsets.symmetric(
        horizontal: tokens.screenPadding,
        vertical: tokens.gapLg,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // ── Course title + hints ─────────────────────────────────────────
          Text(
                course.title,
                style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                  color: AppColors.ink,
                ),
                textAlign: TextAlign.center,
              )
              .animate()
              .fadeIn(duration: const Duration(milliseconds: 300))
              .slideY(begin: -0.08, end: 0),

          if (course.gradeHint != null || course.interestHint != null) ...[
            SizedBox(height: tokens.gapXs),
            Wrap(
              alignment: WrapAlignment.center,
              spacing: tokens.gapSm,
              children: [
                if (course.gradeHint != null)
                  _HintChip(label: course.gradeHint!),
                if (course.interestHint != null)
                  _HintChip(
                    label: course.interestHint!,
                    icon: Icons.favorite_rounded,
                  ),
              ],
            ).animate().fadeIn(
              delay: const Duration(milliseconds: 80),
              duration: const Duration(milliseconds: 250),
            ),
          ],

          SizedBox(height: tokens.gapXs),
          Container(
            padding: EdgeInsets.symmetric(
              horizontal: tokens.gapMd,
              vertical: tokens.gapXs,
            ),
            decoration: BoxDecoration(
              color: AppColors.surfaceTint,
              borderRadius: BorderRadius.circular(tokens.radiusSm),
            ),
            child: Text(
              course.level,
              style: Theme.of(context).textTheme.labelLarge?.copyWith(
                color: AppColors.primary,
              ),
            ),
          ).animate().fadeIn(
            delay: const Duration(milliseconds: 120),
            duration: const Duration(milliseconds: 250),
          ),

          SizedBox(height: tokens.gapXxl),

          // ── Central TopicDiagramSlot ──────────────────────────────────────
          const TopicDiagramSlot(size: 140)
              .animate()
              .fadeIn(
                delay: const Duration(milliseconds: 160),
                duration: const Duration(milliseconds: 350),
              )
              .scale(
                begin: const Offset(0.92, 0.92),
                end: const Offset(1, 1),
                delay: const Duration(milliseconds: 160),
                duration: const Duration(milliseconds: 350),
              ),

          SizedBox(height: tokens.gapXxl),

          // ── Vertical node path (collapsed by default) ─────────────────────
          _CollapsedLessonPath(
            course: course,
            expandedLessonId: state.expandedLessonId,
            onToggle: notifier.toggleLesson,
          ),

          SizedBox(height: tokens.gapXxl),

          // ── Bottom box: active lesson + diagram ───────────────────────────
          if (activeLesson != null) ...[
            _LessonStartBox(lesson: activeLesson),
            SizedBox(height: tokens.gapLg),
          ],

          // ── FeaturedButton (featured CTA — §8) ───────────────────────────
          FeaturedButton(
            label: 'Начать урок',
            onPressed: onStartLesson,
          ),

          SizedBox(height: tokens.gapXl),
        ],
      ),
    );

    // Phase 7: mascot fly-down overlay.
    if (mascotState == MascotState.flyDown) {
      return Stack(
        children: [
          scrollContent,
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: Center(
              child: MascotSlot(size: 100, state: mascotState),
            ),
          ),
        ],
      );
    }

    return scrollContent;
  }
}

// ── Hint chip ─────────────────────────────────────────────────────────────────

class _HintChip extends StatelessWidget {
  const _HintChip({required this.label, this.icon});

  final String label;
  final IconData? icon;

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
        color: AppColors.primary.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(tokens.radiusSm),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(icon, size: 12, color: AppColors.primary),
            SizedBox(width: tokens.gapXs),
          ],
          Text(
            label,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: AppColors.primary,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

// ── Collapsed lesson path ─────────────────────────────────────────────────────

/// Renders each lesson as a compact tappable row.
/// Tapping a non-locked lesson toggles an expansion card.
/// All lessons start collapsed — the «Начать урок» box is immediately visible.
class _CollapsedLessonPath extends StatelessWidget {
  const _CollapsedLessonPath({
    required this.course,
    required this.expandedLessonId,
    required this.onToggle,
  });

  final Course course;
  final String? expandedLessonId;
  final ValueChanged<String> onToggle;

  @override
  Widget build(BuildContext context) {
    final allLessons = course.allLessons;
    if (allLessons.isEmpty) return const SizedBox.shrink();

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(allLessons.length * 2 - 1, (i) {
        if (i.isOdd) {
          final lessonAbove = allLessons[i ~/ 2];
          return _NodeConnector(
            isCompleted: lessonAbove.isCompleted,
          );
        }
        final lesson = allLessons[i ~/ 2];
        final isExpanded = expandedLessonId == lesson.id;

        LessonNodeState nodeState;
        if (lesson.isCompleted) {
          nodeState = LessonNodeState.done;
        } else if (lesson.isLocked) {
          nodeState = LessonNodeState.locked;
        } else {
          nodeState = LessonNodeState.active;
        }

        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Compact row: node + title (always visible)
            GestureDetector(
                  onTap: lesson.isLocked ? null : () => onToggle(lesson.id),
                  behavior: HitTestBehavior.opaque,
                  child: Row(
                    children: [
                      LessonNode(state: nodeState, size: 52),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          lesson.title,
                          style: Theme.of(context).textTheme.bodyLarge
                              ?.copyWith(
                                color: lesson.isLocked
                                    ? AppColors.inkSecondary
                                    : AppColors.ink,
                                fontWeight: isExpanded
                                    ? FontWeight.w700
                                    : FontWeight.w500,
                              ),
                        ),
                      ),
                      if (!lesson.isLocked)
                        Icon(
                          isExpanded
                              ? Icons.keyboard_arrow_up_rounded
                              : Icons.keyboard_arrow_down_rounded,
                          color: AppColors.inkSecondary,
                          size: 20,
                        ),
                    ],
                  ),
                )
                .animate(key: ValueKey('node_row_${lesson.id}'))
                .fadeIn(
                  delay: Duration(milliseconds: (i ~/ 2) * 60),
                  duration: const Duration(milliseconds: 280),
                )
                .slideY(
                  begin: 0.06,
                  end: 0,
                  delay: Duration(milliseconds: (i ~/ 2) * 60),
                  duration: const Duration(milliseconds: 280),
                ),

            // Expandable detail card
            AnimatedSize(
              duration: const Duration(milliseconds: 220),
              curve: Curves.easeInOut,
              child: isExpanded
                  ? Padding(
                      padding: const EdgeInsets.only(
                        left: 64,
                        top: 8,
                        bottom: 4,
                      ),
                      child:
                          AppCard(
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  lesson.title,
                                  style: Theme.of(context).textTheme.labelLarge
                                      ?.copyWith(color: AppColors.ink),
                                ),
                                if (lesson.theory.isNotEmpty) ...[
                                  const SizedBox(height: 6),
                                  Text(
                                    '${lesson.theory.length} карточки теории',
                                    style: Theme.of(context).textTheme.bodySmall
                                        ?.copyWith(
                                          color: AppColors.inkSecondary,
                                        ),
                                  ),
                                ],
                              ],
                            ),
                          ).animate().fadeIn(
                            duration: const Duration(milliseconds: 200),
                          ),
                    )
                  : const SizedBox.shrink(),
            ),
          ],
        );
      }),
    );
  }
}

/// Vertical connector between two nodes.
class _NodeConnector extends StatelessWidget {
  const _NodeConnector({required this.isCompleted});

  final bool isCompleted;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 24,
      width: 52,
      child: Center(
        child: SizedBox(
          width: 2,
          height: 24,
          child: DecoratedBox(
            decoration: BoxDecoration(
              color: isCompleted ? AppColors.primary : AppColors.border,
              borderRadius: BorderRadius.circular(1),
            ),
          ),
        ),
      ),
    );
  }
}

/// Bottom card showing the active lesson + diagram side by side.
class _LessonStartBox extends StatelessWidget {
  const _LessonStartBox({required this.lesson});

  final CourseLesson lesson;

  @override
  Widget build(BuildContext context) {
    return AppCard(
      child: Row(
        children: [
          const TopicDiagramSlot(size: 64),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              lesson.title,
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                color: AppColors.ink,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ── «Создать курс» bottom sheet ───────────────────────────────────────────────

class _CreateCourseSheet extends StatefulWidget {
  const _CreateCourseSheet({required this.onConfirm});

  final ValueChanged<String> onConfirm;

  @override
  State<_CreateCourseSheet> createState() => _CreateCourseSheetState();
}

class _CreateCourseSheetState extends State<_CreateCourseSheet> {
  final _controller = TextEditingController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final tokens =
        Theme.of(context).extension<AppTokens>() ?? AppTokens.defaults();
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;

    return Container(
          margin: const EdgeInsets.symmetric(horizontal: 12),
          padding: EdgeInsets.fromLTRB(
            tokens.screenPadding,
            tokens.gapXl,
            tokens.screenPadding,
            tokens.gapXl + bottomInset,
          ),
          decoration: BoxDecoration(
            color: AppColors.white,
            borderRadius: BorderRadius.vertical(
              top: Radius.circular(tokens.radiusXl),
            ),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Handle bar
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: AppColors.border,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              SizedBox(height: tokens.gapXl),

              Text(
                'Создать курс',
                style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                  color: AppColors.ink,
                ),
              ),
              SizedBox(height: tokens.gapSm),
              Text(
                'Введи тему, и мы создадим для тебя курс с теорией и заданиями.',
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  color: AppColors.inkSecondary,
                ),
              ),
              SizedBox(height: tokens.gapXl),

              // Text field
              Container(
                decoration: BoxDecoration(
                  color: AppColors.surfaceTint,
                  borderRadius: BorderRadius.circular(tokens.radiusMd),
                  border: Border.all(color: AppColors.border),
                ),
                child: TextField(
                  controller: _controller,
                  autofocus: true,
                  textCapitalization: TextCapitalization.sentences,
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    color: AppColors.ink,
                  ),
                  decoration: InputDecoration(
                    hintText: 'Например: Алгебра, IELTS, Химия…',
                    hintStyle: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      color: AppColors.inkSecondary,
                    ),
                    border: InputBorder.none,
                    contentPadding: EdgeInsets.all(tokens.cardPadding),
                  ),
                  onSubmitted: (v) {
                    if (v.trim().isNotEmpty) widget.onConfirm(v.trim());
                  },
                ),
              ),
              SizedBox(height: tokens.gapXl),

              // Confirm — FeaturedButton for this featured CTA (§8)
              FeaturedButton(
                label: 'Создать',
                icon: const Icon(
                  Icons.auto_awesome_rounded,
                  color: AppColors.white,
                  size: 18,
                ),
                onPressed: () {
                  final topic = _controller.text.trim();
                  if (topic.isNotEmpty) widget.onConfirm(topic);
                },
              ),
            ],
          ),
        )
        .animate()
        .slideY(
          begin: 0.15,
          end: 0,
          duration: const Duration(milliseconds: 320),
          curve: Curves.easeOutCubic,
        )
        .fadeIn(duration: const Duration(milliseconds: 200));
  }
}
