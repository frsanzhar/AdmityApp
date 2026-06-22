import 'package:admity/core/theme/app_colors.dart';
import 'package:admity/core/theme/app_tokens.dart';
import 'package:admity/shared/widgets/app_card.dart';
import 'package:admity/shared/widgets/app_scaffold.dart';
import 'package:admity/shared/widgets/featured_button.dart';
import 'package:admity/shared/widgets/lesson_node.dart';
import 'package:admity/shared/widgets/mascot_slot.dart';
import 'package:admity/shared/widgets/topic_diagram_slot.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

// ── Domain models ─────────────────────────────────────────────────────────────

/// A course tab shown at the top of the Courses screen.
class CourseTab {
  const CourseTab({required this.id, required this.label});

  final String id;
  final String label;
}

/// A single lesson item on the vertical node path.
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

// ── State ─────────────────────────────────────────────────────────────────────

/// State for the Courses screen: selected tab index + active lesson index.
class CoursesState {
  const CoursesState({
    required this.selectedTabIndex,
    required this.activeLessonIndex,
  });

  final int selectedTabIndex;
  final int activeLessonIndex;

  CoursesState copyWith({int? selectedTabIndex, int? activeLessonIndex}) {
    return CoursesState(
      selectedTabIndex: selectedTabIndex ?? this.selectedTabIndex,
      activeLessonIndex: activeLessonIndex ?? this.activeLessonIndex,
    );
  }
}

class CoursesNotifier extends Notifier<CoursesState> {
  @override
  CoursesState build() => const CoursesState(
        selectedTabIndex: 0,
        activeLessonIndex: 1,
      );

  void selectTab(int index) {
    state = state.copyWith(selectedTabIndex: index);
  }

  /// Swipe right on the TopicDiagramSlot → advance to the next lesson.
  void advanceLessonBySwipe() {
    const lessons = courseLessons;
    final nextIndex = (state.activeLessonIndex + 1).clamp(0, lessons.length - 1);
    state = state.copyWith(activeLessonIndex: nextIndex);
  }
}

final coursesProvider =
    NotifierProvider<CoursesNotifier, CoursesState>(CoursesNotifier.new);

// ── Seed data (ref-data constants) ────────────────────────────────────────────

const _courseTabs = <CourseTab>[
  CourseTab(id: 'math', label: 'Математика'),
  CourseTab(id: 'logic', label: 'Логика'),
  CourseTab(id: 'english', label: 'Английский'),
];

/// Seed lessons for the currently selected course.
/// In a real app this would be keyed per courseTab.id.
const courseLessons = <LessonItem>[
  LessonItem(
    id: 1,
    title: 'Введение в вероятность',
    nodeState: LessonNodeState.done,
  ),
  LessonItem(
    id: 2,
    title: 'Сравнение вероятностей',
    nodeState: LessonNodeState.active,
  ),
  LessonItem(
    id: 3,
    title: 'Комбинаторика',
    nodeState: LessonNodeState.locked,
  ),
  LessonItem(
    id: 4,
    title: 'Независимые события',
    nodeState: LessonNodeState.locked,
  ),
  LessonItem(
    id: 5,
    title: 'Формула Байеса',
    nodeState: LessonNodeState.locked,
  ),
];

// ── Screen ────────────────────────────────────────────────────────────────────

/// Courses screen — Brilliant-style lesson path (DESIGN_SYSTEM.md §7.3).
///
/// Layout: AppScaffold > SingleChildScrollView > Column(mainAxisSize: .min).
/// Accent: AppColors.primary (cobalt — tab underline + active node ring).
/// FeaturedButton is used ONLY for "Start the Lesson" (featured CTA).
///
/// Phase 7 motion: tapping "Начать урок" triggers [MascotState.flyDown],
/// shows the mascot flying down for 700 ms, then navigates.
/// reduceMotion skips straight to navigation.
class CoursesScreen extends ConsumerStatefulWidget {
  const CoursesScreen({super.key});

  @override
  ConsumerState<CoursesScreen> createState() => _CoursesScreenState();
}

class _CoursesScreenState extends ConsumerState<CoursesScreen> {
  MascotState _mascotState = MascotState.idle;

  void _onStartLesson() {
    final reduceMotion = MediaQuery.of(context).disableAnimations;
    // Phase 7: trigger fly-down mascot overlay (non-blocking — navigation fires
    // immediately so tests and reduceMotion users are unaffected).
    if (!reduceMotion) {
      setState(() => _mascotState = MascotState.flyDown);
    }
    context.go('/lesson');
  }

