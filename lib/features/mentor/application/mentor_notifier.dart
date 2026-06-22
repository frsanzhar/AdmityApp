import 'dart:math' as math;

import 'package:admity/features/mentor/data/eraly_repository.dart';
import 'package:admity/features/mentor/domain/chat_message.dart';
import 'package:admity/features/mentor/domain/ghostwriting_guard.dart';
import 'package:admity/features/mentor/domain/proposed_event.dart';
import 'package:admity/features/mentor/domain/topic_plan.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// ── Chat mode ────────────────────────────────────────────────────────────────

/// Which conversational mode the chat is currently in.
enum ChatMode {
  /// Free-form conversation.
  general,

  /// User has asked for event planning; Ералы is proposing events.
  eventPlanning,

  /// User has asked for a topic plan; Ералы is running the questionnaire.
  topicQuestionnaire,

  /// Ералы has generated a plan and is displaying it.
  showingPlan,
}

// ── State ────────────────────────────────────────────────────────────────────

class MentorState {
  const MentorState({
    required this.messages,
    required this.mode,
    required this.isLoading,
    required this.proposedEvents,
    required this.calendarEvents,
    required this.questionnaire,
    required this.topicPlan,
    required this.pendingTopic,
  });

  factory MentorState.initial() => const MentorState(
    messages: [],
    mode: ChatMode.general,
    isLoading: false,
    proposedEvents: [],
    calendarEvents: [],
    questionnaire: PlanQuestionnaire(),
    topicPlan: null,
    pendingTopic: null,
  );

  final List<ChatMessage> messages;
  final ChatMode mode;
  final bool isLoading;

  /// Events proposed by Ералы — NOT yet saved. Review gate is enforced here.
  final List<ProposedEvent> proposedEvents;

  /// Events that have passed the review gate and been committed to the calendar.
  final List<CalendarEvent> calendarEvents;

  /// Questionnaire state for topic-plan generation.
  final PlanQuestionnaire questionnaire;

  /// The generated plan (null until complete).
  final TopicPlan? topicPlan;

  /// The topic the user named before starting the questionnaire.
  final String? pendingTopic;

  MentorState copyWith({
    List<ChatMessage>? messages,
    ChatMode? mode,
    bool? isLoading,
    List<ProposedEvent>? proposedEvents,
    List<CalendarEvent>? calendarEvents,
    PlanQuestionnaire? questionnaire,
    TopicPlan? topicPlan,
    String? pendingTopic,
  }) {
    return MentorState(
      messages: messages ?? this.messages,
      mode: mode ?? this.mode,
      isLoading: isLoading ?? this.isLoading,
      proposedEvents: proposedEvents ?? this.proposedEvents,
      calendarEvents: calendarEvents ?? this.calendarEvents,
      questionnaire: questionnaire ?? this.questionnaire,
      topicPlan: topicPlan ?? this.topicPlan,
      pendingTopic: pendingTopic ?? this.pendingTopic,
    );
  }
}

// ── Notifier ─────────────────────────────────────────────────────────────────

/// Lightweight unique-id generator (no external package required).
String _newId() {
  final r = math.Random();
  final n = r.nextInt(0x7fffffff);
  return '${DateTime.now().microsecondsSinceEpoch}_$n';
}

class MentorNotifier extends Notifier<MentorState> {
  @override
  MentorState build() {
    // Greet the user on first load.
    final greeting = ChatMessage(
      id: _newId(),
      role: 'assistant',
      text:
          'Привет! Я Ералы — твой AI-наставник по поступлению.\n\n'
          'Могу помочь с тремя вещами:\n'
          '1. Составить план подготовки к экзамену (IELTS, SAT, ЕНТ).\n'
          '2. Запланировать мероприятия в твоём календаре.\n'
          '3. Ответить на вопросы про стипендии и университеты.\n\n'
          'С чего начнём?',
      timestamp: DateTime.now(),
    );
    return MentorState.initial().copyWith(messages: [greeting]);
  }

  EralyRepository get _repo => ref.read(eralyRepositoryProvider);

