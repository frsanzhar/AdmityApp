import 'package:admity/core/storage/local_store.dart';
import 'package:admity/features/chancing_world/data/cds_seed.dart';
import 'package:admity/features/chancing_world/domain/cds_models.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Reference Common Data Set snapshots (seed data; Supabase-backed later).
final cdsProvider = Provider<List<CdsSnapshot>>((ref) => kCdsSeed);

/// Looks up a snapshot by its university key.
final cdsByKeyProvider = Provider.family<CdsSnapshot?, String>((ref, key) {
  for (final s in ref.watch(cdsProvider)) {
    if (s.university == key) return s;
  }
  return null;
});

/// The student's self-reported SAT composite (400–1600), if any.
class SatScoreController extends Notifier<int?> {
  static const _key = 'sat_score';

  @override
  int? build() => (ref.read(localStoreProvider).readJson('test_scores')
      ?[_key] as num?)?.toInt();

  void save(int? sat) {
    state = sat;
    ref.read(localStoreProvider).put('test_scores', {_key: sat});
  }
}

final satScoreProvider =
    NotifierProvider<SatScoreController, int?>(SatScoreController.new);
