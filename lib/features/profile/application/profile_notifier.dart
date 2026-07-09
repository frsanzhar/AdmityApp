/// Profile state management — plain Riverpod (no codegen, CLAUDE.md §1).
library;

import 'package:admity/features/profile/data/profile_repository.dart';
import 'package:admity/features/profile/domain/profile_model.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// ── Provider (repository) ─────────────────────────────────────────────────────

/// The single [ProfileRepository] used by the app.
///
/// Override in tests with [InMemoryProfileRepository]:
/// ```dart
/// ProviderScope(
///   overrides: [
///     profileRepositoryProvider.overrideWithValue(InMemoryProfileRepository()),
///   ],
///   child: MyApp(),
/// );
/// ```
final profileRepositoryProvider = Provider<ProfileRepository>(
  (_) => const HiveProfileRepository(),
);

// ── State ─────────────────────────────────────────────────────────────────────

/// Immutable view of all profile data.
class ProfileState {
  const ProfileState({
    this.profile = StudentProfile.empty,
    this.notes = const [],
    this.packages = const [],
    this.isLoading = false,
    this.isSaving = false,
    this.errorMessage,
  });

  final StudentProfile profile;
  final List<ProfileNote> notes;
  final List<DocumentPackage> packages;
  final bool isLoading;
  final bool isSaving;
  final String? errorMessage;

  ProfileState copyWith({
    StudentProfile? profile,
    List<ProfileNote>? notes,
    List<DocumentPackage>? packages,
    bool? isLoading,
    bool? isSaving,
    String? errorMessage,
  }) {
    return ProfileState(
      profile: profile ?? this.profile,
      notes: notes ?? this.notes,
      packages: packages ?? this.packages,
      isLoading: isLoading ?? this.isLoading,
      isSaving: isSaving ?? this.isSaving,
      errorMessage: errorMessage,
    );
  }
}

// ── Notifier ──────────────────────────────────────────────────────────────────

/// Manages all profile operations against [ProfileRepository].
class ProfileNotifier extends Notifier<ProfileState> {
  @override
  ProfileState build() {
    // Kick off loading immediately; build() must be synchronous.
    // unawaited: intentional fire-and-forget inside a sync build().
    // ignore: discarded_futures
    Future.microtask(_load);
    return const ProfileState(isLoading: true);
  }

  ProfileRepository get _repo => ref.read(profileRepositoryProvider);

  // ── Load ──────────────────────────────────────────────────────────────────

  Future<void> _load() async {
    if (!ref.mounted) return;
    state = state.copyWith(isLoading: true);
    try {
      final results = await Future.wait([
        _repo.loadProfile(),
        _repo.loadNotes(),
        _repo.loadPackages(),
      ]);
      if (!ref.mounted) return;
      state = state.copyWith(
        profile: results[0] as StudentProfile,
        notes: results[1] as List<ProfileNote>,
        packages: results[2] as List<DocumentPackage>,
        isLoading: false,
      );
    } on Object catch (e) {
      if (!ref.mounted) return;
      state = state.copyWith(
        isLoading: false,
        errorMessage: 'Ошибка загрузки: $e',
      );
    }
  }

  // ── Profile CRUD ──────────────────────────────────────────────────────────

  Future<void> saveProfile(StudentProfile profile) async {
    state = state.copyWith(isSaving: true);
    try {
      await _repo.saveProfile(profile);
      state = state.copyWith(profile: profile, isSaving: false);
    } on Object catch (e) {
      state = state.copyWith(
        isSaving: false,
        errorMessage: 'Ошибка сохранения: $e',
      );
    }
  }

  // ── Notes CRUD ────────────────────────────────────────────────────────────

  Future<void> addNote(String text) async {
    final note = ProfileNote(
      id: 'note_${DateTime.now().millisecondsSinceEpoch}',
      text: text.trim(),
      createdAt: DateTime.now(),
    );
    await _repo.saveNote(note);
    state = state.copyWith(notes: [note, ...state.notes]);
  }

  Future<void> editNote(String noteId, String newText) async {
    final idx = state.notes.indexWhere((n) => n.id == noteId);
    if (idx < 0) return;
    final updated = state.notes[idx].copyWith(
      text: newText.trim(),
      updatedAt: DateTime.now(),
    );
    await _repo.saveNote(updated);
    final newList = [...state.notes];
    newList[idx] = updated;
    state = state.copyWith(notes: newList);
  }

  Future<void> deleteNote(String noteId) async {
    await _repo.deleteNote(noteId);
    state = state.copyWith(
      notes: state.notes.where((n) => n.id != noteId).toList(),
    );
  }

  // ── Document packages CRUD ────────────────────────────────────────────────

  Future<void> addPackage({required String name, String? description}) async {
    final pkg = DocumentPackage(
      id: 'pkg_${DateTime.now().millisecondsSinceEpoch}',
      name: name.trim(),
      description: description?.trim(),
      createdAt: DateTime.now(),
    );
    await _repo.savePackage(pkg);
    state = state.copyWith(packages: [pkg, ...state.packages]);
  }

  Future<void> deletePackage(String packageId) async {
    await _repo.deletePackage(packageId);
    state = state.copyWith(
      packages: state.packages.where((p) => p.id != packageId).toList(),
    );
  }

