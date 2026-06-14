import 'dart:async';

import 'package:admity/core/theme/app_radii.dart';
import 'package:admity/core/theme/app_spacing.dart';
import 'package:admity/core/theme/app_theme_extension.dart';
import 'package:admity/features/eraly_chat/domain/chat_models.dart';
import 'package:admity/features/eraly_chat/presentation/chat_providers.dart';
import 'package:admity/shared/widgets/eraly_avatar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// The Eraly chat — message bubbles, the mascot, and a text field. AI runs in
/// the Edge Function; offline it falls back to a principled local response.
class EralyChatScreen extends ConsumerStatefulWidget {
  const EralyChatScreen({super.key});

  @override
  ConsumerState<EralyChatScreen> createState() => _EralyChatScreenState();
}

class _EralyChatScreenState extends ConsumerState<EralyChatScreen> {
  final _input = TextEditingController();
  final _scroll = ScrollController();

  @override
  void dispose() {
    _input.dispose();
    _scroll.dispose();
    super.dispose();
  }

  Future<void> _send() async {
    final text = _input.text;
    if (text.trim().isEmpty) return;
    _input.clear();
    await ref.read(chatProvider.notifier).send(text);
    _scrollToEnd();
  }

  void _scrollToEnd() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scroll.hasClients) {
        unawaited(
          _scroll.animateTo(
            _scroll.position.maxScrollExtent,
            duration: const Duration(milliseconds: 250),
            curve: Curves.easeOut,
          ),
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final messages = ref.watch(chatProvider);
    final thinking = messages.any((m) => m.pending);

    return Scaffold(
      appBar: AppBar(
        titleSpacing: 0,
        title: Row(
          children: [
            EralyAvatar(
              size: 34,
              state: thinking ? EralyState.thinking : EralyState.idle,
            ),
            const SizedBox(width: AppSpacing.xs),
            const Text('Ералы'),
          ],
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              controller: _scroll,
              padding: const EdgeInsets.all(AppSpacing.md),
              itemCount: messages.length,
              itemBuilder: (context, i) => _Bubble(message: messages[i]),
            ),
          ),
          SafeArea(
            top: false,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(
                AppSpacing.md,
                AppSpacing.xs,
                AppSpacing.md,
                AppSpacing.md,
              ),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _input,
                      textInputAction: TextInputAction.send,
                      onSubmitted: (_) => _send(),
                      decoration: const InputDecoration(
                        hintText: 'Спроси про шансы, эссе, стипендии…',
                      ),
                    ),
                  ),
                  const SizedBox(width: AppSpacing.xs),
                  IconButton.filled(
                    onPressed: thinking ? null : _send,
                    icon: const Icon(Icons.arrow_upward_rounded),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _Bubble extends StatelessWidget {
  const _Bubble({required this.message});

  final ChatMessage message;

  @override
  Widget build(BuildContext context) {
    final isUser = message.role == ChatRole.user;
    final tokens = context.tokens;
    final bubbleColor = isUser ? context.colors.primary : tokens.surfaceRaised;
    final textColor = isUser ? Colors.white : context.colors.onSurface;

    final content = message.pending
        ? const SizedBox(
            width: 40,
            child: Text('…', textAlign: TextAlign.center),
          )
        : Text(message.content, style: TextStyle(color: textColor, height: 1.35));

    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.sm),
      child: Row(
        mainAxisAlignment:
            isUser ? MainAxisAlignment.end : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          if (!isUser) ...[
            const EralyAvatar(size: 28),
            const SizedBox(width: AppSpacing.xs),
          ],
          Flexible(
            child: Container(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.md,
                vertical: AppSpacing.sm,
              ),
              decoration: BoxDecoration(
                color: bubbleColor,
                borderRadius: BorderRadius.only(
                  topLeft: AppRadii.rLg,
                  topRight: AppRadii.rLg,
                  bottomLeft: Radius.circular(isUser ? AppRadii.lg : 4),
                  bottomRight: Radius.circular(isUser ? 4 : AppRadii.lg),
                ),
              ),
              child: content,
            ),
          ),
        ],
      ),
    );
  }
}
