import 'package:admity/app.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('Splash → welcome → onboarding for a fresh (not-onboarded) user',
      (tester) async {
    await tester.pumpWidget(const ProviderScope(child: AdmityApp()));
    await tester.pump(); // first splash frame

    // The branded launch screen is shown first.
    expect(find.text('Admity'), findsOneWidget);

    // After the splash hold the timer fires and routes onward. Use fixed pumps
    // (not pumpAndSettle) because the welcome step has a looping float.
    await tester.pump(const Duration(seconds: 3)); // fire the splash timer
    await tester.pump(); // process the go_router navigation
    await tester.pump(const Duration(milliseconds: 600)); // welcome entrance

    // Fresh user lands on the animated welcome step.
    expect(find.text('Привет! Я Ералы'), findsOneWidget);
    expect(find.text('Далее'), findsOneWidget);

    // Advancing reaches the first real question.
    await tester.tap(find.text('Далее'));
    await tester.pump(); // start the step transition
    await tester.pump(const Duration(seconds: 1)); // finish switch + entrance

    expect(find.text('Давай познакомимся'), findsOneWidget);
  });
}
