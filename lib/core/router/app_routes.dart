/// Centralized route paths and names for go_router.
abstract final class AppRoutes {
  // ── Shell tabs ────────────────────────────────────────────────────────────
  static const String dashboard = '/';
  static const String dashboardName = 'dashboard';

  static const String chances = '/chances';
  static const String chancesName = 'chances';

  static const String learn = '/learn';
  static const String learnName = 'learn';

  static const String eraly = '/eraly';
  static const String eralyName = 'eraly';

  static const String profile = '/profile';
  static const String profileName = 'profile';

  // ── Top-level (full-screen) routes ───────────────────────────────────────
  static const String splash = '/splash';
  static const String splashName = 'splash';

  static const String onboarding = '/onboarding';
  static const String onboardingName = 'onboarding';

  static const String auth = '/auth';
  static const String authName = 'auth';

  static const String careerTest = '/career-test';
  static const String careerTestName = 'careerTest';

  static const String valuesTest = '/values-test';
  static const String valuesTestName = 'valuesTest';

  static const String chancingKz = '/chancing-kz';
  static const String chancingKzName = 'chancingKz';

  static const String chancingWorld = '/chancing-world';
  static const String chancingWorldName = 'chancingWorld';

  static const String universities = '/universities';
  static const String universitiesName = 'universities';

  /// University detail, `:slug`.
  static const String universityDetail = '/university/:slug';
  static const String universityDetailName = 'universityDetail';

  static const String scholarships = '/scholarships';
  static const String scholarshipsName = 'scholarships';

  static const String collegeList = '/college-list';
  static const String collegeListName = 'collegeList';

  static const String gap = '/gap';
  static const String gapName = 'gap';

  static const String projects = '/projects';
  static const String projectsName = 'projects';

  static const String notes = '/notes';
  static const String notesName = 'notes';

  static const String essay = '/essay';
  static const String essayName = 'essay';

  static const String design = '/design';
  static const String designName = 'design';

  static const String calendar = '/calendar';
  static const String calendarName = 'calendar';

  static const String gpa = '/gpa';
  static const String gpaName = 'gpa';

  // ── Mini-games ───────────────────────────────────────────────────────────
  static const String wordleGame = '/games/wordle';
  static const String wordleGameName = 'wordleGame';

  static const String guessUni = '/games/guess-uni';
  static const String guessUniName = 'guessUni';

  /// Intensive track detail, `:slug`.
  static const String intensive = '/intensive/:slug';
  static const String intensiveName = 'intensive';

  /// Intensive day detail, `:slug` + `:day`.
  static const String intensiveDay = '/intensive/:slug/day/:day';
  static const String intensiveDayName = 'intensiveDay';
}
