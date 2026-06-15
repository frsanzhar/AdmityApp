import 'package:admity/core/router/app_routes.dart';
import 'package:admity/core/theme/app_colors.dart';
import 'package:admity/core/theme/app_durations.dart';
import 'package:admity/core/theme/app_radii.dart';
import 'package:admity/core/theme/app_spacing.dart';
import 'package:admity/core/theme/app_theme_extension.dart';
import 'package:admity/features/calendar/presentation/calendar_card.dart';
import 'package:admity/features/career_test/presentation/career_providers.dart';
import 'package:admity/features/chancing_kz/presentation/ent_providers.dart';
import 'package:admity/features/gap_closer/presentation/gap_providers.dart';
import 'package:admity/features/intensives/domain/intensive_models.dart';
import 'package:admity/features/intensives/presentation/intensives_providers.dart';
import 'package:admity/features/profile/presentation/profile_providers.dart';
import 'package:admity/features/quotes/presentation/quote_of_day_card.dart';
import 'package:admity/features/scholarships/presentation/scholarships_providers.dart';
import 'package:admity/shared/models/profile.dart';
import 'package:admity/shared/widgets/bento_card.dart';
import 'package:admity/shared/widgets/eraly_avatar.dart';
import 'package:admity/shared/widgets/gamification_badges.dart';
import 'package:admity/shared/widgets/nav_card.dart';
import 'package:admity/shared/widgets/progress_ring.dart';
import 'package:admity/shared/widgets/section_header.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

/// Maximum ЕНТ score (used to render the chances ring as a fraction).
const _entMax = 140;

/// The home dashboard — a warm editorial bento with one clear focal point:
/// a personalized greeting + live stat strip, a single terracotta "next action"
/// hero, a chances/scholarships snapshot, the day's quote and calendar, grouped
/// navigation, mini-games and a tip. Reuses the design tokens + shared widgets.
class DashboardScreen extends ConsumerStatefulWidget {
  const DashboardScreen({super.key});

  @override
  ConsumerState<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends ConsumerState<DashboardScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      if (ref.read(profileProvider).onboarded &&
          ref.read(gapTasksProvider).isEmpty) {
        ref.read(gapTasksProvider.notifier).regenerate();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final profile = ref.watch(profileProvider);
    final ent = ref.watch(entScoreProvider);
    final career = ref.watch(careerProvider);
    final tasks = ref.watch(gapTasksProvider);
    final progressMap = ref.watch(intensiveProgressProvider);
    final eligible =
        ref.watch(scholarshipMatchesProvider).where((m) => m.eligible).length;

    final nextTask = tasks.where((t) => !t.isDone).firstOrNull;
    IntensiveProgress? active;
    for (final p in progressMap.values) {
      if (p.completedDays.isEmpty) continue;
      if (active == null ||
          p.completedDays.length > active.completedDays.length) {
        active = p;
      }
    }

    // Build the staggered section list so each block fades/slides in calmly.
    final sections = <Widget>[
      _Greeting(profile: profile),
      if (active != null || ent != null)
        _StatStrip(active: active, entTotal: ent?.total),
      _HeroCard(
        onboarded: profile.onboarded,
        nextTaskTitle: nextTask?.title,
      ),
      const QuoteOfDayCard(),
      _SnapshotRow(entTotal: ent?.total, eligible: eligible),
      const CalendarCard(),
      _ContinueSection(active: active, riasecCode: career?.riasecCode),
      const _MiniGamesSection(),
      const _TipCard(),
    ];

    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(AppSpacing.screen),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              for (var i = 0; i < sections.length; i++) ...[
                // QuoteOfDayCard animates itself — don't double-animate it.
                if (sections[i] is QuoteOfDayCard)
                  sections[i]
                else
                  sections[i]
                      .animate()
                      .fadeIn(
                        duration: AppDurations.medium,
                        delay: (i * 55).ms,
                      )
                      .slideY(begin: 0.06, curve: Curves.easeOutCubic),
                if (i != sections.length - 1)
                  SizedBox(height: _gapAfter(sections[i])),
              ],
              const SizedBox(height: AppSpacing.xl),
            ],
          ),
        ),
      ),
    );
  }

  /// Larger breathing room before a new headered group, tighter within a group.
  double _gapAfter(Widget w) {
    if (w is _ContinueSection || w is _MiniGamesSection || w is _Greeting) {
      return AppSpacing.lg;
    }
    return AppSpacing.md;
  }
}

