/// Riverpod state management for the psychology tests roadmap.
///
/// Plain hand-written providers — no `@riverpod` codegen (CLAUDE.md §1).
library;

import 'dart:async';

import 'package:admity/features/psytests/data/psytests_repository.dart';
import 'package:admity/features/psytests/domain/psytest_engine.dart';
import 'package:admity/features/psytests/domain/psytest_models.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// ── Repository provider ────────────────────────────────────────────────────────

/// The [PsytestsRepository] used throughout the feature.
///
/// Override in tests with [InMemoryPsytestsRepository].
final psytestsRepositoryProvider = Provider<PsytestsRepository>(
  (_) => const HivePsytestsRepository(),
);

// ── State ──────────────────────────────────────────────────────────────────────

/// Immutable snapshot of all psych-test results.
class PsytestsState {
  const PsytestsState({
    this.isLoading = false,
    this.results = const [],
  });

  final bool isLoading;

  /// All persisted results (one per completed test at most).
  final List<PsyTestResult> results;

  PsytestsState copyWith({
    bool? isLoading,
    List<PsyTestResult>? results,
  }) =>
      PsytestsState(
        isLoading: isLoading ?? this.isLoading,
        results: results ?? this.results,
      );
}

// ── Notifier ───────────────────────────────────────────────────────────────────

/// Manages loading, updating, and clearing psych-test results.
class PsytestsNotifier extends Notifier<PsytestsState> {
  @override
  PsytestsState build() {
    unawaited(_load());
    return const PsytestsState(isLoading: true);
  }

  PsytestsRepository get _repo =>
      ref.read(psytestsRepositoryProvider);

  Future<void> _load() async {
    final results = await _repo.loadResults();
    state = state.copyWith(isLoading: false, results: results);
  }

  /// Persists [result] and updates state.
  ///
  /// If a result for the same test already exists it is replaced.
  Future<void> submitResult(PsyTestResult result) async {
    await _repo.saveResult(result);
    final updated = [
      ...state.results.where((r) => r.testId != result.testId),
      result,
    ];
    state = state.copyWith(results: updated);
  }

  /// Removes a previously stored result for [testId].
  Future<void> clearResult(String testId) async {
    await _repo.clearResult(testId);
    state = state.copyWith(
      results: state.results
          .where((r) => r.testId != testId)
          .toList(),
    );
  }
}

// ── Providers ──────────────────────────────────────────────────────────────────

/// Main provider for psych-test state.
final psytestsProvider =
    NotifierProvider<PsytestsNotifier, PsytestsState>(
  PsytestsNotifier.new,
);

/// Aggregated plain-text personality summary for use by Eraly.
///
/// Returns an empty string until at least one test is completed.
/// Automatically updates when new results are submitted.
final psytestsSummaryProvider = Provider<String>((ref) {
  final state = ref.watch(psytestsProvider);
  if (state.isLoading) return '';
  return buildPsytestsSummary(state.results);
});
