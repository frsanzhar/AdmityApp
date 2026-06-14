import 'package:admity/features/essay_review/domain/essay_models.dart';
import 'package:flutter/foundation.dart';

/// The kind of an external [LessonResource] link — drives its icon/label.
enum LessonResourceKind {
  /// A written guide, page or worked example to read.
  article,

  /// A video lesson (e.g. Khan Academy, Crash Course on YouTube).
  video,

  /// An interactive tool, template or official form.
  tool,
}

/// One teaching block of a day's micro-lesson: a [heading] plus a
/// multi-paragraph Russian [body] that explains the idea and shows a worked
/// example. Immutable; additive — days without sections keep working.
@immutable
class LessonSection {
  /// Creates a lesson section with a [heading] and explanatory [body].
  const LessonSection({required this.heading, required this.body});

  /// Short Russian heading for the block (e.g. «Зачем нужна зацепка»).
  final String heading;

  /// Multi-paragraph Russian explanation. Paragraphs are separated by a
  /// blank line (`\n\n`); the UI renders each as its own paragraph.
  final String body;
}

/// A reputable external link surfaced in the day's «Материалы» list.
/// Immutable and documented; opened with `url_launcher` externally.
@immutable
class LessonResource {
  /// Creates a resource pointing at [url] with a Russian [title].
  const LessonResource({
    required this.title,
    required this.url,
    this.kind = LessonResourceKind.article,
  });

  /// Russian, user-facing label for the link.
  final String title;

  /// The destination URL (a real, well-known page — opened externally).
  final String url;

  /// What kind of resource this is — drives the leading icon.
  final LessonResourceKind kind;
}

/// The kind of optional interactive task a day can surface below its content.
enum IntensiveTaskType {
  /// Type a response and get an instant rubric-based score.
  selfAssessment,

  /// Attach a photo of a deliverable (e.g. a handwritten plan).
  cameraPhoto,

  /// Record / attach a short video (e.g. a self-presentation).
  cameraVideo,
}

/// An optional interactive task attached to an [IntensiveDay]. Additive and
/// non-breaking: days without one keep working unchanged.
@immutable
class IntensiveTask {
  /// Creates an interactive task of [type] with a Russian [prompt].
  const IntensiveTask({
    required this.type,
    required this.prompt,
    this.essayKind,
  });

  /// What kind of task this is (drives which widget renders).
  final IntensiveTaskType type;

  /// The Russian instruction shown to the student on the task card.
  final String prompt;

  /// For [IntensiveTaskType.selfAssessment], the essay kind used to score the
  /// typed response. Ignored for camera tasks.
  final EssayKind? essayKind;
}

/// One day of a 2-week intensive track (10–20 min micro-lesson).
@immutable
class IntensiveDay {
  /// Creates a day with its teaching content, practice steps and reward.
  const IntensiveDay({
    required this.day,
    required this.title,
    required this.goal,
    required this.steps,
    required this.xpReward,
    this.lessonSections = const [],
    this.resources = const [],
    this.estimatedMinutes = 15,
    this.rubricCheck,
    this.task,
  });

  /// 1-based day number within the track (1..14).
  final int day;

  /// Short Russian title of the day.
  final String title;

  /// One-line Russian goal for the day.
  final String goal;

  /// The concrete practice steps the student works through.
  final List<String> steps;

  /// XP awarded when the day's rubric check passes.
  final int xpReward;

  /// The teaching blocks of the micro-lesson (heading + explanation +
  /// worked example). Empty for legacy days with no written content.
  final List<LessonSection> lessonSections;

  /// Reputable external links to read/watch/use for this day. May be empty.
  final List<LessonResource> resources;

  /// Rough time to finish the day, in minutes (shown to set expectations).
  final int estimatedMinutes;

  /// Prompt the student must satisfy (checked by rubric/Eraly) to earn XP.
  /// Null for purely instructional days.
  final String? rubricCheck;

  /// Optional interactive task surfaced below the day's content.
  final IntensiveTask? task;
}

/// A 2-week intensive track.
@immutable
class Intensive {
  const Intensive({
    required this.slug,
    required this.title,
    required this.description,
    required this.days,
  });

  final String slug;
  final String title;
  final String description;
  final List<IntensiveDay> days;

  int get totalXp => days.fold(0, (sum, d) => sum + d.xpReward);
  int get totalDays => days.length;
}

/// Mutable-ish progress snapshot for a student on a track. Immutable value;
/// the engine returns updated copies.
@immutable
class IntensiveProgress {
  const IntensiveProgress({
    required this.intensiveSlug,
    this.currentDay = 1,
    this.xp = 0,
    this.streakCount = 0,
    this.streakFreezes = 2,
    this.lastActiveDate,
    this.completedDays = const {},
  });

  factory IntensiveProgress.fromJson(Map<String, dynamic> json) =>
      IntensiveProgress(
        intensiveSlug: json['intensive_slug'] as String,
        currentDay: (json['current_day'] as num?)?.toInt() ?? 1,
        xp: (json['xp'] as num?)?.toInt() ?? 0,
        streakCount: (json['streak_count'] as num?)?.toInt() ?? 0,
        streakFreezes: (json['streak_freezes'] as num?)?.toInt() ?? 2,
        lastActiveDate: json['last_active'] == null
            ? null
            : DateTime.parse(json['last_active'] as String),
        completedDays: ((json['completed_days'] as List<dynamic>?) ?? [])
            .map((e) => (e as num).toInt())
            .toSet(),
      );

  final String intensiveSlug;
  final int currentDay;
  final int xp;
  final int streakCount;
  final int streakFreezes;
  final DateTime? lastActiveDate;
  final Set<int> completedDays;

  bool isDayComplete(int day) => completedDays.contains(day);

  Map<String, dynamic> toJson() => {
        'intensive_slug': intensiveSlug,
        'current_day': currentDay,
        'xp': xp,
        'streak_count': streakCount,
        'streak_freezes': streakFreezes,
        'last_active': lastActiveDate?.toIso8601String(),
        'completed_days': completedDays.toList()..sort(),
      };

  IntensiveProgress copyWith({
    int? currentDay,
    int? xp,
    int? streakCount,
    int? streakFreezes,
    DateTime? lastActiveDate,
    Set<int>? completedDays,
  }) {
    return IntensiveProgress(
      intensiveSlug: intensiveSlug,
      currentDay: currentDay ?? this.currentDay,
      xp: xp ?? this.xp,
      streakCount: streakCount ?? this.streakCount,
      streakFreezes: streakFreezes ?? this.streakFreezes,
      lastActiveDate: lastActiveDate ?? this.lastActiveDate,
      completedDays: completedDays ?? this.completedDays,
    );
  }
}

/// Outcome of completing a day — drives mascot celebration + UI feedback.
@immutable
class IntensiveCompletion {
  const IntensiveCompletion({
    required this.progress,
    required this.xpGained,
    required this.streakChanged,
    required this.freezeUsed,
    required this.trackFinished,
    required this.accepted,
  });

  final IntensiveProgress progress;
  final int xpGained;
  final bool streakChanged;
  final bool freezeUsed;
  final bool trackFinished;

  /// False when the rubric check did not pass (no XP, day not marked).
  final bool accepted;
}
