import 'dart:async';

import 'package:admity/core/storage/local_store.dart';
import 'package:admity/core/sync/student_sync_repository.dart';
import 'package:admity/features/essay_review/domain/essay_models.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Persisted essay drafts + their latest rubric feedback, keyed by [EssayKind].
/// Previously the essay screen kept everything in widget state (lost on pop);
/// this caches locally and, when signed in, syncs to the `essays` table.
class EssaysController extends Notifier<Map<EssayKind, EssayRecord>> {
  static const _key = 'essays';

  @override
  Map<EssayKind, EssayRecord> build() {
    final json = ref.read(localStoreProvider).readJson(_key);
    if (json == null) return {};
    final out = <EssayKind, EssayRecord>{};
    json.forEach((_, value) {
      if (value is Map<String, dynamic>) {
        final rec = EssayRecord.tryFromJson(value);
        if (rec != null) out[rec.kind] = rec;
      }
    });
    return out;
  }

  /// The saved record for [kind], or null.
  EssayRecord? forKind(EssayKind kind) => state[kind];

  /// Stores a draft + its freshly-scored feedback.
  void saveFeedback(EssayKind kind, String draftText, EssayFeedback feedback) {
    _upsert(
      EssayRecord(
        kind: kind,
        draftText: draftText,
        feedback: feedback,
        updatedAt: DateTime.now(),
      ),
    );
  }

  /// Stores just the draft text (preserving any existing feedback).
  void saveDraft(EssayKind kind, String draftText) {
    _upsert(
      EssayRecord(
        kind: kind,
        draftText: draftText,
        feedback: state[kind]?.feedback,
        updatedAt: DateTime.now(),
      ),
    );
  }

  /// Replaces local state + cache from server-fetched records (sign-in/realtime).
  void hydrate(Map<EssayKind, EssayRecord> records) {
    state = records;
    _persist();
  }

  /// Wipes local drafts on sign-out (server is durable).
  void clear() {
    state = {};
    ref.read(localStoreProvider).remove(_key);
  }

  void _upsert(EssayRecord rec) {
    state = {...state, rec.kind: rec};
    _persist();
    unawaited(ref.read(studentSyncRepositoryProvider).upsertEssay(rec));
  }

  void _persist() {
    ref.read(localStoreProvider).put(_key, {
      for (final e in state.entries) e.key.name: e.value.toJson(),
    });
  }
}

final essaysProvider =
    NotifierProvider<EssaysController, Map<EssayKind, EssayRecord>>(
  EssaysController.new,
);
