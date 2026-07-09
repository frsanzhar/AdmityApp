// Domain models for the universities catalog — the "honest" admissions
// reference for Kazakhstan. Mirrors the Supabase schema in
// supabase/migrations/0001_universities_catalog.sql and is loaded offline from
// assets/data/universities.json (see UniversityCatalogLoader).
//
// Honesty rule: a grant cutoff is only ever surfaced as fact when its
// [GrantThreshold.isVerified] is true and it carries a [GrantThreshold.sourceUrl].
// Never synthesise a score.

import 'dart:math' as math;

import 'package:flutter/foundation.dart';

// ── MajorCategory ─────────────────────────────────────────────────────────────

/// High-level academic direction used for catalog filtering.
///
/// Maps program codes / field values onto user-friendly buckets following the
/// КЗ МНВО ГОП classification (codes B001–BM089).
enum MajorCategory {
  /// IT, информационная безопасность, телекоммуникации (B057–B059, B158).
  it,

  /// Инженерия, строительство, транспортные технологии (field=engineering).
  engineering,

  /// Медицина, фармация, стоматология (field=medicine).
  medicine,

  /// Менеджмент, финансы, маркетинг (field=economics, excl. B049).
  economics,

  /// Право (B049).
  law,

  /// Педагогика, подготовка учителей (B001–B020).
  pedagogy,

  /// Естественные, точные науки, аграрные науки (B050–B082, B183).
  naturalScience,

  /// Искусство, дизайн, гуманитарные науки (field=arts).
  arts,

  /// Социология, политология, международные отношения (field=informatics, B038–B043, B140).
  social,

  /// Туризм, спорт, прочее (field=null).
  other,
}

/// Russian label for a [MajorCategory].
String majorCategoryLabel(MajorCategory cat) {
  switch (cat) {
    case MajorCategory.it:
      return 'IT';
    case MajorCategory.engineering:
      return 'Инженерия';
    case MajorCategory.medicine:
      return 'Медицина';
    case MajorCategory.economics:
      return 'Экономика';
    case MajorCategory.law:
      return 'Право';
    case MajorCategory.pedagogy:
      return 'Педагогика';
    case MajorCategory.naturalScience:
      return 'Естественные науки';
    case MajorCategory.arts:
      return 'Искусство / Гуманитарные';
    case MajorCategory.social:
      return 'Социальные науки';
    case MajorCategory.other:
      return 'Прочее';
  }
}

/// Classifies a program code into a [MajorCategory].
///
/// Uses both the program's [EducationProgram.code] (numeric range) and
/// [EducationProgram.field] so that ambiguous buckets in the raw data are
/// correctly split (e.g. field=informatics contains both IT and social sciences;
/// field=natural contains pedagogy, exact sciences, and agriculture).
MajorCategory majorCategoryFromProgram(EducationProgram p) {
  final code = p.code;
  final field = p.field;

  // ── IT codes (B057–B059 = Информационные технологии / ИБ / Телеком; B158 = Криптология)
  if (code == 'B057' || code == 'B058' || code == 'B059' || code == 'B158') {
    return MajorCategory.it;
  }

  // ── Engineering (all field=engineering codes)
  if (field == 'engineering') return MajorCategory.engineering;

  // ── Medicine
  if (field == 'medicine') return MajorCategory.medicine;

  // ── Law (B049 = Право)
  if (code == 'B049') return MajorCategory.law;

  // ── Economics (remaining field=economics codes)
  if (field == 'economics') return MajorCategory.economics;

  // ── Pedagogy vs. Natural science — both field=natural
  if (field == 'natural') {
    // Extract the numeric part of the code (B001 → 1, BM086 → 86).
    final numeric = int.tryParse(code.replaceAll(RegExp('[^0-9]'), ''));
    if (numeric != null && numeric >= 1 && numeric <= 20) {
      return MajorCategory.pedagogy;
    }
    return MajorCategory.naturalScience;
  }

  // ── Social sciences vs. IT — both can appear as field=informatics
  // (B038–B043, B140 are social sciences; B057–B059, B158 were caught above).
  if (field == 'informatics') return MajorCategory.social;

  // ── Arts / humanities
  if (field == 'arts') return MajorCategory.arts;

  // ── Everything else (field=null: tourism, sport, social work, etc.)
  return MajorCategory.other;
}

