import 'package:admity/core/storage/local_store.dart';
import 'package:admity/features/career_test/domain/career_items.dart';
import 'package:admity/features/career_test/domain/career_models.dart';
import 'package:admity/features/career_test/domain/career_scoring.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Holds the latest [CareerResult], derived from stored raw answers so it can
/// be recomputed deterministically on load.
class CareerController extends Notifier<CareerResult?> {
  static const _key = 'career_answers';

  @override
  CareerResult? build() {
    final json = ref.read(localStoreProvider).readJson(_key);
    if (json == null) return null;
    // Defensive: a legacy / partial / hand-edited store must degrade to "no
    // result", never throw inside the Notifier build.
    final riasecRaw = json['riasec'] as List<dynamic>?;
    final bigFiveRaw = json['big_five'] as List<dynamic>?;
    if (riasecRaw == null || bigFiveRaw == null) return null;
    if (riasecRaw.length != kRiasecItems.length ||
        bigFiveRaw.length != kBigFiveItems.length) {
      return null;
    }
    try {
      final riasec = riasecRaw.map((e) => (e as num).toInt()).toList();
      final bigFive = bigFiveRaw.map((e) => (e as num).toInt()).toList();
      return CareerScoring.score(
        riasecAnswers: riasec,
        bigFiveAnswers: bigFive,
      );
    } on Object {
      return null;
    }
  }

  /// Scores the test, stores the answers, and exposes the result.
  CareerResult submit({
    required List<int> riasecAnswers,
    required List<int> bigFiveAnswers,
  }) {
    final result = CareerScoring.score(
      riasecAnswers: riasecAnswers,
      bigFiveAnswers: bigFiveAnswers,
    );
    state = result;
    ref.read(localStoreProvider).put(_key, {
      'riasec': riasecAnswers,
      'big_five': bigFiveAnswers,
    });
    return result;
  }
}

final careerProvider =
    NotifierProvider<CareerController, CareerResult?>(CareerController.new);
