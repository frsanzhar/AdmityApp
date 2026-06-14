import 'package:admity/features/intensives/domain/intensive_engine.dart';
import 'package:admity/features/intensives/domain/intensive_models.dart';
import 'package:flutter_test/flutter_test.dart';

Intensive makeIntensive(int days) => Intensive(
      slug: 'test',
      title: 'Test track',
      description: '—',
      days: [
        for (var i = 1; i <= days; i++)
          IntensiveDay(
            day: i,
            title: 'Day $i',
            goal: '—',
            steps: const ['step'],
            xpReward: 50,
            rubricCheck: 'check',
          ),
      ],
    );

void main() {
  final intensive = makeIntensive(3);
  final jan1 = DateTime(2025);
  final jan2 = DateTime(2025, 1, 2);
  final jan3 = DateTime(2025, 1, 3);

  test('passing the rubric awards XP and starts the streak', () {
    const p = IntensiveProgress(intensiveSlug: 'test');
    final c = IntensiveEngine.completeDay(
      progress: p,
      intensive: intensive,
      day: 1,
      today: jan1,
    );
    expect(c.accepted, isTrue);
    expect(c.xpGained, 50);
    expect(c.progress.xp, 50);
    expect(c.progress.streakCount, 1);
    expect(c.progress.currentDay, 2);
    expect(c.progress.isDayComplete(1), isTrue);
  });

  test('failing the rubric awards nothing and does not advance', () {
    const p = IntensiveProgress(intensiveSlug: 'test');
    final c = IntensiveEngine.completeDay(
      progress: p,
      intensive: intensive,
      day: 1,
      today: jan1,
      rubricPassed: false,
    );
    expect(c.accepted, isFalse);
    expect(c.xpGained, 0);
    expect(c.progress.streakCount, 0);
    expect(c.progress.isDayComplete(1), isFalse);
  });

  test('consecutive days increment the streak', () {
    const p = IntensiveProgress(intensiveSlug: 'test');
    final d1 = IntensiveEngine.completeDay(
      progress: p,
      intensive: intensive,
      day: 1,
      today: jan1,
    );
    final d2 = IntensiveEngine.completeDay(
      progress: d1.progress,
      intensive: intensive,
      day: 2,
      today: jan2,
    );
    expect(d2.progress.streakCount, 2);
  });

  test('a one-day gap consumes a streak-freeze and preserves the streak', () {
    const p = IntensiveProgress(
      intensiveSlug: 'test',
      streakCount: 1,
    );
    final withDate = p.copyWith(lastActiveDate: jan1);
    final c = IntensiveEngine.completeDay(
      progress: withDate,
      intensive: intensive,
      day: 2,
      today: jan3, // skipped Jan 2
    );
    expect(c.freezeUsed, isTrue);
    expect(c.progress.streakFreezes, 1);
    expect(c.progress.streakCount, 2);
  });

  test('a gap with no freeze resets the streak', () {
    final p = const IntensiveProgress(
      intensiveSlug: 'test',
      streakCount: 5,
    ).copyWith(lastActiveDate: jan1);
    final c = IntensiveEngine.completeDay(
      progress: p,
      intensive: intensive,
      day: 2,
      today: jan3,
    );
    expect(c.freezeUsed, isTrue); // default 2 freezes available
    // Re-run with zero freezes to verify reset.
    final noFreeze =
        p.copyWith(streakFreezes: 0).copyWith(lastActiveDate: jan1);
    final c2 = IntensiveEngine.completeDay(
      progress: noFreeze,
      intensive: intensive,
      day: 2,
      today: jan3,
    );
    expect(c2.freezeUsed, isFalse);
    expect(c2.progress.streakCount, 1);
  });

  test('re-completing an already-done day is a no-op (no streak/XP farming)', () {
    const fresh = IntensiveProgress(intensiveSlug: 'test');
    final first = IntensiveEngine.completeDay(
      progress: fresh,
      intensive: intensive,
      day: 1,
      today: jan1,
    );
    final redo = IntensiveEngine.completeDay(
      progress: first.progress,
      intensive: intensive,
      day: 1,
      today: jan2, // a later day — would have advanced the streak if not guarded
    );
    expect(redo.accepted, isFalse);
    expect(redo.xpGained, 0);
    expect(redo.progress.streakCount, first.progress.streakCount);
    expect(redo.progress.xp, first.progress.xp);
  });

  test('a 2-day gap with no existing streak does not waste a freeze', () {
    final p = const IntensiveProgress(intensiveSlug: 'test')
        .copyWith(lastActiveDate: jan1); // streakCount 0, freezes 2 (defaults)
    final c = IntensiveEngine.completeDay(
      progress: p,
      intensive: intensive,
      day: 2,
      today: jan3,
    );
    expect(c.freezeUsed, isFalse);
    expect(c.progress.streakFreezes, 2);
    expect(c.progress.streakCount, 1);
  });

  test('completing every day finishes the track', () {
    var progress = const IntensiveProgress(intensiveSlug: 'test');
    var finished = false;
    for (var day = 1; day <= intensive.totalDays; day++) {
      final c = IntensiveEngine.completeDay(
        progress: progress,
        intensive: intensive,
        day: day,
        today: DateTime(2025, 1, day),
      );
      progress = c.progress;
      finished = c.trackFinished;
    }
    expect(finished, isTrue);
    expect(progress.xp, 150);
  });
}
