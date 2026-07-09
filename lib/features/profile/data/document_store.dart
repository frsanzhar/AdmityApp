/// DocumentStore — picks, saves, lists, deletes and shares attached files.
///
/// Files are copied into `<appDocumentsDir>/docs/` so they survive across
/// restarts and are excluded from iCloud backup by default (on iOS the
/// Documents directory is the correct location for user-generated files).
///
/// Persistence: the file-path list is kept on `StudentProfile.attachedDocs`
/// so that the single Hive box is the source of truth — no second store.
///
/// All methods swallow errors via `debugPrint`; callers receive null / false /
/// empty list on failure, never an uncaught exception.
library;

import 'dart:io';

import 'package:admity/features/profile/application/profile_notifier.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:open_filex/open_filex.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';

// ── Provider ──────────────────────────────────────────────────────────────────

/// Scoped [DocumentStore] — reads and writes via [profileProvider].
final documentStoreProvider = Provider<DocumentStore>(DocumentStore.new);

// ── DocumentStore ─────────────────────────────────────────────────────────────

/// Manages file attachments that live in the app-documents directory.
///
/// The list of saved paths is persisted on `StudentProfile.attachedDocs`
/// through [profileProvider].
class DocumentStore {
  /// Creates a [DocumentStore] that reads and writes [profileProvider].
  DocumentStore(this._ref);

  final Ref _ref;

  // ── Private helpers ───────────────────────────────────────────────────────

  /// Returns the `docs/` sub-directory inside the app documents folder,
  /// creating it if necessary.
  Future<Directory?> _docsDir() async {
    try {
      final base = await getApplicationDocumentsDirectory();
      final dir = Directory('${base.path}/docs');
      if (!dir.existsSync()) {
        await dir.create(recursive: true);
      }
      return dir;
    } on Object catch (e) {
      debugPrint('[DocumentStore] _docsDir error: $e');
      return null;
    }
  }

  /// Extracts the filename from an absolute file path.
  String _basename(String path) {
    final parts = path.replaceAll(r'\', '/').split('/');
    return parts.isNotEmpty ? parts.last : path;
  }

  /// Persists [paths] to `StudentProfile.attachedDocs`.
  Future<void> _persist(List<String> paths) async {
    final profile = _ref.read(profileProvider).profile;
    await _ref
        .read(profileProvider.notifier)
        .saveProfile(profile.copyWith(attachedDocs: paths));
  }

  // ── Public surface ────────────────────────────────────────────────────────

  /// Opens the system file picker, copies the chosen file into the app docs
  /// directory, appends the saved path to `StudentProfile.attachedDocs`, and
  /// returns the saved path.
  ///
  /// Returns `null` if the user cancelled, or if any step fails.
  Future<String?> pickAndSave() async {
    FilePickerResult? result;
    try {
      result = await FilePicker.platform.pickFiles();
    } on Object catch (e) {
      debugPrint('[DocumentStore] pickFiles error: $e');
      return null;
    }

    if (result == null || result.files.isEmpty) return null;
    final sourceFile = result.files.first;
    final sourcePath = sourceFile.path;
    if (sourcePath == null) return null;

    final dir = await _docsDir();
    if (dir == null) return null;

    try {
      // Build a unique destination name to avoid collisions.
      final name = _basename(sourcePath);
      final stamp = DateTime.now().millisecondsSinceEpoch;
      final destPath = '${dir.path}/${stamp}_$name';

      await File(sourcePath).copy(destPath);

      // Append to the persisted list.
      final updated = [...list(), destPath];
      await _persist(updated);

      return destPath;
    } on Object catch (e) {
      debugPrint('[DocumentStore] copy / persist error: $e');
      return null;
    }
  }

  /// Returns the current list of saved file paths from `StudentProfile.attachedDocs`.
  List<String> list() {
    return _ref.read(profileProvider).profile.attachedDocs;
  }

  /// Deletes the file at [path] from disk and removes it from the persisted list.
  ///
  /// Swallows errors — a path that no longer exists on disk is still removed
  /// from the list so the UI stays consistent.
  Future<void> delete(String path) async {
    // Remove from list first so UI updates even if the file delete fails.
    final updated = list().where((e) => e != path).toList();
    await _persist(updated);

    try {
      final file = File(path);
      if (file.existsSync()) {
        await file.delete();
      }
    } on Object catch (e) {
      debugPrint('[DocumentStore] delete error: $e');
    }
  }

  /// Opens the file at [path] inside the app using the platform's native
  /// document preview (Quick Look on iOS, the default viewer on Android).
  ///
  /// Returns `null` on success, or a human-readable Russian error message when
  /// the file can't be opened (missing, no viewer, denied). Never throws.
  Future<String?> open(String path) async {
    try {
      if (!File(path).existsSync()) {
        return 'Файл не найден — возможно, он был удалён.';
      }
      final result = await OpenFilex.open(path);
      switch (result.type) {
        case ResultType.done:
          return null;
        case ResultType.noAppToOpen:
          return 'Нет приложения для открытия этого типа файла.';
        case ResultType.permissionDenied:
          return 'Нет доступа к файлу.';
        case ResultType.fileNotFound:
          return 'Файл не найден.';
        case ResultType.error:
          return 'Не удалось открыть файл.';
      }
    } on Object catch (e) {
      debugPrint('[DocumentStore] open error: $e');
      return 'Не удалось открыть файл.';
    }
  }

  /// Shares the file at [path] via the system share sheet.
  ///
  /// On iOS/Android this opens the native share-to-app sheet, which lets the
  /// student open the file in any compatible app (Files, Adobe, etc.).
  /// Swallows errors silently.
  Future<void> share(String path) async {
    try {
      await Share.shareXFiles([XFile(path)]);
    } on Object catch (e) {
      debugPrint('[DocumentStore] share error: $e');
    }
  }
}
