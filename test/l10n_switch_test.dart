/// Widget tests for the language-switching chain.
///
/// Verifies:
///   1. [appLocaleProvider] returns null for a fresh profile (appLanguage ==
///      'system') and the correct [Locale] after saveProfile().
///   2. [MaterialApp] rebuilds with the new locale when [appLocaleProvider]
///      changes — Localizations.localeOf() in descendant reflects the switch.
///   3. [AppBottomNav] shows localised labels after the locale changes.
///
/// All tests use [InMemoryProfileRepository] — no Hive, no platform channels.
library;

import 'package:admity/core/l10n/l10n.dart';
import 'package:admity/features/profile/application/profile_notifier.dart';
import 'package:admity/features/profile/data/profile_repository.dart';
import 'package:admity/features/profile/domain/profile_model.dart';
import 'package:admity/shared/widgets/app_bottom_nav.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

// ── Minimal localization helpers ──────────────────────────────────────────────

const _allDelegates = <LocalizationsDelegate<dynamic>>[
  AppLocalizations.delegate,
  GlobalMaterialLocalizations.delegate,
  GlobalWidgetsLocalizations.delegate,
  GlobalCupertinoLocalizations.delegate,
];

// ── Test widgets ──────────────────────────────────────────────────────────────

/// Minimal app that wires [appLocaleProvider] into [MaterialApp.locale]
/// exactly as AdmityApp does — without pulling in the full router.
class _TestApp extends ConsumerWidget {
  const _TestApp({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final locale = ref.watch(appLocaleProvider);
    return MaterialApp(
      locale: locale,
      supportedLocales: supportedAppLocales,
      localizationsDelegates: _allDelegates,
      home: child,
    );
  }
}

/// Leaf that renders `Localizations.localeOf(context).languageCode` as text
/// so tests can assert the effective locale without importing internals.
class _LocaleDisplay extends StatelessWidget {
  const _LocaleDisplay();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Text(Localizations.localeOf(context).languageCode),
      ),
    );
  }
}

// ── Test app builder ──────────────────────────────────────────────────────────

Widget _buildApp({InMemoryProfileRepository? repo}) {
  return ProviderScope(
    overrides: [
      profileRepositoryProvider
          .overrideWithValue(repo ?? InMemoryProfileRepository()),
    ],
    child: const _TestApp(child: _LocaleDisplay()),
  );
}

// ── Helper: grab the ProviderContainer from the pumped tree ──────────────────

ProviderContainer _containerOf(WidgetTester tester) =>
    ProviderScope.containerOf(tester.element(find.byType(_TestApp)));

// ── Tests ─────────────────────────────────────────────────────────────────────

