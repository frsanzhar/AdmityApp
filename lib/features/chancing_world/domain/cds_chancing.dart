import 'package:admity/features/chancing_world/domain/cds_models.dart';
import 'package:admity/shared/models/chance_category.dart';
import 'package:flutter/foundation.dart';

/// Selectivity tier derived from acceptance rate.
enum SelectivityTier { superSelective, selective, accessible }

/// Result of a CDS-based chancing computation. No fabricated percentage — a
/// band position, a category, and the factors the school weighs most.
@immutable
class WorldChancingResult {
  const WorldChancingResult({
    required this.category,
    required this.bandPosition,
    required this.tier,
    required this.acceptanceRate,
    required this.veryImportantFactors,
    this.estimatedPercentile,
    this.usedScore,
    this.band25,
    this.band75,
    this.testKind,
  });

  final WorldChance category;
  final BandPosition bandPosition;
  final SelectivityTier tier;
  final double acceptanceRate;
  final List<String> veryImportantFactors;

  /// Linear-interpolated percentile within the 25–75 band (clamped 1..99).
  final int? estimatedPercentile;
  final int? usedScore;
  final int? band25;
  final int? band75;

  /// 'SAT' or 'ACT' — which band was used.
  final String? testKind;
}

/// Pure CDS chancing logic.
abstract final class CdsChancing {
  static SelectivityTier tierFor(double acceptanceRate) {
    if (acceptanceRate < 0.15) return SelectivityTier.superSelective;
    if (acceptanceRate < 0.5) return SelectivityTier.selective;
    return SelectivityTier.accessible;
  }

  /// Places [score] relative to [p25]..[p75]. Returns the band position plus an
  /// interpolated percentile — but ONLY when the score actually sits inside the
  /// 25–75 anchor band. For scores below the 25th or above the 75th (or a
  /// degenerate band), the percentile is `null`: anything else would be
  /// extrapolation, i.e. a fabricated number, which the product never shows.
  static (BandPosition, int?) _place(int score, int p25, int p75) {
    if (p75 <= p25) {
      // Degenerate band (single/equal/dirty values) — only a coarse position
      // is defensible; no interpolation is possible.
      if (score < p25) return (BandPosition.below, null);
      if (score > p25) return (BandPosition.above, null);
      return (BandPosition.middle, null);
    }
    if (score < p25) return (BandPosition.below, null);
    if (score >= p75) return (BandPosition.above, null);

    final raw = 25 + (score - p25) / (p75 - p25) * 50;
    final pct = raw.clamp(1, 99).round();
    final BandPosition pos;
    if (pct < 40) {
      pos = BandPosition.lower;
    } else if (pct <= 60) {
      pos = BandPosition.middle;
    } else {
      pos = BandPosition.upper;
    }
    return (pos, pct);
  }

  /// Evaluates chancing for a student.
  ///
  /// Provide [satComposite] (400–1600) or [actComposite] (1–36); SAT is
  /// preferred when both are present and the school publishes an SAT band.
  static WorldChancingResult evaluate({
    required CdsSnapshot snapshot,
    int? satComposite,
    int? actComposite,
  }) {
    final tier = tierFor(snapshot.acceptanceRate);

    int? usedScore;
    int? p25;
    int? p75;
    String? testKind;
    if (satComposite != null && snapshot.sat25 != null && snapshot.sat75 != null) {
      usedScore = satComposite;
      p25 = snapshot.sat25;
      p75 = snapshot.sat75;
      testKind = 'SAT';
    } else if (actComposite != null &&
        snapshot.act25 != null &&
        snapshot.act75 != null) {
      usedScore = actComposite;
      p25 = snapshot.act25;
      p75 = snapshot.act75;
      testKind = 'ACT';
    }

    BandPosition position;
    int? percentile;
    if (usedScore != null && p25 != null && p75 != null) {
      final (pos, pct) = _place(usedScore, p25, p75);
      position = pos;
      percentile = pct;
    } else {
      // Test-optional / no score provided — neutral middle.
      position = BandPosition.middle;
    }

    final fit = switch (position) {
      BandPosition.below => 0,
      BandPosition.lower => 1,
      BandPosition.middle => 2,
      BandPosition.upper => 3,
      BandPosition.above => 4,
    };

    final category = _category(tier, fit);

    return WorldChancingResult(
      category: category,
      bandPosition: position,
      tier: tier,
      acceptanceRate: snapshot.acceptanceRate,
      veryImportantFactors: snapshot.veryImportantFactors,
      estimatedPercentile: percentile,
      usedScore: usedScore,
      band25: p25,
      band75: p75,
      testKind: testKind,
    );
  }

  static WorldChance _category(SelectivityTier tier, int fit) {
    switch (tier) {
      case SelectivityTier.superSelective:
        // At ultra-low admit rates, strong scores are necessary but never
        // sufficient — honestly a reach for essentially everyone, regardless
        // of where they sit in the band.
        return WorldChance.reach;
      case SelectivityTier.selective:
        if (fit >= 4) return WorldChance.likely;
        if (fit >= 2) return WorldChance.target;
        return WorldChance.reach;
      case SelectivityTier.accessible:
        if (fit >= 2) return WorldChance.likely;
        if (fit >= 1) return WorldChance.target;
        return WorldChance.reach;
    }
  }
}
