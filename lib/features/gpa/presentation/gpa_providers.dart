import 'package:admity/core/storage/local_store.dart';
import 'package:admity/features/gpa/domain/gpa_calculator.dart';
import 'package:admity/features/gpa/domain/gpa_models.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Holds the editable GPA subjects table, persisted to the local store under
/// the `gpa_subjects` key. Exposes add/remove/update; the live GPAs are read
/// from [gpaResultProvider].
class GpaSubjectsController extends Notifier<List<Subject>> {
  static const _key = 'gpa_subjects';

  @override
  List<Subject> build() {
    final list = ref.read(localStoreProvider).readList(_key);
    if (list == null) return const [];
    return list
        .map((e) => Subject.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  /// Appends a new subject row and persists.
  void add(Subject subject) {
    state = [...state, subject];
    _persist();
  }

  /// Removes the subject with [id] and persists.
  void remove(String id) {
    state = [
      for (final s in state)
        if (s.id != id) s,
    ];
    _persist();
  }

  /// Replaces the subject sharing [updated]'s id in place and persists.
  void update(Subject updated) {
    state = [
      for (final s in state)
        if (s.id == updated.id) updated else s,
    ];
    _persist();
  }

  void _persist() => ref
      .read(localStoreProvider)
      .put(_key, state.map((s) => s.toJson()).toList());
}

/// The GPA subjects table.
final gpaSubjectsProvider =
    NotifierProvider<GpaSubjectsController, List<Subject>>(
  GpaSubjectsController.new,
);

/// Live-computed GPA on both scales, derived from [gpaSubjectsProvider].
final gpaResultProvider = Provider<GpaResult>((ref) {
  final subjects = ref.watch(gpaSubjectsProvider);
  return GpaCalculator.compute(subjects);
});

/// Holds the file path of an optional report-card photo the student attached,
/// persisted under the `gpa_report_photo` key. `null` when none is set.
class GpaReportPhotoController extends Notifier<String?> {
  static const _key = 'gpa_report_photo';

  @override
  String? build() {
    final json = ref.read(localStoreProvider).readJson(_key);
    return json?['path'] as String?;
  }

  /// Stores the report-card photo at [path] (or clears it when `null`).
  void setPath(String? path) {
    state = path;
    if (path == null) {
      ref.read(localStoreProvider).remove(_key);
    } else {
      ref.read(localStoreProvider).put(_key, {'path': path});
    }
  }
}

/// The attached report-card photo path, or `null`.
final gpaReportPhotoProvider =
    NotifierProvider<GpaReportPhotoController, String?>(
  GpaReportPhotoController.new,
);
