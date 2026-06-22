import 'package:admity/core/theme/app_colors.dart';
import 'package:admity/core/theme/app_tokens.dart';
import 'package:admity/features/opportunities/data/opportunity_seed.dart';
import 'package:admity/features/opportunities/domain/opportunity_models.dart';
import 'package:admity/shared/widgets/app_card.dart';
import 'package:admity/shared/widgets/app_scaffold.dart';
import 'package:admity/shared/widgets/primary_button.dart';
import 'package:admity/shared/widgets/topic_diagram_slot.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';

/// Full-screen detail for a Мероприятие.
///
/// Shows: what/when/where, description, prize, registration deadline,
/// "как участвовать" numbered steps, and a PrimaryButton to note/bookmark.
///
/// Layout: AppScaffold + AppBar + SafeArea > SingleChildScrollView > Column(.min).
/// Accent: AppColors.primary (date, steps). PrimaryButton for normal action.
class EventDetailScreen extends StatelessWidget {
  const EventDetailScreen({required this.eventId, super.key});

  final String eventId;

  @override
  Widget build(BuildContext context) {
    final event = seedEvents.where((e) => e.id == eventId).firstOrNull;

    if (event == null) {
      return AppScaffold(
        appBar: AppBar(
          backgroundColor: AppColors.white,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_rounded, color: AppColors.ink),
            onPressed: () => context.go('/opportunities'),
          ),
          title: Text(
            'Мероприятие',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              color: AppColors.ink,
            ),
          ),
          elevation: 0,
        ),
        body: const Center(
          child: Text('Мероприятие не найдено'),
        ),
      );
    }

    return AppScaffold(
      appBar: AppBar(
        backgroundColor: AppColors.white,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded, color: AppColors.ink),
          onPressed: () => context.go('/opportunities'),
        ),
        title: Text(
          event.title,
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
            color: AppColors.ink,
          ),
          overflow: TextOverflow.ellipsis,
        ),
        elevation: 0,
        surfaceTintColor: AppColors.white,
      ),
      body: _EventDetailBody(event: event),
    );
  }
}

class _EventDetailBody extends StatelessWidget {
  const _EventDetailBody({required this.event});

  final OpportunityEvent event;

  @override
  Widget build(BuildContext context) {
    final tokens =
        Theme.of(context).extension<AppTokens>() ?? AppTokens.defaults();

    return SingleChildScrollView(
      padding: EdgeInsets.all(tokens.screenPadding),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Diagram slot ─────────────────────────────────────────────────────
          // TODO(3d): Replace with event-category illustration.
          Center(
            child: const TopicDiagramSlot(size: 96, label: 'Мероприятие')
                .animate()
                .fadeIn(duration: const Duration(milliseconds: 300))
                .scale(begin: const Offset(0.9, 0.9), end: const Offset(1, 1)),
          ),
          SizedBox(height: tokens.gapXl),

          // ── When / where / format meta row ────────────────────────────────────
          Wrap(
                spacing: tokens.gapSm,
                runSpacing: tokens.gapSm,
                children: [
                  _MetaChip(
                    icon: Icons.calendar_today_outlined,
                    label: event.dateLabel,
                    color: AppColors.primary,
                  ),
                  _MetaChip(
                    icon: Icons.location_on_outlined,
                    label: event.city,
                  ),
                  if (event.format != null)
                    _MetaChip(
                      icon: Icons.video_call_outlined,
                      label: event.format!,
                    ),
                ],
              )
              .animate()
              .fadeIn(
                delay: const Duration(milliseconds: 60),
                duration: const Duration(milliseconds: 280),
              )
              .slideY(begin: 0.04, end: 0),
          SizedBox(height: tokens.gapXl),

          // ── Description ───────────────────────────────────────────────────────
          _SectionCard(
                icon: Icons.info_outline_rounded,
                title: 'О мероприятии',
                accentColor: AppColors.primary,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      event.description,
                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        color: AppColors.inkSecondary,
                      ),
                    ),
                    if (event.location != null) ...[
                      SizedBox(height: tokens.gapMd),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Icon(
                            Icons.place_outlined,
                            size: 16,
                            color: AppColors.inkSecondary,
                          ),
                          SizedBox(width: tokens.gapXs),
                          Expanded(
                            child: Text(
                              event.location!,
                              style: Theme.of(context).textTheme.bodyLarge
                                  ?.copyWith(color: AppColors.inkSecondary),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ],
                ),
              )
              .animate()
              .fadeIn(
                delay: const Duration(milliseconds: 100),
                duration: const Duration(milliseconds: 280),
              )
              .slideY(begin: 0.04, end: 0),
          SizedBox(height: tokens.gapMd),

          // ── Prize / reward ────────────────────────────────────────────────────
          if (event.prize != null)
            _SectionCard(
                  icon: Icons.emoji_events_outlined,
                  title: 'Призы',
                  accentColor: AppColors.goldKey,
                  child: Text(
                    event.prize!,
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      color: AppColors.inkSecondary,
                    ),
                  ),
                )
                .animate()
                .fadeIn(
                  delay: const Duration(milliseconds: 140),
                  duration: const Duration(milliseconds: 280),
                )
                .slideY(begin: 0.04, end: 0),
          if (event.prize != null) SizedBox(height: tokens.gapMd),

