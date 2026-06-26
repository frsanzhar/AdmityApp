import 'dart:convert';
import 'dart:io';

import 'package:admity/features/universities/domain/university_catalog.dart';
import 'package:flutter_test/flutter_test.dart';

/// Validates the data contract of the bundled catalog asset directly from disk
/// (no rootBundle needed). Guards the honesty rules from
/// docs/UNIVERSITIES_DATA.md.
void main() {
  group('universities.json contract', () {
    late Map<String, dynamic> data;

    setUpAll(() {
      final file = File('assets/data/universities.json');
      expect(file.existsSync(), isTrue, reason: 'asset must exist');
      data = json.decode(file.readAsStringSync()) as Map<String, dynamic>;
    });

    test('has all top-level sections', () {
      expect(data['meta'], isA<Map<String, dynamic>>());
      for (final key in const [
        'universities',
        'education_programs',
        'university_programs',
        'grant_thresholds',
      ]) {
        expect(data[key], isA<List<dynamic>>(), reason: '$key must be a list');
      }
    });

    test('universities parse and have valid required fields', () {
      final list = (data['universities'] as List<dynamic>)
          .cast<Map<String, dynamic>>()
          .map(UniversityRecord.fromJson)
          .toList();
      expect(list, isNotEmpty);
      final ids = <String>{};
      for (final u in list) {
        expect(u.id, isNotEmpty);
        expect(ids.add(u.id), isTrue, reason: 'duplicate id ${u.id}');
        expect(u.nameRu, isNotEmpty);
        expect(u.city, isNotEmpty);
      }
    });

    test('HONESTY: every grant threshold carries a non-empty source_url', () {
      final raw = (data['grant_thresholds'] as List<dynamic>)
          .cast<Map<String, dynamic>>();
      for (final t in raw) {
        final source = (t['source_url'] as String?) ?? '';
        expect(
          source.trim(),
          isNotEmpty,
          reason: 'threshold ${t['program_code']} has no source_url — '
              'a cutoff may never be shown without a citation',
        );
        // Parses without throwing.
        GrantThreshold.fromJson(t);
      }
    });

    test('offerings reference known universities & programs', () {
      final uniIds = (data['universities'] as List<dynamic>)
          .cast<Map<String, dynamic>>()
          .map((u) => u['id'] as String)
          .toSet();
      final programCodes = (data['education_programs'] as List<dynamic>)
          .cast<Map<String, dynamic>>()
          .map((p) => p['code'] as String)
          .toSet();
      for (final o in (data['university_programs'] as List<dynamic>)
          .cast<Map<String, dynamic>>()) {
        expect(uniIds, contains(o['university_id']));
        expect(programCodes, contains(o['program_code']));
      }
    });
  });
}
