import 'package:admity/core/storage/local_store.dart';
import 'package:admity/features/intensives/data/intensives_seed.dart';
import 'package:admity/features/intensives/domain/intensive_engine.dart';
import 'package:admity/features/intensives/domain/intensive_models.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// All available intensive tracks (seed data).
final intensivesProvider = Provider<List<Intensive>>((ref) => kIntensivesSeed);

/// Looks up an intensive by slug.
final intensiveBySlugProvider = Provider.family<Intensive?, String>((ref, slug) {
  for (final i in ref.watch(intensivesProvider)) {
    if (i.slug == slug) return i;
  }
  return null;
});

/// Per-track progress, keyed by slug. Persisted locally.
class IntensiveProgressController
    extends Notifier<Map<String, IntensiveProgress>> {
  static const _key = 'intensive_progress';

  @override
  Map<String, IntensiveProgress> build() {
    final json = ref.read(localStoreProvider).readJson(_key);
    if (json == null) return {};
    return json.map(
      (slug, value) => MapEntry(
        slug,
        IntensiveProgress.fromJson(value as Map<String, dynamic>),
      ),
    );
  }

  IntensiveProgress progressFor(String slug) =>
      state[slug] ?? IntensiveProgress(intensiveSlug: slug);

  /// Completes a day and returns the outcome (drives mascot + UI feedback).
  IntensiveCompletion completeDay({
    required Intensive intensive,
    required int day,
    bool rubricPassed = true,
    DateTime? now,
  }) {
    final completion = IntensiveEngine.completeDay(
      progress: progressFor(intensive.slug),
      intensive: intensive,
      day: day,
      today: now ?? DateTime.now(),
      rubricPassed: rubricPassed,
    );
    if (completion.accepted) {
      state = {...state, intensive.slug: completion.progress};
      _persist();
    }
    return completion;
  }

  void _persist() => ref.read(localStoreProvider).put(
        _key,
        state.map((slug, p) => MapEntry(slug, p.toJson())),
      );
}

final intensiveProgressProvider =
    NotifierProvider<IntensiveProgressController, Map<String, IntensiveProgress>>(
  IntensiveProgressController.new,
);
