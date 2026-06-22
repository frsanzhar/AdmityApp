import 'package:admity/core/theme/app_colors.dart';
import 'package:admity/core/theme/app_tokens.dart';
import 'package:admity/features/mentor/application/mentor_notifier.dart';
import 'package:admity/features/mentor/domain/proposed_event.dart';
import 'package:admity/shared/widgets/app_card.dart';
import 'package:admity/shared/widgets/app_scaffold.dart';
import 'package:admity/shared/widgets/primary_button.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// ── Event Review Screen ───────────────────────────────────────────────────────
//
// The user MUST visit this screen before events can be saved.
// Tapping «Сохранить все» calls markEventsReviewed() + commitReviewedEvents().
// Each event card allows editing the scheduled time.

class EventReviewScreen extends ConsumerStatefulWidget {
  const EventReviewScreen({super.key});

  @override
  ConsumerState<EventReviewScreen> createState() => _EventReviewScreenState();
}

class _EventReviewScreenState extends ConsumerState<EventReviewScreen> {
  @override
  Widget build(BuildContext context) {
    final mentor = ref.watch(mentorProvider);
    final notifier = ref.read(mentorProvider.notifier);
    final tokens =
        Theme.of(context).extension<AppTokens>() ?? AppTokens.defaults();
    final events = mentor.proposedEvents;

    return AppScaffold(
      appBar: AppBar(
        backgroundColor: AppColors.white,
        elevation: 0,
        title: Text(
          'Проверить мероприятия',
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
            color: AppColors.ink,
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded, color: AppColors.ink),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              padding: EdgeInsets.all(tokens.screenPadding),
              itemCount: events.length,
              itemBuilder: (context, i) {
                return _EventCard(
                  event: events[i],
                  tokens: tokens,
                  onTimeEdit: (newTime) =>
                      notifier.updateEventTime(events[i].id, newTime),
                );
              },
            ),
          ),
          if (events.isEmpty)
            Expanded(
              child: Center(
                child: Text(
                  'Нет предложенных мероприятий',
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    color: AppColors.inkSecondary,
                  ),
                ),
              ),
            ),
          _SaveBar(
            hasEvents: events.isNotEmpty,
            tokens: tokens,
            onSave: () {
              notifier
                ..markEventsReviewed()
                ..commitReviewedEvents();
              Navigator.of(context).pop();
            },
          ),
        ],
      ),
    );
  }
}

// ── Event card ────────────────────────────────────────────────────────────────

class _EventCard extends StatelessWidget {
  const _EventCard({
    required this.event,
    required this.tokens,
    required this.onTimeEdit,
  });

  final ProposedEvent event;
  final AppTokens tokens;
  final ValueChanged<DateTime> onTimeEdit;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(bottom: tokens.gapMd),
      child: AppCard(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              event.title,
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                color: AppColors.ink,
              ),
            ),
            if (event.description.isNotEmpty) ...[
              SizedBox(height: tokens.gapXs),
              Text(
                event.description,
                style: Theme.of(context).textTheme.bodySmall,
              ),
            ],
            SizedBox(height: tokens.gapMd),
            Row(
              children: [
                const Icon(
                  Icons.calendar_today_outlined,
                  size: 16,
                  color: AppColors.inkSecondary,
                ),
                SizedBox(width: tokens.gapXs),
                Expanded(
                  child: Text(
                    _formatDate(event.scheduledAt),
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      color: AppColors.inkSecondary,
                    ),
                  ),
                ),
                GestureDetector(
                  onTap: () => _pickDateTime(context),
                  child: Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: tokens.gapMd,
                      vertical: tokens.gapXs,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.surfaceTint,
                      borderRadius: BorderRadius.circular(tokens.radiusSm),
                      border: Border.all(color: AppColors.border),
                    ),
                    child: Text(
                      'Изменить время',
                      style: Theme.of(context).textTheme.labelLarge?.copyWith(
                        color: AppColors.primary,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _pickDateTime(BuildContext context) async {
    final date = await showDatePicker(
      context: context,
      initialDate: event.scheduledAt,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
      builder: (ctx, child) => Theme(
        data: Theme.of(ctx),
        child: child!,
      ),
    );
    if (date == null || !context.mounted) return;

    final time = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(event.scheduledAt),
    );
    if (time == null) return;

    onTimeEdit(
      DateTime(date.year, date.month, date.day, time.hour, time.minute),
    );
  }

  /// Formats date in RU style without intl package to avoid blank-screen risk.
  static String _formatDate(DateTime dt) {
    const months = [
      'янв',
      'фев',
      'мар',
      'апр',
      'май',
      'июн',
      'июл',
      'авг',
      'сен',
      'окт',
      'ноя',
      'дек',
    ];
    final m = months[dt.month - 1];
    final h = dt.hour.toString().padLeft(2, '0');
    final min = dt.minute.toString().padLeft(2, '0');
    return '${dt.day} $m ${dt.year}, $h:$min';
  }
}

// ── Save bar ──────────────────────────────────────────────────────────────────

class _SaveBar extends StatelessWidget {
  const _SaveBar({
    required this.hasEvents,
    required this.tokens,
    required this.onSave,
  });

  final bool hasEvents;
  final AppTokens tokens;
  final VoidCallback onSave;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(tokens.screenPadding),
      decoration: const BoxDecoration(
        color: AppColors.white,
        border: Border(top: BorderSide(color: AppColors.border)),
      ),
      child: PrimaryButton(
        label: 'Сохранить все в календарь',
        onPressed: hasEvents ? onSave : null,
      ),
    );
  }
}
