import 'dart:async';
import 'dart:convert';
import 'dart:math' as math;

import 'package:admity/features/mentor/application/shared_memory_notifier.dart';
import 'package:admity/features/mentor/data/eraly_repository.dart';
import 'package:admity/features/mentor/domain/assistant_role.dart';
import 'package:admity/features/mentor/domain/chat_message.dart';
import 'package:admity/features/mentor/domain/ghostwriting_guard.dart';
import 'package:admity/features/profile/application/profile_notifier.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';

// ── State ─────────────────────────────────────────────────────────────────────

/// State for a single assistant chat session.
class AssistantState {
  const AssistantState({
    required this.messages,
    required this.isLoading,
    this.pendingAttachmentPath,
    this.pendingAttachmentName,
    this.pendingAttachmentIsImage = false,
  });

  /// Creates the initial state: empty history plus the opening greeting.
  factory AssistantState.initial(AssistantRole role) {
    final greeting = ChatMessage(
      id: _newId(),
      role: 'assistant',
      text: role.greeting,
      timestamp: DateTime.now(),
    );
    return AssistantState(messages: [greeting], isLoading: false);
  }

  /// Full chat history (oldest first).
  final List<ChatMessage> messages;

  /// True while waiting for the Edge Function to respond.
  final bool isLoading;

  /// File path of a picked attachment — cleared after the message is sent.
  final String? pendingAttachmentPath;

  /// Display name of the pending attachment.
  final String? pendingAttachmentName;

  /// True when [pendingAttachmentPath] points to an image (vs. other file type).
  final bool pendingAttachmentIsImage;

  /// Returns a copy with all attachment fields cleared.
  AssistantState withoutAttachment() => AssistantState(
        messages: messages,
        isLoading: isLoading,
      );

  /// Creates a copy with optional field overrides.
  AssistantState copyWith({
    List<ChatMessage>? messages,
    bool? isLoading,
    String? pendingAttachmentPath,
    String? pendingAttachmentName,
    bool? pendingAttachmentIsImage,
  }) {
    return AssistantState(
      messages: messages ?? this.messages,
      isLoading: isLoading ?? this.isLoading,
      pendingAttachmentPath:
          pendingAttachmentPath ?? this.pendingAttachmentPath,
      pendingAttachmentName:
          pendingAttachmentName ?? this.pendingAttachmentName,
      pendingAttachmentIsImage:
          pendingAttachmentIsImage ?? this.pendingAttachmentIsImage,
    );
  }
}

// ── ID helper ─────────────────────────────────────────────────────────────────

/// Lightweight unique-ID generator (no external package required).
String _newId() {
  final r = math.Random();
  final n = r.nextInt(0x7fffffff);
  return '${DateTime.now().microsecondsSinceEpoch}_$n';
}

// ── Notifier ──────────────────────────────────────────────────────────────────

/// Per-assistant notifier.
///
/// Riverpod 3 does not expose a non-codegen family notifier, so each role
/// has its own provider instance — see [assistantProviderFor].  The role is
/// injected via the constructor, which the provider factory calls.
///
/// Responsibilities:
/// - Loads/persists chat history to a per-role Hive box.
/// - Applies the ghostwriting guard before every send (all roles, all langs).
/// - Injects shared-memory context (other assistants' summaries) into every
///   LLM request so the team of assistants is contextually coherent.
/// - Updates the shared-memory summary after each assistant reply.
/// - Handles file/image attachments for [AssistantRole.aruzhan].
class AssistantNotifier extends Notifier<AssistantState> {
  /// Creates the notifier for the given role.  Called by the provider factory.
  AssistantNotifier(this._role);

  final AssistantRole _role;