/// Ownership / status class of a university.
enum UniversityType {
  /// Национальный.
  national,

  /// Государственный.
  state,

  /// Автономная организация образования (e.g. Nazarbayev University).
  autonomous,

  /// Частный.
  private,

  /// Международный / филиал зарубежного вуза.
  international,
}

/// Parses a [UniversityType] from its JSON string, defaulting to
/// [UniversityType.state].
UniversityType universityTypeFromJson(String? raw) {
  switch (raw) {
    case 'national':
      return UniversityType.national;
    case 'autonomous':
      return UniversityType.autonomous;
    case 'private':
      return UniversityType.private;
    case 'international':
      return UniversityType.international;
    case 'state':
    default:
      return UniversityType.state;
  }
}

/// Russian label for a [UniversityType].
String universityTypeLabel(UniversityType type) {
  switch (type) {
    case UniversityType.national:
      return 'Национальный';
    case UniversityType.state:
      return 'Государственный';
    case UniversityType.autonomous:
      return 'Автономный';
    case UniversityType.private:
      return 'Частный';
    case UniversityType.international:
      return 'Международный';
  }
}

/// The grant-competition quota a [GrantThreshold] belongs to.
enum QuotaType {
  /// Общий конкурс.
  general,

  /// Сельская квota (ауыл квотасы).
  rural,

  /// Выпускники лицеев / спец. программ.
  lyceum,

  /// Дети-сироты.
  orphan,

  /// Лица с инвалидностью.
  disability,

  /// Оралманы / кандасы.
  oralman,

  /// Иная квота.
  other,
}

/// Parses a [QuotaType] from its JSON string, defaulting to [QuotaType.general].
QuotaType quotaTypeFromJson(String? raw) {
  switch (raw) {
    case 'rural':
      return QuotaType.rural;
    case 'lyceum':
      return QuotaType.lyceum;
    case 'orphan':
      return QuotaType.orphan;
    case 'disability':
      return QuotaType.disability;
    case 'oralman':
      return QuotaType.oralman;
    case 'other':
      return QuotaType.other;
    case 'general':
    default:
      return QuotaType.general;
  }
}

/// Russian label for a [QuotaType].
String quotaTypeLabel(QuotaType quota) {
  switch (quota) {
    case QuotaType.general:
      return 'Общий конкурс';
    case QuotaType.rural:
      return 'Сельская квота';
    case QuotaType.lyceum:
      return 'Квота лицеев';
    case QuotaType.orphan:
      return 'Квота сирот';
    case QuotaType.disability:
      return 'Квота по инвалидности';
    case QuotaType.oralman:
      return 'Квота кандасов';
    case QuotaType.other:
      return 'Иная квота';
  }
}

/// A single university.
@immutable
class UniversityRecord {
  /// Creates a [UniversityRecord].
  const UniversityRecord({
    required this.id,
    required this.nameRu,
    required this.city,
    required this.type,
    this.nameKz,
    this.nameEn,
    this.website,
    this.hasDormitory,
    this.description,
    this.sourceUrl,
    this.imageUrl,
    this.dormImageUrl,
  });

  /// Builds a [UniversityRecord] from a decoded JSON map.
  factory UniversityRecord.fromJson(Map<String, dynamic> json) {
    return UniversityRecord(
      id: json['id'] as String,
      nameRu: json['name_ru'] as String,
      nameKz: json['name_kz'] as String?,
      nameEn: json['name_en'] as String?,
      city: json['city'] as String,
      type: json['type'] == null
          ? null
          : universityTypeFromJson(json['type'] as String?),
      website: json['website'] as String?,
      hasDormitory: json['has_dormitory'] as bool?,
      description: json['description'] as String?,
      sourceUrl: json['source_url'] as String?,
      imageUrl: json['image_url'] as String?,
      dormImageUrl: json['dorm_image_url'] as String?,
    );
  }

