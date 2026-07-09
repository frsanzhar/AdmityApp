import 'package:admity/core/theme/app_tokens.dart';
import 'package:admity/features/mentor/application/assistant_notifier.dart'
    show assistantProviderFor;
import 'package:admity/features/mentor/application/mentor_notifier.dart';
import 'package:admity/features/mentor/domain/assistant_role.dart';
import 'package:admity/features/mentor/domain/ghostwriting_guard.dart';
import 'package:admity/features/mentor/domain/proposed_event.dart';
import 'package:admity/features/mentor/domain/shared_memory.dart';
import 'package:admity/features/mentor/domain/topic_plan.dart';
import 'package:admity/features/mentor/presentation/assistant_chat_screen.dart';
import 'package:admity/features/mentor/presentation/event_review_screen.dart';
import 'package:admity/features/mentor/presentation/mentor_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

// ── Test helpers ──────────────────────────────────────────────────────────────

Widget _themed(Widget child) {
  return ProviderScope(
    child: MaterialApp(
      theme: ThemeData(extensions: [AppTokens.defaults()]),
      home: child,
    ),
  );
}

// ── 1. Ghostwriting guard ─────────────────────────────────────────────────────

void main() {
  group('GhostwritingGuard', () {
    test('detects Russian "напиши эссе"', () {
      expect(
        GhostwritingGuard.isGhostwritingRequest('напиши эссе за меня'),
        isTrue,
      );
    });

    test('detects Russian "написать сочинение"', () {
      expect(
        GhostwritingGuard.isGhostwritingRequest('можешь написать сочинение?'),
        isTrue,
      );
    });

    test('detects Russian "напишите"', () {
      expect(
        GhostwritingGuard.isGhostwritingRequest('Напишите мне текст'),
        isTrue,
      );
    });

    test('detects English "write my essay"', () {
      expect(
        GhostwritingGuard.isGhostwritingRequest('Write my essay for IELTS'),
        isTrue,
      );
    });

    test('detects English "draft my"', () {
      expect(
        GhostwritingGuard.isGhostwritingRequest('draft my personal statement'),
        isTrue,
      );
    });

    test('detects Kazakh "жаз" (write)', () {
      expect(
        GhostwritingGuard.isGhostwritingRequest('жазып бер маған'),
        isTrue,
      );
    });

    test('does NOT block legitimate questions', () {
      expect(
        GhostwritingGuard.isGhostwritingRequest('как улучшить мое эссе?'),
        isFalse,
      );
    });

    test('does NOT block IELTS plan request', () {
      expect(
        GhostwritingGuard.isGhostwritingRequest(
          'помоги мне подготовиться к IELTS',
        ),
        isFalse,
      );
    });

    test('does NOT block general question in English', () {
      expect(
        GhostwritingGuard.isGhostwritingRequest(
          'how can I improve my writing?',
        ),
        isFalse,
      );
    });

    test('deflection message is non-empty', () {
      expect(GhostwritingGuard.deflectionMessage, isNotEmpty);
    });
  });

  // ── 2. Event review save-gate (domain model) ──────────────────────────────

  group('Event review save-gate', () {
    test(
      'CalendarEvent.fromProposed throws AssertionError '
      'when event is not reviewed',
      () {
        final evt = ProposedEvent(
          id: 'test_1',
          title: 'Test Event',
          scheduledAt: DateTime(2026, 7, 1, 10),
        );
        expect(
          () => CalendarEvent.fromProposed(evt),
          throwsA(isA<AssertionError>()),
        );
      },
    );

    test('CalendarEvent.fromProposed succeeds when reviewed=true', () {
      final evt = ProposedEvent(
        id: 'test_2',
        title: 'Reviewed Event',
        scheduledAt: DateTime(2026, 7, 1, 10),
        reviewed: true,
      );
      final calEvt = CalendarEvent.fromProposed(evt);
      expect(calEvt.id, 'test_2');
      expect(calEvt.title, 'Reviewed Event');
    });

    test('markEventsReviewed + commitReviewedEvents on empty list is safe', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      container.read(mentorProvider.notifier)
        ..markEventsReviewed()
        ..commitReviewedEvents();

      expect(container.read(mentorProvider).calendarEvents, isEmpty);
    });
  });

  // ── 3. ProposedEvent time editing ─────────────────────────────────────────

  group('ProposedEvent time editing', () {
    test('copyWith updates scheduledAt correctly', () {
      final original = ProposedEvent(
        id: 'e1',
        title: 'Workshop',
        scheduledAt: DateTime(2026, 7, 1, 10),
      );
      final newTime = DateTime(2026, 7, 5, 14, 30);
      final updated = original.copyWith(scheduledAt: newTime);
      expect(updated.scheduledAt, newTime);
      expect(updated.id, original.id);
    });

    test('updateEventTime on non-existent id is a no-op', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);
      container
          .read(mentorProvider.notifier)
          .updateEventTime('nonexistent', DateTime(2026, 8, 1, 9));
      expect(container.read(mentorProvider).proposedEvents, isEmpty);
    });
  });

  // ── 4. PlanQuestionnaire state machine ────────────────────────────────────

  group('PlanQuestionnaire state machine', () {
    test('initial state has no answers', () {
      const q = PlanQuestionnaire();
      expect(q.isComplete, isFalse);
      expect(q.nextQuestion, PlanQuestion.resources);
    });

    test('after all three answers: isComplete is true', () {
      const q = PlanQuestionnaire(
        resources: 'Учебник',
        availableTime: '2 часа в день',
        internetAccess: true,
      );
      expect(q.isComplete, isTrue);
      expect(q.nextQuestion, isNull);
    });
  });

  // ── 5. MentorNotifier (Ералы legacy) ─────────────────────────────────────

  group('MentorNotifier (Ералы)', () {
    test('startPlanQuestionnaire sets mode to topicQuestionnaire', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);
      container.read(mentorProvider.notifier).startPlanQuestionnaire('IELTS');
      final state = container.read(mentorProvider);
      expect(state.mode, ChatMode.topicQuestionnaire);
      expect(state.pendingTopic, 'IELTS');
    });

    test('initial state mode is general', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);
      expect(container.read(mentorProvider).mode, ChatMode.general);
    });

    test('initial greeting message is present', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);
      final state = container.read(mentorProvider);
      expect(state.messages, isNotEmpty);
      expect(state.messages.first.role, 'assistant');
    });

    test('ghostwriting message gets deflection reply', () async {
      final container = ProviderContainer();
      addTearDown(container.dispose);
      await container.read(mentorProvider.notifier).pickTone('friendly');
      await container
          .read(mentorProvider.notifier)
          .sendMessage('напиши эссе за меня');
      final messages = container.read(mentorProvider).messages;
      expect(messages.last.role, 'assistant');
      expect(messages.last.text, GhostwritingGuard.deflectionMessage);
    });
  });

  // ── 6. AssistantNotifier (new family) ────────────────────────────────────

  group('AssistantNotifier', () {
    test('each role has a non-empty greeting', () {
      for (final role in AssistantRole.values) {
        final container = ProviderContainer();
        addTearDown(container.dispose);
        final state = container.read(assistantProviderFor(role));
        expect(state.messages, isNotEmpty);
        expect(state.messages.first.role, 'assistant');
        expect(state.messages.first.text, isNotEmpty);
      }
    });

    test('ghostwriting is blocked in assistant chat (Азамат)', () async {
      final container = ProviderContainer();
      addTearDown(container.dispose);
      await container
          .read(assistantProviderFor(AssistantRole.azamat).notifier)
          .sendMessage('напишите эссе за меня');
      final msgs =
          container.read(assistantProviderFor(AssistantRole.azamat)).messages;
      expect(msgs.last.role, 'assistant');
      expect(msgs.last.text, GhostwritingGuard.deflectionMessage);
    });

    test('ghostwriting is blocked in assistant chat (Аружан)', () async {
      final container = ProviderContainer();
      addTearDown(container.dispose);
      await container
          .read(assistantProviderFor(AssistantRole.aruzhan).notifier)
          .sendMessage('write my essay for me');
      final msgs =
          container.read(assistantProviderFor(AssistantRole.aruzhan)).messages;
      expect(msgs.last.role, 'assistant');
      expect(msgs.last.text, GhostwritingGuard.deflectionMessage);
    });

    test('setAttachment stores path/name/isImage', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);
      container
          .read(assistantProviderFor(AssistantRole.aruzhan).notifier)
          .setAttachment(
            path: '/tmp/hw.jpg',
            name: 'hw.jpg',
            isImage: true,
          );
      final state = container.read(assistantProviderFor(AssistantRole.aruzhan));
      expect(state.pendingAttachmentPath, '/tmp/hw.jpg');
      expect(state.pendingAttachmentName, 'hw.jpg');
      expect(state.pendingAttachmentIsImage, isTrue);
    });

    test('clearAttachment removes pending attachment', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);
      final notifier =
          container.read(assistantProviderFor(AssistantRole.aruzhan).notifier);
      notifier.setAttachment(
        path: '/tmp/hw.jpg',
        name: 'hw.jpg',
        isImage: true,
      );
      notifier.clearAttachment();
      final state = container.read(assistantProviderFor(AssistantRole.aruzhan));
      expect(state.pendingAttachmentPath, isNull);
      expect(state.pendingAttachmentName, isNull);
    });

    test('only aruzhan supports attachments (domain flag)', () {
      expect(AssistantRole.aruzhan.supportsAttachments, isTrue);
      expect(AssistantRole.eraly.supportsAttachments, isFalse);
      expect(AssistantRole.azamat.supportsAttachments, isFalse);
      expect(AssistantRole.madina.supportsAttachments, isFalse);
    });
  });

  // ── 7. SharedMemory domain model ─────────────────────────────────────────

  group('SharedMemory', () {
    test('withSummary adds a new entry', () {
      const mem = SharedMemory();
      final updated = mem.withSummary('eraly', 'Обсуждали IELTS');
      expect(updated.summaries['eraly'], 'Обсуждали IELTS');
    });

    test('othersFor excludes the current role', () {
      const mem = SharedMemory(
        summaries: {
          'eraly': 'eraly summary',
          'azamat': 'azamat summary',
          'madina': 'madina summary',
        },
      );
      final others = mem.othersFor('eraly');
      expect(others.containsKey('eraly'), isFalse);
      expect(others.containsKey('azamat'), isTrue);
      expect(others.containsKey('madina'), isTrue);
    });

    test('othersFor returns all when role has no summary', () {
      const mem = SharedMemory(
        summaries: {'azamat': 'essay discussion', 'madina': 'docs chat'},
      );
      final others = mem.othersFor('eraly');
      expect(others.length, 2);
    });
  });

  // ── 8. AssistantRole metadata ─────────────────────────────────────────────

  group('AssistantRole metadata', () {
    test('each role has a unique hive key', () {
      final keys = AssistantRole.values.map((r) => r.hiveKey).toSet();
      expect(keys.length, AssistantRole.values.length);
    });

    test('each role has a non-empty tagline', () {
      for (final role in AssistantRole.values) {
        expect(role.tagline, isNotEmpty);
      }
    });

    test('each role has a non-empty greeting', () {
      for (final role in AssistantRole.values) {
        expect(role.greeting, isNotEmpty);
      }
    });
  });

  // ── 9. MentorScreen hub: no layout errors ─────────────────────────────────

  testWidgets('MentorScreen (hub) builds with no framework/layout errors', (
    tester,
  ) async {
    final errors = <FlutterErrorDetails>[];
    final prev = FlutterError.onError;
    FlutterError.onError = errors.add;
    addTearDown(() => FlutterError.onError = prev);

    await tester.pumpWidget(_themed(const MentorScreen()));
    await tester.pumpAndSettle();

    expect(
      errors,
      isEmpty,
      reason: 'no framework/layout errors on MentorScreen hub',
    );
  });

  testWidgets('MentorScreen hub shows 4 assistant cards', (tester) async {
    await tester.pumpWidget(_themed(const MentorScreen()));
    await tester.pumpAndSettle();

    // Each card shows the assistant's display name.
    expect(find.text('Ералы'), findsOneWidget);
    expect(find.text('Азамат'), findsOneWidget);
    expect(find.text('Мадина'), findsOneWidget);
    expect(find.text('Аружан'), findsOneWidget);
  });

  testWidgets('MentorScreen hub shows role labels', (tester) async {
    await tester.pumpWidget(_themed(const MentorScreen()));
    await tester.pumpAndSettle();

    expect(find.text('Наставник'), findsOneWidget);
    expect(find.text('Эссе-коуч'), findsOneWidget);
    expect(find.text('Документы'), findsOneWidget);
    expect(find.text('Учитель'), findsOneWidget);
  });

  testWidgets(
    'MentorScreen hub does NOT show event/plan CTAs',
    (tester) async {
      await tester.pumpWidget(_themed(const MentorScreen()));
      await tester.pumpAndSettle();
      expect(find.textContaining('Проверить все мероприятия'), findsNothing);
      expect(find.textContaining('Открыть план'), findsNothing);
    },
  );

  // ── 10. AssistantChatScreen widget: no layout errors ──────────────────────

  testWidgets(
    'AssistantChatScreen(azamat) builds with no layout errors',
    (tester) async {
      final errors = <FlutterErrorDetails>[];
      final prev = FlutterError.onError;
      FlutterError.onError = errors.add;
      addTearDown(() => FlutterError.onError = prev);

      await tester.pumpWidget(
        _themed(const AssistantChatScreen(role: AssistantRole.azamat)),
      );
      await tester.pumpAndSettle();

      expect(
        errors,
        isEmpty,
        reason: 'no layout errors on AssistantChatScreen(azamat)',
      );
    },
  );

  testWidgets(
    'AssistantChatScreen(aruzhan) shows attach button',
    (tester) async {
      await tester.pumpWidget(
        _themed(const AssistantChatScreen(role: AssistantRole.aruzhan)),
      );
      await tester.pumpAndSettle();
      expect(find.byIcon(Icons.attach_file_rounded), findsOneWidget);
    },
  );

  testWidgets(
    'AssistantChatScreen(azamat) does NOT show attach button',
    (tester) async {
      await tester.pumpWidget(
        _themed(const AssistantChatScreen(role: AssistantRole.azamat)),
      );
      await tester.pumpAndSettle();
      expect(find.byIcon(Icons.attach_file_rounded), findsNothing);
    },
  );

  testWidgets('AssistantChatScreen shows send button', (tester) async {
    await tester.pumpWidget(
      _themed(const AssistantChatScreen(role: AssistantRole.madina)),
    );
    await tester.pumpAndSettle();
    expect(find.byIcon(Icons.send_rounded), findsOneWidget);
  });

  // ── 11. EralyChatScreen widget: no layout errors ──────────────────────────

  testWidgets('EralyChatScreen builds with no layout errors', (tester) async {
    final errors = <FlutterErrorDetails>[];
    final prev = FlutterError.onError;
    FlutterError.onError = errors.add;
    addTearDown(() => FlutterError.onError = prev);

    await tester.pumpWidget(_themed(const EralyChatScreen()));
    await tester.pumpAndSettle();

    expect(
      errors,
      isEmpty,
      reason: 'no layout errors on EralyChatScreen',
    );
  });

  testWidgets('EralyChatScreen has input field and send button', (
    tester,
  ) async {
    await tester.pumpWidget(_themed(const EralyChatScreen()));
    await tester.pumpAndSettle();
    expect(find.byType(TextField), findsOneWidget);
    expect(find.byIcon(Icons.send_rounded), findsOneWidget);
  });

  testWidgets('EralyChatScreen shows no CTAs on first open', (tester) async {
    await tester.pumpWidget(_themed(const EralyChatScreen()));
    await tester.pumpAndSettle();
    expect(find.textContaining('Проверить все мероприятия'), findsNothing);
    expect(find.textContaining('Открыть план'), findsNothing);
  });

  // ── 12. EventReviewScreen: no layout errors ────────────────────────────────

  testWidgets('EventReviewScreen builds with no layout errors', (tester) async {
    final errors = <FlutterErrorDetails>[];
    final prev = FlutterError.onError;
    FlutterError.onError = errors.add;
    addTearDown(() => FlutterError.onError = prev);

    await tester.pumpWidget(_themed(const EventReviewScreen()));
    await tester.pumpAndSettle();

    expect(
      errors,
      isEmpty,
      reason: 'no framework/layout errors on EventReviewScreen',
    );
  });

  testWidgets(
    'EventReviewScreen shows empty-state message when no events',
    (tester) async {
      await tester.pumpWidget(_themed(const EventReviewScreen()));
      await tester.pumpAndSettle();
      expect(find.text('Нет предложенных мероприятий'), findsOneWidget);
    },
  );
}
