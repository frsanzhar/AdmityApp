import 'dart:async';
import 'dart:ui';

import 'package:flutter_test/flutter_test.dart';

/// Global test harness config.
///
/// Forces `MediaQuery.disableAnimations = true` for EVERY widget test so that
/// infinite / repeating animations (e.g. the active LessonNode pulse, the
/// Ералы typing indicator) do not make `pumpAndSettle()` hang forever. Widgets
/// honour `disableAnimations` and render their static frame under test.
Future<void> testExecutable(FutureOr<void> Function() testMain) async {
  final binding = TestWidgetsFlutterBinding.ensureInitialized();
  binding.platformDispatcher.accessibilityFeaturesTestValue =
      const _NoAnimationAccessibilityFeatures();
  await testMain();
}

class _NoAnimationAccessibilityFeatures implements AccessibilityFeatures {
  const _NoAnimationAccessibilityFeatures();

  @override
  bool get disableAnimations => true;

  @override
  bool get accessibleNavigation => false;

  @override
  bool get boldText => false;

  @override
  bool get highContrast => false;

  @override
  bool get invertColors => false;

  @override
  bool get onOffSwitchLabels => false;

  @override
  bool get reduceMotion => false;

  @override
  bool get supportsAnnounce => false;
}
