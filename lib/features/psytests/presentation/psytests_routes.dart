/// GoRoute fragment for the psych-tests roadmap feature.
///
/// Integrate by merging these routes into the top-level [GoRouter]:
/// ```dart
/// GoRouter(
///   routes: [
///     ...psytestsRoutes,
///     // other routes
///   ],
/// )
/// ```
library;

import 'package:admity/features/psytests/presentation/psytest_taking_screen.dart';
import 'package:admity/features/psytests/presentation/psytests_roadmap_screen.dart';
import 'package:go_router/go_router.dart';

/// Routes for the psychology tests roadmap.
///
/// - `/psytests`          → [PsytestsRoadmapScreen]
/// - `/psytests/:testId`  → [PsytestTakingScreen]
final List<GoRoute> psytestsRoutes = [
  GoRoute(
    path: '/psytests',
    builder: (context, state) => const PsytestsRoadmapScreen(),
    routes: [
      GoRoute(
        path: ':testId',
        builder: (context, state) => PsytestTakingScreen(
          testId: state.pathParameters['testId']!,
        ),
      ),
    ],
  ),
];
