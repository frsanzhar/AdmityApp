/// Domain models for the Courses feature.
///
/// A [Course] is what gets shown as a page in the horizontal PageView.
/// A [Course] contains ordered [CourseModule]s; each module contains ordered
/// [CourseLesson]s.
///
/// ## Generated-course contract
/// When `CourseGenerationService` synthesises a course (offline or via the
/// mentor Edge Function) the result MUST conform to this shape:
///
/// ```dart
/// Course(
///   id: 'gen_<timestamp>',
///   title: '<topic>',
///   level: 'Уровень 1',
///   subjectLabel: '<short label>',
///   gradeHint: 'для 11 класса',
///   interestHint: 'по твоим интересам',
///   modules: [ /* 2–4 CourseModule entries */ ],
/// )
/// ```
///
/// The `TheoryCard.body` field contains explanatory text (plain Cyrillic prose,
/// up to 300 chars).  `CourseLessonQuestion` mirrors the `LessonQuestion` class
/// in lesson_screen.dart so the lesson flow can consume it directly.
library;

// ── TheoryCard ────────────────────────────────────────────────────────────────

/// A single card shown in the THEORY step of the lesson flow.
class TheoryCard {
  const TheoryCard({
    required this.headline,
    required this.body,
    this.emoji,
  });

  /// Short heading shown at the top of the card (≤ 50 chars).
  final String headline;

  /// Explanatory body text (≤ 300 chars, plain Cyrillic prose).
  final String body;

  /// Optional single emoji that acts as a visual anchor for the card.
  final String? emoji;
}

// ── LessonQuestion (course-level) ─────────────────────────────────────────────

/// A multiple-choice question embedded inside a [CourseLesson].
///
/// This mirrors the `LessonQuestion` defined in `lesson_screen.dart`.
/// Kept here so course-level models are self-contained and the data layer
/// can construct full lessons without importing the presentation layer.
class CourseLessonQuestion {
  const CourseLessonQuestion({
    required this.question,
    required this.options,
    required this.correctIndex,
    required this.explanation,
  });

  final String question;
  final List<String> options;
  final int correctIndex;
  final String explanation;
}

// ── CourseLesson ──────────────────────────────────────────────────────────────

/// A single lesson inside a [CourseModule].
class CourseLesson {
  const CourseLesson({
    required this.id,
    required this.title,
    this.theory = const [],
    this.questions = const [],
    this.isCompleted = false,
    this.isLocked = false,
  });

  final String id;
  final String title;

  /// Theory cards shown in the THEORY step (intro → theory → questions).
  final List<TheoryCard> theory;

  /// Multiple-choice questions for the QUESTION step.
  final List<CourseLessonQuestion> questions;

  final bool isCompleted;
  final bool isLocked;

  CourseLesson copyWith({
    bool? isCompleted,
    bool? isLocked,
  }) {
    return CourseLesson(
      id: id,
      title: title,
      theory: theory,
      questions: questions,
      isCompleted: isCompleted ?? this.isCompleted,
      isLocked: isLocked ?? this.isLocked,
    );
  }
}

// ── CourseModule ──────────────────────────────────────────────────────────────

/// A named grouping of lessons within a [Course].
class CourseModule {
  const CourseModule({
    required this.id,
    required this.title,
    this.lessons = const [],
  });

  final String id;
  final String title;
  final List<CourseLesson> lessons;
}

// ── Course ────────────────────────────────────────────────────────────────────

/// Top-level course, shown as one page in the horizontal PageView on
/// CoursesScreen.
class Course {
  const Course({
    required this.id,
    required this.title,
    required this.subjectLabel,
    required this.level,
    this.gradeHint,
    this.interestHint,
    this.modules = const [],
    this.isGenerated = false,
  });

  /// Unique identifier (stable seed IDs for bundled courses; `gen_<timestamp>`
  /// for AI-generated courses).
  final String id;

  /// Full title displayed at the top of the course page.
  final String title;

  /// Short label shown in the page indicator dots and mini tab chip
  /// (≤ 12 chars, e.g. 'Математика').
  final String subjectLabel;

  /// Difficulty/progress label shown under the title (e.g. 'Уровень 1').
  final String level;

  /// Reason hint based on grade (e.g. 'для 11 класса').
  /// Shown in grey beneath the title when non-null.
  final String? gradeHint;

  /// Reason hint based on interests (e.g. 'по твоим интересам').
  final String? interestHint;

  final List<CourseModule> modules;

  /// True when the course was created via `CourseGenerationService`.
  final bool isGenerated;

  /// Flat list of all lessons across all modules — convenience accessor.
  List<CourseLesson> get allLessons =>
      modules.expand((m) => m.lessons).toList();
}
