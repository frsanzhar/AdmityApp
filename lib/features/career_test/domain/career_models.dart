import 'package:flutter/foundation.dart';

/// The six Holland (RIASEC) interest types.
enum RiasecType {
  realistic('R', 'Практик', 'Техника, руки, реальные объекты'),
  investigative('I', 'Исследователь', 'Анализ, наука, идеи'),
  artistic('A', 'Творец', 'Искусство, самовыражение'),
  social('S', 'Помощник', 'Люди, обучение, забота'),
  enterprising('E', 'Лидер', 'Влияние, бизнес, убеждение'),
  conventional('C', 'Систематик', 'Порядок, данные, структура');

  const RiasecType(this.letter, this.label, this.blurb);

  final String letter;
  final String label;
  final String blurb;
}

/// The Big Five (OCEAN) personality traits.
enum BigFiveTrait {
  openness('Открытость'),
  conscientiousness('Добросовестность'),
  extraversion('Экстраверсия'),
  agreeableness('Доброжелательность'),
  neuroticism('Нейротизм');

  const BigFiveTrait(this.label);

  final String label;
}

/// A single RIASEC activity-format item ("how interesting is it to…", 1–5).
@immutable
class RiasecItem {
  const RiasecItem(this.text, this.type);
  final String text;
  final RiasecType type;
}

/// A single Big Five agreement item. [reverse] flips the scale when scoring.
@immutable
class BigFiveItem {
  const BigFiveItem(this.text, this.trait, {this.reverse = false});
  final String text;
  final BigFiveTrait trait;
  final bool reverse;
}

/// A recommended cluster of majors, matched from a RIASEC code.
@immutable
class MajorCluster {
  const MajorCluster({
    required this.name,
    required this.description,
    required this.majors,
    required this.codes,
  });

  final String name;
  final String description;
  final List<String> majors;

  /// RIASEC letters this cluster aligns with (e.g. ['I', 'R', 'C']).
  final List<String> codes;
}

/// Output of the career test.
@immutable
class CareerResult {
  const CareerResult({
    required this.riasecScores,
    required this.riasecCode,
    required this.bigFive,
    required this.recommendedClusters,
  });

  /// Normalized 0..1 score per RIASEC type.
  final Map<RiasecType, double> riasecScores;

  /// Three-letter code of the top types, e.g. "IRC".
  final String riasecCode;

  /// Normalized 0..1 score per Big Five trait.
  final Map<BigFiveTrait, double> bigFive;

  final List<MajorCluster> recommendedClusters;

  Map<String, dynamic> toJson() => {
        'riasec_code': riasecCode,
        'riasec_scores': riasecScores.map((k, v) => MapEntry(k.name, v)),
        'big_five': bigFive.map((k, v) => MapEntry(k.name, v)),
        'recommended_clusters':
            recommendedClusters.map((c) => c.name).toList(),
      };
}
