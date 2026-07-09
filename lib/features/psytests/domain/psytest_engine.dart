/// Scoring engine and personality-summary builder for the psytests feature.
library;

import 'package:admity/features/psytests/data/psytests_seed.dart';
import 'package:admity/features/psytests/domain/psytest_models.dart';

/// Scores a completed test and returns a [PsyTestResult].
///
/// [selectedIndices] — index (0-based) of the option chosen for each question.
/// A `null` entry means the question was skipped; it contributes 0 to all
/// categories.  Length must equal `def.questions.length`.
PsyTestResult scoreTest(
  PsyTestDef def,
  List<int?> selectedIndices,
) {
  // Initialise scores to 0 for every known category.
  final scores = <String, int>{
    for (final key in def.categoryLabels.keys) key: 0,
  };

  for (var q = 0; q < def.questions.length; q++) {
    final idx = q < selectedIndices.length ? selectedIndices[q] : null;
    if (idx == null) continue;
    final opts = def.questions[q].options;
    if (idx < 0 || idx >= opts.length) continue;
    for (final entry in opts[idx].weights.entries) {
      scores[entry.key] = (scores[entry.key] ?? 0) + entry.value;
    }
  }

  // Top-2 categories by score (non-zero only for the second slot).
  final sorted = scores.entries.toList()
    ..sort((a, b) => b.value.compareTo(a.value));

  final top = <String>[];
  if (sorted.isNotEmpty) {
    top.add(sorted.first.key);
    if (sorted.length > 1 && sorted[1].value > 0) {
      top.add(sorted[1].key);
    }
  }

  return PsyTestResult(
    testId: def.id,
    completedAt: DateTime.now(),
    scores: scores,
    topCategories: top,
  );
}

/// Aggregates completed test results into a plain-text personality profile.
///
/// Designed to be passed to Eraly as part of the student's context.
/// Skips any result whose test id is not found in [psytestsDefs].
String buildPsytestsSummary(List<PsyTestResult> results) {
  if (results.isEmpty) return '';

  final buf = StringBuffer('Профиль личности студента:\n');

  for (final result in results) {
    final matching = psytestsDefs.where((d) => d.id == result.testId);
    if (matching.isEmpty) continue;
    final def = matching.first;

    if (result.topCategories.isEmpty) continue;

    final labels = result.topCategories
        .map((k) => def.categoryLabels[k] ?? k)
        .join(' + ');

    buf.write('• ${def.title}: $labels\n');
  }

  return buf.toString().trimRight();
}
