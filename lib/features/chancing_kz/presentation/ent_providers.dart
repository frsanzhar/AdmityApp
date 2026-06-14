import 'package:admity/core/storage/local_store.dart';
import 'package:admity/features/chancing_kz/data/ent_cutoffs_seed.dart';
import 'package:admity/features/chancing_kz/domain/ent_models.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// The student's saved ЕНТ score (predicted or real).
class EntScoreController extends Notifier<EntScore?> {
  static const _key = 'ent_score';

  @override
  EntScore? build() {
    final json = ref.read(localStoreProvider).readJson(_key);
    return json == null ? null : EntScore.fromJson(json);
  }

  void save(EntScore score) {
    state = score;
    ref.read(localStoreProvider).put(_key, score.toJson());
  }

  void clear() {
    state = null;
    ref.read(localStoreProvider).remove(_key);
  }
}

final entScoreProvider =
    NotifierProvider<EntScoreController, EntScore?>(EntScoreController.new);

/// Reference ЕНТ cut-offs (seed data; Supabase-backed later).
final entCutoffsProvider =
    Provider<List<EntCutoff>>((ref) => kEntCutoffsSeed);
