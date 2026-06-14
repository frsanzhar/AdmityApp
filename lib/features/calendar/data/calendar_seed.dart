import 'package:admity/features/calendar/domain/calendar_event.dart';

/// Key admissions dates for the upcoming cycle.
///
/// Many entries are recurring annual events whose exact day shifts each year:
/// these are marked [CalendarEvent.isApproximate] («ориентир») and anchored to
/// well-known typical dates. Always verify the current deadline at the source.
///
/// Scholarship deadlines mirror `kScholarshipsSeed`; because that catalogue
/// stores deadlines as free-text ranges, the concrete dates below are the
/// commonly-cited cutoffs for the matching programmes.
///
/// Not `const` because [DateTime] is not a const constructor.
final List<CalendarEvent> kCalendarSeed = [
  // ── Scholarship deadlines (mirror scholarships_seed) ──────────────────────
  CalendarEvent(
    date: DateTime(2026, 1, 10),
    title: 'Türkiye Bursları — открытие заявок',
    subtitle: 'Турция · заявки 10 янв – 20 фев',
    kind: CalendarEventKind.deadline,
    sourceUrl: 'https://turkiyeburslari.gov.tr',
    isApproximate: true,
  ),
  CalendarEvent(
    date: DateTime(2026, 1, 15),
    title: 'Stipendium Hungaricum — дедлайн',
    subtitle: 'Венгрия · до 14:00 CET',
    kind: CalendarEventKind.deadline,
    sourceUrl: 'https://stipendiumhungaricum.hu',
  ),
  CalendarEvent(
    date: DateTime(2026, 1, 15),
    title: 'Erasmus Mundus — типичный дедлайн',
    subtitle: 'ЕС · часто 5 или 15 января',
    kind: CalendarEventKind.deadline,
    sourceUrl: 'https://erasmus-plus.ec.europa.eu',
    isApproximate: true,
  ),
  CalendarEvent(
    date: DateTime(2026, 2, 20),
    title: 'Türkiye Bursları — закрытие заявок',
    subtitle: 'Турция · все уровни',
    kind: CalendarEventKind.deadline,
    sourceUrl: 'https://turkiyeburslari.gov.tr',
    isApproximate: true,
  ),
  CalendarEvent(
    date: DateTime(2026, 3, 3),
    title: 'Болашак — открытие приёма',
    subtitle: 'Казахстан · приём 3 мар – 17 окт',
    kind: CalendarEventKind.deadline,
    sourceUrl: 'https://bolashak.gov.kz',
    isApproximate: true,
  ),
  CalendarEvent(
    date: DateTime(2026, 10, 17),
    title: 'Болашак — закрытие приёма',
    subtitle: 'Казахстан · ориентир',
    kind: CalendarEventKind.deadline,
    sourceUrl: 'https://bolashak.gov.kz',
    isApproximate: true,
  ),
  CalendarEvent(
    date: DateTime(2026, 11, 5),
    title: 'Chevening — дедлайн заявок',
    subtitle: 'Великобритания · ориентир (ноябрь)',
    kind: CalendarEventKind.deadline,
    sourceUrl: 'https://chevening.org',
    isApproximate: true,
  ),
  CalendarEvent(
    date: DateTime(2026, 10),
    title: 'Global Korea Scholarship — посольский трек',
    subtitle: 'Корея · ориентир (сен–окт)',
    kind: CalendarEventKind.deadline,
    sourceUrl: 'https://studyinkorea.go.kr',
    isApproximate: true,
  ),

  // ── ЕНТ (НЦТ) окна ────────────────────────────────────────────────────────
  CalendarEvent(
    date: DateTime(2026, 3, 20),
    title: 'ЕНТ — мартовское окно',
    subtitle: 'Казахстан · ориентир (весна)',
    kind: CalendarEventKind.exam,
    sourceUrl: 'https://testcenter.kz',
    isApproximate: true,
  ),
  CalendarEvent(
    date: DateTime(2026, 6, 20),
    title: 'ЕНТ — основное (грантовое) окно',
    subtitle: 'Казахстан · ориентир (лето)',
    kind: CalendarEventKind.exam,
    sourceUrl: 'https://testcenter.kz',
    isApproximate: true,
  ),

  // ── Глобальные admissions milestones ──────────────────────────────────────
  CalendarEvent(
    date: DateTime(2026, 8),
    title: 'Common App — открытие сезона',
    subtitle: 'США · ориентир (1 августа)',
    kind: CalendarEventKind.milestone,
    sourceUrl: 'https://commonapp.org',
    isApproximate: true,
  ),
  CalendarEvent(
    date: DateTime(2026, 11),
    title: 'Common App — Early Action / Early Decision',
    subtitle: 'США · ориентир (1 ноября)',
    kind: CalendarEventKind.milestone,
    sourceUrl: 'https://commonapp.org',
    isApproximate: true,
  ),
  CalendarEvent(
    date: DateTime(2027),
    title: 'Common App — Regular Decision',
    subtitle: 'США · ориентир (часто 1 января)',
    kind: CalendarEventKind.milestone,
    sourceUrl: 'https://commonapp.org',
    isApproximate: true,
  ),
  CalendarEvent(
    date: DateTime(2026, 10, 15),
    title: 'UCAS — ранний дедлайн (Oxbridge, медицина)',
    subtitle: 'Великобритания · ориентир (15 октября)',
    kind: CalendarEventKind.milestone,
    sourceUrl: 'https://ucas.com',
    isApproximate: true,
  ),
  CalendarEvent(
    date: DateTime(2027, 1, 29),
    title: 'UCAS — основной дедлайн заявок',
    subtitle: 'Великобритания · ориентир (конец января)',
    kind: CalendarEventKind.milestone,
    sourceUrl: 'https://ucas.com',
    isApproximate: true,
  ),
];
