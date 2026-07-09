import 'dart:convert';

import 'package:admity/features/mentor/domain/shared_memory.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';

/// Manages the [SharedMemory] that is injected into every assistant request.
///
/// Summaries are persisted in a dedicated Hive box so they survive app
/// restarts.  The box is opened lazily — if Hive is not yet initialised
/// (e.g. in widget tests) the notifier starts with empty summaries and
/// silently skips persistence; the rest of the app degrades gracefully.
class SharedMemoryNotifier extends Notifier<SharedMemory> {
  static const _boxName = 'mentor_shared';
  static const _key = '__shared__';

  @override
  SharedMemory build() {
    // Load stored summaries asynchronously — initial state is empty.
    // ignore: discarded_futures
    Future.microtask(_load);
    return const SharedMemory();
  }

  Future<void> _load() async {
    try {
      if (!Hive.isBoxOpen(_boxName)) {
        await Hive.openBox<String>(_boxName);
      }
      final box = Hive.box<String>(_boxName);
      final raw = box.get(_key);
      if (raw == null || !ref.mounted) return;
      final map = jsonDecode(raw) as Map<String, dynamic>;
      state = SharedMemory(
        summaries: map.map((k, v) => MapEntry(k, v as String)),
      );
    } on Object catch (e) {
      debugPrint('[SharedMemory] load failed: $e');
    }
  }

  /// Updates the stored summary for [role] and persists it to Hive.
  ///
  /// Called after every assistant reply so other assistants can read it.
  Future<void> updateSummary(String role, String summary) async {
    state = state.withSummary(role, summary);
    await _persist();
  }

  Future<void> _persist() async {
    try {
      if (!Hive.isBoxOpen(_boxName)) {
        await Hive.openBox<String>(_boxName);
      }
      await Hive.box<String>(_boxName).put(_key, jsonEncode(state.summaries));
    } on Object catch (e) {
      debugPrint('[SharedMemory] persist failed: $e');
    }
  }
}

/// Riverpod provider for the shared cross-assistant memory context.
final sharedMemoryProvider =
    NotifierProvider<SharedMemoryNotifier, SharedMemory>(
  SharedMemoryNotifier.new,
);