/// Personalized greeting band: state-aware mascot, time-of-day greeting, a
/// context line built from the profile, and a quick jump to the profile tab.
class _Greeting extends StatelessWidget {
  const _Greeting({required this.profile});

  final Profile profile;

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;
    final name = (profile.fullName ?? '').trim();
    final firstName = name.isEmpty ? '' : name.split(' ').first;
    final greeting = firstName.isEmpty
        ? '${_timeGreeting()}!'
        : '${_timeGreeting()}, $firstName!';

    return Row(
      children: [
        const EralyAvatar(size: 64),
        const SizedBox(width: AppSpacing.sm),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                greeting,
                style: context.text.headlineSmall,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              Text(
                _contextLine(),
                style: context.text.bodySmall?.copyWith(color: tokens.textMuted),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
        IconButton(
          onPressed: () => context.go(AppRoutes.profile),
          icon: Icon(Icons.account_circle_rounded, color: tokens.textMuted),
          tooltip: 'Профиль',
        ),
      ],
    );
  }

  String _timeGreeting() {
    final h = DateTime.now().hour;
    if (h < 12) return 'Доброе утро';
    if (h < 18) return 'Добрый день';
    return 'Добрый вечер';
  }

  String _contextLine() {
    final dream = (profile.dreamField ?? '').trim();
    if (dream.isNotEmpty) return 'Цель: $dream';
    final grade = profile.grade;
    final region = (profile.region ?? '').trim();
    if (grade != null && region.isNotEmpty) return '$grade класс · $region';
    if (region.isNotEmpty) return region;
    if (grade != null) return '$grade класс';
    return 'Твой путь в университет';
  }
}

/// A compact row of the most motivating live numbers, pulled to the top.
class _StatStrip extends StatelessWidget {
  const _StatStrip({required this.active, required this.entTotal});

  final IntensiveProgress? active;
  final int? entTotal;

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;
    return Wrap(
      spacing: AppSpacing.xs,
      runSpacing: AppSpacing.xs,
      children: [
        if (active != null && active!.streakCount > 0)
          StreakBadge(days: active!.streakCount),
        if (active != null && active!.xp > 0)
          XpChip(xp: active!.xp, compact: true),
        if (entTotal != null)
          _Pill(
            icon: Icons.insights_rounded,
            label: 'ЕНТ $entTotal/$_entMax',
            color: tokens.info,
          ),
      ],
    );
  }
}

/// A small tinted pill (icon + label) matching the XpChip/StreakBadge language.
class _Pill extends StatelessWidget {
  const _Pill({required this.icon, required this.label, required this.color});

  final IconData icon;
  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.16),
        borderRadius: AppRadii.brPill,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: color),
          const SizedBox(width: 4),
          Text(label, style: context.text.labelMedium?.copyWith(color: color)),
        ],
      ),
    );
  }
}

/// The single primary card — the only terracotta-filled surface on the page, so
/// it owns the focal point. Either the onboarding nudge or the next task.
class _HeroCard extends StatelessWidget {
  const _HeroCard({required this.onboarded, required this.nextTaskTitle});

  final bool onboarded;
  final String? nextTaskTitle;

