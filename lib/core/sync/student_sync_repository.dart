import 'package:admity/core/env/app_env.dart';
import 'package:admity/core/utils/app_logger.dart';
import 'package:admity/features/career_test/domain/career_models.dart';
import 'package:admity/features/chancing_kz/domain/ent_models.dart';
import 'package:admity/features/eraly_chat/domain/chat_models.dart';
import 'package:admity/features/essay_review/domain/essay_models.dart';
import 'package:admity/features/gap_closer/domain/gap_task.dart';
import 'package:admity/features/intensives/domain/intensive_models.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

const _logger = AppLogger('StudentSync');

/// Read/write the remaining owner-scoped student tables to Supabase
/// (ent_scores, career_results, gap_tasks, intensive_progress, college_list,
/// essays, chat). Same contract as ProfileRepository: every method is a safe
/// no-op when Supabase isn't configured or there's no session, and all network
/// errors are swallowed (logged) so the local store stays the offline source of
/// truth and the guest/offline path never breaks.
class StudentSyncRepository {
  /// Creates the repository.
  const StudentSyncRepository();

  SupabaseClient? get _client =>
      AppEnv.hasSupabase ? Supabase.instance.client : null;

  String? get _userId => _client?.auth.currentSession?.user.id;

  // ── ENT score (one row / user) ────────────────────────────────────────────

  Future<EntScore?> fetchEnt() async {
    final c = _client;
    final u = _userId;
    if (c == null || u == null) return null;
    try {
      final row =
          await c.from('ent_scores').select().eq('user_id', u).maybeSingle();
      return row == null ? null : EntScore.fromJson(row);
    } on Object catch (e) {
      _logger.warn('fetchEnt failed: $e');
      return null;
    }
  }

  Future<void> upsertEnt(EntScore score) async {
    final c = _client;
    final u = _userId;
    if (c == null || u == null) return;
    try {
      await c.from('ent_scores').upsert(
        {...score.toJson(), 'user_id': u},
        onConflict: 'user_id',
      );
    } on Object catch (e) {
      _logger.warn('upsertEnt failed: $e');
    }
  }

  // ── Career (one row / user; raw answers round-trip the local model) ─────────

  Future<({List<int> riasec, List<int> bigFive})?> fetchCareerAnswers() async {
    final c = _client;
    final u = _userId;
    if (c == null || u == null) return null;
    try {
      final row = await c
          .from('career_results')
          .select('raw_answers')
          .eq('user_id', u)
          .maybeSingle();
      final raw = row?['raw_answers'];
      if (raw is! Map) return null;
      final riasec = _intList(raw['riasec']);
      final bigFive = _intList(raw['big_five']);
      if (riasec.isEmpty || bigFive.isEmpty) return null;
      return (riasec: riasec, bigFive: bigFive);
    } on Object catch (e) {
      _logger.warn('fetchCareerAnswers failed: $e');
      return null;
    }
  }

  Future<void> upsertCareer({
    required List<int> riasecAnswers,
    required List<int> bigFiveAnswers,
    required CareerResult result,
  }) async {
    final c = _client;
    final u = _userId;
    if (c == null || u == null) return;
    try {
      await c.from('career_results').upsert(
        {
          ...result.toJson(),
          'raw_answers': {'riasec': riasecAnswers, 'big_five': bigFiveAnswers},
          'user_id': u,
        },
        onConflict: 'user_id',
      );
    } on Object catch (e) {
      _logger.warn('upsertCareer failed: $e');
    }
  }

  // ── Gap tasks (many / user; client_id preserves the deterministic local id) ─

  Future<List<GapTask>?> fetchGapTasks() async {
    final c = _client;
    final u = _userId;
    if (c == null || u == null) return null;
    try {
      final rows = await c.from('gap_tasks').select().eq('user_id', u);
      return [
        for (final r in rows)
          GapTask(
            id: (r['client_id'] as String?) ?? (r['id'] as String? ?? ''),
            title: r['title'] as String? ?? '',
            description: r['description'] as String? ?? '',
            dueDate: DateTime.tryParse(r['due_date'] as String? ?? ''),
            linkedIntensiveSlug: r['linked_intensive_slug'] as String?,
            isDone: (r['is_done'] as bool?) ?? false,
          ),
      ];
    } on Object catch (e) {
      _logger.warn('fetchGapTasks failed: $e');
      return null;
    }
  }

  Future<void> replaceGapTasks(List<GapTask> tasks) async {
    final c = _client;
    final u = _userId;
    if (c == null || u == null) return;
    try {
      await c.from('gap_tasks').delete().eq('user_id', u);
      if (tasks.isNotEmpty) {
        await c.from('gap_tasks').insert([
          for (final t in tasks)
            {
              'user_id': u,
              'client_id': t.id,
              'title': t.title,
              'description': t.description,
              'due_date': t.dueDate?.toIso8601String().split('T').first,
              'linked_intensive_slug': t.linkedIntensiveSlug,
              'is_done': t.isDone,
            },
        ]);
      }
    } on Object catch (e) {
      _logger.warn('replaceGapTasks failed: $e');
    }
  }

  // ── Intensive progress (many / user; keyed by intensive_slug) ───────────────

