import 'package:admity/features/chancing_kz/domain/ent_chancing.dart';
import 'package:admity/features/chancing_kz/domain/ent_models.dart';
import 'package:admity/shared/models/chance_category.dart';
import 'package:flutter_test/flutter_test.dart';

EntScore scoreWith({
  int history = 18,
  int math = 9,
  int reading = 9,
  int p1 = 45,
  int p2 = 45,
}) =>
    EntScore(
      history: history,
      mathLiteracy: math,
      readingLiteracy: reading,
      profile1Subject: 'Биология',
      profile1Score: p1,
      profile2Subject: 'Химия',
      profile2Score: p2,
    );

void main() {
  group('EntChancing — КазНМУ Общая медицина (gov 70, real 124)', () {
    test('comfortably above cut-off → safe', () {
      final r = EntChancing.evaluate(
        score: scoreWith(p1: 48, p2: 47), // total 131
        govThreshold: 70,
        realCutoff: 124,
      );
      expect(r.total, 131);
      expect(r.category, KzChance.safe);
    });

    test('exactly at cut-off → at-risk (cut-offs move year to year)', () {
      final r = EntChancing.evaluate(
        score: scoreWith(p1: 44, p2: 44), // total 124
        govThreshold: 70,
        realCutoff: 124,
      );
      expect(r.category, KzChance.atRisk);
    });

    test('above gov threshold but below cut-off → at-risk', () {
      final r = EntChancing.evaluate(
        score: scoreWith(history: 15, math: 8, reading: 8, p1: 35, p2: 34),
        govThreshold: 70,
        realCutoff: 124,
      );
      expect(r.total, 100);
      expect(r.category, KzChance.atRisk);
    });

    test('below gov threshold → belowThreshold', () {
      final r = EntChancing.evaluate(
        score: scoreWith(history: 12, math: 6, reading: 6, p1: 18, p2: 18),
        govThreshold: 70,
        realCutoff: 124,
      );
      expect(r.total, 60);
      expect(r.category, KzChance.belowThreshold);
    });
  });

  test('failing a per-subject minimum forces belowThreshold', () {
    final r = EntChancing.evaluate(
      score: scoreWith(p1: 4), // profile subject < 5
      govThreshold: 50,
    );
    expect(r.meetsSubjectMinimums, isFalse);
    expect(r.category, KzChance.belowThreshold);
  });

  group('No real cut-off data', () {
    test('well above threshold → safe', () {
      final r = EntChancing.evaluate(
        score: scoreWith(p1: 30, p2: 30), // total 96 vs gov 50
        govThreshold: 50,
      );
      expect(r.category, KzChance.safe);
    });

    test('just above threshold → at-risk', () {
      final r = EntChancing.evaluate(
        score: scoreWith(history: 10, math: 6, reading: 6, p1: 16, p2: 16),
        govThreshold: 50, // total 54, within +12 margin
      );
      expect(r.total, 54);
      expect(r.category, KzChance.atRisk);
    });
  });
}
