import 'dart:convert';
import 'dart:io';

import 'package:admity/features/mentor/domain/assistant_role.dart';
import 'package:admity/features/mentor/domain/proposed_event.dart';
import 'package:admity/features/mentor/domain/topic_plan.dart';
import 'package:admity/features/profile/domain/profile_model.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

// ── Profile context for Ералы ─────────────────────────────────────────────────

/// Builds the PII-minimised student context sent to the Edge Function so Ералы
/// knows the student's goals, exams, scores and schedule up front.
///
/// Privacy (CLAUDE.md): NO name, NO email, NO city/region. GPA goes as a
/// coarse band, never the raw number. Every onboarding answer and later
/// profile edit flows through here automatically because callers read the
/// current profile at send time.
Map<String, dynamic> buildEralyProfileContext(StudentProfile p) {
  var gpaBand = p.gpaBand;
  if (gpaBand == null && p.gpa != null) {
    final v = double.tryParse(p.gpa!.replaceAll(',', '.'));
    if (v != null && v > 0) {
      final low = (v * 2).floorToDouble() / 2;
      gpaBand = '${low.toStringAsFixed(1)}–${(low + 0.5).toStringAsFixed(1)}';
    }
  }
  final map = <String, dynamic>{
    'role': p.role,
    'age': p.age,
    'grade': p.grade,
    'motivation': p.motivation,
    'target_majors': p.targetMajors.isEmpty ? null : p.targetMajors,
    'target_universities':
        p.targetUniversities.isEmpty ? null : p.targetUniversities,
    'interests': p.interests.isEmpty ? null : p.interests,
    'confidence': p.confidence,
    'gpa_band': gpaBand,
    'ielts': p.ieltsScore,
    'sat': p.satScore,
    'toefl': p.toeflScore,
    'career_result': p.careerResult,
    'daily_goal_minutes': p.dailyGoalMinutes,
    'schedule': p.schedule,
    'aid_target': p.aidTarget,
    'languages': p.languages.isEmpty ? null : p.languages,
  }..removeWhere((_, v) => v == null);
  return map;
}

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

  // ── Multi-role chat ───────────────────────────────────────────────────────

  /// Sends a chat message as a specific [role] assistant.
  ///
  /// [messages] is the full conversation history (oldest first); the last
  /// entry is the new user message.  [profileContext] is the PII-minimised
  /// student profile.  [othersContext] is a map of other assistants'
  /// 2–3 line summaries (shared memory) injected for cross-assistant
  /// coherence.
  ///
  /// Falls back gracefully to offline canned responses when Supabase is not
  /// configured.
  Future<String> chatAs({
    required AssistantRole role,
    required List<Map<String, String>> messages,
    Map<String, dynamic>? profileContext,
    Map<String, String>? othersContext,
  }) async {
    if (!_hasSupabase) return _offlineRoleChat(role, messages);

    try {
      final history = messages.length > 1
          ? messages
                .sublist(0, messages.length - 1)
                .map(
                  (m) => <String, String>{
                    'role': m['role'] ?? 'user',
                    'content': m['text'] ?? '',
                  },
                )
                .toList()
          : <Map<String, String>>[];
      final lastText =
          messages.isNotEmpty ? (messages.last['text'] ?? '') : '';

      final profile = <String, dynamic>{
        ...?profileContext,
        if (othersContext != null && othersContext.isNotEmpty)
          'others_context': othersContext,
      };

      final payload = <String, dynamic>{
        'role': role.name,
        'message': lastText,
        'history': history,
        'profile': profile,
      };

      final response = await Supabase.instance.client.functions.invoke(
        _kFunctionName,
        body: payload,
      );
      final data = response.data;
      if (data is Map) {
        return (data['reply'] as String?) ??
            _offlineRoleChat(role, messages);
      }
      return _offlineRoleChat(role, messages);
    } on Exception catch (e) {
      debugPrint('[EralyRepository] chatAs(${role.name}) error: $e');
      return _offlineRoleChat(role, messages);
    }
  }

  /// Sends a message with an image attachment.
  ///
  /// Used by [AssistantRole.aruzhan] (homework photo review).  The image at
  /// [imagePath] is read, base64-encoded, and forwarded to the Edge Function
  /// as a vision block.  Non-image files should NOT use this method — call
  /// [chatAs] instead with the file name mentioned in the message text.
  ///
  /// The client is responsible for compressing images to a reasonable size
  /// before passing [imagePath] (≤ 400 KB recommended for fast responses).
  Future<String> chatWithImage({
    required AssistantRole role,
    required String text,
    required String imagePath,
    required List<Map<String, String>> history,
    Map<String, dynamic>? profileContext,
    Map<String, String>? othersContext,
  }) async {
    if (!_hasSupabase) return _offlineRoleChat(role, history);

    try {
      final file = File(imagePath);
      if (!file.existsSync()) {
        return _offlineRoleChat(role, history);
      }

      final bytes = await file.readAsBytes();
      final base64Data = base64Encode(bytes);

      // Determine MIME type from extension (basic detection — sufficient for
      // the homework-photo use-case which is always jpg/png/gif/webp).
      final ext = imagePath.split('.').last.toLowerCase();
      final mime = switch (ext) {
        'jpg' || 'jpeg' => 'image/jpeg',
        'png' => 'image/png',
        'gif' => 'image/gif',
        'webp' => 'image/webp',
        _ => 'image/jpeg',
      };

      final mappedHistory = history
          .map(
            (m) => <String, String>{
              'role': m['role'] ?? 'user',
              'content': m['text'] ?? '',
            },
          )
          .toList();

      final profile = <String, dynamic>{
        ...?profileContext,
        if (othersContext != null && othersContext.isNotEmpty)
          'others_context': othersContext,
      };

      final payload = <String, dynamic>{
        'role': role.name,
        'message': text,
        'history': mappedHistory,
        'profile': profile,
        'image_base64': base64Data,
        'image_mime': mime,
      };

      final response = await Supabase.instance.client.functions.invoke(
        _kFunctionName,
        body: payload,
      );
      final data = response.data;
      if (data is Map) {
        return (data['reply'] as String?) ??
            _offlineRoleChat(role, history);
      }
      return _offlineRoleChat(role, history);
    } on Exception catch (e) {
      debugPrint('[EralyRepository] chatWithImage error: $e');
      return _offlineRoleChat(role, history);
    }
  }

  // ── Offline fallbacks (per role) ──────────────────────────────────────────

  /// Returns a canned response for the given [role] when offline.
  ///
  /// Each role has 3–5 context-aware fallbacks that rotate based on message
  /// count so the student doesn't see the same text on every send.
  String _offlineRoleChat(
    AssistantRole role,
    List<Map<String, String>> messages,
  ) {
    final turnCount = messages.length;
    switch (role) {
      case AssistantRole.eraly:
        return _offlineChatFallback(messages, 'friendly');

      case AssistantRole.azamat:
        const azamatFallbacks = <String>[
          'Скинь черновик эссе — разберём структуру и аргументы. Без текста не смогу помочь.',
          'Главное в хорошем эссе — конкретика и твой личный голос. Расскажи, о чём хочешь написать.',
          'Совет по структуре: зацепи читателя во вступлении, дай три конкретных примера в теле, заверши выводом. Что уже есть?',
          'Без черновика сложно. Напиши хотя бы 2–3 предложения — начнём разбор оттуда.',
          'Вузы хотят видеть тебя, а не шаблон. С какого момента твоей жизни начинается история?',
        ];
        return azamatFallbacks[turnCount % azamatFallbacks.length];

      case AssistantRole.madina:
        const madinaFallbacks = <String>[
          'Для поступления в казахстанские вузы основной пакет: аттестат, сертификат ЕНТ, медсправка 086-У, фото 3×4, ИИН, удостоверение. Уточни, что именно ищешь.',
          'Справку 086-У выдаёт районная поликлиника или ЦОН. Возьми ИИН и удостоверение личности.',
          'Для иностранных вузов аттестат нужно апостилировать и перевести у нотариуса. Уточни у конкретного вуза — требования разные.',
          'Уточни, пожалуйста: какой документ нужен и для какого учебного заведения? Тогда дам точный ответ.',
          'Рекомендательное письмо пишет учитель или директор школы. Попроси заранее — минимум за 2–3 недели до дедлайна.',
        ];
        return madinaFallbacks[turnCount % madinaFallbacks.length];

      case AssistantRole.aruzhan:
        const aruzhanFallbacks = <String>[
          'Прикрепи фото задания или напиши условие — разберём вместе по шагам!',
          'Покажи, что задали, и я объясню по шагам. Что именно вызывает затруднение?',
          'Хороший вопрос! Сначала вспомним теорию, потом решим пример. Что нужно объяснить?',
          'Чтобы помочь с ДЗ, нужно видеть задание. Прикрепи фото или напиши условие.',
          'Прогресс — через практику! Пришли задание — покажу, как подойти к нему шаг за шагом.',
        ];
        return aruzhanFallbacks[turnCount % aruzhanFallbacks.length];
    }
  }

  // ── Chat ─────────────────────────────────────────────────────────────────

  /// Sends [messages] (minimal history) and returns Ералы's reply text.
  ///
  /// Each entry in [messages] is `{'role': 'user'|'assistant', 'text': '…'}`.
  /// No PII — caller must strip names/emails before passing here.
  ///
  /// [tone] is 'strict' or 'friendly' (defaults to 'friendly' when null).
  /// It is forwarded to the Edge Function so the LLM system prompt can adapt
  /// Ералы's persona accordingly.  The offline fallback also uses it.
  Future<String> chat({
    required List<Map<String, String>> messages,
    String? gpaBand,
    String? tone,
    Map<String, dynamic>? profileContext,
  }) async {
    final resolvedTone = tone ?? 'friendly';
    if (!_hasSupabase) return _offlineChatFallback(messages, resolvedTone);

    try {
      // The deployed `eraly` function expects { message, history, profile }
      // and returns { reply }. Map the client's message list onto that shape:
      // the last entry is the new message; earlier ones are the history.
      final history = messages.length > 1
          ? messages
                .sublist(0, messages.length - 1)
                .map(
                  (m) => <String, String>{
                    'role': m['role'] ?? 'user',
                    'content': m['text'] ?? '',
                  },
                )
                .toList()
          : <Map<String, String>>[];
      final lastText = messages.isNotEmpty ? (messages.last['text'] ?? '') : '';
      final payload = <String, dynamic>{
        'message': lastText,
        'history': history,
        'profile': <String, dynamic>{
          'tone': resolvedTone,
          'gpa_band': ?gpaBand,
          ...?profileContext,
        },
      };
      final response = await Supabase.instance.client.functions.invoke(
        _kFunctionName,
        body: payload,
      );
      final data = response.data;
      if (data is Map) {
        return (data['reply'] as String?) ??
            _offlineChatFallback(messages, resolvedTone);
      }
      return _offlineChatFallback(messages, resolvedTone);
    } on Exception catch (e) {
      debugPrint('[EralyRepository] chat error: $e');
      return _offlineChatFallback(messages, resolvedTone);
    }
  }

  // ── Event suggestions ─────────────────────────────────────────────────────

  /// Asks Ералы to propose calendar events for [topic].
  /// Returns a list of [ProposedEvent] — none are reviewed yet.
  Future<List<ProposedEvent>> proposeEvents({
    required String topic,
    Map<String, dynamic>? profileContext,
  }) async {
    if (!_hasSupabase) return _offlineEvents(topic);

    try {
      final payload = <String, dynamic>{
        'mode': 'propose_events',
        'topic': topic,
        'profile': ?profileContext,
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
    Map<String, dynamic>? profileContext,
  }) async {
    if (!_hasSupabase) return _offlinePlan(topic);

    try {
      final payload = <String, dynamic>{
        'mode': 'generate_plan',
        'topic': topic,
        'resources': resources,
        'available_time': availableTime,
        'internet_access': internetAccess,
        'profile': ?profileContext,
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

  /// Returns a canned reply shaped by [tone]: 'strict' = direct/demanding,
  /// 'friendly' (default) = warm/supportive.  No essay ghostwriting.
  String _offlineChatFallback(
    List<Map<String, String>> messages,
    String tone,
  ) {
    final isStrict = tone == 'strict';
    final last = messages.isNotEmpty ? messages.last['text'] ?? '' : '';
    final lower = last.toLowerCase();
    final turnCount = messages.length;

    // --- Topic plan triggers ---
    if (lower.contains('ielts')) {
      return isStrict
          ? 'IELTS. Сначала скажи: какие материалы уже есть? '
              'Без чёткого инвентаря план не построить.'
          : 'IELTS — отличная цель! Давай составим персональный план. '
              'Для начала: какие материалы у тебя уже есть? '
              '(учебники, приложения, курсы — перечисли всё)';
    }
    if (lower.contains('sat')) {
      return isStrict
          ? 'SAT требует системной работы. Какими ресурсами пользуешься? '
              'Перечисли конкретно.'
          : 'SAT — серьёзный шаг! Я помогу разбить подготовку на чёткие уроки. '
              'Расскажи, какими ресурсами ты пользуешься?';
    }
    if (lower.contains('ент') || lower.contains('unified')) {
      return isStrict
          ? 'ЕНТ — главный экзамен. Сколько недель до него? '
              'Назови точную дату — составим план без воды.'
          : 'ЕНТ — ключевой экзамен. Хочешь составить поурочный план? '
              'Напиши, сколько времени у тебя есть до экзамена.';
    }
    if (lower.contains('план') ||
        lower.contains('study') ||
        lower.contains('подготовк')) {
      return isStrict
          ? 'Назови тему или экзамен. Потом задам три вопроса — '
              'и составлю план без лишних слов.'
          : 'Конечно, помогу составить план! Назови тему или экзамен, '
              'и я задам несколько вопросов, чтобы сделать план под тебя.';
    }

    // --- Event/calendar triggers ---
    if (lower.contains('мероприят') ||
        lower.contains('событи') ||
        lower.contains('event') ||
        lower.contains('запланир') ||
        lower.contains('календар')) {
      return isStrict
          ? 'Укажи тему мероприятий. Предложу конкретные даты — '
              'ты проверяешь и подтверждаешь.'
          : 'С удовольствием помогу! Напиши тему или цель мероприятий — '
              'я предложу несколько конкретных дат и могу поставить их в '
              'календарь.';
    }

    // --- Scholarship / university ---
    if (lower.contains('стипенди') || lower.contains('scholarship')) {
      return isStrict
          ? 'Стипендии: казахстанские или зарубежные? '
              'Ответь кратко — подберу варианты под профиль.'
          : 'Стипендии — моя любимая тема! Расскажи: '
              'ты смотришь на казахстанские программы или зарубежные? '
              'Это поможет мне точнее подобрать варианты.';
    }
    if (lower.contains('универ') ||
        lower.contains('university') ||
        lower.contains('college') ||
        lower.contains('поступ')) {
      return isStrict
          ? 'Конкретно: в какую страну и в какой университет целишься? '
              'Чем точнее — тем полезнее анализ.'
          : 'Поступление — большой шаг, и я рядом. '
              'В какую страну или университет ты целишься? '
              'Или пока только изучаешь варианты?';
    }

    // --- Greeting ---
    if (lower.contains('привет') ||
        lower.contains('hello') ||
        lower.contains('hi ') ||
        lower == 'hi') {
      return isStrict
          ? 'Начнём. Куда поступаешь и что уже сделал? '
              'Конкретика — основа работы.'
          : 'Привет! Расскажи немного о себе — '
              'куда хочешь поступить, что уже пробовал делать для этого? '
              'Чем больше ты расскажешь, тем точнее я смогу помочь.';
    }

    // --- Generic follow-up ---
    final followUps = isStrict
        ? const [
            'Уточни задачу: экзамен, поступление или что-то другое? Коротко.',
            'Понял. Скажи конкретнее — это для ЕНТ, международного экзамена или вуза?',
            'Хорошо. Что именно нужно — план, анализ шансов или список стипендий?',
          ]
        : const [
            'Интересно! Расскажи подробнее — я хочу понять, чем именно помочь.',
            'Хороший вопрос. Уточни, пожалуйста: ты спрашиваешь про экзамены, поступление или что-то другое?',
            'Понял. Чтобы дать точный ответ, скажи: это для ЕНТ, международного экзамена или для чего-то ещё?',
          ];
    // Rotate through follow-ups based on message count.
    return followUps[turnCount % followUps.length];
  }

  /// Shortens a raw user request to a compact label for offline event titles —
  /// the full prompt must never become an event name.
  String _shortTopic(String topic) {
    final clean = topic.trim().replaceAll(RegExp(r'\s+'), ' ');
    if (clean.length <= 28) return clean;
    return '${clean.substring(0, 28).trimRight()}…';
  }

  List<ProposedEvent> _offlineEvents(String rawTopic) {
    final topic = _shortTopic(rawTopic);
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

  TopicPlan _offlinePlan(String rawTopic) {
    final topic = _shortTopic(rawTopic);
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
