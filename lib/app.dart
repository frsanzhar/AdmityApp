import 'package:admity/core/l10n/locale_controller.dart';
import 'package:admity/core/router/app_router.dart';
import 'package:admity/core/theme/app_theme.dart';
import 'package:admity/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Root application widget.
///
/// A pure function of Riverpod state: the router, theme and locale all come
/// from providers, so there is no mutable widget state here.
class AdmityApp extends ConsumerWidget {
  /// Creates the root app widget.
  const AdmityApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(appRouterProvider);
    final locale = ref.watch(localeControllerProvider);

    return MaterialApp.router(
      onGenerateTitle: (context) => AppLocalizations.of(context).appTitle,
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      darkTheme: AppTheme.dark,
      // themeMode defaults to ThemeMode.system. A user-controlled override
      // (dark-first) is wired through a provider in Step 2.
      locale: locale,
      supportedLocales: AppLocalizations.supportedLocales,
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      routerConfig: router,
    );
  }
}
