import 'dart:async';
import 'dart:math' as math;

import 'package:admity/core/theme/app_colors.dart';
import 'package:admity/core/theme/app_tokens.dart';
import 'package:admity/features/mentor/application/assistant_notifier.dart'
    show assistantProviderFor;
import 'package:admity/features/mentor/application/mentor_notifier.dart';
import 'package:admity/features/mentor/domain/assistant_role.dart';
import 'package:admity/features/mentor/domain/chat_message.dart';
import 'package:admity/features/mentor/presentation/event_review_screen.dart';
import 'package:admity/features/mentor/presentation/topic_plan_screen.dart';
import 'package:admity/shared/widgets/anim.dart';
import 'package:admity/shared/widgets/app_scaffold.dart';
import 'package:admity/shared/widgets/featured_button.dart';
import 'package:admity/shared/widgets/mascot_slot.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// ── AssistantChatScreen (Азамат / Мадина / Аружан) ───────────────────────────

/// Unified chat screen for [AssistantRole.azamat], [AssistantRole.madina],
/// and [AssistantRole.aruzhan].
///
/// Аружан's input bar includes a paperclip button for file/photo attachments.
/// Chat history is persisted per-role in Hive.
class AssistantChatScreen extends ConsumerStatefulWidget {
  const AssistantChatScreen({required this.role, super.key});

  final AssistantRole role;

  @override
  ConsumerState<AssistantChatScreen> createState() =>
      _AssistantChatScreenState();
}

class _AssistantChatScreenState extends ConsumerState<AssistantChatScreen> {
  final _controller = TextEditingController();
  final _scrollController = ScrollController();

  @override
  void dispose() {
    _controller.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _send() {
    final text = _controller.text.trim();
    if (text.isEmpty) return;
    _controller.clear();
    unawaited(
      ref
          .read(assistantProviderFor(widget.role).notifier)
          .sendMessage(text),
    );
    _scheduleScroll();
  }

  Future<void> _pickAttachment() async {
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: const ['jpg', 'jpeg', 'png', 'gif', 'webp', 'pdf'],
      );
      if (result == null || result.files.isEmpty) return;
      final file = result.files.first;
      if (file.path == null) return;

      final ext = (file.extension ?? '').toLowerCase();
      final isImage = ['jpg', 'jpeg', 'png', 'gif', 'webp'].contains(ext);

      ref.read(assistantProviderFor(widget.role).notifier).setAttachment(
            path: file.path!,
            name: file.name,
            isImage: isImage,
          );
    } on Exception catch (e) {
      debugPrint('[AssistantChatScreen] pickAttachment error: $e');
    }
  }

  void _clearAttachment() {
    ref.read(assistantProviderFor(widget.role).notifier).clearAttachment();
  }

  void _scheduleScroll() {
    WidgetsBinding.instance.addPostFrameCallback((_) => _scrollToBottom());
  }

  void _scrollToBottom() {
    if (_scrollController.hasClients) {
      unawaited(
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(assistantProviderFor(widget.role));
    final tokens =
        Theme.of(context).extension<AppTokens>() ?? AppTokens.defaults();

    ref.listen(
      assistantProviderFor(widget.role).select((s) => s.messages.length),
      (prev, next) {
        if (next != prev) _scheduleScroll();
      },
    );

    return AppScaffold(
      resizeToAvoidBottomInset: true,
      appBar: _AssistantAppBar(role: widget.role, tokens: tokens),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              controller: _scrollController,
              padding: EdgeInsets.symmetric(
                horizontal: tokens.screenPadding,
                vertical: tokens.gapLg,
              ),
              itemCount: state.messages.length,
              itemBuilder: (context, i) => _ChatBubble(
                key: ValueKey(state.messages[i].id),
                message: state.messages[i],
                accentColor: widget.role.accentColor,
                tokens: tokens,
                index: i,
              ),
            ),
          ),
          if (state.isLoading)
            Padding(
              padding: EdgeInsets.only(bottom: tokens.gapSm),
              child: _TypingBubble(
                label: '${widget.role.displayName} думает...',
              ),
            ),
          // Attachment chip
          if (state.pendingAttachmentName != null)
            _AttachmentChip(
              name: state.pendingAttachmentName!,
              onRemove: _clearAttachment,
              tokens: tokens,
            ),
          _ChatInputBar(
            controller: _controller,
            isLoading: state.isLoading,
            tokens: tokens,
            onSend: _send,
            showAttachButton: widget.role.supportsAttachments,
            onAttach: _pickAttachment,
            accentColor: widget.role.accentColor,
          ),
        ],
      ),
    );
  }
}

