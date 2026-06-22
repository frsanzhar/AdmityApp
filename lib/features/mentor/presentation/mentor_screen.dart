import 'dart:async';
import 'dart:math' as math;

import 'package:admity/core/theme/app_colors.dart';
import 'package:admity/core/theme/app_tokens.dart';
import 'package:admity/features/mentor/application/mentor_notifier.dart';
import 'package:admity/features/mentor/domain/chat_message.dart';
import 'package:admity/features/mentor/presentation/event_review_screen.dart';
import 'package:admity/features/mentor/presentation/topic_plan_screen.dart';
import 'package:admity/shared/widgets/anim.dart';
import 'package:admity/shared/widgets/app_scaffold.dart';
import 'package:admity/shared/widgets/featured_button.dart';
import 'package:admity/shared/widgets/mascot_slot.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
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
    final tokens =
        Theme.of(context).extension<AppTokens>() ?? AppTokens.defaults();

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
                  key: ValueKey(mentor.messages[i].id),
                  message: mentor.messages[i],
                  tokens: tokens,
                  index: i,
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
  const _MessageBubble({
    required this.message,
    required this.tokens,
    required this.index,
    super.key,
  });

  final ChatMessage message;
  final AppTokens tokens;

  /// Position in the list — used to clamp the stagger delay so only the last
  /// few bubbles actually animate (earlier bubbles appear instantly).
  final int index;

  @override
  Widget build(BuildContext context) {
    final isUser = message.isUser;
    final reduceAnim = reduceMotion(context);

    final bubble = Padding(
      padding: EdgeInsets.only(bottom: tokens.gapMd),
      child: Row(
        mainAxisAlignment: isUser
            ? MainAxisAlignment.end
            : MainAxisAlignment.start,
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

    if (reduceAnim) return bubble;

    // Slide from right for user messages, from left for assistant.
    // Only animate the last bubble (newest) to avoid animating history.
    return bubble
        .animate(key: ValueKey(message.id))
        .fadeSlideIn(duration: kAnimEntranceDuration);
  }
}

// ── Typing indicator ──────────────────────────────────────────────────────────

/// Animated three-dot typing indicator shown while Ералы is loading a reply.
class _TypingIndicator extends StatefulWidget {
  const _TypingIndicator();

  @override
  State<_TypingIndicator> createState() => _TypingIndicatorState();
}

class _TypingIndicatorState extends State<_TypingIndicator>
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
    // Only repeat when motion is allowed — an unconditional repeat() makes
    // pumpAndSettle() hang forever in widget tests.
    if (!MediaQuery.of(context).disableAnimations && !_controller.isAnimating) {
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
          const MascotSlot(size: 24, tag: 'typing'),
          const SizedBox(width: 8),
          _TypingDots(controller: _controller, reduceAnim: reduceAnim),
        ],
      ),
    );
  }
}

class _TypingDots extends StatelessWidget {
  const _TypingDots({
    required this.controller,
    required this.reduceAnim,
  });

  final AnimationController controller;
  final bool reduceAnim;

  @override
  Widget build(BuildContext context) {
    if (reduceAnim) {
      return Text(
        'Ералы думает...',
        style: Theme.of(context).textTheme.bodySmall,
      );
    }

    return AnimatedBuilder(
      animation: controller,
      builder: (context, _) {
        return Row(
          mainAxisSize: MainAxisSize.min,
          children: List.generate(3, (i) {
            // Each dot peaks at a different phase: 0, 1/3, 2/3.
            final phase = (controller.value - i / 3.0) % 1.0;
            // Map phase 0..0.5 to up, 0.5..1 to down using a sine curve.
            final t = math.sin(phase * math.pi * 2);
            final offsetY = -4.0 * ((t + 1) / 2); // 0 → -4 → 0
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
                  borderSide: const BorderSide(
                    color: AppColors.primary,
                    width: 1.5,
                  ),
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
