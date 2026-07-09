// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'Admity';

  @override
  String get languageSectionTitle => 'App language';

  @override
  String get languageSystem => 'System default';

  @override
  String get languageRussian => 'Русский';

  @override
  String get languageKazakh => 'Қазақша';

  @override
  String get languageEnglish => 'English';

  @override
  String get authWelcomeTitle => 'Welcome';

  @override
  String get authCreateAccountTitle => 'Create account';

  @override
  String get authSignInSubtitle => 'Sign in to continue';

  @override
  String get authSignUpSubtitle => 'Enter your details to get started';

  @override
  String get authEmailLabel => 'Email';

  @override
  String get authPasswordLabel => 'Password';

  @override
  String get authEmailRequired => 'Enter your email';

  @override
  String get authEmailInvalid => 'Invalid email';

  @override
  String get authPasswordRequired => 'Enter your password';

  @override
  String get authPasswordMinLength => 'At least 6 characters';

  @override
  String get authSignInButton => 'Sign in';

  @override
  String get authSignUpButton => 'Sign up';

  @override
  String get authAlreadyHaveAccount => 'Already have an account? Sign in';

  @override
  String get authNoAccount => 'No account? Sign up';

  @override
  String get authOrDivider => 'or';

  @override
  String get authContinueWithGoogle => 'Continue with Google';

  @override
  String get authContinueWithApple => 'Continue with Apple';

  @override
  String get authContinueAsGuest => 'Continue as guest';

  @override
  String get authErrorSignIn =>
      'Could not sign in. Check your connection and try again.';

  @override
  String get authErrorCreateAccount =>
      'Could not create account. Check your connection and try again.';

  @override
  String get authErrorGoogleNotConfigured =>
      'Google sign-in is not configured yet. Add GOOGLE_WEB_CLIENT_ID.';

  @override
  String get authErrorCancelled => 'Sign-in cancelled.';

  @override
  String get authErrorGoogleTokenFailed =>
      'Could not get Google token. Try again.';

  @override
  String get authErrorGoogleSignIn =>
      'Could not sign in with Google. Try again.';

  @override
  String get authErrorAppleTokenFailed =>
      'Could not get Apple token. Try again.';

  @override
  String get authErrorAppleSignIn => 'Could not sign in with Apple. Try again.';

  @override
  String authErrorAppleRaw(String message) {
    return 'Apple Sign In: $message';
  }

  @override
  String get authErrorGuestFailed => 'Could not create guest profile.';

  @override
  String get authErrorInvalidCredentials => 'Incorrect email or password.';

  @override
  String get authErrorEmailNotConfirmed =>
      'Please confirm your email via the link we sent you.';

  @override
  String get authErrorEmailAlreadyRegistered =>
      'This email is already registered. Try signing in.';

  @override
  String get authErrorPasswordTooShort =>
      'Password must be at least 6 characters.';

  @override
  String get authErrorRateLimit =>
      'Too many attempts. Wait a moment and try again.';

  @override
  String get homeGreeting => 'Hi!';

  @override
  String get homeGreetingSubtitle => 'Ready to learn something new?';

  @override
  String homeStreakSemanticLabel(int count, String dayWord) {
    return 'Streak: $count $dayWord';
  }

  @override
  String get homeStreakStart => 'Start your streak!';

  @override
  String homeStreakActive(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count days',
      one: '$count day',
    );
    return 'Streak — $_temp0';
  }

  @override
  String get homeStreakDayDone => 'Day complete!';

  @override
  String get homeStreakDayNotDone => 'Not yet complete';

  @override
  String homeStreakWeekSummary(int count) {
    return '$count of 7 days this week';
  }

  @override
  String get homeWeekdayMon => 'Mo';

  @override
  String get homeWeekdayTue => 'Tu';

  @override
  String get homeWeekdayWed => 'We';

  @override
  String get homeWeekdayThu => 'Th';

  @override
  String get homeWeekdayFri => 'Fr';

  @override
  String get homeWeekdaySat => 'Sa';

  @override
  String get homeWeekdaySun => 'Su';

  @override
  String get homeCalendarMonthJan => 'January';

  @override
  String get homeCalendarMonthFeb => 'February';

  @override
  String get homeCalendarMonthMar => 'March';

  @override
  String get homeCalendarMonthApr => 'April';

  @override
  String get homeCalendarMonthMay => 'May';

  @override
  String get homeCalendarMonthJun => 'June';

  @override
  String get homeCalendarMonthJul => 'July';

  @override
  String get homeCalendarMonthAug => 'August';

  @override
  String get homeCalendarMonthSep => 'September';

  @override
  String get homeCalendarMonthOct => 'October';

  @override
  String get homeCalendarMonthNov => 'November';

  @override
  String get homeCalendarMonthDec => 'December';

  @override
  String get homeCalendarAgendaMonthGenJan => 'January';

  @override
  String get homeCalendarAgendaMonthGenFeb => 'February';

  @override
  String get homeCalendarAgendaMonthGenMar => 'March';

  @override
  String get homeCalendarAgendaMonthGenApr => 'April';

  @override
  String get homeCalendarAgendaMonthGenMay => 'May';

  @override
  String get homeCalendarAgendaMonthGenJun => 'June';

  @override
  String get homeCalendarAgendaMonthGenJul => 'July';

  @override
  String get homeCalendarAgendaMonthGenAug => 'August';

  @override
  String get homeCalendarAgendaMonthGenSep => 'September';

  @override
  String get homeCalendarAgendaMonthGenOct => 'October';

  @override
  String get homeCalendarAgendaMonthGenNov => 'November';

  @override
  String get homeCalendarAgendaMonthGenDec => 'December';

  @override
  String get homeCalendarWeekdayFullMon => 'Monday';

  @override
  String get homeCalendarWeekdayFullTue => 'Tuesday';

  @override
  String get homeCalendarWeekdayFullWed => 'Wednesday';

  @override
  String get homeCalendarWeekdayFullThu => 'Thursday';

  @override
  String get homeCalendarWeekdayFullFri => 'Friday';

  @override
  String get homeCalendarWeekdayFullSat => 'Saturday';

  @override
  String get homeCalendarWeekdayFullSun => 'Sunday';

  @override
  String get homeCalendarNoEvents => 'No events. Add your first one!';

  @override
  String get homeCalendarEralyBadge => 'Eraly';

  @override
  String get homeCalendarAddEvent => 'Add event';

  @override
  String get homeEventSheetTitleNew => 'New event';

  @override
  String get homeEventSheetTitleEdit => 'Edit event';

  @override
  String get homeEventSheetFieldTitleLabel => 'Title';

  @override
  String get homeEventSheetFieldTitleHint => 'What\'s planned?';

  @override
  String get homeEventSheetFieldDescLabel => 'Description';

  @override
  String get homeEventSheetFieldDescHint => 'Details (optional)';

  @override
  String get homeEventSheetSave => 'Save';

  @override
  String get homeEventSheetDelete => 'Delete event';

  @override
  String get homeTodayTaskTitle => 'Today\'s task';

  @override
  String get homeTodayTaskBody =>
      'Lesson: Comparing probabilities — continue from where you left off.';

  @override
  String get homeTodayTaskContinue => 'Continue';

  @override
  String get homeTaskListTitle => 'Today\'s tasks';

  @override
  String get homeTaskListEmpty => 'No tasks. Tap + to add one.';

  @override
  String get homeTaskSheetTitleNew => 'New task';

  @override
  String get homeTaskSheetTitleEdit => 'Edit';

  @override
  String get homeTaskSheetFieldTitleLabel => 'Title';

  @override
  String get homeTaskSheetFieldTitleHint => 'What needs to be done?';

  @override
  String get homeTaskSheetFieldDescLabel => 'Description';

  @override
  String get homeTaskSheetFieldDescHint => 'Details (optional)';

  @override
  String get homeTaskSheetNoDescription => 'No description added.';

  @override
  String get homeTaskSheetSave => 'Save';

  @override
  String get homeTaskSheetDelete => 'Delete task';

  @override
  String get homeDefaultTodo1Title => 'Complete the math lesson';

  @override
  String get homeDefaultTodo1Desc =>
      'Section \"Comparing probabilities\" — about 15 minutes.';

  @override
  String get homeDefaultTodo2Title => 'Research BOLASHAK scholarships';

  @override
  String get homeDefaultTodo2Desc =>
      'Check admission requirements and the application deadline.';

  @override
  String get homeDefaultTodo3Title => 'Update profile';

  @override
  String get homeDefaultTodo3Desc =>
      'Add latest grades and upload current documents.';

  @override
  String get homeDefaultTodo4Title => 'Read about UNT requirements';

  @override
  String get homeDefaultTodo4Desc =>
      'Minimum scores per subject required for admission.';

  @override
  String get homeCareerCardTitle => 'Discover your career';

  @override
  String get homeCareerCardSubtitle => 'Daily test — 3 minutes';

  @override
  String get homeCareerCardButton => 'Take the test';

  @override
  String get eralyName => 'Eraly';

  @override
  String get eralySubtitle => 'AI mentor';

  @override
  String get eralyTypingText => 'Eraly is thinking...';

  @override
  String get eralyReviewEventsButton => 'Review all events';

  @override
  String get eralyOpenPlanButton => 'Open plan';

  @override
  String get eralyToneStrictLabel => 'Strict\nmentor';

  @override
  String get eralyToneStrictDescription => 'Direct and to the point';

  @override
  String get eralyToneFriendlyLabel => 'Friendly\nmentor';

  @override
  String get eralyToneFriendlyDescription => 'Warm and supportive';

  @override
  String get eralyInputHint => 'Message Eraly...';

  @override
  String get eralyTonePrompt =>
      'Hi! I\'m Eraly — your AI admission mentor. Before we start, choose how you\'d like me to communicate with you:';

  @override
  String get eralyGreetingStrict =>
      'Good. We work seriously: set goals, stay disciplined, and cut the noise. Tell me — where are you applying and what have you done so far?';

  @override
  String get eralyGreetingFriendly =>
      'Awesome! I\'m right here — I\'ll support you every step of the way. Tell me about yourself: where do you want to study and where shall we start?';

  @override
  String eralyEventsProposedAnnounce(int count) {
    return 'I\'ve prepared $count events. Tap «Review all events» to check and adjust the timing.';
  }

  @override
  String get eralyEventsProposeLoading =>
      'Great! Give me a second — I\'ll suggest a few events...';

  @override
  String get eralyEventsSaved =>
      'All events saved to the calendar! You can find them in «Home». What else can I help you with?';

  @override
  String get eralyPlanGenerating => 'Building your plan — one second...';

  @override
  String eralyPlanReady(String topic, int lessonCount) {
    return 'Done! I\'ve built a «$topic» plan with $lessonCount lessons. Scroll down to see it. If you want changes — just ask!';
  }

  @override
  String get eralyQuestionResources =>
      'Great, let\'s start! What study materials do you have? (books, online courses, apps — list what you\'ve got)';

  @override
  String get eralyQuestionTime =>
      'Got it. How much time per week can you dedicate to preparation? (e.g. «2 hours a day» or «10 hours a week»)';

  @override
  String get eralyQuestionInternet =>
      'Do you have stable internet access for online resources? (yes / no)';

  @override
  String get eralyOfflineIeltsStrict =>
      'IELTS. First tell me: what materials do you already have? You can\'t build a plan without a clear inventory.';

  @override
  String get eralyOfflineIeltsFriendly =>
      'IELTS — great goal! Let\'s build a personalised plan. To start: what materials do you already have? (textbooks, apps, courses — list them all)';

  @override
  String get eralyOfflineSatStrict =>
      'SAT demands systematic work. What resources are you using? Be specific.';

  @override
  String get eralyOfflineSatFriendly =>
      'SAT — a serious step! I\'ll help break preparation into clear lessons. Tell me, what resources are you using?';

  @override
  String get eralyOfflineEntStrict =>
      'UNT — the main exam. How many weeks until it? Give me the exact date — we\'ll build a tight plan.';

  @override
  String get eralyOfflineEntFriendly =>
      'UNT — the key exam. Want to build a lesson-by-lesson plan? Write how much time you have before the exam.';

  @override
  String get eralyOfflinePlanStrict =>
      'Name the topic or exam. Then I\'ll ask three questions — and build a plan, no fluff.';

  @override
  String get eralyOfflinePlanFriendly =>
      'Of course, I\'ll help you build a plan! Name the topic or exam, and I\'ll ask a few questions to tailor it to you.';

  @override
  String get eralyOfflineEventsStrict =>
      'Tell me the event topic. I\'ll suggest specific dates — you review and confirm.';

  @override
  String get eralyOfflineEventsFriendly =>
      'Happy to help! Write the topic or goal of the events — I\'ll suggest a few specific dates and can add them to your calendar.';

  @override
  String get eralyOfflineScholarshipStrict =>
      'Scholarships: Kazakhstani or international? Answer briefly — I\'ll match options to your profile.';

  @override
  String get eralyOfflineScholarshipFriendly =>
      'Scholarships — my favourite topic! Tell me: are you looking at Kazakhstani programmes or international ones? That\'ll help me find the best match.';

  @override
  String get eralyOfflineUniversityStrict =>
      'Specifically: which country and university are you targeting? The more precise, the more useful the analysis.';

  @override
  String get eralyOfflineUniversityFriendly =>
      'Applying is a big step, and I\'m right here. Which country or university are you targeting? Or are you still exploring options?';

  @override
  String get eralyOfflineGreetingStrict =>
      'Let\'s begin. Where are you applying and what have you done? Specifics are the foundation.';

  @override
  String get eralyOfflineGreetingFriendly =>
      'Hi! Tell me a bit about yourself — where do you want to study, what have you tried so far? The more you share, the better I can help.';

  @override
  String get eralyOfflineFollowUpStrict1 =>
      'Clarify the task: exam, admission, or something else? Keep it short.';

  @override
  String get eralyOfflineFollowUpStrict2 =>
      'Got it. Be more specific — is this for UNT, an international exam, or a university?';

  @override
  String get eralyOfflineFollowUpStrict3 =>
      'Good. What exactly do you need — a plan, chances analysis, or a list of scholarships?';

  @override
  String get eralyOfflineFollowUpFriendly1 =>
      'Interesting! Tell me more — I want to understand exactly how I can help.';

  @override
  String get eralyOfflineFollowUpFriendly2 =>
      'Good question. Please clarify: are you asking about exams, admission, or something else?';

  @override
  String get eralyOfflineFollowUpFriendly3 =>
      'Got it. To give a precise answer, tell me: is this for UNT, an international exam, or something else?';

  @override
  String eralyOfflineEventTitle1(String topic) {
    return 'Kickoff: $topic';
  }

  @override
  String get eralyOfflineEventDescription1 =>
      'First introduction to the topic — study the key concepts and make a list of questions.';

  @override
  String eralyOfflineEventTitle2(String topic) {
    return 'Practice: $topic';
  }

  @override
  String get eralyOfflineEventDescription2 =>
      'Practice session — solve 10–15 problems or take a practice test.';

  @override
  String eralyOfflineEventTitle3(String topic) {
    return 'Review: $topic';
  }

  @override
  String get eralyOfflineEventDescription3 =>
      'Final review — consolidate weak areas and check your progress.';

  @override
  String get eralyOfflinePlanNotes =>
      'Basic offline plan. Connect to the internet so Eraly can build a plan tailored to your materials and schedule.';

  @override
  String eralyOfflinePlanLesson1Title(String topic) {
    return 'Introduction to $topic';
  }

  @override
  String eralyOfflinePlanLesson2Title(String topic) {
    return 'Key concepts of $topic';
  }

  @override
  String get eralyOfflinePlanLesson3Title => 'Practical exercises';

  @override
  String get eralyOfflinePlanLesson4Title =>
      'Analysing mistakes and weak areas';

  @override
  String get eralyOfflinePlanLesson5Title => 'Practice test and final review';

  @override
  String eralyParsedEventFallbackTitle(int number) {
    return 'Event $number';
  }

  @override
  String eralyParsedLessonFallbackTitle(int number) {
    return 'Lesson $number';
  }

  @override
  String get onbIntro =>
      'Getting into university is a big step. Admity will help you take it with confidence.';

  @override
  String get onbWhoAreYou => 'Who are you?';

  @override
  String get onbRoleStudentLabel => 'I\'m a student';

  @override
  String get onbRoleStudentDesc => 'Preparing for university admission';

  @override
  String get onbRoleParentLabel => 'Parent';

  @override
  String get onbRoleParentDesc => 'Helping my child get into university';

  @override
  String get onbRoleTeacherLabel => 'Teacher';

  @override
  String get onbRoleTeacherDesc => 'Preparing students for university';

  @override
  String get onbNextButton => 'Next';

  @override
  String get onbMascotGreetingName => 'Hi! I\'m Eraly,';

  @override
  String get onbMascotGreetingDesc =>
      'your personal admissions mentor. I\'ll tell you everything you need to know and help you not miss a single opportunity.';

  @override
  String get onbMotivationTitle => 'What is your goal?';

  @override
  String get onbMotivationSubtitle =>
      'This will help us find the right path for you';

  @override
  String get onbMotivationTopKzLabel => 'Get into a top Kazakhstan university';

  @override
  String get onbMotivationTopKzDesc => 'NU, KBTU, KazNU and others';

  @override
  String get onbMotivationAbroadLabel => 'Get into a university abroad';

  @override
  String get onbMotivationAbroadDesc => 'USA, Europe, Asia and other countries';

  @override
  String get onbMotivationExploreLabel => 'Career exploration';

  @override
  String get onbMotivationExploreDesc => 'Still choosing a direction';

  @override
  String get onbAgeTitle => 'How old are you?';

  @override
  String get onbAgeSubtitle => 'Helps us tailor content to your age.';

  @override
  String get onbAgeHint => '16';

  @override
  String get onbSubjectTitle => 'Which subjects interest you as a major?';

  @override
  String get onbSubjectSubtitle => 'You can choose several';

  @override
  String get onbSubjectPsychologyLabel => 'Psychology';

  @override
  String get onbSubjectPsychologyDesc => 'Behavior and the mind';

  @override
  String get onbSubjectPoliticsLabel => 'Political Science';

  @override
  String get onbSubjectPoliticsDesc => 'Political science and diplomacy';

  @override
  String get onbSubjectEconomicsLabel => 'Economics';

  @override
  String get onbSubjectEconomicsDesc => 'Finance and business';

  @override
  String get onbSubjectChemistryLabel => 'Chemistry';

  @override
  String get onbSubjectChemistryDesc => 'Reactions and substances';

  @override
  String get onbSubjectBiologyLabel => 'Biology';

  @override
  String get onbSubjectBiologyDesc => 'Life and medicine';

  @override
  String get onbSubjectPhysicsLabel => 'Physics';

  @override
  String get onbSubjectPhysicsDesc => 'Mechanics and quantum physics';

  @override
  String get onbSubjectMathLabel => 'Mathematics';

  @override
  String get onbSubjectMathDesc => 'Algebra and calculus';

  @override
  String get onbTrustTitle => 'Built with experts from leading universities';

  @override
  String get onbTrustSubtitle =>
      'Content developed with the involvement of methodologists from Kazakhstan universities and international partners.';

  @override
  String get onbConfidenceTitle => 'How confident are you that you\'ll get in?';

  @override
  String get onbConfidenceSubtitle =>
      'An honest answer will help us build the right plan';

  @override
  String get onbConfidence100Label => '100% confident';

  @override
  String get onbConfidence100Desc => 'I know I\'ll get in';

  @override
  String get onbConfidenceMostlyYesLabel => 'Most likely yes';

  @override
  String get onbConfidenceMostlyYesDesc => 'Good chance of getting in';

  @override
  String get onbConfidenceNotSureLabel => 'Not sure yet';

  @override
  String get onbConfidenceNotSureDesc => 'Need more preparation';

  @override
  String get onbConfidenceJustStartingLabel => 'Just getting started';

  @override
  String get onbConfidenceJustStartingDesc =>
      'Haven\'t figured out my goals yet';

  @override
  String get onbStatsTitle => 'Your academic scores';

  @override
  String get onbStatsSubtitle =>
      'Optional — you can skip this. It\'s needed for an honest assessment of your chances.';

  @override
  String get onbStatsGpaLabel => 'GPA / Average grade';

  @override
  String get onbStatsGpaHint => 'e.g. 4.8';

  @override
  String get onbStatsIeltsLabel => 'IELTS (if you have it)';

  @override
  String get onbStatsIeltsHint => 'e.g. 7.0';

  @override
  String get onbStatsSatLabel => 'SAT (if you have it)';

  @override
  String get onbStatsSatHint => 'e.g. 1400';

  @override
  String get onbTopicUniverseTitle => 'Everything you need — right here';

  @override
  String get onbTopicUniverseMascotCaption => 'I know where to start';

  @override
  String get onbGoalTitle => 'How much time per day?';

  @override
  String get onbGoalMinUnit => 'min';

  @override
  String get onbGoal10Subtitle => 'A little, but every day';

  @override
  String get onbGoal20Subtitle => 'Steady progress';

  @override
  String get onbGoal30Subtitle => 'Good pace';

  @override
  String get onbGoal60Subtitle => 'Deep dive';

  @override
  String get onbScheduleTitle => 'When is it convenient?';

  @override
  String get onbScheduleMorningLabel => 'Morning';

  @override
  String get onbScheduleMorningSubtitle => 'Before the day begins';

  @override
  String get onbScheduleDayLabel => 'Daytime';

  @override
  String get onbScheduleDaySubtitle => 'In free time';

  @override
  String get onbScheduleEveningLabel => 'Evening';

  @override
  String get onbScheduleEveningSubtitle => 'After school';

  @override
  String get onbScheduleFlexLabel => 'Whenever I can';

  @override
  String get onbScheduleFlexSubtitle => 'Flexible schedule';

  @override
  String get onbNotificationsTitle => 'Reminders';

  @override
  String get onbNotificationsBody =>
      'Would you like Admity to remind you about your study sessions?';

  @override
  String get onbNotificationsEnableButton => 'Enable';

  @override
  String get onbNotificationsSkipButton => 'Skip';

  @override
  String get onbThreeStepTitle => 'Your three-step plan';

  @override
  String get onbPlanStep1Title => 'Learn the basics';

  @override
  String get onbPlanStep1Desc =>
      'We\'ll cover the fundamentals of your subject';

  @override
  String get onbPlanStep2Title => 'Practice';

  @override
  String get onbPlanStep2Desc => 'Problems, tests, and error analysis';

  @override
  String get onbPlanStep3Title => 'Test yourself';

  @override
  String get onbPlanStep3Desc => 'Final skill check and results analysis';

  @override
  String get onbCreatePlanButton => 'Create my plan';

  @override
  String get onbPlanCreationTitle => 'Creating your plan…';

  @override
  String get onbPlanCreationCard1 => 'Analysing your profile';

  @override
  String get onbPlanCreationCard2 => 'Selecting universities and programmes';

  @override
  String get onbPlanCreationCard3 => 'Building your personalised path';

  @override
  String get onbPlanCreationAlmost => 'Almost ready…';

  @override
  String get onbFinishTitle => 'All set!';

  @override
  String get onbFinishSubtitle =>
      'Your personalised plan is ready. Shall we begin?';

  @override
  String get onbFinishStartButton => 'Start';

  @override
  String get onbReminderTitle => 'Time to study with Admity 🎓';

  @override
  String onbReminderBody(int minutes) {
    return 'Spend $minutes min on your university prep — you\'re on the right track!';
  }

  @override
  String onbStudyPlanCareerTest(String major) {
    return 'Take a career aptitude test to confirm your interest in $major';
  }

  @override
  String get onbStudyPlanUpdateProfile =>
      'Make sure your profile — UNT score, GPA, grades — is current and accurate';

  @override
  String onbStudyPlanExploreRequirements(String major) {
    return 'Research the entry requirements and passing scores for $major';
  }

  @override
  String get onbStudyPlanTargetList =>
      'Make a list of target universities (Kazakhstan and/or abroad) with deadlines';

  @override
  String onbStudyPlanDailyTime(String timeLabel) {
    return 'Set aside daily $timeLabel preparation time and stick to your schedule';
  }

  @override
  String get onbStudyPlanPracticeTests =>
      'Practice UNT test questions / international exams in your chosen subjects';

  @override
  String get onbStudyPlanIntlDocs =>
      'Prepare documents for international applications: essays, recommendations, language certificates';

  @override
  String get onbStudyPlanLocalDocs =>
      'Gather your document package: school certificate, transcript, recommendation letters';

  @override
  String get onbStudyPlanTimeMorning => 'in the morning';

  @override
  String get onbStudyPlanTimeDay => 'in the afternoon';

  @override
  String get onbStudyPlanTimeEvening => 'in the evening';

  @override
  String get onbStudyPlanTimeFlex => 'at a convenient time';

  @override
  String get onbStudyPlanDefaultMajor => 'your chosen field';

  @override
  String get oppScreenTitle => 'Opportunities';

  @override
  String get oppTabScholarships => 'Scholarships';

  @override
  String get oppTabEvents => 'Events';

  @override
  String get oppTabProjectIdeas => 'Project Ideas';

  @override
  String get oppFilterCityDefault => 'City';

  @override
  String get oppFilterFieldDefault => 'Field';

  @override
  String get oppFilterAccessibilityDefault => 'Accessibility';

  @override
  String get oppFilterReset => 'Reset';

  @override
  String get oppFilterResetAll => 'Reset filter';

  @override
  String get oppPickerCityTitle => 'Select city';

  @override
  String get oppPickerFieldTitle => 'Select field';

  @override
  String get oppPickerAccessibilityTitle => 'Select accessibility';

  @override
  String get oppCardMoreDetails => 'Learn more';

  @override
  String get oppScholarshipsEmpty =>
      'No scholarships match the selected filters';

  @override
  String oppEventsBannerNearby(String city) {
    return 'near you — $city';
  }

  @override
  String get oppEventsBannerSetCity =>
      'Set your city in your profile to see nearby events';

  @override
  String get oppEventLocalBadge => 'Nearby';

  @override
  String oppIdeasBannerInterest(String interest) {
    return 'based on your interest: $interest';
  }

  @override
  String get oppIdeasBannerAddInterests =>
      'Add interests to your profile — we\'ll show ideas tailored for you';

  @override
  String get oppAcademicFieldMathematics => 'Mathematics';

  @override
  String get oppAcademicFieldEngineering => 'Engineering';

  @override
  String get oppAcademicFieldMedicine => 'Medicine';

  @override
  String get oppAcademicFieldEconomics => 'Economics';

  @override
  String get oppAcademicFieldArts => 'Arts';

  @override
  String get oppAcademicFieldLaw => 'Law';

  @override
  String get oppAcademicFieldInformatics => 'Informatics';

  @override
  String get oppAcademicFieldNatural => 'Natural Sciences';

  @override
  String get oppAccessibilityEasy => 'Easy';

  @override
  String get oppAccessibilityMedium => 'Medium';

  @override
  String get oppAccessibilityHard => 'Hard';

  @override
  String get oppDifficultyEasy => 'Easy';

  @override
  String get oppDifficultyHard => 'Hard';

  @override
  String get oppUniversityAppBarFallback => 'University';

  @override
  String get oppUniversityNotFound => 'University not found';

  @override
  String get oppUniversityAboutSection => 'About the university';

  @override
  String get oppUniversityProgramsSection => 'Programmes';

  @override
  String get oppUniversityAdmissionChancesSection => 'Admission chances';

  @override
  String get oppUniversityAcceptanceRateLabel =>
      'Acceptance rate — realistic estimate';

  @override
  String oppUniversityEntThreshold(int score) {
    return 'UNT ≥ $score points';
  }

  @override
  String get oppUniversityRequirementsSection => 'Requirements';

  @override
  String get oppUniversityCostSection => 'Cost & scholarships';

  @override
  String get oppUniversityAdmissionStepsSection => 'How to apply';

  @override
  String oppUniversityOpenWebsite(String label) {
    return 'Open website: $label';
  }

  @override
  String get oppEventAppBarFallback => 'Event';

  @override
  String get oppEventNotFound => 'Event not found';

  @override
  String get oppEventDiagramSlotLabel => 'Event';

  @override
  String get oppEventAboutSection => 'About the event';

  @override
  String get oppEventPrizesSection => 'Prizes';

  @override
  String oppEventRegistrationDeadline(String deadline) {
    return 'Registration deadline: $deadline';
  }

  @override
  String get oppEventHowToParticipateSection => 'How to participate';

  @override
  String get oppEventAddToList => 'Add to event list';

  @override
  String get oppEventSaved => 'Event saved';

  @override
  String get oppScholarshipAppBarFallback => 'Scholarship';

  @override
  String get oppScholarshipNotFound => 'Scholarship not found';

  @override
  String get oppScholarshipCoverageSection => 'What it covers';

  @override
  String get oppScholarshipHowToGetSection => 'How to get it';

  @override
  String get oppScholarshipRequiredStatsSection => 'Required stats';

  @override
  String get oppScholarshipHowToBoostLabel => 'How to achieve them:';

  @override
  String get oppScholarshipDocumentsSection => 'Required documents';

  @override
  String get oppScholarshipApplyCta => 'Apply';

  @override
  String get oppIdeaAppBarFallback => 'Project Idea';

  @override
  String get oppIdeaNotFound => 'Project idea not found';

  @override
  String get oppIdeaWhatSection => 'About the project';

  @override
  String get oppIdeaWhySection => 'Why it fits you';

  @override
  String get oppIdeaStepsSection => 'Steps';

  @override
  String get oppIdeaOutcomeSection => 'What you\'ll get';

  @override
  String get oppIdeaSaveIdea => 'Save idea';

  @override
  String get oppIdeaSavedSnackbar => 'Idea saved to profile';

  @override
  String get oppApplyAppBarTitle => 'Apply';

  @override
  String get oppApplyFormTitle => 'Fill in the application';

  @override
  String get oppApplyFormSubtitle =>
      'All fields are required. Data is stored locally.';

  @override
  String get oppApplyFieldFullName => 'Full name';

  @override
  String get oppApplyHintFullName => 'First Last Patronymic';

  @override
  String get oppApplyFieldContact => 'Contact (email or phone)';

  @override
  String get oppApplyHintContact => 'example@mail.kz or +7 777 000 00 00';

  @override
  String get oppApplyFieldMotivation => 'Motivation letter';

  @override
  String get oppApplyHintMotivation =>
      'Tell us why you want this scholarship and how it will help your studies...';

  @override
  String get oppApplySubmitButton => 'Submit application';

  @override
  String get oppApplyErrorFullNameEmpty => 'Please enter your full name';

  @override
  String get oppApplyErrorContactEmpty => 'Please enter a contact';

  @override
  String get oppApplyErrorMotivationTooShort =>
      'Please write at least 20 characters';

  @override
  String get oppApplySuccessTitle => 'Application submitted!';

  @override
  String get oppApplySuccessBody =>
      'We saved your application. Track its status in Profile → Documents.';

  @override
  String get oppApplySuccessCardTitle => 'Application received';

  @override
  String get oppApplySuccessCardSubtitle => 'Data saved locally';

  @override
  String get oppApplySuccessBackButton => 'Back to scholarships';

  @override
  String get oppCareerTestTitle => 'Discover your career';

  @override
  String oppCareerTestProgressLabel(int current, int total) {
    return '$current / $total';
  }

  @override
  String get oppCareerTestCategoryLabel => 'People-oriented';

  @override
  String get oppCareerCategoryAnalytical => 'Analytics';

  @override
  String get oppCareerCategoryCreative => 'Creativity';

  @override
  String get oppCareerCategoryTechnical => 'Technology';

  @override
  String get oppCareerCategoryLeadership => 'Leadership';

  @override
  String get oppCareerAnswerYes => 'Yes';

  @override
  String get oppCareerAnswerNo => 'No';

  @override
  String get oppCareerAnswerSometimes => 'Sometimes';

  @override
  String get oppCareerAnswerMaybe => 'Maybe';

  @override
  String get oppCareerResultTitleDone => 'You completed the test!';

  @override
  String get oppCareerResultTitleAlreadyDone => 'Test already completed!';

  @override
  String get oppCareerResultStrengthLabel => 'Your strength:';

  @override
  String get oppCareerResultInsightFallback => 'Keep developing your skills!';

  @override
  String get oppCareerResultCategoriesHeader => 'Results by category:';

  @override
  String get oppCareerResultReturnTomorrow =>
      'Come back tomorrow for a new test';

  @override
  String get oppCareerResultHomeButton => 'Home';

  @override
  String get oppCareerInsightSocial =>
      'You\'re a natural communicator! Your strengths are empathy and finding common ground. Professions for you: teacher, psychologist, HR manager, social worker, PR specialist.';

  @override
  String get oppCareerInsightAnalytical =>
      'You think systematically and love diving into data. Consider: data analyst, financier, scientist, programmer, economist.';

  @override
  String get oppCareerInsightCreative =>
      'You see the world differently and create new things. Your paths: designer, artist, architect, director, UX specialist, marketer.';

  @override
  String get oppCareerInsightTechnical =>
      'You love understanding how things work and building real solutions. Careers for you: engineer, programmer, IT specialist, scientist, researcher.';

  @override
  String get oppCareerInsightLeadership =>
      'You can lead people and achieve goals through a team. Right for you: manager, entrepreneur, public official, top executive, strategist.';

  @override
  String get oppLessonIntroTitle => 'Comparing probabilities';

  @override
  String get oppLessonIntroSubtitle =>
      'Learn to compare chances of events and understand what is certain, impossible, or random.';

  @override
  String oppLessonStatTheoryCards(int count) {
    return '$count theory cards';
  }

  @override
  String oppLessonStatQuestions(int count) {
    return '$count questions';
  }

  @override
  String get oppLessonStatXp => '+50 XP';

  @override
  String get oppLessonStartButton => 'Start lesson';

  @override
  String oppLessonTheoryPill(int current, int total) {
    return 'Theory  $current / $total';
  }

  @override
  String get oppLessonTheoryNextButton => 'Next';

  @override
  String get oppLessonTheoryToQuestionsButton => 'To questions';

  @override
  String oppLessonQuestionPill(int current, int total) {
    return 'Question $current of $total';
  }

  @override
  String get oppLessonCheckButton => 'Check';

  @override
  String get oppLessonTrueFalseTrue => 'True';

  @override
  String get oppLessonTrueFalseFalse => 'False';

  @override
  String get oppLessonFeedbackCorrect => 'Correct!';

  @override
  String get oppLessonFeedbackIncorrect => 'Incorrect';

  @override
  String oppLessonFeedbackXpBadge(int xp) {
    return '+$xp XP';
  }

  @override
  String get oppLessonWhyExpander => 'Why?';

  @override
  String get oppLessonContinueButton => 'Continue';

  @override
  String get oppLessonCompleteTitle => 'Lesson complete!';

  @override
  String get oppLessonCompleteSubtitle =>
      'Great work! You finished the lesson on probability.';

  @override
  String get oppLessonXpEarned => 'XP earned';

  @override
  String oppLessonXpValue(int xp) {
    return '+$xp XP';
  }

  @override
  String get oppLessonCorrectAnswersLabel => 'Correct answers';

  @override
  String oppLessonCorrectAnswersValue(int correct, int total) {
    return '$correct of $total';
  }

  @override
  String get oppLessonDoneButton => 'Done';

  @override
  String get oppLessonTheoryProbabilityTitle => 'What is probability?';

  @override
  String get oppLessonTheoryProbabilityBody =>
      'Probability is a number from 0 to 1 that describes how likely an event is. 0 means the event is impossible, 1 means it is certain. All events in between have probability strictly between 0 and 1.';

  @override
  String get oppLessonTheoryFormulaTitle => 'Classical formula';

  @override
  String get oppLessonTheoryFormulaBody =>
      'P(A) = m / n, where m is the number of favorable outcomes and n is the total number of equally likely outcomes. Example: flip a coin. n = 2 (heads and tails), m = 1 (heads). So P(heads) = 1/2 = 0.5.';

  @override
  String get oppLessonTheoryComparingTitle => 'Comparing probabilities';

  @override
  String get oppLessonTheoryComparingBody =>
      'Probabilities are compared just like ordinary fractions. P(A) > P(B) means event A happens more often than B. Example: probability of drawing a red ball from a bag (3 red out of 10) = 3/10 = 0.3, blue = 7/10 = 0.7. Blue is more likely.';

  @override
  String get oppLessonTheoryCertainTitle => 'Certain and impossible events';

  @override
  String get oppLessonTheoryCertainBody =>
      'A certain event always happens (P = 1). Example: rolling a die always gives a number from 1 to 6 — that is certain. An impossible event never happens (P = 0). Example: rolling a 7 on that same die.';

  @override
  String get oppLessonQ0Text =>
      'A coin is flipped. What is the probability of heads?';

  @override
  String get oppLessonQ0Explanation =>
      'A coin has two equally likely outcomes: heads and tails. So the probability of heads = 1/2 = 0.5.';

  @override
  String get oppLessonQ1Text => 'The probability of a certain event equals 1.';

  @override
  String get oppLessonQ1OptionTrue => 'True';

  @override
  String get oppLessonQ1OptionFalse => 'False';

  @override
  String get oppLessonQ1Explanation =>
      'A certain event is one that will definitely happen. By definition, its probability equals 1.';

  @override
  String get oppLessonQ2Text =>
      'The probability of an impossible event equals ____.';

  @override
  String get oppLessonQ2Explanation =>
      'An impossible event can never occur. Its probability equals 0 by definition.';

  @override
  String get profScreenTitle => 'Profile';

  @override
  String get profAddDataPrompt => 'Add your details →';

  @override
  String get profEditTooltip => 'Edit profile';

  @override
  String profGoalChip(int minutes) {
    return 'Goal: $minutes min/day';
  }

  @override
  String get profDocPackagesSectionTitle => 'Document package';

  @override
  String get profDocPackagesSectionSubtitle =>
      'Check off documents as you prepare them and attach files';

  @override
  String get profMyDocsSectionTitle => 'My documents';

  @override
  String get profMyDocsSectionSubtitle =>
      'Attach files, open them, and share with your advisor';

  @override
  String get profCareerTestCardTitle => 'Career orientation test';

  @override
  String get profCareerTestCardSubtitleDuration => 'Takes ~10–15 minutes';

  @override
  String profCareerTestCardSubtitleRetake(String result) {
    return 'Result: $result. Retake?';
  }

  @override
  String get profCareerTestDialogTitle => 'Career orientation test';

  @override
  String get profCareerTestDialogBody =>
      'The test takes 10–15 minutes. Answer honestly — your result will be more accurate.';

  @override
  String get profCareerTestDialogCancel => 'Cancel';

  @override
  String get profCareerTestDialogConfirm => 'Continue';

  @override
  String get profNewPackageTitle => 'New package';

  @override
  String get profNewPackageNameLabel => 'Package name';

  @override
  String get profNewPackageNameHint => 'E.g. NU 2026';

  @override
  String get profNewPackageDescLabel => 'Description (optional)';

  @override
  String get profNewPackageDescHint => 'Documents for Nazarbayev University';

  @override
  String get profCreatePackageButton => 'Create package';

  @override
  String profPackageProgress(int attached, int total) {
    return '$attached / $total confirmed';
  }

  @override
  String get profDocActionOpen => 'Open';

  @override
  String get profDocActionReplace => 'Replace';

  @override
  String get profDocActionRemove => 'Remove from package';

  @override
  String get profDocAttachButton => 'Attach';

  @override
  String get profNoAttachedFiles => 'No attached files';

  @override
  String get profAttachFileButton => 'Attach file';

  @override
  String get profDocActionShare => 'Share';

  @override
  String get profDocActionDelete => 'Delete';

  @override
  String get profAddDocumentButton => 'Add document';

  @override
  String get profAddDocSheetTitle => 'Add document';

  @override
  String profAddDocSheetSubtitle(String packageName) {
    return 'to package ‘$packageName’';
  }

  @override
  String get profAddDocUploadNew => 'Upload new file';

  @override
  String get profAddDocAddSlot => 'Add item without file';

  @override
  String get profAddDocFromMyDocs => 'From my documents';

  @override
  String get profAddDocNoSavedFiles =>
      'No saved files yet. Upload a new one — it will also appear in \'My documents\'.';

  @override
  String get profAddSlotDialogTitle => 'New item';

  @override
  String get profAddSlotDialogHint => 'E.g. Recommendation letter';

  @override
  String get profAddSlotDialogCancel => 'Cancel';

  @override
  String get profAddSlotDialogAdd => 'Add';

  @override
  String get profEditScreenTitle => 'My details';

  @override
  String get profEditSectionPersonal => 'Personal details';

  @override
  String get profEditFieldNameLabel => 'Name';

  @override
  String get profEditFieldNameHint => 'What\'s your name?';

  @override
  String get profEditFieldGradeLabel => 'Grade';

  @override
  String get profEditFieldGradeHint => '11th grade';

  @override
  String get profEditFieldCityLabel => 'City';

  @override
  String get profEditFieldCityHint => 'Almaty, Astana...';

  @override
  String get profEditFieldGpaLabel => 'GPA / average grade';

  @override
  String get profEditFieldGpaHint => '4.8';

  @override
  String get profEditFieldLanguagesLabel => 'Languages (comma-separated)';

  @override
  String get profEditFieldLanguagesHint => 'KZ, RU, EN';

  @override
  String get profEditSectionAcademic => 'Majors and interests';

  @override
  String get profEditFieldMajorsLabel => 'Study majors (comma-separated)';

  @override
  String get profEditFieldMajorsHint => 'IT, Medicine, Finance...';

  @override
  String get profEditFieldInterestsLabel =>
      'Interests and hobbies (comma-separated)';

  @override
  String get profEditFieldInterestsHint => 'Mathematics, Design, Music...';

  @override
  String get profEditSectionExams => 'Exam scores';

  @override
  String get profEditFieldIeltsLabel => 'IELTS score';

  @override
  String get profEditFieldIeltsHint => '7.0';

  @override
  String get profEditFieldSatLabel => 'SAT score';

  @override
  String get profEditFieldSatHint => '1400';

  @override
  String get profEditFieldToeflLabel => 'TOEFL score';

  @override
  String get profEditFieldToeflHint => '100';

  @override
  String get profEditSaveButton => 'Save';

  @override
  String get profEditSavedSnackbar => 'Details saved';

  @override
  String get profCareerTestScreenTitle => 'Career orientation';

  @override
  String profCareerTestProgress(int current, int total) {
    return '$current / $total';
  }

  @override
  String get profCareerTestWarning =>
      'The test takes ~10–15 minutes. Answer honestly — your result will be more accurate.';

  @override
  String profCareerTestQuestionLabel(int number) {
    return 'Question $number';
  }

  @override
  String get profCareerTestAnswerNo => 'No';

  @override
  String get profCareerTestAnswerNeutral => 'Neutral';

  @override
  String get profCareerTestAnswerYes => 'Yes';

  @override
  String get profCareerResultTitle => 'Result ready!';

  @override
  String get profCareerResultProfileLabel => 'Your profile';

  @override
  String get profCareerResultSavedNote =>
      'Your result has been saved to your profile. You can retake the test at any time.';

  @override
  String get profCareerResultCloseButton => 'Close';

  @override
  String profNotifierLoadError(String error) {
    return 'Loading error: $error';
  }

  @override
  String profNotifierSaveError(String error) {
    return 'Save error: $error';
  }

  @override
  String get profSeedPackageName => 'KZ standard package';

  @override
  String get profSeedPackageDesc =>
      'Standard set of documents for admission to Kazakhstani universities';

  @override
  String get profSeedItemId => 'National ID / Birth certificate';

  @override
  String get profSeedItemTranscript => 'School certificate / Grade transcript';

  @override
  String get profSeedItemMedical => 'Medical certificate 086-U';

  @override
  String get profSeedItemPhotos => '3×4 photos (6 pcs)';

  @override
  String get profSeedItemUnt => 'UNT / USE certificate';

  @override
  String get profSeedItemIntlExam =>
      'IELTS / TOEFL / SAT certificate (if available)';

  @override
  String get profSeedItemMotivation => 'Motivation letter';

  @override
  String get profSeedItemRecommendations => 'Recommendation letters (2 pcs)';

  @override
  String get profSeedItemApplication => 'Admission application';

  @override
  String get profSeedItemParentalConsent => 'Parental consent (for minors)';

  @override
  String get profCareerResultEngineerResearcher => 'Research engineer';

  @override
  String get profCareerResultArchitectDesigner =>
      'Architect / Product designer';

  @override
  String get profCareerResultScientistInnovator => 'Scientist innovator';

  @override
  String get profCareerResultHrCoach => 'HR manager / Coach';

  @override
  String get profCareerResultCfo => 'Finance director';

  @override
  String get profCareerResultArtTherapistEducator =>
      'Art therapist / Creative educator';

  @override
  String get profCareerResultEngineerTechnologist => 'Engineer / Technologist';

  @override
  String get profCareerResultScientistAnalyst => 'Scientist / Analyst';

  @override
  String get profCareerResultCreativeDesigner =>
      'Creative professional / Designer';

  @override
  String get profCareerResultTeacherPsychologist => 'Teacher / Psychologist';

  @override
  String get profCareerResultEntrepreneurManager => 'Entrepreneur / Manager';

  @override
  String get profCareerResultFinancistAdministrator =>
      'Finance specialist / Administrator';

  @override
  String get profCareerQ1 =>
      'I enjoy assembling and repairing things with my own hands';

  @override
  String get profCareerQ2 => 'I prefer working outdoors';

  @override
  String get profCareerQ3 =>
      'I find technical devices and mechanisms interesting';

  @override
  String get profCareerQ4 => 'I enjoy physical work';

  @override
  String get profCareerQ5 => 'I enjoy working with tools and equipment';

  @override
  String get profCareerQ6 => 'I enjoy solving complex problems and puzzles';

  @override
  String get profCareerQ7 =>
      'I enjoy spending time reading scientific articles';

  @override
  String get profCareerQ8 =>
      'I find it interesting to study how the world around us works';

  @override
  String get profCareerQ9 => 'I enjoy analysing data and finding patterns';

  @override
  String get profCareerQ10 => 'I enjoy conducting experiments';

  @override
  String get profCareerQ11 => 'I enjoy drawing, writing, or making music';

  @override
  String get profCareerQ12 =>
      'I enjoy creating something beautiful or original';

  @override
  String get profCareerQ13 => 'I often find unconventional solutions';

  @override
  String get profCareerQ14 => 'Creative self-expression is important to me';

  @override
  String get profCareerQ15 => 'I enjoy design and aesthetics';

  @override
  String get profCareerQ16 => 'I enjoy helping other people';

  @override
  String get profCareerQ17 =>
      'I am good at sensing others\' moods and emotions';

  @override
  String get profCareerQ18 => 'I enjoy working in a team';

  @override
  String get profCareerQ19 => 'I enjoy teaching others';

  @override
  String get profCareerQ20 =>
      'Volunteering and helping the community matter to me';

  @override
  String get profCareerQ21 => 'I enjoy persuading people and negotiating';

  @override
  String get profCareerQ22 => 'I am ready to take responsibility and lead';

  @override
  String get profCareerQ23 => 'I am drawn to building a business';

  @override
  String get profCareerQ24 => 'I enjoy competing and winning';

  @override
  String get profCareerQ25 => 'I am good at selling ideas and products';

  @override
  String get profCareerQ26 => 'I enjoy working with numbers and documents';

  @override
  String get profCareerQ27 => 'I value order and organisation';

  @override
  String get profCareerQ28 => 'I enjoy following clear rules and instructions';

  @override
  String get profCareerQ29 =>
      'I find accounting, finance, or data management interesting';

  @override
  String get profCareerQ30 => 'I enjoy organising and classifying information';

  @override
  String get sharedNavHome => 'Home';

  @override
  String get sharedNavUniversities => 'Universities';

  @override
  String get sharedNavEraly => 'Eraly';

  @override
  String get sharedNavOpportunities => 'Opportunities';

  @override
  String get sharedNavProfile => 'Profile';

  @override
  String get sharedNotifStudyReminderTitle => 'Time to study!';

  @override
  String get sharedNotifStudyBody10 =>
      'Just 10 minutes — and you\'re one step closer to your goal!';

  @override
  String get sharedNotifStudyBody20 =>
      '20 minutes of study today — you\'ve got this!';

  @override
  String sharedNotifStudyBody30(int minutes) {
    return '$minutes minutes of study planned. Shall we start?';
  }

  @override
  String sharedNotifStudyBodyBig(int minutes) {
    return 'Big goal today: $minutes minutes. Good luck!';
  }

  @override
  String sharedNotifCalendarNowTitle(String eventTitle) {
    return 'Now: $eventTitle';
  }

  @override
  String get sharedNotifCalendarNowBody => 'Event is starting!';

  @override
  String sharedNotifCalendarSoonTitle(String eventTitle) {
    return 'Soon: $eventTitle';
  }

  @override
  String get sharedNotifCalendarSoonBody => 'Scheduled for today.';

  @override
  String sharedNotifTodoNudgeTitle(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'You have $count tasks today',
      one: 'You have $count task today',
    );
    return '$_temp0';
  }

  @override
  String get sharedNotifChannelName => 'Daily reminders';

  @override
  String get sharedNotifChannelDesc =>
      'Reminders for daily study sessions and upcoming events';

  @override
  String get uniTitle => 'Universities';

  @override
  String uniSubtitleKz(int count) {
    return '$count universities in Kazakhstan';
  }

  @override
  String get uniErrorLoad => 'Failed to load universities';

  @override
  String get uniEmptyList => 'No universities found';

  @override
  String get uniNoResults => 'No universities match the selected filters';

  @override
  String get uniFilterCity => 'City';

  @override
  String get uniFilterType => 'Type';

  @override
  String get uniFilterReset => 'Reset';

  @override
  String get uniPickCityTitle => 'Select city';

  @override
  String get uniPickTypeTitle => 'Select type';

  @override
  String get uniFilterClearItem => 'Clear filter';

  @override
  String uniProgramCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count programs',
      one: '$count program',
    );
    return '$_temp0';
  }

  @override
  String uniCompetitionFrom(int score) {
    return 'competition from $score pts';
  }

  @override
  String get uniTypeNational => 'National';

  @override
  String get uniTypeState => 'State';

  @override
  String get uniTypeAutonomous => 'Autonomous';

  @override
  String get uniTypePrivate => 'Private';

  @override
  String get uniTypeInternational => 'International';

  @override
  String get uniHubSubtitle => 'Choose which universities to explore';

  @override
  String get uniHubKzTitle => 'Kazakhstan Universities';

  @override
  String get uniHubKzSubtitle =>
      'Catalog of 88+ universities with competition scores and programs';

  @override
  String get uniHubAbroadTitle => 'Universities Abroad';

  @override
  String get uniHubAbroadSubtitle =>
      'Top world universities with financial aid for international students';

  @override
  String get uniAbroadTitle => 'Universities Abroad';

  @override
  String uniAbroadCountSubtitle(int count) {
    return '$count universities worldwide';
  }

  @override
  String get uniAbroadErrorLoad => 'Failed to load abroad universities';

  @override
  String get uniAbroadEmptyList => 'No abroad universities found';

  @override
  String get uniAbroadMatchBadge => 'match';

  @override
  String uniAbroadTuitionPerYear(String price) {
    return '\$$price/yr';
  }

  @override
  String get uniFinAidNeedBlind => 'Need-blind admission';

  @override
  String get uniFinAidGenerous => 'Generous financial aid';

  @override
  String get uniFinAidLimited => 'Limited aid';

  @override
  String get uniFinAidNone => 'No financial aid';

  @override
  String get uniShortFinAidNeedBlind => 'need-blind';

  @override
  String get uniShortFinAidGenerous => 'generous grants';

  @override
  String get uniShortFinAidLimited => 'limited aid';

  @override
  String get uniShortFinAidNone => 'no aid';

  @override
  String get uniDetailErrorLoad => 'Failed to load data';

  @override
  String get uniDetailNotFound => 'University not found';

  @override
  String get uniDetailFinanceSection => 'Finances';

  @override
  String get uniDetailFinAidLabel => 'Financial aid';

  @override
  String get uniDetailTuitionLabel => 'Annual tuition';

  @override
  String get uniDetailMajorsSection => 'Fields of study';

  @override
  String uniDetailSourceLink(String url) {
    return 'Source: $url';
  }

  @override
  String get uniMajorCs => 'CS';

  @override
  String get uniMajorEngineering => 'Engineering';

  @override
  String get uniMajorMathematics => 'Mathematics';

  @override
  String get uniMajorPhysics => 'Physics';

  @override
  String get uniMajorChemistry => 'Chemistry';

  @override
  String get uniMajorBiology => 'Biology';

  @override
  String get uniMajorMedicine => 'Medicine';

  @override
  String get uniMajorEconomics => 'Economics';

  @override
  String get uniMajorBusiness => 'Business';

  @override
  String get uniMajorPsychology => 'Psychology';

  @override
  String get uniMajorPolitics => 'Political science';

  @override
  String get uniDetailKzErrorLoad => 'Failed to load university';

  @override
  String get uniDetailKzNotFound => 'University not found';

  @override
  String get uniDetailHasDormYes => 'Yes';

  @override
  String get uniDetailHasDormNo => 'No';

  @override
  String get uniDetailHasDormitory => 'Dormitory available';

  @override
  String get uniDetailStatPrograms => 'programs';

  @override
  String get uniDetailStatCompetition => 'competition from, pts';

  @override
  String get uniDetailStatDormitory => 'dormitory';

  @override
  String get uniDetailAboutSection => 'About';

  @override
  String get uniDetailInfoSection => 'Information';

  @override
  String uniDetailProgramsSection(int count) {
    return 'Programs ($count)';
  }

  @override
  String get uniDetailProgramsNote =>
      'The score is the minimum to participate in the grant competition (UNT). This is not a cutoff score. Tap a program to expand details.';

  @override
  String uniDetailCompetitionFrom(int score) {
    return 'Competition from $score pts';
  }

  @override
  String get uniDetailLanguagesLabel => 'Languages of instruction';

  @override
  String get uniDetailGrantPlacesLabel => 'Grant places';

  @override
  String get uniDetailTuitionKztLabel => 'Annual tuition';

  @override
  String get uniDetailNoScoreData => 'No score data available yet.';

  @override
  String get uniDetailScoresByYear => 'Scores by year';

  @override
  String get uniDetailUnverified => 'unverified';

  @override
  String get uniDetailEmptyPrograms =>
      'No program or grant data available for this university yet.';

  @override
  String get uniDetailSourcesTitle => 'Data sources';

  @override
  String get uniLangKz => 'kaz';

  @override
  String get uniLangRu => 'rus';

  @override
  String get uniLangEn => 'eng';

  @override
  String get uniQuotaGeneral => 'General competition';

  @override
  String get uniQuotaRural => 'Rural quota';

  @override
  String get uniQuotaLyceum => 'Lyceum quota';

  @override
  String get uniQuotaOrphan => 'Orphan quota';

  @override
  String get uniQuotaDisability => 'Disability quota';

  @override
  String get uniQuotaOralman => 'Oralman quota';

  @override
  String get uniQuotaOther => 'Other quota';

  @override
  String get uniGrantMetricCutoff => 'Grant cutoff score';

  @override
  String get uniGrantMetricCompetitionMin => 'Minimum to compete for grant';

  @override
  String get uniGrantMetricPaidMin => 'Minimum for paid enrollment';

  @override
  String get uniGrantMetricNationalFloor => 'National floor (MES order)';
}
