import 'package:admity/core/theme/app_tokens.dart';
import 'package:admity/features/universities/data/university_catalog_providers.dart';
import 'package:admity/features/universities/domain/university_catalog.dart';
import 'package:admity/features/universities/presentation/university_catalog_detail_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

// ── Fake catalog with one fully-populated university ─────────────────────────
const _fakeCatalog = UniversityCatalog(
  universities: [
    UniversityRecord(
      id: 'nu',
      nameRu: 'Назарбаев Университет',
      city: 'Астана',
      type: UniversityType.autonomous,
      nameEn: 'Nazarbayev University',
      website: 'nu.edu.kz',
      hasDormitory: true,
      description: 'Исследовательский университет в Астане.',
      sourceUrl: 'https://nu.edu.kz',
    ),
    UniversityRecord(
      id: 'kaznu',
      nameRu: 'КазНУ им. аль-Фараби',
      city: 'Алматы',
      type: UniversityType.national,
    ),
  ],
  programs: [
    EducationProgram(
      code: 'B057',
      nameRu: 'Информационные технологии',
      field: 'informatics',
      entSubject1: 'Математика',
      entSubject2: 'Физика',
    ),
  ],
  offerings: [
    UniversityProgram(
      universityId: 'nu',
      programCode: 'B057',
      tuitionPerYearKzt: 1200000,
      languages: ['en'],
      grantPlaces: 40,
    ),
  ],
  thresholds: [
    GrantThreshold(
      programCode: 'B057',
      universityId: 'nu',
      year: 2024,
      quotaType: QuotaType.general,
      metric: GrantMetric.competitionMin,
      minScore: 120,
      isVerified: true,
      sourceUrl: 'https://testsource.kz',
    ),
  ],
);

// ignore: specify_nonobvious_property_types, the Override type is not exported.
final _overrides = [
  universityCatalogProvider.overrideWith((ref) => _fakeCatalog),
];

Widget _app(String id) {
  return ProviderScope(
    overrides: _overrides,
    child: MaterialApp(
      theme: ThemeData(extensions: [AppTokens.defaults()]),
      home: UniversityCatalogDetailScreen(universityId: id),
    ),
  );
}

void main() {
  group('UniversityCatalogDetailScreen — blank-screen guard', () {
    testWidgets('builds with NO framework/layout errors', (tester) async {
      final errors = <FlutterErrorDetails>[];
      final prev = FlutterError.onError;
      FlutterError.onError = errors.add;
      addTearDown(() => FlutterError.onError = prev);

      await tester.pumpWidget(_app('nu'));
      await tester.pumpAndSettle();

      expect(errors, isEmpty, reason: 'no swallowed layout errors');
    });
  });

  group('UniversityCatalogDetailScreen — content', () {
    testWidgets('shows hero name, stats, and program', (tester) async {
      await tester.pumpWidget(_app('nu'));
      await tester.pumpAndSettle();

      expect(find.text('Назарбаев Университет'), findsOneWidget);
      // Stat labels.
      expect(find.text('программ'), findsOneWidget);
      expect(find.textContaining('конкурс от'), findsOneWidget);
      // Program is listed.
      expect(find.text('Информационные технологии'), findsOneWidget);
      // Honest competition figure, not a проходной балл.
      expect(find.textContaining('Конкурс от 120'), findsOneWidget);
    });

    testWidgets('tapping a program expands its details', (tester) async {
      await tester.pumpWidget(_app('nu'));
      await tester.pumpAndSettle();

      // Collapsed: tuition fact not yet shown.
      expect(find.textContaining('Стоимость в год'), findsNothing);

      final program = find.text('Информационные технологии');
      await tester.ensureVisible(program);
      await tester.pumpAndSettle();
      await tester.tap(program);
      await tester.pumpAndSettle();

      expect(find.textContaining('Стоимость в год'), findsOneWidget);
      expect(find.textContaining('Грантовых мест'), findsOneWidget);
    });

    testWidgets('unknown id shows fallback message', (tester) async {
      await tester.pumpWidget(_app('does-not-exist'));
      await tester.pumpAndSettle();

      expect(find.text('Вуз не найден'), findsOneWidget);
    });
  });

  group('UniversityCatalogDetailScreen — action buttons', () {
    testWidgets('"Мои шансы" button is visible', (tester) async {
      await tester.pumpWidget(_app('nu'));
      await tester.pumpAndSettle();

      expect(find.text('Мои шансы'), findsOneWidget);
    });

    testWidgets('"Документы" button is visible', (tester) async {
      await tester.pumpWidget(_app('nu'));
      await tester.pumpAndSettle();

      expect(find.text('Документы'), findsOneWidget);
    });

    testWidgets(
      'tapping "Документы" opens the document checklist sheet',
      (tester) async {
        await tester.pumpWidget(_app('nu'));
        await tester.pumpAndSettle();

        final btn = find.text('Документы');
        await tester.ensureVisible(btn);
        await tester.tap(btn);
        await tester.pumpAndSettle();

        // The sheet title should be visible immediately.
        expect(
          find.textContaining('Документы для поступления'),
          findsOneWidget,
        );

        // Scroll the sheet to reveal the Qabylday button at the bottom.
        await tester.scrollUntilVisible(
          find.textContaining('Qabylday'),
          100,
          scrollable: find.byType(Scrollable).last,
        );
        expect(find.textContaining('Qabylday'), findsOneWidget);
      },
    );

    testWidgets(
      'tapping "Мои шансы" opens the chances sheet',
      (tester) async {
        await tester.pumpWidget(_app('nu'));
        await tester.pumpAndSettle();

        final btn = find.text('Мои шансы');
        await tester.ensureVisible(btn);
        await tester.tap(btn);
        await tester.pumpAndSettle();

        // The sheet shows the title and evaluate button.
        expect(find.textContaining('Мои шансы'), findsWidgets);
        expect(find.text('Оценить шансы'), findsOneWidget);
      },
    );

    testWidgets(
      '"Оценить шансы" with ENT score shows local evaluation',
      (tester) async {
        await tester.pumpWidget(_app('nu'));
        await tester.pumpAndSettle();

        // Open chances sheet.
        final btn = find.text('Мои шансы');
        await tester.ensureVisible(btn);
        await tester.tap(btn);
        await tester.pumpAndSettle();

        // Enter ENT score.
        final entField = find.byType(TextField);
        await tester.enterText(entField, '105');

        // Evaluate (no Supabase configured in tests → local evaluation).
        await tester.tap(find.text('Оценить шансы'));
        await tester.pumpAndSettle();

        // Local evaluation should produce an honest result.
        // Score 105 < min 120 → "ниже минимума" path expected.
        expect(find.textContaining('Оценка'), findsOneWidget);
      },
    );
  });

  group('UniversityCatalogDetailScreen — document checklist content', () {
    testWidgets(
      'document sheet shows standard admission documents',
      (tester) async {
        await tester.pumpWidget(_app('nu'));
        await tester.pumpAndSettle();

        await tester.tap(find.text('Документы'));
        await tester.pumpAndSettle();

        // Scroll the sheet to find key standard documents.
        expect(
          find.textContaining('Аттестат'),
          findsWidgets,
        );
        expect(
          find.textContaining('Удостоверение'),
          findsWidgets,
        );
      },
    );
  });
}