// ── EralyChatScreen ───────────────────────────────────────────────────────────

/// Ералы's dedicated chat screen — reuses the existing [mentorProvider] so
/// event planning, topic plans, and the tone-picker all continue to work.
///
/// Shares the private chat UI widgets ([_ChatBubble], [_TypingBubble],
/// [_ChatInputBar]) with [AssistantChatScreen] for visual consistency.
class EralyChatScreen extends ConsumerStatefulWidget {
  const EralyChatScreen({super.key});

  @override
  ConsumerState<EralyChatScreen> createState() => _EralyChatScreenState();
}

class _EralyChatScreenState extends ConsumerState<EralyChatScreen> {
  final _controller = TextEditingController();
  final _scrollController = ScrollController();

  @override
  void dispose() {
    _controller.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _send() {
    final text = _controller.text.trim();
    if (text.isEmpty) return;
    if (ref.read(mentorProvider).needsTonePick) return;
    _controller.clear();
    unawaited(ref.read(mentorProvider.notifier).sendMessage(text));
    _scheduleScroll();
  }

  void _pickTone(String tone) {
    unawaited(ref.read(mentorProvider.notifier).pickTone(tone));
    _scheduleScroll();
  }

  void _scheduleScroll() {
    WidgetsBinding.instance.addPostFrameCallback((_) => _scrollToBottom());
  }

  void _scrollToBottom() {
    if (_scrollController.hasClients) {
      unawaited(
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final mentor = ref.watch(mentorProvider);
    final tokens =
        Theme.of(context).extension<AppTokens>() ?? AppTokens.defaults();

    ref.listen(
      mentorProvider.select((s) => s.messages.length),
      (prev, next) {
        if (next != prev) _scheduleScroll();
      },
    );

    return AppScaffold(
      resizeToAvoidBottomInset: true,
      appBar: _EralyAppBar(tokens: tokens),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              controller: _scrollController,
              padding: EdgeInsets.symmetric(
                horizontal: tokens.screenPadding,
                vertical: tokens.gapLg,
              ),
              itemCount: mentor.messages.length,
              itemBuilder: (context, i) => _ChatBubble(
                key: ValueKey(mentor.messages[i].id),
                message: mentor.messages[i],
                accentColor: AssistantRole.eraly.accentColor,
                tokens: tokens,
                index: i,
              ),
            ),
          ),
          if (mentor.isLoading)
            Padding(
              padding: EdgeInsets.only(bottom: tokens.gapSm),
              child: const _TypingBubble(label: 'Ералы думает...'),
            ),
          // Context-sensitive CTA buttons (event review / open plan).
          _EralyContextButtons(
            mentor: mentor,
            tokens: tokens,
            onReviewEvents: () => Navigator.of(context).push(
              MaterialPageRoute<void>(
                builder: (_) => const EventReviewScreen(),
              ),
            ),
            onShowPlan: () => Navigator.of(context).push(
              MaterialPageRoute<void>(
                builder: (_) => TopicPlanScreen(plan: mentor.topicPlan!),
              ),
            ),
          ),
          // Tone picker — shown only on first open before tone is chosen.
          if (mentor.needsTonePick)
            _TonePicker(tokens: tokens, onPick: _pickTone),
          _ChatInputBar(
            controller: _controller,
            isLoading: mentor.isLoading || mentor.needsTonePick,
            tokens: tokens,
            onSend: _send,
            accentColor: AssistantRole.eraly.accentColor,
          ),
        ],
      ),
    );
  }
}

// ── App bars ──────────────────────────────────────────────────────────────────

class _AssistantAppBar extends StatelessWidget implements PreferredSizeWidget {
  const _AssistantAppBar({required this.role, required this.tokens});

