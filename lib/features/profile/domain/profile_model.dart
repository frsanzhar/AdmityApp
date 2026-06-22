/// Domain models for the Profile feature (§7.7 DESIGN_SYSTEM.md).
///
/// Privacy-first for minors: only fields the student explicitly provides.
/// All fields nullable — nothing is required to use the app.
library;

// ── StudentProfile ────────────────────────────────────────────────────────────

/// The student's self-described data.
///
/// Stored locally; Supabase sync is a future concern.
/// No PII field is mandatory — this is for minors.
class StudentProfile {
  const StudentProfile({
    this.name,
    this.grade,
    this.city,
    this.gpaBand,
    this.gpa,
    this.interests = const [],
    this.ieltsScore,
    this.satScore,
    this.toeflScore,
    this.careerResult,
    this.onboardingComplete = false,
    this.targetUniversities = const [],
    this.targetMajors = const [],
    this.languages = const [],
  });

  /// Deserialises from a raw JSON map (code-free persistence — no codegen).
  factory StudentProfile.fromJson(Map<String, dynamic> json) {
    return StudentProfile(
      name: json['name'] as String?,
      grade: json['grade'] as String?,
      city: json['city'] as String?,
      gpaBand: json['gpa_band'] as String?,
      gpa: json['gpa'] as String?,
      interests: _stringList(json['interests']),
      ieltsScore: json['ielts_score'] as String?,
      satScore: json['sat_score'] as String?,
      toeflScore: json['toefl_score'] as String?,
      careerResult: json['career_result'] as String?,
      onboardingComplete: (json['onboarding_complete'] as bool?) ?? false,
      targetUniversities: _stringList(json['target_universities']),
      targetMajors: _stringList(json['target_majors']),
      languages: _stringList(json['languages']),
    );
  }

  static const empty = StudentProfile();

  /// Student's display name (optional, user-chosen).
  final String? name;

  /// School grade / class (e.g. "11 класс") — drives course selection.
  final String? grade;

  /// City / region string — used to surface nearby events (§7.6).
  final String? city;

  /// GPA as a rough band string (e.g. "4.5–5.0") — never a raw number sent
  /// to the server; see CLAUDE.md on PII minimisation.
  final String? gpaBand;

  /// Average grade / GPA as the student entered it during onboarding.
  final String? gpa;

  /// Interests / hobbies — drive course suggestions + project ideas (§7.6).
  final List<String> interests;

  /// Standardized exam scores (null = not taken). Strings keep them flexible.
  final String? ieltsScore;
  final String? satScore;
  final String? toeflScore;

  /// Career-orientation test result label (null until the test is taken).
  final String? careerResult;

  /// Whether the student finished the onboarding flow (gates the intro).
  final bool onboardingComplete;

  /// Universities the student is targeting.
  final List<String> targetUniversities;

  /// Academic majors / directions of interest.
  final List<String> targetMajors;

  /// Languages the student uses (e.g. ["KZ", "RU", "EN"]).
  final List<String> languages;

  StudentProfile copyWith({
    String? name,
    String? grade,
    String? city,
    String? gpaBand,
    String? gpa,
    List<String>? interests,
    String? ieltsScore,
    String? satScore,
    String? toeflScore,
    String? careerResult,
    bool? onboardingComplete,
    List<String>? targetUniversities,
    List<String>? targetMajors,
    List<String>? languages,
  }) {
    return StudentProfile(
      name: name ?? this.name,
      grade: grade ?? this.grade,
      city: city ?? this.city,
      gpaBand: gpaBand ?? this.gpaBand,
      gpa: gpa ?? this.gpa,
      interests: interests ?? this.interests,
      ieltsScore: ieltsScore ?? this.ieltsScore,
      satScore: satScore ?? this.satScore,
      toeflScore: toeflScore ?? this.toeflScore,
      careerResult: careerResult ?? this.careerResult,
      onboardingComplete: onboardingComplete ?? this.onboardingComplete,
      targetUniversities: targetUniversities ?? this.targetUniversities,
      targetMajors: targetMajors ?? this.targetMajors,
      languages: languages ?? this.languages,
    );
  }

  /// Serialises to a raw JSON map (code-free persistence — no codegen).
  Map<String, dynamic> toJson() => {
    'name': name,
    'grade': grade,
    'city': city,
    'gpa_band': gpaBand,
    'gpa': gpa,
    'interests': interests,
    'ielts_score': ieltsScore,
    'sat_score': satScore,
    'toefl_score': toeflScore,
    'career_result': careerResult,
    'onboarding_complete': onboardingComplete,
    'target_universities': targetUniversities,
    'target_majors': targetMajors,
    'languages': languages,
  };
}

