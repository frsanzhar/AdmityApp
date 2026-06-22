import 'dart:async';

import 'package:admity/core/theme/app_colors.dart';
import 'package:admity/core/theme/app_tokens.dart';
import 'package:admity/features/mentor/application/mentor_notifier.dart';
import 'package:admity/features/mentor/domain/chat_message.dart';
import 'package:admity/features/mentor/presentation/event_review_screen.dart';
import 'package:admity/features/mentor/presentation/topic_plan_screen.dart';
import 'package:admity/shared/widgets/app_scaffold.dart';
import 'package:admity/shared/widgets/featured_button.dart';
import 'package:admity/shared/widgets/mascot_slot.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// ── Mentor Screen ─────────────────────────────────────────────────────────────

class MentorScreen extends ConsumerStatefulWidget {
  const MentorScreen({super.key});

  @override
  ConsumerState<MentorScreen> createState() => _MentorScreenState();
}

class _MentorScreenState extends ConsumerState<MentorScreen> {
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
    // Fire and forget — async result intentionally discarded; errors are
    // caught inside the notifier.
    unawaited(ref.read(mentorProvider.notifier).sendMessage(text));
    // Scroll to bottom after next frame.
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
    final tokens = Theme.of(context).extension<AppTokens>() ?? AppTokens.defaults();

    // Auto-scroll when new messages arrive.
    ref.listen(mentorProvider.select((s) => s.messages.length), (prev, next) {
      if (next != prev) _scheduleScroll();
    });

    return AppScaffold(
      resizeToAvoidBottomInset: true,
      appBar: _MentorAppBar(tokens: tokens),
      body: Column(
        children: [
          // ── Chat list (Expanded — not stretch-in-scroll) ───────────────
          Expanded(
            child: ListView.builder(
              controller: _scrollController,
              padding: EdgeInsets.symmetric(
                horizontal: tokens.screenPadding,
                vertical: tokens.gapLg,
              ),
              itemCount: mentor.messages.length,
              itemBuilder: (context, i) {
                return _MessageBubble(
                  message: mentor.messages[i],
                  tokens: tokens,
                );
              },
            ),
          ),

          // ── Loading indicator ──────────────────────────────────────────
          if (mentor.isLoading)
            Padding(
              padding: EdgeInsets.only(bottom: tokens.gapSm),
              child: const _TypingIndicator(),
            ),

          // ── CTA buttons (context-sensitive) ───────────────────────────
          _ContextButtons(
            mentor: mentor,
            tokens: tokens,
            onReviewEvents: () => Navigator.of(context).push(
              MaterialPageRoute<void>(
                builder: (_) => const EventReviewScreen(),
              ),
            ),
            onShowPlan: () => Navigator.of(context).push(
              MaterialPageRoute<void>(
                builder: (_) => TopicPlanScreen(
                  plan: mentor.topicPlan!,
                ),
              ),
            ),
          ),

          // ── Input bar ─────────────────────────────────────────────────
          _InputBar(
            controller: _controller,
            isLoading: mentor.isLoading,
            tokens: tokens,
            onSend: _send,
          ),
        ],
      ),
    );
  }
}

// ── App bar ───────────────────────────────────────────────────────────────────

class _MentorAppBar extends StatelessWidget implements PreferredSizeWidget {
  const _MentorAppBar({required this.tokens});

  final AppTokens tokens;

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: AppColors.white,
      elevation: 0,
      titleSpacing: tokens.screenPadding,
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

// ── Message bubble ────────────────────────────────────────────────────────────

class _MessageBubble extends StatelessWidget {
  const _MessageBubble({required this.message, required this.tokens});

  final ChatMessage message;
  final AppTokens tokens;

  @override
  Widget build(BuildContext context) {
    final isUser = message.isUser;

    return Padding(
      padding: EdgeInsets.only(bottom: tokens.gapMd),
      child: Row(
        mainAxisAlignment:
            isUser ? MainAxisAlignment.end : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          if (!isUser) ...[
            const MascotSlot(size: 28, tag: 'chat'),
            SizedBox(width: tokens.gapSm),
          ],
          Flexible(
            child: Container(
              padding: EdgeInsets.symmetric(
                horizontal: tokens.cardPadding,
                vertical: tokens.gapMd,
              ),
              decoration: BoxDecoration(
                color: isUser ? AppColors.primary : AppColors.surfaceTint,
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
  }
}

// ── Typing indicator ──────────────────────────────────────────────────────────

class _TypingIndicator extends StatelessWidget {
  const _TypingIndicator();

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        const MascotSlot(size: 24, tag: 'typing'),
        const SizedBox(width: 8),
        Text(
          'Ералы печатает...',
          style: Theme.of(context).textTheme.bodySmall,
        ),
      ],
    );
  }
}

// ── Context-sensitive CTA buttons ─────────────────────────────────────────────

class _ContextButtons extends StatelessWidget {
  const _ContextButtons({
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
    final showEventButton = mentor.proposedEvents.isNotEmpty &&
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
            FeaturedButton(
              label: 'Открыть план',
              onPressed: onShowPlan,
            ),
          ],
        ],
      ),
    );
  }
}

// ── Input bar ─────────────────────────────────────────────────────────────────

class _InputBar extends StatelessWidget {
  const _InputBar({
    required this.controller,
    required this.isLoading,
    required this.tokens,
    required this.onSend,
  });

  final TextEditingController controller;
  final bool isLoading;
  final AppTokens tokens;
  final VoidCallback onSend;

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
        border: Border(
          top: BorderSide(color: AppColors.border),
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: controller,
              enabled: !isLoading,
              minLines: 1,
              maxLines: 4,
              textInputAction: TextInputAction.send,
              onSubmitted: (_) => onSend(),
              decoration: InputDecoration(
                hintText: 'Напиши Ералы...',
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
                  borderSide:
                      const BorderSide(color: AppColors.primary, width: 1.5),
                ),
              ),
            ),
          ),
          SizedBox(width: tokens.gapSm),
          SizedBox(
            width: 48,
            height: 48,
            child: Material(
              color: AppColors.primary,
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
