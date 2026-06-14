import 'package:admity/features/chancing_kz/domain/ent_models.dart';
import 'package:admity/shared/models/chance_category.dart';
import 'package:flutter/foundation.dart';

/// Result of an ЕНТ chancing computation. Deterministic and explainable —
/// no fabricated percentage, only a category plus the margins it derives from.
@immutable
class EntChancingResult {
  const EntChancingResult({
    required this.category,
    required this.total,
    required this.govThreshold,
    required this.meetsSubjectMinimums,
    required this.marginToThreshold,
    this.realCutoff,
    this.marginToCutoff,
  });

  final KzChance category;
  final int total;
  final int govThreshold;
  final bool meetsSubjectMinimums;

  /// `total - govThreshold` (negative means below the floor).
  final int marginToThreshold;

  /// Last published real cut-off, if known.
  final int? realCutoff;

  /// `total - realCutoff` when [realCutoff] is known.
  final int? marginToCutoff;
}

/// Pure ЕНТ chancing logic.
///
/// Categories:
/// * [KzChance.belowThreshold] — fails a per-subject minimum, or total below
///   the gov/university threshold.
/// * [KzChance.atRisk] — clears the threshold but is below, at, or only just
///   above the most recent real cut-off (cut-offs move year to year).
/// * [KzChance.safe] — comfortably above the recent real cut-off (or, with no
///   cut-off data, well above the threshold).
abstract final class EntChancing {
  /// Margin above the real cut-off required to be considered [KzChance.safe].
  static const int safeMargin = 4;

  /// Margin above the bare threshold (when no real cut-off is known) to be
  /// considered [KzChance.safe].
  static const int safeMarginNoData = 12;

  static EntChancingResult evaluate({
    required EntScore score,
    required int govThreshold,
    int? realCutoff,
  }) {
    final total = score.total;
    final meetsMins = score.meetsSubjectMinimums;
    final marginToThreshold = total - govThreshold;
    final marginToCutoff = realCutoff == null ? null : total - realCutoff;

    final KzChance category;
    if (!meetsMins || total < govThreshold) {
      category = KzChance.belowThreshold;
    } else if (realCutoff != null) {
      if (total >= realCutoff + safeMargin) {
        category = KzChance.safe;
      } else {
        // At, below, or only just above last year's bar — genuinely uncertain.
        category = KzChance.atRisk;
      }
    } else {
      category = total >= govThreshold + safeMarginNoData
          ? KzChance.safe
          : KzChance.atRisk;
    }

    return EntChancingResult(
      category: category,
      total: total,
      govThreshold: govThreshold,
      meetsSubjectMinimums: meetsMins,
      marginToThreshold: marginToThreshold,
      realCutoff: realCutoff,
      marginToCutoff: marginToCutoff,
    );
  }

  /// Convenience overload working directly from an [EntCutoff] record.
  static EntChancingResult evaluateForCutoff({
    required EntScore score,
    required EntCutoff cutoff,
  }) =>
      evaluate(
        score: score,
        govThreshold: cutoff.govThreshold,
        realCutoff: cutoff.realCutoff,
      );
}
