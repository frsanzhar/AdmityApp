import 'package:admity/features/gpa/domain/gpa_models.dart';

/// The computed grade-point averages for a set of subjects, on both the
/// Kazakh 5-point scale and the US 4.0 scale.
class GpaResult {
  /// Creates an immutable GPA result.
  const GpaResult({required this.scale5, required this.scale4});

  /// An empty result (no subjects) — both averages are zero.
  static const GpaResult empty = GpaResult(scale5: 0, scale4: 0);

  /// Weighted average on the Kazakh 5-point scale (0..5).
  final double scale5;

  /// Weighted average on the US 4.0 scale (0..4).
  final double scale4;
}

/// Pure GPA math over a list of [Subject]s. No UI, no I/O.
///
/// If every subject carries a positive [Subject.credits] value the average is
/// credit-weighted; otherwise it falls back to a simple (equal-weight) mean.
abstract final class GpaCalculator {
  /// Computes the GPA on both scales for [subjects].
  static GpaResult compute(List<Subject> subjects) {
    if (subjects.isEmpty) return GpaResult.empty;

    final useCredits =
        subjects.every((s) => (s.credits ?? 0) > 0);

    if (useCredits) {
      var weightSum = 0.0;
      var weighted5 = 0.0;
      var weighted4 = 0.0;
      for (final s in subjects) {
        final w = s.credits!;
        weightSum += w;
        weighted5 += s.grade.points5 * w;
        weighted4 += s.grade.points4 * w;
      }
      if (weightSum == 0) return GpaResult.empty;
      return GpaResult(
        scale5: weighted5 / weightSum,
        scale4: weighted4 / weightSum,
      );
    }

    var sum5 = 0;
    var sum4 = 0;
    for (final s in subjects) {
      sum5 += s.grade.points5;
      sum4 += s.grade.points4;
    }
    final n = subjects.length;
    return GpaResult(scale5: sum5 / n, scale4: sum4 / n);
  }
}
