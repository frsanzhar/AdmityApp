import 'package:admity/features/mentor/domain/proposed_event.dart';
import 'package:admity/features/mentor/domain/topic_plan.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

// ── Supabase availability guard ───────────────────────────────────────────────

/// True when Supabase has been initialised (i.e. env vars were provided).
/// Falls back gracefully to offline/canned responses when false.
bool get _hasSupabase {
  try {
    // Accessing .instance throws AssertionError (subclass of Error, not
    // Exception) when Supabase.initialize() has not been called.
    // We use `on Object` to catch both Error and Exception subtypes.
    final _ = Supabase.instance.client;
    return true;
  } on Object {
    return false;
  }
}

// Edge Function URL suffix — matches supabase/functions/eraly/index.ts
const _kFunctionName = 'eraly';

// ── Repository ────────────────────────────────────────────────────────────────

/// Repository that wraps the Ералы Edge Function call.
///
/// Client payloads are PII-minimised: no name/email/region; GPA is sent as a
/// band string (e.g. "3.5–4.0"), not a raw number.
///
/// When Supabase is not configured ([_hasSupabase] == false) the repository
/// returns canned/guided offline responses so the app degrades gracefully.
class EralyRepository {
  const EralyRepository();

  // ── Chat ─────────────────────────────────────────────────────────────────

  /// Sends [messages] (minimal history) and returns Ералы's reply text.
  ///
  /// Each entry in [messages] is `{'role': 'user'|'assistant', 'text': '…'}`.
  /// No PII — caller must strip names/emails before passing here.
  Future<String> chat({
    required List<Map<String, String>> messages,
    String? gpaBand,
  }) async {
    if (!_hasSupabase) return _offlineChatFallback(messages);

    try {
      final payload = <String, dynamic>{
        'mode': 'chat',
        'messages': messages,
        'gpa_band': ?gpaBand,
      };
      final response = await Supabase.instance.client.functions.invoke(
        _kFunctionName,
        body: payload,
      );
      final data = response.data;
      if (data is Map) {
        return (data['reply'] as String?) ?? _offlineChatFallback(messages);
      }
      return _offlineChatFallback(messages);
    } on Exception catch (e) {
      debugPrint('[EralyRepository] chat error: $e');
      return _offlineChatFallback(messages);
    }
  }

  // ── Event suggestions ─────────────────────────────────────────────────────

  /// Asks Ералы to propose calendar events for [topic].
  /// Returns a list of [ProposedEvent] — none are reviewed yet.
  Future<List<ProposedEvent>> proposeEvents({
    required String topic,
  }) async {
    if (!_hasSupabase) return _offlineEvents(topic);

    try {
      final payload = <String, dynamic>{
        'mode': 'propose_events',
        'topic': topic,
      };
      final response = await Supabase.instance.client.functions.invoke(
        _kFunctionName,
        body: payload,
      );
      final data = response.data;
      if (data is Map && data['events'] is List) {
        final raw = data['events'] as List<dynamic>;
        return _parseEvents(raw);
      }
      return _offlineEvents(topic);
    } on Exception catch (e) {
      debugPrint('[EralyRepository] proposeEvents error: $e');
      return _offlineEvents(topic);
    }
  }

  // ── Topic plan ────────────────────────────────────────────────────────────

  /// Generates a lesson-by-lesson plan for [topic] from questionnaire answers.
  Future<TopicPlan> generatePlan({
    required String topic,
    required String resources,
    required String availableTime,
    required bool internetAccess,
  }) async {
    if (!_hasSupabase) return _offlinePlan(topic);

    try {
      final payload = <String, dynamic>{
        'mode': 'generate_plan',
        'topic': topic,
        'resources': resources,
        'available_time': availableTime,
        'internet_access': internetAccess,
      };
      final response = await Supabase.instance.client.functions.invoke(
        _kFunctionName,
        body: payload,
      );
      final data = response.data;
      if (data is Map) {
        return _parsePlan(topic, data);
      }
      return _offlinePlan(topic);
    } on Exception catch (e) {
      debugPrint('[EralyRepository] generatePlan error: $e');
      return _offlinePlan(topic);
    }
  }

