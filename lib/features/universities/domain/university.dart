import 'package:flutter/foundation.dart';

/// Whether a university is in Kazakhstan or abroad.
enum UniScope { kz, world }

/// An illustrative «типичный профиль поступившего» for a university.
///
/// HONESTY RULE: these are composite, illustrative profiles — never real named
/// people. [isIllustrative] is always `true` and the UI must label such cards
/// as «иллюстративный пример» so students never mistake them for guarantees.
@immutable
class AdmittedCase {
  /// Creates an illustrative admitted-student case.
  const AdmittedCase({
    required this.profileSummary,
    required this.whatWorked,
    required this.outcome,
    this.isIllustrative = true,
  });

  /// Rebuilds an [AdmittedCase] from stored JSON.
  factory AdmittedCase.fromJson(Map<String, dynamic> json) => AdmittedCase(
        profileSummary: json['profile_summary'] as String,
        whatWorked: json['what_worked'] as String,
        outcome: json['outcome'] as String,
        isIllustrative: (json['is_illustrative'] as bool?) ?? true,
      );

  /// Short composite academic profile, e.g.
  /// «ЕНТ 128/140, GPA 4.8, олимпиада по биологии».
  final String profileSummary;

  /// What seemed to make the application strong (essay, project, ECs…).
  final String whatWorked;

  /// The result, e.g. «Поступил(а) на грант, факультет CS».
  final String outcome;

  /// Always `true`: this is a composite illustration, not a real person.
  final bool isIllustrative;

  /// Serializes this case to JSON.
  Map<String, dynamic> toJson() => {
        'profile_summary': profileSummary,
        'what_worked': whatWorked,
        'outcome': outcome,
        'is_illustrative': isIllustrative,
      };
}

/// A university the student can explore and add to their list.
@immutable
class University {
  /// Creates a [University] catalogue entry.
  const University({
    required this.slug,
    required this.name,
    required this.country,
    required this.scope,
    required this.languages,
    required this.programs,
    this.ranking,
    this.tuition,
    this.finAidNotes,
    this.isNeedBlindFullNeed = false,
    this.cdsUniversityKey,
    this.acceptanceRate,
    this.acceptanceRateYear,
    this.isAcceptanceRateEstimate = false,
    this.mission,
    this.values = const [],
    this.notableFacts = const [],
    this.website,
    this.admittedCases = const [],
  });

  /// Rebuilds a [University] from stored JSON (backward compatible).
  factory University.fromJson(Map<String, dynamic> json) => University(
        slug: json['slug'] as String,
        name: json['name'] as String,
        country: json['country'] as String,
        scope: UniScope.values.byName(json['scope'] as String),
        languages: ((json['languages'] as List<dynamic>?) ?? [])
            .map((e) => e as String)
            .toList(),
        programs: ((json['programs'] as List<dynamic>?) ?? [])
            .map((e) => e as String)
            .toList(),
        ranking: (json['ranking'] as num?)?.toInt(),
        tuition: json['tuition'] as String?,
        finAidNotes: json['fin_aid_notes'] as String?,
        isNeedBlindFullNeed:
            (json['is_need_blind_full_need'] as bool?) ?? false,
        cdsUniversityKey: json['cds_university_key'] as String?,
        acceptanceRate: (json['acceptance_rate'] as num?)?.toDouble(),
        acceptanceRateYear: (json['acceptance_rate_year'] as num?)?.toInt(),
        isAcceptanceRateEstimate:
            (json['is_acceptance_rate_estimate'] as bool?) ?? false,
        mission: json['mission'] as String?,
        values: ((json['values'] as List<dynamic>?) ?? [])
            .map((e) => e as String)
            .toList(),
        notableFacts: ((json['notable_facts'] as List<dynamic>?) ?? [])
            .map((e) => e as String)
            .toList(),
        website: json['website'] as String?,
        admittedCases: ((json['admitted_cases'] as List<dynamic>?) ?? [])
            .map((e) => AdmittedCase.fromJson(e as Map<String, dynamic>))
            .toList(),
      );

  /// Stable identifier used in routes and the saved college list.
  final String slug;

  /// Display name of the university.
  final String name;

  /// Country (Russian display string).
  final String country;

  /// Whether the school is in Kazakhstan or abroad.
  final UniScope scope;

  /// Languages of instruction.
  final List<String> languages;

  /// Notable program areas.
  final List<String> programs;

  /// Optional overall ranking position.
  final int? ranking;

  /// Free-text tuition summary.
  final String? tuition;

  /// Free-text financial-aid notes.
  final String? finAidNotes;

  /// Whether the school is need-blind and meets full demonstrated need.
  final bool isNeedBlindFullNeed;

  /// Links to a `CdsSnapshot.university` for world chancing.
  final String? cdsUniversityKey;

  /// Overall admit/acceptance rate as a fraction in `0..1`
  /// (e.g. `0.04` == 4%). `null` when no reliable figure exists
  /// (typical for KZ schools that admit via ЕНТ thresholds).
  final double? acceptanceRate;

  /// Reporting year for [acceptanceRate] (shown for honesty).
  final int? acceptanceRateYear;

  /// Whether [acceptanceRate] is an estimate («оценка») rather than an
  /// officially published figure.
  final bool isAcceptanceRateEstimate;

  /// Brief paraphrased mission statement (Russian).
  final String? mission;

  /// Core institutional values (Russian short phrases).
  final List<String> values;

  /// Notable facts / selling points (Russian short phrases).
  final List<String> notableFacts;

  /// Official website URL, if known.
  final String? website;

  /// Illustrative «кейсы поступивших» (composite, never real people).
  final List<AdmittedCase> admittedCases;

  /// Serializes this university to JSON (backward compatible).
  Map<String, dynamic> toJson() => {
        'slug': slug,
        'name': name,
        'country': country,
        'scope': scope.name,
        'languages': languages,
        'programs': programs,
        if (ranking != null) 'ranking': ranking,
        if (tuition != null) 'tuition': tuition,
        if (finAidNotes != null) 'fin_aid_notes': finAidNotes,
        'is_need_blind_full_need': isNeedBlindFullNeed,
        if (cdsUniversityKey != null) 'cds_university_key': cdsUniversityKey,
        if (acceptanceRate != null) 'acceptance_rate': acceptanceRate,
        if (acceptanceRateYear != null)
          'acceptance_rate_year': acceptanceRateYear,
        'is_acceptance_rate_estimate': isAcceptanceRateEstimate,
        if (mission != null) 'mission': mission,
        'values': values,
        'notable_facts': notableFacts,
        if (website != null) 'website': website,
        'admitted_cases': admittedCases.map((e) => e.toJson()).toList(),
      };
}