          // ── Registration deadline ─────────────────────────────────────────────
          if (event.registrationDeadline != null)
            Container(
              padding: EdgeInsets.all(tokens.cardPadding),
              decoration: BoxDecoration(
                color: AppColors.errorRed.withValues(alpha: 0.06),
                borderRadius: BorderRadius.circular(tokens.radiusMd),
                border: Border.all(
                  color: AppColors.errorRed.withValues(alpha: 0.2),
                ),
              ),
              child: Row(
                children: [
                  const Icon(
                    Icons.access_time_rounded,
                    size: 16,
                    color: AppColors.errorRed,
                  ),
                  SizedBox(width: tokens.gapSm),
                  Expanded(
                    child: Text(
                      'Дедлайн регистрации: ${event.registrationDeadline}',
                      style: Theme.of(context).textTheme.labelLarge?.copyWith(
                        color: AppColors.errorRed,
                      ),
                    ),
                  ),
                ],
              ),
            ).animate().fadeIn(
              delay: const Duration(milliseconds: 180),
              duration: const Duration(milliseconds: 280),
            ),
          if (event.registrationDeadline != null)
            SizedBox(height: tokens.gapMd),

          // ── How to participate ────────────────────────────────────────────────
          if (event.howToParticipate != null &&
              event.howToParticipate!.isNotEmpty)
            _SectionCard(
                  icon: Icons.route_outlined,
                  title: 'Как участвовать',
                  accentColor: AppColors.primary,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: event.howToParticipate!
                        .asMap()
                        .entries
                        .map(
                          (entry) => Padding(
                            padding: EdgeInsets.only(bottom: tokens.gapMd),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Container(
                                  width: 24,
                                  height: 24,
                                  decoration: const BoxDecoration(
                                    color: AppColors.primary,
                                    shape: BoxShape.circle,
                                  ),
                                  alignment: Alignment.center,
                                  child: Text(
                                    '${entry.key + 1}',
                                    style: const TextStyle(
                                      color: AppColors.white,
                                      fontSize: 12,
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                ),
                                SizedBox(width: tokens.gapSm),
                                Expanded(
                                  child: Padding(
                                    padding: const EdgeInsets.only(top: 3),
                                    child: Text(
                                      entry.value,
                                      style: Theme.of(context)
                                          .textTheme
                                          .bodyLarge
                                          ?.copyWith(color: AppColors.ink),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        )
                        .toList(),
                  ),
                )
                .animate()
                .fadeIn(
                  delay: const Duration(milliseconds: 220),
                  duration: const Duration(milliseconds: 280),
                )
                .slideY(begin: 0.04, end: 0),
          if (event.howToParticipate != null &&
              event.howToParticipate!.isNotEmpty)
            SizedBox(height: tokens.gapXxl),

          // ── CTA — add to calendar / note ──────────────────────────────────────
          PrimaryButton(
            label: 'Добавить в список мероприятий',
            icon: const Icon(
              Icons.bookmark_add_outlined,
              color: AppColors.white,
              size: 18,
            ),
            onPressed: () {
              // TODO(feature): integrate with Ералы calendar when Supabase is live.
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: const Text('Мероприятие сохранено'),
                  backgroundColor: AppColors.successGreen,
                  behavior: SnackBarBehavior.floating,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              );
            },
          ).animate().fadeIn(
            delay: const Duration(milliseconds: 260),
            duration: const Duration(milliseconds: 280),
          ),
          SizedBox(height: tokens.gapXl),
        ],
      ),
    );
  }
}

// ── Shared section card ────────────────────────────────────────────────────────

class _SectionCard extends StatelessWidget {
  const _SectionCard({
    required this.icon,
    required this.title,
    required this.accentColor,
    required this.child,
  });

  final IconData icon;
  final String title;
  final Color accentColor;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final tokens =
        Theme.of(context).extension<AppTokens>() ?? AppTokens.defaults();

    return AppCard(
      padding: EdgeInsets.zero,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: EdgeInsets.all(tokens.cardPadding),
            child: Row(
              children: [
                Icon(icon, size: 18, color: accentColor),
                SizedBox(width: tokens.gapSm),
                Text(
                  title,
                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    color: AppColors.ink,
                  ),
                ),
              ],
            ),
          ),
          const Divider(height: 1, color: AppColors.border),
          Padding(
            padding: EdgeInsets.all(tokens.cardPadding),
            child: child,
          ),
        ],
      ),
    );
  }
}

// ── Meta chip ─────────────────────────────────────────────────────────────────

class _MetaChip extends StatelessWidget {
  const _MetaChip({
    required this.icon,
    required this.label,
    this.color = AppColors.inkSecondary,
  });

  final IconData icon;
  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final tokens =
        Theme.of(context).extension<AppTokens>() ?? AppTokens.defaults();

    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: tokens.gapMd,
        vertical: tokens.gapXs,
      ),
      decoration: BoxDecoration(
        color: AppColors.surfaceTint,
        borderRadius: BorderRadius.circular(tokens.radiusSm),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: color),
          SizedBox(width: tokens.gapXs),
          Text(
            label,
            style: Theme.of(
              context,
            ).textTheme.labelLarge?.copyWith(color: color),
          ),
        ],
      ),
    );
  }
}