  Future<void> addItemToPackage({
    required String packageId,
    required String label,
  }) async {
    final idx = state.packages.indexWhere((p) => p.id == packageId);
    if (idx < 0) return;
    final pkg = state.packages[idx];
    final item = DocumentItem(
      id: 'item_${DateTime.now().millisecondsSinceEpoch}',
      label: label.trim(),
    );
    final updated = pkg.copyWith(items: [...pkg.items, item]);
    await _repo.savePackage(updated);
    final newList = [...state.packages];
    newList[idx] = updated;
    state = state.copyWith(packages: newList);
  }

  /// Adds an already-saved file (an existing local [filePath]) to [packageId]
  /// as a new, already-attached document item.
  ///
  /// Used by the "Добавить документ" flow when the student picks a file from
  /// "Мои документы" or uploads a new one. No-op if the package is gone.
  Future<void> addExistingDocToPackage({
    required String packageId,
    required String filePath,
    required String label,
  }) async {
    final idx = state.packages.indexWhere((p) => p.id == packageId);
    if (idx < 0) return;
    final pkg = state.packages[idx];
    final item = DocumentItem(
      id: 'item_${DateTime.now().millisecondsSinceEpoch}',
      label: label.trim().isEmpty ? 'Документ' : label.trim(),
      filePath: filePath,
      isAttached: true,
    );
    final updated = pkg.copyWith(items: [...pkg.items, item]);
    await _repo.savePackage(updated);
    final newList = [...state.packages];
    newList[idx] = updated;
    state = state.copyWith(packages: newList);
  }

  Future<void> removeItemFromPackage({
    required String packageId,
    required String itemId,
  }) async {
    final idx = state.packages.indexWhere((p) => p.id == packageId);
    if (idx < 0) return;
    final pkg = state.packages[idx];
    final updated = pkg.copyWith(
      items: pkg.items.where((i) => i.id != itemId).toList(),
    );
    await _repo.savePackage(updated);
    final newList = [...state.packages];
    newList[idx] = updated;
    state = state.copyWith(packages: newList);
  }

  Future<void> toggleDocumentItem({
    required String packageId,
    required String itemId,
  }) async {
    final idx = state.packages.indexWhere((p) => p.id == packageId);
    if (idx < 0) return;
    final pkg = state.packages[idx];
    final itemIdx = pkg.items.indexWhere((i) => i.id == itemId);
    if (itemIdx < 0) return;
    final item = pkg.items[itemIdx];
    final updatedItems = [...pkg.items];
    updatedItems[itemIdx] = item.copyWith(isAttached: !item.isAttached);
    final updated = pkg.copyWith(items: updatedItems);
    await _repo.savePackage(updated);
    final newList = [...state.packages];
    newList[idx] = updated;
    state = state.copyWith(packages: newList);
  }

  /// Opens the system file picker and attaches the chosen file to the given
  /// [DocumentItem].  Stores the local path on the item and marks it attached.
  ///
  /// Returns true if a file was picked, false if the user cancelled.
  Future<bool> attachFileToItem({
    required String packageId,
    required String itemId,
  }) async {
    FilePickerResult? result;
    try {
      result = await FilePicker.platform.pickFiles();
    } on Object catch (e) {
      debugPrint('[ProfileNotifier] attachFileToItem pickFiles error: $e');
      return false;
    }
    if (result == null || result.files.isEmpty) return false;

    final file = result.files.first;
    final path = file.path;
    if (path == null) return false;

    final pkgIdx = state.packages.indexWhere((p) => p.id == packageId);
    if (pkgIdx < 0) return false;
    final pkg = state.packages[pkgIdx];
    final itemIdx = pkg.items.indexWhere((i) => i.id == itemId);
    if (itemIdx < 0) return false;

    final updatedItems = [...pkg.items];
    updatedItems[itemIdx] = pkg.items[itemIdx].copyWith(
      filePath: path,
      isAttached: true,
    );
    final updatedPkg = pkg.copyWith(items: updatedItems);
    await _repo.savePackage(updatedPkg);

    final newList = [...state.packages];
    newList[pkgIdx] = updatedPkg;
    state = state.copyWith(packages: newList);
    return true;
  }

  /// Seeds the standard KZ university-admission document package if no packages
  /// exist yet.  Safe to call multiple times — is a no-op once seeded.
  Future<void> ensureDefaultPackageSeeded() async {
    // Wait until loading is complete before checking.
    if (state.isLoading) {
      await Future<void>.delayed(const Duration(milliseconds: 50));
    }
    if (state.packages.isNotEmpty) return;

    await addPackage(
      name: 'Стандартный пакет КЗ',
      description: 'Типовой набор документов для поступления в вузы Казахстана',
    );

    final pkgs = state.packages;
    if (pkgs.isEmpty) return;
    final pkgId = pkgs.first.id;

    const defaultItems = [
      'Удостоверение личности / Свидетельство о рождении',
      'Аттестат / Транскрипт оценок',
      'Медицинская справка 086-У',
      'Фотографии 3×4 (6 шт.)',
      'Сертификат ЕНТ / ЕГЭ',
      'Сертификат IELTS / TOEFL / SAT (при наличии)',
      'Мотивационное письмо',
      'Рекомендательные письма (2 шт.)',
      'Заявление о поступлении',
      'Согласие родителей (для несовершеннолетних)',
    ];

    for (final label in defaultItems) {
      await addItemToPackage(packageId: pkgId, label: label);
    }
  }
}

// ── Public provider ───────────────────────────────────────────────────────────

final profileProvider = NotifierProvider<ProfileNotifier, ProfileState>(
  ProfileNotifier.new,
);
