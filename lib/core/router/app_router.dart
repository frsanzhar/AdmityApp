import 'package:admity/core/router/app_routes.dart';
import 'package:admity/core/router/scaffold_with_nav_bar.dart';
import 'package:admity/features/auth/presentation/auth_screen.dart';
import 'package:admity/features/calendar/presentation/calendar_screen.dart';
import 'package:admity/features/career_test/presentation/career_test_screen.dart';
import 'package:admity/features/career_test/presentation/values_test_screen.dart';
import 'package:admity/features/chancing_kz/presentation/chances_hub_screen.dart';
import 'package:admity/features/chancing_kz/presentation/chancing_kz_screen.dart';
import 'package:admity/features/chancing_world/presentation/chancing_world_screen.dart';
import 'package:admity/features/dashboard/presentation/dashboard_screen.dart';
import 'package:admity/features/design_showcase/presentation/design_showcase_screen.dart';
import 'package:admity/features/eraly_chat/presentation/eraly_chat_screen.dart';
import 'package:admity/features/essay_review/presentation/essay_screen.dart';
import 'package:admity/features/games/guess_uni/presentation/guess_uni_screen.dart';
import 'package:admity/features/games/wordle/presentation/wordle_screen.dart';
import 'package:admity/features/gap_closer/presentation/gap_screen.dart';
import 'package:admity/features/gpa/presentation/gpa_table_screen.dart';
import 'package:admity/features/intensives/presentation/intensive_day_screen.dart';
import 'package:admity/features/intensives/presentation/intensive_screen.dart';
import 'package:admity/features/intensives/presentation/learn_hub_screen.dart';
import 'package:admity/features/onboarding/presentation/onboarding_screen.dart';
import 'package:admity/features/profile/presentation/profile_screen.dart';
import 'package:admity/features/project_ideas/presentation/project_ideas_screen.dart';
import 'package:admity/features/scholarships/presentation/scholarships_screen.dart';
import 'package:admity/features/splash/presentation/splash_screen.dart';
import 'package:admity/features/universities/presentation/college_list_screen.dart';
import 'package:admity/features/universities/presentation/universities_screen.dart';
import 'package:admity/features/universities/presentation/university_detail_screen.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

final _rootKey = GlobalKey<NavigatorState>();

/// The application router: a [StatefulShellRoute] for the five tabs, with
/// detail screens pushed full-screen over the shell.
final appRouterProvider = Provider<GoRouter>((ref) {
  GoRoute fullScreen(
    String path,
    String name,
    Widget Function(GoRouterState state) build,
  ) =>
      GoRoute(
        path: path,
        name: name,
        parentNavigatorKey: _rootKey,
        builder: (context, state) => build(state),
      );

  return GoRouter(
    navigatorKey: _rootKey,
    initialLocation: AppRoutes.splash,
    routes: [
      StatefulShellRoute.indexedStack(
        builder: (context, state, navigationShell) =>
            ScaffoldWithNavBar(navigationShell: navigationShell),
        branches: [
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: AppRoutes.dashboard,
                name: AppRoutes.dashboardName,
                builder: (context, state) => const DashboardScreen(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: AppRoutes.chances,
                name: AppRoutes.chancesName,
                builder: (context, state) => const ChancesHubScreen(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: AppRoutes.learn,
                name: AppRoutes.learnName,
                builder: (context, state) => const LearnHubScreen(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: AppRoutes.eraly,
                name: AppRoutes.eralyName,
                builder: (context, state) => const EralyChatScreen(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: AppRoutes.profile,
                name: AppRoutes.profileName,
                builder: (context, state) => const ProfileScreen(),
              ),
            ],
          ),
        ],
      ),
      fullScreen(AppRoutes.splash, AppRoutes.splashName,
          (_) => const SplashScreen()),
      fullScreen(AppRoutes.onboarding, AppRoutes.onboardingName,
          (_) => const OnboardingScreen()),
      fullScreen(
          AppRoutes.auth, AppRoutes.authName, (_) => const AuthScreen()),
      fullScreen(AppRoutes.careerTest, AppRoutes.careerTestName,
          (_) => const CareerTestScreen()),
      fullScreen(AppRoutes.valuesTest, AppRoutes.valuesTestName,
          (_) => const ValuesTestScreen()),
      fullScreen(AppRoutes.chancingKz, AppRoutes.chancingKzName,
          (_) => const ChancingKzScreen()),
      fullScreen(AppRoutes.chancingWorld, AppRoutes.chancingWorldName,
          (_) => const ChancingWorldScreen()),
      fullScreen(AppRoutes.universities, AppRoutes.universitiesName,
          (_) => const UniversitiesScreen()),
      fullScreen(
        AppRoutes.universityDetail,
        AppRoutes.universityDetailName,
        (state) =>
            UniversityDetailScreen(slug: state.pathParameters['slug'] ?? ''),
      ),
      fullScreen(AppRoutes.scholarships, AppRoutes.scholarshipsName,
          (_) => const ScholarshipsScreen()),
      fullScreen(AppRoutes.collegeList, AppRoutes.collegeListName,
          (_) => const CollegeListScreen()),
      fullScreen(AppRoutes.gap, AppRoutes.gapName, (_) => const GapScreen()),
      fullScreen(AppRoutes.projects, AppRoutes.projectsName,
          (_) => const ProjectIdeasScreen()),
      fullScreen(AppRoutes.essay, AppRoutes.essayName, (_) => const EssayScreen()),
      fullScreen(AppRoutes.design, AppRoutes.designName,
          (_) => const DesignShowcaseScreen()),
      fullScreen(AppRoutes.calendar, AppRoutes.calendarName,
          (_) => const CalendarScreen()),
      fullScreen(AppRoutes.gpa, AppRoutes.gpaName,
          (_) => const GpaTableScreen()),
      fullScreen(AppRoutes.wordleGame, AppRoutes.wordleGameName,
          (_) => const WordleScreen()),
      fullScreen(AppRoutes.guessUni, AppRoutes.guessUniName,
          (_) => const GuessUniScreen()),
      fullScreen(
        AppRoutes.intensive,
        AppRoutes.intensiveName,
        (state) => IntensiveScreen(slug: state.pathParameters['slug'] ?? ''),
      ),
      fullScreen(
        AppRoutes.intensiveDay,
        AppRoutes.intensiveDayName,
        (state) => IntensiveDayScreen(
          slug: state.pathParameters['slug'] ?? '',
          day: int.tryParse(state.pathParameters['day'] ?? '1') ?? 1,
        ),
      ),
    ],
  );
});
