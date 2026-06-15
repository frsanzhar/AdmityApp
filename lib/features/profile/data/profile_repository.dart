import 'package:admity/core/env/app_env.dart';
import 'package:admity/core/utils/app_logger.dart';
import 'package:admity/shared/models/profile.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

const _logger = AppLogger('ProfileRepository');

/// Reads/writes the student [Profile] and private notes to Supabase, scoped to
/// the signed-in user by RLS (`auth.uid() = user_id`).
///
/// Every method is a safe no-op when Supabase isn't configured or there's no
/// session, and network errors are swallowed (logged) — the local store stays
/// the offline source of truth, so sync can never break the guest/offline path.
class ProfileRepository {
  /// Creates the repository.
  const ProfileRepository();

  SupabaseClient? get _client =>
      AppEnv.hasSupabase ? Supabase.instance.client : null;

  String? get _userId => _client?.auth.currentSession?.user.id;

  /// Whether there is an authenticated session to sync against.
  bool get isSignedIn => _userId != null;

  /// Fetches the signed-in user's profile row, or `null` if none / on error.
  Future<Profile?> fetchProfile() async {
    final client = _client;
    final userId = _userId;
    if (client == null || userId == null) return null;
    try {
      final row = await client
          .from('profiles')
          .select()
          .eq('user_id', userId)
          .maybeSingle();
      if (row == null) return null;
      // PostgREST may serialize a `numeric` column as a string to preserve
      // precision; Profile.fromJson expects a num for gpa, so coerce first.
      final gpa = row['gpa'];
      if (gpa is String) row['gpa'] = double.tryParse(gpa);
      return Profile.fromJson(row);
    } on Object catch (e) {
      _logger.warn('fetchProfile failed: $e');
      return null;
    }
  }

  /// Upserts [profile] for the signed-in user (no-op when signed out).
  Future<void> upsertProfile(Profile profile) async {
    final client = _client;
    final userId = _userId;
    if (client == null || userId == null) return;
    try {
      await client.from('profiles').upsert(
            profile.copyWith(userId: userId).toJson(),
            onConflict: 'user_id',
          );
    } on Object catch (e) {
      _logger.warn('upsertProfile failed: $e');
    }
  }

  /// Fetches the user's notes oldest-first, or `null` on error / signed out.
  Future<List<String>?> fetchNotes() async {
    final client = _client;
    final userId = _userId;
    if (client == null || userId == null) return null;
    try {
      final rows = await client
          .from('personal_notes')
          .select('content')
          .eq('user_id', userId)
          .order('created_at');
      return [
        for (final r in rows)
          if ((r['content'] as String?)?.trim().isNotEmpty ?? false)
            (r['content'] as String).trim(),
      ];
    } on Object catch (e) {
      _logger.warn('fetchNotes failed: $e');
      return null;
    }
  }

  /// Replaces the user's notes with [notes] (delete-all then insert). Notes are
  /// a short list of plain strings with no stable ids, so a full replace is
  /// simpler and idempotent versus per-row diffing.
  Future<void> replaceNotes(List<String> notes) async {
    final client = _client;
    final userId = _userId;
    if (client == null || userId == null) return;
    try {
      await client.from('personal_notes').delete().eq('user_id', userId);
      if (notes.isNotEmpty) {
        await client.from('personal_notes').insert([
          for (final c in notes) {'user_id': userId, 'content': c},
        ]);
      }
    } on Object catch (e) {
      _logger.warn('replaceNotes failed: $e');
    }
  }
}

/// Provides the shared [ProfileRepository].
final profileRepositoryProvider =
    Provider<ProfileRepository>((ref) => const ProfileRepository());
