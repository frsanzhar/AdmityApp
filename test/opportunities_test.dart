import 'package:admity/core/theme/app_tokens.dart';
import 'package:admity/features/opportunities/data/opportunity_seed.dart';
import 'package:admity/features/opportunities/domain/opportunity_filter.dart';
import 'package:admity/features/opportunities/domain/opportunity_models.dart';
import 'package:admity/features/opportunities/presentation/opportunities_providers.dart';
import 'package:admity/features/opportunities/presentation/opportunities_screen.dart';
import 'package:admity/features/opportunities/presentation/scholarship_apply_screen.dart';
import 'package:admity/features/opportunities/presentation/scholarship_detail_screen.dart';
import 'package:admity/features/profile/application/profile_notifier.dart';
import 'package:admity/features/profile/domain/profile_model.dart';
import 'package:admity/shared/widgets/featured_button.dart';
import 'package:admity/shared/widgets/mascot_slot.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';

// ── Helpers ───────────────────────────────────────────────────────────────────

Widget _themed(Widget widget) {
  return ProviderScope(
    child: MaterialApp(
      theme: ThemeData(extensions: [AppTokens.defaults()]),
      home: Scaffold(body: widget),
    ),
  );
}

/// Wraps [widget] in a ProviderScope that overrides [profileProvider] with a
/// pre-built [ProfileState] so we can test personalisation without real storage.
Widget _themedWithProfile(
  Widget widget, {
  StudentProfile profile = StudentProfile.empty,
}) {
  return ProviderScope(
    overrides: [
      profileProvider.overrideWith(
        () => _FakeProfileNotifier(ProfileState(profile: profile)),
      ),
    ],
    child: MaterialApp(
      theme: ThemeData(extensions: [AppTokens.defaults()]),
      home: Scaffold(body: widget),
    ),
  );
}

/// Minimal fake notifier — extends [ProfileNotifier] and overrides [build] to
/// return a fixed [ProfileState] without touching storage or network.
class _FakeProfileNotifier extends ProfileNotifier {
  _FakeProfileNotifier(this._fixed);
  final ProfileState _fixed;

  @override
  ProfileState build() => _fixed;
}

Widget _routerWrapped(Widget widget) {
  final router = GoRouter(
    initialLocation: '/opportunities',
    routes: [
      GoRoute(
        path: '/opportunities',
        builder: (context, state) => Scaffold(body: widget),
      ),
      GoRoute(
        path: '/opportunities/scholarship/:id',
        builder: (context, state) => Scaffold(
          body: Center(child: Text('Detail:${state.pathParameters['id']}')),
        ),
      ),
      GoRoute(
        path: '/opportunities/scholarship/:id/apply',
        builder: (context, state) =>
            const Scaffold(body: Center(child: Text('ApplyScreen'))),
      ),
    ],
  );
  return ProviderScope(
    child: MaterialApp.router(
      routerConfig: router,
      theme: ThemeData(extensions: [AppTokens.defaults()]),
    ),
  );
}

Widget _applyRouterWrapped(Widget widget, {ProviderContainer? container}) {
  final router = GoRouter(
    initialLocation: '/opportunities/scholarship/bolashak/apply',
    routes: [
      GoRoute(
        path: '/opportunities/scholarship/:id/apply',
        builder: (context, state) => Scaffold(body: widget),
      ),
      GoRoute(
        path: '/opportunities',
        builder: (context, state) =>
            const Scaffold(body: Center(child: Text('OpportunitiesScreen'))),
      ),
      GoRoute(
        path: '/opportunities/scholarship/:id',
        builder: (context, state) =>
            const Scaffold(body: Center(child: Text('DetailScreen'))),
      ),
    ],
  );
  if (container != null) {
    return UncontrolledProviderScope(
      container: container,
      child: MaterialApp.router(
        routerConfig: router,
        theme: ThemeData(extensions: [AppTokens.defaults()]),
      ),
    );
  }
  return ProviderScope(
    child: MaterialApp.router(
      routerConfig: router,
      theme: ThemeData(extensions: [AppTokens.defaults()]),
    ),
  );
}

