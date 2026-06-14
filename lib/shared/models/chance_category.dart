/// Honest chancing categories. Admity never shows a fabricated percentage —
/// only a category plus the ranges/thresholds it is derived from.
library;

/// Kazakhstan (ЕНТ-grant) outcome category.
enum KzChance {
  /// Below the relevant gov / university threshold.
  belowThreshold,

  /// Above the threshold but near or below recent real cut-offs.
  atRisk,

  /// Comfortably above recent real cut-offs.
  safe,
}

/// World (Common Data Set) outcome category.
enum WorldChance {
  /// Below the typical admitted profile — a stretch.
  reach,

  /// Squarely within the typical admitted profile.
  target,

  /// At or above the typical admitted profile.
  likely,
}

/// Where a student's test score sits inside a 25–75 percentile band.
enum BandPosition {
  /// Below the 25th percentile.
  below,

  /// Lower part of the 25–75 band.
  lower,

  /// Around the median.
  middle,

  /// Upper part of the 25–75 band.
  upper,

  /// At or above the 75th percentile.
  above,
}
