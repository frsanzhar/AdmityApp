/// CoursesScreen — Brilliant-style course path (DESIGN_SYSTEM.md §7.3).
///
/// ## Layout
/// `AppScaffold > Column > [fixed _TopBar] > Expanded > PageView`
/// Each page: `SingleChildScrollView > Column(mainAxisSize: .min)`.
/// Never uses CrossAxisAlignment.stretch inside a scroll — follows the
/// blank-screen gotcha rule from CLAUDE.md.
///
/// ## Top bar (fixed, outside scroll)
/// chevron-down | KeyBadge(2) | Spacer | StreakBadge(7) | «Создать курс» pill
///
/// ## PageView (requirement 4)
/// Swiping left/right moves between whole course pages
/// (e.g. Математика → Логика → Английский). A horizontal scrollable chip row
/// at the top of each page scroll area lets the user jump by tap.
///
/// ## Course header (inside scroll)
/// TopicDiagramSlot(120) → title → stats row → bordered level chip.
///
/// ## Node path (inside scroll)
/// Centred column of LessonNode discs connected by thin vertical lines.
/// Active node has MascotSlot sitting ABOVE it. Tapping a non-locked node
/// toggles an expansion card below it.
///
/// ## Bottom lesson box (inside scroll)
/// AppCard with TopicDiagramSlot(56) + lesson title, then two buttons stacked:
/// PrimaryButton «Начать» (dark) and FeaturedButton «Перепрыгнуть» (gradient).
///
/// ## «Создать курс» (requirement 2)
/// Small pill button in the top bar. Bottom sheet with text field +
/// FeaturedButton «Создать».
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
import 'package:admity/shared/widgets/key_badge.dart';
import 'package:admity/shared/widgets/lesson_node.dart';
import 'package:admity/shared/widgets/mascot_slot.dart';
import 'package:admity/shared/widgets/primary_button.dart';
import 'package:admity/shared/widgets/streak_badge.dart';
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

/// CoursesScreen — Brilliant-style redesign.
///
/// Fixed top bar (chevron + badges + «Создать курс»), then an Expanded
/// PageView of scrollable course pages.
class CoursesScreen extends ConsumerStatefulWidget {
  const CoursesScreen({super.key});

  @override
  ConsumerState<CoursesScreen> createState() => _CoursesScreenState();
}

class _CoursesScreenState extends ConsumerState<CoursesScreen> {
  late final PageController _pageController;
  // Phase 7: updated via setState when mascot flies down.
  final MascotState _mascotState = MascotState.idle;

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
    // TODO(motion): mascot fly-down
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

