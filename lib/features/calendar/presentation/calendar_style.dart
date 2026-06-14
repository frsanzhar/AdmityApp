import 'package:admity/core/theme/app_theme_extension.dart';
import 'package:admity/features/calendar/domain/calendar_event.dart';
import 'package:flutter/material.dart';

/// Shared brand mapping from a [CalendarEventKind] to its color and icon, plus
/// small date-formatting helpers used across the calendar widgets.
///
/// Dates are formatted with hand-rolled Russian month names so the feature
/// works fully offline without `intl` locale initialization.
abstract final class CalendarStyle {
  /// Genitive month names (for "15 января").
  static const List<String> _monthsGenitive = [
    'января',
    'февраля',
    'марта',
    'апреля',
    'мая',
    'июня',
    'июля',
    'августа',
    'сентября',
    'октября',
    'ноября',
    'декабря',
  ];

  /// Short month abbreviations (for "15 янв").
  static const List<String> _monthsShort = [
    'янв',
    'фев',
    'мар',
    'апр',
    'мая',
    'июн',
    'июл',
    'авг',
    'сен',
    'окт',
    'ноя',
    'дек',
  ];

  /// Brand-token color for [kind] in the current theme.
  static Color color(BuildContext context, CalendarEventKind kind) {
    final tokens = context.tokens;
    return switch (kind) {
      CalendarEventKind.deadline => tokens.danger,
      CalendarEventKind.exam => tokens.info,
      CalendarEventKind.milestone => tokens.success,
    };
  }

  /// Icon for [kind].
  static IconData icon(CalendarEventKind kind) => switch (kind) {
        CalendarEventKind.deadline => Icons.flag_rounded,
        CalendarEventKind.exam => Icons.edit_note_rounded,
        CalendarEventKind.milestone => Icons.outlined_flag_rounded,
      };

  /// "15 янв" style short label.
  static String shortDate(DateTime date) =>
      '${date.day} ${_monthsShort[date.month - 1]}';

  /// "15 января 2026" style full label.
  static String longDate(DateTime date) =>
      '${date.day} ${_monthsGenitive[date.month - 1]} ${date.year}';

  /// Nominative month names (for the month-view header "Январь 2026").
  static const List<String> _monthsNominative = [
    'Январь',
    'Февраль',
    'Март',
    'Апрель',
    'Май',
    'Июнь',
    'Июль',
    'Август',
    'Сентябрь',
    'Октябрь',
    'Ноябрь',
    'Декабрь',
  ];

  /// Short weekday labels, Monday-first.
  static const List<String> weekdaysShort = [
    'Пн',
    'Вт',
    'Ср',
    'Чт',
    'Пт',
    'Сб',
    'Вс',
  ];

  /// "Январь 2026" style header label (avoids `intl` locale data).
  static String monthYear(DateTime date) =>
      '${_monthsNominative[date.month - 1]} ${date.year}';

  /// Short weekday label for a [DateTime] (Mon..Sun → Пн..Вс).
  static String weekdayShort(DateTime date) =>
      weekdaysShort[date.weekday - 1];

  /// Russian "осталось N дней" phrasing for a non-negative day count.
  static String daysLeftLabel(int days) {
    if (days == 0) return 'Сегодня';
    if (days == 1) return 'Завтра';
    final mod100 = days % 100;
    final mod10 = days % 10;
    String word;
    if (mod100 >= 11 && mod100 <= 14) {
      word = 'дней';
    } else if (mod10 == 1) {
      word = 'день';
    } else if (mod10 >= 2 && mod10 <= 4) {
      word = 'дня';
    } else {
      word = 'дней';
    }
    return 'через $days $word';
  }
}
