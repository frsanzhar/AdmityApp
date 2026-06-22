import 'package:admity/features/courses/presentation/courses_screen.dart';
import 'package:admity/features/home/presentation/home_screen.dart';
import 'package:admity/features/mentor/presentation/mentor_screen.dart';
import 'package:admity/features/opportunities/presentation/opportunities_screen.dart';
import 'package:admity/features/profile/presentation/profile_screen.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

/// The five bottom-nav destinations (DESIGN_SYSTEM.md §5), in order.
/// Index 2 (Ералы) is the accent/center tab.
const _tabs = <({String path, String label, IconData icon, IconData active})>[
  (path: '/home', label: 'Главная', icon: Icons.home_outlined, active: Icons.home),
  (path: '/courses', label: 'Курсы', icon: Icons.school_outlined, active: Icons.school),
  (path: '/mentor', label: 'Ералы', icon: Icons.forum_outlined, active: Icons.forum),
  (path: '/opportunities', label: 'Возможности', icon: Icons.explore_outlined, active: Icons.explore),
  (path: '/profile', label: 'Профиль', icon: Icons.person_outline, active: Icons.person),
];

GoRouter createRouter() {
  return GoRouter(
    initialLocation: '/home',
    routes: [
      StatefulShellRoute.indexedStack(
        builder: (context, state, shell) => _ShellScaffold(shell: shell),
        branches: [
          StatefulShellBranch(
            routes: [GoRoute(path: '/home', builder: (context, state) => const HomeScreen())],
          ),
          StatefulShellBranch(
            routes: [GoRoute(path: '/courses', builder: (context, state) => const CoursesScreen())],
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

/// Temporary shell using a stock NavigationBar.
///
/// Phase 1 replaces this with the design-system `AppBottomNav` (§4). Kept
/// dependency-free (no AppTokens) so Phase 0's theme rebuild can't break it.
class _ShellScaffold extends StatelessWidget {
  const _ShellScaffold({required this.shell});

  final StatefulNavigationShell shell;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: shell,
      bottomNavigationBar: NavigationBar(
        selectedIndex: shell.currentIndex,
        onDestinationSelected: (i) => shell.goBranch(
          i,
          initialLocation: i == shell.currentIndex,
        ),
        destinations: [
          for (final t in _tabs)
            NavigationDestination(
              icon: Icon(t.icon),
              selectedIcon: Icon(t.active),
              label: t.label,
            ),
        ],
      ),
    );
  }
}
