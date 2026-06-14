import 'package:admity/features/scholarships/domain/scholarship_models.dart';

/// Pure scholarship matching. Honest by design: it surfaces *why* a program
/// does or doesn't fit, and never hides a hard blocker behind a soft match.
abstract final class ScholarshipMatcher {
  /// Returns matches for [scholarships] given the student [context],
  /// eligible-first, each with plain-language reasons.
  static List<ScholarshipMatch> match(
    List<Scholarship> scholarships,
    EligibilityContext context,
  ) {
    final results = scholarships
        .map((s) => _matchOne(s, context))
        .toList(growable: false)
      ..sort((a, b) {
        if (a.eligible != b.eligible) return a.eligible ? -1 : 1;
        return a.scholarship.name.compareTo(b.scholarship.name);
      });
    return results;
  }

  static ScholarshipMatch _matchOne(Scholarship s, EligibilityContext ctx) {
    final reasons = <String>[];
    var eligible = true;

    if (!s.levels.contains(ctx.intendedLevel)) {
      eligible = false;
      final offered = s.levels.map((l) => l.label).join(', ');
      reasons.add(
        'Не для уровня «${ctx.intendedLevel.label}» (есть: $offered).',
      );
    }
    if (s.requiresWorkYears > ctx.workYears) {
      eligible = false;
      reasons.add(
        'Нужен опыт работы ~${s.requiresWorkYears} г. '
        '(у тебя ${ctx.workYears}).',
      );
    }
    if (s.ageMax != null && ctx.ageYears != null && ctx.ageYears! > s.ageMax!) {
      eligible = false;
      reasons.add('Возрастной лимит: до ${s.ageMax}.');
    }
    if (s.requiresKzCitizen && !ctx.isKzCitizen) {
      eligible = false;
      reasons.add('Требуется гражданство РК.');
    }
    // Caveats (e.g. "бакалавриат пока не возвращён") explain a *blocker* — show
    // them only when the program doesn't currently fit, not to eligible users.
    if (s.note != null && !eligible) {
      reasons.add('⚠️ ${s.note}');
    }

    if (eligible) {
      reasons
        ..insert(0, 'Покрывает: ${s.covers.join(', ')}.')
        ..insert(1, 'Дедлайн: ${s.deadline} (проверь у первоисточника).');
    }

    return ScholarshipMatch(
      scholarship: s,
      eligible: eligible,
      reasons: reasons,
    );
  }
}
