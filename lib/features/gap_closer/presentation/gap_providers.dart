import 'dart:async';

import 'package:admity/core/storage/local_store.dart';
import 'package:admity/core/sync/student_sync_repository.dart';
import 'package:admity/features/career_test/presentation/career_providers.dart';
import 'package:admity/features/gap_closer/domain/gap_generator.dart';
import 'package:admity/features/gap_closer/domain/gap_task.dart';
import 'package:admity/features/profile/presentation/profile_providers.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// The student's gap tasks. Generated from profile + career result, then
/// editable (toggle done). Persisted locally.
class GapTasksController extends Notifier<List<GapTask>> {
  static const _key = 'gap_tasks';

  @override
  List<GapTask> build() {
    final list = ref.read(localStoreProvider).readList(_key);
    if (list == null) return const [];
    return list
        .map((e) => GapTask.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  /// (Re)generates tasks from the current profile, preserving done-state for
  /// tasks that still apply.
  void regenerate() {
    final profile = ref.read(profileProvider);
    final hasCareer = ref.read(careerProvider) != null;
    final generated = GapGenerator.generate(
      profile: profile,
      hasCareerResult: hasCareer,
    );
    // Preserve done-state AND the original deadline for tasks that still apply,
    // so a refresh doesn't silently re-date everything to "today + N".
    final existing = {for (final t in state) t.id: t};
    state = generated.map((t) {
      final old = existing[t.id];
      return old == null
          ? t
          : t.copyWith(isDone: old.isDone, dueDate: old.dueDate);
    }).toList();
    _persist();
  }

  void toggle(String id) {
    state = [
      for (final t in state)
        if (t.id == id) t.copyWith(isDone: !t.isDone) else t,
    ];
    _persist();
  }

  /// Replaces local state + cache from server-fetched tasks (sign-in/realtime).
  void hydrate(List<GapTask> tasks) {
    state = tasks;
    ref
        .read(localStoreProvider)
        .put(_key, tasks.map((t) => t.toJson()).toList());
  }

  /// Wipes local tasks on sign-out (server is durable).
  void clear() {
    state = const [];
    ref.read(localStoreProvider).remove(_key);
  }

  void _persist() {
    ref
        .read(localStoreProvider)
        .put(_key, state.map((t) => t.toJson()).toList());
    unawaited(ref.read(studentSyncRepositoryProvider).replaceGapTasks(state));
  }
}

final gapTasksProvider =
    NotifierProvider<GapTasksController, List<GapTask>>(GapTasksController.new);
