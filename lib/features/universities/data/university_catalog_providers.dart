// Riverpod providers exposing the universities catalog to the UI.
//
// Hand-written providers (no codegen) per the project's toolchain note.

import 'package:admity/features/universities/data/university_catalog_loader.dart';
import 'package:admity/features/universities/domain/university_catalog.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// The catalog loader (overridable in tests with a fake asset path).
final universityCatalogLoaderProvider = Provider<UniversityCatalogLoader>(
  (ref) => const UniversityCatalogLoader(),
);

/// Async catalog, loaded once from the bundled JSON asset.
final universityCatalogProvider = FutureProvider<UniversityCatalog>((ref) {
  return ref.watch(universityCatalogLoaderProvider).load();
});

// ── Score presets ─────────────────────────────────────────────────────────────

/// Score presets for the "Балл до N" competition-score filter.
///
/// These are the accepted preset values shown in the picker sheet.
const List<int> catalogScorePresets = [80, 90, 100, 110, 120, 130];

// ── CatalogFilter ─────────────────────────────────────────────────────────────

/// Combined filter applied to the catalog list.
@immutable
class CatalogFilter {
  /// Creates a [CatalogFilter].
  const CatalogFilter({
    this.city,
    this.type,
    this.major,
    this.hasDormitory,
    this.maxScore,
  });

  /// Selected city, or null for all.
  final String? city;

  /// Selected university type, or null for all.
  final UniversityType? type;

  /// Selected major category, or null for all.
  final MajorCategory? major;

  /// When true, only universities with confirmed dormitories are shown.
  /// Null means no filter.
  final bool? hasDormitory;

  /// Maximum competition-entry minimum score; universities with a lower or equal
  /// score pass. Null means no limit.
  final int? maxScore;

  /// True when nothing is filtered.
  bool get isEmpty =>
      city == null &&
      type == null &&
      major == null &&
      hasDormitory == null &&
      maxScore == null;

  /// Returns a copy with the given overrides.
  ///
  /// Pass a `clear*` flag to explicitly unset a field.
  CatalogFilter copyWith({
    String? city,
    UniversityType? type,
    MajorCategory? major,
    bool? hasDormitory,
    int? maxScore,
    bool clearCity = false,
    bool clearType = false,
    bool clearMajor = false,
    bool clearDormitory = false,
    bool clearMaxScore = false,
  }) {
    return CatalogFilter(
      city: clearCity ? null : (city ?? this.city),
      type: clearType ? null : (type ?? this.type),
      major: clearMajor ? null : (major ?? this.major),
      hasDormitory:
          clearDormitory ? null : (hasDormitory ?? this.hasDormitory),
      maxScore: clearMaxScore ? null : (maxScore ?? this.maxScore),
    );
  }
}

// ── CatalogFilterNotifier ────────────────────────────────────────────────────

/// Holds the current [CatalogFilter].
class CatalogFilterNotifier extends Notifier<CatalogFilter> {
  @override
  CatalogFilter build() => const CatalogFilter();

  /// Sets (or clears, when null) the city filter.
  void setCity(String? city) =>
      state = state.copyWith(city: city, clearCity: city == null);

  /// Sets (or clears, when null) the type filter.
  void setType(UniversityType? type) =>
      state = state.copyWith(type: type, clearType: type == null);

  /// Sets (or clears, when null) the major category filter.
  void setMajor(MajorCategory? major) =>
      state = state.copyWith(major: major, clearMajor: major == null);

  /// Toggles the dormitory filter (null → true → null).
  void toggleDormitory() {
    final current = state.hasDormitory;
    state = state.copyWith(
      hasDormitory: current == null ? true : null,
      clearDormitory: current != null,
    );
  }

  /// Sets (or clears, when null) the max competition-score filter.
  void setMaxScore(int? score) =>
      state = state.copyWith(maxScore: score, clearMaxScore: score == null);

  /// Clears all filters.
  void clearAll() => state = const CatalogFilter();
}

/// The catalog filter notifier provider.
final catalogFilterProvider =
    NotifierProvider<CatalogFilterNotifier, CatalogFilter>(
      CatalogFilterNotifier.new,
    );

// ── applyCatalogFilter ────────────────────────────────────────────────────────

/// Applies [filter] to the catalog's universities list.
///
/// Needs the full [catalog] (not just the universities list) so it can look up
/// programs and competition scores for the major and score filters.
List<UniversityRecord> applyCatalogFilter(
  UniversityCatalog catalog,
  CatalogFilter filter,
) {
  return catalog.universities.where((u) {
    // City
    if (filter.city != null && u.city != filter.city) return false;
    // Type
    if (filter.type != null && u.type != filter.type) return false;
    // Dormitory
    if (filter.hasDormitory == true && u.hasDormitory != true) return false;
    // Max competition score
    if (filter.maxScore != null) {
      final score = catalog.minCompetitionScoreFor(u.id);
      // If the university has no score data, let it through (no info ≠ fail).
      if (score != null && score > filter.maxScore!) return false;
    }
    // Major category
    if (filter.major != null) {
      final cats = catalog.universityCategoriesFor(u.id);
      if (!cats.contains(filter.major)) return false;
    }
    return true;
  }).toList();
}
