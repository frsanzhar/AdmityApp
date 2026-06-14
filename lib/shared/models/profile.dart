import 'package:flutter/foundation.dart';

/// Geographies a student can target. Drives chancing and scholarship matching.
enum TargetGeo {
  kz('Казахстан'),
  eu('Европа'),
  us('США'),
  asia('Азия');

  const TargetGeo(this.label);

  /// Human label (RU).
  final String label;
}

/// Self-reported English proficiency — influences country/program suggestions.
enum EnglishLevel {
  beginner('Начальный (A1–A2)'),
  intermediate('Средний (B1–B2)'),
  advanced('Продвинутый (C1–C2)'),
  unknown('Пока не знаю');

  const EnglishLevel(this.label);

  /// Human label (RU).
  final String label;
}

/// How sensitive the family budget is — drives scholarship/grant emphasis.
enum BudgetSensitivity {
  needFull('Нужен полный грант / стипендия'),
  needPartial('Нужна частичная поддержка'),
  flexible('Бюджет гибкий'),
  notSure('Ещё не решили');

  const BudgetSensitivity(this.label);

  /// Human label (RU).
  final String label;
}

/// Returns the enum value whose `name` matches [name], or null if none — so a
/// legacy/unknown stored string never throws (unlike `Enum.byName`).
T? _enumByNameOrNull<T extends Enum>(List<T> values, String? name) {
  if (name == null) return null;
  for (final v in values) {
    if (v.name == name) return v;
  }
  return null;
}

/// The student profile. Persisted to Supabase `profiles` when signed in, and
/// mirrored locally so the app works offline.
@immutable
class Profile {
  /// Creates a student profile. All fields are optional so a fresh/guest user
  /// starts empty and the JSON stays backward compatible as fields are added.
  const Profile({
    this.userId,
    this.fullName,
    this.region,
    this.grade,
    this.locale,
    this.gpa,
    this.targetGeos = const {},
    this.interests = const {},
    this.onboarded = false,
    this.dreamField,
    this.englishLevel,
    this.studyHoursPerDay,
    this.budgetSensitivity,
    this.motivation,
    this.usesGpaCalculator = false,
  });

  /// Deserializes a profile from stored/Supabase JSON (null-tolerant).
  factory Profile.fromJson(Map<String, dynamic> json) => Profile(
        userId: json['user_id'] as String?,
        fullName: json['full_name'] as String?,
        region: json['region'] as String?,
        grade: (json['grade'] as num?)?.toInt(),
        locale: json['locale'] as String?,
        gpa: (json['gpa'] as num?)?.toDouble(),
        targetGeos: ((json['target_geo'] as List<dynamic>?) ?? [])
            .map((e) => TargetGeo.values.byName(e as String))
            .toSet(),
        interests: ((json['interests'] as List<dynamic>?) ?? [])
            .map((e) => e as String)
            .toSet(),
        onboarded: (json['onboarded'] as bool?) ?? false,
        dreamField: json['dream_field'] as String?,
        englishLevel: _enumByNameOrNull(
          EnglishLevel.values,
          json['english_level'] as String?,
        ),
        studyHoursPerDay: (json['study_hours_per_day'] as num?)?.toInt(),
        budgetSensitivity: _enumByNameOrNull(
          BudgetSensitivity.values,
          json['budget_sensitivity'] as String?,
        ),
        motivation: json['motivation'] as String?,
        usesGpaCalculator: (json['uses_gpa_calculator'] as bool?) ?? false,
      );

  /// Supabase auth user id (null in guest/offline mode).
  final String? userId;

  /// Full name.
  final String? fullName;

  /// Region or city.
  final String? region;

  /// School grade (9..12).
  final int? grade;

  /// Preferred locale code (kk/ru/en).
  final String? locale;

  /// Current or expected GPA on the 5-point scale.
  final double? gpa;

  /// Target geographies (KZ / EU / US / Asia).
  final Set<TargetGeo> targetGeos;

  /// Interest tags chosen during onboarding.
  final Set<String> interests;

  /// Whether onboarding is complete.
  final bool onboarded;

  /// Free-form dream direction/career (e.g. «Медицина», «IT»).
  final String? dreamField;

  /// Self-reported English level.
  final EnglishLevel? englishLevel;

  /// Hours per day the student can realistically study.
  final int? studyHoursPerDay;

  /// Family budget sensitivity for cost/scholarship emphasis.
  final BudgetSensitivity? budgetSensitivity;

  /// Free-form «почему/зачем» motivation note (helps Eraly & essays).
  final String? motivation;

  /// True when the GPA was computed via the GPA calculator helper.
  final bool usesGpaCalculator;

  /// Serializes the profile to a JSON-safe map.
  Map<String, dynamic> toJson() => {
        if (userId != null) 'user_id': userId,
        'full_name': fullName,
        'region': region,
        'grade': grade,
        'locale': locale,
        'gpa': gpa,
        'target_geo': targetGeos.map((e) => e.name).toList(),
        'interests': interests.toList(),
        'onboarded': onboarded,
        'dream_field': dreamField,
        'english_level': englishLevel?.name,
        'study_hours_per_day': studyHoursPerDay,
        'budget_sensitivity': budgetSensitivity?.name,
        'motivation': motivation,
        'uses_gpa_calculator': usesGpaCalculator,
      };

  /// Returns a copy with the given fields replaced.
  Profile copyWith({
    String? userId,
    String? fullName,
    String? region,
    int? grade,
    String? locale,
    double? gpa,
    Set<TargetGeo>? targetGeos,
    Set<String>? interests,
    bool? onboarded,
    String? dreamField,
    EnglishLevel? englishLevel,
    int? studyHoursPerDay,
    BudgetSensitivity? budgetSensitivity,
    String? motivation,
    bool? usesGpaCalculator,
  }) {
    return Profile(
      userId: userId ?? this.userId,
      fullName: fullName ?? this.fullName,
      region: region ?? this.region,
      grade: grade ?? this.grade,
      locale: locale ?? this.locale,
      gpa: gpa ?? this.gpa,
      targetGeos: targetGeos ?? this.targetGeos,
      interests: interests ?? this.interests,
      onboarded: onboarded ?? this.onboarded,
      dreamField: dreamField ?? this.dreamField,
      englishLevel: englishLevel ?? this.englishLevel,
      studyHoursPerDay: studyHoursPerDay ?? this.studyHoursPerDay,
      budgetSensitivity: budgetSensitivity ?? this.budgetSensitivity,
      motivation: motivation ?? this.motivation,
      usesGpaCalculator: usesGpaCalculator ?? this.usesGpaCalculator,
    );
  }
}
