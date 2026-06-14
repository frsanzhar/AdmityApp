import 'package:admity/features/essay_review/domain/essay_models.dart';
import 'package:admity/features/essay_review/domain/rubric_scorer.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  int scoreOf(EssayFeedback f, RubricCriterion c) =>
      f.scores.firstWhere((s) => s.criterion == c).score;

  test('detects clichés and lowers the cliché-avoidance score', () {
    final f = LocalRubricScorer.score(
      'С самого детства я мечтал изменить мир и доказать, что тяжёлый труд '
      'всегда побеждает.',
      EssayKind.commonApp,
    );
    expect(scoreOf(f, RubricCriterion.clicheAvoidance), lessThan(4));
    expect(f.suggestions.any((s) => s.contains('клише')), isTrue);
  });

  test('flags going over the word limit', () {
    final longText = List.filled(1000, 'слово').join(' ');
    final f = LocalRubricScorer.score(longText, EssayKind.commonApp);
    expect(f.wordCount, 1000);
    expect(scoreOf(f, RubricCriterion.wordEconomy), lessThanOrEqualTo(1));
    expect(f.suggestions.any((s) => s.contains('Сократи')), isTrue);
  });

  test('rewards concrete, well-structured writing', () {
    final f = LocalRubricScorer.score(
      'Бабушка сказала: «Твоя машинка глупее моей».\n\n'
      'Я наклеил 12 меток на катушки и записал 3 названия её голосом.\n\n'
      'Через неделю машинка снова застучала, и я понял, как слушать людей.',
      EssayKind.commonApp,
    );
    expect(scoreOf(f, RubricCriterion.structure), greaterThanOrEqualTo(3));
    expect(scoreOf(f, RubricCriterion.concreteness), greaterThanOrEqualTo(3));
    expect(f.overall, isNotNull);
  });

  test('never returns a fabricated overall percentage', () {
    final f = LocalRubricScorer.score('Короткий текст.', EssayKind.motivationEu);
    expect(f.overall, isNot(contains('%')));
  });
}
