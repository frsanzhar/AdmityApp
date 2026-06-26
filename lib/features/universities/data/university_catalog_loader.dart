// Offline-first loader for the universities catalog.
//
// Source of truth at runtime is the bundled JSON asset
// (assets/data/universities.json), generated from Supabase by
// tools/scrape_universities (see docs/UNIVERSITIES_DATA.md). When Supabase is
// wired, a sync layer can refresh the asset; the loader stays the same.

import 'dart:convert';

import 'package:admity/features/universities/domain/university_catalog.dart';
import 'package:flutter/services.dart' show rootBundle;

/// Loads and parses the bundled universities catalog JSON asset.
class UniversityCatalogLoader {
  /// Creates a loader for the given [assetPath].
  const UniversityCatalogLoader({
    this.assetPath = 'assets/data/universities.json',
  });

  /// Path to the JSON asset bundled with the app.
  final String assetPath;

  /// Reads the asset and decodes it into a [UniversityCatalog].
  ///
  /// Degrades gracefully: any read/parse failure returns
  /// [UniversityCatalog.empty] rather than throwing, keeping the app usable
  /// offline even if the asset is missing or malformed.
  Future<UniversityCatalog> load() async {
    try {
      final raw = await rootBundle.loadString(assetPath);
      final decoded = json.decode(raw) as Map<String, dynamic>;
      return _parse(decoded);
    } on Object {
      return UniversityCatalog.empty;
    }
  }

  UniversityCatalog _parse(Map<String, dynamic> json) {
    List<T> mapList<T>(
      String key,
      T Function(Map<String, dynamic>) fromJson,
    ) {
      final list = json[key] as List<dynamic>? ?? const <dynamic>[];
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
}
