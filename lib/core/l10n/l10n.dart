/// App localization plumbing (RU / KK / EN).
///
/// - `context.l10n` — the [AppLocalizations] for the current build context.
/// - [appLocaleProvider] — the locale override chosen by the student, or null
///   to follow the system (Apple ID / device) language.
/// - [appLocalizationsProvider] — [AppLocalizations] resolved OUTSIDE the
///   widget tree (for notifiers/services without a BuildContext).
library;

import 'dart:ui';

import 'package:admity/features/profile/application/profile_notifier.dart';
import 'package:admity/l10n/gen/app_localizations.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

export 'package:admity/l10n/gen/app_localizations.dart';

/// Locales the app ships with. Order matters: the first entry (Russian) is
/// the fallback when the system language is unsupported.
const supportedAppLocales = [Locale('ru'), Locale('kk'), Locale('en')];

/// Convenient `context.l10n` accessor.
extension L10nX on BuildContext {
  /// The localizations bundle for this context.
  AppLocalizations get l10n => AppLocalizations.of(this);
}

/// The student's explicit language choice ('ru' | 'kk' | 'en'), or null when
/// following the system language ("system" / unset).
final appLocaleProvider = Provider<Locale?>((ref) {
  final lang = ref.watch(
    profileProvider.select((s) => s.profile.appLanguage),
  );
  return switch (lang) {
    'ru' => const Locale('ru'),
    'kk' => const Locale('kk'),
    'en' => const Locale('en'),
    _ => null, // 'system' / null → follow the device (Apple ID) language.
  };
});

/// [AppLocalizations] usable without a BuildContext (notifiers, services).
///
/// Resolution: explicit choice → device language → Russian fallback.
final appLocalizationsProvider = Provider<AppLocalizations>((ref) {
  final chosen = ref.watch(appLocaleProvider);
  final locale = chosen ?? _matchDeviceLocale();
  return lookupAppLocalizations(locale);
});

Locale _matchDeviceLocale() {
  final device = PlatformDispatcher.instance.locale;
  for (final l in supportedAppLocales) {
    if (l.languageCode == device.languageCode) return l;
  }
  return supportedAppLocales.first;
}
