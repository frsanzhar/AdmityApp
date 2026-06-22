import 'package:rive/rive.dart';

/// Lightweight helper for loading Rive files from the asset bundle.
///
/// Returns `null` if the asset is not found (e.g. the .riv file has not yet
/// been delivered by the designer) or if the Rive native renderer is not
/// available (e.g. during flutter test on host).
/// Callers must treat `null` as "render static fallback".
///
/// Uses [Factory.flutter] for compatibility with all platforms without
/// requiring native renderer setup.
Future<File?> loadRiveAsset(String assetPath) async {
  try {
    return await File.asset(assetPath, riveFactory: Factory.flutter);
    // ignore: avoid_catches_without_on_clauses // Must catch Error (ArgumentError from FFI) + Exception.
  } catch (_) {
    // Covers:
    //   - Asset not bundled yet (designer hasn't delivered the .riv file).
    //   - Native renderer symbol not found (flutter test host environment).
    //   - Any other Rive initialisation failure.
    return null;
  }
}
