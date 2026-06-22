import 'package:admity/core/theme/app_colors.dart';
import 'package:admity/core/theme/app_tokens.dart';
import 'package:admity/features/opportunities/data/opportunity_seed.dart';
import 'package:admity/features/opportunities/domain/opportunity_models.dart';
import 'package:admity/shared/widgets/app_card.dart';
import 'package:admity/shared/widgets/app_scaffold.dart';
import 'package:admity/shared/widgets/mascot_slot.dart';
import 'package:admity/shared/widgets/primary_button.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';

/// Full-screen detail for an Идея проекта.
///
/// Shows: description, why it fits the student's interests, step-by-step guide,
/// expected outcome, tech stack, and a PrimaryButton to "Save idea".
///
/// Layout: AppScaffold + AppBar + SafeArea > SingleChildScrollView > Column(.min).
/// Accent: AppColors.primary. PrimaryButton for the save action.
class IdeaDetailScreen extends StatelessWidget {
  const IdeaDetailScreen({required this.ideaId, super.key});

  final String ideaId;

  @override
  Widget build(BuildContext context) {
    final idea = seedProjectIdeas.where((p) => p.id == ideaId).firstOrNull;

    if (idea == null) {
      return AppScaffold(
        appBar: AppBar(
          backgroundColor: AppColors.white,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_rounded, color: AppColors.ink),
            onPressed: () => context.go('/opportunities'),
          ),
          title: Text(
            'Идея проекта',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              color: AppColors.ink,
            ),
          ),
          elevation: 0,
        ),
        body: const Center(
          child: Text('Идея проекта не найдена'),
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
          idea.title,
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
            color: AppColors.ink,
          ),
          overflow: TextOverflow.ellipsis,
        ),
        elevation: 0,
        surfaceTintColor: AppColors.white,
      ),
      body: _IdeaDetailBody(idea: idea),
    );
  }
}

class _IdeaDetailBody extends StatelessWidget {
  const _IdeaDetailBody({required this.idea});

  final ProjectIdea idea;

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
          // ── Hero: mascot + meta chips ─────────────────────────────────────────
          Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // TODO(mascot): Replace with field-specific illustration.
                  const MascotSlot(size: 72, tag: 'project-idea'),
                  SizedBox(width: tokens.gapLg),
                  Expanded(
                    child: Wrap(
                      spacing: tokens.gapSm,
                      runSpacing: tokens.gapSm,
                      children: [
                        _MetaChip(
                          icon: Icons.school_outlined,
                          label: academicFieldLabel(idea.field),
                          color: AppColors.primary,
                        ),
                        _DifficultyChip(difficulty: idea.difficulty),
                      ],
                    ),
                  ),
                ],
              )
              .animate()
              .fadeIn(duration: const Duration(milliseconds: 300))
              .slideY(begin: 0.05, end: 0),
          SizedBox(height: tokens.gapXl),

          // ── Description ───────────────────────────────────────────────────────
          _SectionCard(
                icon: Icons.lightbulb_outline_rounded,
                title: 'Что за проект',
                accentColor: AppColors.primary,
                child: Text(
                  idea.description,
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    color: AppColors.inkSecondary,
                  ),
                ),
              )
              .animate()
              .fadeIn(
                delay: const Duration(milliseconds: 80),
                duration: const Duration(milliseconds: 280),
              )
              .slideY(begin: 0.04, end: 0),
          SizedBox(height: tokens.gapMd),

          // ── Why it fits ───────────────────────────────────────────────────────
          if (idea.whyItFits != null)
            _SectionCard(
                  icon: Icons.interests_rounded,
                  title: 'Почему это твоё',
                  accentColor: AppColors.successGreen,
                  child: Text(
                    idea.whyItFits!,
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      color: AppColors.inkSecondary,
                    ),
                  ),
                )
                .animate()
                .fadeIn(
                  delay: const Duration(milliseconds: 120),
                  duration: const Duration(milliseconds: 280),
                )
                .slideY(begin: 0.04, end: 0),
          if (idea.whyItFits != null) SizedBox(height: tokens.gapMd),

          // ── Steps ────────────────────────────────────────────────────────────
          if (idea.steps != null && idea.steps!.isNotEmpty)
            _SectionCard(
                  icon: Icons.route_outlined,
                  title: 'Шаги',
                  accentColor: AppColors.primary,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: idea.steps!
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
                  delay: const Duration(milliseconds: 160),
                  duration: const Duration(milliseconds: 280),
                )
                .slideY(begin: 0.04, end: 0),
          if (idea.steps != null && idea.steps!.isNotEmpty)
            SizedBox(height: tokens.gapMd),

          // ── Expected outcome ──────────────────────────────────────────────────
          if (idea.expectedOutcome != null)
            _SectionCard(
                  icon: Icons.emoji_events_outlined,
                  title: 'Что получишь в итоге',
                  accentColor: AppColors.goldKey,
                  child: Text(
                    idea.expectedOutcome!,
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      color: AppColors.inkSecondary,
                    ),
                  ),
                )
                .animate()
                .fadeIn(
                  delay: const Duration(milliseconds: 200),
                  duration: const Duration(milliseconds: 280),
                )
                .slideY(begin: 0.04, end: 0),
          if (idea.expectedOutcome != null) SizedBox(height: tokens.gapMd),

          // ── Tech stack ────────────────────────────────────────────────────────
          if (idea.techStack != null)
            Container(
              padding: EdgeInsets.all(tokens.cardPadding),
              decoration: BoxDecoration(
                color: AppColors.surfaceTint,
                borderRadius: BorderRadius.circular(tokens.radiusMd),
                border: Border.all(color: AppColors.border),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(
                    Icons.code_rounded,
                    size: 16,
                    color: AppColors.inkSecondary,
                  ),
                  SizedBox(width: tokens.gapSm),
                  Expanded(
                    child: Text(
                      idea.techStack!,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: AppColors.inkSecondary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ).animate().fadeIn(
              delay: const Duration(milliseconds: 240),
              duration: const Duration(milliseconds: 280),
            ),
          if (idea.techStack != null) SizedBox(height: tokens.gapXxl),

          // ── CTA — save idea ───────────────────────────────────────────────────
          PrimaryButton(
            label: 'Сохранить идею',
            icon: const Icon(
              Icons.bookmark_add_outlined,
              color: AppColors.white,
              size: 18,
            ),
            onPressed: () {
              // TODO(feature): persist to local profile notes when storage is wired.
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: const Text('Идея сохранена в профиль'),
                  backgroundColor: AppColors.successGreen,
                  behavior: SnackBarBehavior.floating,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              );
            },
          ).animate().fadeIn(
            delay: const Duration(milliseconds: 280),
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
        color: color.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(tokens.radiusSm),
        border: Border.all(color: color.withValues(alpha: 0.3)),
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

// ── Difficulty chip ────────────────────────────────────────────────────────────

class _DifficultyChip extends StatelessWidget {
  const _DifficultyChip({required this.difficulty});

  final String difficulty;

  @override
  Widget build(BuildContext context) {
    final tokens =
        Theme.of(context).extension<AppTokens>() ?? AppTokens.defaults();

    final color = difficulty == 'Легко'
        ? AppColors.successGreen
        : difficulty == 'Сложно'
        ? AppColors.errorRed
        : AppColors.goldKey;

    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: tokens.gapMd,
        vertical: tokens.gapXs,
      ),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(tokens.radiusSm),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.speed_rounded, size: 14, color: color),
          SizedBox(width: tokens.gapXs),
          Text(
            difficulty,
            style: Theme.of(context).textTheme.labelLarge?.copyWith(
              color: color,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}
