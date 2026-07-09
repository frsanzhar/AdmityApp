import 'dart:math' as math;

import 'package:admity/features/mentor/data/eraly_repository.dart';
import 'package:admity/features/mentor/domain/chat_message.dart';
import 'package:admity/features/mentor/domain/ghostwriting_guard.dart';
import 'package:admity/features/mentor/domain/proposed_event.dart';
import 'package:admity/features/mentor/domain/topic_plan.dart';
import 'package:admity/features/profile/application/profile_notifier.dart';
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
    required this.needsTonePick,
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
    needsTonePick: false,
  );

  final List<ChatMessage> messages;
  final ChatMode mode;
  final bool isLoading;

  /// True when the user has not yet chosen a tone and the picker should be
  /// displayed before the input bar.
  final bool needsTonePick;

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
    bool? needsTonePick,
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
      needsTonePick: needsTonePick ?? this.needsTonePick,
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
    // Use read (not watch) so a later profile save does not re-run build()
    // and wipe the chat history.  Profile may still be loading on very first
    // app launch — in that case we start with the tone-picker prompt and defer
    // the full personalisation to [_initFromProfile].
    final profileState = ref.read(profileProvider);
    if (profileState.isLoading) {
      // Schedule a check once the profile finishes loading.
      // unawaited: intentional fire-and-forget inside a sync build().
      // ignore: discarded_futures
      Future.microtask(_initFromProfile);
      // Return the tone-picker prompt immediately so the screen is never empty.
      return _initialStateForProfile(null);
    }
    return _initialStateForProfile(profileState.profile.soundPreference);
  }

  /// Called asynchronously when the build-time profile was still loading.
  Future<void> _initFromProfile() async {
    // Wait for profile to finish loading (poll — maximum ~2 s).
    for (var i = 0; i < 40; i++) {
      if (!ref.mounted) return;
      final ps = ref.read(profileProvider);
      if (!ps.isLoading) {
        if (!ref.mounted) return;
        state = _initialStateForProfile(ps.profile.soundPreference);
        return;
      }
      await Future<void>.delayed(const Duration(milliseconds: 50));
    }
    // Timed out — treat as first-time user (no tone chosen).
    if (!ref.mounted) return;
    state = _initialStateForProfile(null);
  }

  /// Builds the initial [MentorState] based on the stored [soundPreference].
  MentorState _initialStateForProfile(String? soundPreference) {
    if (soundPreference != null) {
      // Tone already set — greet normally.
      final greeting = ChatMessage(
        id: _newId(),
        role: 'assistant',
        text: _greetingForTone(soundPreference),
        timestamp: DateTime.now(),
      );
      return MentorState.initial().copyWith(messages: [greeting]);
    }

    // First open — show tone-picker prompt before anything else.
    final tonePrompt = ChatMessage(
      id: _newId(),
      role: 'assistant',
      text:
          'Привет! Я Ералы — твой AI-наставник по поступлению. '
          'Прежде чем начать, выбери, как мне с тобой общаться:',
      timestamp: DateTime.now(),
    );
    return MentorState.initial().copyWith(
      messages: [tonePrompt],
      needsTonePick: true,
    );
  }

  EralyRepository get _repo => ref.read(eralyRepositoryProvider);

  /// Returns the current tone from the profile, defaulting to 'friendly'.
  String get _tone =>
      ref.read(profileProvider).profile.soundPreference ?? 'friendly';

  /// PII-minimised student context — read fresh on EVERY request, so both the
  /// onboarding answers and any later profile edits reach Ералы automatically.
  Map<String, dynamic> get _profileContext =>
      buildEralyProfileContext(ref.read(profileProvider).profile);

  // ── Tone pick ─────────────────────────────────────────────────────────────

  /// Called by the UI when the student picks 'strict' or 'friendly'.
  ///
  /// Saves to profile and appends a personalised greeting from Ералы.
  Future<void> pickTone(String tone) async {
    // Persist immediately.
    final currentProfile = ref.read(profileProvider).profile;
    await ref
        .read(profileProvider.notifier)
        .saveProfile(currentProfile.copyWith(soundPreference: tone));

    state = state.copyWith(needsTonePick: false);
    _appendAssistant(_greetingForTone(tone));
  }

  static String _greetingForTone(String tone) {
    if (tone == 'strict') {
      return 'Хорошо. Работаем серьёзно: ставим цели, держим дисциплину '
          'и не отвлекаемся на лишнее. Расскажи — куда поступаешь и '
          'что уже сделал для этого?';
    }
    return 'Отлично! Я рядом — буду поддерживать и помогать на каждом шаге. '
        'Расскажи о себе: куда хочешь поступить и с чего начнём?';
  }

  // ── Public API ────────────────────────────────────────────────────────────

  /// Sends [text] from the user and gets Ералы's response.
  ///
  /// Ignored while the tone picker is still open — the student must choose a
  /// tone before free-form conversation begins.
  Future<void> sendMessage(String text) async {
    if (text.trim().isEmpty) return;
    if (state.needsTonePick) return;

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
      final events = await _repo.proposeEvents(
        topic: text,
        profileContext: _profileContext,
      );
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

    // General chat. IMPORTANT: include ALL messages — the last one is the
    // user's new text, which the repository sends as the current message
    // (earlier code dropped it, so Ералы replied to stale history).
    state = state.copyWith(isLoading: true);
    final history = state.messages
        .map((m) => {'role': m.role, 'text': m.text})
        .toList();
    final reply = await _repo.chat(
      messages: history,
      tone: _tone,
      profileContext: _profileContext,
    );
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
      profileContext: _profileContext,
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
