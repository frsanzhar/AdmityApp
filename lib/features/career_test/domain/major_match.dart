import 'package:admity/features/career_test/domain/values_test.dart';
import 'package:flutter/foundation.dart';

/// A recommended major / field of study with a short Russian rationale.
@immutable
class MajorMatch {
  /// Creates a major recommendation.
  const MajorMatch({
    required this.major,
    required this.rationale,
    required this.codes,
  });

  /// Russian name of the major / field (e.g. "Информатика").
  final String major;

  /// One-line Russian explanation of why it fits the profile.
  final String rationale;

  /// RIASEC letters this major aligns with (e.g. ['I', 'R', 'C']).
  final List<String> codes;
}

/// Static catalogue of majors keyed to RIASEC letters. Each entry carries the
/// letters it aligns with so [matchMajors] can rank by overlap with a code.
const List<MajorMatch> kMajorCatalogue = [
  MajorMatch(
    major: 'Информатика и программирование',
    rationale: 'Логика, анализ и работа с системами — твоя стихия.',
    codes: ['I', 'R', 'C'],
  ),
  MajorMatch(
    major: 'Анализ данных и ИИ',
    rationale: 'Любишь искать закономерности в данных и проверять гипотезы.',
    codes: ['I', 'C', 'E'],
  ),
  MajorMatch(
    major: 'Инженерия и робототехника',
    rationale: 'Тебе нравится конструировать и решать практические задачи.',
    codes: ['R', 'I', 'E'],
  ),
  MajorMatch(
    major: 'Естественные науки',
    rationale: 'Исследования, эксперименты и открытия зажигают тебя.',
    codes: ['I', 'R', 'A'],
  ),
  MajorMatch(
    major: 'Медицина и здравоохранение',
    rationale: 'Сочетаешь интерес к науке с желанием помогать людям.',
    codes: ['I', 'S', 'R'],
  ),
  MajorMatch(
    major: 'Психология',
    rationale: 'Тебе интересны люди, их мотивы и поддержка других.',
    codes: ['S', 'I', 'A'],
  ),
  MajorMatch(
    major: 'Дизайн и медиа',
    rationale: 'Творчество и визуальное самовыражение — про тебя.',
    codes: ['A', 'I', 'E'],
  ),
  MajorMatch(
    major: 'Архитектура',
    rationale: 'Объединяешь творчество с расчётом и работой над формой.',
    codes: ['A', 'R', 'I'],
  ),
  MajorMatch(
    major: 'Педагогика и образование',
    rationale: 'Любишь объяснять, наставлять и развивать других.',
    codes: ['S', 'A', 'C'],
  ),
  MajorMatch(
    major: 'Социальная работа',
    rationale: 'Хочешь помогать тем, кому трудно, и менять жизни к лучшему.',
    codes: ['S', 'E', 'C'],
  ),
  MajorMatch(
    major: 'Бизнес и менеджмент',
    rationale: 'Тебе близки лидерство, организация и достижение целей.',
    codes: ['E', 'C', 'S'],
  ),
  MajorMatch(
    major: 'Экономика и финансы',
    rationale: 'Хорошо чувствуешь цифры, структуру и стратегию.',
    codes: ['C', 'E', 'I'],
  ),
  MajorMatch(
    major: 'Маркетинг и реклама',
    rationale: 'Сочетаешь креатив с умением убеждать и продвигать.',
    codes: ['E', 'A', 'S'],
  ),
  MajorMatch(
    major: 'Право и юриспруденция',
    rationale: 'Тебе важны порядок, аргументация и влияние на решения.',
    codes: ['E', 'C', 'S'],
  ),
];

/// Pure function: maps a 3-letter RIASEC [code] to a ranked list of
/// recommended majors. Earlier letters of the code weigh more, mirroring the
/// scoring used for clusters.
///
/// When [topValue] is supplied, majors whose profile aligns with that value
/// get a small bonus (e.g. "Помощь людям" boosts social majors), so a tie
/// between two equally fitting majors leans toward the user's motivation.
/// Ties are otherwise broken by catalogue order for determinism.
///
/// Returns at most [limit] majors, all with a positive match.
List<MajorMatch> matchMajors(
  String code, {
  ValueScale? topValue,
  int limit = 4,
}) {
  final letters = code.toUpperCase().split('');

  double scoreFor(MajorMatch m) {
    var s = 0.0;
    for (var i = 0; i < letters.length; i++) {
      if (m.codes.contains(letters[i])) {
        s += (letters.length - i).toDouble();
      }
    }
    if (topValue != null) {
      for (final letter in _valueAffinity[topValue] ?? const <String>[]) {
        if (m.codes.contains(letter)) {
          s += 0.5;
        }
      }
    }
    return s;
  }

  final ranked = kMajorCatalogue.toList()
    ..sort((a, b) {
      final cmp = scoreFor(b).compareTo(scoreFor(a));
      return cmp != 0
          ? cmp
          : kMajorCatalogue.indexOf(a).compareTo(kMajorCatalogue.indexOf(b));
    });
  return ranked.where((m) => scoreFor(m) > 0).take(limit).toList();
}

/// RIASEC letters most associated with each value scale, used as a tie-breaker
/// bonus inside [matchMajors].
const Map<ValueScale, List<String>> _valueAffinity = {
  ValueScale.achievement: ['E', 'C'],
  ValueScale.stability: ['C', 'R'],
  ValueScale.creativity: ['A', 'I'],
  ValueScale.helpingOthers: ['S'],
};
