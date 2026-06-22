import 'package:admity/core/router/app_router.dart';
import 'package:admity/core/theme/app_tokens.dart';
import 'package:flutter/material.dart';
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
    return MaterialApp.router(
      title: 'Admity',
      debugShowCheckedModeBanner: false,
      theme: buildAppTheme(),
      routerConfig: router,
    );
  }
}
