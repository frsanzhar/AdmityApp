import 'package:flutter/foundation.dart';

/// A grade on the Kazakh 5-point scale, with a mapping to the US 4.0 scale.
///
/// The Kazakh school system grades 5 (excellent) down to 2 (unsatisfactory);
/// 1 is effectively unused. We map each to a conventional US 4.0 equivalent so
/// the same table can show both scales side by side.
enum Grade {
  /// «Отлично» — 5 on the 5-point scale, 4.0 on the US scale.
  excellent(5, 4),

  /// «Хорошо» — 4 on the 5-point scale, 3.0 on the US scale.
  good(4, 3),

  /// «Удовлетворительно» — 3 on the 5-point scale, 2.0 on the US scale.
  satisfactory(3, 2),

  /// «Неудовлетворительно» — 2 on the 5-point scale, 1.0 on the US scale.
  unsatisfactory(2, 1);

  const Grade(this.points5, this.points4);

  /// The value on the Kazakh 5-point scale (2..5).
  final int points5;

  /// The value on the US 4.0 scale (1..4).
  final int points4;

  /// Resolves a [Grade] from its 5-point value, defaulting to [excellent]
  /// for any out-of-range input.
  static Grade fromPoints5(int value) {
    for (final g in Grade.values) {
      if (g.points5 == value) return g;
    }
    return Grade.excellent;
  }

  /// Short Russian label for the grade (e.g. «5 — отлично»).
  String get labelRu => switch (this) {
        Grade.excellent => '5 — отлично',
        Grade.good => '4 — хорошо',
        Grade.satisfactory => '3 — удовл.',
        Grade.unsatisfactory => '2 — неуд.',
      };
}

/// A single academic subject in the GPA table: its name, the [Grade], and an
/// optional credit/hour weight used for credit-weighted averaging.
@immutable
class Subject {
  /// Creates an immutable subject row.
  const Subject({
    required this.id,
    required this.name,
    required this.grade,
    this.credits,
  });

  /// Rebuilds a [Subject] from its JSON form (as stored locally).
  factory Subject.fromJson(Map<String, dynamic> json) => Subject(
        id: json['id'] as String,
        name: json['name'] as String,
        grade: Grade.fromPoints5((json['grade'] as num?)?.toInt() ?? 5),
        credits: (json['credits'] as num?)?.toDouble(),
      );

  /// Stable unique identifier for this row.
  final String id;

  /// Human-readable subject name (e.g. «Математика»).
  final String name;

  /// The grade earned in this subject.
  final Grade grade;

  /// Optional credit hours; when present across rows GPA is credit-weighted.
  final double? credits;

  /// Serializes this subject to a JSON-compatible map.
  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'grade': grade.points5,
        'credits': credits,
      };

  /// Returns a copy with selected fields replaced.
  Subject copyWith({String? name, Grade? grade, double? credits}) => Subject(
        id: id,
        name: name ?? this.name,
        grade: grade ?? this.grade,
        credits: credits ?? this.credits,
      );
}