  @override
  Widget build(BuildContext context) {
    final (eyebrow, title, cta, route, celebrate) = _content();
    return BentoCard(
      color: context.colors.primary,
      padding: const EdgeInsets.all(AppSpacing.lg),
      onTap: () => context.push(route),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  eyebrow,
                  style: context.text.labelSmall?.copyWith(
                    color: AppColors.cream.withValues(alpha: 0.85),
                    letterSpacing: 1.2,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: AppSpacing.xs),
                Text(
                  title,
                  style: context.text.titleLarge?.copyWith(
                    color: AppColors.cream,
                    height: 1.2,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: AppSpacing.md),
                _HeroButton(label: cta, onTap: () => context.push(route)),
              ],
            ),
          ),
          if (celebrate) ...[
            const SizedBox(width: AppSpacing.sm),
            const EralyAvatar(size: 64, state: EralyState.celebrate),
          ],
        ],
      ),
    );
  }

  (String, String, String, String, bool) _content() {
    if (!onboarded) {
      return (
        'ДОБРО ПОЖАЛОВАТЬ',
        'Заполни профиль за пару минут',
        'Начать',
        AppRoutes.onboarding,
        false,
      );
    }
    final title = nextTaskTitle;
    if (title != null) {
      return ('СЕГОДНЯ', title, 'Открыть план', AppRoutes.gap, false);
    }
    return (
      'ОТЛИЧНО',
      'Все задачи закрыты — красавчик!',
      'Что дальше?',
      AppRoutes.learn,
      true,
    );
  }
}

class _HeroButton extends StatelessWidget {
  const _HeroButton({required this.label, required this.onTap});

  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return FilledButton(
      onPressed: onTap,
      style: FilledButton.styleFrom(
        backgroundColor: AppColors.cream,
        foregroundColor: context.colors.primary,
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.md,
          vertical: AppSpacing.sm,
        ),
        shape: const RoundedRectangleBorder(borderRadius: AppRadii.brMd),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(label, style: context.text.labelLarge),
          const SizedBox(width: 6),
          const Icon(Icons.arrow_forward_rounded, size: 18),
        ],
      ),
    );
  }
}

/// Two equal cards forming the bento's mid band: chances ring + scholarships.
class _SnapshotRow extends StatelessWidget {
  const _SnapshotRow({required this.entTotal, required this.eligible});

  final int? entTotal;
  final int eligible;

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;
    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Expanded(
            child: BentoCard(
              accent: tokens.info,
              onTap: () => context.go(AppRoutes.chances),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Твои шансы', style: context.text.titleMedium),
                  const SizedBox(height: AppSpacing.sm),
                  Center(
                    child: entTotal != null
                        ? ProgressRing(
                            progress: (entTotal! / _entMax).clamp(0.0, 1.0),
                            size: 76,
                            color: tokens.info,
                            label: '$entTotal',
                            sublabel: '/$_entMax',
                          )
                        : _RingPlaceholder(color: tokens.info),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: BentoCard(
              onTap: () => context.push(AppRoutes.scholarships),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _IconChip(
                    icon: Icons.workspace_premium_rounded,
                    color: tokens.success,
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '$eligible',
                        style: context.text.headlineSmall
                            ?.copyWith(color: tokens.success),
                      ),
                      Text(
                        eligible == 0
                            ? 'Подбери стипендии'
                            : 'стипендий тебе подходят',
                        style: context.text.bodySmall
                            ?.copyWith(color: tokens.textMuted),
                      ),
                    ],
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

class _RingPlaceholder extends StatelessWidget {
  const _RingPlaceholder({required this.color});

  final Color color;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 76,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.insights_rounded, color: color),
          const SizedBox(height: AppSpacing.xs),
          Text(
            'Узнай свои шансы',
            textAlign: TextAlign.center,
            style: context.text.bodySmall
                ?.copyWith(color: context.tokens.textMuted),
          ),
        ],
      ),
    );
  }
}

/// A 44px tinted icon chip (matches NavCard's leading visual).
class _IconChip extends StatelessWidget {
  const _IconChip({required this.icon, required this.color});

  final IconData icon;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 44,
      height: 44,
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.14),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Icon(icon, color: color),
    );
  }
}

/// Grouped navigation rows (tinted chip + chevron) so "go somewhere" actions
/// read differently from the hero/snapshot.
class _ContinueSection extends StatelessWidget {
  const _ContinueSection({required this.active, required this.riasecCode});

