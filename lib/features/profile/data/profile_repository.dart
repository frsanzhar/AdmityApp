/// ProfileRepository — local-first storage seam for profile data.
///
/// Storage choice: Hive raw boxes (no TypeAdapters, no codegen) with manual
/// JSON Map to/from model mapping.
///
/// Codegen resolution check (Flutter 3.41.6 / Dart 3.11.4):
///   hive_generator FAILS: `dart pub add hive_generator build_runner --dry-run`
///   produces dependency-conflict errors (analyzer/meta pin clash — same root
///   cause as riverpod_generator and drift_dev, see CLAUDE.md §1).
///   hive 2.2.3 + hive_flutter 1.1.0 (raw, codegen-free) resolve cleanly.
///   Fallback: plain Map stored in a Hive Box as a JSON string; models
///   encode/decode via toJson() / fromJson().
///
/// Architecture:
///   [ProfileRepository] — abstract interface, tested against
///   [InMemoryProfileRepository] (no device path needed in tests).
///   [HiveProfileRepository] — production implementation.
///   Supabase sync: clean seam with TODO(sync) markers — not required now.
library;

import 'dart:convert';

import 'package:admity/features/profile/domain/profile_model.dart';
import 'package:flutter/foundation.dart';
import 'package:hive_flutter/hive_flutter.dart';

// ── Abstract interface ────────────────────────────────────────────────────────

/// Contract for profile persistence.
///
/// Both [HiveProfileRepository] (production) and [InMemoryProfileRepository]
/// (tests) implement this. Callers only depend on this interface, never the
/// concrete type — injected via the provider.
abstract class ProfileRepository {
  // ── Profile ───────────────────────────────────────────────────────────────

  Future<StudentProfile> loadProfile();
  Future<void> saveProfile(StudentProfile profile);

  // ── Notes ─────────────────────────────────────────────────────────────────

  Future<List<ProfileNote>> loadNotes();
  Future<void> saveNote(ProfileNote note);
  Future<void> deleteNote(String noteId);

  // ── Document packages ─────────────────────────────────────────────────────

  Future<List<DocumentPackage>> loadPackages();
  Future<void> savePackage(DocumentPackage pkg);
  Future<void> deletePackage(String packageId);
}

// ── Hive implementation (production) ─────────────────────────────────────────

/// Hive-backed [ProfileRepository].
///
/// Uses raw Hive Box of String — each entry is a JSON-encoded string.
/// No TypeAdapters, no codegen (hive_generator fails on this SDK).
class HiveProfileRepository implements ProfileRepository {
  const HiveProfileRepository();

  // Box names — short, versioned by key prefix if needed later.
  static const _profileBox = 'admity_profile';
  static const _notesBox = 'admity_notes';
  static const _packagesBox = 'admity_packages';
  static const _profileKey = '__profile__';

  // ── Init ──────────────────────────────────────────────────────────────────

  /// Initialises Hive with a path derived from path_provider.
  ///
  /// Must be called once at app startup, before any repository method.
  static Future<void> init() async {
    await Hive.initFlutter();
    await Hive.openBox<String>(_profileBox);
    await Hive.openBox<String>(_notesBox);
    await Hive.openBox<String>(_packagesBox);
  }

  // ── Helpers ───────────────────────────────────────────────────────────────

  Box<String> get _profile => Hive.box<String>(_profileBox);
  Box<String> get _notes => Hive.box<String>(_notesBox);
  Box<String> get _packages => Hive.box<String>(_packagesBox);

  static Map<String, dynamic> _decode(String raw) {
    final decoded = json.decode(raw);
    if (decoded is Map<String, dynamic>) return decoded;
    return <String, dynamic>{};
  }

  // ── ProfileRepository implementation ─────────────────────────────────────

  @override
  Future<StudentProfile> loadProfile() async {
    final raw = _profile.get(_profileKey);
    if (raw == null) return StudentProfile.empty;
    try {
      return StudentProfile.fromJson(_decode(raw));
    } on Object catch (e) {
      debugPrint('[ProfileRepository] loadProfile error: $e');
      return StudentProfile.empty;
    }
  }

  @override
  Future<void> saveProfile(StudentProfile profile) async {
    await _profile.put(_profileKey, json.encode(profile.toJson()));
    // TODO(sync): push to Supabase when online sync is implemented
  }

  @override
  Future<List<ProfileNote>> loadNotes() async {
    final out = <ProfileNote>[];
    for (final raw in _notes.values) {
      try {
        out.add(ProfileNote.fromJson(_decode(raw)));
      } on Object catch (e) {
        debugPrint('[ProfileRepository] loadNotes skip corrupt entry: $e');
      }
    }
    out.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    return out;
  }

  @override
  Future<void> saveNote(ProfileNote note) async {
    await _notes.put(note.id, json.encode(note.toJson()));
    // TODO(sync): push to Supabase when online sync is implemented
  }

  @override
  Future<void> deleteNote(String noteId) async {
    await _notes.delete(noteId);
    // TODO(sync): push delete to Supabase when online sync is implemented
  }

  @override
  Future<List<DocumentPackage>> loadPackages() async {
    final out = <DocumentPackage>[];
    for (final raw in _packages.values) {
      try {
        out.add(DocumentPackage.fromJson(_decode(raw)));
      } on Object catch (e) {
        debugPrint(
          '[ProfileRepository] loadPackages skip corrupt entry: $e',
        );
      }
    }
    out.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    return out;
  }

  @override
  Future<void> savePackage(DocumentPackage pkg) async {
    await _packages.put(pkg.id, json.encode(pkg.toJson()));
    // TODO(sync): push to Supabase when online sync is implemented
  }

  @override
  Future<void> deletePackage(String packageId) async {
    await _packages.delete(packageId);
    // TODO(sync): push delete to Supabase when online sync is implemented
  }
}

// ── In-memory implementation (tests) ─────────────────────────────────────────

/// Pure in-memory [ProfileRepository] — no device path, no Hive, no I/O.
///
/// Used in unit + widget tests; injected via ProviderScope.overrides.
class InMemoryProfileRepository implements ProfileRepository {
  StudentProfile _profile = StudentProfile.empty;
  final Map<String, ProfileNote> _notes = {};
  final Map<String, DocumentPackage> _packages = {};

  @override
  Future<StudentProfile> loadProfile() async => _profile;

  @override
  Future<void> saveProfile(StudentProfile profile) async {
    _profile = profile;
  }

  @override
  Future<List<ProfileNote>> loadNotes() async {
    final out = _notes.values.toList()
      ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
    return out;
  }

  @override
  Future<void> saveNote(ProfileNote note) async {
    _notes[note.id] = note;
  }

  @override
  Future<void> deleteNote(String noteId) async {
    _notes.remove(noteId);
  }

  @override
  Future<List<DocumentPackage>> loadPackages() async {
    final out = _packages.values.toList()
      ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
    return out;
  }

  @override
  Future<void> savePackage(DocumentPackage pkg) async {
    _packages[pkg.id] = pkg;
  }

  @override
  Future<void> deletePackage(String packageId) async {
    _packages.remove(packageId);
  }
}
