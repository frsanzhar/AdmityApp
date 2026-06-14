import 'package:admity/features/intensives/domain/intensive_models.dart';

/// Pure intensive progression logic: XP, streaks, streak-freeze.
///
/// Rewards are gated on `rubricPassed` — opening a lesson earns nothing, only
/// passing its check does (this is what stops XP-grinding of easy lessons).
abstract final class IntensiveEngine {
  /// Completes [day] for [progress] as of [today].
  static IntensiveCompletion completeDay({
    required IntensiveProgress progress,
    required Intensive intensive,
    required int day,
    required DateTime today,
    bool rubricPassed = true,
  }) {
    if (!rubricPassed) {
      return IntensiveCompletion(
        progress: progress,
        xpGained: 0,
        streakChanged: false,
        freezeUsed: false,
        trackFinished: false,
        accepted: false,
      );
    }

    // Re-completing a day already finished earns nothing AND must not touch the
    // streak or last-active date (otherwise a student could farm an arbitrary
    // streak by re-confirming one old day each day).
    if (progress.isDayComplete(day)) {
      return IntensiveCompletion(
        progress: progress,
        xpGained: 0,
        streakChanged: false,
        freezeUsed: false,
        trackFinished: progress.completedDays.length >= intensive.totalDays,
        accepted: false,
      );
    }

    final xpGained = intensive.days
        .firstWhere((d) => d.day == day, orElse: () => intensive.days.first)
        .xpReward;

    final todayDate = _dateOnly(today);
    final last =
        progress.lastActiveDate == null ? null : _dateOnly(progress.lastActiveDate!);

    var newStreak = progress.streakCount;
    var freezes = progress.streakFreezes;
    var freezeUsed = false;
    var streakChanged = false;

    if (last == null) {
      newStreak = 1;
      streakChanged = true;
    } else {
      final diff = todayDate.difference(last).inDays;
      if (diff == 0) {
        if (newStreak == 0) {
          newStreak = 1;
          streakChanged = true;
        }
      } else if (diff == 1) {
        newStreak += 1;
        streakChanged = true;
      } else if (diff == 2 && freezes > 0 && newStreak > 0) {
        // One missed day, covered by a freeze — but only spend a freeze when
        // there's actually a streak to protect.
        freezes -= 1;
        freezeUsed = true;
        newStreak += 1;
        streakChanged = true;
      } else {
        newStreak = 1;
        streakChanged = true;
      }
    }

    final completed = {...progress.completedDays, day};
    final nextDay = day >= progress.currentDay
        ? (day + 1).clamp(1, intensive.totalDays)
        : progress.currentDay;
    final trackFinished = completed.length >= intensive.totalDays;

    final updated = progress.copyWith(
      currentDay: nextDay,
      xp: progress.xp + xpGained,
      streakCount: newStreak,
      streakFreezes: freezes,
      lastActiveDate: todayDate,
      completedDays: completed,
    );

    return IntensiveCompletion(
      progress: updated,
      xpGained: xpGained,
      streakChanged: streakChanged,
      freezeUsed: freezeUsed,
      trackFinished: trackFinished,
      accepted: true,
    );
  }

  static DateTime _dateOnly(DateTime d) => DateTime(d.year, d.month, d.day);
}
