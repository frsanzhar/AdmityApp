import 'package:admity/features/scholarships/domain/scholarship_matcher.dart';
import 'package:admity/features/scholarships/domain/scholarship_models.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  const chevening = Scholarship(
    slug: 'chevening',
    name: 'Chevening',
    country: 'UK',
    levels: {StudyLevel.master},
    covers: ['обучение', 'стипендия'],
    deadline: 'ноябрь',
    eligibility: '~2 года опыта',
    sourceUrl: 'https://chevening.org',
    requiresWorkYears: 2,
  );
  const bolashak = Scholarship(
    slug: 'bolashak',
    name: 'Болашак',
    country: 'KZ',
    levels: {StudyLevel.master, StudyLevel.phd, StudyLevel.exchange},
    covers: ['обучение'],
    deadline: 'март–октябрь',
    eligibility: 'приглашение из списка',
    sourceUrl: 'https://bolashak.gov.kz',
    note: 'Бакалавриат пока не возвращён',
  );
  const gks = Scholarship(
    slug: 'gks',
    name: 'Global Korea Scholarship',
    country: 'Korea',
    levels: {StudyLevel.bachelor},
    covers: ['обучение', 'стипендия', 'год языка'],
    deadline: 'сен–окт',
    eligibility: 'GPA ≥ 80%',
    sourceUrl: 'https://studyinkorea.go.kr',
    ageMax: 24, // rule is "возраст <25" → max allowed age is 24
  );

  const schoolStudent = EligibilityContext(ageYears: 17);

  test('Chevening is filtered out for a school student', () {
    final m = ScholarshipMatcher.match([chevening], schoolStudent).single;
    expect(m.eligible, isFalse);
    expect(m.reasons.any((r) => r.contains('опыт')), isTrue);
  });

  test('Bolashak is ineligible for bachelor and surfaces the caveat', () {
    final m = ScholarshipMatcher.match([bolashak], schoolStudent).single;
    expect(m.eligible, isFalse);
    expect(m.reasons.any((r) => r.contains('не возвращён')), isTrue);
  });

  test('GKS fits a 17-year-old bachelor applicant', () {
    final m = ScholarshipMatcher.match([gks], schoolStudent).single;
    expect(m.eligible, isTrue);
    expect(m.reasons.first, contains('Покрывает'));
  });

  test('a 25-year-old is excluded from GKS (rule is age < 25)', () {
    const olderStudent = EligibilityContext(ageYears: 25);
    final m = ScholarshipMatcher.match([gks], olderStudent).single;
    expect(m.eligible, isFalse);
    expect(m.reasons.any((r) => r.contains('Возраст')), isTrue);
  });

  test('eligible programs do not show a blocker-only caveat', () {
    // Bolashak fits a master applicant; its bachelor caveat must NOT appear.
    const masterApplicant = EligibilityContext(intendedLevel: StudyLevel.master);
    final m = ScholarshipMatcher.match([bolashak], masterApplicant).single;
    expect(m.eligible, isTrue);
    expect(m.reasons.any((r) => r.contains('не возвращён')), isFalse);
  });

  test('eligible matches sort before ineligible ones', () {
    final matches = ScholarshipMatcher.match(
      [chevening, gks, bolashak],
      schoolStudent,
    );
    expect(matches.first.eligible, isTrue);
    expect(matches.last.eligible, isFalse);
  });
}
