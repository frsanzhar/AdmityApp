import 'package:flutter/foundation.dart';

/// Common Data Set factor importance (section C7).
enum FactorImportance {
  veryImportant('Очень важно'),
  important('Важно'),
  considered('Учитывается'),
  notConsidered('Не учитывается');

  const FactorImportance(this.label);

  final String label;
}

/// A snapshot of a university's Common Data Set admissions data.
@immutable
class CdsSnapshot {
  const CdsSnapshot({
    required this.university,
    required this.year,
    required this.acceptanceRate,
    this.sat25,
    this.sat75,
    this.act25,
    this.act75,
    this.gpaAvg,
    this.factors = const {},
  });

  factory CdsSnapshot.fromJson(Map<String, dynamic> json) => CdsSnapshot(
        university: json['university'] as String,
        year: (json['year'] as num).toInt(),
        acceptanceRate: (json['acceptance_rate'] as num).toDouble(),
        sat25: (json['sat_25'] as num?)?.toInt(),
        sat75: (json['sat_75'] as num?)?.toInt(),
        act25: (json['act_25'] as num?)?.toInt(),
        act75: (json['act_75'] as num?)?.toInt(),
        gpaAvg: (json['gpa_avg'] as num?)?.toDouble(),
        factors: ((json['factors'] as Map<String, dynamic>?) ?? {}).map(
          (k, v) => MapEntry(k, FactorImportance.values.byName(v as String)),
        ),
      );

  final String university;
  final int year;

  /// Overall admit rate, 0..1.
  final double acceptanceRate;
  final int? sat25;
  final int? sat75;
  final int? act25;
  final int? act75;
  final double? gpaAvg;
  final Map<String, FactorImportance> factors;

  /// Factor keys marked very important (drives "where you can strengthen").
  List<String> get veryImportantFactors => factors.entries
      .where((e) => e.value == FactorImportance.veryImportant)
      .map((e) => e.key)
      .toList();
}
