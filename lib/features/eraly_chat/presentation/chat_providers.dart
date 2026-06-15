import 'dart:async';

import 'package:admity/core/ai/eraly_client.dart';
import 'package:admity/core/storage/local_store.dart';
import 'package:admity/core/sync/student_sync_repository.dart';
import 'package:admity/features/calendar/domain/calendar_ai_actions.dart';
import 'package:admity/features/calendar/domain/calendar_event.dart';
import 'package:admity/features/calendar/presentation/calendar_providers.dart';
import 'package:admity/features/career_test/presentation/career_providers.dart';
import 'package:admity/features/chancing_kz/presentation/ent_providers.dart';
import 'package:admity/features/eraly_chat/domain/chat_models.dart';
import 'package:admity/features/profile/presentation/profile_providers.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Holds the active Eraly conversation. Cached locally and (when signed in)
/// persisted to Supabase, so history survives restarts and syncs across devices.
class ChatController extends Notifier<List<ChatMessage>> {
  static const _key = 'chat_messages';
  var _seq = 0;

  String _id() => 'm${_seq++}_${DateTime.now().microsecondsSinceEpoch}';

  ChatMessage _greeting() => ChatMessage(
        id: _id(),
        role: ChatRole.eraly,
        content:
            'Привет! Я Ералы. Спроси про твои шансы, стипендии, эссе или с '
            'чего начать. Я помогу и подскажу — но работу за тебя делать не '
            'буду 🙂',
        createdAt: DateTime.now(),
      );

  @override
  List<ChatMessage> build() {
    final cached = ref.read(localStoreProvider).readList(_key);
    if (cached != null && cached.isNotEmpty) {
      return cached
          .whereType<Map<String, dynamic>>()
          .map(ChatMessage.fromJson)
          .toList();
    }
    return [_greeting()];
  }

  Future<void> send(String text) async {
    final trimmed = text.trim();
    if (trimmed.isEmpty) return;

    // Snapshot the conversation BEFORE adding the new turn. The server appends
    // [message] itself, so sending it inside [history] too would duplicate the
    // student's message in the prompt. This is prior turns only.
    final priorHistory = state.where((m) => !m.pending).toList();

    final user = ChatMessage(
      id: _id(),
      role: ChatRole.user,
      content: trimmed,
      createdAt: DateTime.now(),
    );
    final pending = ChatMessage(
      id: _id(),
      role: ChatRole.eraly,
      content: '',
      createdAt: DateTime.now(),
      pending: true,
    );
    state = [...state, user, pending];

    final reply = await ref.read(eralyClientProvider).send(
          history: priorHistory,
          message: trimmed,
          profileContext: _profileContext(),
        );

    // Eraly may embed ```calendar action blocks — apply them to the student's
    // calendar and show a friendly confirmation instead of the raw block.
    final parsed = parseEralyReply(reply);
    final summary = _applyCalendarActions(parsed.actions);
    final content = summary.isEmpty
        ? parsed.text
        : (parsed.text.isEmpty ? summary : '${parsed.text}\n\n$summary');

    state = [
      for (final m in state)
        if (m.id == pending.id)
          m.copyWith(content: content, pending: false)
        else
          m,
    ];

    // Cache locally and (when signed in) append this turn to the cloud thread.
    _persistLocal();
    final eralyMsg =
        state.firstWhere((m) => m.id == pending.id, orElse: () => pending);
    unawaited(
      ref.read(studentSyncRepositoryProvider).appendMessages([user, eralyMsg]),
    );
  }

  /// Replaces local state + cache from server-fetched history (sign-in).
  void hydrate(List<ChatMessage> messages) {
    state = messages.isEmpty ? [_greeting()] : messages;
    _persistLocal();
  }

  /// Resets to a fresh greeting on sign-out (server history is durable).
  void clear() {
    state = [_greeting()];
    ref.read(localStoreProvider).remove(_key);
  }

  void _persistLocal() {
    ref.read(localStoreProvider).put(
          _key,
          [for (final m in state) if (!m.pending) m.toJson()],
        );
  }

  /// Applies Eraly's calendar [actions] to [userCalendarEventsProvider] and
  /// returns a short Russian confirmation (empty when nothing changed).
  String _applyCalendarActions(List<CalendarAiAction> actions) {
    if (actions.isEmpty) return '';
    final notifier = ref.read(userCalendarEventsProvider.notifier);
    final existing = ref.read(userCalendarEventsProvider);
    final lines = <String>[];
    var n = 0;
    for (final a in actions) {
      if (a.op == 'add') {
        // Never fabricate a deadline. If Eraly didn't give a real date, skip the
        // add and ask — a wrong date is worse than no date for an applicant.
        final date = a.date;
        if (date == null) {
          lines.add(
            '📅 Уточни дату для «${a.title}» — и я добавлю её в календарь.',
          );
          continue;
        }
        notifier.add(
          CalendarEvent(
            id: 'ai_${DateTime.now().microsecondsSinceEpoch}_${n++}',
            title: a.title,
            date: date,
            kind: a.kind,
            subtitle: a.note,
            userCreated: true,
          ),
        );
        lines.add(
          '📅 Добавил в календарь: «${a.title}» — '
          '${date.day.toString().padLeft(2, '0')}.'
          '${date.month.toString().padLeft(2, '0')}.${date.year}',
        );
      } else {
        final query = a.title.toLowerCase();
        final matches = existing
            .where(
              (e) =>
                  e.userCreated &&
                  e.id != null &&
                  e.title.toLowerCase().contains(query),
            )
            .toList();
        for (final e in matches) {
          notifier.removeById(e.id!);
        }
        if (matches.isNotEmpty) {
          lines.add('🗑 Убрал из календаря: «${a.title}»');
        }
      }
    }
    return lines.join('\n');
  }

  Map<String, dynamic> _profileContext() {
    final profile = ref.read(profileProvider);
    final ent = ref.read(entScoreProvider);
    final career = ref.read(careerProvider);
    return {
      'region': profile.region,
      'grade': profile.grade,
      'gpa': profile.gpa,
      'target_geo': profile.targetGeos.map((g) => g.name).toList(),
      'interests': profile.interests.toList(),
      'ent_total': ent?.total,
      'riasec_code': career?.riasecCode,
    };
  }
}

final chatProvider =
    NotifierProvider<ChatController, List<ChatMessage>>(ChatController.new);
