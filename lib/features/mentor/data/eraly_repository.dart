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
    final lower = last.toLowerCase();
    final turnCount = messages.length;

    // --- Topic plan triggers ---
    if (lower.contains('ielts')) {
      return 'IELTS — отличная цель! Давай составим персональный план. '
          'Для начала: какие материалы у тебя уже есть? '
          '(учебники, приложения, курсы — перечисли всё)';
    }
    if (lower.contains('sat')) {
      return 'SAT — серьёзный шаг! Я помогу разбить подготовку на чёткие уроки. '
          'Расскажи, какими ресурсами ты пользуешься?';
    }
    if (lower.contains('ент') || lower.contains('unified')) {
      return 'ЕНТ — ключевой экзамен. Хочешь составить поурочный план? '
          'Напиши, сколько времени у тебя есть до экзамена.';
    }
    if (lower.contains('план') ||
        lower.contains('study') ||
        lower.contains('подготовк')) {
      return 'Конечно, помогу составить план! Назови тему или экзамен, '
          'и я задам несколько вопросов, чтобы сделать план под тебя.';
    }

    // --- Event/calendar triggers ---
    if (lower.contains('мероприят') ||
        lower.contains('событи') ||
        lower.contains('event') ||
        lower.contains('запланир') ||
        lower.contains('календар')) {
      return 'С удовольствием помогу! Напиши тему или цель мероприятий — '
          'я предложу несколько конкретных дат и могу поставить их в календарь.';
    }

    // --- Scholarship / university ---
    if (lower.contains('стипенди') || lower.contains('scholarship')) {
      return 'Стипендии — моя любимая тема! Расскажи: '
          'ты смотришь на казахстанские программы или зарубежные? '
          'Это поможет мне точнее подобрать варианты.';
    }
    if (lower.contains('универ') ||
        lower.contains('university') ||
        lower.contains('college') ||
        lower.contains('поступ')) {
      return 'Поступление — большой шаг, и я рядом. '
          'В какую страну или университет ты целишься? '
          'Или пока только изучаешь варианты?';
    }

    // --- Greeting ---
    if (turnCount <= 2 ||
        lower.contains('привет') ||
        lower.contains('hello') ||
        lower.contains('hi ') ||
        lower == 'hi') {
      return 'Привет! Я Ералы — твой AI-наставник по поступлению. '
          'Могу помочь с тремя вещами:\n'
          '1. Составить план подготовки к экзамену (IELTS, SAT, ЕНТ).\n'
          '2. Запланировать мероприятия в календаре.\n'
          '3. Ответить на вопросы про стипендии и университеты.\n'
          'С чего начнём?';
    }

    // --- Generic follow-up ---
    const followUps = [
      'Интересно! Расскажи подробнее — я хочу понять, чем именно помочь.',
      'Хороший вопрос. Уточни, пожалуйста: ты спрашиваешь про экзамены, поступление или что-то другое?',
      'Понял. Чтобы дать точный ответ, скажи: это для ЕНТ, международного экзамена или для чего-то ещё?',
    ];
    // Rotate through follow-ups based on message count.
    return followUps[turnCount % followUps.length];
  }

  List<ProposedEvent> _offlineEvents(String topic) {
    final base = DateTime.now().copyWith(
      hour: 10,
      minute: 0,
      second: 0,
      millisecond: 0,
      microsecond: 0,
    );
    return [
      ProposedEvent(
        id: 'evt_offline_1',
        title: 'Старт: $topic',
        scheduledAt: base.add(const Duration(days: 1)),
        description:
            'Первое знакомство с темой — изучи ключевые понятия и '
            'составь список вопросов.',
      ),
      ProposedEvent(
        id: 'evt_offline_2',
        title: 'Практика: $topic',
        scheduledAt: base.add(const Duration(days: 3)),
        description:
            'Практическое занятие — реши 10–15 задач или '
            'сделай пробный тест.',
      ),
      ProposedEvent(
        id: 'evt_offline_3',
        title: 'Повторение: $topic',
        scheduledAt: base.add(const Duration(days: 7)),
        description:
            'Итоговое повторение — закрепи слабые места и '
            'проверь прогресс.',
      ),
    ];
  }

  TopicPlan _offlinePlan(String topic) {
    return TopicPlan(
      topic: topic,
      notes:
          'Базовый офлайн-план. Подключитесь к интернету, чтобы Ералы '
          'составил план под ваши материалы и расписание.',
      lessons: [
        PlanLesson(
          index: 1,
          title: 'Введение в $topic',
          durationMinutes: 60,
        ),
        PlanLesson(
          index: 2,
          title: 'Ключевые концепции $topic',
          durationMinutes: 90,
        ),
        const PlanLesson(
          index: 3,
          title: 'Практические упражнения',
          durationMinutes: 60,
        ),
        const PlanLesson(
          index: 4,
          title: 'Разбор ошибок и слабых мест',
          durationMinutes: 45,
        ),
        const PlanLesson(
          index: 5,
          title: 'Пробный тест и итоговое повторение',
          durationMinutes: 60,
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