  @override
  AssistantState build() {
    // History load is async — fire it and return the greeting immediately
    // so the screen is never blank.  Wrapped in runZonedGuarded so that any
    // Hive Zone-level errors (e.g. uninitialized Hive in unit tests) are
    // swallowed here and never reach the test-framework's zone handler.
    runZonedGuarded<void>(
      () {
        unawaited(Future.microtask(_loadHistory));
      },
      (e, s) =>
          debugPrint('[AssistantNotifier(${_role.name})] history zone: $e'),
    );
    return AssistantState.initial(_role);
  }

  // ── Public API ─────────────────────────────────────────────────────────────

  /// Sends [text] to the assistant.
  ///
  /// If a pending attachment exists it is included in the request then cleared.
  /// The ghostwriting guard is checked first — applies to every role.
  Future<void> sendMessage(String text) async {
    if (text.trim().isEmpty) return;

    // 1. Ghostwriting guard — same deflection for all roles, all languages.
    if (GhostwritingGuard.isGhostwritingRequest(text)) {
      _appendUser(text);
      _appendAssistant(GhostwritingGuard.deflectionMessage);
      return;
    }

    // 2. Capture and clear pending attachment.
    final attachPath = state.pendingAttachmentPath;
    final attachName = state.pendingAttachmentName;
    final attachIsImage = state.pendingAttachmentIsImage;

    // Show attachment label inline in the user bubble.
    final displayText =
        attachName != null ? '$text\n📎 $attachName' : text;
    _appendUser(displayText);
    state = state.withoutAttachment();
    state = state.copyWith(isLoading: true);

    // 3. Build context payloads.
    final profileCtx = buildEralyProfileContext(
      ref.read(profileProvider).profile,
    );
    final others = ref.read(sharedMemoryProvider).othersFor(_role.name);
    final repo = ref.read(eralyRepositoryProvider);

    // Full conversation for context — last entry is the new user message.
    final allMessages = state.messages
        .map(
          (m) => <String, String>{'role': m.role, 'text': m.text},
        )
        .toList();

    // 4. Call Edge Function (online) or fall back offline.
    String reply;
    if (attachPath != null && attachIsImage) {
      reply = await repo.chatWithImage(
        role: _role,
        text: text,
        imagePath: attachPath,
        history: allMessages,
        profileContext: profileCtx,
        othersContext: others,
      );
    } else {
      reply = await repo.chatAs(
        role: _role,
        messages: allMessages,
        profileContext: profileCtx,
        othersContext: others,
      );
    }

    if (!ref.mounted) return;

    // 5. Append reply and refresh shared memory.
    state = state.copyWith(isLoading: false);
    _appendAssistant(reply);
    _refreshSharedMemory();
  }

  /// Registers a pending file/image attachment for the next message.
  void setAttachment({
    required String path,
    required String name,
    required bool isImage,
  }) {
    state = state.copyWith(
      pendingAttachmentPath: path,
      pendingAttachmentName: name,
      pendingAttachmentIsImage: isImage,
    );
  }

  /// Removes the pending attachment without sending.
  void clearAttachment() {
    state = state.withoutAttachment();
  }

  // ── Shared memory ─────────────────────────────────────────────────────────

  /// Generates a 2–3 line summary from recent messages and stores it in
  /// [sharedMemoryProvider] so the other assistants can read it.
  void _refreshSharedMemory() {
    final recent = state.messages.reversed.take(5).toList().reversed.toList();
    final summary = recent.map((m) {
      final who = m.isUser ? 'Ученик' : _role.displayName;
      final txt =
          m.text.length > 90 ? '${m.text.substring(0, 90)}…' : m.text;
      return '$who: $txt';
    }).join('\n');

    unawaited(
      ref
          .read(sharedMemoryProvider.notifier)
          .updateSummary(_role.name, summary),
    );
  }

  // ── Hive persistence ──────────────────────────────────────────────────────