  final AssistantRole role;
  final AppTokens tokens;

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: AppColors.white,
      elevation: 0,
      leading: const BackButton(color: AppColors.ink),
      titleSpacing: 0,
      title: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _AssistantAvatar(role: role),
          SizedBox(width: tokens.gapSm),
          Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                role.displayName,
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      color: AppColors.ink,
                    ),
              ),
              Text(
                role.roleLabel,
                style: Theme.of(context).textTheme.bodySmall,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _EralyAppBar extends StatelessWidget implements PreferredSizeWidget {
  const _EralyAppBar({required this.tokens});

  final AppTokens tokens;

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: AppColors.white,
      elevation: 0,
      leading: const BackButton(color: AppColors.ink),
      titleSpacing: 0,
      title: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const MascotSlot(size: 36, tag: 'mentor'),
          SizedBox(width: tokens.gapSm),
          Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Ералы',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      color: AppColors.ink,
                    ),
              ),
              Text(
                'AI-наставник',
                style: Theme.of(context).textTheme.bodySmall,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// ── Shared chat UI widgets ────────────────────────────────────────────────────

/// Circular avatar for non-Ералы assistants using the role's accent colour.
class _AssistantAvatar extends StatelessWidget {
  const _AssistantAvatar({required this.role});

  final AssistantRole role;

  static const double _kSize = 36;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: _kSize,
      height: _kSize,
      decoration: BoxDecoration(
        color: role.accentColor.withValues(alpha: 0.15),
        shape: BoxShape.circle,
      ),
      child: Icon(
        role.icon,
        size: _kSize * 0.55,
        color: role.accentColor,
      ),
    );
  }
}

/// A single chat message bubble — shared by both [AssistantChatScreen] and
/// [EralyChatScreen].
class _ChatBubble extends StatelessWidget {
  const _ChatBubble({
    required this.message,
    required this.accentColor,
    required this.tokens,
    required this.index,
    super.key,
  });

  final ChatMessage message;
  final Color accentColor;
  final AppTokens tokens;
  final int index;

  @override
  Widget build(BuildContext context) {
    final isUser = message.isUser;
    final reduceAnim = reduceMotion(context);

    final bubble = Padding(
      padding: EdgeInsets.only(bottom: tokens.gapMd),
      child: Row(
        mainAxisAlignment:
            isUser ? MainAxisAlignment.end : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          if (!isUser) ...[
            Container(
              width: 28,
              height: 28,
              decoration: BoxDecoration(
                color: accentColor.withValues(alpha: 0.15),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.smart_toy_rounded,
                size: 16,
                color: accentColor,
              ),
            ),
            SizedBox(width: tokens.gapSm),
          ],
          Flexible(
            child: Container(
              padding: EdgeInsets.symmetric(
                horizontal: tokens.cardPadding,
                vertical: tokens.gapMd,
              ),
              decoration: BoxDecoration(
                color: isUser ? accentColor : AppColors.surfaceTint,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(tokens.radiusLg),
                  topRight: Radius.circular(tokens.radiusLg),
                  bottomLeft: Radius.circular(isUser ? tokens.radiusLg : 4),
                  bottomRight: Radius.circular(isUser ? 4 : tokens.radiusLg),
                ),
                boxShadow: tokens.cardShadow,
              ),
              child: Text(
                message.text,
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      color: isUser ? AppColors.white : AppColors.ink,
                    ),
              ),
            ),
          ),
          if (isUser) SizedBox(width: tokens.gapSm),
        ],
      ),
    );

    if (reduceAnim) return bubble;
    return bubble
        .animate(key: ValueKey(message.id))
        .fadeSlideIn(duration: kAnimEntranceDuration);
  }
}

/// Animated three-dot typing indicator shown while the assistant is loading.
class _TypingBubble extends StatefulWidget {
  const _TypingBubble({required this.label});

  final String label;

  @override
  State<_TypingBubble> createState() => _TypingBubbleState();
}

