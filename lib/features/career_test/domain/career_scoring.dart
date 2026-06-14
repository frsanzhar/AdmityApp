import 'package:admity/features/career_test/domain/career_items.dart';
import 'package:admity/features/career_test/domain/career_models.dart';

/// Pure scoring for the career test. Deterministic and unit-tested.
abstract final class CareerScoring {
  /// Scores RIASEC + Big Five answers and derives the code + clusters.
  ///
  /// [riasecAnswers] and [bigFiveAnswers] are 1..5 Likert values aligned by
  /// index with [kRiasecItems] / [kBigFiveItems].
  static CareerResult score({
    required List<int> riasecAnswers,
    required List<int> bigFiveAnswers,
  }) {
    assert(
      riasecAnswers.length == kRiasecItems.length,
      'riasecAnswers must align with kRiasecItems',
    );
    assert(
      bigFiveAnswers.length == kBigFiveItems.length,
      'bigFiveAnswers must align with kBigFiveItems',
    );

    final riasec = _scoreRiasec(riasecAnswers);
    final bigFive = _scoreBigFive(bigFiveAnswers);
    final code = _codeFrom(riasec);
    final clusters = recommendClusters(code);

    return CareerResult(
      riasecScores: riasec,
      riasecCode: code,
      bigFive: bigFive,
      recommendedClusters: clusters,
    );
  }

  static Map<RiasecType, double> _scoreRiasec(List<int> answers) {
    final sums = {for (final t in RiasecType.values) t: 0};
    final counts = {for (final t in RiasecType.values) t: 0};
    for (var i = 0; i < kRiasecItems.length; i++) {
      final type = kRiasecItems[i].type;
      sums[type] = sums[type]! + answers[i];
      counts[type] = counts[type]! + 1;
    }
    // Normalize each type's average (1..5) to 0..1.
    return {
      for (final t in RiasecType.values)
        t: counts[t]! == 0 ? 0.0 : ((sums[t]! / counts[t]!) - 1) / 4,
    };
  }

  static Map<BigFiveTrait, double> _scoreBigFive(List<int> answers) {
    final sums = {for (final t in BigFiveTrait.values) t: 0.0};
    final counts = {for (final t in BigFiveTrait.values) t: 0};
    for (var i = 0; i < kBigFiveItems.length; i++) {
      final item = kBigFiveItems[i];
      final raw = item.reverse ? 6 - answers[i] : answers[i];
      sums[item.trait] = sums[item.trait]! + raw;
      counts[item.trait] = counts[item.trait]! + 1;
    }
    return {
      for (final t in BigFiveTrait.values)
        t: counts[t]! == 0 ? 0.0 : ((sums[t]! / counts[t]!) - 1) / 4,
    };
  }

  /// Three-letter RIASEC code from the top three types (ties broken by the
  /// canonical RIASEC order for determinism).
  static String _codeFrom(Map<RiasecType, double> scores) {
    final ordered = RiasecType.values.toList()
      ..sort((a, b) {
        final cmp = scores[b]!.compareTo(scores[a]!);
        return cmp != 0 ? cmp : a.index.compareTo(b.index);
      });
    return ordered.take(3).map((t) => t.letter).join();
  }

  /// Ranks clusters by overlap with the (ordered) RIASEC [code]. Earlier
  /// letters in the code weigh more.
  static List<MajorCluster> recommendClusters(String code, {int limit = 3}) {
    final letters = code.split('');
    double scoreFor(MajorCluster c) {
      var s = 0.0;
      for (var i = 0; i < letters.length; i++) {
        if (c.codes.contains(letters[i])) {
          s += (letters.length - i).toDouble();
        }
      }
      return s;
    }

    final ranked = kMajorClusters.toList()
      ..sort((a, b) {
        final cmp = scoreFor(b).compareTo(scoreFor(a));
        return cmp != 0
            ? cmp
            : kMajorClusters.indexOf(a).compareTo(kMajorClusters.indexOf(b));
      });
    return ranked.where((c) => scoreFor(c) > 0).take(limit).toList();
  }
}
