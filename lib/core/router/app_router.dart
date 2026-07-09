import 'package:admity/features/auth/presentation/auth_screen.dart';
import 'package:admity/features/career/presentation/daily_career_test_screen.dart';
import 'package:admity/features/home/presentation/home_screen.dart';
import 'package:admity/features/lesson/presentation/lesson_screen.dart';
import 'package:admity/features/mentor/presentation/mentor_screen.dart';
import 'package:admity/features/onboarding/presentation/onboarding_screen.dart';
import 'package:admity/features/opportunities/presentation/event_detail_screen.dart';
import 'package:admity/features/opportunities/presentation/idea_detail_screen.dart';
import 'package:admity/features/opportunities/presentation/opportunities_screen.dart';
import 'package:admity/features/opportunities/presentation/scholarship_apply_screen.dart';
import 'package:admity/features/opportunities/presentation/scholarship_detail_screen.dart';
import 'package:admity/features/opportunities/presentation/university_detail_screen.dart';
import 'package:admity/features/profile/presentation/profile_edit_screen.dart';
import 'package:admity/features/profile/presentation/profile_screen.dart';
import 'package:admity/features/psytests/presentation/psytests_routes.dart';
import 'package:admity/features/splash/presentation/splash_screen.dart';
import 'package:admity/features/universities/presentation/abroad_universities_screen.dart';
import 'package:admity/features/universities/presentation/universities_hub_screen.dart';
import 'package:admity/features/universities/presentation/universities_screen.dart';
import 'package:admity/features/universities/presentation/university_catalog_detail_screen.dart';
import 'package:admity/shared/widgets/app_bottom_nav.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

/// Creates the application router.
GoRouter createRouter() {
  return GoRouter(
    initialLocation: '/',
    routes: [
      GoRoute(path: '/', builder: (context, state) => const SplashScreen()),
      // Authentication screen — shown to unauthenticated users.
      GoRoute(path: '/auth', builder: (context, state) => const AuthScreen()),
      // Animated onboarding — full-screen, shown when profile is incomplete.
      GoRoute(path: '/onboarding', builder: (context, state) => const OnboardingScreen()),
      // Daily career-orientation test — full-screen, a new test each day.
      GoRoute(path: '/career-test', builder: (context, state) => const DailyCareerTestScreen()),
      // Psych-tests roadmap (Duolingo-style path of 12 tests).
      ...psytestsRoutes,
      // KZ universities catalog — list view.
      GoRoute(path: '/uni-kz', builder: (context, state) => const UniversitiesScreen()),
      // KZ university detail — programs (ГОП) + honest grant figures.
      GoRoute(
        path: '/uni-kz/:id',
        builder: (context, state) => UniversityCatalogDetailScreen(
          universityId: state.pathParameters['id'] ?? '',
        ),
      ),
      // Abroad universities — list view.
      GoRoute(path: '/uni-abroad', builder: (context, state) => const AbroadUniversitiesScreen()),
      // Abroad university detail.
      GoRoute(
        path: '/uni-abroad/:id',
        builder: (context, state) => AbroadUniversityDetailScreen(
          universityId: state.pathParameters['id'] ?? '',
        ),
      ),
      // Full-screen lesson route — outside the tab shell so it covers the bottom nav.
      GoRoute(path: '/lesson', builder: (context, state) => const LessonScreen()),
      // Full-screen scholarship detail + apply routes — outside the tab shell.
      GoRoute(
        path: '/opportunities/scholarship/:id',
        builder: (context, state) => ScholarshipDetailScreen(
          scholarshipId: state.pathParameters['id'] ?? '',
        ),
      ),
      GoRoute(
        path: '/opportunities/scholarship/:id/apply',
        builder: (context, state) => ScholarshipApplyScreen(
          scholarshipId: state.pathParameters['id'] ?? '',
        ),
      ),
      GoRoute(
        path: '/opportunities/university/:id',
        builder: (context, state) => UniversityDetailScreen(
          universityId: state.pathParameters['id'] ?? '',
        ),
      ),
      GoRoute(
        path: '/opportunities/event/:id',
        builder: (context, state) => EventDetailScreen(
          eventId: state.pathParameters['id'] ?? '',
        ),
      ),
      GoRoute(
        path: '/opportunities/idea/:id',
        builder: (context, state) => IdeaDetailScreen(
          ideaId: state.pathParameters['id'] ?? '',
        ),
      ),
      // Full-screen profile data editor — opened from the Profile pencil.
      GoRoute(
        path: '/profile/edit',
        builder: (context, state) => const ProfileEditScreen(),
      ),
      StatefulShellRoute.indexedStack(
        builder: (context, state, shell) => _ShellScaffold(shell: shell),
        branches: [
          StatefulShellBranch(
            routes: [GoRoute(path: '/home', builder: (context, state) => const HomeScreen())],
          ),
          // Tab index 1: Universities hub (KZ catalog + Abroad picker).
          StatefulShellBranch(
            routes: [GoRoute(path: '/universities', builder: (context, state) => const UniversitiesHubScreen())],
          ),
          StatefulShellBranch(
            routes: [GoRoute(path: '/mentor', builder: (context, state) => const MentorScreen())],
          ),
          StatefulShellBranch(
            routes: [GoRoute(path: '/opportunities', builder: (context, state) => const OpportunitiesScreen())],
          ),
          StatefulShellBranch(
            routes: [GoRoute(path: '/profile', builder: (context, state) => const ProfileScreen())],
          ),
        ],
      ),
    ],
  );
}

class _ShellScaffold extends StatelessWidget {
  const _ShellScaffold({required this.shell});

  final StatefulNavigationShell shell;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: shell,
      bottomNavigationBar: AppBottomNav(
        selectedIndex: shell.currentIndex,
        onTap: (i) => shell.goBranch(i, initialLocation: i == shell.currentIndex),
        items: defaultNavItems,
      ),
    );
  }
}
