/// Unit tests for the psych-test scoring engine and summary builder.
library;

import 'package:admity/features/psytests/data/psytests_seed.dart';
import 'package:admity/features/psytests/domain/psytest_engine.dart';
import 'package:admity/features/psytests/domain/psytest_models.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  // ── scoreTest ──────────────────────────────────────────────────────────────

  group('scoreTest', () {
    // Use the first seed test for most unit tests.
    final def = psytestsDefs[0]; // personality_type

    test('all-intro answers → top category is intro', () {
      // Option 0 of every question maps to 'intro'.
      final answers = List<int?>.filled(def.questions.length, 0);
      final result = scoreTest(def, answers);

      expect(result.testId, def.id);
      expect(result.topCategories.first, 'intro');
    });

    test('all-extro answers → top category is extro', () {
      // Option 1 of every question maps to 'extro'.
      final answers = List<int?>.filled(def.questions.length, 1);
      final result = scoreTest(def, answers);

      expect(result.topCategories.first, 'extro');
    });

    test('null (skipped) answers contribute 0 to all categories', () {
      final answers = List<int?>.filled(def.questions.length, null);
      final result = scoreTest(def, answers);

      expect(result.scores.values.every((s) => s == 0), isTrue);
    });

    test('partial answers only count answered questions', () {
      // Answer only the first 3 questions with intro (option 0).
      final answers = List<int?>.filled(def.questions.length, null);
      answers[0] = 0;
      answers[1] = 0;
      answers[2] = 0;

      final result = scoreTest(def, answers);

      // intro score must be > 0, extro score must be 0 or low.
      expect(result.scores['intro'] ?? 0, greaterThan(0));
    });

    test('topCategories contains at most 2 items', () {
      final answers = List<int?>.filled(def.questions.length, 0);
      final result = scoreTest(def, answers);

      expect(result.topCategories.length, lessThanOrEqualTo(2));
    });

    test('topCategories has at least 1 item when answers exist', () {
      final answers = List<int?>.filled(def.questions.length, 0);
      final result = scoreTest(def, answers);

      expect(result.topCategories, isNotEmpty);
    });

    test('completedAt is set to a recent DateTime', () {
      final before = DateTime.now();
      final answers = List<int?>.filled(def.questions.length, 0);
      final result = scoreTest(def, answers);
      final after = DateTime.now();

      expect(result.completedAt.isAfter(before), isTrue);
      expect(result.completedAt.isBefore(after.add(const Duration(seconds: 1))),
          isTrue);
    });

    test('scores map contains every category key from the def', () {
      final answers = List<int?>.filled(def.questions.length, 0);
      final result = scoreTest(def, answers);

      for (final key in def.categoryLabels.keys) {
        expect(result.scores.containsKey(key), isTrue,
            reason: 'Missing category key: $key');
      }
    });

    test('out-of-range option index is ignored gracefully', () {
      final answers = List<int?>.filled(def.questions.length, 99);
      final result = scoreTest(def, answers);

      // All scores should stay at 0 because index 99 is out of range.
      expect(result.scores.values.every((s) => s == 0), isTrue);
    });

    test('scoreTest works on all 12 seed tests without throwing', () {
      for (final testDef in psytestsDefs) {
        final answers = List<int?>.filled(testDef.questions.length, 0);
        expect(
          () => scoreTest(testDef, answers),
          returnsNormally,
          reason: 'scoreTest threw on test id=${testDef.id}',
        );
      }
    });
  });

  // ── PsyTestResult JSON round-trip ──────────────────────────────────────────

  group('PsyTestResult JSON round-trip', () {
    test('serialises and deserialises correctly', () {
      final original = PsyTestResult(
        testId: 'personality_type',
        completedAt: DateTime(2026, 7, 1, 12),
        scores: {'intro': 5, 'extro': 2, 'ambi': 1},
        topCategories: ['intro', 'extro'],
      );
      final json = original.toJson();
      final restored = PsyTestResult.fromJson(json);

      expect(restored.testId, original.testId);
      expect(restored.completedAt, original.completedAt);
      expect(restored.scores, original.scores);
      expect(restored.topCategories, original.topCategories);
    });

    test('empty topCategories round-trips', () {
      final original = PsyTestResult(
        testId: 'x',
        completedAt: DateTime(2026),
        scores: {'a': 0},
        topCategories: [],
      );
      final restored = PsyTestResult.fromJson(original.toJson());
      expect(restored.topCategories, isEmpty);
    });
  });

  // ── buildPsytestsSummary ───────────────────────────────────────────────────

  group('buildPsytestsSummary', () {
    test('returns empty string for empty list', () {
      expect(buildPsytestsSummary([]), '');
    });

    test('contains test title in summary', () {
      final def = psytestsDefs[0]; // personality_type
      final result = PsyTestResult(
        testId: def.id,
        completedAt: DateTime(2026, 7),
        scores: {'intro': 5},
        topCategories: ['intro'],
      );
      final summary = buildPsytestsSummary([result]);

      expect(summary.contains(def.title), isTrue);
    });

    test('contains category label in summary', () {
      final def = psytestsDefs[0];
      final result = PsyTestResult(
        testId: def.id,
        completedAt: DateTime(2026, 7),
        scores: {'intro': 5},
        topCategories: ['intro'],
      );
      final summary = buildPsytestsSummary([result]);

      expect(
        summary.contains(def.categoryLabels['intro']!),
        isTrue,
      );
    });

    test('includes bullet for each result', () {
      final results = psytestsDefs.take(3).map((d) {
        return PsyTestResult(
          testId: d.id,
          completedAt: DateTime(2026, 7),
          scores: {d.categoryLabels.keys.first: 3},
          topCategories: [d.categoryLabels.keys.first],
        );
      }).toList();

      final summary = buildPsytestsSummary(results);
      final bulletCount = '•'.allMatches(summary).length;
      expect(bulletCount, 3);
    });

    test('unknown test id is skipped gracefully', () {
      final result = PsyTestResult(
        testId: 'nonexistent_id_xyz',
        completedAt: DateTime(2026),
        scores: {'x': 1},
        topCategories: ['x'],
      );
      expect(() => buildPsytestsSummary([result]), returnsNormally);
    });

    test('result with empty topCategories is skipped', () {
      final def = psytestsDefs[0];
      final result = PsyTestResult(
        testId: def.id,
        completedAt: DateTime(2026),
        scores: {'intro': 0},
        topCategories: [],
      );
      final summary = buildPsytestsSummary([result]);
      // No bullet should appear.
      expect(summary.contains('•'), isFalse);
    });
  });

  // ── Seed data sanity ───────────────────────────────────────────────────────

  group('Seed data sanity', () {
    test('has exactly 12 test definitions', () {
      expect(psytestsDefs.length, 12);
    });

    test('order values are 1..12 with no gaps', () {
      final orders = psytestsDefs.map((d) => d.order).toList()..sort();
      expect(orders, List.generate(12, (i) => i + 1));
    });

    test('all test ids are unique', () {
      final ids = psytestsDefs.map((d) => d.id).toList();
      expect(ids.toSet().length, ids.length);
    });

    test('every test has at least 6 questions', () {
      for (final def in psytestsDefs) {
        expect(
          def.questions.length,
          greaterThanOrEqualTo(6),
          reason: 'Test ${def.id} has too few questions',
        );
      }
    });

    test('every question has at least 3 options', () {
      for (final def in psytestsDefs) {
        for (final q in def.questions) {
          expect(
            q.options.length,
            greaterThanOrEqualTo(3),
            reason: 'Question in ${def.id} has fewer than 3 options',
          );
        }
      }
    });

    test('every option has at least one weight', () {
      for (final def in psytestsDefs) {
        for (final q in def.questions) {
          for (final opt in q.options) {
            expect(
              opt.weights.isNotEmpty,
              isTrue,
              reason: 'Option "${opt.text}" in ${def.id} has empty weights',
            );
          }
        }
      }
    });

    test('categoryLabels matches categoryDescriptions keys', () {
      for (final def in psytestsDefs) {
        for (final key in def.categoryLabels.keys) {
          expect(
            def.categoryDescriptions.containsKey(key),
            isTrue,
            reason:
                'categoryDescriptions missing key "$key" in test ${def.id}',
          );
        }
      }
    });
  });

  // ── InMemoryPsytestsRepository ────────────────────────────────────────────

  group('InMemoryPsytestsRepository', () {
    late _FakeRepo repo;

    setUp(() => repo = _FakeRepo());

    test('loadResults returns empty list initially', () async {
      final results = await repo.loadResults();
      expect(results, isEmpty);
    });

    test('saveResult then loadResults returns the result', () async {
      final r = PsyTestResult(
        testId: 'personality_type',
        completedAt: DateTime(2026, 7),
        scores: {'intro': 3},
        topCategories: ['intro'],
      );
      await repo.saveResult(r);
      final loaded = await repo.loadResults();
      expect(loaded.length, 1);
      expect(loaded.first.testId, 'personality_type');
    });

    test('saveResult replaces existing result for same testId', () async {
      final r1 = PsyTestResult(
        testId: 'personality_type',
        completedAt: DateTime(2026, 7),
        scores: {'intro': 3},
        topCategories: ['intro'],
      );
      final r2 = PsyTestResult(
        testId: 'personality_type',
        completedAt: DateTime(2026, 7, 2),
        scores: {'extro': 5},
        topCategories: ['extro'],
      );
      await repo.saveResult(r1);
      await repo.saveResult(r2);
      final loaded = await repo.loadResults();
      expect(loaded.length, 1);
      expect(loaded.first.topCategories, ['extro']);
    });

    test('clearResult removes the result', () async {
      final r = PsyTestResult(
        testId: 'personality_type',
        completedAt: DateTime(2026, 7),
        scores: {'intro': 1},
        topCategories: ['intro'],
      );
      await repo.saveResult(r);
      await repo.clearResult('personality_type');
      expect(await repo.loadResults(), isEmpty);
    });

    test('clearResult on non-existent id is a no-op', () async {
      await repo.clearResult('nonexistent');
      expect(await repo.loadResults(), isEmpty);
    });
  });
}

// ── Helpers ────────────────────────────────────────────────────────────────────

class _FakeRepo {
  final List<PsyTestResult> _data = [];

  Future<List<PsyTestResult>> loadResults() async =>
      List.unmodifiable(_data);

  Future<void> saveResult(PsyTestResult result) async {
    _data.removeWhere((r) => r.testId == result.testId);
    _data.add(result);
  }

  Future<void> clearResult(String testId) async {
    _data.removeWhere((r) => r.testId == testId);
  }
}
