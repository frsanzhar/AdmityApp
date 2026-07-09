import 'package:admity/core/theme/app_tokens.dart';
import 'package:admity/features/opportunities/data/opportunity_seed.dart';
import 'package:admity/features/opportunities/domain/opportunity_filter.dart';
import 'package:admity/features/opportunities/domain/opportunity_models.dart';
import 'package:admity/features/opportunities/domain/study_material.dart';
import 'package:admity/features/opportunities/presentation/event_detail_screen.dart';
import 'package:admity/features/opportunities/presentation/idea_detail_screen.dart';
import 'package:admity/features/opportunities/presentation/opportunities_providers.dart';
import 'package:admity/features/opportunities/presentation/opportunities_screen.dart';
import 'package:admity/features/opportunities/presentation/scholarship_apply_screen.dart';
import 'package:admity/features/opportunities/presentation/scholarship_detail_screen.dart';
import 'package:admity/features/opportunities/presentation/study_materials_provider.dart';
import 'package:admity/features/opportunities/presentation/university_detail_screen.dart';
import 'package:admity/features/profile/application/profile_notifier.dart';
import 'package:admity/features/profile/domain/profile_model.dart';
import 'package:admity/shared/widgets/featured_button.dart';
import 'package:admity/shared/widgets/mascot_slot.dart';
import 'package:admity/shared/widgets/progress_ring.dart';
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

    testWidgets(
      'three section tabs are visible (Университеты moved to /universities)',
      (tester) async {
        await tester.pumpWidget(_themed(const OpportunitiesScreen()));
        await tester.pumpAndSettle();

        expect(find.text('Стипендии'), findsWidgets);
        // Университеты is now its own /universities screen — must NOT appear here.
        expect(find.text('Университеты'), findsNothing);
        expect(find.text('Мероприятия'), findsOneWidget);
        expect(find.text('Идеи проектов'), findsOneWidget);
      },
    );

    testWidgets('default section shows scholarships list', (tester) async {
      await tester.pumpWidget(_themed(const OpportunitiesScreen()));
      await tester.pumpAndSettle();

      expect(find.text('Болашак'), findsOneWidget);
    });

    // Университеты tab was removed from OpportunitiesScreen — it lives at
    // /universities. This test now verifies that universities are NOT shown here.
    testWidgets('Университеты tab is absent from OpportunitiesScreen', (
      tester,
    ) async {
      await tester.pumpWidget(_themed(const OpportunitiesScreen()));
      await tester.pumpAndSettle();

      expect(find.text('Университеты'), findsNothing);
      // Seed university name should not appear either
      expect(find.text('Назарбаев Университет'), findsNothing);
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

  // ── Widget tests: UniversityDetailScreen ──────────────────────────────────────

  group('UniversityDetailScreen widget tests', () {
    testWidgets('builds with NO framework/layout errors (blank-screen guard)', (
      tester,
    ) async {
      final errors = <FlutterErrorDetails>[];
      final prev = FlutterError.onError;
      FlutterError.onError = errors.add;
      addTearDown(() => FlutterError.onError = prev);

      await tester.pumpWidget(
        _themed(const UniversityDetailScreen(universityId: 'nu')),
      );
      await tester.pumpAndSettle();

      expect(
        errors,
        isEmpty,
        reason: 'no swallowed layout errors on UniversityDetailScreen',
      );
    });

    testWidgets('shows university name and key sections', (tester) async {
      await tester.pumpWidget(
        _themed(const UniversityDetailScreen(universityId: 'nu')),
      );
      await tester.pumpAndSettle();

      expect(find.text('Назарбаев Университет'), findsWidgets);
      expect(find.text('О университете'), findsOneWidget);
      expect(find.text('Направления'), findsOneWidget);
      expect(find.text('Шансы поступления'), findsOneWidget);
      expect(find.text('Требования'), findsOneWidget);
      expect(find.text('Стоимость и стипендии'), findsOneWidget);
    });

    testWidgets('shows ProgressRing for acceptance rate', (tester) async {
      await tester.pumpWidget(
        _themed(const UniversityDetailScreen(universityId: 'nu')),
      );
      await tester.pumpAndSettle();

      expect(find.byType(ProgressRing), findsOneWidget);
    });

    testWidgets('shows "Как поступить" steps section', (tester) async {
      await tester.pumpWidget(
        _themed(const UniversityDetailScreen(universityId: 'nu')),
      );
      await tester.pumpAndSettle();

      await tester.scrollUntilVisible(
        find.text('Как поступить'),
        100,
        scrollable: find.byType(Scrollable).first,
      );
      expect(find.text('Как поступить'), findsOneWidget);
    });

    testWidgets('shows FeaturedButton for website CTA', (tester) async {
      await tester.pumpWidget(
        _themed(const UniversityDetailScreen(universityId: 'nu')),
      );
      await tester.pumpAndSettle();

      await tester.scrollUntilVisible(
        find.byType(FeaturedButton),
        100,
        scrollable: find.byType(Scrollable).first,
      );
      expect(find.byType(FeaturedButton), findsOneWidget);
    });

    testWidgets('unknown university id shows fallback', (tester) async {
      await tester.pumpWidget(
        _themed(const UniversityDetailScreen(universityId: 'unknown_xyz')),
      );
      await tester.pumpAndSettle();

      expect(find.text('Университет не найден'), findsOneWidget);
    });

    // University navigation from OpportunitiesScreen is gone; navigation now
    // happens from UniversitiesScreen (/universities). This test is superseded
    // by universities_screen_test.dart which covers the tapping flow.
    testWidgets(
      'OpportunitiesScreen no longer has a university navigation path',
      (
        tester,
      ) async {
        await tester.pumpWidget(_themed(const OpportunitiesScreen()));
        await tester.pumpAndSettle();

        expect(find.text('Университеты'), findsNothing);
      },
    );
  });

  // ── Widget tests: EventDetailScreen ──────────────────────────────────────────

  group('EventDetailScreen widget tests', () {
    testWidgets('builds with NO framework/layout errors (blank-screen guard)', (
      tester,
    ) async {
      final errors = <FlutterErrorDetails>[];
      final prev = FlutterError.onError;
      FlutterError.onError = errors.add;
      addTearDown(() => FlutterError.onError = prev);

      await tester.pumpWidget(
        _themed(const EventDetailScreen(eventId: 'stem_fair')),
      );
      await tester.pumpAndSettle();

      expect(
        errors,
        isEmpty,
        reason: 'no swallowed layout errors on EventDetailScreen',
      );
    });

    testWidgets('shows event title, date, location and description', (
      tester,
    ) async {
      await tester.pumpWidget(
        _themed(const EventDetailScreen(eventId: 'stem_fair')),
      );
      await tester.pumpAndSettle();

      expect(find.text('STEM-ярмарка Казахстана'), findsWidgets);
      expect(find.text('О мероприятии'), findsOneWidget);
      expect(find.text('Как участвовать'), findsOneWidget);
    });

    testWidgets('shows prize section when event has prize', (tester) async {
      await tester.pumpWidget(
        _themed(const EventDetailScreen(eventId: 'stem_fair')),
      );
      await tester.pumpAndSettle();

      expect(find.text('Призы'), findsOneWidget);
    });

    testWidgets('shows registration deadline banner', (tester) async {
      await tester.pumpWidget(
        _themed(const EventDetailScreen(eventId: 'stem_fair')),
      );
      await tester.pumpAndSettle();

      expect(find.textContaining('Дедлайн регистрации'), findsOneWidget);
    });

    testWidgets('PrimaryButton "Добавить в список" is present', (tester) async {
      await tester.pumpWidget(
        _themed(const EventDetailScreen(eventId: 'hackathon_kz')),
      );
      await tester.pumpAndSettle();

      await tester.scrollUntilVisible(
        find.text('Добавить в список мероприятий'),
        100,
        scrollable: find.byType(Scrollable).first,
      );
      expect(find.text('Добавить в список мероприятий'), findsOneWidget);
    });

    testWidgets('unknown event id shows fallback', (tester) async {
      await tester.pumpWidget(
        _themed(const EventDetailScreen(eventId: 'unknown_xyz')),
      );
      await tester.pumpAndSettle();

      expect(find.text('Мероприятие не найдено'), findsOneWidget);
    });

    testWidgets('tapping event card in list navigates to detail', (
      tester,
    ) async {
      final router = GoRouter(
        initialLocation: '/opportunities',
        routes: [
          GoRoute(
            path: '/opportunities',
            builder: (context, state) =>
                const Scaffold(body: OpportunitiesScreen()),
          ),
          GoRoute(
            path: '/opportunities/scholarship/:id',
            builder: (context, state) =>
                const Scaffold(body: Center(child: Text('ScholarshipDetail'))),
          ),
          GoRoute(
            path: '/opportunities/event/:id',
            builder: (context, state) => Scaffold(
              body: Center(
                child: Text('EventDetail:${state.pathParameters['id']}'),
              ),
            ),
          ),
        ],
      );

      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp.router(
            routerConfig: router,
            theme: ThemeData(extensions: [AppTokens.defaults()]),
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Switch to events tab
      await tester.tap(find.text('Мероприятия'));
      await tester.pumpAndSettle();

      // Tap the STEM-ярмарка card
      await tester.tap(find.text('STEM-ярмарка Казахстана'));
      await tester.pumpAndSettle();

      expect(find.textContaining('EventDetail:stem_fair'), findsOneWidget);
    });
  });

  // ── Widget tests: IdeaDetailScreen ───────────────────────────────────────────

  group('IdeaDetailScreen widget tests', () {
    testWidgets('builds with NO framework/layout errors (blank-screen guard)', (
      tester,
    ) async {
      final errors = <FlutterErrorDetails>[];
      final prev = FlutterError.onError;
      FlutterError.onError = errors.add;
      addTearDown(() => FlutterError.onError = prev);

      await tester.pumpWidget(
        _themed(const IdeaDetailScreen(ideaId: 'ml_ent')),
      );
      await tester.pumpAndSettle();

      expect(
        errors,
        isEmpty,
        reason: 'no swallowed layout errors on IdeaDetailScreen',
      );
    });

    testWidgets('shows idea title, description, and key sections', (
      tester,
    ) async {
      await tester.pumpWidget(
        _themed(const IdeaDetailScreen(ideaId: 'ml_ent')),
      );
      await tester.pumpAndSettle();

      expect(find.text('Предиктор ЕНТ-баллов'), findsWidgets);
      expect(find.text('Что за проект'), findsOneWidget);
      expect(find.text('Почему это твоё'), findsOneWidget);
      expect(find.text('Шаги'), findsOneWidget);
    });

    testWidgets('shows "Что получишь в итоге" section', (tester) async {
      await tester.pumpWidget(
        _themed(const IdeaDetailScreen(ideaId: 'ml_ent')),
      );
      await tester.pumpAndSettle();

      await tester.scrollUntilVisible(
        find.text('Что получишь в итоге'),
        100,
        scrollable: find.byType(Scrollable).first,
      );
      expect(find.text('Что получишь в итоге'), findsOneWidget);
    });

    testWidgets('PrimaryButton "Сохранить идею" is present', (tester) async {
      await tester.pumpWidget(
        _themed(const IdeaDetailScreen(ideaId: 'ml_ent')),
      );
      await tester.pumpAndSettle();

      await tester.scrollUntilVisible(
        find.text('Сохранить идею'),
        100,
        scrollable: find.byType(Scrollable).first,
      );
      expect(find.text('Сохранить идею'), findsOneWidget);
    });

    testWidgets('shows MascotSlot in the hero', (tester) async {
      await tester.pumpWidget(
        _themed(const IdeaDetailScreen(ideaId: 'eco_monitor')),
      );
      await tester.pumpAndSettle();

      expect(find.byType(MascotSlot), findsOneWidget);
    });

    testWidgets('unknown idea id shows fallback', (tester) async {
      await tester.pumpWidget(
        _themed(const IdeaDetailScreen(ideaId: 'unknown_xyz')),
      );
      await tester.pumpAndSettle();

      expect(find.text('Идея проекта не найдена'), findsOneWidget);
    });

    testWidgets('tapping idea card in list navigates to detail', (
      tester,
    ) async {
      final router = GoRouter(
        initialLocation: '/opportunities',
        routes: [
          GoRoute(
            path: '/opportunities',
            builder: (context, state) =>
                const Scaffold(body: OpportunitiesScreen()),
          ),
          GoRoute(
            path: '/opportunities/scholarship/:id',
            builder: (context, state) =>
                const Scaffold(body: Center(child: Text('ScholarshipDetail'))),
          ),
          GoRoute(
            path: '/opportunities/idea/:id',
            builder: (context, state) => Scaffold(
              body: Center(
                child: Text('IdeaDetail:${state.pathParameters['id']}'),
              ),
            ),
          ),
        ],
      );

      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp.router(
            routerConfig: router,
            theme: ThemeData(extensions: [AppTokens.defaults()]),
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Switch to project ideas tab
      await tester.tap(find.text('Идеи проектов'));
      await tester.pumpAndSettle();

      // Tap the first idea card
      await tester.tap(find.text('Предиктор ЕНТ-баллов'));
      await tester.pumpAndSettle();

      expect(find.textContaining('IdeaDetail:ml_ent'), findsOneWidget);
    });
  });

  // ── Study material domain model tests ────────────────────────────────────────

  group('StudyMaterial model tests', () {
    test('fromJson deserializes all fields correctly', () {
      final json = <String, dynamic>{
        'id': 'abc',
        'title': 'IELTS Guide',
        'description': 'Full prep guide',
        'exam': 'ielts',
        'major': 'Английский язык',
        'file_url': 'https://example.com/guide.pdf',
        'size_label': '4.2 МБ',
        'created_at': '2025-01-15T10:00:00.000Z',
      };
      final m = StudyMaterial.fromJson(json);
      expect(m.id, 'abc');
      expect(m.title, 'IELTS Guide');
      expect(m.exam, StudyMaterialExam.ielts);
      expect(m.major, 'Английский язык');
      expect(m.sizeLabel, '4.2 МБ');
      expect(m.createdAt, DateTime.parse('2025-01-15T10:00:00.000Z'));
    });

    test('fromJson uses empty string when description is null', () {
      final json = <String, dynamic>{
        'id': 'x',
        'title': 'SAT Math',
        'description': null,
        'exam': 'sat',
        'file_url': 'https://x.com/file',
        'created_at': '2025-06-01T00:00:00.000Z',
      };
      final m = StudyMaterial.fromJson(json);
      expect(m.description, '');
    });

    test('parseStudyMaterialExam maps known values correctly', () {
      expect(parseStudyMaterialExam('ielts'), StudyMaterialExam.ielts);
      expect(parseStudyMaterialExam('IELTS'), StudyMaterialExam.ielts);
      expect(parseStudyMaterialExam('sat'), StudyMaterialExam.sat);
      expect(parseStudyMaterialExam('ent'), StudyMaterialExam.ent);
      expect(parseStudyMaterialExam('other'), StudyMaterialExam.other);
      expect(parseStudyMaterialExam(null), StudyMaterialExam.other);
      expect(parseStudyMaterialExam('unknown'), StudyMaterialExam.other);
    });

    test('studyMaterialExamLabel returns correct strings', () {
      expect(studyMaterialExamLabel(StudyMaterialExam.ielts), 'IELTS');
      expect(studyMaterialExamLabel(StudyMaterialExam.sat), 'SAT');
      expect(studyMaterialExamLabel(StudyMaterialExam.ent), 'ЕНТ');
      expect(studyMaterialExamLabel(StudyMaterialExam.other), 'Другое');
    });
  });

  // ── StudyMaterialsFilter tests ────────────────────────────────────────────────

  group('StudyMaterialsFilter tests', () {
    test('default filter has no active filters', () {
      expect(const StudyMaterialsFilter().hasActiveFilter, isFalse);
    });

    test('hasActiveFilter is true when query is set', () {
      expect(
        const StudyMaterialsFilter(query: 'IELTS').hasActiveFilter,
        isTrue,
      );
    });

    test('hasActiveFilter is true when exam is set', () {
      expect(
        const StudyMaterialsFilter(exam: StudyMaterialExam.sat)
            .hasActiveFilter,
        isTrue,
      );
    });

    test('hasActiveFilter is true when major is set', () {
      expect(
        const StudyMaterialsFilter(major: 'Math').hasActiveFilter,
        isTrue,
      );
    });

    test('copyWith clearExam removes exam', () {
      const f = StudyMaterialsFilter(exam: StudyMaterialExam.ielts);
      expect(f.copyWith(clearExam: true).exam, isNull);
    });

    test('copyWith clearMajor removes major', () {
      const f = StudyMaterialsFilter(major: 'Math');
      expect(f.copyWith(clearMajor: true).major, isNull);
    });

    test('cleared resets to defaults', () {
      const f = StudyMaterialsFilter(
        query: 'x',
        exam: StudyMaterialExam.ent,
        major: 'Bio',
        newestFirst: false,
      );
      final cleared = f.cleared();
      expect(cleared.query, '');
      expect(cleared.exam, isNull);
      expect(cleared.major, isNull);
      expect(cleared.newestFirst, isTrue);
    });
  });

  // ── filteredStudyMaterialsProvider tests ─────────────────────────────────────

  // Shared stub materials for provider tests.
  final dateNewer = DateTime(2025, 6);
  final dateOlder = DateTime(2025);

  List<StudyMaterial> stubMaterials() => [
    StudyMaterial(
      id: 'm1',
      title: 'IELTS Grammar',
      description: 'Grammar guide for IELTS',
      exam: StudyMaterialExam.ielts,
      fileUrl: 'https://x.com/1',
      createdAt: dateNewer,
    ),
    StudyMaterial(
      id: 'm2',
      title: 'SAT Math Practice',
      description: 'Practice tests for SAT math',
      exam: StudyMaterialExam.sat,
      major: 'Математика',
      fileUrl: 'https://x.com/2',
      createdAt: dateOlder,
    ),
    StudyMaterial(
      id: 'm3',
      title: 'ЕНТ Биология',
      description: 'Шпаргалки по биологии',
      exam: StudyMaterialExam.ent,
      fileUrl: 'https://x.com/3',
      createdAt: dateNewer,
    ),
  ];

  ProviderContainer containerWithData(List<StudyMaterial> data) {
    return ProviderContainer(
      overrides: [
        studyMaterialsProvider.overrideWith(
          () => _FakeStudyMaterialsNotifier(data),
        ),
      ],
    );
  }

  group('filteredStudyMaterialsProvider unit tests', () {
    test('no filter returns all items sorted newest first by default', () async {
      final container = containerWithData(stubMaterials());
      addTearDown(container.dispose);

      // Await the async notifier so the derived provider sees real data.
      await container.read(studyMaterialsProvider.future);
      final result = container.read(filteredStudyMaterialsProvider);

      // m1 and m3 are newer, m2 is older — both newest should come first
      expect(result.length, 3);
      expect(result.last.id, 'm2');
    });

    test('exam filter narrows to matching items only', () async {
      final container = containerWithData(stubMaterials());
      addTearDown(container.dispose);

      await container.read(studyMaterialsProvider.future);
      container
          .read(studyMaterialsFilterProvider.notifier)
          .setExam(StudyMaterialExam.ielts);

      final result = container.read(filteredStudyMaterialsProvider);
      expect(result.every((m) => m.exam == StudyMaterialExam.ielts), isTrue);
      expect(result.length, 1);
      expect(result.first.id, 'm1');
    });

    test('text search matches title', () async {
      final container = containerWithData(stubMaterials());
      addTearDown(container.dispose);

      await container.read(studyMaterialsProvider.future);
      container.read(studyMaterialsFilterProvider.notifier).setQuery('SAT');

      final result = container.read(filteredStudyMaterialsProvider);
      expect(result.length, 1);
      expect(result.first.id, 'm2');
    });

    test('text search matches description (case-insensitive)', () async {
      final container = containerWithData(stubMaterials());
      addTearDown(container.dispose);

      await container.read(studyMaterialsProvider.future);
      container
          .read(studyMaterialsFilterProvider.notifier)
          .setQuery('шпаргалки');

      final result = container.read(filteredStudyMaterialsProvider);
      expect(result.length, 1);
      expect(result.first.id, 'm3');
    });

    test('major filter narrows to matching major', () async {
      final container = containerWithData(stubMaterials());
      addTearDown(container.dispose);

      await container.read(studyMaterialsProvider.future);
      container
          .read(studyMaterialsFilterProvider.notifier)
          .setMajor('Математика');

      final result = container.read(filteredStudyMaterialsProvider);
      expect(result.length, 1);
      expect(result.first.id, 'm2');
    });

    test('sort oldest first puts oldest item at front', () async {
      final container = containerWithData(stubMaterials());
      addTearDown(container.dispose);

      await container.read(studyMaterialsProvider.future);
      container.read(studyMaterialsFilterProvider.notifier).toggleSort();

      final result = container.read(filteredStudyMaterialsProvider);
      expect(result.first.id, 'm2'); // m2 is the oldest
    });

    test('filter with no matches returns empty list', () async {
      final container = containerWithData(stubMaterials());
      addTearDown(container.dispose);

      await container.read(studyMaterialsProvider.future);
      container
          .read(studyMaterialsFilterProvider.notifier)
          .setQuery('zzz_no_match_zzz');

      final result = container.read(filteredStudyMaterialsProvider);
      expect(result, isEmpty);
    });

    test('studyMaterialMajorsProvider collects unique majors', () async {
      final container = containerWithData(stubMaterials());
      addTearDown(container.dispose);

      await container.read(studyMaterialsProvider.future);
      final majors = container.read(studyMaterialMajorsProvider);
      expect(majors, contains('Математика'));
      expect(majors.length, 1);
    });
  });

  // ── Материалы tab widget tests ────────────────────────────────────────────────

  Widget themedWithMaterials(
    Widget widget,
    List<StudyMaterial> data,
  ) {
    return ProviderScope(
      overrides: [
        studyMaterialsProvider.overrideWith(
          () => _FakeStudyMaterialsNotifier(data),
        ),
      ],
      child: MaterialApp(
        theme: ThemeData(extensions: [AppTokens.defaults()]),
        home: Scaffold(body: widget),
      ),
    );
  }

  group('Материалы tab widget tests', () {
    testWidgets('tab appears in the OpportunitiesScreen header', (
      tester,
    ) async {
      final errors = <FlutterErrorDetails>[];
      final prev = FlutterError.onError;
      FlutterError.onError = errors.add;
      addTearDown(() => FlutterError.onError = prev);

      await tester.pumpWidget(
        themedWithMaterials(const OpportunitiesScreen(), const []),
      );
      await tester.pumpAndSettle();

      expect(find.text('Материалы'), findsOneWidget);
      expect(errors, isEmpty, reason: 'no layout errors on OpportunitiesScreen');
    });

    testWidgets('blank-screen guard: Материалы tab builds without layout errors',
        (tester) async {
      final errors = <FlutterErrorDetails>[];
      final prev = FlutterError.onError;
      FlutterError.onError = errors.add;
      addTearDown(() => FlutterError.onError = prev);

      await tester.pumpWidget(
        themedWithMaterials(const OpportunitiesScreen(), const []),
      );
      await tester.pumpAndSettle();

      await tester.tap(find.text('Материалы'));
      await tester.pumpAndSettle();

      expect(
        errors,
        isEmpty,
        reason: 'no swallowed layout errors on Материалы tab',
      );
    });

    testWidgets('shows "Материалы скоро появятся" when data is empty', (
      tester,
    ) async {
      await tester.pumpWidget(
        themedWithMaterials(const OpportunitiesScreen(), const []),
      );
      await tester.pumpAndSettle();

      await tester.tap(find.text('Материалы'));
      await tester.pumpAndSettle();

      expect(find.text('Материалы скоро появятся'), findsOneWidget);
    });

    testWidgets('shows material cards when data is non-empty', (tester) async {
      await tester.pumpWidget(
        themedWithMaterials(const OpportunitiesScreen(), stubMaterials()),
      );
      await tester.pumpAndSettle();

      await tester.tap(find.text('Материалы'));
      await tester.pumpAndSettle();

      // IELTS Grammar is newest and appears first.
      expect(find.text('IELTS Grammar'), findsOneWidget);
      // Confirm multiple "Скачать" CTAs are present — list is populated.
      expect(find.text('Скачать'), findsWidgets);

      // Scroll down to find the SAT card (may be below the viewport).
      await tester.scrollUntilVisible(
        find.text('SAT Math Practice'),
        100,
        scrollable: find.byType(Scrollable).last,
      );
      expect(find.text('SAT Math Practice'), findsOneWidget);
    });

    testWidgets('exam filter chips are visible on the Материалы tab', (
      tester,
    ) async {
      await tester.pumpWidget(
        themedWithMaterials(const OpportunitiesScreen(), const []),
      );
      await tester.pumpAndSettle();

      await tester.tap(find.text('Материалы'));
      await tester.pumpAndSettle();

      expect(find.text('Все'), findsOneWidget);
      expect(find.text('IELTS'), findsOneWidget);
      expect(find.text('SAT'), findsOneWidget);
      expect(find.text('ЕНТ'), findsOneWidget);
    });

    testWidgets('exam chip filter shows only matching cards', (tester) async {
      final container = ProviderContainer(
        overrides: [
          studyMaterialsProvider.overrideWith(
            () => _FakeStudyMaterialsNotifier(stubMaterials()),
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

      await tester.tap(find.text('Материалы'));
      await tester.pumpAndSettle();

      // Set the filter via the provider notifier (avoids ambiguous text-finder
      // that would match both the chip label and the exam badge on cards).
      container
          .read(studyMaterialsFilterProvider.notifier)
          .setExam(StudyMaterialExam.ielts);
      await tester.pumpAndSettle();

      expect(
        container.read(studyMaterialsFilterProvider).exam,
        StudyMaterialExam.ielts,
      );
      // Only the IELTS Grammar card should be present.
      expect(find.text('IELTS Grammar'), findsOneWidget);
      expect(find.text('SAT Math Practice'), findsNothing);
    });

    testWidgets(
      'shows "Ничего не нашлось" when filter is active but no results',
      (tester) async {
        final container = ProviderContainer(
          overrides: [
            studyMaterialsProvider.overrideWith(
              () => _FakeStudyMaterialsNotifier(stubMaterials()),
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

        await tester.tap(find.text('Материалы'));
        await tester.pumpAndSettle();

        // Search for something that matches nothing
        container
            .read(studyMaterialsFilterProvider.notifier)
            .setQuery('zzz_no_match_zzz');
        await tester.pumpAndSettle();

        expect(find.textContaining('Ничего не нашлось'), findsOneWidget);
      },
    );

    testWidgets('search field filters cards by title', (tester) async {
      final container = ProviderContainer(
        overrides: [
          studyMaterialsProvider.overrideWith(
            () => _FakeStudyMaterialsNotifier(stubMaterials()),
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

      await tester.tap(find.text('Материалы'));
      await tester.pumpAndSettle();

      // Type in the search field
      await tester.enterText(find.byType(TextField), 'Биология');
      await tester.pumpAndSettle();

      expect(find.text('ЕНТ Биология'), findsOneWidget);
      expect(find.text('IELTS Grammar'), findsNothing);
      expect(find.text('SAT Math Practice'), findsNothing);
    });

    testWidgets('sort toggle chip is visible', (tester) async {
      await tester.pumpWidget(
        themedWithMaterials(const OpportunitiesScreen(), const []),
      );
      await tester.pumpAndSettle();

      await tester.tap(find.text('Материалы'));
      await tester.pumpAndSettle();

      expect(find.text('Сначала новые'), findsOneWidget);
    });

    testWidgets(
      'Материалы tab with data builds with NO layout errors (blank-screen guard)',
      (tester) async {
        final errors = <FlutterErrorDetails>[];
        final prev = FlutterError.onError;
        FlutterError.onError = errors.add;
        addTearDown(() => FlutterError.onError = prev);

        await tester.pumpWidget(
          themedWithMaterials(const OpportunitiesScreen(), stubMaterials()),
        );
        await tester.pumpAndSettle();

        await tester.tap(find.text('Материалы'));
        await tester.pumpAndSettle();

        expect(
          errors,
          isEmpty,
          reason: 'no layout errors on Материалы tab with data',
        );
      },
    );
  });
}

// ── Fake study-materials notifier ─────────────────────────────────────────────

class _FakeStudyMaterialsNotifier extends StudyMaterialsNotifier {
  _FakeStudyMaterialsNotifier(this._data);
  final List<StudyMaterial> _data;

  @override
  Future<List<StudyMaterial>> build() async => _data;
}
