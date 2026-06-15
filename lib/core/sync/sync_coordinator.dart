import 'dart:async';

import 'package:admity/core/env/app_env.dart';
import 'package:admity/core/sync/student_sync_repository.dart';
import 'package:admity/features/career_test/presentation/career_providers.dart';
import 'package:admity/features/chancing_kz/presentation/ent_providers.dart';
import 'package:admity/features/eraly_chat/domain/chat_models.dart';
import 'package:admity/features/eraly_chat/presentation/chat_providers.dart';
import 'package:admity/features/essay_review/presentation/essay_providers.dart';
import 'package:admity/features/gap_closer/presentation/gap_providers.dart';
import 'package:admity/features/intensives/presentation/intensives_providers.dart';
import 'package:admity/features/profile/data/profile_repository.dart';
import 'package:admity/features/profile/presentation/profile_providers.dart';
import 'package:admity/features/universities/presentation/universities_providers.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

/// Orchestrates two-way sync of ALL student data with Supabase:
///
/// - sign-in / restored session: pull every table — the server copy wins when
///   it holds data, otherwise the local (guest) data is migrated up.
/// - live: a Realtime channel mirrors server-side changes (from other devices)
///   back into local state, debounced so a single write's delete+insert events
///   coalesce into one refetch.
/// - sign-out: every student provider is cleared (privacy on shared devices);
///   the server stays the durable record and re-hydrates next sign-in.
///
/// Everything is a no-op when Supabase isn't configured. Watch this once at the
/// app root to keep it alive for the app's lifetime.
final syncCoordinatorProvider = Provider<void>((ref) {
  if (!AppEnv.hasSupabase) return;
  final client = Supabase.instance.client;
  final auth = client.auth;
  final profileRepo = ref.read(profileRepositoryProvider);
  final repo = ref.read(studentSyncRepositoryProvider);

  RealtimeChannel? channel;
  final timers = <String, Timer>{};

  // ── Realtime mirrors (server → local). hydrate(empty) intentionally clears,
  //    so a deletion on another device propagates here. ──────────────────────
  Future<void> pullProfile() async {
    final r = await profileRepo.fetchProfile();
    if (r != null) ref.read(profileProvider.notifier).hydrate(r);
  }

  Future<void> pullNotes() async {
    final r = await profileRepo.fetchNotes();
    if (r != null) ref.read(notesProvider.notifier).hydrate(r);
  }

  Future<void> pullEnt() async =>
      ref.read(entScoreProvider.notifier).hydrate(await repo.fetchEnt());

  Future<void> pullCareer() async {
    final a = await repo.fetchCareerAnswers();
    if (a != null) {
      ref.read(careerProvider.notifier).hydrateAnswers(a.riasec, a.bigFive);
    }
  }

  Future<void> pullGap() async {
    final r = await repo.fetchGapTasks();
    if (r != null) ref.read(gapTasksProvider.notifier).hydrate(r);
  }

  Future<void> pullIntensive() async {
    final r = await repo.fetchIntensiveProgress();
    if (r != null) ref.read(intensiveProgressProvider.notifier).hydrate(r);
  }

  Future<void> pullCollege() async {
    final r = await repo.fetchCollegeList();
    if (r != null) ref.read(collegeListProvider.notifier).hydrate(r);
  }

  Future<void> pullEssays() async {
    final r = await repo.fetchEssays();
    if (r != null) ref.read(essaysProvider.notifier).hydrate(r);
  }

  Future<void> pullChat() async {
    final r = await repo.fetchMessages();
    if (r != null && r.isNotEmpty) ref.read(chatProvider.notifier).hydrate(r);
  }

  // ── Initial reconciliation on sign-in: server-wins-if-present, else push the
  //    local guest data up. ────────────────────────────────────────────────
  Future<void> pullAll() async {
    final remoteProfile = await profileRepo.fetchProfile();
    if (remoteProfile != null && remoteProfile.onboarded) {
      ref.read(profileProvider.notifier).hydrate(remoteProfile);
    } else {
      await profileRepo.upsertProfile(ref.read(profileProvider));
    }

    final remoteNotes = await profileRepo.fetchNotes();
    if (remoteNotes != null && remoteNotes.isNotEmpty) {
      ref.read(notesProvider.notifier).hydrate(remoteNotes);
    } else {
      await profileRepo.replaceNotes(ref.read(notesProvider));
    }

    final remoteEnt = await repo.fetchEnt();
    if (remoteEnt != null) {
      ref.read(entScoreProvider.notifier).hydrate(remoteEnt);
    } else {
      final local = ref.read(entScoreProvider);
      if (local != null) await repo.upsertEnt(local);
    }

    final remoteCareer = await repo.fetchCareerAnswers();
    if (remoteCareer != null) {
      ref
          .read(careerProvider.notifier)
          .hydrateAnswers(remoteCareer.riasec, remoteCareer.bigFive);
    } else {
      await ref.read(careerProvider.notifier).syncUp();
    }

    final remoteGap = await repo.fetchGapTasks();
    if (remoteGap != null && remoteGap.isNotEmpty) {
      ref.read(gapTasksProvider.notifier).hydrate(remoteGap);
    } else {
      await repo.replaceGapTasks(ref.read(gapTasksProvider));
    }

    final remoteIntensive = await repo.fetchIntensiveProgress();
    if (remoteIntensive != null && remoteIntensive.isNotEmpty) {
      ref.read(intensiveProgressProvider.notifier).hydrate(remoteIntensive);
    } else {
      await repo.upsertIntensiveProgress(ref.read(intensiveProgressProvider));
    }

    final remoteCollege = await repo.fetchCollegeList();
    if (remoteCollege != null && remoteCollege.isNotEmpty) {
      ref.read(collegeListProvider.notifier).hydrate(remoteCollege);
    } else {
      await repo.replaceCollegeList(ref.read(collegeListProvider));
    }

    final remoteEssays = await repo.fetchEssays();
    if (remoteEssays != null && remoteEssays.isNotEmpty) {
      ref.read(essaysProvider.notifier).hydrate(remoteEssays);
    } else {
      for (final r in ref.read(essaysProvider).values) {
        await repo.upsertEssay(r);
      }
    }

    final remoteChat = await repo.fetchMessages();
    if (remoteChat != null && remoteChat.isNotEmpty) {
      ref.read(chatProvider.notifier).hydrate(remoteChat);
    } else {
      // Migrate the local conversation up, minus the client-only seed greeting
      // (a leading run of eraly messages with no preceding user message).
      final local = ref.read(chatProvider).where((m) => !m.pending).toList();
      var start = 0;
      while (start < local.length && local[start].role == ChatRole.eraly) {
        start++;
      }
      final toUpload = local.sublist(start);
      if (toUpload.isNotEmpty) await repo.appendMessages(toUpload);
    }
  }

  void debounced(String key, Future<void> Function() pull) {
    timers[key]?.cancel();
    timers[key] =
        Timer(const Duration(milliseconds: 500), () => unawaited(pull()));
  }

  void subscribe(String userId) {
    unawaited(channel?.unsubscribe());
    final ch = client.channel('student-sync');
    void watch(String table, Future<void> Function() pull) {
      ch.onPostgresChanges(
        event: PostgresChangeEvent.all,
        schema: 'public',
        table: table,
        filter: PostgresChangeFilter(
          type: PostgresChangeFilterType.eq,
          column: 'user_id',
          value: userId,
        ),
        callback: (_) => debounced(table, pull),
      );
    }

    watch('profiles', pullProfile);
    watch('personal_notes', pullNotes);
    watch('ent_scores', pullEnt);
    watch('career_results', pullCareer);
    watch('gap_tasks', pullGap);
    watch('intensive_progress', pullIntensive);
    watch('college_list', pullCollege);
    watch('essays', pullEssays);
    watch('chat_messages', pullChat);
    ch.subscribe();
    channel = ch;
  }

  void teardown() {
    for (final t in timers.values) {
      t.cancel();
    }
    timers.clear();
    unawaited(channel?.unsubscribe());
    channel = null;
  }

  void clearAll() {
    ref.read(profileProvider.notifier).clear();
    ref.read(notesProvider.notifier).clear();
    ref.read(entScoreProvider.notifier).clear();
    ref.read(careerProvider.notifier).clear();
    ref.read(gapTasksProvider.notifier).clear();
    ref.read(intensiveProgressProvider.notifier).clear();
    ref.read(collegeListProvider.notifier).clear();
    ref.read(essaysProvider.notifier).clear();
    ref.read(chatProvider.notifier).clear();
  }

  final sub = auth.onAuthStateChange.listen((data) {
    final userId = auth.currentSession?.user.id;
    switch (data.event) {
      case AuthChangeEvent.signedIn:
      case AuthChangeEvent.initialSession:
        if (userId != null) {
          unawaited(pullAll().then((_) => subscribe(userId)));
        }
      case AuthChangeEvent.signedOut:
        teardown();
        clearAll();
      case _:
        break;
    }
  });

  ref.onDispose(() {
    unawaited(sub.cancel());
    teardown();
  });
});
