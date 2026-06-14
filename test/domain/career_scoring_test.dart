import 'package:admity/features/career_test/domain/career_items.dart';
import 'package:admity/features/career_test/domain/career_models.dart';
import 'package:admity/features/career_test/domain/career_scoring.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  // Item order: R,R,I,I,A,A,S,S,E,E,C,C.
  List<int> riasecFavoring(RiasecType type) => [
        for (final item in kRiasecItems) item.type == type ? 5 : 1,
      ];

  test('top interest drives the leading code letter', () {
    final result = CareerScoring.score(
      riasecAnswers: riasecFavoring(RiasecType.investigative),
      bigFiveAnswers: List.filled(kBigFiveItems.length, 3),
    );
    expect(result.riasecCode.startsWith('I'), isTrue);
    expect(result.recommendedClusters, isNotEmpty);
    expect(result.recommendedClusters.first.codes, contains('I'));
  });

  test('scores normalize to 0..1', () {
    final maxed = CareerScoring.score(
      riasecAnswers: List.filled(kRiasecItems.length, 5),
      bigFiveAnswers: List.filled(kBigFiveItems.length, 5),
    );
    for (final v in maxed.riasecScores.values) {
      expect(v, inInclusiveRange(0, 1));
    }
    expect(
      maxed.riasecScores[RiasecType.realistic],
      closeTo(1, 1e-9),
    );

    final minned = CareerScoring.score(
      riasecAnswers: List.filled(kRiasecItems.length, 1),
      bigFiveAnswers: List.filled(kBigFiveItems.length, 1),
    );
    expect(minned.riasecScores[RiasecType.realistic], closeTo(0, 1e-9));
  });

  test('Big Five reverse-keyed item is flipped', () {
    // The reverse item is "Я спокоен даже под давлением" (low neuroticism).
    // Answering 5 (agree) should LOWER neuroticism, not raise it.
    final calm = CareerScoring.score(
      riasecAnswers: List.filled(kRiasecItems.length, 3),
      bigFiveAnswers: [
        for (final item in kBigFiveItems)
          item.reverse ? 5 : (item.trait == BigFiveTrait.neuroticism ? 5 : 3),
      ],
    );
    // One direct neuroticism item at 5 and one reverse at 5 → net moderate.
    expect(
      calm.bigFive[BigFiveTrait.neuroticism],
      lessThan(0.75),
    );
  });

  test('determinism: same input → same code', () {
    final a = CareerScoring.score(
      riasecAnswers: riasecFavoring(RiasecType.social),
      bigFiveAnswers: List.filled(kBigFiveItems.length, 4),
    );
    final b = CareerScoring.score(
      riasecAnswers: riasecFavoring(RiasecType.social),
      bigFiveAnswers: List.filled(kBigFiveItems.length, 4),
    );
    expect(a.riasecCode, b.riasecCode);
  });
}
