import 'package:rive/rive.dart';

/// Master switch for the Rive runtime.
///
/// Kept `false` until BOTH are true: the designer has delivered `.riv` assets
/// into `assets/rive/`, AND `dart run rive_native:setup --platform <os>` has
/// been run for the target. While false, every slot renders its (now
/// flutter_animate-animated) static fallback and the rive_native FFI library is
/// never touched — this avoids the "Rive Native: Failed to open dynamic
/// library" failure on the flutter-test host and any device without the lib.
const bool kRiveEnabled = false;

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
  // Rive disabled until assets + native lib are wired — never touch FFI.
  if (!kRiveEnabled) return null;
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
