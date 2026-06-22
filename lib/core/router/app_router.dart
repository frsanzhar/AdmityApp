import 'package:admity/core/theme/app_tokens.dart';
import 'package:admity/features/chancing/presentation/chancing_screen.dart';
import 'package:admity/features/dashboard/presentation/dashboard_screen.dart';
import 'package:admity/features/mentor/presentation/mentor_screen.dart';
import 'package:admity/features/profile/presentation/profile_screen.dart';
import 'package:admity/features/study/presentation/study_screen.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

/// The five bottom-nav destinations, in order.
const _tabs = <_Tab>[
  _Tab('/', 'Главная', Icons.home_outlined, Icons.home),
  _Tab('/chances', 'Шансы', Icons.insights_outlined, Icons.insights),
  _Tab('/study', 'Учёба', Icons.school_outlined, Icons.school),
  _Tab('/mentor', 'Ералы', Icons.forum_outlined, Icons.forum),
  _Tab('/profile', 'Профиль', Icons.person_outline, Icons.person),
];

GoRouter createRouter() {
  return GoRouter(
    initialLocation: '/',
    routes: [
      StatefulShellRoute.indexedStack(
        builder: (context, state, shell) => _ShellScaffold(shell: shell),
        branches: [
          StatefulShellBranch(
            routes: [GoRoute(path: '/', builder: (context, state) => const DashboardScreen())],
          ),
          StatefulShellBranch(
            routes: [GoRoute(path: '/chances', builder: (context, state) => const ChancingScreen())],
          ),
          StatefulShellBranch(
            routes: [GoRoute(path: '/study', builder: (context, state) => const StudyScreen())],
          ),
          StatefulShellBranch(
            routes: [GoRoute(path: '/mentor', builder: (context, state) => const MentorScreen())],
          ),
          StatefulShellBranch(
            routes: [GoRoute(path: '/profile', builder: (context, state) => const ProfileScreen())],
          ),
        ],
      ),
    ],
  );
}

class _Tab {
  const _Tab(this.path, this.label, this.icon, this.activeIcon);
  final String path;
  final String label;
  final IconData icon;
  final IconData activeIcon;
}

class _ShellScaffold extends StatelessWidget {
  const _ShellScaffold({required this.shell});

  final StatefulNavigationShell shell;

  @override
  Widget build(BuildContext context) {
    final tokens = Theme.of(context).extension<AppTokens>()!;
    return Scaffold(
      body: shell,
      bottomNavigationBar: NavigationBar(
        selectedIndex: shell.currentIndex,
        indicatorColor: tokens.brand.withValues(alpha: 0.12),
        onDestinationSelected: (i) => shell.goBranch(
          i,
          initialLocation: i == shell.currentIndex,
        ),
        destinations: [
          for (final t in _tabs)
            NavigationDestination(
              icon: Icon(t.icon),
              selectedIcon: Icon(t.activeIcon),
              label: t.label,
            ),
        ],
      ),
    );
  }
}
