import 'package:flutter/foundation.dart';

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

  final List<RubricScore> scores;
  final int wordCount;
  final List<String> strengths;
  final List<String> suggestions;
  final String? overall;

  /// Average of the available numeric scores, 0..4.
  double get average => scores.isEmpty
      ? 0
      : scores.map((s) => s.score).reduce((a, b) => a + b) / scores.length;
}
