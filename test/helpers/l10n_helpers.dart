/// Shared test helpers for pumping widgets that use `context.l10n`.
///
/// Tests assert RUSSIAN strings, so every wrapper pins `locale: ru` — the
/// device locale of the test runner must not affect expectations.
library;

import 'package:admity/core/l10n/l10n.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

/// Localization setup shared by all test MaterialApps.
const testLocale = Locale('ru');

/// Delegates required by any widget tree that reads `context.l10n`.
const testLocalizationDelegates = <LocalizationsDelegate<dynamic>>[
  AppLocalizations.delegate,
  GlobalMaterialLocalizations.delegate,
  GlobalWidgetsLocalizations.delegate,
  GlobalCupertinoLocalizations.delegate,
];

/// Wraps [child] in a localized [MaterialApp] (Russian) with [theme].
Widget localizedApp({required Widget child, ThemeData? theme}) {
  return MaterialApp(
    theme: theme,
    locale: testLocale,
    supportedLocales: supportedAppLocales,
    localizationsDelegates: testLocalizationDelegates,
    home: child,
  );
}

/// Wraps a [routerConfig] in a localized [MaterialApp.router] (Russian).
Widget localizedRouterApp({
  required RouterConfig<Object> routerConfig,
  ThemeData? theme,
}) {
  return MaterialApp.router(
    theme: theme,
    locale: testLocale,
    supportedLocales: supportedAppLocales,
    localizationsDelegates: testLocalizationDelegates,
    routerConfig: routerConfig,
  );
}
