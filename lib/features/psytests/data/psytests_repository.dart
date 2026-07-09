/// Local-first storage for psychological test results.
///
/// Mirrors the architecture of `HiveProfileRepository`: abstract interface +
/// Hive production impl + InMemory test impl.  No TypeAdapters — plain JSON.
library;

import 'dart:convert';

import 'package:admity/features/psytests/domain/psytest_models.dart';
import 'package:hive_flutter/hive_flutter.dart';

// ── Abstract interface ─────────────────────────────────────────────────────────

/// Storage contract for psych-test results.
abstract class PsytestsRepository {
  Future<List<PsyTestResult>> loadResults();
  Future<void> saveResult(PsyTestResult result);
  Future<void> clearResult(String testId);
}

// ── Hive implementation (production) ──────────────────────────────────────────

/// Hive-backed [PsytestsRepository].
///
/// Stores all results as a JSON array under a single key in one raw
/// `Box<String>`.  No TypeAdapters needed.
class HivePsytestsRepository implements PsytestsRepository {
  const HivePsytestsRepository();

  static const _boxName = 'admity_psytests';
  static const _resultsKey = '__results__';

  /// Opens the Hive box.  Call once at app startup (e.g. inside bootstrap).
  static Future<void> init() async {
    await Hive.openBox<String>(_boxName);
  }

  Box<String> get _box => Hive.box<String>(_boxName);

  @override
  Future<List<PsyTestResult>> loadResults() async {
    final raw = _box.get(_resultsKey);
    if (raw == null) return [];
    final list = jsonDecode(raw) as List<dynamic>;
    return list
        .map((e) => PsyTestResult.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  @override
  Future<void> saveResult(PsyTestResult result) async {
    final existing = await loadResults();
    final updated = [
      ...existing.where((r) => r.testId != result.testId),
      result,
    ];
    await _box.put(
      _resultsKey,
      jsonEncode(updated.map((r) => r.toJson()).toList()),
    );
  }

  @override
  Future<void> clearResult(String testId) async {
    final existing = await loadResults();
    final updated =
        existing.where((r) => r.testId != testId).toList();
    await _box.put(
      _resultsKey,
      jsonEncode(updated.map((r) => r.toJson()).toList()),
    );
  }
}

// ── In-memory implementation (tests) ──────────────────────────────────────────

/// Non-persistent [PsytestsRepository] for unit and widget tests.
class InMemoryPsytestsRepository implements PsytestsRepository {
  final List<PsyTestResult> _results = [];

  @override
  Future<List<PsyTestResult>> loadResults() async =>
      List.unmodifiable(_results);

  @override
  Future<void> saveResult(PsyTestResult result) async {
    _results.removeWhere((r) => r.testId == result.testId);
    _results.add(result);
  }

  @override
  Future<void> clearResult(String testId) async {
    _results.removeWhere((r) => r.testId == testId);
  }
}
