/// Riverpod providers backing the Материалы (study materials) tab.
library;

import 'package:admity/features/opportunities/data/study_material_repository.dart';
import 'package:admity/features/opportunities/domain/study_material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// ── Repository provider ───────────────────────────────────────────────────────

/// Provides a singleton [StudyMaterialRepository].
final studyMaterialRepositoryProvider = Provider<StudyMaterialRepository>(
  (_) => const StudyMaterialRepository(),
);

// ── Async data (pull-to-refresh) ──────────────────────────────────────────────

/// Loads and caches all study materials.
/// Exposes [refresh] for pull-to-refresh.
class StudyMaterialsNotifier extends AsyncNotifier<List<StudyMaterial>> {
  @override
  Future<List<StudyMaterial>> build() =>
      ref.read(studyMaterialRepositoryProvider).fetchAll();

  /// Re-fetches from the repository — used by pull-to-refresh.
  Future<void> refresh() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(
      () => ref.read(studyMaterialRepositoryProvider).fetchAll(),
    );
  }
}

/// Provides the raw list of study materials (or loading / error state).
final studyMaterialsProvider =
    AsyncNotifierProvider<StudyMaterialsNotifier, List<StudyMaterial>>(
      StudyMaterialsNotifier.new,
    );

// ── Filter state ──────────────────────────────────────────────────────────────

/// Active filter + sort settings for the Материалы tab.
class StudyMaterialsFilter {
  /// Creates a [StudyMaterialsFilter].
  const StudyMaterialsFilter({
    this.query = '',
    this.exam,
    this.major,
    this.newestFirst = true,
  });

  /// Free-text search query matched against title and description.
  final String query;

  /// Exam chip filter — null means «Все».
  final StudyMaterialExam? exam;

  /// Major chip filter — null means «Все».
  final String? major;

  /// When true, items are sorted newest → oldest; otherwise oldest → newest.
  final bool newestFirst;

  /// Whether any filter or search is currently active.
  bool get hasActiveFilter =>
      query.isNotEmpty || exam != null || major != null;

  /// Returns a copy with the specified fields replaced.
  StudyMaterialsFilter copyWith({
    String? query,
    StudyMaterialExam? exam,
    bool clearExam = false,
    String? major,
    bool clearMajor = false,
    bool? newestFirst,
  }) {
    return StudyMaterialsFilter(
      query: query ?? this.query,
      exam: clearExam ? null : (exam ?? this.exam),
      major: clearMajor ? null : (major ?? this.major),
      newestFirst: newestFirst ?? this.newestFirst,
    );
  }

  /// Returns a completely reset filter with all defaults.
  StudyMaterialsFilter cleared() => const StudyMaterialsFilter();
}

/// Manages the active [StudyMaterialsFilter].
class StudyMaterialsFilterNotifier extends Notifier<StudyMaterialsFilter> {
  @override
  StudyMaterialsFilter build() => const StudyMaterialsFilter();

  /// Updates the free-text search query.
  void setQuery(String q) => state = state.copyWith(query: q);

  /// Sets or clears the exam chip filter.
  void setExam(StudyMaterialExam? exam) =>
      state = state.copyWith(exam: exam, clearExam: exam == null);

  /// Sets or clears the major chip filter.
  void setMajor(String? major) =>
      state = state.copyWith(major: major, clearMajor: major == null);

  /// Flips the sort direction between newest-first and oldest-first.
  void toggleSort() =>
      state = state.copyWith(newestFirst: !state.newestFirst);

  /// Clears all filters and resets to defaults.
  void clearAll() => state = state.cleared();
}

/// Provides the active [StudyMaterialsFilter].
final studyMaterialsFilterProvider =
    NotifierProvider<StudyMaterialsFilterNotifier, StudyMaterialsFilter>(
      StudyMaterialsFilterNotifier.new,
    );

// ── Derived: filtered + sorted list ──────────────────────────────────────────

/// Applies [studyMaterialsFilterProvider] to the raw list from
/// [studyMaterialsProvider].  Returns an empty list while loading or on error.
final filteredStudyMaterialsProvider = Provider<List<StudyMaterial>>((ref) {
  final all =
      ref.watch(studyMaterialsProvider).value ?? const <StudyMaterial>[];
  final filter = ref.watch(studyMaterialsFilterProvider);

  var result = [...all];

  if (filter.query.isNotEmpty) {
    final lower = filter.query.toLowerCase();
    result = result
        .where(
          (m) =>
              m.title.toLowerCase().contains(lower) ||
              m.description.toLowerCase().contains(lower),
        )
        .toList();
  }

  if (filter.exam != null) {
    result = result.where((m) => m.exam == filter.exam).toList();
  }

  if (filter.major != null) {
    final majorLower = filter.major!.toLowerCase();
    result =
        result.where((m) => m.major?.toLowerCase() == majorLower).toList();
  }

  if (filter.newestFirst) {
    result.sort((a, b) => b.createdAt.compareTo(a.createdAt));
  } else {
    result.sort((a, b) => a.createdAt.compareTo(b.createdAt));
  }

  return result;
});

/// All unique major values present in the currently loaded materials.
/// Used to build the major filter chips dynamically.
final studyMaterialMajorsProvider = Provider<List<String>>((ref) {
  final all =
      ref.watch(studyMaterialsProvider).value ?? const <StudyMaterial>[];
  final seen = <String>{};
  for (final m in all) {
    if (m.major != null && m.major!.isNotEmpty) {
      seen.add(m.major!);
    }
  }
  return seen.toList()..sort();
});
