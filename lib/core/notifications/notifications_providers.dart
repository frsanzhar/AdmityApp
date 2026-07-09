/// Riverpod providers for the notifications layer.
///
/// Exposes [notificationsServiceProvider] as a thin wrapper that lets widgets
/// call service methods without touching [NotificationsService] directly, and
/// [rescheduleStudyReminderProvider] which wires a profile change to a daily
/// notification update.
library;

import 'package:admity/core/notifications/notifications_service.dart';
import 'package:admity/features/profile/application/profile_notifier.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// ── Service provider ──────────────────────────────────────────────────────────

/// Provides [NotificationsService] as a plain value so it can be injected via
/// [Ref] in tests (override with a no-op implementation).
///
/// The class itself is stateless (static methods only), so the provider just
/// exposes [NotificationsService.instance] as a convenience handle; callers
/// may use [NotificationsService] static methods directly without going through
/// this provider.
final notificationsServiceProvider = Provider<NotificationsService>(
  (_) => NotificationsService.instance,
);

// ── Study-reminder scheduler ──────────────────────────────────────────────────

/// Notification id reserved for the daily study reminder.
const kStudyReminderId = 1001;

/// Schedules (or re-schedules) the daily study reminder based on the current
/// `StudentProfile.schedule` and `StudentProfile.dailyGoalMinutes`.
///
/// Call this after any profile change that might affect the study slot:
/// ```dart
/// await ref.read(rescheduleStudyReminderProvider.future);
/// ```
///
/// The provider is a [FutureProvider] so it naturally participates in the
/// loading / error pattern.  It reads [profileProvider] reactively — the next
/// time the profile changes and this provider is re-read, it re-schedules.
final rescheduleStudyReminderProvider = FutureProvider<void>((ref) async {
  final profile = ref.watch(profileProvider).profile;

  // Resolve hour from the schedule preference.
  final hour = _hourForSchedule(profile.schedule);
  final goalMinutes = profile.dailyGoalMinutes ?? 20;

  await NotificationsService.scheduleDailyReminder(
    id: kStudyReminderId,
    hour: hour,
    minute: 0,
    title: 'Время учиться!',
    body: _bodyForGoal(goalMinutes),
  );
  debugPrint(
    '[NotificationsService] study reminder scheduled at $hour:00, '
    'goal: ${goalMinutes}m',
  );
});

// ── Helpers ───────────────────────────────────────────────────────────────────

/// Maps the student's [schedule] preference to an hour-of-day.
///
/// The mapping deliberately stays coarse — notifications don't need to be
/// exact; the OS trims them for battery anyway.
int _hourForSchedule(String? schedule) => switch (schedule) {
  'Утро' => 8,
  'День' => 13,
  'Вечер' => 19,
  'Ночь' => 21,
  // Default to evening if no preference is set.
  _ => 19,
};

/// Builds a motivational body string based on the daily goal.
String _bodyForGoal(int minutes) {
  if (minutes <= 10) {
    return 'Всего 10 минут — и ты на шаг ближе к цели!';
  }
  if (minutes <= 20) {
    return '20 минут занятий сегодня — ты справишься!';
  }
  if (minutes <= 30) {
    return 'Запланировано $minutes минут учёбы. Начнём?';
  }
  return 'Большая цель сегодня: $minutes минут. Удачи!';
}
