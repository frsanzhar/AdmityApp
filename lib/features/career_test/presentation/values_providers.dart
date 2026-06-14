import 'package:admity/core/storage/local_store.dart';
import 'package:admity/features/career_test/domain/values_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Holds the latest [ValuesResult] for the "Ценности и мотиваторы" mini-test,
/// derived from stored raw answers so it recomputes deterministically on load.
class ValuesController extends Notifier<ValuesResult?> {
  static const _key = 'values_answers';

  @override
  ValuesResult? build() {
    final raw = ref.read(localStoreProvider).readList(_key);
    if (raw == null || raw.length != kValueItems.length) return null;
    try {
      final answers = raw.map((e) => (e as num).toInt()).toList();
      return ValuesScoring.score(answers);
    } on Object {
      return null;
    }
  }

  /// Scores [answers] (1..5 Likert, aligned with [kValueItems]), persists them
  /// and exposes the result.
  ValuesResult submit(List<int> answers) {
    final result = ValuesScoring.score(answers);
    state = result;
    ref.read(localStoreProvider).put(_key, answers);
    return result;
  }
}

/// The current values-test result, or `null` until the test is taken.
final valuesProvider =
    NotifierProvider<ValuesController, ValuesResult?>(ValuesController.new);
