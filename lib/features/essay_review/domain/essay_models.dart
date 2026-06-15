import 'package:flutter/foundation.dart';

/// Returns the enum value whose `name` matches [name], or null — so legacy /
/// unknown stored strings never throw (unlike `Enum.byName`).
T? _enumByNameOrNull<T extends Enum>(List<T> values, Object? name) {
  if (name is! String) return null;
  for (final v in values) {
    if (v.name == name) return v;
  }
  return null;
}

/// The kind of admissions essay, which sets the prompt + length expectations.
enum EssayKind {
  commonApp('Common App (США)', 'личная рефлексивная история о тебе', 650),
  ucas('UCAS (Великобритания, 3 вопроса)', 'мотивация и подготовка к предмету', 650),
  motivationEu('Мотивационное письмо (Европа)', 'почему этот предмет и вуз', 500);

  const EssayKind(this.label, this.focus, this.wordLimit);

  final String label;
  final String focus;

  /// Recommended length in words.
  final int wordLimit;
}

/// The eight rubric criteria an essay is scored against (each 0..4).
enum RubricCriterion {
  concreteness('Конкретика и детали'),
  showDontTell("Show, don't tell"),
  voice('Личный голос'),
  reflection('Рефлексия и рост'),
  structure('Структура'),
  wordEconomy('Экономия слов'),
  clicheAvoidance('Без клише'),
  promptFit('Соответствие промпту');

  const RubricCriterion(this.label);

  final String label;
}

/// A score (0..4) for one criterion, with a short comment.
@immutable
class RubricScore {
  const RubricScore({
    required this.criterion,
    required this.score,
    required this.comment,
    this.byEraly = false,
  });

  final RubricCriterion criterion;
  final int score; // 0..4
  final String comment;

  /// True when produced by the online Eraly editor (vs the local heuristic).
  final bool byEraly;

  /// Serializes for the local cache / sync (`rubric_feedback` jsonb).
  Map<String, dynamic> toJson() => {
        'criterion': criterion.name,
        'score': score,
        'comment': comment,
        'by_eraly': byEraly,
      };

  /// Rebuilds a score, or null when the criterion is unknown (so a renamed /
  /// legacy criterion is skipped rather than crashing).
  static RubricScore? tryFromJson(Map<String, dynamic> json) {
    final criterion =
        _enumByNameOrNull(RubricCriterion.values, json['criterion']);
    if (criterion == null) return null;
    return RubricScore(
      criterion: criterion,
      score: (json['score'] as num?)?.toInt() ?? 0,
      comment: json['comment'] as String? ?? '',
      byEraly: (json['by_eraly'] as bool?) ?? false,
    );
  }
}

/// Aggregated feedback for a draft.
@immutable
class EssayFeedback {
  const EssayFeedback({
    required this.scores,
    required this.wordCount,
    required this.strengths,
    required this.suggestions,
    this.overall,
  });

  /// Rebuilds feedback from cached/synced JSON; tolerant of partial rubrics
  /// (the local scorer emits only 5 of 8 criteria) and unknown criteria.
  factory EssayFeedback.fromJson(Map<String, dynamic> json) => EssayFeedback(
        scores: [
          for (final s in (json['scores'] as List<dynamic>? ?? []))
            if (s is Map<String, dynamic>)
              ?RubricScore.tryFromJson(s),
        ],
        wordCount: (json['word_count'] as num?)?.toInt() ?? 0,
        strengths: [
          for (final s in (json['strengths'] as List<dynamic>? ?? []))
            if (s is String) s,
        ],
        suggestions: [
          for (final s in (json['suggestions'] as List<dynamic>? ?? []))
            if (s is String) s,
        ],
        overall: json['overall'] as String?,
      );

  final List<RubricScore> scores;
  final int wordCount;
  final List<String> strengths;
  final List<String> suggestions;
  final String? overall;

  /// Average of the available numeric scores, 0..4.
  double get average => scores.isEmpty
      ? 0
      : scores.map((s) => s.score).reduce((a, b) => a + b) / scores.length;

  /// Serializes for the local cache / sync (stored as the `rubric_feedback`
  /// jsonb column). [average] is computed, so it is not persisted.
  Map<String, dynamic> toJson() => {
        'scores': scores.map((s) => s.toJson()).toList(),
        'word_count': wordCount,
        'strengths': strengths,
        'suggestions': suggestions,
        if (overall != null) 'overall': overall,
      };
}

/// A persisted essay draft for one [EssayKind] — the user's draft text plus the
/// latest rubric [feedback] (if scored). This is the unit synced to the
/// `essays` table (one row per kind, keyed by `(user_id, kind)`).
@immutable
class EssayRecord {
  /// Creates an essay record.
  const EssayRecord({
    required this.kind,
    required this.draftText,
    required this.updatedAt,
    this.feedback,
  });

  /// The essay kind (Common App / UCAS / motivation letter).
  final EssayKind kind;

  /// The student's current draft text.
  final String draftText;

  /// The latest rubric feedback, or null if not scored yet.
  final EssayFeedback? feedback;

  /// When this record was last changed (drives last-writer-wins on sync).
  final DateTime updatedAt;

  /// Copy with selected fields replaced.
  EssayRecord copyWith({String? draftText, EssayFeedback? feedback, DateTime? updatedAt}) =>
      EssayRecord(
        kind: kind,
        draftText: draftText ?? this.draftText,
        feedback: feedback ?? this.feedback,
        updatedAt: updatedAt ?? this.updatedAt,
      );

  /// Serializes for the local cache.
  Map<String, dynamic> toJson() => {
        'kind': kind.name,
        'draft_text': draftText,
        'rubric_feedback': feedback?.toJson(),
        'updated_at': updatedAt.toUtc().toIso8601String(),
      };

  /// Rebuilds a record, or null when the kind is unknown.
  static EssayRecord? tryFromJson(Map<String, dynamic> json) {
    final kind = _enumByNameOrNull(EssayKind.values, json['kind']);
    if (kind == null) return null;
    final fb = json['rubric_feedback'];
    return EssayRecord(
      kind: kind,
      draftText: json['draft_text'] as String? ?? '',
      feedback: fb is Map<String, dynamic> ? EssayFeedback.fromJson(fb) : null,
      updatedAt: DateTime.tryParse(json['updated_at'] as String? ?? '') ??
          DateTime.fromMillisecondsSinceEpoch(0),
    );
  }
}
