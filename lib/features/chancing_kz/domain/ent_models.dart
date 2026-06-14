import 'package:flutter/foundation.dart';

/// Maximum total ЕНТ score (2025–2026 structure).
const int kEntMaxScore = 140;

/// Minimum points required on each individual subject (and creative exam).
const int kEntSubjectMinimum = 5;

/// Government grant threshold groups (2024–2026). Universities may set their
/// own, higher thresholds — captured per-specialty in [EntCutoff.govThreshold].
enum EntThresholdGroup {
  national('Национальные вузы', 65),
  medicine('Медицина / здравоохранение', 70),
  lawPedagogy('Право и педагогика', 75),
  agriVet('Сельское хозяйство, ветеринария', 60),
  other('Прочие специальности', 50);

  const EntThresholdGroup(this.label, this.threshold);

  final String label;
  final int threshold;
}

/// A student's ЕНТ result (5 subjects). [total] is the sum of all sections.
@immutable
class EntScore {
  const EntScore({
    required this.history,
    required this.mathLiteracy,
    required this.readingLiteracy,
    required this.profile1Subject,
    required this.profile1Score,
    required this.profile2Subject,
    required this.profile2Score,
    this.isPredicted = false,
  });

  // Defensive parsing: a legacy / partial store degrades to zeros rather than
  // throwing inside the Notifier build.
  factory EntScore.fromJson(Map<String, dynamic> json) => EntScore(
        history: (json['history'] as num?)?.toInt() ?? 0,
        mathLiteracy: (json['math_literacy'] as num?)?.toInt() ?? 0,
        readingLiteracy: (json['reading_literacy'] as num?)?.toInt() ?? 0,
        profile1Subject: json['profile1_subject'] as String? ?? 'Профиль 1',
        profile1Score: (json['profile1_score'] as num?)?.toInt() ?? 0,
        profile2Subject: json['profile2_subject'] as String? ?? 'Профиль 2',
        profile2Score: (json['profile2_score'] as num?)?.toInt() ?? 0,
        isPredicted: (json['is_predicted'] as bool?) ?? false,
      );

  final int history; // /20
  final int mathLiteracy; // /10
  final int readingLiteracy; // /10
  final String profile1Subject;
  final int profile1Score; // /50
  final String profile2Subject;
  final int profile2Score; // /50
  final bool isPredicted;

  int get total =>
      history + mathLiteracy + readingLiteracy + profile1Score + profile2Score;

  /// All sections must clear the per-subject minimum to qualify for a grant.
  bool get meetsSubjectMinimums =>
      history >= kEntSubjectMinimum &&
      mathLiteracy >= 3 && // lowered to 3 since 2024 (fewer questions)
      readingLiteracy >= 3 &&
      profile1Score >= kEntSubjectMinimum &&
      profile2Score >= kEntSubjectMinimum;

  Map<String, dynamic> toJson() => {
        'history': history,
        'math_literacy': mathLiteracy,
        'reading_literacy': readingLiteracy,
        'profile1_subject': profile1Subject,
        'profile1_score': profile1Score,
        'profile2_subject': profile2Subject,
        'profile2_score': profile2Score,
        'total': total,
        'is_predicted': isPredicted,
      };
}

/// Reference cut-off data for a university + specialty in a given year.
/// [realCutoff] is the actual grant cut-off published after the competition.
@immutable
class EntCutoff {
  const EntCutoff({
    required this.university,
    required this.specialty,
    required this.year,
    required this.govThreshold,
    this.realCutoff,
  });

  factory EntCutoff.fromJson(Map<String, dynamic> json) => EntCutoff(
        university: json['university'] as String,
        specialty: json['specialty'] as String,
        year: (json['year'] as num).toInt(),
        govThreshold: (json['gov_threshold'] as num).toInt(),
        realCutoff: (json['real_cutoff'] as num?)?.toInt(),
      );

  final String university;
  final String specialty;
  final int year;
  final int govThreshold;
  final int? realCutoff;
}
