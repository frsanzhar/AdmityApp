// Seed domain models for the Opportunities feature.
// No backend yet — all data is Dart constants in opportunity_seed.dart.
// When a repository is wired, replace the seed constants with async calls
// that return these same types.

/// The four top-level sections of the Opportunities tab.
enum OpportunitySection {
  scholarships,
  universities,
  events,
  projectIdeas,
}

/// Academic field / направление — used for filtering + project ideas.
enum AcademicField {
  mathematics,
  engineering,
  medicine,
  economics,
  arts,
  law,
  informatics,
  natural,
}

String academicFieldLabel(AcademicField f) {
  switch (f) {
    case AcademicField.mathematics:
      return 'Математика';
    case AcademicField.engineering:
      return 'Инженерия';
    case AcademicField.medicine:
      return 'Медицина';
    case AcademicField.economics:
      return 'Экономика';
    case AcademicField.arts:
      return 'Искусство';
    case AcademicField.law:
      return 'Право';
    case AcademicField.informatics:
      return 'Информатика';
    case AcademicField.natural:
      return 'Естественные науки';
  }
}

/// Accessibility level — how easy it is to qualify.
enum Accessibility { easy, medium, hard }

String accessibilityLabel(Accessibility a) {
  switch (a) {
    case Accessibility.easy:
      return 'Легко';
    case Accessibility.medium:
      return 'Средне';
    case Accessibility.hard:
      return 'Сложно';
  }
}

/// A scholarship entity.
class Scholarship {
  const Scholarship({
    required this.id,
    required this.name,
    required this.city,
    required this.field,
    required this.coverageLabel,
    required this.accessibility,
    required this.requiredDocuments,
    required this.whatItCovers,
    required this.howToGet,
    required this.requiredStats,
    required this.howToBoostStats,
    this.priceLabel,
  });

  final String id;
  final String name;
  final String city;
  final AcademicField field;

  /// Human-readable coverage (e.g. "100 % оплата обучения").
  final String coverageLabel;

  /// If there is a cash/grant component, e.g. "250 000 ₸/мес".
  final String? priceLabel;

  final Accessibility accessibility;
  final List<String> requiredDocuments;
  final String whatItCovers;
  final String howToGet;

  /// Stats needed (e.g. "ЕНТ ≥ 110 баллов, GPA ≥ 4.0").
  final String requiredStats;

  /// How to reach those stats ("как добить").
  final String howToBoostStats;
}

/// A university entity.
class University {
  const University({
    required this.id,
    required this.name,
    required this.city,
    required this.field,
    required this.tuitionLabel,
    required this.accessibility,
    required this.description,
    required this.entThreshold,
    this.mission,
    this.programs,
    this.acceptanceRate,
    this.requirements,
    this.scholarshipInfo,
    this.admissionSteps,
    this.websiteLabel,
  });

  final String id;
  final String name;
  final String city;
  final AcademicField field;
  final String tuitionLabel;
  final Accessibility accessibility;
  final String description;
  final int entThreshold;

  /// Short mission / about statement.
  final String? mission;

  /// List of academic programmes / directions offered.
  final List<String>? programs;

  /// Realistic acceptance rate as a fraction (0.0–1.0). Honest — never inflated.
  final double? acceptanceRate;

  /// Admission requirements in human-readable form.
  final String? requirements;

  /// Information about available scholarships / grants.
  final String? scholarshipInfo;

  /// Step-by-step guide ("как поступить").
  final List<String>? admissionSteps;

  /// Human-readable website label (e.g. "nu.edu.kz").
  final String? websiteLabel;
}

/// A nearby event.
class OpportunityEvent {
  const OpportunityEvent({
    required this.id,
    required this.title,
    required this.dateLabel,
    required this.city,
    required this.description,
    this.location,
    this.format,
    this.howToParticipate,
    this.prize,
    this.registrationDeadline,
    this.registrationUrl,
  });

  final String id;
  final String title;
  final String dateLabel;
  final String city;
  final String description;

  /// Venue or online platform.
  final String? location;

  /// "Очно" / "Онлайн" / "Гибридный".
  final String? format;

  /// Steps to participate ("как участвовать").
  final List<String>? howToParticipate;

  /// Prize / reward description.
  final String? prize;

  /// Registration deadline (human-readable).
  final String? registrationDeadline;

  /// Registration link label (e.g. "hackalmaty.kz").
  final String? registrationUrl;
}

/// A project idea (keyed to an academic field).
class ProjectIdea {
  const ProjectIdea({
    required this.id,
    required this.title,
    required this.field,
    required this.description,
    required this.difficulty,
    this.whyItFits,
    this.steps,
    this.expectedOutcome,
    this.techStack,
  });

  final String id;
  final String title;
  final AcademicField field;
  final String description;
  final String difficulty;

  /// Why this idea matches student interests in this field.
  final String? whyItFits;

  /// Ordered list of steps to execute the project.
  final List<String>? steps;

  /// What the student will have at the end.
  final String? expectedOutcome;

  /// Technologies / tools involved (for portfolio context).
  final String? techStack;
}

/// Filter state applied to the scholarships / universities list.
class OpportunityFilter {
  const OpportunityFilter({
    this.city,
    this.field,
    this.accessibility,
  });

  final String? city;
  final AcademicField? field;
  final Accessibility? accessibility;

  OpportunityFilter copyWith({
    String? city,
    AcademicField? field,
    Accessibility? accessibility,
    bool clearCity = false,
    bool clearField = false,
    bool clearAccessibility = false,
  }) {
    return OpportunityFilter(
      city: clearCity ? null : (city ?? this.city),
      field: clearField ? null : (field ?? this.field),
      accessibility: clearAccessibility
          ? null
          : (accessibility ?? this.accessibility),
    );
  }

  bool get isEmpty => city == null && field == null && accessibility == null;
}
