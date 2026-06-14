import 'package:flutter/foundation.dart';

/// The four motivational value scales of the mini-test
/// "Ценности и мотиваторы". Each captures what drives a person at work.
enum ValueScale {
  /// Drive to achieve, win, and reach ambitious goals.
  achievement('Достижение', 'Цели, результат, рост и победы'),

  /// Drive for security, predictability, and steady income.
  stability('Стабильность', 'Надёжность, спокойствие, уверенность в завтра'),

  /// Drive to create, invent, and express oneself.
  creativity('Творчество', 'Идеи, самовыражение, новизна'),

  /// Drive to help, care for, and serve others.
  helpingOthers('Помощь людям', 'Забота, польза, вклад в других');

  const ValueScale(this.label, this.blurb);

  /// Short Russian label for the scale.
  final String label;

  /// One-line Russian description of what the scale means.
  final String blurb;
}

/// A single value-test item (agreement format, 1..5 Likert). [reverse] flips
/// the scale when scoring so the bank is not all keyed in one direction.
@immutable
class ValueItem {
  /// Creates a value-test item for [scale]; set [reverse] for negatively
  /// keyed wording.
  const ValueItem(this.text, this.scale, {this.reverse = false});

  /// Russian statement shown to the user.
  final String text;

  /// The value scale this item loads onto.
  final ValueScale scale;

  /// Whether the 1..5 answer should be reversed before scoring.
  final bool reverse;
}

/// A scored value scale with its normalized 0..1 result, used for ranking.
@immutable
class ValueScore {
  /// Creates a scored scale.
  const ValueScore({required this.scale, required this.score});

  /// The value scale.
  final ValueScale scale;

  /// Normalized average for the scale in the range 0..1.
  final double score;
}

/// Result of the "Ценности и мотиваторы" mini-test: scales ranked from the
/// strongest to the weakest motivator.
@immutable
class ValuesResult {
  /// Creates a values result from the [ranked] scales (highest first).
  const ValuesResult({required this.ranked});

  /// Scales sorted by descending [ValueScore.score].
  final List<ValueScore> ranked;

  /// The single strongest motivating value scale.
  ValueScale get top => ranked.first.scale;

  /// Serializes the result to a JSON-safe map.
  Map<String, dynamic> toJson() => {
        'top': top.name,
        'scores': {for (final s in ranked) s.scale.name: s.score},
      };
}

/// The 16 value-test items, 4 per [ValueScale]. All Russian, offline.
const List<ValueItem> kValueItems = [
  // Achievement.
  ValueItem('Для меня важно ставить высокие цели и достигать их', ValueScale.achievement),
  ValueItem('Я хочу быть лучшим в том, чем занимаюсь', ValueScale.achievement),
  ValueItem('Меня мотивирует карьерный рост и признание', ValueScale.achievement),
  ValueItem('Мне не важно соревноваться и побеждать', ValueScale.achievement, reverse: true),

  // Stability.
  ValueItem('Мне важна стабильная и надёжная работа', ValueScale.stability),
  ValueItem('Я ценю спокойствие и предсказуемость в жизни', ValueScale.stability),
  ValueItem('Постоянный доход для меня важнее риска ради большего', ValueScale.stability),
  ValueItem('Мне комфортно жить в постоянной неопределённости', ValueScale.stability, reverse: true),

  // Creativity.
  ValueItem('Мне важно придумывать новое и создавать своё', ValueScale.creativity),
  ValueItem('Я хочу свободно выражать себя в работе', ValueScale.creativity),
  ValueItem('Меня вдохновляют нестандартные идеи и эксперименты', ValueScale.creativity),
  ValueItem('Я предпочитаю чёткие инструкции свободе творчества', ValueScale.creativity, reverse: true),

  // Helping others.
  ValueItem('Мне важно приносить пользу другим людям', ValueScale.helpingOthers),
  ValueItem('Я хочу, чтобы моя работа делала мир лучше', ValueScale.helpingOthers),
  ValueItem('Помогать тем, кому трудно, для меня ценно', ValueScale.helpingOthers),
  ValueItem('Я сосредоточен на себе больше, чем на других', ValueScale.helpingOthers, reverse: true),
];

/// Pure scoring for the "Ценности и мотиваторы" mini-test. Deterministic.
abstract final class ValuesScoring {
  /// Scores [answers] (1..5 Likert, aligned by index with [kValueItems]) and
  /// returns the value scales ranked from strongest to weakest motivator.
  ///
  /// Reverse-keyed items are flipped (`6 - answer`). Each scale's raw average
  /// (1..5) is normalized to 0..1. Ties are broken by the canonical
  /// [ValueScale] order for determinism.
  static ValuesResult score(List<int> answers) {
    assert(
      answers.length == kValueItems.length,
      'answers must align with kValueItems',
    );

    final sums = {for (final s in ValueScale.values) s: 0.0};
    final counts = {for (final s in ValueScale.values) s: 0};
    for (var i = 0; i < kValueItems.length; i++) {
      final item = kValueItems[i];
      final raw = item.reverse ? 6 - answers[i] : answers[i];
      sums[item.scale] = sums[item.scale]! + raw;
      counts[item.scale] = counts[item.scale]! + 1;
    }

    final scores = [
      for (final s in ValueScale.values)
        ValueScore(
          scale: s,
          score: counts[s]! == 0 ? 0.0 : ((sums[s]! / counts[s]!) - 1) / 4,
        ),
    ]..sort((a, b) {
        final cmp = b.score.compareTo(a.score);
        return cmp != 0 ? cmp : a.scale.index.compareTo(b.scale.index);
      });

    return ValuesResult(ranked: scores);
  }
}