// ── Unit tests: pure filter logic ─────────────────────────────────────────────

void main() {
  group('filterScholarships unit tests', () {
    test('empty filter returns all scholarships', () {
      final result = filterScholarships(
        seedScholarships,
        const OpportunityFilter(),
      );
      expect(result.length, seedScholarships.length);
    });

    test('city filter is case-insensitive partial match', () {
      final result = filterScholarships(
        seedScholarships,
        const OpportunityFilter(city: 'астана'),
      );
      expect(
        result.every((s) => s.city.toLowerCase().contains('астана')),
        isTrue,
      );
      expect(result.isNotEmpty, isTrue);
    });

    test('field filter returns only matching field', () {
      final result = filterScholarships(
        seedScholarships,
        const OpportunityFilter(field: AcademicField.informatics),
      );
      expect(result.every((s) => s.field == AcademicField.informatics), isTrue);
    });

    test('accessibility filter returns only matching level', () {
      final result = filterScholarships(
        seedScholarships,
        const OpportunityFilter(accessibility: Accessibility.hard),
      );
      expect(
        result.every((s) => s.accessibility == Accessibility.hard),
        isTrue,
      );
    });

    test('combined filter: city + field narrows correctly', () {
      final result = filterScholarships(
        seedScholarships,
        const OpportunityFilter(
          city: 'Астана',
          field: AcademicField.engineering,
        ),
      );
      expect(result.every((s) => s.city == 'Астана'), isTrue);
      expect(result.every((s) => s.field == AcademicField.engineering), isTrue);
    });

    test('filter with no matches returns empty list', () {
      final result = filterScholarships(
        seedScholarships,
        const OpportunityFilter(city: 'НесуществующийГород123'),
      );
      expect(result, isEmpty);
    });
  });

  group('filterUniversities unit tests', () {
    test('empty filter returns all universities', () {
      final result = filterUniversities(
        seedUniversities,
        const OpportunityFilter(),
      );
      expect(result.length, seedUniversities.length);
    });

    test('city filter narrows universities', () {
      final result = filterUniversities(
        seedUniversities,
        const OpportunityFilter(city: 'Алматы'),
      );
      expect(result.isNotEmpty, isTrue);
      expect(result.every((u) => u.city.contains('Алматы')), isTrue);
    });

    test('accessibility filter easy returns only easy', () {
      final result = filterUniversities(
        seedUniversities,
        const OpportunityFilter(accessibility: Accessibility.easy),
      );
      expect(
        result.every((u) => u.accessibility == Accessibility.easy),
        isTrue,
      );
    });
  });

  group('filterProjectIdeas unit tests', () {
    test('null field returns all ideas', () {
      final result = filterProjectIdeas(seedProjectIdeas, null);
      expect(result.length, seedProjectIdeas.length);
    });

    test('field filter returns only matching ideas', () {
      final result = filterProjectIdeas(
        seedProjectIdeas,
        AcademicField.informatics,
      );
      expect(result.every((p) => p.field == AcademicField.informatics), isTrue);
      expect(result.isNotEmpty, isTrue);
    });
  });

  group('OpportunityFilter model tests', () {
    test('isEmpty is true when all fields null', () {
      expect(const OpportunityFilter().isEmpty, isTrue);
    });

    test('isEmpty is false when any field set', () {
      expect(
        const OpportunityFilter(city: 'Алматы').isEmpty,
        isFalse,
      );
    });

    test('copyWith clearCity sets city to null', () {
      const f = OpportunityFilter(city: 'Алматы');
      final cleared = f.copyWith(clearCity: true);
      expect(cleared.city, isNull);
    });
  });

  // ── Widget tests: OpportunitiesScreen ────────────────────────────────────────

  group('OpportunitiesScreen widget tests', () {
    testWidgets('builds with NO framework/layout errors', (tester) async {
      final errors = <FlutterErrorDetails>[];
      final prev = FlutterError.onError;
      FlutterError.onError = errors.add;
      addTearDown(() => FlutterError.onError = prev);

      await tester.pumpWidget(_themed(const OpportunitiesScreen()));
      await tester.pumpAndSettle();

      expect(
        errors,
        isEmpty,
        reason: 'no swallowed layout errors on OpportunitiesScreen',
      );
    });

    testWidgets('all four section tabs are visible', (tester) async {
      await tester.pumpWidget(_themed(const OpportunitiesScreen()));
      await tester.pumpAndSettle();

      expect(find.text('Стипендии'), findsWidgets);
      expect(find.text('Университеты'), findsOneWidget);
      expect(find.text('Мероприятия'), findsOneWidget);
      expect(find.text('Идеи проектов'), findsOneWidget);
    });

    testWidgets('default section shows scholarships list', (tester) async {
      await tester.pumpWidget(_themed(const OpportunitiesScreen()));
      await tester.pumpAndSettle();

      expect(find.text('Болашак'), findsOneWidget);
    });

    testWidgets('switching to Университеты shows universities', (tester) async {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      await tester.pumpWidget(
        UncontrolledProviderScope(
          container: container,
          child: MaterialApp(
            theme: ThemeData(extensions: [AppTokens.defaults()]),
            home: const Scaffold(body: OpportunitiesScreen()),
          ),
        ),
      );
      await tester.pumpAndSettle();

      await tester.tap(find.text('Университеты'));
      await tester.pumpAndSettle();

      expect(
        container.read(opportunitiesSectionProvider),
        OpportunitySection.universities,
      );
      expect(find.text('Назарбаев Университет'), findsOneWidget);
    });

    testWidgets('switching to Мероприятия shows events', (tester) async {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      await tester.pumpWidget(
        UncontrolledProviderScope(
          container: container,
          child: MaterialApp(
            theme: ThemeData(extensions: [AppTokens.defaults()]),
            home: const Scaffold(body: OpportunitiesScreen()),
          ),
        ),
      );
      await tester.pumpAndSettle();

      await tester.tap(find.text('Мероприятия'));
      await tester.pumpAndSettle();

      expect(
        container.read(opportunitiesSectionProvider),
        OpportunitySection.events,
      );
      expect(find.text('STEM-ярмарка Казахстана'), findsOneWidget);
    });

    testWidgets('switching to Идеи проектов shows project ideas', (
      tester,
    ) async {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      await tester.pumpWidget(
        UncontrolledProviderScope(
          container: container,
          child: MaterialApp(
            theme: ThemeData(extensions: [AppTokens.defaults()]),
            home: const Scaffold(body: OpportunitiesScreen()),
          ),
        ),
      );
      await tester.pumpAndSettle();

      await tester.tap(find.text('Идеи проектов'));
      await tester.pumpAndSettle();

      expect(
        container.read(opportunitiesSectionProvider),
        OpportunitySection.projectIdeas,
      );
      expect(find.text('Предиктор ЕНТ-баллов'), findsOneWidget);
    });

    testWidgets('filter by field narrows scholarship list', (tester) async {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      await tester.pumpWidget(
        UncontrolledProviderScope(
          container: container,
          child: MaterialApp(
            theme: ThemeData(extensions: [AppTokens.defaults()]),
            home: const Scaffold(body: OpportunitiesScreen()),
          ),
        ),
      );
      await tester.pumpAndSettle();

      container
          .read(opportunityFilterProvider.notifier)
          .setField(AcademicField.informatics);
      await tester.pumpAndSettle();

      final filtered = container.read(filteredScholarshipsProvider);
      expect(
        filtered.every((s) => s.field == AcademicField.informatics),
        isTrue,
      );
    });

    testWidgets('clearing filter shows all scholarships again', (tester) async {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      await tester.pumpWidget(
        UncontrolledProviderScope(
          container: container,
          child: MaterialApp(
            theme: ThemeData(extensions: [AppTokens.defaults()]),
            home: const Scaffold(body: OpportunitiesScreen()),
          ),
        ),
      );
      await tester.pumpAndSettle();

      container
          .read(opportunityFilterProvider.notifier)
          .setField(AcademicField.informatics);
      await tester.pumpAndSettle();

      container.read(opportunityFilterProvider.notifier).clearAll();
      await tester.pumpAndSettle();

      final all = container.read(filteredScholarshipsProvider);
      expect(all.length, seedScholarships.length);
    });

    testWidgets('tapping scholarship card navigates to detail', (tester) async {
      await tester.pumpWidget(_routerWrapped(const OpportunitiesScreen()));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Болашак'));
      await tester.pumpAndSettle();

      expect(find.textContaining('Detail:bolashak'), findsOneWidget);
    });
  });

  // ── Personalised project ideas (req 1) ────────────────────────────────────────

  group('personalizedProjectIdeasProvider unit tests', () {
    test(
      'empty interests returns all ideas with hasProfileInterests=false',
      () {
        final container = ProviderContainer(
          overrides: [
            profileProvider.overrideWith(
              () => _FakeProfileNotifier(
                const ProfileState(),
              ),
            ),
          ],
        );
        addTearDown(container.dispose);

        final result = container.read(personalizedProjectIdeasProvider);
        expect(result.hasProfileInterests, isFalse);
        expect(result.matchedInterest, isNull);
        expect(result.ideas.length, seedProjectIdeas.length);
      },
    );

    test('informatics-mapped interest ranks informatics ideas first', () {
      final container = ProviderContainer(
        overrides: [
          profileProvider.overrideWith(
            () => _FakeProfileNotifier(
              const ProfileState(
                profile: StudentProfile(interests: ['Программирование']),
              ),
            ),
          ),
        ],
      );
      addTearDown(container.dispose);

      final result = container.read(personalizedProjectIdeasProvider);
      expect(result.hasProfileInterests, isTrue);
      expect(result.matchedInterest, 'Программирование');
      expect(result.ideas.first.field, AcademicField.informatics);
    });

    test(
      'unrecognised interest returns all ideas but hasProfileInterests=true',
      () {
        final container = ProviderContainer(
          overrides: [
            profileProvider.overrideWith(
              () => _FakeProfileNotifier(
                const ProfileState(
                  profile: StudentProfile(interests: ['Кулинария']),
                ),
              ),
            ),
          ],
        );
        addTearDown(container.dispose);

        final result = container.read(personalizedProjectIdeasProvider);
        expect(result.hasProfileInterests, isTrue);
        expect(result.ideas.length, seedProjectIdeas.length);
      },
    );
  });

  group('personalizedProjectIdeas widget tests', () {
    testWidgets('shows "по твоему интересу" banner when interests match', (
      tester,
    ) async {
      final errors = <FlutterErrorDetails>[];
      final prev = FlutterError.onError;
      FlutterError.onError = errors.add;
      addTearDown(() => FlutterError.onError = prev);

      final container = ProviderContainer(
        overrides: [
          profileProvider.overrideWith(
            () => _FakeProfileNotifier(
              const ProfileState(
                profile: StudentProfile(interests: ['Информатика']),
              ),
            ),
          ),
        ],
      );
      addTearDown(container.dispose);

      await tester.pumpWidget(
        UncontrolledProviderScope(
          container: container,
          child: MaterialApp(
            theme: ThemeData(extensions: [AppTokens.defaults()]),
            home: const Scaffold(body: OpportunitiesScreen()),
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Switch to Project Ideas tab
      await tester.tap(find.text('Идеи проектов'));
      await tester.pumpAndSettle();

      expect(find.textContaining('по твоему интересу'), findsOneWidget);
      expect(
        errors,
        isEmpty,
        reason: 'no layout errors on project ideas with interests',
      );
    });

    testWidgets('shows fill-profile prompt when interests empty', (
      tester,
    ) async {
      final errors = <FlutterErrorDetails>[];
      final prev = FlutterError.onError;
      FlutterError.onError = errors.add;
      addTearDown(() => FlutterError.onError = prev);

      await tester.pumpWidget(
        _themedWithProfile(const OpportunitiesScreen()),
      );
      await tester.pumpAndSettle();

      await tester.tap(find.text('Идеи проектов'));
      await tester.pumpAndSettle();

      expect(find.textContaining('Добавь интересы'), findsOneWidget);
      expect(errors, isEmpty);
    });
  });

  // ── Location-based events (req 2) ─────────────────────────────────────────────

  group('localEventsProvider unit tests', () {
    test('no city returns all events unranked', () {
      final container = ProviderContainer(
        overrides: [
          profileProvider.overrideWith(
            () => _FakeProfileNotifier(
              const ProfileState(),
            ),
          ),
        ],
      );
      addTearDown(container.dispose);

      final result = container.read(localEventsProvider);
      expect(result.profileCity, isNull);
      expect(result.events.length, seedEvents.length);
    });

    test('matching city moves local events to front', () {
      final container = ProviderContainer(
        overrides: [
          profileProvider.overrideWith(
            () => _FakeProfileNotifier(
              const ProfileState(
                profile: StudentProfile(city: 'Алматы'),
              ),
            ),
          ),
        ],
      );
      addTearDown(container.dispose);

      final result = container.read(localEventsProvider);
      expect(result.profileCity, 'Алматы');
      // Local events come first
      expect(
        result.events.first.city.toLowerCase().contains('алматы'),
        isTrue,
      );
    });

    test('city with no matching events returns all events', () {
      final container = ProviderContainer(
        overrides: [
          profileProvider.overrideWith(
            () => _FakeProfileNotifier(
              const ProfileState(
                profile: StudentProfile(city: 'Нур-Султан99'),
              ),
            ),
          ),
        ],
      );
      addTearDown(container.dispose);

      final result = container.read(localEventsProvider);
      expect(result.events.length, seedEvents.length);
    });
  });

  group('location-based events widget tests', () {
    testWidgets('shows "рядом с тобой" banner when city is set', (
      tester,
    ) async {
      final errors = <FlutterErrorDetails>[];
      final prev = FlutterError.onError;
      FlutterError.onError = errors.add;
      addTearDown(() => FlutterError.onError = prev);

      final container = ProviderContainer(
        overrides: [
          profileProvider.overrideWith(
            () => _FakeProfileNotifier(
              const ProfileState(
                profile: StudentProfile(city: 'Алматы'),
              ),
            ),
          ),
        ],
      );
      addTearDown(container.dispose);

      await tester.pumpWidget(
        UncontrolledProviderScope(
          container: container,
          child: MaterialApp(
            theme: ThemeData(extensions: [AppTokens.defaults()]),
            home: const Scaffold(body: OpportunitiesScreen()),
          ),
        ),
      );
      await tester.pumpAndSettle();

      await tester.tap(find.text('Мероприятия'));
      await tester.pumpAndSettle();

      expect(find.textContaining('рядом с тобой'), findsOneWidget);
      expect(find.textContaining('Алматы'), findsWidgets);
      expect(
        errors,
        isEmpty,
        reason: 'no layout errors on events tab with city',
      );
    });

    testWidgets('shows fill-profile prompt when city not set', (tester) async {
      final errors = <FlutterErrorDetails>[];
      final prev = FlutterError.onError;
      FlutterError.onError = errors.add;
      addTearDown(() => FlutterError.onError = prev);

      await tester.pumpWidget(
        _themedWithProfile(const OpportunitiesScreen()),
      );
      await tester.pumpAndSettle();

      await tester.tap(find.text('Мероприятия'));
      await tester.pumpAndSettle();

      expect(find.textContaining('Укажи свой город'), findsOneWidget);
      expect(errors, isEmpty);
    });

    testWidgets(
      'events tab builds with NO layout errors (blank-screen guard)',
      (tester) async {
        final errors = <FlutterErrorDetails>[];
        final prev = FlutterError.onError;
        FlutterError.onError = errors.add;
        addTearDown(() => FlutterError.onError = prev);

        await tester.pumpWidget(_themed(const OpportunitiesScreen()));
        await tester.pumpAndSettle();

        await tester.tap(find.text('Мероприятия'));
        await tester.pumpAndSettle();

        expect(
          errors,
          isEmpty,
          reason: 'no swallowed layout errors on events tab',
        );
      },
    );

    testWidgets(
      'project ideas tab builds with NO layout errors (blank-screen guard)',
      (tester) async {
        final errors = <FlutterErrorDetails>[];
        final prev = FlutterError.onError;
        FlutterError.onError = errors.add;
        addTearDown(() => FlutterError.onError = prev);

        await tester.pumpWidget(_themed(const OpportunitiesScreen()));
        await tester.pumpAndSettle();

        await tester.tap(find.text('Идеи проектов'));
        await tester.pumpAndSettle();

        expect(
          errors,
          isEmpty,
          reason: 'no swallowed layout errors on project ideas tab',
        );
      },
    );
  });

  // ── Widget tests: ScholarshipDetailScreen ─────────────────────────────────────

  group('ScholarshipDetailScreen widget tests', () {
    testWidgets('builds with NO framework/layout errors', (tester) async {
      final errors = <FlutterErrorDetails>[];
      final prev = FlutterError.onError;
      FlutterError.onError = errors.add;
      addTearDown(() => FlutterError.onError = prev);

      await tester.pumpWidget(
        _themed(const ScholarshipDetailScreen(scholarshipId: 'bolashak')),
      );
      await tester.pumpAndSettle();

      expect(
        errors,
        isEmpty,
        reason: 'no layout errors on ScholarshipDetailScreen',
      );
    });

    testWidgets('shows scholarship name, coverage, and how-to sections', (
      tester,
    ) async {
      await tester.pumpWidget(
        _themed(const ScholarshipDetailScreen(scholarshipId: 'bolashak')),
      );
      await tester.pumpAndSettle();

      expect(find.text('Болашак'), findsWidgets);
      expect(find.text('Что покрывает'), findsOneWidget);
      expect(find.text('Как получить'), findsOneWidget);
      expect(find.text('Нужные показатели'), findsOneWidget);
      expect(find.text('Требуемые документы'), findsOneWidget);
    });

    testWidgets('FeaturedButton "Подать заявку" is present', (tester) async {
      await tester.pumpWidget(
        _themed(const ScholarshipDetailScreen(scholarshipId: 'bolashak')),
      );
      await tester.pumpAndSettle();

      await tester.scrollUntilVisible(
        find.text('Подать заявку'),
        100,
        scrollable: find.byType(Scrollable).first,
      );
      await tester.pumpAndSettle();

      expect(find.byType(FeaturedButton), findsOneWidget);
      expect(find.text('Подать заявку'), findsOneWidget);
    });

    testWidgets('unknown scholarship id shows fallback', (tester) async {
      await tester.pumpWidget(
        _themed(const ScholarshipDetailScreen(scholarshipId: 'unknown_xyz')),
      );
      await tester.pumpAndSettle();

      expect(find.text('Стипендия не найдена'), findsOneWidget);
    });
  });

  // ── Widget tests: ScholarshipApplyScreen ─────────────────────────────────────

  group('ScholarshipApplyScreen widget tests', () {
    testWidgets('builds with NO framework/layout errors', (tester) async {
      final errors = <FlutterErrorDetails>[];
      final prev = FlutterError.onError;
      FlutterError.onError = errors.add;
      addTearDown(() => FlutterError.onError = prev);

      await tester.pumpWidget(
        _applyRouterWrapped(
          const ScholarshipApplyScreen(scholarshipId: 'bolashak'),
        ),
      );
      await tester.pumpAndSettle();

      expect(
        errors,
        isEmpty,
        reason: 'no layout errors on ScholarshipApplyScreen',
      );
    });

    testWidgets('form fields are visible', (tester) async {
      await tester.pumpWidget(
        _applyRouterWrapped(
          const ScholarshipApplyScreen(scholarshipId: 'bolashak'),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('ФИО'), findsOneWidget);
      expect(find.text('Контакт (email или телефон)'), findsOneWidget);
      expect(find.text('Мотивационное письмо'), findsOneWidget);
      expect(find.text('Отправить заявку'), findsOneWidget);
    });

    testWidgets('submitting empty form shows validation errors', (
      tester,
    ) async {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      await tester.pumpWidget(
        _applyRouterWrapped(
          const ScholarshipApplyScreen(scholarshipId: 'bolashak'),
          container: container,
        ),
      );
      await tester.pumpAndSettle();

      await tester.scrollUntilVisible(
        find.text('Отправить заявку'),
        100,
        scrollable: find.byType(Scrollable).first,
      );
      await tester.tap(find.text('Отправить заявку'));
      await tester.pumpAndSettle();

      final errors = container.read(applicationFormProvider).fieldErrors;
      expect(errors, isNotNull);
      expect(errors!['fullName'], isNotNull);
      expect(errors['contact'], isNotNull);
      expect(errors['motivation'], isNotNull);
    });

    testWidgets('valid form submission shows success screen', (tester) async {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      await tester.pumpWidget(
        _applyRouterWrapped(
          const ScholarshipApplyScreen(scholarshipId: 'bolashak'),
          container: container,
        ),
      );
      await tester.pumpAndSettle();

      container.read(applicationFormProvider.notifier)
        ..setFullName('Иванов Иван Иванович')
        ..setContact('ivan@mail.kz')
        ..setMotivation(
          'Я хочу получить эту стипендию, потому что стремлюсь учиться за рубежом '
          'и развивать казахстанскую науку.',
        );
      await tester.pump();

      // submit() includes an 800ms real delay; use runAsync to run it outside
      // fake-async so the timer fires and the future resolves.
      await tester.runAsync(
        () => container.read(applicationFormProvider.notifier).submit(),
      );
      await tester.pump();

      expect(container.read(applicationFormProvider).isSuccess, isTrue);
    });

    testWidgets('success state shows MascotSlot and success message', (
      tester,
    ) async {
      final errors = <FlutterErrorDetails>[];
      final prev = FlutterError.onError;
      FlutterError.onError = errors.add;
      addTearDown(() => FlutterError.onError = prev);

      final container = ProviderContainer();
      addTearDown(container.dispose);

      await tester.pumpWidget(
        _applyRouterWrapped(
          const ScholarshipApplyScreen(scholarshipId: 'bolashak'),
          container: container,
        ),
      );
      await tester.pumpAndSettle();

      container.read(applicationFormProvider.notifier)
        ..setFullName('Иванов Иван')
        ..setContact('ivan@mail.kz')
        ..setMotivation('Очень сильно хочу учиться и развиваться за рубежом!');

      // submit() has an 800ms real delay; use runAsync so the timer fires.
      await tester.runAsync(
        () => container.read(applicationFormProvider.notifier).submit(),
      );
      await tester.pump();

      expect(find.text('Заявка отправлена!'), findsOneWidget);
      expect(find.byType(MascotSlot), findsOneWidget);
      expect(find.text('Вернуться к стипендиям'), findsOneWidget);

      expect(errors, isEmpty, reason: 'no layout errors on success screen');
    });
  });
}
