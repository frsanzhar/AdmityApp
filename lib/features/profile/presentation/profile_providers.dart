import 'dart:async';

import 'package:admity/core/storage/local_store.dart';
import 'package:admity/features/profile/data/profile_repository.dart';
import 'package:admity/shared/models/profile.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Holds the student [Profile]. The local store is the offline source of truth
/// (synchronous reads); when signed in, every save also writes through to
/// Supabase, and [hydrate]/[clear] are driven by the auth-sync coordinator.
class ProfileController extends Notifier<Profile> {
  static const _key = 'profile';

  @override
  Profile build() {
    final json = ref.read(localStoreProvider).readJson(_key);
    return json == null ? const Profile() : Profile.fromJson(json);
  }

  void save(Profile profile) {
    state = profile;
    ref.read(localStoreProvider).put(_key, profile.toJson());
    unawaited(ref.read(profileRepositoryProvider).upsertProfile(profile));
  }

  void update(Profile Function(Profile current) transform) =>
      save(transform(state));

  /// Replaces local state + cache from a server-fetched profile (sign-in).
  void hydrate(Profile profile) {
    state = profile;
    ref.read(localStoreProvider).put(_key, profile.toJson());
  }

  /// Wipes the local profile on sign-out (privacy on shared devices); the
  /// server copy is the durable record and re-hydrates on the next sign-in.
  void clear() {
    state = const Profile();
    ref.read(localStoreProvider).remove(_key);
  }
}

final profileProvider =
    NotifierProvider<ProfileController, Profile>(ProfileController.new);

/// The student's private "interesting facts about me" notes (RLS-protected
/// when synced). Used by Eraly to find essay topics and project ideas.
class NotesController extends Notifier<List<String>> {
  static const _key = 'personal_notes';

  @override
  List<String> build() {
    final list = ref.read(localStoreProvider).readList(_key);
    return list == null ? const [] : list.map((e) => e as String).toList();
  }

  void add(String note) {
    if (note.trim().isEmpty) return;
    state = [...state, note.trim()];
    _persist();
  }

  void removeAt(int index) {
    final copy = [...state]..removeAt(index);
    state = copy;
    _persist();
  }

  /// Replaces local state + cache from server-fetched notes (sign-in).
  void hydrate(List<String> notes) {
    state = notes;
    ref.read(localStoreProvider).put(_key, notes);
  }

  /// Wipes local notes on sign-out (private data; re-hydrates on next sign-in).
  void clear() {
    state = const [];
    ref.read(localStoreProvider).remove(_key);
  }

  void _persist() {
    ref.read(localStoreProvider).put(_key, state);
    unawaited(ref.read(profileRepositoryProvider).replaceNotes(state));
  }
}

final notesProvider =
    NotifierProvider<NotesController, List<String>>(NotesController.new);