  // ── Public API ────────────────────────────────────────────────────────────

  /// Sends [text] from the user and gets Ералы's response.
  Future<void> sendMessage(String text) async {
    if (text.trim().isEmpty) return;

    // 1. Ghostwriting guard — deflect immediately, no LLM round-trip.
    if (GhostwritingGuard.isGhostwritingRequest(text)) {
      _appendUser(text);
      _appendAssistant(GhostwritingGuard.deflectionMessage);
      return;
    }

    _appendUser(text);

    // 2. Route to the right mode handler.
    switch (state.mode) {
      case ChatMode.topicQuestionnaire:
        await _handleQuestionnaireAnswer(text);
      case ChatMode.eventPlanning:
      case ChatMode.general:
      case ChatMode.showingPlan:
        await _handleGeneralMessage(text);
    }
  }

  // ── Review gate ───────────────────────────────────────────────────────────

  /// Marks all proposed events as reviewed.
  ///
  /// This is the mandatory step before [commitReviewedEvents] can succeed.
  void markEventsReviewed() {
    final reviewed = state.proposedEvents
        .map((e) => e.copyWith(reviewed: true))
        .toList();
    state = state.copyWith(proposedEvents: reviewed);
  }

  /// Updates the scheduled time of a proposed event.
  ///
  /// Time editing is allowed before and after the review step.
  void updateEventTime(String eventId, DateTime newTime) {
    final updated = state.proposedEvents.map((e) {
      if (e.id == eventId) return e.copyWith(scheduledAt: newTime);
      return e;
    }).toList();
    state = state.copyWith(proposedEvents: updated);
  }

  /// Commits all reviewed events to the calendar.
  ///
  /// Throws [StateError] if any event has not been reviewed yet.
  /// The UI calls [markEventsReviewed] first — this is the hard save-gate.
  void commitReviewedEvents() {
    final unreviewed = state.proposedEvents.where((e) => !e.reviewed).toList();
    if (unreviewed.isNotEmpty) {
      throw StateError(
        'Cannot save events before the review step is completed. '
        'Call markEventsReviewed() first.',
      );
    }

    final newEvents = state.proposedEvents
        .map(CalendarEvent.fromProposed)
        .toList();
    state = state.copyWith(
      calendarEvents: [...state.calendarEvents, ...newEvents],
      proposedEvents: const [],
      mode: ChatMode.general,
    );

    _appendAssistant(
      'Все мероприятия сохранены в календарь! '
      'Ты можешь просмотреть их в разделе «Главная». '
      'Чем ещё могу помочь?',
    );
  }

  // ── Plan questionnaire ────────────────────────────────────────────────────

  /// Starts the topic-plan questionnaire for [topic].
  void startPlanQuestionnaire(String topic) {
    state = state.copyWith(
      mode: ChatMode.topicQuestionnaire,
      pendingTopic: topic,
      questionnaire: const PlanQuestionnaire(),
    );
    _appendAssistant(_questionText(PlanQuestion.resources));
  }

  // ── Private helpers ───────────────────────────────────────────────────────

  Future<void> _handleGeneralMessage(String text) async {
    final lower = text.toLowerCase();

    // Detect intent: event planning
    if (_isEventIntent(lower)) {
      state = state.copyWith(mode: ChatMode.eventPlanning, isLoading: true);
      _appendAssistant(
        'Отлично! Дай мне секунду — предложу несколько мероприятий...',
      );
      final events = await _repo.proposeEvents(topic: text);
      state = state.copyWith(
        proposedEvents: events,
        isLoading: false,
      );
      if (events.isNotEmpty) {
        _appendAssistant(
          'Я подготовил ${events.length} мероприятия. '
          'Нажми «Проверить все мероприятия», чтобы просмотреть и изменить время.',
        );
      }
      return;
    }

    // Detect intent: topic plan
    final topic = _extractPlanTopic(lower);
    if (topic != null) {
      startPlanQuestionnaire(topic);
      return;
    }

    // General chat
    state = state.copyWith(isLoading: true);
    final history = state.messages
        .where((m) => m.id != state.messages.last.id)
        .map((m) => {'role': m.role, 'text': m.text})
        .toList();
    final reply = await _repo.chat(messages: history);
    state = state.copyWith(isLoading: false);
    _appendAssistant(reply);
  }

