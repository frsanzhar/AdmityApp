import 'package:admity/core/theme/app_theme.dart';
import 'package:admity/features/dashboard/presentation/dashboard_screen.dart';
import 'package:admity/features/quotes/presentation/quote_of_day_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  // The home dashboard is a layout-heavy bento (IntrinsicHeight rows, a
  // horizontal rail, a stat strip). A render error here is swallowed by the
  // app's FlutterError.onError override at runtime (blank screen), but surfaces
  // as a test failure here — so this guards the redesign against overflow/layout
  // regressions that wouldn't show up in the splash→onboarding boot test.
  testWidgets('Home dashboard renders without layout errors', (tester) async {
    await tester.pumpWidget(
      ProviderScope(
        child: MaterialApp(
          theme: AppTheme.light,
          home: const DashboardScreen(),
        ),
      ),
    );
    // initState post-frame + entrance animation; fixed pumps (not pumpAndSettle)
    // to stay robust if a child animates.
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 700));

    // Key sections of the new layout are present and built.
    expect(find.byType(QuoteOfDayCard), findsOneWidget);
    expect(find.text('Продолжай путь'), findsOneWidget);
    expect(find.text('Мини-игры и инструменты'), findsOneWidget);
    expect(find.text('Совет дня'), findsOneWidget);

    // A fresh (not-onboarded) user gets the onboarding hero as the focal point.
    expect(find.text('Заполни профиль за пару минут'), findsOneWidget);
    expect(find.text('Начать'), findsOneWidget);
  });
}
