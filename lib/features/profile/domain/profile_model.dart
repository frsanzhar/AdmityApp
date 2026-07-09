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
    this.age,
    this.role,
    this.motivation,
    this.subject,
    this.knowledgeLevel,
    this.soundPreference,
    this.dailyGoalMinutes,
    this.schedule,
    this.onboardingComplete = false,
    this.targetUniversities = const [],
    this.targetMajors = const [],
    this.languages = const [],
    this.confidence,
    this.aidTarget,
    this.maxPricePerYear,
    this.authProvider,
    this.authEmail,
    this.attachedDocs = const [],
    this.studyPlan = const [],
    this.appLanguage = 'system',
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
      age: json['age'] as int?,
      role: json['role'] as String?,
      motivation: json['motivation'] as String?,
      subject: json['subject'] as String?,
      knowledgeLevel: json['knowledge_level'] as String?,
      soundPreference: json['sound_preference'] as String?,
      dailyGoalMinutes: json['daily_goal_minutes'] as int?,
      schedule: json['schedule'] as String?,
      onboardingComplete: (json['onboarding_complete'] as bool?) ?? false,
      targetUniversities: _stringList(json['target_universities']),
      targetMajors: _stringList(json['target_majors']),
      languages: _stringList(json['languages']),
      confidence: json['confidence'] as String?,
      aidTarget: json['aid_target'] as String?,
      maxPricePerYear: json['max_price_per_year'] as int?,
      authProvider: json['auth_provider'] as String?,
      authEmail: json['auth_email'] as String?,
      attachedDocs: _stringList(json['attached_docs']),
      studyPlan: _stringList(json['study_plan']),
      appLanguage: (json['app_language'] as String?) ?? 'system',
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

  /// Student age (years), entered during onboarding.
  final int? age;

  /// Role: ученик / родитель / учитель (onboarding role select).
  final String? role;

  /// What motivates the student (onboarding motivation step).
  final String? motivation;

  /// Primary subject focus (e.g. "Математика" / "Информатика").
  final String? subject;

  /// Self-reported knowledge level (onboarding).
  final String? knowledgeLevel;

  /// Mascot sound/voice preference (onboarding).
  final String? soundPreference;

  /// Daily learning goal in minutes (10/20/30/60), chosen during onboarding.
  final int? dailyGoalMinutes;

  /// When the student plans to learn (e.g. "Утро"/"День"/"Вечер").
  final String? schedule;

  /// Whether the student finished the onboarding flow (gates the intro).
  final bool onboardingComplete;

  /// Universities the student is targeting.
  final List<String> targetUniversities;

  /// Academic majors / directions of interest.
  final List<String> targetMajors;

  /// Languages the student uses (e.g. ["KZ", "RU", "EN"]).
  final List<String> languages;

  /// How confident the student feels about getting in (free-form label).
  final String? confidence;

  /// Financial-aid target: one of full_ride | full_tuition | half_tuition | any.
  final String? aidTarget;

  /// Maximum tuition the student/family can pay per year, in KZT.
  final int? maxPricePerYear;

  /// Authentication provider used to sign in: email | google | apple | guest.
  final String? authProvider;

  /// Email address associated with the authenticated account (if any).
  final String? authEmail;

  /// Paths to files the student has attached (local app-documents directory).
  final List<String> attachedDocs;

  /// Ordered list of generated study-plan step strings.
  final List<String> studyPlan;

  /// UI language: 'system' (follow device / Apple ID), 'ru', 'kk' or 'en'.
  final String appLanguage;

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
    int? age,
    String? role,
    String? motivation,
    String? subject,
    String? knowledgeLevel,
    String? soundPreference,
    int? dailyGoalMinutes,
    String? schedule,
    bool? onboardingComplete,
    List<String>? targetUniversities,
    List<String>? targetMajors,
    List<String>? languages,
    String? confidence,
    String? aidTarget,
    int? maxPricePerYear,
    String? authProvider,
    String? authEmail,
    List<String>? attachedDocs,
    List<String>? studyPlan,
    String? appLanguage,
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
      age: age ?? this.age,
      role: role ?? this.role,
      motivation: motivation ?? this.motivation,
      subject: subject ?? this.subject,
      knowledgeLevel: knowledgeLevel ?? this.knowledgeLevel,
      soundPreference: soundPreference ?? this.soundPreference,
      dailyGoalMinutes: dailyGoalMinutes ?? this.dailyGoalMinutes,
      schedule: schedule ?? this.schedule,
      onboardingComplete: onboardingComplete ?? this.onboardingComplete,
      targetUniversities: targetUniversities ?? this.targetUniversities,
      targetMajors: targetMajors ?? this.targetMajors,
      languages: languages ?? this.languages,
      confidence: confidence ?? this.confidence,
      aidTarget: aidTarget ?? this.aidTarget,
      maxPricePerYear: maxPricePerYear ?? this.maxPricePerYear,
      authProvider: authProvider ?? this.authProvider,
      authEmail: authEmail ?? this.authEmail,
      attachedDocs: attachedDocs ?? this.attachedDocs,
      studyPlan: studyPlan ?? this.studyPlan,
      appLanguage: appLanguage ?? this.appLanguage,
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
    'age': age,
    'role': role,
    'motivation': motivation,
    'subject': subject,
    'knowledge_level': knowledgeLevel,
    'sound_preference': soundPreference,
    'daily_goal_minutes': dailyGoalMinutes,
    'schedule': schedule,
    'onboarding_complete': onboardingComplete,
    'target_universities': targetUniversities,
    'target_majors': targetMajors,
    'languages': languages,
    'confidence': confidence,
    'aid_target': aidTarget,
    'max_price_per_year': maxPricePerYear,
    'auth_provider': authProvider,
    'auth_email': authEmail,
    'attached_docs': attachedDocs,
    'study_plan': studyPlan,
    'app_language': appLanguage,
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