  Future<void> _handleQuestionnaireAnswer(String answer) async {
    final q = state.questionnaire;
    final next = q.nextQuestion;

    if (next == null) {
      // All answers already collected — shouldn't happen, but guard it.
      await _finishQuestionnaire();
      return;
    }

    PlanQuestionnaire updated;
    switch (next) {
      case PlanQuestion.resources:
        updated = q.copyWith(resources: answer);
      case PlanQuestion.availableTime:
        updated = q.copyWith(availableTime: answer);
      case PlanQuestion.internetAccess:
        final hasInternet = _parseYesNo(answer);
        updated = q.copyWith(internetAccess: hasInternet);
    }

    state = state.copyWith(questionnaire: updated);

    final nextAfter = updated.nextQuestion;
    if (nextAfter != null) {
      _appendAssistant(_questionText(nextAfter));
    } else {
      await _finishQuestionnaire();
    }
  }

  Future<void> _finishQuestionnaire() async {
    final q = state.questionnaire;
    final topic = state.pendingTopic ?? 'тема';
    state = state.copyWith(isLoading: true);
    _appendAssistant('Составляю план — одну секунду...');

    final plan = await _repo.generatePlan(
      topic: topic,
      resources: q.resources ?? '',
      availableTime: q.availableTime ?? '',
      internetAccess: q.internetAccess ?? false,
    );

    state = state.copyWith(
      isLoading: false,
      topicPlan: plan,
      mode: ChatMode.showingPlan,
    );

    _appendAssistant(
      'Готово! Я составил план «${plan.topic}» из ${plan.lessons.length} уроков. '
      'Прокрути вниз, чтобы увидеть его. Если хочешь что-то изменить — спроси!',
    );
  }

  void _appendUser(String text) {
    final msg = ChatMessage(
      id: _newId(),
      role: 'user',
      text: text,
      timestamp: DateTime.now(),
    );
    state = state.copyWith(messages: [...state.messages, msg]);
  }

  void _appendAssistant(String text) {
    final msg = ChatMessage(
      id: _newId(),
      role: 'assistant',
      text: text,
      timestamp: DateTime.now(),
    );
    state = state.copyWith(messages: [...state.messages, msg]);
  }

  static bool _isEventIntent(String lower) {
    const triggers = [
      'мероприят',
      'событи',
      'event',
      'добав',
      'запланир',
      'schedule',
      'calendar',
    ];
    return triggers.any(lower.contains);
  }

  static String? _extractPlanTopic(String lower) {
    const planTriggers = [
      'план',
      'подготовк',
      'study plan',
      'ielts',
      'sat',
      'ент',
    ];
    if (planTriggers.any(lower.contains)) {
      // Heuristic: return the whole message as the "topic seed"
      return lower.trim();
    }
    return null;
  }

  static bool _parseYesNo(String answer) {
    final l = answer.toLowerCase();
    return l.contains('да') ||
        l.contains('yes') ||
        l.contains('иа') || // KZ "иә" (yes)
        l.contains('есть');
  }

  static String _questionText(PlanQuestion q) {
    switch (q) {
      case PlanQuestion.resources:
        return 'Хорошо, начнём! Какие учебные материалы у тебя есть? '
            '(книги, онлайн-курсы, приложения — перечисли, что имеется)';
      case PlanQuestion.availableTime:
        return 'Понял. Сколько времени в неделю ты можешь уделять подготовке? '
            '(например: «2 часа в день» или «10 часов в неделю»)';
      case PlanQuestion.internetAccess:
        return 'Есть ли у тебя стабильный доступ к интернету для онлайн-ресурсов? '
            '(да / нет)';
    }
  }
}

// ── Provider ──────────────────────────────────────────────────────────────────

final mentorProvider = NotifierProvider<MentorNotifier, MentorState>(
  MentorNotifier.new,
);
