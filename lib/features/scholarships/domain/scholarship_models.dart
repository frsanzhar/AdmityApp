import 'package:flutter/foundation.dart';

/// Study level a scholarship funds (or a student intends).
enum StudyLevel {
  bachelor('Бакалавриат'),
  master('Магистратура'),
  phd('Докторантура'),
  exchange('Стажировка');

  const StudyLevel(this.label);

  final String label;
}

/// A scholarship/grant program with structured eligibility for matching.
@immutable
class Scholarship {
  const Scholarship({
    required this.slug,
    required this.name,
    required this.country,
    required this.levels,
    required this.covers,
    required this.deadline,
    required this.eligibility,
    required this.sourceUrl,
    this.year,
    this.requiresWorkYears = 0,
    this.ageMax,
    this.requiresKzCitizen = false,
    this.note,
  });

  factory Scholarship.fromJson(Map<String, dynamic> json) => Scholarship(
        slug: json['slug'] as String,
        name: json['name'] as String,
        country: json['country'] as String,
        levels: ((json['levels'] as List<dynamic>?) ?? [])
            .map((e) => StudyLevel.values.byName(e as String))
            .toSet(),
        covers: ((json['covers'] as List<dynamic>?) ?? [])
            .map((e) => e as String)
            .toList(),
        deadline: json['deadline'] as String,
        eligibility: json['eligibility'] as String,
        sourceUrl: json['source_url'] as String,
        year: (json['year'] as num?)?.toInt(),
        requiresWorkYears: (json['requires_work_years'] as num?)?.toInt() ?? 0,
        ageMax: (json['age_max'] as num?)?.toInt(),
        requiresKzCitizen: (json['requires_kz_citizen'] as bool?) ?? false,
        note: json['note'] as String?,
      );

  final String slug;
  final String name;
  final String country;
  final Set<StudyLevel> levels;
  final List<String> covers;
  final String deadline;
  final String eligibility;
  final String sourceUrl;
  final int? year;
  final int requiresWorkYears;
  final int? ageMax;
  final bool requiresKzCitizen;

  /// Honest caveat (e.g. "бакалавриат пока не возвращён").
  final String? note;
}

/// Context describing the student for matching.
@immutable
class EligibilityContext {
  const EligibilityContext({
    this.intendedLevel = StudyLevel.bachelor,
    this.ageYears,
    this.workYears = 0,
    this.isKzCitizen = true,
  });

  final StudyLevel intendedLevel;
  final int? ageYears;
  final int workYears;
  final bool isKzCitizen;
}

/// Result of matching a scholarship to a student.
@immutable
class ScholarshipMatch {
  const ScholarshipMatch({
    required this.scholarship,
    required this.eligible,
    required this.reasons,
  });

  final Scholarship scholarship;
  final bool eligible;

  /// Plain-language reasons (why it fits, or why it doesn't).
  final List<String> reasons;
}
