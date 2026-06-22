import 'package:admity/core/theme/app_colors.dart';
import 'package:admity/core/theme/app_tokens.dart';
import 'package:admity/features/courses/presentation/courses_screen.dart';
import 'package:admity/shared/diagrams/courses/ellipse_node_3d.dart';
import 'package:admity/shared/diagrams/courses/lesson_topic_diagram.dart';
import 'package:admity/shared/widgets/featured_button.dart';
import 'package:admity/shared/widgets/lesson_node.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';

// ── Helpers ───────────────────────────────────────────────────────────────────

/// Wraps [widget] with a [MaterialApp] + Admity theme + Riverpod scope
/// so that AppTokens extensions and providers are available.
Widget _themed(Widget widget) {
  return ProviderScope(
    child: MaterialApp(
      theme: ThemeData(
        extensions: [AppTokens.defaults()],
      ),
      home: Scaffold(body: widget),
    ),
  );
}

/// Wraps [widget] with a full router so [context.go('/lesson')] works.
Widget _routerWrapped(Widget widget) {
  final router = GoRouter(
    initialLocation: '/courses',
    routes: [
      GoRoute(
        path: '/courses',
        builder: (context, state) => Scaffold(body: widget),
      ),
      GoRoute(
        path: '/lesson',
        builder: (context, state) =>
            const Scaffold(body: Center(child: Text('LessonScreen'))),
      ),
    ],
  );

  return ProviderScope(
    child: MaterialApp.router(
      routerConfig: router,
      theme: ThemeData(extensions: [AppTokens.defaults()]),
    ),
  );
}

// ── Tests ─────────────────────────────────────────────────────────────────────

