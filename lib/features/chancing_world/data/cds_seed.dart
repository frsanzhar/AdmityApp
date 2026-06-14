import 'package:admity/features/chancing_world/domain/cds_models.dart';

/// Reference Common Data Set snapshots. Ranges are 25–75 percentile bands and
/// are orientation, not cut-offs. Sources: each school's CDS (commondataset.org).
const List<CdsSnapshot> kCdsSeed = [
  CdsSnapshot(
    university: 'Harvard University',
    year: 2024,
    acceptanceRate: 0.04,
    sat25: 1500,
    sat75: 1580,
    act25: 34,
    act75: 36,
    gpaAvg: 4.18,
    factors: {
      'rigor': FactorImportance.veryImportant,
      'gpa': FactorImportance.veryImportant,
      'essay': FactorImportance.veryImportant,
      'recommendations': FactorImportance.veryImportant,
      'character': FactorImportance.veryImportant,
      'talent': FactorImportance.veryImportant,
      'extracurricular': FactorImportance.important,
      'interest': FactorImportance.notConsidered,
    },
  ),
  CdsSnapshot(
    university: 'MIT',
    year: 2024,
    acceptanceRate: 0.04,
    sat25: 1520,
    sat75: 1580,
    act25: 35,
    act75: 36,
    factors: {
      'rigor': FactorImportance.veryImportant,
      'gpa': FactorImportance.veryImportant,
      'essay': FactorImportance.veryImportant,
      'character': FactorImportance.veryImportant,
      'talent': FactorImportance.veryImportant,
    },
  ),
  CdsSnapshot(
    university: 'University of Michigan',
    year: 2024,
    acceptanceRate: 0.18,
    sat25: 1370,
    sat75: 1530,
    act25: 32,
    act75: 35,
    factors: {
      'rigor': FactorImportance.veryImportant,
      'gpa': FactorImportance.veryImportant,
      'essay': FactorImportance.important,
      'extracurricular': FactorImportance.important,
    },
  ),
  CdsSnapshot(
    university: 'Arizona State University',
    year: 2024,
    acceptanceRate: 0.88,
    sat25: 1110,
    sat75: 1350,
    act25: 21,
    act75: 28,
    factors: {
      'gpa': FactorImportance.veryImportant,
      'rigor': FactorImportance.important,
    },
  ),
  CdsSnapshot(
    university: 'University of Amsterdam (orientation)',
    year: 2024,
    acceptanceRate: 0.6,
    sat25: 1200,
    sat75: 1400,
    factors: {
      'gpa': FactorImportance.veryImportant,
      'rigor': FactorImportance.veryImportant,
    },
  ),
];