  /// Stable slug id, e.g. `nu`, `kbtu`.
  final String id;

  /// Russian name.
  final String nameRu;

  /// Kazakh name.
  final String? nameKz;

  /// English name.
  final String? nameEn;

  /// City the main campus is in.
  final String city;

  /// Ownership / status class; null when not confidently known.
  final UniversityType? type;

  /// Official website (host only, e.g. `nu.edu.kz`).
  final String? website;

  /// Whether the university provides dormitories.
  final bool? hasDormitory;

  /// Short description / about.
  final String? description;

  /// Provenance URL for this record.
  final String? sourceUrl;

  /// Optional photo URL (Wikimedia Commons or similar static CDN).
  ///
  /// Null for most universities — the UI must always show a graceful
  /// placeholder icon when this is null or the request fails.
  final String? imageUrl;

  /// Optional dormitory photo URL — same sourcing/placeholder rules as
  /// [imageUrl].
  final String? dormImageUrl;

  /// Returns a copy with [imageUrl] set (used by the image-merge loader).
  UniversityRecord withImageUrl(String? url) {
    return UniversityRecord(
      id: id,
      nameRu: nameRu,
      nameKz: nameKz,
      nameEn: nameEn,
      city: city,
      type: type,
      website: website,
      hasDormitory: hasDormitory,
      description: description,
      sourceUrl: sourceUrl,
      imageUrl: url,
      dormImageUrl: dormImageUrl,
    );
  }

  /// Returns a copy with [dormImageUrl] set (used by the image-merge loader).
  UniversityRecord withDormImageUrl(String? url) {
    return UniversityRecord(
      id: id,
      nameRu: nameRu,
      nameKz: nameKz,
      nameEn: nameEn,
      city: city,
      type: type,
      website: website,
      hasDormitory: hasDormitory,
      description: description,
      sourceUrl: sourceUrl,
      imageUrl: imageUrl,
      dormImageUrl: url,
    );
  }
}

/// An education program group (ГОП — группа образовательных программ).
@immutable
class EducationProgram {
  /// Creates an [EducationProgram].
  const EducationProgram({
    required this.code,
    required this.nameRu,
    this.nameKz,
    this.field,
    this.entSubject1,
    this.entSubject2,
    this.sourceUrl,
  });

  /// Builds an [EducationProgram] from a decoded JSON map.
  factory EducationProgram.fromJson(Map<String, dynamic> json) {
    return EducationProgram(
      code: json['code'] as String,
      nameRu: json['name_ru'] as String,
      nameKz: json['name_kz'] as String?,
      field: json['field'] as String?,
      entSubject1: json['ent_profile_subject_1'] as String?,
      entSubject2: json['ent_profile_subject_2'] as String?,
      sourceUrl: json['source_url'] as String?,
    );
  }

  /// ГОП code, e.g. `B057`.
  final String code;

  /// Russian name.
  final String nameRu;

  /// Kazakh name.
  final String? nameKz;

  /// Academic field key (maps to the app's AcademicField).
  final String? field;

  /// First profile ЕНТ subject.
  final String? entSubject1;

  /// Second profile ЕНТ subject.
  final String? entSubject2;

  /// Provenance URL.
  final String? sourceUrl;
}

/// A university's offering of a particular [EducationProgram].
@immutable
class UniversityProgram {
  /// Creates a [UniversityProgram].
  const UniversityProgram({
    required this.universityId,
    required this.programCode,
    this.tuitionPerYearKzt,
    this.languages = const <String>[],
    this.grantPlaces,
    this.sourceUrl,
  });