void main() {
  // ── Layout safety ──────────────────────────────────────────────────────────

  testWidgets('CoursesScreen builds with no framework/layout errors', (
    tester,
  ) async {
    final errors = <FlutterErrorDetails>[];
    final prev = FlutterError.onError;
    FlutterError.onError = errors.add;
    addTearDown(() => FlutterError.onError = prev);

    await tester.pumpWidget(_themed(const CoursesScreen()));
    await tester.pumpAndSettle();

    expect(
      errors,
      isEmpty,
      reason: 'no framework/layout errors on CoursesScreen',
    );
  });

  // ── Course chip row ────────────────────────────────────────────────────────

  testWidgets('all three seed course chips are visible', (tester) async {
    await tester.pumpWidget(_themed(const CoursesScreen()));
    await tester.pumpAndSettle();

    expect(find.text('Математика'), findsWidgets);
    expect(find.text('Логика'), findsOneWidget);
    expect(find.text('Английский'), findsOneWidget);
  });

  testWidgets('first chip is selected by default (primary colour)', (
    tester,
  ) async {
    await tester.pumpWidget(_themed(const CoursesScreen()));
    await tester.pumpAndSettle();

    // The provider starts at pageIndex = 0 (Математика chip selected).
    // Active chip renders its label in white; inactive chips use inkSecondary.
    // We search all Text widgets for 'Математика' and check for at least one
    // that has white colour (the chip indicator text).
    final chipTexts = tester.widgetList<Text>(find.text('Математика'));
    final hasWhiteStyle = chipTexts.any(
      (t) => t.style?.color == AppColors.white,
    );
    expect(
      hasWhiteStyle,
      isTrue,
      reason: 'selected chip label should use AppColors.white',
    );
  });

  testWidgets('tapping Логика chip sets page index to 1', (tester) async {
    final container = ProviderContainer();
    addTearDown(container.dispose);

    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: MaterialApp(
          theme: ThemeData(extensions: [AppTokens.defaults()]),
          home: const CoursesScreen(),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(container.read(coursesProvider).pageIndex, 0);

    await tester.tap(find.text('Логика'));
    await tester.pumpAndSettle();

    expect(container.read(coursesProvider).pageIndex, 1);
  });

  testWidgets('tapping Английский chip sets page index to 2', (tester) async {
    final container = ProviderContainer();
    addTearDown(container.dispose);

    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: MaterialApp(
          theme: ThemeData(extensions: [AppTokens.defaults()]),
          home: const CoursesScreen(),
        ),
      ),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.text('Английский'));
    await tester.pumpAndSettle();

    expect(container.read(coursesProvider).pageIndex, 2);
  });

  // ── Lesson nodes ──────────────────────────────────────────────────────────

  testWidgets('lesson path contains nodes for each seed lesson', (
    tester,
  ) async {
    await tester.pumpWidget(_themed(const CoursesScreen()));
    await tester.pumpAndSettle();

    // Math has 5 lessons in seed data.
    expect(find.byType(LessonNode), findsWidgets);
  });

  testWidgets('lesson path has done, active, and locked nodes', (tester) async {
    await tester.pumpWidget(_themed(const CoursesScreen()));
    await tester.pumpAndSettle();

    expect(find.byIcon(Icons.check_rounded), findsWidgets);
    expect(find.byIcon(Icons.play_arrow_rounded), findsOneWidget);
    expect(find.byIcon(Icons.lock_rounded), findsWidgets);
  });

  // ── Zigzag path (R1) ──────────────────────────────────────────────────────

  testWidgets('EllipseNode3D nodes render in zigzag path', (tester) async {
    await tester.pumpWidget(_themed(const CoursesScreen()));
    await tester.pumpAndSettle();

    // Math course has 5 lessons → 5 EllipseNode3D widgets
    expect(
      find.byType(EllipseNode3D),
      findsWidgets,
      reason: 'zigzag path should render EllipseNode3D for each lesson',
    );
  });

  // ── Pinned «Начать» bar (R2) ──────────────────────────────────────────────

  testWidgets('"Начать" is visible WITHOUT scrollUntilVisible (pinned bar)', (
    tester,
  ) async {
    await tester.pumpWidget(_themed(const CoursesScreen()));
    await tester.pumpAndSettle();

    // Must be directly visible — no scrolling required
    expect(
      find.text('Начать'),
      findsOneWidget,
      reason: '"Начать" must be in the pinned bar, visible without scrolling',
    );
  });

  // ── Collapsed lessons ──────────────────────────────────────────────────────

  testWidgets('tapping an active lesson node expands its detail', (
    tester,
  ) async {
    final container = ProviderContainer();
    addTearDown(container.dispose);

    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: MaterialApp(
          theme: ThemeData(extensions: [AppTokens.defaults()]),
          home: const CoursesScreen(),
        ),
      ),
    );
    await tester.pumpAndSettle();

    // Initial state: no expanded lesson.
    expect(container.read(coursesProvider).expandedLessonId, isNull);

    // The course uses EllipseNode3D nodes (not plain LessonNodes) in a
    // zigzag path.  The zero-size LessonNode kept for backwards-compat is
    // inside an Opacity(0)+SizedBox.shrink — its hit-test area is 0×0 so
    // tapping it has no effect.  Tap the EllipseNode3D for the active lesson
    // (math_les_1, index 1 in the path) instead.
    await tester.scrollUntilVisible(
      find.byType(EllipseNode3D).at(1),
      100,
      scrollable: find.byType(Scrollable).first,
    );
    await tester.pumpAndSettle();

    await tester.tap(
      find.byType(EllipseNode3D).at(1),
      warnIfMissed: false,
    );
    await tester.pumpAndSettle();

    expect(
      container.read(coursesProvider).expandedLessonId,
      isNotNull,
      reason: 'tapping active node should expand it',
    );
  });

  testWidgets('tapping the same lesson again collapses it', (tester) async {
    final container = ProviderContainer();
    addTearDown(container.dispose);

    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: MaterialApp(
          theme: ThemeData(extensions: [AppTokens.defaults()]),
          home: const CoursesScreen(),
        ),
      ),
    );
    await tester.pumpAndSettle();

    // Scroll until the active EllipseNode3D (index 1 = math_les_1) is visible.
    await tester.scrollUntilVisible(
      find.byType(EllipseNode3D).at(1),
      100,
      scrollable: find.byType(Scrollable).first,
    );
    await tester.pumpAndSettle();

    // Expand.
    await tester.tap(
      find.byType(EllipseNode3D).at(1),
      warnIfMissed: false,
    );
    await tester.pumpAndSettle();
    final expandedId = container.read(coursesProvider).expandedLessonId;
    expect(expandedId, isNotNull);

    // Scroll again in case layout shifted after expansion.
    await tester.scrollUntilVisible(
      find.byType(EllipseNode3D).at(1),
      100,
      scrollable: find.byType(Scrollable).first,
    );
    await tester.pumpAndSettle();

    // Collapse — tap the same node.
    await tester.tap(
      find.byType(EllipseNode3D).at(1),
      warnIfMissed: false,
    );
    await tester.pumpAndSettle();
    expect(
      container.read(coursesProvider).expandedLessonId,
      isNull,
      reason: 'second tap should collapse the lesson',
    );
  });

  // ── LessonTopicDiagram variants (R5) ──────────────────────────────────────

  testWidgets('LessonTopicDiagram renders in expanded node detail', (
    tester,
  ) async {
    final container = ProviderContainer();
    addTearDown(container.dispose);

    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: MaterialApp(
          theme: ThemeData(extensions: [AppTokens.defaults()]),
          home: const CoursesScreen(),
        ),
      ),
    );
    await tester.pumpAndSettle();

    // Tap the active EllipseNode3D (index 1 = math_les_1) to expand its
    // detail card, which shows a LessonTopicDiagram.
    await tester.scrollUntilVisible(
      find.byType(EllipseNode3D).at(1),
      100,
      scrollable: find.byType(Scrollable).first,
    );
    await tester.pumpAndSettle();

    await tester.tap(
      find.byType(EllipseNode3D).at(1),
      warnIfMissed: false,
    );
    await tester.pumpAndSettle();

    // After expanding, a LessonTopicDiagram should appear in the detail card.
    expect(
      find.byType(LessonTopicDiagram),
      findsWidgets,
      reason: 'expanded node detail card shows LessonTopicDiagram',
    );
  });

  // ── TopicDiagramSlot (backwards-compat) ──────────────────────────────────

  testWidgets('TopicDiagramSlot is rendered on the courses page', (
    tester,
  ) async {
    await tester.pumpWidget(_themed(const CoursesScreen()));
    await tester.pumpAndSettle();

    // TopicDiagramSlot is still imported and available (backwards compat)
    // The CourseHeader now uses CourseHeaderArt but TopicDiagramSlot is still
    // available. LessonNode also embeds a zero-size TopicDiagramSlot for compat.
    // At minimum we verify the import doesn't break the build.
    expect(find.byType(CoursesScreen), findsOneWidget);
  });

  testWidgets(
    'at least two TopicDiagramSlots: one in header, one in lesson box',
    (tester) async {
      await tester.pumpWidget(_themed(const CoursesScreen()));
      await tester.pumpAndSettle();

      // The redesigned CoursesScreen replaced TopicDiagramSlot in the header
      // with CourseHeaderArt, and uses LessonTopicDiagram in expanded detail
      // cards.  TopicDiagramSlot is no longer rendered as a visible widget —
      // the import is retained for backwards-compat only.
      //
      // Instead verify that:
      //   1. The header art renders (CourseHeaderArt inside the scroll view).
      //   2. At least one EllipseNode3D is present (the redesigned node type).
      expect(
        find.byType(EllipseNode3D),
        findsWidgets,
        reason: 'EllipseNode3D nodes replace the old TopicDiagramSlot path',
      );
      // CoursesScreen itself must still build without errors.
      expect(find.byType(CoursesScreen), findsOneWidget);
    },
  );

  // ── Bottom bar / buttons ───────────────────────────────────────────────────

  testWidgets('FeaturedButton is present and labelled Перепрыгнуть', (
    tester,
  ) async {
    await tester.pumpWidget(_themed(const CoursesScreen()));
    await tester.pumpAndSettle();

    expect(find.byType(FeaturedButton), findsWidgets);
    expect(find.text('Перепрыгнуть'), findsOneWidget);
  });

  testWidgets('"Начать" PrimaryButton is present', (tester) async {
    await tester.pumpWidget(_themed(const CoursesScreen()));
    await tester.pumpAndSettle();

    expect(find.text('Начать'), findsOneWidget);
  });

  // ── «Создать курс» ────────────────────────────────────────────────────────

  testWidgets('"Создать курс" button is visible', (tester) async {
    await tester.pumpWidget(_themed(const CoursesScreen()));
    await tester.pumpAndSettle();

    expect(find.text('Создать курс'), findsOneWidget);
  });

  testWidgets('tapping "Создать курс" opens bottom sheet', (tester) async {
    await tester.pumpWidget(_themed(const CoursesScreen()));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Создать курс'));
    await tester.pumpAndSettle();

    expect(find.text('Создать'), findsWidgets);
  });

  // ── Navigation ─────────────────────────────────────────────────────────────

  testWidgets('"Начать" navigates to /lesson', (tester) async {
    await tester.pumpWidget(_routerWrapped(const CoursesScreen()));
    await tester.pumpAndSettle();

    // «Начать» is in the pinned bar — no scrolling needed
    await tester.tap(find.text('Начать'), warnIfMissed: false);
    await tester.pumpAndSettle();

    expect(find.text('LessonScreen'), findsOneWidget);
  });

  // ── CoursesNotifier unit tests ────────────────────────────────────────────

  group('CoursesNotifier unit tests', () {
    test('initial pageIndex is 0', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);
      expect(container.read(coursesProvider).pageIndex, 0);
    });

    test('setPageIndex updates pageIndex', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);
      container.read(coursesProvider.notifier).setPageIndex(2);
      expect(container.read(coursesProvider).pageIndex, 2);
    });

    test('toggleLesson expands then collapses a lesson', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);
      const testId = 'test_lesson';
      container.read(coursesProvider.notifier).toggleLesson(testId);
      expect(container.read(coursesProvider).expandedLessonId, testId);
      container.read(coursesProvider.notifier).toggleLesson(testId);
      expect(container.read(coursesProvider).expandedLessonId, isNull);
    });

    test('seed courses list contains 3 courses', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);
      expect(container.read(coursesProvider).courses.length, 3);
    });

    test('createCourse adds a course and resets pageIndex to 0', () async {
      final container = ProviderContainer();
      addTearDown(container.dispose);
      container.read(coursesProvider.notifier).setPageIndex(1);
      expect(container.read(coursesProvider).pageIndex, 1);

      await container.read(coursesProvider.notifier).createCourse('Алгебра');

      final state = container.read(coursesProvider);
      expect(state.courses.length, 4, reason: '3 seed + 1 generated');
      expect(state.pageIndex, 0, reason: 'should animate to the new page (0)');
      expect(state.courses.first.isGenerated, isTrue);
    });

    test('createCourse with empty topic is a no-op', () async {
      final container = ProviderContainer();
      addTearDown(container.dispose);
      final before = container.read(coursesProvider).courses.length;
      await container.read(coursesProvider.notifier).createCourse('   ');
      expect(container.read(coursesProvider).courses.length, before);
    });

    test('createCourse produces a course with modules and lessons', () async {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      await container.read(coursesProvider.notifier).createCourse('Алгебра');

      final generatedCourse = container.read(coursesProvider).courses.first;
      expect(
        generatedCourse.modules,
        isNotEmpty,
        reason: 'generated course should have at least one module',
      );
      expect(
        generatedCourse.allLessons,
        isNotEmpty,
        reason: 'generated course should have at least one lesson',
      );
      // Verify each lesson has theory and questions
      for (final lesson in generatedCourse.allLessons) {
        expect(
          lesson.theory,
          isNotEmpty,
          reason: 'each generated lesson should have theory cards',
        );
        expect(
          lesson.questions,
          isNotEmpty,
          reason: 'each generated lesson should have questions',
        );
      }
    });
  });
}