void main() {
  // ── 1. Provider-level unit tests (no widget pump) ─────────────────────────

  group('appLocaleProvider', () {
    ProviderContainer makeContainer() {
      final container = ProviderContainer(
        overrides: [
          profileRepositoryProvider
              .overrideWithValue(InMemoryProfileRepository()),
        ],
      );
      addTearDown(container.dispose);
      return container;
    }

    test('returns null for fresh profile (appLanguage == system)', () async {
      final c = makeContainer();
      // Wait for ProfileNotifier._load() to complete.
      await Future<void>.delayed(Duration.zero);
      expect(c.read(appLocaleProvider), isNull);
    });

    test('returns Locale(kk) after saveProfile(appLanguage: kk)', () async {
      final c = makeContainer();
      await Future<void>.delayed(Duration.zero);

      await c.read(profileProvider.notifier).saveProfile(
            StudentProfile.empty.copyWith(appLanguage: 'kk'),
          );

      expect(c.read(appLocaleProvider), equals(const Locale('kk')));
    });

    test('returns Locale(en) after saveProfile(appLanguage: en)', () async {
      final c = makeContainer();
      await Future<void>.delayed(Duration.zero);

      await c.read(profileProvider.notifier).saveProfile(
            StudentProfile.empty.copyWith(appLanguage: 'en'),
          );

      expect(c.read(appLocaleProvider), equals(const Locale('en')));
    });

    test('returns Locale(ru) after saveProfile(appLanguage: ru)', () async {
      final c = makeContainer();
      await Future<void>.delayed(Duration.zero);

      await c.read(profileProvider.notifier).saveProfile(
            StudentProfile.empty.copyWith(appLanguage: 'ru'),
          );

      expect(c.read(appLocaleProvider), equals(const Locale('ru')));
    });

    test('returns null again after reverting to system', () async {
      final c = makeContainer();
      await Future<void>.delayed(Duration.zero);

      await c.read(profileProvider.notifier).saveProfile(
            StudentProfile.empty.copyWith(appLanguage: 'en'),
          );
      expect(c.read(appLocaleProvider), isNotNull);

      await c.read(profileProvider.notifier).saveProfile(
            StudentProfile.empty.copyWith(appLanguage: 'system'),
          );
      expect(c.read(appLocaleProvider), isNull);
    });
  });

  // ── 2. Widget-level: MaterialApp.locale rebuilds ──────────────────────────

  group('MaterialApp locale rebuilds', () {
    testWidgets(
      'Localizations.localeOf returns kk after saveProfile(appLanguage: kk)',
      (tester) async {
        await tester.pumpWidget(_buildApp());
        await tester.pumpAndSettle(); // profile load + initial build

        final c = _containerOf(tester);
        await c.read(profileProvider.notifier).saveProfile(
              StudentProfile.empty.copyWith(appLanguage: 'kk'),
            );
        await tester.pumpAndSettle();

        final locale = Localizations.localeOf(
          tester.element(find.byType(_LocaleDisplay)),
        );
        expect(locale.languageCode, 'kk');
      },
    );

    testWidgets(
      'Localizations.localeOf returns en after saveProfile(appLanguage: en)',
      (tester) async {
        await tester.pumpWidget(_buildApp());
        await tester.pumpAndSettle();

        final c = _containerOf(tester);
        await c.read(profileProvider.notifier).saveProfile(
              StudentProfile.empty.copyWith(appLanguage: 'en'),
            );
        await tester.pumpAndSettle();

        final locale = Localizations.localeOf(
          tester.element(find.byType(_LocaleDisplay)),
        );
        expect(locale.languageCode, 'en');
      },
    );

    testWidgets(
      'Localizations.localeOf returns ru after saveProfile(appLanguage: ru)',
      (tester) async {
        await tester.pumpWidget(_buildApp());
        await tester.pumpAndSettle();

        final c = _containerOf(tester);
        await c.read(profileProvider.notifier).saveProfile(
              StudentProfile.empty.copyWith(appLanguage: 'ru'),
            );
        await tester.pumpAndSettle();

        final locale = Localizations.localeOf(
          tester.element(find.byType(_LocaleDisplay)),
        );
        expect(locale.languageCode, 'ru');
      },
    );

    testWidgets(
      'language switch is reversible: kk → ru updates locale',
      (tester) async {
        await tester.pumpWidget(_buildApp());
        await tester.pumpAndSettle();

        final c = _containerOf(tester);

        // Switch to Kazakh first.
        await c.read(profileProvider.notifier).saveProfile(
              StudentProfile.empty.copyWith(appLanguage: 'kk'),
            );
        await tester.pumpAndSettle();
        expect(
          Localizations.localeOf(
            tester.element(find.byType(_LocaleDisplay)),
          ).languageCode,
          'kk',
        );

        // Then switch to Russian.
        await c.read(profileProvider.notifier).saveProfile(
              StudentProfile.empty.copyWith(appLanguage: 'ru'),
            );
        await tester.pumpAndSettle();
        expect(
          Localizations.localeOf(
            tester.element(find.byType(_LocaleDisplay)),
          ).languageCode,
          'ru',
        );
      },
    );
  });

  // ── 3. AppBottomNav shows localised labels ────────────────────────────────

  group('AppBottomNav localised labels', () {
    Widget navInLocale(Locale locale) {
      return MaterialApp(
        locale: locale,
        supportedLocales: supportedAppLocales,
        localizationsDelegates: _allDelegates,
        home: Scaffold(
          bottomNavigationBar: AppBottomNav(
            selectedIndex: 0,
            onTap: (_) {},
            items: defaultNavItems,
          ),
        ),
      );
    }

    testWidgets('shows Russian labels when locale is ru', (tester) async {
      await tester.pumpWidget(navInLocale(const Locale('ru')));
      await tester.pumpAndSettle();

      expect(find.text('Главная'), findsOneWidget);
      expect(find.text('Вузы'), findsOneWidget);
      expect(find.text('Ералы'), findsOneWidget);
      expect(find.text('Возможности'), findsOneWidget);
      expect(find.text('Профиль'), findsOneWidget);
    });

    testWidgets('shows Kazakh labels when locale is kk', (tester) async {
      await tester.pumpWidget(navInLocale(const Locale('kk')));
      await tester.pumpAndSettle();

      expect(find.text('Басты бет'), findsOneWidget);
      expect(find.text('ЖОО'), findsOneWidget);
      expect(find.text('Ералы'), findsOneWidget);
      expect(find.text('Мүмкіндіктер'), findsOneWidget);
      expect(find.text('Профиль'), findsOneWidget);
    });

    testWidgets('shows English labels when locale is en', (tester) async {
      await tester.pumpWidget(navInLocale(const Locale('en')));
      await tester.pumpAndSettle();

      expect(find.text('Home'), findsOneWidget);
      expect(find.text('Universities'), findsOneWidget);
      expect(find.text('Eraly'), findsOneWidget);
      expect(find.text('Opportunities'), findsOneWidget);
      expect(find.text('Profile'), findsOneWidget);
    });

    testWidgets(
      'bottom nav updates when locale switches kk → en via saveProfile',
      (tester) async {
        final repo = InMemoryProfileRepository();

        // Build an app with the same pattern as AdmityApp: appLocaleProvider
        // drives MaterialApp.locale; AppBottomNav shows defaultNavItems.
        final app = ProviderScope(
          overrides: [
            profileRepositoryProvider.overrideWithValue(repo),
          ],
          child: const _ConsumerNavApp(),
        );
        await tester.pumpWidget(app);
        await tester.pumpAndSettle();

        // Initial: system locale → MaterialApp falls back to device/test locale.
        // Switch to Kazakh.
        final c = ProviderScope.containerOf(
          tester.element(find.byType(_ConsumerNavApp)),
        );
        await c.read(profileProvider.notifier).saveProfile(
              StudentProfile.empty.copyWith(appLanguage: 'kk'),
            );
        await tester.pumpAndSettle();

        expect(find.text('Басты бет'), findsOneWidget);

        // Now switch to English.
        await c.read(profileProvider.notifier).saveProfile(
              StudentProfile.empty.copyWith(appLanguage: 'en'),
            );
        await tester.pumpAndSettle();

        expect(find.text('Home'), findsOneWidget);
        expect(find.text('Басты бет'), findsNothing);
      },
    );
  });
}

// ── Helper widget that mimics AdmityApp's locale + nav wiring ────────────────

/// Mimics AdmityApp: watches [appLocaleProvider] and passes it to
/// [MaterialApp]; shows [AppBottomNav] with [defaultNavItems] so the
/// "bottom-nav updates" test can assert on the actual rendered labels.
class _ConsumerNavApp extends ConsumerWidget {
  const _ConsumerNavApp();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final locale = ref.watch(appLocaleProvider);
    return MaterialApp(
      locale: locale,
      supportedLocales: supportedAppLocales,
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      home: Scaffold(
        body: const SizedBox.shrink(),
        bottomNavigationBar: AppBottomNav(
          selectedIndex: 0,
          onTap: (_) {},
          items: defaultNavItems,
        ),
      ),
    );
  }
}