  Future<Map<String, IntensiveProgress>?> fetchIntensiveProgress() async {
    final c = _client;
    final u = _userId;
    if (c == null || u == null) return null;
    try {
      final rows =
          await c.from('intensive_progress').select().eq('user_id', u);
      return {
        for (final r in rows)
          (r['intensive_slug'] as String): IntensiveProgress.fromJson(r),
      };
    } on Object catch (e) {
      _logger.warn('fetchIntensiveProgress failed: $e');
      return null;
    }
  }

  Future<void> upsertIntensiveProgress(
    Map<String, IntensiveProgress> progress,
  ) async {
    final c = _client;
    final u = _userId;
    if (c == null || u == null) return;
    try {
      if (progress.isEmpty) return;
      await c.from('intensive_progress').upsert(
        [for (final p in progress.values) {...p.toJson(), 'user_id': u}],
        onConflict: 'user_id,intensive_slug',
      );
    } on Object catch (e) {
      _logger.warn('upsertIntensiveProgress failed: $e');
    }
  }

  // ── College list (many / user; the app only models the slugs today) ─────────

  Future<Set<String>?> fetchCollegeList() async {
    final c = _client;
    final u = _userId;
    if (c == null || u == null) return null;
    try {
      final rows = await c
          .from('college_list')
          .select('university_slug')
          .eq('user_id', u);
      return {
        for (final r in rows)
          if (r['university_slug'] is String) r['university_slug'] as String,
      };
    } on Object catch (e) {
      _logger.warn('fetchCollegeList failed: $e');
      return null;
    }
  }

  Future<void> replaceCollegeList(Set<String> slugs) async {
    final c = _client;
    final u = _userId;
    if (c == null || u == null) return;
    try {
      await c.from('college_list').delete().eq('user_id', u);
      if (slugs.isNotEmpty) {
        await c.from('college_list').insert([
          for (final s in slugs) {'user_id': u, 'university_slug': s},
        ]);
      }
    } on Object catch (e) {
      _logger.warn('replaceCollegeList failed: $e');
    }
  }

  // ── Essays (many / user; keyed by kind) ─────────────────────────────────────

  Future<Map<EssayKind, EssayRecord>?> fetchEssays() async {
    final c = _client;
    final u = _userId;
    if (c == null || u == null) return null;
    try {
      final rows = await c.from('essays').select().eq('user_id', u);
      final out = <EssayKind, EssayRecord>{};
      for (final r in rows) {
        final rec = EssayRecord.tryFromJson(r);
        if (rec != null) out[rec.kind] = rec;
      }
      return out;
    } on Object catch (e) {
      _logger.warn('fetchEssays failed: $e');
      return null;
    }
  }

  Future<void> upsertEssay(EssayRecord r) async {
    final c = _client;
    final u = _userId;
    if (c == null || u == null) return;
    try {
      await c.from('essays').upsert(
        {
          'user_id': u,
          'kind': r.kind.name,
          'draft_text': r.draftText,
          'rubric_feedback': r.feedback?.toJson(),
          'updated_at': r.updatedAt.toUtc().toIso8601String(),
        },
        onConflict: 'user_id,kind',
      );
    } on Object catch (e) {
      _logger.warn('upsertEssay failed: $e');
    }
  }

  // ── Chat (one thread / user + its messages) ─────────────────────────────────

  Future<String?> _ensureThreadId() async {
    final c = _client;
    final u = _userId;
    if (c == null || u == null) return null;
    final existing = await c
        .from('chat_threads')
        .select('id')
        .eq('user_id', u)
        .limit(1)
        .maybeSingle();
    if (existing != null) return existing['id'] as String?;
    final created = await c
        .from('chat_threads')
        .insert({'user_id': u})
        .select('id')
        .single();
    return created['id'] as String?;
  }

  Future<List<ChatMessage>?> fetchMessages() async {
    final c = _client;
    final u = _userId;
    if (c == null || u == null) return null;
    try {
      final threadId = await _ensureThreadId();
      if (threadId == null) return null;
      final rows = await c
          .from('chat_messages')
          .select('id, role, content, created_at')
          .eq('thread_id', threadId)
          .order('created_at');
      return [for (final r in rows) ChatMessage.fromJson(r)];
    } on Object catch (e) {
      _logger.warn('fetchMessages failed: $e');
      return null;
    }
  }

  /// Appends finalized (non-pending) messages to the user's thread.
  Future<void> appendMessages(List<ChatMessage> messages) async {
    final c = _client;
    final u = _userId;
    if (c == null || u == null || messages.isEmpty) return;
    try {
      final threadId = await _ensureThreadId();
      if (threadId == null) return;
      await c.from('chat_messages').insert([
        for (final m in messages)
          {
            'thread_id': threadId,
            'user_id': u,
            'role': m.role.name,
            'content': m.content,
            'created_at': m.createdAt.toIso8601String(),
          },
      ]);
    } on Object catch (e) {
      _logger.warn('appendMessages failed: $e');
    }
  }

  List<int> _intList(Object? v) => v is List
      ? [for (final e in v) if (e is num) e.toInt()]
      : const [];
}

/// Provides the shared [StudentSyncRepository].
final studentSyncRepositoryProvider =
    Provider<StudentSyncRepository>((ref) => const StudentSyncRepository());