  /// Builds a [UniversityProgram] from a decoded JSON map.
  factory UniversityProgram.fromJson(Map<String, dynamic> json) {
    return UniversityProgram(
      universityId: json['university_id'] as String,
      programCode: json['program_code'] as String,
      tuitionPerYearKzt: json['tuition_per_year_kzt'] as int?,
      languages:
          (json['languages'] as List<dynamic>?)?.cast<String>() ??
          const <String>[],
      grantPlaces: json['grant_places'] as int?,
      sourceUrl: json['source_url'] as String?,
    );
  }

  /// References [UniversityRecord.id].
  final String universityId;

  /// References [EducationProgram.code].
  final String programCode;

  /// Annual tuition in tenge; null when unknown.
  final int? tuitionPerYearKzt;

  /// Languages of instruction (`ru`, `kz`, `en`).
  final List<String> languages;

  /// Number of state-grant places, when known.
  final int? grantPlaces;

  /// Provenance URL.
  final String? sourceUrl;
}

/// What a [GrantThreshold] score actually measures. These are distinct in KZ
/// and must never be conflated in the UI.
enum GrantMetric {
  /// Проходной балл — последний зачисленный на грант (итог конкурса).
  cutoff,

  /// Минимальный балл для допуска к конкурсу на грант.
  competitionMin,

  /// Минимальный балл для зачисления на платное.
  paidMin,

  /// Пороговый минимум из приказа МНВО (national floor).
  nationalFloor,
}

/// Parses a [GrantMetric] from its JSON string, defaulting to
/// [GrantMetric.cutoff].
GrantMetric grantMetricFromJson(String? raw) {
  switch (raw) {
    case 'competition_min':
      return GrantMetric.competitionMin;
    case 'paid_min':
      return GrantMetric.paidMin;
    case 'national_floor':
      return GrantMetric.nationalFloor;
    case 'cutoff':
    default:
      return GrantMetric.cutoff;
  }
}

/// Russian label for a [GrantMetric] — use this exact wording in the UI so a
/// "minimum to compete" is never shown as a "проходной балл".
String grantMetricLabel(GrantMetric metric) {
  switch (metric) {
    case GrantMetric.cutoff:
      return 'Проходной балл на грант';
    case GrantMetric.competitionMin:
      return 'Минимум для участия в конкурсе на грант';
    case GrantMetric.paidMin:
      return 'Минимум на платное';
    case GrantMetric.nationalFloor:
      return 'Пороговый минимум (приказ МНВО)';
  }
}

/// A grant score for a program (and optionally a university), year and quota.
/// [metric] says what the score means — read it before showing the number.
@immutable
class GrantThreshold {
  /// Creates a [GrantThreshold].
  const GrantThreshold({
    required this.programCode,
    required this.year,
    required this.quotaType,
    required this.metric,
    required this.sourceUrl,
    required this.isVerified,
    this.universityId,
    this.minScore,
    this.maxScore,
    this.note,
  });

  /// Builds a [GrantThreshold] from a decoded JSON map.
  factory GrantThreshold.fromJson(Map<String, dynamic> json) {
    return GrantThreshold(
      programCode: json['program_code'] as String,
      universityId: json['university_id'] as String?,
      year: json['year'] as int,
      quotaType: quotaTypeFromJson(json['quota_type'] as String?),
      metric: grantMetricFromJson(json['metric'] as String?),
      minScore: json['min_score'] as int?,
      maxScore: json['max_score'] as int?,
      isVerified: json['is_verified'] as bool? ?? false,
      sourceUrl: json['source_url'] as String,
      note: json['note'] as String?,
    );
  }

  /// References [EducationProgram.code].
  final String programCode;

  /// References [UniversityRecord.id]; null = national ГОП-level cutoff.
  final String? universityId;

  /// Admission year the cutoff is for.
  final int year;

  /// Quota the cutoff applies to.
  final QuotaType quotaType;

  /// What [minScore]/[maxScore] actually measure.
  final GrantMetric metric;

  /// The score value (meaning depends on [metric]).
  final int? minScore;

  /// Highest admitted grant score, when published.
  final int? maxScore;