  // ── Offline fallbacks ─────────────────────────────────────────────────────

  String _offlineChatFallback(List<Map<String, String>> messages) {
    final last = messages.isNotEmpty ? messages.last['text'] ?? '' : '';
    if (last.toLowerCase().contains('ielts')) {
      return 'Отличный выбор! Давай составим план подготовки к IELTS. '
          'Сначала расскажи: какие учебные материалы у тебя есть?';
    }
    if (last.toLowerCase().contains('мероприят') ||
        last.toLowerCase().contains('событи') ||
        last.toLowerCase().contains('event')) {
      return 'Я могу помочь спланировать мероприятия. '
          'Назови тему или цель — и я предложу несколько вариантов.';
    }
    return 'Привет! Я Ералы — твой AI-наставник. '
        'Чем могу помочь сегодня?';
  }

  List<ProposedEvent> _offlineEvents(String topic) {
    final base = DateTime.now();
    return [
      ProposedEvent(
        id: 'evt_1',
        title: 'Подготовка к $topic',
        scheduledAt: base.add(const Duration(days: 1)),
        description: 'Первая сессия подготовки',
      ),
      ProposedEvent(
        id: 'evt_2',
        title: 'Практика $topic',
        scheduledAt: base.add(const Duration(days: 3)),
        description: 'Практическое занятие',
      ),
      ProposedEvent(
        id: 'evt_3',
        title: 'Повторение $topic',
        scheduledAt: base.add(const Duration(days: 7)),
        description: 'Повторение пройденного',
      ),
    ];
  }

  TopicPlan _offlinePlan(String topic) {
    return TopicPlan(
      topic: topic,
      notes:
          'Офлайн-план. Подключитесь к интернету для персонализированного плана.',
      lessons: [
        PlanLesson(
          index: 1,
          title: 'Введение в $topic',
          durationMinutes: 60,
        ),
        PlanLesson(
          index: 2,
          title: 'Основные концепции $topic',
          durationMinutes: 90,
        ),
        const PlanLesson(
          index: 3,
          title: 'Практика и упражнения',
          durationMinutes: 60,
        ),
        const PlanLesson(
          index: 4,
          title: 'Итоговое повторение',
          durationMinutes: 45,
        ),
      ],
    );
  }

  // ── Parsers ───────────────────────────────────────────────────────────────

  List<ProposedEvent> _parseEvents(List<dynamic> raw) {
    final events = <ProposedEvent>[];
    for (final (i, item) in raw.indexed) {
      if (item is! Map) continue;
      final id = item['id'] as String? ?? 'evt_$i';
      final title = item['title'] as String? ?? 'Событие ${i + 1}';
      final desc = item['description'] as String? ?? '';
      DateTime scheduledAt;
      try {
        scheduledAt = DateTime.parse(item['scheduled_at'] as String? ?? '');
      } on Exception {
        scheduledAt = DateTime.now().add(Duration(days: i + 1));
      }
      events.add(
        ProposedEvent(
          id: id,
          title: title,
          scheduledAt: scheduledAt,
          description: desc,
        ),
      );
    }
    return events;
  }

  TopicPlan _parsePlan(String topic, Map<dynamic, dynamic> data) {
    final notes = data['notes'] as String? ?? '';
    final rawLessons = data['lessons'];
    final lessons = <PlanLesson>[];
    if (rawLessons is List) {
      for (final (i, item) in rawLessons.indexed) {
        if (item is! Map) continue;
        lessons.add(
          PlanLesson(
            index: i + 1,
            title: item['title'] as String? ?? 'Урок ${i + 1}',
            durationMinutes: (item['duration_minutes'] as num?)?.toInt() ?? 60,
            resource: item['resource'] as String?,
          ),
        );
      }
    }
    return TopicPlan(topic: topic, notes: notes, lessons: lessons);
  }
}

// ── Provider ──────────────────────────────────────────────────────────────────

final eralyRepositoryProvider = Provider<EralyRepository>(
  (_) => const EralyRepository(),
);
