import 'dart:async';

import 'package:admity/core/theme/app_colors.dart';
import 'package:admity/core/theme/app_tokens.dart';
import 'package:admity/features/mentor/domain/assistant_role.dart';
import 'package:admity/features/mentor/presentation/assistant_chat_screen.dart';
import 'package:admity/shared/widgets/anim.dart';
import 'package:admity/shared/widgets/app_scaffold.dart';
import 'package:admity/shared/widgets/mascot_slot.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// ── Mentor Hub ────────────────────────────────────────────────────────────────

/// Entry screen for the Mentor tab — shows 4 AI-assistant cards.
///
/// Each card navigates to the respective chat:
/// - **Ералы** → [EralyChatScreen] (existing mentor flow: events, plans, chat).
/// - **Азамат** → [AssistantChatScreen] (essay coaching, NOT ghostwriting).
/// - **Мадина** → [AssistantChatScreen] (document checklist, KZ specifics).
/// - **Аружан** → [AssistantChatScreen] (lessons, homework photo review).
///
/// The router still references `MentorScreen` by name — this class IS that
/// screen; the chat screens are pushed on top within the same branch.
class MentorScreen extends ConsumerWidget {
  const MentorScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tokens =
        Theme.of(context).extension<AppTokens>() ?? AppTokens.defaults();

    return AppScaffold(
      appBar: _HubAppBar(tokens: tokens),
      body: SafeArea(
        top: false,
        child: SingleChildScrollView(
          padding: EdgeInsets.fromLTRB(
            tokens.screenPadding,
            tokens.gapLg,
            tokens.screenPadding,
            tokens.gapXxl,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Выбери ассистента',
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                      color: AppColors.ink,
                    ),
              ),
              SizedBox(height: tokens.gapSm),
              Text(
                'Каждый специализируется в своей области и знает, что '
                'обсуждают другие — они работают как команда.',
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      color: AppColors.inkSecondary,
                    ),
              ),
              SizedBox(height: tokens.gapXl),
              // 2-column grid of assistant cards.
              GridView.count(
                crossAxisCount: 2,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                crossAxisSpacing: tokens.gapMd,
                mainAxisSpacing: tokens.gapMd,
                childAspectRatio: 0.82,
                children: AssistantRole.values.indexed.map(
                  ((int, AssistantRole) entry) {
                    final (i, role) = entry;
                    return _AssistantCard(
                      role: role,
                      tokens: tokens,
                      animDelay: Duration(milliseconds: i * 80),
                    );
                  },
                ).toList(),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ── Hub app bar ───────────────────────────────────────────────────────────────

class _HubAppBar extends StatelessWidget implements PreferredSizeWidget {
  const _HubAppBar({required this.tokens});

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
          const MascotSlot(size: 32, tag: 'hub'),
          SizedBox(width: tokens.gapSm),
          Text(
            'ИИ-ассистенты',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  color: AppColors.ink,
                ),
          ),
        ],
      ),
    );
  }
}

// ── Assistant card ────────────────────────────────────────────────────────────

/// Hub card for a single [AssistantRole].
///
/// Tapping navigates to [EralyChatScreen] for Ералы or [AssistantChatScreen]
/// for the other three roles.
class _AssistantCard extends StatelessWidget {
  const _AssistantCard({
    required this.role,
    required this.tokens,
    this.animDelay = Duration.zero,
  });

  final AssistantRole role;
  final AppTokens tokens;
  final Duration animDelay;

  void _navigate(BuildContext context) {
    final Widget screen = role == AssistantRole.eraly
        ? const EralyChatScreen()
        : AssistantChatScreen(role: role);
    unawaited(
      Navigator.of(context).push(
        MaterialPageRoute<void>(builder: (_) => screen),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final card = Material(
      color: AppColors.white,
      borderRadius: BorderRadius.circular(tokens.radiusLg),
      child: InkWell(
        borderRadius: BorderRadius.circular(tokens.radiusLg),
        onTap: () => _navigate(context),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(tokens.radiusLg),
            border: Border.all(color: AppColors.border),
            boxShadow: tokens.cardShadow,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Coloured header strip with avatar.
              Container(
                height: 80,
                decoration: BoxDecoration(
                  color: role.accentColor.withValues(alpha: 0.10),
                  borderRadius: BorderRadius.vertical(
                    top: Radius.circular(tokens.radiusLg),
                  ),
                ),
                child: Center(
                  child: _CardAvatar(role: role),
                ),
              ),
              // Text content.
              Expanded(
                child: Padding(
                  padding: EdgeInsets.all(tokens.cardPadding),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        role.displayName,
                        style:
                            Theme.of(context).textTheme.titleLarge?.copyWith(
                                  color: AppColors.ink,
                                ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        role.roleLabel,
                        style:
                            Theme.of(context).textTheme.labelLarge?.copyWith(
                                  color: role.accentColor,
                                ),
                      ),
                      SizedBox(height: tokens.gapSm),
                      Text(
                        role.tagline,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: AppColors.inkSecondary,
                            ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );

    if (MediaQuery.of(context).disableAnimations) return card;
    return card
        .animate()
        .fade(
          duration: kAnimEntranceDuration,
          delay: animDelay,
          curve: kAnimEntranceCurve,
        )
        .slideY(
          begin: 0.10,
          end: 0,
          duration: kAnimEntranceDuration,
          delay: animDelay,
          curve: kAnimEntranceCurve,
        );
  }
}

/// Circular avatar shown in the hub card header.
class _CardAvatar extends StatelessWidget {
  const _CardAvatar({required this.role});

  final AssistantRole role;

  @override
  Widget build(BuildContext context) {
    if (role == AssistantRole.eraly) {
      // Use the real Ералы mascot for the main hero card.
      return const MascotSlot(size: 52, tag: 'hub_eraly');
    }
    return Container(
      width: 52,
      height: 52,
      decoration: BoxDecoration(
        color: role.accentColor.withValues(alpha: 0.18),
        shape: BoxShape.circle,
      ),
      child: Icon(role.icon, size: 28, color: role.accentColor),
    );
  }
}
