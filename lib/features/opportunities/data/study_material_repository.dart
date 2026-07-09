/// Repository for reading study materials from the Supabase study_materials table.
library;

import 'package:admity/core/config/app_config.dart';
import 'package:admity/features/opportunities/domain/study_material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

/// Reads [StudyMaterial] rows from the `study_materials` Supabase table.
///
/// Returns an empty list when Supabase is not configured (i.e. when
/// `AppConfig.hasSupabase` is false), so the app degrades gracefully in
/// offline / guest mode without errors.
class StudyMaterialRepository {
  /// Creates a [StudyMaterialRepository].
  const StudyMaterialRepository();

  /// Fetches all rows ordered by `created_at` descending (newest first).
  Future<List<StudyMaterial>> fetchAll() async {
    if (!AppConfig.hasSupabase) return const [];
    try {
      final rows = await Supabase.instance.client
          .from('study_materials')
          .select()
          .order('created_at', ascending: false);
      return (rows as List<dynamic>)
          .cast<Map<String, dynamic>>()
          .map(StudyMaterial.fromJson)
          .toList();
    } on Object {
      return const [];
    }
  }
}