class _TypingBubbleState extends State<_TypingBubble>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    );
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!MediaQuery.of(context).disableAnimations &&
        !_controller.isAnimating) {
      unawaited(_controller.repeat());
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final reduceAnim = MediaQuery.of(context).disableAnimations;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 24,
            height: 24,
            decoration: BoxDecoration(
              color: AppColors.inkSecondary.withValues(alpha: 0.12),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.smart_toy_rounded,
              size: 14,
              color: AppColors.inkSecondary,
            ),
          ),
          const SizedBox(width: 8),
          if (reduceAnim)
            Text(
              widget.label,
              style: Theme.of(context).textTheme.bodySmall,
            )
          else
            AnimatedBuilder(
              animation: _controller,
              builder: (context, _) {
                return Row(
                  mainAxisSize: MainAxisSize.min,
                  children: List.generate(3, (i) {
                    final phase = (_controller.value - i / 3.0) % 1.0;
                    final t = math.sin(phase * math.pi * 2);
                    final offsetY = -4.0 * ((t + 1) / 2);
                    return Transform.translate(
                      offset: Offset(0, offsetY),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 2),
                        child: Container(
                          width: 7,
                          height: 7,
                          decoration: const BoxDecoration(
                            color: AppColors.inkSecondary,
                            shape: BoxShape.circle,
                          ),
                        ),
                      ),
                    );
                  }),
                );
              },
            ),
        ],
      ),
    );
  }
}

/// Chip shown above the input bar when a file/photo is pending.
class _AttachmentChip extends StatelessWidget {
  const _AttachmentChip({
    required this.name,
    required this.onRemove,
    required this.tokens,
  });

  final String name;
  final VoidCallback onRemove;
  final AppTokens tokens;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.fromLTRB(
        tokens.screenPadding,
        tokens.gapSm,
        tokens.gapSm,
        0,
      ),
      color: AppColors.white,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(
            Icons.attach_file_rounded,
            size: 16,
            color: AppColors.inkSecondary,
          ),
          const SizedBox(width: 4),
          Flexible(
            child: Text(
              name,
              overflow: TextOverflow.ellipsis,
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ),
          const SizedBox(width: 4),
          GestureDetector(
            onTap: onRemove,
            child: const Icon(
              Icons.close_rounded,
              size: 16,
              color: AppColors.inkSecondary,
            ),
          ),
        ],
      ),
    );
  }
}

/// Input bar — shared by both screens.
///
/// Shows a paperclip button when [showAttachButton] is true (Аружан only).
class _ChatInputBar extends StatelessWidget {
  const _ChatInputBar({
    required this.controller,
    required this.isLoading,
    required this.tokens,
    required this.onSend,
    required this.accentColor,
    this.showAttachButton = false,
    this.onAttach,
  });

