/// Domain model for a study material — a downloadable resource for exam prep.
library;

/// The target exam for a [StudyMaterial].
enum StudyMaterialExam { ielts, sat, ent, other }

/// Returns the human-readable label for [exam].
String studyMaterialExamLabel(StudyMaterialExam exam) {
  switch (exam) {
    case StudyMaterialExam.ielts:
      return 'IELTS';
    case StudyMaterialExam.sat:
      return 'SAT';
    case StudyMaterialExam.ent:
      return 'ЕНТ';
    case StudyMaterialExam.other:
      return 'Другое';
  }
}

/// Parses a raw string value from the database into [StudyMaterialExam].
StudyMaterialExam parseStudyMaterialExam(String? raw) {
  switch (raw?.toLowerCase().trim()) {
    case 'ielts':
      return StudyMaterialExam.ielts;
    case 'sat':
      return StudyMaterialExam.sat;
    case 'ent':
      return StudyMaterialExam.ent;
    default:
      return StudyMaterialExam.other;
  }
}

/// A downloadable study material (book, practice test, etc.).
class StudyMaterial {
  /// Creates a [StudyMaterial].
  const StudyMaterial({
    required this.id,
    required this.title,
    required this.description,
    required this.exam,
    required this.fileUrl,
    required this.createdAt,
    this.major,
    this.sizeLabel,
  });

  /// Deserializes from a Supabase row (snake_case keys).
  factory StudyMaterial.fromJson(Map<String, dynamic> json) {
    return StudyMaterial(
      id: json['id'] as String,
      title: json['title'] as String,
      description: json['description'] as String? ?? '',
      exam: parseStudyMaterialExam(json['exam'] as String?),
      major: json['major'] as String?,
      fileUrl: json['file_url'] as String,
      sizeLabel: json['size_label'] as String?,
      createdAt: DateTime.parse(json['created_at'] as String),
    );
  }

  /// Unique row identifier.
  final String id;

  /// Short title shown as the card heading.
  final String title;

  /// Longer description of the material's content.
  final String description;

  /// Target exam.
  final StudyMaterialExam exam;

  /// Optional academic major / subject area.
  final String? major;

  /// Direct download or view URL.
  final String fileUrl;

  /// Human-readable file size, e.g. '3.2 МБ'.
  final String? sizeLabel;

  /// Insertion timestamp — used for newest/oldest sort.
  final DateTime createdAt;
}