  @override
  Widget build(BuildContext context) {
    final tokens =
        Theme.of(context).extension<AppTokens>() ?? AppTokens.defaults();
    final state = ref.watch(coursesProvider);
    final notifier = ref.read(coursesProvider.notifier);

    final selectedTab = _courseTabs[state.selectedTabIndex];
    final activeLesson = courseLessons[
        state.activeLessonIndex.clamp(0, courseLessons.length - 1)];

    final scrollBody = SingleChildScrollView(
      padding: EdgeInsets.symmetric(
        horizontal: tokens.screenPadding,
        vertical: tokens.gapLg,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // ── 1. Course tabs ────────────────────────────────────────────────
          _CourseTabs(
            tabs: _courseTabs,
            selectedIndex: state.selectedTabIndex,
            onTabSelected: notifier.selectTab,
          ),
          SizedBox(height: tokens.gapXl),

          // ── 2. Today's course/lesson header ───────────────────────────────
          Text(
            selectedTab.label,
            style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                  color: AppColors.ink,
                ),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: tokens.gapXs),
          Text(
            activeLesson.title,
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  color: AppColors.inkSecondary,
                ),
            textAlign: TextAlign.center,
          ),
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
              'Уровень 1',
              style: Theme.of(context).textTheme.labelLarge?.copyWith(
                    color: AppColors.primary,
                  ),
            ),
          ),
          SizedBox(height: tokens.gapXxl),

          // ── 3. Central TopicDiagramSlot with swipe-right gesture ──────────
          _SwipeableDiagram(
            onSwipeRight: notifier.advanceLessonBySwipe,
          ),
          SizedBox(height: tokens.gapXxl),

          // ── 4. Vertical node path ─────────────────────────────────────────
          _LessonPath(
            lessons: courseLessons,
            activeLessonIndex: state.activeLessonIndex,
          ),
          SizedBox(height: tokens.gapXxl),

          // ── 5. Bottom lesson box + FeaturedButton ─────────────────────────
          _LessonStartBox(activeLesson: activeLesson),
          SizedBox(height: tokens.gapLg),
          FeaturedButton(
            label: 'Начать урок',
            onPressed: _onStartLesson,
          ),
          SizedBox(height: tokens.gapXl),
        ],
      ),
    );

    // Phase 7: overlay the mascot fly-down on top of the scroll body.
    // Stack is only introduced here; the scroll layout tree is unchanged.
    final body = _mascotState == MascotState.flyDown
        ? Stack(
            children: [
              scrollBody,
              // Mascot flies down from the top-centre of the screen.
              Positioned(
                top: 0,
                left: 0,
                right: 0,
                child: Center(
                  child: MascotSlot(
                    size: 100,
                    state: _mascotState,
                  ),
                ),
              ),
            ],
          )
        : scrollBody;

    return AppScaffold(body: body);
  }
}

// ── Sub-widgets ───────────────────────────────────────────────────────────────

/// Horizontal scrollable tab row with a blue underline under the selected tab.
class _CourseTabs extends StatelessWidget {
  const _CourseTabs({
    required this.tabs,
    required this.selectedIndex,
    required this.onTabSelected,
  });

  final List<CourseTab> tabs;
  final int selectedIndex;
  final ValueChanged<int> onTabSelected;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: List.generate(tabs.length, (i) {
          final isSelected = i == selectedIndex;
          return GestureDetector(
            onTap: () => onTabSelected(i),
            behavior: HitTestBehavior.opaque,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    child: Text(
                      tabs[i].label,
                      style: Theme.of(context).textTheme.labelLarge?.copyWith(
                            color: isSelected
                                ? AppColors.primary
                                : AppColors.inkSecondary,
                          ),
                    ),
                  ),
                  // Active blue underline
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 180),
                    height: 2,
                    width: 48,
                    decoration: BoxDecoration(
                      color: isSelected
                          ? AppColors.primary
                          : Colors.transparent,
                      borderRadius: BorderRadius.circular(1),
                    ),
                  ),
                ],
              ),
            ),
          );
        }),
      ),
    );
  }
}

/// Wraps [TopicDiagramSlot] with a horizontal drag detector.
/// A leftward flick (dx < -40) triggers [onSwipeRight] (select next lesson).
class _SwipeableDiagram extends StatelessWidget {
  const _SwipeableDiagram({required this.onSwipeRight});

  final VoidCallback onSwipeRight;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onHorizontalDragEnd: (details) {
        // Negative velocity.x = leftward swipe on screen = "swipe right" intent
        // per the spec (drag right = advance). Positive velocity = swipe right.
        if ((details.primaryVelocity ?? 0) > 40) {
          onSwipeRight();
        }
      },
      child: const TopicDiagramSlot(size: 160),
    );
  }
}

/// Vertical path of [LessonNode]s connected by a dotted line.
class _LessonPath extends StatelessWidget {
  const _LessonPath({
    required this.lessons,
    required this.activeLessonIndex,
  });

  final List<LessonItem> lessons;
  final int activeLessonIndex;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(lessons.length * 2 - 1, (i) {
        // Even indices = nodes, odd = connectors
        if (i.isOdd) {
          return _NodeConnector(
            isCompleted: lessons[i ~/ 2].nodeState == LessonNodeState.done,
          );
        }
        final lesson = lessons[i ~/ 2];
        return LessonNode(
          state: lesson.nodeState,
          label: lesson.title,
          size: 60,
        );
      }),
    );
  }
}

/// Thin vertical line connecting two [LessonNode]s.
class _NodeConnector extends StatelessWidget {
  const _NodeConnector({required this.isCompleted});

  final bool isCompleted;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 32,
      width: 2,
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: isCompleted ? AppColors.primary : AppColors.border,
          borderRadius: BorderRadius.circular(1),
        ),
      ),
    );
  }
}

/// Bottom card showing the active lesson + diagram side by side.
class _LessonStartBox extends StatelessWidget {
  const _LessonStartBox({required this.activeLesson});

  final LessonItem activeLesson;

  @override
  Widget build(BuildContext context) {
    return AppCard(
      child: Row(
        children: [
          const TopicDiagramSlot(size: 64),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              activeLesson.title,
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    color: AppColors.ink,
                  ),
              textAlign: TextAlign.center,
            ),
          ),
        ],
      ),
    );
  }
}
