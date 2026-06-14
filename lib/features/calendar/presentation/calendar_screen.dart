import 'package:admity/core/theme/app_radii.dart';
import 'package:admity/core/theme/app_spacing.dart';
import 'package:admity/core/theme/app_theme_extension.dart';
import 'package:admity/features/calendar/domain/calendar_event.dart';
import 'package:admity/features/calendar/presentation/calendar_providers.dart';
import 'package:admity/features/calendar/presentation/calendar_style.dart';
import 'package:admity/shared/widgets/bento_card.dart';
import 'package:admity/shared/widgets/source_note.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:table_calendar/table_calendar.dart' as tc;
import 'package:url_launcher/url_launcher.dart';

/// Full month-view admissions calendar: a [tc.TableCalendar] with brand-colored
/// event markers and an agenda of the selected day's events below.
///
/// Russian labels are supplied via [tc.HeaderStyle.titleTextFormatter] and a
/// custom day-of-week builder so the calendar works offline without `intl`
/// locale initialization.
class CalendarScreen extends ConsumerStatefulWidget {
  /// Creates the calendar screen.
  const CalendarScreen({super.key});

  @override
  ConsumerState<CalendarScreen> createState() => _CalendarScreenState();
}

class _CalendarScreenState extends ConsumerState<CalendarScreen> {
  late DateTime _focusedDay;
  late DateTime _selectedDay;
  tc.CalendarFormat _format = tc.CalendarFormat.month;

  @override
  void initState() {
    super.initState();
    final now = ref.read(calendarNowProvider);
    final next = ref.read(upcomingEventsProvider).firstOrNull;
    _selectedDay = next?.date ?? now;
    _focusedDay = _selectedDay;
  }

  List<CalendarEvent> _eventsFor(DateTime day) {
    final key = DateTime(day.year, day.month, day.day);
    return ref.read(eventsByDayProvider)[key] ?? const [];
  }