  final IntensiveProgress? active;
  final String? riasecCode;

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const SectionHeader(title: 'Продолжай путь'),
        const SizedBox(height: AppSpacing.sm),
        NavCard(
          icon: Icons.local_fire_department_rounded,
          accent: tokens.streak,
          title: 'Интенсив',
          subtitle: active == null
              ? 'Начни 2-недельный трек.'
              : 'Прогресс: ${active!.completedDays.length}/14 дней.',
          trailing:
              active != null ? StreakBadge(days: active!.streakCount) : null,
          onTap: () => context.go(AppRoutes.learn),
        ),
        const SizedBox(height: AppSpacing.md),
        NavCard(
          icon: Icons.explore_rounded,
          title: 'Профориентация',
          subtitle: riasecCode == null
              ? 'Пройди тест RIASEC.'
              : 'Твой код: $riasecCode.',
          onTap: () => context.push(AppRoutes.careerTest),
        ),
        const SizedBox(height: AppSpacing.md),
        NavCard(
          icon: Icons.forum_rounded,
          accent: context.colors.primary,
          title: 'Спроси Ералы',
          subtitle: 'Помогу и подскажу — но не сделаю работу за тебя.',
          onTap: () => context.go(AppRoutes.eraly),
        ),
      ],
    );
  }
}

/// A horizontal rail of mini-games — a texture change from the stacked cards.
class _MiniGamesSection extends StatelessWidget {
  const _MiniGamesSection();

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const SectionHeader(
          title: 'Мини-игры и инструменты',
          subtitle: 'Прокачивай мозг каждый день',
        ),
        const SizedBox(height: AppSpacing.sm),
        SizedBox(
          height: 132,
          child: ListView(
            scrollDirection: Axis.horizontal,
            children: [
              _GameCard(
                icon: Icons.grid_view_rounded,
                title: 'Слово дня',
                subtitle: 'Отгадай за 6 попыток',
                color: tokens.success,
                onTap: () => context.push(AppRoutes.wordleGame),
              ),
              const SizedBox(width: AppSpacing.md),
              _GameCard(
                icon: Icons.travel_explore_rounded,
                title: 'Угадай вуз',
                subtitle: 'Узнай по подсказкам',
                color: tokens.xp,
                onTap: () => context.push(AppRoutes.guessUni),
              ),
              const SizedBox(width: AppSpacing.md),
              _GameCard(
                icon: Icons.calculate_rounded,
                title: 'Калькулятор GPA',
                subtitle: 'Средний балл по таблице',
                color: tokens.info,
                onTap: () => context.push(AppRoutes.gpa),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _GameCard extends StatelessWidget {
  const _GameCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.color,
    required this.onTap,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final Color color;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 156,
      child: BentoCard(
        accent: color,
        onTap: onTap,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            _IconChip(icon: icon, color: color),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: context.text.titleSmall,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                Text(
                  subtitle,
                  style: context.text.bodySmall
                      ?.copyWith(color: context.tokens.textMuted),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

/// The day's tip, wrapped in a card so it matches the page rhythm instead of
/// being a naked paragraph.
class _TipCard extends StatelessWidget {
  const _TipCard();

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;
    return BentoCard(
      color: tokens.surfaceSunken,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.lightbulb_rounded, size: 20, color: tokens.xp),
              const SizedBox(width: AppSpacing.xs),
              Text('Совет дня', style: context.text.titleMedium),
            ],
          ),
          const SizedBox(height: AppSpacing.xs),
          Text(
            'Есть 5 вузов США (MIT, Harvard, Yale, Princeton, Amherst), где '
            'заявка на финпомощь НЕ снижает шанс поступить. «Need-blind» ≠ '
            'автоматически бесплатно — но точно стоит подавать.',
            style: context.text.bodyMedium?.copyWith(color: tokens.textMuted),
          ),
        ],
      ),
    );
  }
}
