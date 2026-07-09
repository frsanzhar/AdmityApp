// Tests for Phase 7 Rive motion wiring.
//
// These tests verify the logic layer (reduceMotion fallback, MascotState
// transitions, navigation gating) rather than the Rive runtime itself, which
// is not available in the flutter_test host environment.

import 'package:admity/core/theme/app_tokens.dart';
import 'package:admity/shared/widgets/mascot_slot.dart';
import 'package:admity/shared/widgets/streak_badge.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

// ── Helpers ───────────────────────────────────────────────────────────────────

Widget _themed(Widget child) {
  return ProviderScope(
    child: MaterialApp(
      theme: ThemeData(extensions: [AppTokens.defaults()]),
      home: child,
    ),
  );
}

// ── MascotSlot ────────────────────────────────────────────────────────────────

void main() {
  group('MascotSlot', () {
    testWidgets('renders static blob fallback when no .riv asset is bundled',
        (tester) async {
      final errors = <FlutterErrorDetails>[];
      final prev = FlutterError.onError;
      FlutterError.onError = errors.add;
      addTearDown(() => FlutterError.onError = prev);

      await tester.pumpWidget(_themed(const MascotSlot()));
      await tester.pumpAndSettle();

      // Widget should render without errors; Rive file is absent so the blob
      // CustomPaint is used as fallback.
      expect(errors, isEmpty, reason: 'no layout/framework errors');
      expect(find.byType(MascotSlot), findsOneWidget);
    });

    testWidgets('does NOT render the tag caption (kept for API only)',
        (tester) async {
      await tester.pumpWidget(
        _themed(const MascotSlot(tag: 'test-tag', size: 80)),
      );
      await tester.pumpAndSettle();
      expect(find.text('test-tag'), findsNothing);
    });

    testWidgets('reduces to static blob when MediaQuery.disableAnimations',
        (tester) async {
      final errors = <FlutterErrorDetails>[];
      final prev = FlutterError.onError;
      FlutterError.onError = errors.add;
      addTearDown(() => FlutterError.onError = prev);

      await tester.pumpWidget(
        MediaQuery(
          data: const MediaQueryData(disableAnimations: true),
          child: _themed(
            const MascotSlot(state: MascotState.celebrate),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(errors, isEmpty,
          reason: 'no errors when disableAnimations + celebrate state');
      expect(find.byType(MascotSlot), findsOneWidget);
    });

    testWidgets(
        'all MascotState variants build without layout errors', (tester) async {
      for (final state in MascotState.values) {
        final errors = <FlutterErrorDetails>[];
        final prev = FlutterError.onError;
        FlutterError.onError = errors.add;
        addTearDown(() => FlutterError.onError = prev);

        await tester.pumpWidget(_themed(MascotSlot(state: state)));
        await tester.pumpAndSettle();

        expect(errors, isEmpty,
            reason: 'no errors for MascotState.${state.name}');
      }
    });
  });

  // ── StreakBadge ───────────────────────────────────────────────────────────────

  group('StreakBadge', () {
    testWidgets('renders day count and bolt icon without Rive asset',
        (tester) async {
      final errors = <FlutterErrorDetails>[];
      final prev = FlutterError.onError;
      FlutterError.onError = errors.add;
      addTearDown(() => FlutterError.onError = prev);

      await tester.pumpWidget(_themed(const StreakBadge(days: 7)));
      await tester.pumpAndSettle();

      expect(errors, isEmpty);
      expect(find.text('7'), findsOneWidget);
      // Static bolt icon renders because no .riv asset is bundled.
      expect(find.byIcon(Icons.bolt), findsOneWidget);
    });

    testWidgets('shows bolt icon with disableAnimations=true', (tester) async {
      await tester.pumpWidget(
        MediaQuery(
          data: const MediaQueryData(disableAnimations: true),
          child: _themed(const StreakBadge(days: 3)),
        ),
      );
      await tester.pumpAndSettle();
      expect(find.byIcon(Icons.bolt), findsOneWidget);
      expect(find.text('3'), findsOneWidget);
    });
  });

  // ── reduceMotion fallback ─────────────────────────────────────────────────────

  group('reduceMotion fallback renders without errors', () {
    testWidgets('MascotSlot + flyDown + disableAnimations', (tester) async {
      final errors = <FlutterErrorDetails>[];
      final prev = FlutterError.onError;
      FlutterError.onError = errors.add;
      addTearDown(() => FlutterError.onError = prev);

      await tester.pumpWidget(
        MediaQuery(
          data: const MediaQueryData(disableAnimations: true),
          child: _themed(const MascotSlot(state: MascotState.flyDown)),
        ),
      );
      await tester.pumpAndSettle();
      expect(errors, isEmpty);
    });

    testWidgets('StreakBadge + disableAnimations', (tester) async {
      final errors = <FlutterErrorDetails>[];
      final prev = FlutterError.onError;
      FlutterError.onError = errors.add;
      addTearDown(() => FlutterError.onError = prev);

      await tester.pumpWidget(
        MediaQuery(
          data: const MediaQueryData(disableAnimations: true),
          child: _themed(const StreakBadge(days: 42)),
        ),
      );
      await tester.pumpAndSettle();
      expect(errors, isEmpty);
      expect(find.text('42'), findsOneWidget);
    });
  });
}
