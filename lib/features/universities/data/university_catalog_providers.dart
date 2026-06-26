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

/// City + type filter applied to the catalog list.
@immutable
class CatalogFilter {
  /// Creates a [CatalogFilter].
  const CatalogFilter({this.city, this.type});

  /// Selected city, or null for all.
  final String? city;

  /// Selected university type, or null for all.
  final UniversityType? type;

  /// True when nothing is filtered.
  bool get isEmpty => city == null && type == null;

  /// Returns a copy with the given overrides (pass clear flags to unset).
  CatalogFilter copyWith({
    String? city,
    UniversityType? type,
    bool clearCity = false,
    bool clearType = false,
  }) {
    return CatalogFilter(
      city: clearCity ? null : (city ?? this.city),
      type: clearType ? null : (type ?? this.type),
    );
  }
}

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

  /// Clears all filters.
  void clearAll() => state = const CatalogFilter();
}

/// The catalog filter notifier provider.
final catalogFilterProvider =
    NotifierProvider<CatalogFilterNotifier, CatalogFilter>(
      CatalogFilterNotifier.new,
    );

/// Applies [filter] to [universities].
List<UniversityRecord> applyCatalogFilter(
  List<UniversityRecord> universities,
  CatalogFilter filter,
) {
  return universities.where((u) {
    if (filter.city != null && u.city != filter.city) return false;
    if (filter.type != null && u.type != filter.type) return false;
    return true;
  }).toList();
}
