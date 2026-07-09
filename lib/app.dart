import 'package:admity/core/l10n/l10n.dart';
import 'package:admity/core/router/app_router.dart';
import 'package:admity/core/theme/app_tokens.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

/// Holds the app's [GoRouter]. Kept in a provider so features can navigate or
/// override it in tests/bootstrap.
final routerProvider = Provider<GoRouter>((ref) => createRouter());

class AdmityApp extends ConsumerWidget {
  const AdmityApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(routerProvider);
    // null → follow the device (Apple ID) language; falls back to Russian
    // when the device language is not among the supported locales.
    final locale = ref.watch(appLocaleProvider);
    return MaterialApp.router(
      title: 'Admity',
      debugShowCheckedModeBanner: false,
      theme: buildAppTheme(),
      routerConfig: router,
      locale: locale,
      supportedLocales: supportedAppLocales,
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
    );
  }
}
