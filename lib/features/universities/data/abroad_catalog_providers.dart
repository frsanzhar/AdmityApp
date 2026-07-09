// Riverpod providers for the foreign-universities (abroad) catalog.
//
// Hand-written providers — no codegen per CLAUDE.md §Toolchain.
// Loaded once from the bundled JSON asset; degrades to an empty list on any
// error so the app remains usable even if the asset is missing.

import 'dart:convert';

import 'package:admity/features/universities/domain/abroad_university.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Path to the bundled abroad-universities JSON asset.
const _kAbroadAsset = 'assets/data/universities_abroad.json';

/// Path to the image sidecar: id → {campus: url, dorm: url}.
const _kAbroadImagesAsset = 'assets/data/abroad_university_images.json';

/// Loads the abroad catalog from [_kAbroadAsset].
///
/// Returns an empty list (never throws) on any read or parse failure so the
/// screen shows an empty state rather than crashing.
Future<List<AbroadUniversity>> _loadAbroadCatalog() async {
  try {
    final raw = await rootBundle.loadString(_kAbroadAsset);
    final decoded = json.decode(raw) as Map<String, dynamic>;
    final list = decoded['universities'] as List<dynamic>? ?? const <dynamic>[];
    var unis = list
        .whereType<Map<String, dynamic>>()
        .map(AbroadUniversity.fromJson)
        .toList(growable: false);

    // Merge campus/dorm photo URLs from the sidecar (best-effort: a missing
    // or malformed sidecar never breaks the catalog).
    try {
      final imgRaw = await rootBundle.loadString(_kAbroadImagesAsset);
      final imgMap = json.decode(imgRaw) as Map<String, dynamic>;
      unis = unis.map((u) {
        final rec = imgMap[u.id];
        if (rec is Map<String, dynamic>) {
          final campus = rec['campus'];
          final dorm = rec['dorm'];
          return u.withImages(
            campus: campus is String && campus.trim().isNotEmpty
                ? campus.trim()
                : null,
            dorm: dorm is String && dorm.trim().isNotEmpty ? dorm.trim() : null,
          );
        }
        return u;
      }).toList(growable: false);
    } on Object {
      // Sidecar missing — continue without photos.
    }

    return unis;
  } on Object {
    return const <AbroadUniversity>[];
  }
}

/// Async provider that resolves to the full list of foreign universities.
///
/// Loaded once; any error yields an empty list via graceful fallback.
final abroadUniversitiesProvider =
    FutureProvider<List<AbroadUniversity>>((ref) => _loadAbroadCatalog());
