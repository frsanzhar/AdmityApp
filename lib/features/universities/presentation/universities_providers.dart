import 'dart:async';

import 'package:admity/core/storage/local_store.dart';
import 'package:admity/core/sync/student_sync_repository.dart';
import 'package:admity/features/universities/data/universities_seed.dart';
import 'package:admity/features/universities/domain/university.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Reference university catalogue (seed data; Supabase-backed later).
final Provider<List<University>> universitiesProvider =
    Provider<List<University>>((ref) => kUniversitiesSeed);

/// Free-text search query for the explorer.
class UniSearchController extends Notifier<String> {
  @override
  String build() => '';

  void setQuery(String query) => state = query;
}

final uniSearchProvider =
    NotifierProvider<UniSearchController, String>(UniSearchController.new);

/// Filtered universities by the current [uniSearchProvider].
final filteredUniversitiesProvider = Provider<List<University>>((ref) {
  final query = ref.watch(uniSearchProvider).trim().toLowerCase();
  final all = ref.watch(universitiesProvider);
  if (query.isEmpty) return all;
  return all
      .where(
        (u) =>
            u.name.toLowerCase().contains(query) ||
            u.country.toLowerCase().contains(query) ||
            u.programs.any((p) => p.toLowerCase().contains(query)),
      )
      .toList();
});

/// The student's college list (set of university slugs).
class CollegeListController extends Notifier<Set<String>> {
  static const _key = 'college_list';

  @override
  Set<String> build() {
    final list = ref.read(localStoreProvider).readList(_key);
    return list == null ? <String>{} : list.map((e) => e as String).toSet();
  }

  bool contains(String slug) => state.contains(slug);

  void toggle(String slug) {
    final copy = {...state};
    if (!copy.add(slug)) copy.remove(slug);
    state = copy;
    _persist();
  }

  /// Replaces local state + cache from a server-fetched list (sign-in/realtime).
  void hydrate(Set<String> slugs) {
    state = slugs;
    ref.read(localStoreProvider).put(_key, slugs.toList());
  }

  /// Wipes the local list on sign-out (server is durable).
  void clear() {
    state = <String>{};
    ref.read(localStoreProvider).remove(_key);
  }

  void _persist() {
    ref.read(localStoreProvider).put(_key, state.toList());
    unawaited(
      ref.read(studentSyncRepositoryProvider).replaceCollegeList(state),
    );
  }
}

final collegeListProvider =
    NotifierProvider<CollegeListController, Set<String>>(
  CollegeListController.new,
);
