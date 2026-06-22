import 'package:admity/core/theme/app_colors.dart';
import 'package:admity/core/theme/app_tokens.dart';
import 'package:admity/features/courses/presentation/courses_screen.dart';
import 'package:admity/shared/widgets/featured_button.dart';
import 'package:admity/shared/widgets/lesson_node.dart';
import 'package:admity/shared/widgets/topic_diagram_slot.dart';
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

  testWidgets('CoursesScreen builds with no framework/layout errors',
      (tester) async {
    final errors = <FlutterErrorDetails>[];
    final prev = FlutterError.onError;
    FlutterError.onError = errors.add;
    addTearDown(() => FlutterError.onError = prev);

    await tester.pumpWidget(_themed(const CoursesScreen()));
    await tester.pumpAndSettle();

    expect(errors, isEmpty,
        reason: 'no framework/layout errors on CoursesScreen');
  });

  // ── Tabs ───────────────────────────────────────────────────────────────────

  testWidgets('all three course tabs are visible', (tester) async {
    await tester.pumpWidget(_themed(const CoursesScreen()));
    await tester.pumpAndSettle();

    expect(find.text('Математика'), findsWidgets);
    expect(find.text('Логика'), findsOneWidget);
    expect(find.text('Английский'), findsOneWidget);
  });

  testWidgets('first tab is selected by default (blue underline state)',
      (tester) async {
    await tester.pumpWidget(_themed(const CoursesScreen()));
    await tester.pumpAndSettle();

    // The provider starts at selectedTabIndex = 0 (Математика).
    final state = tester
        .element(find.byType(CoursesScreen))
        .findAncestorWidgetOfExactType<ProviderScope>();
    expect(state, isNotNull);

    // Verify the first tab label renders in primary colour via its text style.
    // We find all RichText descendants for 'Математика' and confirm at least
    // one uses the primary colour — which the active tab applies.
    final tabTexts = tester.widgetList<Text>(find.text('Математика'));
    final hasPrimaryStyle = tabTexts.any(
      (t) => t.style?.color == AppColors.primary,
    );
    expect(hasPrimaryStyle, isTrue,
        reason: 'selected tab label should use AppColors.primary');
  });

  testWidgets('tapping Логика tab updates selected tab', (tester) async {
    await tester.pumpWidget(_themed(const CoursesScreen()));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Логика'));
    await tester.pumpAndSettle();

    // After tap, 'Логика' tab text should be in primary colour.
    final logicTexts = tester.widgetList<Text>(find.text('Логика'));
    final hasPrimary = logicTexts.any(
      (t) => t.style?.color == AppColors.primary,
    );
    expect(hasPrimary, isTrue,
        reason: 'tapped tab label should switch to AppColors.primary');
  });

  testWidgets('tapping Английский tab updates selected tab', (tester) async {
    await tester.pumpWidget(_themed(const CoursesScreen()));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Английский'));
    await tester.pumpAndSettle();

    final engTexts = tester.widgetList<Text>(find.text('Английский'));
    final hasPrimary = engTexts.any(
      (t) => t.style?.color == AppColors.primary,
    );
    expect(hasPrimary, isTrue,
        reason: 'Английский tab should become active after tap');
  });

  // ── Lesson node path ───────────────────────────────────────────────────────

  testWidgets('lesson path contains active, done, and locked nodes',
      (tester) async {
    await tester.pumpWidget(_themed(const CoursesScreen()));
    await tester.pumpAndSettle();

    expect(find.byType(LessonNode), findsNWidgets(courseLessons.length));
    expect(find.byIcon(Icons.play_arrow_rounded), findsWidgets);
    expect(find.byIcon(Icons.check_rounded), findsWidgets);
    expect(find.byIcon(Icons.lock_rounded), findsWidgets);
  });

  // ── TopicDiagramSlot (swipe gesture) ──────────────────────────────────────

  testWidgets('swipe right on TopicDiagramSlot advances active lesson',
      (tester) async {
    // Use a ProviderContainer so we can read state after the gesture.
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

    // Capture starting state.
    final before = container.read(coursesProvider).activeLessonIndex;

    // Simulate a rightward fling on the diagram slot using flingFrom so
    // velocity is properly generated (onHorizontalDragEnd checks primaryVelocity).
    final diagramFinder = find.byType(TopicDiagramSlot).first;
    final center = tester.getCenter(diagramFinder);
    await tester.flingFrom(center, const Offset(120, 0), 800);
    await tester.pumpAndSettle();

    final after = container.read(coursesProvider).activeLessonIndex;
    expect(after, greaterThan(before),
        reason: 'rightward fling should advance the active lesson index');
  });

  // ── Bottom box ─────────────────────────────────────────────────────────────

  testWidgets('FeaturedButton "Начать урок" is present', (tester) async {
    await tester.pumpWidget(_themed(const CoursesScreen()));
    await tester.pumpAndSettle();

    expect(find.byType(FeaturedButton), findsOneWidget);
    expect(find.text('Начать урок'), findsOneWidget);
  });

  testWidgets('bottom lesson card contains active lesson title',
      (tester) async {
    await tester.pumpWidget(_themed(const CoursesScreen()));
    await tester.pumpAndSettle();

    // The active lesson at index 1 is 'Сравнение вероятностей'.
    // It appears in the header AND the bottom box, so we use findsWidgets.
    expect(find.text('Сравнение вероятностей'), findsWidgets);
  });

  // ── Navigation ─────────────────────────────────────────────────────────────

  testWidgets('"Начать урок" navigates to /lesson', (tester) async {
    await tester.pumpWidget(_routerWrapped(const CoursesScreen()));
    await tester.pumpAndSettle();

    // The button may be off-screen — scroll down until it is visible.
    await tester.scrollUntilVisible(
      find.text('Начать урок'),
      100,
      scrollable: find.byType(Scrollable).first,
    );
    await tester.pumpAndSettle();

    await tester.tap(find.text('Начать урок'), warnIfMissed: false);
    await tester.pumpAndSettle();

    expect(find.text('LessonScreen'), findsOneWidget);
  });
}
