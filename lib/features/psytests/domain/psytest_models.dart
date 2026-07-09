/// Domain models for the Psychology Tests roadmap feature.
library;

/// A single answer option within a [PsyQuestion].
///
/// [weights] maps a category key to a score contribution.
class PsyOption {
  const PsyOption({required this.text, required this.weights});

  final String text;

  /// Category key → score weight.  Usually `{key: 1}` or `{key: 2}`.
  final Map<String, int> weights;
}

/// A single question within a [PsyTestDef].
class PsyQuestion {
  const PsyQuestion({required this.text, required this.options});

  final String text;

  /// 3–4 answer options for this question.
  final List<PsyOption> options;
}

/// Static definition of one psychological test (from seed data, never persisted).
class PsyTestDef {
  const PsyTestDef({
    required this.id,
    required this.order,
    required this.title,
    required this.description,
    required this.emoji,
    required this.questions,
    required this.categoryLabels,
    required this.categoryDescriptions,
    required this.resultHint,
  });

  /// Stable string identifier (matches stored [PsyTestResult.testId]).
  final String id;

  /// 1-based position in the roadmap.
  final int order;

  final String title;
  final String description;

  /// Emoji shown on the roadmap node.
  final String emoji;

  final List<PsyQuestion> questions;

  /// Maps category key → short human-readable label (e.g. `{'intro': 'Интроверт'}`).
  final Map<String, String> categoryLabels;

  /// Maps category key → friendly paragraph description for a teen.
  final Map<String, String> categoryDescriptions;

  /// One-liner explaining what this test reveals about career direction.
  final String resultHint;
}

/// Persisted result of one completed test.
class PsyTestResult {
  const PsyTestResult({
    required this.testId,
    required this.completedAt,
    required this.scores,
    required this.topCategories,
  });

  factory PsyTestResult.fromJson(Map<String, dynamic> json) {
    return PsyTestResult(
      testId: json['testId'] as String,
      completedAt: DateTime.parse(json['completedAt'] as String),
      scores: Map<String, int>.fromEntries(
        (json['scores'] as Map<String, dynamic>).entries.map(
          (e) => MapEntry(e.key, (e.value as num).toInt()),
        ),
      ),
      topCategories: List<String>.from(
        json['topCategories'] as List<dynamic>,
      ),
    );
  }

  final String testId;
  final DateTime completedAt;

  /// Accumulated score per category key.
  final Map<String, int> scores;

  /// Keys of the 1–2 highest-scoring categories.
  final List<String> topCategories;

  Map<String, dynamic> toJson() => {
    'testId': testId,
    'completedAt': completedAt.toIso8601String(),
    'scores': scores,
    'topCategories': topCategories,
  };
}
