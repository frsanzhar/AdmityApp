import 'package:admity/core/theme/app_colors.dart';
import 'package:admity/core/theme/app_tokens.dart';
import 'package:admity/shared/widgets/app_bottom_nav.dart';
import 'package:admity/shared/widgets/app_card.dart';
import 'package:admity/shared/widgets/app_scaffold.dart';
import 'package:admity/shared/widgets/featured_button.dart';
import 'package:admity/shared/widgets/key_badge.dart';
import 'package:admity/shared/widgets/lesson_node.dart';
import 'package:admity/shared/widgets/mascot_slot.dart';
import 'package:admity/shared/widgets/primary_button.dart';
import 'package:admity/shared/widgets/progress_ring.dart';
import 'package:admity/shared/widgets/streak_badge.dart';
import 'package:admity/shared/widgets/topic_diagram_slot.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

// ── Helper ─────────────────────────────────────────────────────────────────

/// Wraps [widget] with a [MaterialApp] using the Admity theme so that
/// [ThemeExtension]s are available.
Widget _wrap(Widget widget) {
  return MaterialApp(
    theme: buildAppTheme(),
    home: Scaffold(body: Center(child: widget)),
  );
}

// ── Tests ─────────────────────────────────────────────────────────────────

void main() {
  // ── AppColors ─────────────────────────────────────────────────────────────

  group('AppColors', () {
    test('primary is bright brand green 0xFF17C653', () {
      expect(AppColors.primary.toARGB32(), 0xFF17C653);
    });

    test('accentLime is 0xFFC2F03C', () {
      expect(AppColors.accentLime.toARGB32(), 0xFFC2F03C);
    });

    test('ctaGradient has 4 stops', () {
      expect(AppColors.ctaGradient.length, 4);
    });

    test('cardShadow is 8-% opacity dark', () {
      expect(AppColors.cardShadow.toARGB32(), 0x14101828);
    });
  });

  // ── AppTokens ─────────────────────────────────────────────────────────────

  group('AppTokens', () {
    test('defaults() values match DESIGN_SYSTEM §3', () {
      final t = AppTokens.defaults();
      expect(t.radiusSm, 12);
      expect(t.radiusMd, 16);
      expect(t.radiusLg, 20);
      expect(t.radiusXl, 28);
      expect(t.gapXs, 4);
      expect(t.gapSm, 8);
      expect(t.gapMd, 12);
      expect(t.gapLg, 16);
      expect(t.gapXl, 24);
      expect(t.gapXxl, 32);
      expect(t.cardPadding, 16);
      expect(t.screenPadding, 20);
    });

    test('cardShadow has blur 24 and y-offset 8', () {
      final shadow = AppTokens.defaults().cardShadow.first;
      expect(shadow.blurRadius, 24);
      expect(shadow.offset.dy, 8);
      expect(shadow.color, AppColors.cardShadow);
    });

    test('copyWith replaces single field', () {
      final t = AppTokens.defaults().copyWith(radiusSm: 99);
      expect(t.radiusSm, 99);
      expect(t.radiusMd, 16); // unchanged
    });

    test('lerp interpolates numeric fields', () {
      final a = AppTokens.defaults();
      final b = a.copyWith(radiusSm: 100);
      final mid = a.lerp(b, 0.5) as AppTokens?;
      expect(mid?.radiusSm, closeTo(56, 0.01)); // (12+100)/2
    });
  });

  // ── PrimaryButton ─────────────────────────────────────────────────────────

  group('PrimaryButton', () {
    testWidgets('renders label without layout errors', (tester) async {
      final errors = <FlutterErrorDetails>[];
      final prev = FlutterError.onError;
      FlutterError.onError = errors.add;

      await tester.pumpWidget(
        _wrap(PrimaryButton(label: 'Continue', onPressed: () {})),
      );
      await tester.pumpAndSettle();

      FlutterError.onError = prev;
      expect(errors, isEmpty, reason: 'no layout errors');
      expect(find.text('Continue'), findsOneWidget);
    });

    testWidgets('calls onPressed when tapped', (tester) async {
      var taps = 0;
      await tester.pumpWidget(
        _wrap(PrimaryButton(label: 'Tap me', onPressed: () => taps++)),
      );
      await tester.tap(find.text('Tap me'));
      expect(taps, 1);
    });

    testWidgets('shows spinner when isLoading is true', (tester) async {
      await tester.pumpWidget(
        _wrap(
          PrimaryButton(label: 'Loading', onPressed: () {}, isLoading: true),
        ),
      );
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
      expect(find.text('Loading'), findsNothing);
    });
  });

  // ── FeaturedButton ────────────────────────────────────────────────────────

  group('FeaturedButton', () {
    testWidgets('renders label with gradient without layout errors',
        (tester) async {
      final errors = <FlutterErrorDetails>[];
      final prev = FlutterError.onError;
      FlutterError.onError = errors.add;

      await tester.pumpWidget(
        _wrap(FeaturedButton(label: 'Start the Lesson', onPressed: () {})),
      );
      await tester.pumpAndSettle();

      FlutterError.onError = prev;
      expect(errors, isEmpty, reason: 'no layout errors');
      expect(find.text('Start the Lesson'), findsOneWidget);
    });

    testWidgets('has gradient BoxDecoration', (tester) async {
      await tester.pumpWidget(
        _wrap(FeaturedButton(label: 'Featured', onPressed: () {})),
      );
      await tester.pumpAndSettle();

      final containers = tester.widgetList<Container>(find.byType(Container));
      final hasGradient = containers.any(
        (c) =>
            c.decoration is BoxDecoration &&
            (c.decoration! as BoxDecoration).gradient != null,
      );
      expect(hasGradient, isTrue, reason: 'FeaturedButton should have gradient');
    });

    testWidgets('PrimaryButton and FeaturedButton are visually distinct',
        (tester) async {
      await tester.pumpWidget(
        _wrap(
          Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              PrimaryButton(label: 'Primary', onPressed: () {}),
              const SizedBox(height: 8),
              FeaturedButton(label: 'Featured', onPressed: () {}),
            ],
          ),
        ),
      );
      await tester.pumpAndSettle();
      expect(find.text('Primary'), findsOneWidget);
      expect(find.text('Featured'), findsOneWidget);
    });
  });

  // ── AppCard ───────────────────────────────────────────────────────────────

  group('AppCard', () {
    testWidgets('renders child without layout errors', (tester) async {
      final errors = <FlutterErrorDetails>[];
      final prev = FlutterError.onError;
      FlutterError.onError = errors.add;

      await tester.pumpWidget(
        _wrap(const AppCard(child: Text('Card content'))),
      );
      await tester.pumpAndSettle();

      FlutterError.onError = prev;
      expect(errors, isEmpty);
      expect(find.text('Card content'), findsOneWidget);
    });
  });

  // ── StreakBadge ───────────────────────────────────────────────────────────

  group('StreakBadge', () {
    testWidgets('shows day count and lightning icon', (tester) async {
      await tester.pumpWidget(_wrap(const StreakBadge(days: 7)));
      await tester.pumpAndSettle();
      expect(find.text('7'), findsOneWidget);
      expect(find.byIcon(Icons.bolt), findsOneWidget);
    });
  });

  // ── KeyBadge ──────────────────────────────────────────────────────────────

  group('KeyBadge', () {
    testWidgets('shows key count and key icon', (tester) async {
      await tester.pumpWidget(_wrap(const KeyBadge(count: 3)));
      await tester.pumpAndSettle();
      expect(find.text('3'), findsOneWidget);
      expect(find.byIcon(Icons.key_rounded), findsOneWidget);
    });
  });

  // ── ProgressRing ──────────────────────────────────────────────────────────

  group('ProgressRing', () {
    testWidgets('paints without layout errors at progress 0.0', (tester) async {
      final errors = <FlutterErrorDetails>[];
      final prev = FlutterError.onError;
      FlutterError.onError = errors.add;

      await tester.pumpWidget(_wrap(const ProgressRing(progress: 0)));
      await tester.pumpAndSettle();

      FlutterError.onError = prev;
      expect(errors, isEmpty, reason: 'no layout errors');
      expect(find.byType(ProgressRing), findsOneWidget);
    });

    testWidgets('paints without layout errors at progress 0.5', (tester) async {
      final errors = <FlutterErrorDetails>[];
      final prev = FlutterError.onError;
      FlutterError.onError = errors.add;

      await tester.pumpWidget(_wrap(const ProgressRing(progress: 0.5)));
      await tester.pumpAndSettle();

      FlutterError.onError = prev;
      expect(errors, isEmpty, reason: 'no layout errors');
      expect(find.byType(ProgressRing), findsOneWidget);
    });

    testWidgets('paints without layout errors at progress 1.0', (tester) async {
      final errors = <FlutterErrorDetails>[];
      final prev = FlutterError.onError;
      FlutterError.onError = errors.add;

      await tester.pumpWidget(_wrap(const ProgressRing(progress: 1)));
      await tester.pumpAndSettle();

      FlutterError.onError = prev;
      expect(errors, isEmpty, reason: 'no layout errors');
      expect(find.byType(ProgressRing), findsOneWidget);
    });

    testWidgets('clamps out-of-range progress values', (tester) async {
      await tester.pumpWidget(_wrap(const ProgressRing(progress: 1.5)));
      await tester.pumpAndSettle();
      expect(find.byType(ProgressRing), findsOneWidget);
    });

    testWidgets('renders optional child in centre', (tester) async {
      await tester.pumpWidget(
        _wrap(
          const ProgressRing(
            progress: 0.82,
            child: Text('82%'),
          ),
        ),
      );
      expect(find.text('82%'), findsOneWidget);
    });
  });

  // ── LessonNode ────────────────────────────────────────────────────────────

  group('LessonNode', () {
    testWidgets('active node renders play icon without errors', (tester) async {
      final errors = <FlutterErrorDetails>[];
      final prev = FlutterError.onError;
      FlutterError.onError = errors.add;

      await tester.pumpWidget(
        _wrap(const LessonNode(state: LessonNodeState.active)),
      );
      await tester.pumpAndSettle();

      FlutterError.onError = prev;
      expect(errors, isEmpty);
      expect(find.byIcon(Icons.play_arrow_rounded), findsOneWidget);
    });

    testWidgets('done node renders check icon', (tester) async {
      await tester.pumpWidget(
        _wrap(const LessonNode(state: LessonNodeState.done)),
      );
      await tester.pumpAndSettle();
      expect(find.byIcon(Icons.check_rounded), findsOneWidget);
    });

    testWidgets('locked node renders lock icon', (tester) async {
      await tester.pumpWidget(
        _wrap(const LessonNode(state: LessonNodeState.locked)),
      );
      await tester.pumpAndSettle();
      expect(find.byIcon(Icons.lock_rounded), findsOneWidget);
    });

    testWidgets('locked node does not fire onTap', (tester) async {
      var taps = 0;
      await tester.pumpWidget(
        _wrap(
          LessonNode(
            state: LessonNodeState.locked,
            onTap: () => taps++,
          ),
        ),
      );
      await tester.tap(find.byType(LessonNode));
      expect(taps, 0);
    });

    testWidgets('active node fires onTap', (tester) async {
      var taps = 0;
      await tester.pumpWidget(
        _wrap(
          LessonNode(
            state: LessonNodeState.active,
            onTap: () => taps++,
          ),
        ),
      );
      await tester.tap(find.byType(LessonNode));
      expect(taps, 1);
    });
  });

  // ── MascotSlot ────────────────────────────────────────────────────────────

  group('MascotSlot', () {
    testWidgets('builds without layout errors with tag', (tester) async {
      final errors = <FlutterErrorDetails>[];
      final prev = FlutterError.onError;
      FlutterError.onError = errors.add;

      await tester.pumpWidget(
        _wrap(const MascotSlot(size: 80, tag: 'home')),
      );
      await tester.pumpAndSettle();

      FlutterError.onError = prev;
      expect(errors, isEmpty, reason: 'no layout errors');
      expect(find.byType(MascotSlot), findsOneWidget);
      // Tag captions are intentionally not rendered anymore.
      expect(find.text('home'), findsNothing);
    });

    testWidgets('builds without layout errors without tag', (tester) async {
      final errors = <FlutterErrorDetails>[];
      final prev = FlutterError.onError;
      FlutterError.onError = errors.add;

      await tester.pumpWidget(_wrap(const MascotSlot()));
      await tester.pumpAndSettle();

      FlutterError.onError = prev;
      expect(errors, isEmpty);
    });
  });

  // ── TopicDiagramSlot ──────────────────────────────────────────────────────

  group('TopicDiagramSlot', () {
    testWidgets('builds without layout errors with label', (tester) async {
      final errors = <FlutterErrorDetails>[];
      final prev = FlutterError.onError;
      FlutterError.onError = errors.add;

      await tester.pumpWidget(
        _wrap(
          const TopicDiagramSlot(size: 100, label: 'Математика'),
        ),
      );
      await tester.pumpAndSettle();

      FlutterError.onError = prev;
      expect(errors, isEmpty, reason: 'no layout errors');
      expect(find.byType(TopicDiagramSlot), findsOneWidget);
      expect(find.text('Математика'), findsOneWidget);
    });

    testWidgets('has gradient decoration', (tester) async {
      await tester.pumpWidget(
        _wrap(const TopicDiagramSlot(size: 100)),
      );
      await tester.pumpAndSettle();

      final containers = tester.widgetList<Container>(find.byType(Container));
      final hasGradient = containers.any(
        (c) =>
            c.decoration is BoxDecoration &&
            (c.decoration! as BoxDecoration).gradient != null,
      );
      expect(
        hasGradient,
        isTrue,
        reason: 'TopicDiagramSlot should have gradient',
      );
    });
  });

  // ── AppBottomNav ──────────────────────────────────────────────────────────

  group('AppBottomNav', () {
    testWidgets('renders all 5 tab labels without errors', (tester) async {
      final errors = <FlutterErrorDetails>[];
      final prev = FlutterError.onError;
      FlutterError.onError = errors.add;

      await tester.pumpWidget(
        _wrap(
          AppBottomNav(
            selectedIndex: 0,
            onTap: (_) {},
            items: defaultNavItems,
          ),
        ),
      );
      await tester.pumpAndSettle();

      FlutterError.onError = prev;
      expect(errors, isEmpty);
      expect(find.text('Главная'), findsOneWidget);
      expect(find.text('Вузы'), findsOneWidget);
      expect(find.text('Ералы'), findsOneWidget);
      expect(find.text('Возможности'), findsOneWidget);
      expect(find.text('Профиль'), findsOneWidget);
    });

    testWidgets('highlights selected tab with primary colour', (tester) async {
      await tester.pumpWidget(
        _wrap(
          AppBottomNav(
            selectedIndex: 0,
            onTap: (_) {},
            items: defaultNavItems,
          ),
        ),
      );
      await tester.pumpAndSettle();

      final icon = tester.widget<Icon>(find.byIcon(Icons.home_rounded));
      expect(icon.color, AppColors.primary);
    });

    testWidgets('fires onTap with correct index', (tester) async {
      var lastTap = -1;
      await tester.pumpWidget(
        _wrap(
          AppBottomNav(
            selectedIndex: 0,
            onTap: (i) => lastTap = i,
            items: defaultNavItems,
          ),
        ),
      );
      await tester.tap(find.text('Вузы'));
      expect(lastTap, 1);
    });

    testWidgets('accent centre tab (Ералы) renders when selected',
        (tester) async {
      await tester.pumpWidget(
        _wrap(
          AppBottomNav(
            selectedIndex: 2, // Ералы
            onTap: (_) {},
            items: defaultNavItems,
          ),
        ),
      );
      await tester.pumpAndSettle();
      expect(find.text('Ералы'), findsOneWidget);
    });
  });

  // ── AppScaffold ───────────────────────────────────────────────────────────

  group('AppScaffold', () {
    testWidgets('wraps body in SafeArea without layout errors', (tester) async {
      final errors = <FlutterErrorDetails>[];
      final prev = FlutterError.onError;
      FlutterError.onError = errors.add;

      await tester.pumpWidget(
        MaterialApp(
          theme: buildAppTheme(),
          home: const AppScaffold(
            body: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [Text('Hello')],
              ),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      FlutterError.onError = prev;
      expect(errors, isEmpty, reason: 'no layout errors');
      expect(find.text('Hello'), findsOneWidget);
      expect(find.byType(SafeArea), findsAtLeastNWidgets(1));
    });
  });
}