  Future<void> _loadHistory() async {
    try {
      final boxName = _role.hiveKey;
      if (!Hive.isBoxOpen(boxName)) {
        await Hive.openBox<String>(boxName);
      }
      final box = Hive.box<String>(boxName);
      if (box.isEmpty) return;

      final msgs = box.values
          .map((raw) {
            final map = jsonDecode(raw) as Map<String, dynamic>;
            return ChatMessage(
              id: map['id'] as String,
              role: map['role'] as String,
              text: map['text'] as String,
              timestamp: DateTime.parse(map['ts'] as String),
            );
          })
          .toList()
        ..sort((a, b) => a.timestamp.compareTo(b.timestamp));

      if (msgs.isNotEmpty && ref.mounted) {
        state = AssistantState(messages: msgs, isLoading: false);
      }
    } on Object catch (e) {
      debugPrint('[AssistantNotifier(${_role.name})] loadHistory error: $e');
    }
  }

  Future<void> _persistMsg(ChatMessage msg) async {
    try {
      final boxName = _role.hiveKey;
      if (!Hive.isBoxOpen(boxName)) {
        await Hive.openBox<String>(boxName);
      }
      await Hive.box<String>(boxName).put(
        msg.id,
        jsonEncode(<String, String>{
          'id': msg.id,
          'role': msg.role,
          'text': msg.text,
          'ts': msg.timestamp.toIso8601String(),
        }),
      );
    } on Object catch (e) {
      debugPrint('[AssistantNotifier(${_role.name})] persistMsg error: $e');
    }
  }

  // ── Message helpers ───────────────────────────────────────────────────────

  void _appendUser(String text) {
    final msg = ChatMessage(
      id: _newId(),
      role: 'user',
      text: text,
      timestamp: DateTime.now(),
    );
    state = state.copyWith(messages: [...state.messages, msg]);
    _fireAndPersist(msg);
  }

  void _appendAssistant(String text) {
    final msg = ChatMessage(
      id: _newId(),
      role: 'assistant',
      text: text,
      timestamp: DateTime.now(),
    );
    state = state.copyWith(messages: [...state.messages, msg]);
    _fireAndPersist(msg);
  }

  /// Persists [msg] to Hive in a guarded zone so that Hive Zone-level errors
  /// (e.g. uninitialized Hive in unit tests) never reach the test framework.
  void _fireAndPersist(ChatMessage msg) {
    runZonedGuarded<void>(
      () {
        unawaited(_persistMsg(msg));
      },
      (e, s) =>
          debugPrint('[AssistantNotifier(${_role.name})] persist zone: $e'),
    );
  }
}

// ── Providers ─────────────────────────────────────────────────────────────────

/// Returns the [NotifierProvider] for the given [role].
///
/// Each role has its own provider created with a constructor-arg factory
/// (Riverpod 3 does not expose a non-codegen family notifier).
/// This function dispatches to the correct one.
///
/// Usage:
/// ```dart
/// ref.watch(assistantProviderFor(AssistantRole.azamat))
/// ref.read(assistantProviderFor(AssistantRole.aruzhan).notifier).sendMessage('…')
/// ```
NotifierProvider<AssistantNotifier, AssistantState> assistantProviderFor(
  AssistantRole role,
) =>
    switch (role) {
      AssistantRole.eraly => _eralyAssistantProvider,
      AssistantRole.azamat => _azamatProvider,
      AssistantRole.madina => _madinaProvider,
      AssistantRole.aruzhan => _aruzhanProvider,
    };

final _eralyAssistantProvider =
    NotifierProvider<AssistantNotifier, AssistantState>(
  () => AssistantNotifier(AssistantRole.eraly),
);

final _azamatProvider =
    NotifierProvider<AssistantNotifier, AssistantState>(
  () => AssistantNotifier(AssistantRole.azamat),
);

final _madinaProvider =
    NotifierProvider<AssistantNotifier, AssistantState>(
  () => AssistantNotifier(AssistantRole.madina),
);

final _aruzhanProvider =
    NotifierProvider<AssistantNotifier, AssistantState>(
  () => AssistantNotifier(AssistantRole.aruzhan),
);