  final TextEditingController controller;
  final bool isLoading;
  final AppTokens tokens;
  final VoidCallback onSend;
  final Color accentColor;
  final bool showAttachButton;
  final VoidCallback? onAttach;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.fromLTRB(
        tokens.screenPadding,
        tokens.gapMd,
        tokens.gapSm,
        tokens.gapMd,
      ),
      decoration: const BoxDecoration(
        color: AppColors.white,
        border: Border(top: BorderSide(color: AppColors.border)),
      ),
      child: Row(
        children: [
          if (showAttachButton) ...[
            SizedBox(
              width: 40,
              height: 40,
              child: Material(
                color: AppColors.surfaceTint,
                borderRadius: BorderRadius.circular(tokens.radiusMd),
                child: InkWell(
                  borderRadius: BorderRadius.circular(tokens.radiusMd),
                  onTap: isLoading ? null : onAttach,
                  child: const Icon(
                    Icons.attach_file_rounded,
                    color: AppColors.inkSecondary,
                    size: 20,
                  ),
                ),
              ),
            ),
            SizedBox(width: tokens.gapSm),
          ],
          Expanded(
            child: TextField(
              controller: controller,
              enabled: !isLoading,
              minLines: 1,
              maxLines: 4,
              textInputAction: TextInputAction.send,
              onSubmitted: (_) => onSend(),
              decoration: InputDecoration(
                hintText: 'Написать...',
                hintStyle: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      color: AppColors.inkSecondary,
                    ),
                filled: true,
                fillColor: AppColors.surfaceTint,
                contentPadding: EdgeInsets.symmetric(
                  horizontal: tokens.cardPadding,
                  vertical: tokens.gapMd,
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(tokens.radiusMd),
                  borderSide: BorderSide.none,
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(tokens.radiusMd),
                  borderSide: BorderSide.none,
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(tokens.radiusMd),
                  borderSide: BorderSide(color: accentColor, width: 1.5),
                ),
              ),
            ),
          ),
          SizedBox(width: tokens.gapSm),
          SizedBox(
            width: 48,
            height: 48,
            child: Material(
              color: accentColor,
              borderRadius: BorderRadius.circular(tokens.radiusMd),
              child: InkWell(
                borderRadius: BorderRadius.circular(tokens.radiusMd),
                onTap: isLoading ? null : onSend,
                child: const Icon(
                  Icons.send_rounded,
                  color: AppColors.white,
                  size: 22,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Ералы-specific widgets ────────────────────────────────────────────────────

/// Context-sensitive CTA buttons for Ералы's chat (event review / open plan).
class _EralyContextButtons extends StatelessWidget {
  const _EralyContextButtons({
    required this.mentor,
    required this.tokens,
    required this.onReviewEvents,
    required this.onShowPlan,
  });

  final MentorState mentor;
  final AppTokens tokens;
  final VoidCallback onReviewEvents;
  final VoidCallback onShowPlan;

  @override
  Widget build(BuildContext context) {
    final showEventButton =
        mentor.proposedEvents.isNotEmpty &&
        mentor.mode == ChatMode.eventPlanning;
    final showPlanButton =
        mentor.topicPlan != null && mentor.mode == ChatMode.showingPlan;

    if (!showEventButton && !showPlanButton) return const SizedBox.shrink();

    return Padding(
      padding: EdgeInsets.fromLTRB(
        tokens.screenPadding,
        0,
        tokens.screenPadding,
        tokens.gapSm,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (showEventButton)
            FeaturedButton(
              label: 'Проверить все мероприятия',
              onPressed: onReviewEvents,
            ),
          if (showPlanButton) ...[
            if (showEventButton) SizedBox(height: tokens.gapSm),
            FeaturedButton(label: 'Открыть план', onPressed: onShowPlan),
          ],
        ],
      ),
    );
  }
}

/// Inline tone picker for Ералы's first-open experience.
class _TonePicker extends StatelessWidget {
  const _TonePicker({required this.tokens, required this.onPick});

  final AppTokens tokens;
  final void Function(String tone) onPick;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.fromLTRB(
        tokens.screenPadding,
        tokens.gapSm,
        tokens.screenPadding,
        tokens.gapSm,
      ),
      color: AppColors.surfaceTint,
      child: Row(
        children: [
          Expanded(
            child: _ToneOption(
              label: 'Строгий\nнаставник',
              emoji: '🎯',
              description: 'Прямо и по делу',
              onTap: () => onPick('strict'),
              tokens: tokens,
            ),
          ),
          SizedBox(width: tokens.gapMd),
          Expanded(
            child: _ToneOption(
              label: 'Дружеский\nнаставник',
              emoji: '😊',
              description: 'Тепло и поддержка',
              onTap: () => onPick('friendly'),
              tokens: tokens,
            ),
          ),
        ],
      ),
    );
  }
}

class _ToneOption extends StatelessWidget {
  const _ToneOption({
    required this.label,
    required this.emoji,
    required this.description,
    required this.onTap,
    required this.tokens,
  });

  final String label;
  final String emoji;
  final String description;
  final VoidCallback onTap;
  final AppTokens tokens;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.white,
      borderRadius: BorderRadius.circular(tokens.radiusMd),
      child: InkWell(
        borderRadius: BorderRadius.circular(tokens.radiusMd),
        onTap: onTap,
        child: Container(
          padding: EdgeInsets.all(tokens.cardPadding),
          decoration: BoxDecoration(
            border: Border.all(color: AppColors.border),
            borderRadius: BorderRadius.circular(tokens.radiusMd),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(emoji, style: const TextStyle(fontSize: 28)),
              SizedBox(height: tokens.gapSm),
              Text(
                label,
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.labelLarge?.copyWith(
                      color: AppColors.ink,
                      height: 1.3,
                    ),
              ),
              const SizedBox(height: 2),
              Text(
                description,
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: AppColors.inkSecondary,
                    ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
