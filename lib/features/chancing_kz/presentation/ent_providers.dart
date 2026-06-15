import 'dart:async';

import 'package:admity/core/storage/local_store.dart';
import 'package:admity/core/sync/student_sync_repository.dart';
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
    unawaited(ref.read(studentSyncRepositoryProvider).upsertEnt(score));
  }

  /// Replaces local state + cache from a server-fetched score (sign-in/realtime).
  /// A null [score] means the server has no row → clear local.
  void hydrate(EntScore? score) {
    if (score == null) {
      clear();
      return;
    }
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
