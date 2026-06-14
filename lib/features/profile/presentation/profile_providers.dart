import 'package:admity/core/storage/local_store.dart';
import 'package:admity/shared/models/profile.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Holds the student [Profile], persisted to the local store (and to Supabase
/// when connected).
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
  }

  void update(Profile Function(Profile current) transform) =>
      save(transform(state));
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

  void _persist() => ref.read(localStoreProvider).put(_key, state);
}

final notesProvider =
    NotifierProvider<NotesController, List<String>>(NotesController.new);
