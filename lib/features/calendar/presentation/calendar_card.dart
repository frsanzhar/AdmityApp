import 'package:admity/core/theme/app_radii.dart';
import 'package:admity/core/theme/app_spacing.dart';
import 'package:admity/core/theme/app_theme_extension.dart';
import 'package:admity/features/calendar/domain/calendar_event.dart';
import 'package:admity/features/calendar/presentation/calendar_providers.dart';
import 'package:admity/features/calendar/presentation/calendar_style.dart';
import 'package:admity/shared/widgets/bento_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

/// Compact home card listing the next few admissions dates. Drop it straight
/// into the dashboard [Column] inside a [SingleChildScrollView].
class CalendarCard extends ConsumerWidget {
  /// Creates the calendar home card.
  const CalendarCard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final now = ref.watch(calendarNowProvider);
    final upcoming = ref.watch(upcomingEventsProvider).take(4).toList();
    final tokens = context.tokens;

    return BentoCard(
      accent: tokens.info,
      // Route registered as AppRoutes.calendar ('/calendar', name 'calendar')
      // by the integrator; uses the literal path to avoid editing app_routes.
      onTap: () => context.push('/calendar'),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.event_rounded, color: context.colors.primary),
              const SizedBox(width: AppSpacing.xs),
              Expanded(
                child: Text('Календарь', style: context.text.titleMedium),
              ),
              Text(
                'Ближайшие дедлайны',
                style: context.text.bodySmall
                    ?.copyWith(color: tokens.textMuted),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.sm),
          if (upcoming.isEmpty)
            Text(
              'Пока нет предстоящих дат.',
              style: context.text.bodySmall
                  ?.copyWith(color: tokens.textMuted),
            )
          else
            for (var i = 0; i < upcoming.length; i++) ...[
              _EventRow(event: upcoming[i], now: now),
              if (i != upcoming.length - 1)
                const SizedBox(height: AppSpacing.sm),
            ],
        ],
      ),
    );
  }
}

class _EventRow extends StatelessWidget {
  const _EventRow({required this.event, required this.now});

  final CalendarEvent event;
  final DateTime now;

  @override
  Widget build(BuildContext context) {
    final color = CalendarStyle.color(context, event.kind);
    final days = event.daysFrom(now);

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _DateChip(date: event.date, color: color),
        const SizedBox(width: AppSpacing.sm),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                event.title,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: context.text.bodyMedium,
              ),
              Text(
                CalendarStyle.daysLeftLabel(days),
                style: context.text.bodySmall?.copyWith(color: color),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _DateChip extends StatelessWidget {
  const _DateChip({required this.date, required this.color});

  final DateTime date;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 56,
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.xs),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: AppRadii.brMd,
      ),
      child: Column(
        children: [
          Text(
            '${date.day}',
            style: context.text.titleMedium?.copyWith(
              color: color,
              fontWeight: FontWeight.bold,
            ),
          ),
          Text(
            CalendarStyle.shortDate(date).split(' ').last,
            style: context.text.bodySmall?.copyWith(color: color),
          ),
        ],
      ),
    );
  }
}
