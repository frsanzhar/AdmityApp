// Offline-first loader for the universities catalog.
//
// Primary source of truth: assets/data/universities.json (generated from
// Supabase — see docs/UNIVERSITIES_DATA.md).
//
// Secondary merge: assets/data/university_images.json — a map of university
// id → Wikimedia Commons image URL. Kept separate so it can be updated
// without touching the main catalog asset.

import 'dart:convert';

import 'package:admity/features/universities/domain/university_catalog.dart';
import 'package:flutter/services.dart' show rootBundle;

/// Loads and parses the bundled universities catalog JSON asset, then merges
/// the optional image-URL sidecar.
class UniversityCatalogLoader {
  /// Creates a loader for the given asset paths.
  const UniversityCatalogLoader({
    this.assetPath = 'assets/data/universities.json',
    this.imagesAssetPath = 'assets/data/university_images.json',
    this.dormImagesAssetPath = 'assets/data/university_dorm_images.json',
  });

  /// Path to the main catalog JSON asset.
  final String assetPath;

  /// Path to the image-URL sidecar JSON asset (map of id → url).
  final String imagesAssetPath;

  /// Path to the dorm-photo sidecar JSON asset (map of id → url).
  final String dormImagesAssetPath;

  /// Reads both assets and returns a fully merged [UniversityCatalog].
  ///
  /// Any read/parse failure degrades gracefully to [UniversityCatalog.empty]
  /// so the app stays usable offline.
  Future<UniversityCatalog> load() async {
    try {
      final raw = await rootBundle.loadString(assetPath);
      final decoded = json.decode(raw) as Map<String, dynamic>;
      var catalog = _parse(decoded);

      // Merge image URLs from the sidecar (best-effort; failures are silently
      // swallowed so a bad sidecar never breaks the catalog).
      try {
        final imgRaw = await rootBundle.loadString(imagesAssetPath);
        final imgMap =
            json.decode(imgRaw) as Map<String, dynamic>;
        catalog = _mergeImages(catalog, imgMap);
      } on Object {
        // Image sidecar missing or malformed — continue without photos.
      }

      // Merge dormitory photos the same best-effort way.
      try {
        final dormRaw = await rootBundle.loadString(dormImagesAssetPath);
        final dormMap = json.decode(dormRaw) as Map<String, dynamic>;
        catalog = _mergeDormImages(catalog, dormMap);
      } on Object {
        // Dorm sidecar missing or malformed — continue without dorm photos.
      }

      return catalog;
    } on Object {
      return UniversityCatalog.empty;
    }
  }

  UniversityCatalog _parse(Map<String, dynamic> parsed) {
    List<T> mapList<T>(
      String key,
      T Function(Map<String, dynamic>) fromJson,
    ) {
      final list = parsed[key] as List<dynamic>? ?? const <dynamic>[];
      return list
          .whereType<Map<String, dynamic>>()
          .map(fromJson)
          .toList(growable: false);
    }

    return UniversityCatalog(
      universities: mapList('universities', UniversityRecord.fromJson),
      programs: mapList('education_programs', EducationProgram.fromJson),
      offerings: mapList('university_programs', UniversityProgram.fromJson),
      thresholds: mapList('grant_thresholds', GrantThreshold.fromJson),
    );
  }

  /// Returns a new [UniversityCatalog] with [UniversityRecord.imageUrl] set
  /// from [imgMap] (id → url string).
  UniversityCatalog _mergeImages(
    UniversityCatalog catalog,
    Map<String, dynamic> imgMap,
  ) {
    final updated = catalog.universities.map((u) {
      final url = imgMap[u.id];
      if (url is String && url.trim().isNotEmpty) {
        return u.withImageUrl(url.trim());
      }
      return u;
    }).toList(growable: false);

    return UniversityCatalog(
      universities: updated,
      programs: catalog.programs,
      offerings: catalog.offerings,
      thresholds: catalog.thresholds,
    );
  }

  /// Returns a new [UniversityCatalog] with [UniversityRecord.dormImageUrl]
  /// set from [dormMap] (id → url string).
  UniversityCatalog _mergeDormImages(
    UniversityCatalog catalog,
    Map<String, dynamic> dormMap,
  ) {
    final updated = catalog.universities.map((u) {
      final url = dormMap[u.id];
      if (url is String && url.trim().isNotEmpty) {
        return u.withDormImageUrl(url.trim());
      }
      return u;
    }).toList(growable: false);

    return UniversityCatalog(
      universities: updated,
      programs: catalog.programs,
      offerings: catalog.offerings,
      thresholds: catalog.thresholds,
    );
  }
}