    return AppScaffold(
      body: SafeArea(
        child: Column(
          children: [
            // ── Fixed top bar ──────────────────────────────────────────────
            _TopBar(
              isGenerating: state.isGenerating,
              onCreateCourse: _showCreateCourseSheet,
            ),

            // ── Full-page swipeable PageView ──────────────────────────────
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
                    courses: state.courses,
                    selectedIndex: state.pageIndex,
                    expandedLessonId: state.expandedLessonId,
                    onTabTap: _jumpToPage,
                    onStartLesson: _onStartLesson,
                    mascotState: _mascotState,
                    onToggleLesson: ref
                        .read(coursesProvider.notifier)
                        .toggleLesson,
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Top bar ───────────────────────────────────────────────────────────────────

/// Fixed top bar outside the PageView scroll area.
/// Row: chevron-down | KeyBadge(2) | Spacer | StreakBadge(7) | «Создать курс»
class _TopBar extends StatelessWidget {
  const _TopBar({
    required this.isGenerating,
    required this.onCreateCourse,
  });

  final bool isGenerating;
  final VoidCallback onCreateCourse;

  @override
  Widget build(BuildContext context) {
    final tokens =
        Theme.of(context).extension<AppTokens>() ?? AppTokens.defaults();

    return Padding(
      padding: EdgeInsets.symmetric(
        horizontal: tokens.screenPadding,
        vertical: tokens.gapMd,
      ),
      child: Row(
        children: [
          // Collapse / back chevron
          GestureDetector(
            onTap: () {
              // Chevron-down: collapse / back — no-op until parent nav is wired
            },
            behavior: HitTestBehavior.opaque,
            child: const SizedBox(
              width: 44,
              height: 44,
              child: Center(
                child: Icon(
                  Icons.keyboard_arrow_down_rounded,
                  size: 28,
                  color: AppColors.ink,
                ),
              ),
            ),
          ),
          const SizedBox(width: 8),
          // TODO(profile): wire to real key count from profileProvider
          const KeyBadge(count: 2),
          const Spacer(),
          // TODO(profile): wire to real streak from profileProvider
          const StreakBadge(days: 7),
          const SizedBox(width: 8),
          // «Создать курс» pill button
          if (isGenerating)
            const SizedBox(
              width: 22,
              height: 22,
              child: CircularProgressIndicator(
                strokeWidth: 2.5,
                color: AppColors.primary,
              ),
            )
          else
            GestureDetector(
              onTap: onCreateCourse,
              behavior: HitTestBehavior.opaque,
              child: Container(
                constraints: const BoxConstraints(minHeight: 44),
                padding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: AppColors.ink,
                  borderRadius: BorderRadius.circular(999),
                ),
                alignment: Alignment.center,
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(
                      Icons.add_rounded,
                      color: AppColors.white,
                      size: 16,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      'Создать курс',
                      style: Theme.of(context).textTheme.labelLarge?.copyWith(
                        color: AppColors.white,
                      ),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }
}

// ── Single course page ────────────────────────────────────────────────────────

/// One page inside the PageView.
/// Layout: `SingleChildScrollView > Column(mainAxisSize: .min)`.
class _CoursePage extends StatelessWidget {
  const _CoursePage({
    required this.course,
    required this.courses,
    required this.selectedIndex,
    required this.expandedLessonId,
    required this.onTabTap,
    required this.onStartLesson,
    required this.mascotState,
    required this.onToggleLesson,
    super.key,
  });

  final Course course;
  final List<Course> courses;
  final int selectedIndex;
  final String? expandedLessonId;
  final ValueChanged<int> onTabTap;
  final VoidCallback onStartLesson;
  final MascotState mascotState;
  final ValueChanged<String> onToggleLesson;

  @override
  Widget build(BuildContext context) {
    final tokens =
        Theme.of(context).extension<AppTokens>() ?? AppTokens.defaults();

    final allLessons = course.allLessons;
    final activeLessons = allLessons
        .where((l) => !l.isCompleted && !l.isLocked)
        .toList();
    final activeLesson = activeLessons.isNotEmpty ? activeLessons.first : null;
    final activeLessonIndex = activeLesson != null
        ? allLessons.indexOf(activeLesson)
        : -1;

    // Count stats
    final totalLessons = allLessons.length;
    final totalExercises = allLessons.fold<int>(
      0,
      (sum, l) => sum + l.questions.length,
    );

    // First module title for the level chip subtitle
    final firstModuleTitle = course.modules.isNotEmpty
        ? course.modules.first.title
        : course.level;

    final scrollContent = SingleChildScrollView(
      padding: EdgeInsets.symmetric(
        horizontal: tokens.screenPadding,
        vertical: tokens.gapLg,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // ── Tab chip row ────────────────────────────────────────────────
          _CourseTabRow(
            courses: courses,
            selectedIndex: selectedIndex,
            onTap: onTabTap,
          ),

          SizedBox(height: tokens.gapXxl),

          // ── Course header ────────────────────────────────────────────────
          _CourseHeader(
            course: course,
            totalLessons: totalLessons,
            totalExercises: totalExercises,
            firstModuleTitle: firstModuleTitle,
          ),

          SizedBox(height: tokens.gapXxl),

          // ── Vertical node path ───────────────────────────────────────────
          _NodePath(
            course: course,
            expandedLessonId: expandedLessonId,
            onToggle: onToggleLesson,
          ),

          SizedBox(height: tokens.gapXl),

          // ── Bottom lesson box ────────────────────────────────────────────
          if (activeLesson != null) ...[
            _LessonStartBox(
              lesson: activeLesson,
              lessonIndex: activeLessonIndex,
              onStart: onStartLesson,
            ),
          ],

          SizedBox(height: tokens.gapXxl),
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

// ── Tab chip row ──────────────────────────────────────────────────────────────

/// Horizontal scrollable pill chips inside the scroll area (first item).
/// Selected = AppColors.primary fill + white text.
/// Unselected = AppColors.surfaceTint + AppColors.inkSecondary text.
class _CourseTabRow extends StatelessWidget {
  const _CourseTabRow({
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
                      constraints: const BoxConstraints(minHeight: 44),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 8,
                      ),
                      decoration: BoxDecoration(
                        color: isSelected
                            ? AppColors.primary
                            : AppColors.surfaceTint,
                        borderRadius: BorderRadius.circular(999),
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

// ── Course header ─────────────────────────────────────────────────────────────

/// Central header: TopicDiagramSlot → title → stats row → bordered level chip.
class _CourseHeader extends StatelessWidget {
  const _CourseHeader({
    required this.course,
    required this.totalLessons,
    required this.totalExercises,
    required this.firstModuleTitle,
  });

  final Course course;
  final int totalLessons;
  final int totalExercises;
  final String firstModuleTitle;

  @override
  Widget build(BuildContext context) {
    final tokens =
        Theme.of(context).extension<AppTokens>() ?? AppTokens.defaults();

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // 3D topic art
        // size: 120 (default) — matches DESIGN_SYSTEM.md §7.3 spec
        const TopicDiagramSlot()
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

        SizedBox(height: tokens.gapSm),

        // Course title
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

        SizedBox(height: tokens.gapXs),

        // Stats row
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.menu_book_rounded,
              size: 14,
              color: AppColors.inkSecondary,
            ),
            const SizedBox(width: 4),
            Text(
              '$totalLessons уроков',
              style: Theme.of(context).textTheme.bodySmall,
            ),
            const SizedBox(width: 12),
            Text(
              '·',
              style: Theme.of(context).textTheme.bodySmall,
            ),
            const SizedBox(width: 12),
            const Icon(
              Icons.edit_rounded,
              size: 14,
              color: AppColors.inkSecondary,
            ),
            const SizedBox(width: 4),
            Text(
              '$totalExercises упражнений',
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ],
        ),

        SizedBox(height: tokens.gapLg),

        // Bordered level chip
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          decoration: BoxDecoration(
            border: Border.all(color: AppColors.primary, width: 2),
            borderRadius: BorderRadius.circular(tokens.radiusMd),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                course.level.toUpperCase(),
                style: Theme.of(context).textTheme.labelLarge?.copyWith(
                  color: AppColors.primary,
                  letterSpacing: 1.2,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                firstModuleTitle,
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  color: AppColors.ink,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ).animate().fadeIn(
          delay: const Duration(milliseconds: 120),
          duration: const Duration(milliseconds: 250),
        ),
      ],
    );
  }
}

// ── Node path ─────────────────────────────────────────────────────────────────

/// Vertical column of centred LessonNode discs connected by thin lines.
/// Active node has MascotSlot sitting above it.
class _NodePath extends StatelessWidget {
  const _NodePath({
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
          return _NodeConnector(isCompleted: lessonAbove.isCompleted);
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

        return _LessonNodeRow(
              lesson: lesson,
              nodeState: nodeState,
              isExpanded: isExpanded,
              onToggle: () {
                if (!lesson.isLocked) onToggle(lesson.id);
              },
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
            );
      }),
    );
  }
}

/// A single lesson row: MascotSlot (if active) above the node disc, then
/// an optional expanded detail card below.
class _LessonNodeRow extends StatelessWidget {
  const _LessonNodeRow({
    required this.lesson,
    required this.nodeState,
    required this.isExpanded,
    required this.onToggle,
  });

  final CourseLesson lesson;
  final LessonNodeState nodeState;
  final bool isExpanded;
  final VoidCallback onToggle;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: GestureDetector(
        onTap: lesson.isLocked ? null : onToggle,
        behavior: HitTestBehavior.opaque,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // MascotSlot sits above the active node
            if (nodeState == LessonNodeState.active) ...[
              const MascotSlot(size: 44, tag: 'course-node'),
              const SizedBox(height: 4),
            ],
            LessonNode(state: nodeState, size: 60),
            // Expansion detail card
            AnimatedSize(
              duration: const Duration(milliseconds: 220),
              curve: Curves.easeInOut,
              child: isExpanded && nodeState != LessonNodeState.locked
                  ? Padding(
                      padding: const EdgeInsets.only(top: 8, bottom: 4),
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
        ),
      ),
    );
  }
}

/// Vertical connector line between two nodes.
/// 2 px wide, 28 px tall, primary if completed else border colour.
class _NodeConnector extends StatelessWidget {
  const _NodeConnector({required this.isCompleted});

  final bool isCompleted;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: SizedBox(
        width: 2,
        height: 28,
        child: DecoratedBox(
          decoration: BoxDecoration(
            color: isCompleted ? AppColors.primary : AppColors.border,
            borderRadius: BorderRadius.circular(1),
          ),
        ),
      ),
    );
  }
}

// ── Bottom lesson start box ───────────────────────────────────────────────────

/// AppCard with TopicDiagramSlot + lesson title/number, then two buttons:
/// PrimaryButton «Начать» (dark) and FeaturedButton «Перепрыгнуть» (gradient).
class _LessonStartBox extends StatelessWidget {
  const _LessonStartBox({
    required this.lesson,
    required this.lessonIndex,
    required this.onStart,
  });

  final CourseLesson lesson;
  final int lessonIndex;
  final VoidCallback onStart;

  @override
  Widget build(BuildContext context) {
    final tokens =
        Theme.of(context).extension<AppTokens>() ?? AppTokens.defaults();

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        AppCard(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const TopicDiagramSlot(size: 56),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          lesson.title,
                          style: Theme.of(context).textTheme.titleLarge
                              ?.copyWith(color: AppColors.ink),
                        ),
                        SizedBox(height: tokens.gapXs),
                        Text(
                          'Урок ${lessonIndex + 1}',
                          style: Theme.of(context).textTheme.bodySmall
                              ?.copyWith(color: AppColors.inkSecondary),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        SizedBox(height: tokens.gapMd),
        // Dark primary button for standard action
        PrimaryButton(label: 'Начать', onPressed: onStart),
        SizedBox(height: tokens.gapSm),
        // Gradient featured button for jump-ahead CTA
        FeaturedButton(label: 'Перепрыгнуть', onPressed: onStart),
      ],
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
