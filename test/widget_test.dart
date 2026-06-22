import 'package:admity/app.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('app boots into the dashboard tab without layout errors',
      (tester) async {
    // Fail loudly on any framework error (incl. swallowed layout errors) —
    // see CLAUDE.md: those otherwise render a silent blank screen.
    final errors = <FlutterErrorDetails>[];
    final prev = FlutterError.onError;
    FlutterError.onError = errors.add;
    addTearDown(() => FlutterError.onError = prev);

    await tester.pumpWidget(const ProviderScope(child: AdmityApp()));
    await tester.pumpAndSettle();

    expect(errors, isEmpty, reason: 'no framework/layout errors on boot');
    // Dashboard tab title and the bottom nav are present.
    expect(find.text('Главная'), findsWidgets);
    expect(find.byType(NavigationBar), findsOneWidget);
  });
}
