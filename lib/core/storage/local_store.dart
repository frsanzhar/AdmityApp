import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:admity/core/utils/app_logger.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

const _logger = AppLogger('LocalStore');

/// A tiny JSON-file key/value store for offline-light persistence of the
/// student's own data (profile, notes, scores, progress). Reads are
/// synchronous (in-memory); writes are debounced fire-and-forget to disk.
///
/// When Supabase is connected, repositories write-through to Postgres as the
/// source of truth; this remains the offline cache.
class LocalStore {
  LocalStore._(this._file, this._data);

  /// In-memory only (used in tests / when no filesystem is available).
  factory LocalStore.inMemory() => LocalStore._(null, {});

  /// Loads (or creates) the on-disk store. Never throws — falls back to memory.
  static Future<LocalStore> load() async {
    try {
      final dir = await getApplicationDocumentsDirectory();
      final file = File(p.join(dir.path, 'admity_store.json'));
      if (file.existsSync()) {
        final decoded = jsonDecode(await file.readAsString());
        if (decoded is Map<String, dynamic>) {
          return LocalStore._(file, decoded);
        }
      }
      return LocalStore._(file, {});
    } on Object catch (e) {
      _logger.warn('Falling back to in-memory store: $e');
      return LocalStore.inMemory();
    }
  }

  final File? _file;
  final Map<String, dynamic> _data;

  Map<String, dynamic>? readJson(String key) =>
      _data[key] as Map<String, dynamic>?;

  List<dynamic>? readList(String key) => _data[key] as List<dynamic>?;

  void put(String key, Object? value) {
    _data[key] = value;
    _persist();
  }

  void remove(String key) {
    _data.remove(key);
    _persist();
  }

  void _persist() {
    final file = _file;
    if (file == null) return;
    unawaited(
      file.writeAsString(jsonEncode(_data)).catchError((Object e) {
        _logger.warn('Persist failed: $e');
        return file;
      }),
    );
  }
}

/// Provides the loaded [LocalStore]. Overridden in `bootstrap` with the real
/// instance; defaults to in-memory so tests work without an override.
final localStoreProvider = Provider<LocalStore>((ref) => LocalStore.inMemory());