// ── ProfileNote ───────────────────────────────────────────────────────────────

/// A free-form note the student writes about themselves.
class ProfileNote {
  const ProfileNote({
    required this.id,
    required this.text,
    required this.createdAt,
    this.updatedAt,
  });

  factory ProfileNote.fromJson(Map<String, dynamic> json) {
    return ProfileNote(
      id: json['id'] as String,
      text: json['text'] as String,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: json['updated_at'] != null
          ? DateTime.parse(json['updated_at'] as String)
          : null,
    );
  }

  final String id;
  final String text;
  final DateTime createdAt;
  final DateTime? updatedAt;

  ProfileNote copyWith({
    String? text,
    DateTime? updatedAt,
  }) {
    return ProfileNote(
      id: id,
      text: text ?? this.text,
      createdAt: createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'text': text,
    'created_at': createdAt.toIso8601String(),
    'updated_at': updatedAt?.toIso8601String(),
  };
}

// ── DocumentPackage ───────────────────────────────────────────────────────────

/// A named collection of document items the student assembles to send together
/// (§7.7: "Документы как пакет — чтобы отправлять разом без возни").
class DocumentPackage {
  const DocumentPackage({
    required this.id,
    required this.name,
    required this.createdAt,
    this.description,
    this.items = const [],
  });

  factory DocumentPackage.fromJson(Map<String, dynamic> json) {
    final rawItems = json['items'];
    final items = <DocumentItem>[];
    if (rawItems is List) {
      for (final item in rawItems) {
        if (item is Map<String, dynamic>) {
          items.add(DocumentItem.fromJson(item));
        }
      }
    }
    return DocumentPackage(
      id: json['id'] as String,
      name: json['name'] as String,
      description: json['description'] as String?,
      items: items,
      createdAt: DateTime.parse(json['created_at'] as String),
    );
  }

  final String id;

  /// Human label (e.g. "NU Application Pack").
  final String name;
  final String? description;
  final List<DocumentItem> items;
  final DateTime createdAt;

  DocumentPackage copyWith({
    String? name,
    String? description,
    List<DocumentItem>? items,
  }) {
    return DocumentPackage(
      id: id,
      name: name ?? this.name,
      description: description ?? this.description,
      items: items ?? this.items,
      createdAt: createdAt,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'description': description,
    'items': items.map((e) => e.toJson()).toList(),
    'created_at': createdAt.toIso8601String(),
  };
}

// ── DocumentItem ──────────────────────────────────────────────────────────────

/// A single document slot inside a [DocumentPackage].
///
/// Actual file attachment is a future concern — see TODO(files).
class DocumentItem {
  const DocumentItem({
    required this.id,
    required this.label,
    this.filePath,
    this.mimeType,
    this.isAttached = false,
  });

  factory DocumentItem.fromJson(Map<String, dynamic> json) {
    return DocumentItem(
      id: json['id'] as String,
      label: json['label'] as String,
      filePath: json['file_path'] as String?,
      mimeType: json['mime_type'] as String?,
      isAttached: (json['is_attached'] as bool?) ?? false,
    );
  }

  final String id;

  /// Human-readable label (e.g. "Транскрипт", "Рекомендательное письмо").
  final String label;

  /// Local file path once attached — null until user attaches a file.
  // TODO(files): wire to file picker
  final String? filePath;

  /// MIME type of the attached file (null until attached).
  final String? mimeType;

  /// Whether a file has been attached to this slot.
  final bool isAttached;

  DocumentItem copyWith({
    String? label,
    String? filePath,
    String? mimeType,
    bool? isAttached,
  }) {
    return DocumentItem(
      id: id,
      label: label ?? this.label,
      filePath: filePath ?? this.filePath,
      mimeType: mimeType ?? this.mimeType,
      isAttached: isAttached ?? this.isAttached,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'label': label,
    'file_path': filePath,
    'mime_type': mimeType,
    'is_attached': isAttached,
  };
}

// ── Helper ────────────────────────────────────────────────────────────────────

List<String> _stringList(dynamic raw) {
  if (raw is List) {
    return raw.whereType<String>().toList();
  }
  return const [];
}
