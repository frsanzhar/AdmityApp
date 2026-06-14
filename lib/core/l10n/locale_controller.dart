import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Holds the app's selected [Locale].
///
/// `null` means "follow the device locale". The user can override it (KZ / RU /
/// EN); Eraly still replies in the language of each message regardless of this.
class LocaleController extends Notifier<Locale?> {
  @override
  Locale? build() => null;

  /// Sets an explicit app locale, or `null` to follow the device.
  void setLocale(Locale? locale) => state = locale;
}

/// Provider for the current app locale override.
final localeControllerProvider =
    NotifierProvider<LocaleController, Locale?>(LocaleController.new);