  @override
  Widget build(BuildContext context) {
    final byDay = ref.watch(eventsByDayProvider);
    final now = ref.watch(calendarNowProvider);
    final tokens = context.tokens;
    final selected = _eventsFor(_selectedDay);

    final keys = byDay.keys.toList()..sort();
    final firstDay = keys.isEmpty
        ? DateTime(_focusedDay.year - 1)
        : DateTime(keys.first.year, keys.first.month);
    final lastDay = keys.isEmpty
        ? DateTime(_focusedDay.year + 1, 12, 31)
        : DateTime(keys.last.year, keys.last.month + 1, 0);

    return Scaffold(
      appBar: AppBar(title: const Text('Календарь')),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(AppSpacing.screen),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              BentoCard(
                padding: const EdgeInsets.all(AppSpacing.sm),
                child: tc.TableCalendar<CalendarEvent>(
                  firstDay: firstDay,
                  lastDay: lastDay,
                  focusedDay: _focusedDay,
                  currentDay: now,
                  calendarFormat: _format,
                  availableCalendarFormats: const {
                    tc.CalendarFormat.month: 'Месяц',
                    tc.CalendarFormat.twoWeeks: '2 недели',
                    tc.CalendarFormat.week: 'Неделя',
                  },
                  startingDayOfWeek: tc.StartingDayOfWeek.monday,
                  selectedDayPredicate: (d) => tc.isSameDay(d, _selectedDay),
                  eventLoader: _eventsFor,
                  onDaySelected: (selectedDay, focusedDay) {
                    setState(() {
                      _selectedDay = selectedDay;
                      _focusedDay = focusedDay;
                    });
                  },
                  onFormatChanged: (format) =>
                      setState(() => _format = format),
                  onPageChanged: (focusedDay) => _focusedDay = focusedDay,
                  calendarStyle: tc.CalendarStyle(
                    todayDecoration: BoxDecoration(
                      color: tokens.info.withValues(alpha: 0.25),
                      shape: BoxShape.circle,
                    ),
                    todayTextStyle:
                        TextStyle(color: context.colors.onSurface),
                    selectedDecoration: BoxDecoration(
                      color: context.colors.primary,
                      shape: BoxShape.circle,
                    ),
                    selectedTextStyle:
                        TextStyle(color: context.colors.onPrimary),
                    weekendTextStyle: TextStyle(color: tokens.textMuted),
                    outsideTextStyle: TextStyle(
                      color: tokens.textMuted.withValues(alpha: 0.5),
                    ),
                    defaultTextStyle:
                        TextStyle(color: context.colors.onSurface),
                  ),
                  headerStyle: tc.HeaderStyle(
                    formatButtonShowsNext: false,
                    titleCentered: true,
                    titleTextFormatter: (date, _) =>
                        CalendarStyle.monthYear(date),
                    formatButtonDecoration: BoxDecoration(
                      color: tokens.info.withValues(alpha: 0.12),
                      borderRadius: AppRadii.brPill,
                    ),
                    formatButtonTextStyle: context.text.bodySmall ??
                        const TextStyle(),
                    titleTextStyle:
                        context.text.titleMedium ?? const TextStyle(),
                    leftChevronIcon: Icon(
                      Icons.chevron_left_rounded,
                      color: context.colors.onSurface,
                    ),
                    rightChevronIcon: Icon(
                      Icons.chevron_right_rounded,
                      color: context.colors.onSurface,
                    ),
                  ),
                  calendarBuilders: tc.CalendarBuilders<CalendarEvent>(
                    dowBuilder: (context, day) => Center(
                      child: Text(
                        CalendarStyle.weekdayShort(day),
                        style: context.text.labelSmall
                            ?.copyWith(color: tokens.textMuted),
                      ),
                    ),
                    markerBuilder: (context, day, events) {
                      if (events.isEmpty) return null;
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 4),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            for (final e in events.take(3))
                              Container(
                                width: 6,
                                height: 6,
                                margin: const EdgeInsets.symmetric(
                                  horizontal: 1,
                                ),
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color:
                                      CalendarStyle.color(context, e.kind),
                                ),
                              ),
                          ],
                        ),
                      );
                    },
                  ),
                ),
              ),
              const SizedBox(height: AppSpacing.md),
              Text(
                CalendarStyle.longDate(_selectedDay),
                style: context.text.titleMedium,
              ),
              const SizedBox(height: AppSpacing.sm),
              if (selected.isEmpty)
                Padding(
                  padding:
                      const EdgeInsets.symmetric(vertical: AppSpacing.md),
                  child: Text(
                    'На этот день событий нет.',
                    style: context.text.bodyMedium
                        ?.copyWith(color: tokens.textMuted),
                  ),
                )
              else
                for (final e in selected) ...[
                  _EventCard(event: e),
                  const SizedBox(height: AppSpacing.sm),
                ],
              const SizedBox(height: AppSpacing.xs),
              const SourceNote(
                text: 'Многие даты — ориентир и меняются каждый год. Всегда '
                    'проверяй актуальный дедлайн у первоисточника.',
              ),
              const SizedBox(height: AppSpacing.xl),
            ],
          ),
        ),
      ),
    );
  }
}

class _EventCard extends StatelessWidget {
  const _EventCard({required this.event});

  final CalendarEvent event;

  Future<void> _openSource() async {
    final url = event.sourceUrl;
    if (url == null) return;
    final uri = Uri.tryParse(url);
    if (uri != null) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  @override
  Widget build(BuildContext context) {
    final color = CalendarStyle.color(context, event.kind);

    return BentoCard(
      accent: color,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(CalendarStyle.icon(event.kind), color: color, size: 20),
              const SizedBox(width: AppSpacing.xs),
              Expanded(
                child: Text(event.title, style: context.text.titleSmall),
              ),
              if (event.isApproximate)
                _Tag(text: 'ориентир', color: color),
            ],
          ),
          if (event.subtitle != null) ...[
            const SizedBox(height: AppSpacing.xxs),
            Text(
              event.subtitle!,
              style: context.text.bodySmall
                  ?.copyWith(color: context.tokens.textMuted),
            ),
          ],
          if (event.sourceUrl != null)
            Align(
              alignment: Alignment.centerLeft,
              child: TextButton.icon(
                onPressed: _openSource,
                icon: const Icon(Icons.open_in_new_rounded, size: 16),
                label: const Text('Первоисточник'),
              ),
            ),
        ],
      ),
    );
  }
}

class _Tag extends StatelessWidget {
  const _Tag({required this.text, required this.color});

  final String text;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.xs,
        vertical: 2,
      ),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: AppRadii.brPill,
      ),
      child: Text(
        text,
        style: context.text.labelSmall?.copyWith(color: color),
      ),
    );
  }
}