  /// True only when sourced from a primary publication. The UI must not present
  /// an unverified threshold as a hard fact.
  final bool isVerified;

  /// Provenance URL (required — honesty guard).
  final String sourceUrl;

  /// Free-text note (e.g. caveats about the source).
  final String? note;
}

/// The full in-memory catalog with lookup helpers.
@immutable
class UniversityCatalog {
  /// Creates a [UniversityCatalog].
  const UniversityCatalog({
    required this.universities,
    required this.programs,
    required this.offerings,
    required this.thresholds,
  });

  /// An empty catalog (used as a safe fallback).
  static const UniversityCatalog empty = UniversityCatalog(
    universities: <UniversityRecord>[],
    programs: <EducationProgram>[],
    offerings: <UniversityProgram>[],
    thresholds: <GrantThreshold>[],
  );

  /// All universities.
  final List<UniversityRecord> universities;

  /// All education programs (ГОП).
  final List<EducationProgram> programs;

  /// All university↔program offerings.
  final List<UniversityProgram> offerings;

  /// All grant thresholds.
  final List<GrantThreshold> thresholds;

  /// Programs offered by [universityId].
  List<EducationProgram> programsForUniversity(String universityId) {
    final codes = offerings
        .where((o) => o.universityId == universityId)
        .map((o) => o.programCode)
        .toSet();
    return programs.where((p) => codes.contains(p.code)).toList();
  }

  /// Verified thresholds for [programCode], newest year first.
  List<GrantThreshold> verifiedThresholdsForProgram(String programCode) {
    final list = thresholds
        .where((t) => t.programCode == programCode && t.isVerified)
        .toList()
      ..sort((a, b) => b.year.compareTo(a.year));
    return list;
  }

  /// The university with [id], or null.
  UniversityRecord? universityById(String id) {
    for (final u in universities) {
      if (u.id == id) return u;
    }
    return null;
  }

  /// Number of programs [universityId] offers.
  int offeringCountFor(String universityId) =>
      offerings.where((o) => o.universityId == universityId).length;

  /// Lowest competition-entry minimum across this university's programs, or
  /// null if none. NOT a проходной балл — see [GrantMetric.competitionMin].
  int? minCompetitionScoreFor(String universityId) {
    int? best;
    for (final t in thresholds) {
      if (t.universityId == universityId &&
          t.metric == GrantMetric.competitionMin &&
          t.minScore != null) {
        best = best == null ? t.minScore : math.min(best, t.minScore!);
      }
    }
    return best;
  }

  /// Thresholds for a specific [universityId] + [programCode], newest first.
  List<GrantThreshold> thresholdsFor(String universityId, String programCode) {
    final list = thresholds
        .where(
          (t) => t.universityId == universityId && t.programCode == programCode,
        )
        .toList()
      ..sort((a, b) => b.year.compareTo(a.year));
    return list;
  }

  /// Distinct cities present, sorted.
  List<String> get cities {
    final set = <String>{};
    for (final u in universities) {
      if (u.city.trim().isNotEmpty) set.add(u.city.trim());
    }
    final list = set.toList()..sort();
    return list;
  }

  /// Distinct (known) university types present, in enum order.
  List<UniversityType> get typesPresent {
    final set = universities.map((u) => u.type).whereType<UniversityType>().toSet();
    return UniversityType.values.where(set.contains).toList();
  }

  /// The set of [MajorCategory] values covered by [universityId]'s programs.
  ///
  /// Used to decide whether a university passes the major filter.
  Set<MajorCategory> universityCategoriesFor(String universityId) {
    final programsForUni = programsForUniversity(universityId);
    return programsForUni.map(majorCategoryFromProgram).toSet();
  }

  /// Distinct [MajorCategory] values that appear in at least one university's
  /// program list, in the enum declaration order.
  List<MajorCategory> get majorCategoriesPresent {
    final set = <MajorCategory>{};
    for (final u in universities) {
      set.addAll(universityCategoriesFor(u.id));
    }
    return MajorCategory.values.where(set.contains).toList();
  }
}
