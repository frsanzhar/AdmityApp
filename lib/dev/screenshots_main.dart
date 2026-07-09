/// Screenshot-tour entrypoint for App Store marketing captures.
///
/// Runs the real app, seeds a presentable demo profile, then auto-navigates
/// through the key screens on a fixed timetable so an external script can
/// capture simulator screenshots at known moments:
///
///   t=3s  /auth          t=9s  /onboarding    t=15s /home
///   t=21s /uni-kz        t=27s /uni-kz/kaznu  t=33s /mentor
///   t=39s /profile
///
/// Build: flutter build ios --simulator -t lib/dev/screenshots_main.dart
/// Never shipped: not referenced by lib/main.dart.
library;

import 'dart:async';

import 'package:admity/app.dart';
import 'package:admity/bootstrap.dart';
import 'package:admity/core/router/app_router.dart';
import 'package:admity/features/profile/data/profile_repository.dart';
import 'package:admity/features/profile/domain/profile_model.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

Future<void> main() async {
  final router = createRouter();
  await bootstrap(() async {
    // Seed a realistic, presentable profile so Home/Profile look alive.
    await const HiveProfileRepository().saveProfile(
      const StudentProfile(
        onboardingComplete: true,
        role: 'Ученик',
        age: 16,
        grade: '11 класс',
        motivation: 'Поступить в топ-вуз Казахстана',
        targetMajors: ['Информационные технологии', 'Математика'],
        confidence: 'Уверен в себе',
        gpa: '4.8',
        ieltsScore: '7.0',
        satScore: '1350',
        dailyGoalMinutes: 30,
        schedule: 'Вечер',
        interests: ['Программирование', 'Робототехника'],
        appLanguage: 'ru',
      ),
    );
    _scheduleTour(router);
    return ProviderScope(
      overrides: [routerProvider.overrideWithValue(router)],
      child: const AdmityApp(),
    );
  });
}

void _scheduleTour(GoRouter router) {
  const stops = <(int, String)>[
    (3, '/auth'),
    (9, '/onboarding'),
    (15, '/home'),
    (21, '/uni-kz'),
    (27, '/uni-kz/kaznu'),
    (33, '/mentor'),
    (39, '/profile'),
  ];
  for (final (sec, path) in stops) {
    Timer(Duration(seconds: sec), () => router.go(path));
  }
}
