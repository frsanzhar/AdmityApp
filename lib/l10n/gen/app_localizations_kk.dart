// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Kazakh (`kk`).
class AppLocalizationsKk extends AppLocalizations {
  AppLocalizationsKk([String locale = 'kk']) : super(locale);

  @override
  String get appTitle => 'Admity';

  @override
  String get languageSectionTitle => 'Қолданба тілі';

  @override
  String get languageSystem => 'Жүйедегідей';

  @override
  String get languageRussian => 'Русский';

  @override
  String get languageKazakh => 'Қазақша';

  @override
  String get languageEnglish => 'English';

  @override
  String get authWelcomeTitle => 'Қош келдіңіз';

  @override
  String get authCreateAccountTitle => 'Аккаунт жасау';

  @override
  String get authSignInSubtitle => 'Жалғастыру үшін кіріңіз';

  @override
  String get authSignUpSubtitle => 'Бастау үшін деректерді енгізіңіз';

  @override
  String get authEmailLabel => 'Email';

  @override
  String get authPasswordLabel => 'Құпиясөз';

  @override
  String get authEmailRequired => 'Email енгізіңіз';

  @override
  String get authEmailInvalid => 'Жарамсыз email';

  @override
  String get authPasswordRequired => 'Құпиясөз енгізіңіз';

  @override
  String get authPasswordMinLength => 'Кемінде 6 таңба';

  @override
  String get authSignInButton => 'Кіру';

  @override
  String get authSignUpButton => 'Тіркелу';

  @override
  String get authAlreadyHaveAccount => 'Аккаунт бар ма? Кіру';

  @override
  String get authNoAccount => 'Аккаунт жоқ па? Тіркелу';

  @override
  String get authOrDivider => 'немесе';

  @override
  String get authContinueWithGoogle => 'Google арқылы жалғастыру';

  @override
  String get authContinueWithApple => 'Apple арқылы жалғастыру';

  @override
  String get authContinueAsGuest => 'Қонақ ретінде жалғастыру';

  @override
  String get authErrorSignIn =>
      'Кіру мүмкін болмады. Байланысты тексеріп, қайталап көріңіз.';

  @override
  String get authErrorCreateAccount =>
      'Аккаунт жасау мүмкін болмады. Байланысты тексеріп, қайталап көріңіз.';

  @override
  String get authErrorGoogleNotConfigured =>
      'Google арқылы кіру әлі реттелмеген. GOOGLE_WEB_CLIENT_ID қосыңыз.';

  @override
  String get authErrorCancelled => 'Кіру болдырылмады.';

  @override
  String get authErrorGoogleTokenFailed =>
      'Google токенін алу мүмкін болмады. Қайталап көріңіз.';

  @override
  String get authErrorGoogleSignIn =>
      'Google арқылы кіру мүмкін болмады. Қайталап көріңіз.';

  @override
  String get authErrorAppleTokenFailed =>
      'Apple токенін алу мүмкін болмады. Қайталап көріңіз.';

  @override
  String get authErrorAppleSignIn =>
      'Apple арқылы кіру мүмкін болмады. Қайталап көріңіз.';

  @override
  String authErrorAppleRaw(String message) {
    return 'Apple арқылы кіру: $message';
  }

  @override
  String get authErrorGuestFailed => 'Қонақ профилін жасау мүмкін болмады.';

  @override
  String get authErrorInvalidCredentials => 'Email немесе құпиясөз қате.';

  @override
  String get authErrorEmailNotConfirmed =>
      'Хаттағы сілтеме арқылы emailді растаңыз.';

  @override
  String get authErrorEmailAlreadyRegistered =>
      'Бұл email тіркелген. Кіріп көріңіз.';

  @override
  String get authErrorPasswordTooShort =>
      'Құпиясөз кемінде 6 таңбадан тұруы керек.';

  @override
  String get authErrorRateLimit =>
      'Тым көп әрекет. Біраз күтіп, қайталап көріңіз.';

  @override
  String get homeGreeting => 'Сәлем!';

  @override
  String get homeGreetingSubtitle => 'Жаңа білімге дайынсың ба?';

  @override
  String homeStreakSemanticLabel(int count, String dayWord) {
    return 'Серия: $count күн';
  }

  @override
  String get homeStreakStart => 'Сериясыңды бастай кет!';

  @override
  String homeStreakActive(int count) {
    return 'Серия — $count күн';
  }

  @override
  String get homeStreakDayDone => 'Күн аяқталды!';

  @override
  String get homeStreakDayNotDone => 'Әлі аяқталмаған';

  @override
  String homeStreakWeekSummary(int count) {
    return 'Осы аптада $count / 7 күн';
  }

  @override
  String get homeWeekdayMon => 'Дс';

  @override
  String get homeWeekdayTue => 'Сс';

  @override
  String get homeWeekdayWed => 'Ср';

  @override
  String get homeWeekdayThu => 'Бс';

  @override
  String get homeWeekdayFri => 'Жм';

  @override
  String get homeWeekdaySat => 'Сн';

  @override
  String get homeWeekdaySun => 'Жк';

  @override
  String get homeCalendarMonthJan => 'Қаңтар';

  @override
  String get homeCalendarMonthFeb => 'Ақпан';

  @override
  String get homeCalendarMonthMar => 'Наурыз';

  @override
  String get homeCalendarMonthApr => 'Сәуір';

  @override
  String get homeCalendarMonthMay => 'Мамыр';

  @override
  String get homeCalendarMonthJun => 'Маусым';

  @override
  String get homeCalendarMonthJul => 'Шілде';

  @override
  String get homeCalendarMonthAug => 'Тамыз';

  @override
  String get homeCalendarMonthSep => 'Қыркүйек';

  @override
  String get homeCalendarMonthOct => 'Қазан';

  @override
  String get homeCalendarMonthNov => 'Қараша';

  @override
  String get homeCalendarMonthDec => 'Желтоқсан';

  @override
  String get homeCalendarAgendaMonthGenJan => 'қаңтар';

  @override
  String get homeCalendarAgendaMonthGenFeb => 'ақпан';

  @override
  String get homeCalendarAgendaMonthGenMar => 'наурыз';

  @override
  String get homeCalendarAgendaMonthGenApr => 'сәуір';

  @override
  String get homeCalendarAgendaMonthGenMay => 'мамыр';

  @override
  String get homeCalendarAgendaMonthGenJun => 'маусым';

  @override
  String get homeCalendarAgendaMonthGenJul => 'шілде';

  @override
  String get homeCalendarAgendaMonthGenAug => 'тамыз';

  @override
  String get homeCalendarAgendaMonthGenSep => 'қыркүйек';

  @override
  String get homeCalendarAgendaMonthGenOct => 'қазан';

  @override
  String get homeCalendarAgendaMonthGenNov => 'қараша';

  @override
  String get homeCalendarAgendaMonthGenDec => 'желтоқсан';

  @override
  String get homeCalendarWeekdayFullMon => 'Дүйсенбі';

  @override
  String get homeCalendarWeekdayFullTue => 'Сейсенбі';

  @override
  String get homeCalendarWeekdayFullWed => 'Сәрсенбі';

  @override
  String get homeCalendarWeekdayFullThu => 'Бейсенбі';

  @override
  String get homeCalendarWeekdayFullFri => 'Жұма';

  @override
  String get homeCalendarWeekdayFullSat => 'Сенбі';

  @override
  String get homeCalendarWeekdayFullSun => 'Жексенбі';

  @override
  String get homeCalendarNoEvents => 'Оқиғалар жоқ. Алғашқысын қосыңыз!';

  @override
  String get homeCalendarEralyBadge => 'Ералы';

  @override
  String get homeCalendarAddEvent => 'Оқиға қосу';

  @override
  String get homeEventSheetTitleNew => 'Жаңа оқиға';

  @override
  String get homeEventSheetTitleEdit => 'Оқиғаны өзгерту';

  @override
  String get homeEventSheetFieldTitleLabel => 'Атауы';

  @override
  String get homeEventSheetFieldTitleHint => 'Не жоспарланған?';

  @override
  String get homeEventSheetFieldDescLabel => 'Сипаттама';

  @override
  String get homeEventSheetFieldDescHint => 'Толығырақ (міндетті емес)';

  @override
  String get homeEventSheetSave => 'Сақтау';

  @override
  String get homeEventSheetDelete => 'Оқиғаны жою';

  @override
  String get homeTodayTaskTitle => 'Бүгінгі тапсырма';

  @override
  String get homeTodayTaskBody =>
      'Сабақ: Ықтималдықтарды салыстыру — тоқтаған жерінен жалғастыр.';

  @override
  String get homeTodayTaskContinue => 'Жалғастыру';

  @override
  String get homeTaskListTitle => 'Бүгінгі тапсырмалар';

  @override
  String get homeTaskListEmpty => 'Тапсырмалар жоқ. Қосу үшін + басыңыз.';

  @override
  String get homeTaskSheetTitleNew => 'Жаңа тапсырма';

  @override
  String get homeTaskSheetTitleEdit => 'Өзгерту';

  @override
  String get homeTaskSheetFieldTitleLabel => 'Атауы';

  @override
  String get homeTaskSheetFieldTitleHint => 'Не істеу керек?';

  @override
  String get homeTaskSheetFieldDescLabel => 'Сипаттама';

  @override
  String get homeTaskSheetFieldDescHint => 'Толығырақ (міндетті емес)';

  @override
  String get homeTaskSheetNoDescription => 'Сипаттама қосылмаған.';

  @override
  String get homeTaskSheetSave => 'Сақтау';

  @override
  String get homeTaskSheetDelete => 'Тапсырманы жою';

  @override
  String get homeDefaultTodo1Title => 'Математика сабағын өту';

  @override
  String get homeDefaultTodo1Desc =>
      '«Ықтималдықтарды салыстыру» тарауы — шамамен 15 минут.';

  @override
  String get homeDefaultTodo2Title => 'БОЛАШАҚ стипендияларын зерттеу';

  @override
  String get homeDefaultTodo2Desc =>
      'Түсу талаптарын және құжаттар тапсыру мерзімін тексеру.';

  @override
  String get homeDefaultTodo3Title => 'Профильді жаңарту';

  @override
  String get homeDefaultTodo3Desc =>
      'Соңғы бағаларды қосу және өзекті құжаттарды жүктеу.';

  @override
  String get homeDefaultTodo4Title => 'ҰБТ талаптары туралы оқу';

  @override
  String get homeDefaultTodo4Desc =>
      'Түсу үшін әрбір пән бойынша минималды балл.';

  @override
  String get homeCareerCardTitle => 'Өз мамандығыңды тап';

  @override
  String get homeCareerCardSubtitle => 'Күнделікті тест — 3 минут';

  @override
  String get homeCareerCardButton => 'Тестті өту';

  @override
  String get eralyName => 'Ералы';

  @override
  String get eralySubtitle => 'AI-тәлімгер';

  @override
  String get eralyTypingText => 'Ералы ойлап жатыр...';

  @override
  String get eralyReviewEventsButton => 'Барлық іс-шараларды тексеру';

  @override
  String get eralyOpenPlanButton => 'Жоспарды ашу';

  @override
  String get eralyToneStrictLabel => 'Қатаң\nтәлімгер';

  @override
  String get eralyToneStrictDescription => 'Тура және нақты';

  @override
  String get eralyToneFriendlyLabel => 'Достық\nтәлімгер';

  @override
  String get eralyToneFriendlyDescription => 'Жылылық пен қолдау';

  @override
  String get eralyInputHint => 'Ералыға жаз...';

  @override
  String get eralyTonePrompt =>
      'Сәлем! Мен Ералы — сенің оқуға түсуге арналған AI-тәлімгерің. Бастамас бұрын, мен саған қалай сөйлесуімді таңда:';

  @override
  String get eralyGreetingStrict =>
      'Жақсы. Байыппен жұмыс жасаймыз: мақсат қоямыз, тәртіп сақтаймыз және артық нәрсеге алаңдамаймыз. Айт — қайда оқуға түсесің және не істедің?';

  @override
  String get eralyGreetingFriendly =>
      'Тамаша! Мен жаныңдамын — әр қадамда қолдап, көмектесемін. Өзің туралы айт: қайда оқуға түскің келеді және неден бастаймыз?';

  @override
  String eralyEventsProposedAnnounce(int count) {
    return 'Мен $count іс-шара дайындадым. Уақытты қарап, өзгерту үшін «Барлық іс-шараларды тексеру» батырмасын басыңыз.';
  }

  @override
  String get eralyEventsProposeLoading =>
      'Тамаша! Маған бір секунд бер — бірнеше іс-шара ұсынамын...';

  @override
  String get eralyEventsSaved =>
      'Барлық іс-шаралар күнтізбеге сақталды! Оларды «Басты бет» бөлімінен қарай аласың. Тағы не көмек ете аламын?';

  @override
  String get eralyPlanGenerating => 'Жоспар құрып жатырмын — бір секунд...';

  @override
  String eralyPlanReady(String topic, int lessonCount) {
    return 'Дайын! Мен «$topic» жоспарын $lessonCount сабақтан тұрып жасадым. Оны көру үшін төмен айналдыр. Өзгерткің келсе — сұра!';
  }

  @override
  String get eralyQuestionResources =>
      'Жақсы, бастайық! Қандай оқу материалдарың бар? (кітаптар, онлайн-курстар, қолданбалар — барлығын тізіп шығ)';

  @override
  String get eralyQuestionTime =>
      'Түсіндім. Дайындыққа аптасына қанша уақыт бөле аласың? (мысалы: «күніне 2 сағат» немесе «аптасына 10 сағат»)';

  @override
  String get eralyQuestionInternet =>
      'Онлайн-ресурстар үшін тұрақты интернет байланысың бар ма? (иә / жоқ)';

  @override
  String get eralyOfflineIeltsStrict =>
      'IELTS. Алдымен айт: қандай материалдарың бар? Нақты тізімсіз жоспар жасау мүмкін емес.';

  @override
  String get eralyOfflineIeltsFriendly =>
      'IELTS — тамаша мақсат! Жеке жоспар жасайық. Бастайық: қандай материалдарың бар? (оқулықтар, қолданбалар, курстар — барлығын тізіп шығ)';

  @override
  String get eralyOfflineSatStrict =>
      'SAT жүйелі жұмысты талап етеді. Қандай ресурстарды қолданасың? Нақты тізіп шығ.';

  @override
  String get eralyOfflineSatFriendly =>
      'SAT — маңызды қадам! Мен дайындықты нақты сабақтарға бөлуге көмектесемін. Қандай ресурстарды қолданатыныңды айт?';

  @override
  String get eralyOfflineEntStrict =>
      'ҰБТ — негізгі емтихан. Қанша апта қалды? Нақты күнді айт — артық сөзсіз жоспар жасаймыз.';

  @override
  String get eralyOfflineEntFriendly =>
      'ҰБТ — маңызды емтихан. Сабақ бойынша жоспар жасағың келе ме? Емтиханға дейін қанша уақытың бар екенін жаз.';

  @override
  String get eralyOfflinePlanStrict =>
      'Тақырыпты немесе емтиханды атап бер. Содан кейін үш сұрақ қоямын — және артық сөзсіз жоспар жасаймын.';

  @override
  String get eralyOfflinePlanFriendly =>
      'Әрине, жоспар жасауға көмектесемін! Тақырыпты немесе емтиханды атап бер, мен саған арнап жоспар жасау үшін бірнеше сұрақ қоямын.';

  @override
  String get eralyOfflineEventsStrict =>
      'Іс-шаралар тақырыбын көрсет. Нақты күндер ұсынамын — сен тексеріп, растайсың.';

  @override
  String get eralyOfflineEventsFriendly =>
      'Қуана көмектесемін! Іс-шаралардың тақырыбын немесе мақсатын жаз — бірнеше нақты күн ұсынамын және күнтізбеге қосуға болады.';

  @override
  String get eralyOfflineScholarshipStrict =>
      'Стипендиялар: қазақстандық па, шетелдік пе? Қысқаша жауап бер — профильіңе сай нұсқалар іздеймін.';

  @override
  String get eralyOfflineScholarshipFriendly =>
      'Стипендиялар — менің сүйікті тақырыбым! Айт: қазақстандық бағдарламаларды қарастырасың ба, шетелдіктерді бе? Бұл маған нұсқаларды дәлірек іздеуге көмектеседі.';

  @override
  String get eralyOfflineUniversityStrict =>
      'Нақтырақ: қай елге және қай университетке бағыт алдың? Неғұрлым нақты болса, талдау соғұрлым пайдалы.';

  @override
  String get eralyOfflineUniversityFriendly =>
      'Оқуға түсу — үлкен қадам, мен жаныңдамын. Қай елге немесе университетке бағыт алдың? Әлде әзірше нұсқаларды зерттеп жүрсің бе?';

  @override
  String get eralyOfflineGreetingStrict =>
      'Бастайық. Қайда оқуға түсесің және не істедің? Нақтылық — жұмыстың негізі.';

  @override
  String get eralyOfflineGreetingFriendly =>
      'Сәлем! Өзің туралы аздап айт — қайда оқуға түскің келеді, не істеп көрдің? Неғұрлым көп айтсаң, соғұрлым дәлірек көмектесе аламын.';

  @override
  String get eralyOfflineFollowUpStrict1 =>
      'Тапсырманы нақтыла: емтихан, оқуға түсу немесе басқа нәрсе ме? Қысқаша.';

  @override
  String get eralyOfflineFollowUpStrict2 =>
      'Түсіндім. Нақтырақ айт — бұл ҰБТ үшін бе, халықаралық емтихан үшін бе, әлде ЖОО үшін бе?';

  @override
  String get eralyOfflineFollowUpStrict3 =>
      'Жақсы. Не керек нақтырақ — жоспар ба, мүмкіндіктерді талдау ма, әлде стипендиялар тізімі ме?';

  @override
  String get eralyOfflineFollowUpFriendly1 =>
      'Қызықты! Толығырақ айт — саған нақты қалай көмектесе алатынымды түсінгім келеді.';

  @override
  String get eralyOfflineFollowUpFriendly2 =>
      'Жақсы сұрақ. Нақтыла, өтінемін: емтихандар туралы сұрап жатырсың ба, оқуға түсу туралы ба, әлде басқа нәрсе ме?';

  @override
  String get eralyOfflineFollowUpFriendly3 =>
      'Түсіндім. Нақты жауап беру үшін айт: бұл ҰБТ үшін бе, халықаралық емтихан үшін бе, әлде басқа нәрсе үшін бе?';

  @override
  String eralyOfflineEventTitle1(String topic) {
    return 'Старт: $topic';
  }

  @override
  String get eralyOfflineEventDescription1 =>
      'Тақырыпты алғаш таныстыру — негізгі ұғымдарды зерттеп, сұрақтар тізімін жаса.';

  @override
  String eralyOfflineEventTitle2(String topic) {
    return 'Тәжірибе: $topic';
  }

  @override
  String get eralyOfflineEventDescription2 =>
      'Практикалық сабақ — 10–15 есеп шеш немесе сынақ тест жаса.';

  @override
  String eralyOfflineEventTitle3(String topic) {
    return 'Қайталау: $topic';
  }

  @override
  String get eralyOfflineEventDescription3 =>
      'Қорытынды қайталау — осал жерлерді бекіт және прогресті тексер.';

  @override
  String get eralyOfflinePlanNotes =>
      'Негізгі офлайн-жоспар. Ералының сіздің материалдарыңыз бен кестеңізге арнап жоспар жасауы үшін интернетке қосылыңыз.';

  @override
  String eralyOfflinePlanLesson1Title(String topic) {
    return '$topic кіріспесі';
  }

  @override
  String eralyOfflinePlanLesson2Title(String topic) {
    return '$topic негізгі тұжырымдамалары';
  }

  @override
  String get eralyOfflinePlanLesson3Title => 'Практикалық жаттығулар';

  @override
  String get eralyOfflinePlanLesson4Title => 'Қателер мен осал жерлерді талдау';

  @override
  String get eralyOfflinePlanLesson5Title =>
      'Сынақ тест және қорытынды қайталау';

  @override
  String eralyParsedEventFallbackTitle(int number) {
    return '$number іс-шара';
  }

  @override
  String eralyParsedLessonFallbackTitle(int number) {
    return '$number сабақ';
  }

  @override
  String get onbIntro =>
      'Университетке түсу — бұл үлкен қадам. Admity оны сенімді түрде жасауға көмектеседі.';

  @override
  String get onbWhoAreYou => 'Сен кімсің?';

  @override
  String get onbRoleStudentLabel => 'Мен оқимын';

  @override
  String get onbRoleStudentDesc => 'Түсуге дайындалып жатырмын';

  @override
  String get onbRoleParentLabel => 'Ата-ана';

  @override
  String get onbRoleParentDesc => 'Балама түсуге көмектесемін';

  @override
  String get onbRoleTeacherLabel => 'Мұғалім';

  @override
  String get onbRoleTeacherDesc => 'Оқушыларды жоғары оқу орнына дайындаймын';

  @override
  String get onbNextButton => 'Келесі';

  @override
  String get onbMascotGreetingName => 'Сәлем! Мен — Ералы,';

  @override
  String get onbMascotGreetingDesc =>
      'сенің жеке түсу жөніндегі тәлімгерің. Не білу керектігін айтамын және бірде-бір мүмкіндікті жіберіп алмауыңа көмектесемін.';

  @override
  String get onbMotivationTitle => 'Сенің мақсатың не?';

  @override
  String get onbMotivationSubtitle => 'Бұл дұрыс жолды таңдауға көмектеседі';

  @override
  String get onbMotivationTopKzLabel => 'Қазақстанның үздік ЖОО-сына түсу';

  @override
  String get onbMotivationTopKzDesc => 'НУ, КБТУ, ҚазҰУ және басқалар';

  @override
  String get onbMotivationAbroadLabel => 'Шетелдегі ЖОО-ға түсу';

  @override
  String get onbMotivationAbroadDesc => 'АҚШ, Еуропа, Азия және басқа елдер';

  @override
  String get onbMotivationExploreLabel => 'Мамандық таңдау';

  @override
  String get onbMotivationExploreDesc => 'Әлі бағыт таңдап жатырмын';

  @override
  String get onbAgeTitle => 'Жасың нешеде?';

  @override
  String get onbAgeSubtitle => 'Жасыңа сәйкес мазмұн таңдауға көмектеседі.';

  @override
  String get onbAgeHint => '16';

  @override
  String get onbSubjectTitle =>
      'Негізгі мамандық ретінде қандай пәндер қызықтырады?';

  @override
  String get onbSubjectSubtitle => 'Бірнеше таңдауға болады';

  @override
  String get onbSubjectPsychologyLabel => 'Психология';

  @override
  String get onbSubjectPsychologyDesc => 'Мінез-құлық және психика';

  @override
  String get onbSubjectPoliticsLabel => 'Саясат';

  @override
  String get onbSubjectPoliticsDesc => 'Саясаттану және дипломатия';

  @override
  String get onbSubjectEconomicsLabel => 'Экономика';

  @override
  String get onbSubjectEconomicsDesc => 'Қаржы және бизнес';

  @override
  String get onbSubjectChemistryLabel => 'Химия';

  @override
  String get onbSubjectChemistryDesc => 'Реакциялар мен заттар';

  @override
  String get onbSubjectBiologyLabel => 'Биология';

  @override
  String get onbSubjectBiologyDesc => 'Өмір және медицина';

  @override
  String get onbSubjectPhysicsLabel => 'Физика';

  @override
  String get onbSubjectPhysicsDesc => 'Механика және кванттар';

  @override
  String get onbSubjectMathLabel => 'Математика';

  @override
  String get onbSubjectMathDesc => 'Алгебра және талдау';

  @override
  String get onbTrustTitle => 'Жетекші ЖОО сарапшыларымен бірге жасалған';

  @override
  String get onbTrustSubtitle =>
      'Мазмұн Қазақстан университеттерінің әдіскерлері мен халықаралық серіктестердің қатысуымен жасалған.';

  @override
  String get onbConfidenceTitle => 'Түсетініңе қаншалықты сенімдісің?';

  @override
  String get onbConfidenceSubtitle =>
      'Шынайы жауап жоспарды дұрыс жасауға көмектеседі';

  @override
  String get onbConfidence100Label => '100% сенімдімін';

  @override
  String get onbConfidence100Desc => 'Түсетінімді білемін';

  @override
  String get onbConfidenceMostlyYesLabel => 'Көбіне иә';

  @override
  String get onbConfidenceMostlyYesDesc => 'Жақсы мүмкіндік бар';

  @override
  String get onbConfidenceNotSureLabel => 'Әлі сенімді емеспін';

  @override
  String get onbConfidenceNotSureDesc => 'Көбірек дайындық керек';

  @override
  String get onbConfidenceJustStartingLabel => 'Жаңа бастап жатырмын';

  @override
  String get onbConfidenceJustStartingDesc =>
      'Мақсаттарымды әлі анықтаған жоқпын';

  @override
  String get onbStatsTitle => 'Сенің академиялық көрсеткіштерің';

  @override
  String get onbStatsSubtitle =>
      'Міндетті емес — өткізіп жіберуге болады. Мүмкіндіктерді дұрыс бағалау үшін керек.';

  @override
  String get onbStatsGpaLabel => 'ҮОК / Орташа балл';

  @override
  String get onbStatsGpaHint => 'Мысалы: 4.8';

  @override
  String get onbStatsIeltsLabel => 'IELTS (болса)';

  @override
  String get onbStatsIeltsHint => 'Мысалы: 7.0';

  @override
  String get onbStatsSatLabel => 'SAT (болса)';

  @override
  String get onbStatsSatHint => 'Мысалы: 1400';

  @override
  String get onbTopicUniverseTitle => 'Қажеттінің бәрі — осында';

  @override
  String get onbTopicUniverseMascotCaption =>
      'Қайдан бастау керектігін білемін';

  @override
  String get onbGoalTitle => 'Күніне қанша уақыт?';

  @override
  String get onbGoalMinUnit => 'мин';

  @override
  String get onbGoal10Subtitle => 'Аз, бірақ күн сайын';

  @override
  String get onbGoal20Subtitle => 'Тұрақты прогресс';

  @override
  String get onbGoal30Subtitle => 'Жақсы қарқын';

  @override
  String get onbGoal60Subtitle => 'Терең кіру';

  @override
  String get onbScheduleTitle => 'Қашан ыңғайлы?';

  @override
  String get onbScheduleMorningLabel => 'Таң';

  @override
  String get onbScheduleMorningSubtitle => 'Күн басталғанға дейін';

  @override
  String get onbScheduleDayLabel => 'Күндіз';

  @override
  String get onbScheduleDaySubtitle => 'Бос уақытта';

  @override
  String get onbScheduleEveningLabel => 'Кеш';

  @override
  String get onbScheduleEveningSubtitle => 'Оқудан кейін';

  @override
  String get onbScheduleFlexLabel => 'Мүмкін болғанда';

  @override
  String get onbScheduleFlexSubtitle => 'Икемді кесте';

  @override
  String get onbNotificationsTitle => 'Еске салулар';

  @override
  String get onbNotificationsBody =>
      'Admity сабақтар туралы еске салғанын қалайсың ба?';

  @override
  String get onbNotificationsEnableButton => 'Қосу';

  @override
  String get onbNotificationsSkipButton => 'Өткізіп жіберу';

  @override
  String get onbThreeStepTitle => 'Сенің үш қадамдық жоспарың';

  @override
  String get onbPlanStep1Title => 'Негіздерді үйрен';

  @override
  String get onbPlanStep1Desc => 'Пәніңнің негізін зерттейміз';

  @override
  String get onbPlanStep2Title => 'Жаттық';

  @override
  String get onbPlanStep2Desc => 'Есептер, тесттер, қателерді талдау';

  @override
  String get onbPlanStep3Title => 'Өзіңді тексер';

  @override
  String get onbPlanStep3Desc =>
      'Финалдық дағды тексеруі және нәтижелерді талдау';

  @override
  String get onbCreatePlanButton => 'Менің жоспарымды жасау';

  @override
  String get onbPlanCreationTitle => 'Жоспарыңды жасап жатырмыз…';

  @override
  String get onbPlanCreationCard1 => 'Профиліңді талдап жатырмыз';

  @override
  String get onbPlanCreationCard2 => 'ЖОО мен бағыттарды іріктеп жатырмыз';

  @override
  String get onbPlanCreationCard3 => 'Жеке жолыңды құрып жатырмыз';

  @override
  String get onbPlanCreationAlmost => 'Жуырда дайын болады…';

  @override
  String get onbFinishTitle => 'Бәрі дайын!';

  @override
  String get onbFinishSubtitle => 'Сенің жеке жоспарың жасалды. Бастаймыз ба?';

  @override
  String get onbFinishStartButton => 'Бастау';

  @override
  String get onbReminderTitle => 'Admity-мен оқу уақыты 🎓';

  @override
  String onbReminderBody(int minutes) {
    return 'Түсуге дайындалуға $minutes мин бөл — сен дұрыс жолдасың!';
  }

  @override
  String onbStudyPlanCareerTest(String major) {
    return '$major саласына деген қызығушылықты растау үшін мамандықтық бағдарлау тестінен өт';
  }

  @override
  String get onbStudyPlanUpdateProfile =>
      'Профиліңнің — ҰБТ, ҮОК, бағалар — өзекті және дәл екеніне көз жеткіз';

  @override
  String onbStudyPlanExploreRequirements(String major) {
    return '$major бағыты бойынша қабылдау талаптарын және өту балдарын зерттe';
  }

  @override
  String get onbStudyPlanTargetList =>
      'Мерзімдерімен мақсатты ЖОО тізімін жаса (Қазақстан және/немесе шетелде)';

  @override
  String onbStudyPlanDailyTime(String timeLabel) {
    return '$timeLabel күнделікті дайындыққа уақыт бөл және кестеге бер';
  }

  @override
  String get onbStudyPlanPracticeTests =>
      'Таңдалған пәндер бойынша ҰБТ тапсырмаларын / халықаралық емтихандарды жаттық';

  @override
  String get onbStudyPlanIntlDocs =>
      'Халықаралық өтінімдерге арналған құжаттарды дайында: эссе, ұсыныстар, тіл сертификаттары';

  @override
  String get onbStudyPlanLocalDocs =>
      'Құжаттар пакетін жина: аттестат, транскрипт, ұсыныс хаттар';

  @override
  String get onbStudyPlanTimeMorning => 'таңертең';

  @override
  String get onbStudyPlanTimeDay => 'күндізгі';

  @override
  String get onbStudyPlanTimeEvening => 'кешкі';

  @override
  String get onbStudyPlanTimeFlex => 'ыңғайлы уақытта';

  @override
  String get onbStudyPlanDefaultMajor => 'таңдалған бағыт';

  @override
  String get oppScreenTitle => 'Мүмкіндіктер';

  @override
  String get oppTabScholarships => 'Стипендиялар';

  @override
  String get oppTabEvents => 'Іс-шаралар';

  @override
  String get oppTabProjectIdeas => 'Жоба идеялары';

  @override
  String get oppFilterCityDefault => 'Қала';

  @override
  String get oppFilterFieldDefault => 'Бағыт';

  @override
  String get oppFilterAccessibilityDefault => 'Қолжетімділік';

  @override
  String get oppFilterReset => 'Тазалау';

  @override
  String get oppFilterResetAll => 'Сүзгіні тазалау';

  @override
  String get oppPickerCityTitle => 'Қаланы таңдау';

  @override
  String get oppPickerFieldTitle => 'Бағытты таңдау';

  @override
  String get oppPickerAccessibilityTitle => 'Қолжетімділікті таңдау';

  @override
  String get oppCardMoreDetails => 'Толығырақ';

  @override
  String get oppScholarshipsEmpty =>
      'Таңдалған сүзгілер бойынша стипендиялар жоқ';

  @override
  String oppEventsBannerNearby(String city) {
    return 'саған жақын — $city';
  }

  @override
  String get oppEventsBannerSetCity =>
      'Жанындағы іс-шараларды көру үшін профильде қалаңды көрсет';

  @override
  String get oppEventLocalBadge => 'Жақын';

  @override
  String oppIdeasBannerInterest(String interest) {
    return 'сенің қызығушылығыңа қарай: $interest';
  }

  @override
  String get oppIdeasBannerAddInterests =>
      'Профильге қызығушылықтарыңды қос — саған арнайы идеялар көрсетеміз';

  @override
  String get oppAcademicFieldMathematics => 'Математика';

  @override
  String get oppAcademicFieldEngineering => 'Инженерия';

  @override
  String get oppAcademicFieldMedicine => 'Медицина';

  @override
  String get oppAcademicFieldEconomics => 'Экономика';

  @override
  String get oppAcademicFieldArts => 'Өнер';

  @override
  String get oppAcademicFieldLaw => 'Құқық';

  @override
  String get oppAcademicFieldInformatics => 'Информатика';

  @override
  String get oppAcademicFieldNatural => 'Жаратылыстану ғылымдары';

  @override
  String get oppAccessibilityEasy => 'Оңай';

  @override
  String get oppAccessibilityMedium => 'Орташа';

  @override
  String get oppAccessibilityHard => 'Қиын';

  @override
  String get oppDifficultyEasy => 'Оңай';

  @override
  String get oppDifficultyHard => 'Қиын';

  @override
  String get oppUniversityAppBarFallback => 'Университет';

  @override
  String get oppUniversityNotFound => 'Университет табылмады';

  @override
  String get oppUniversityAboutSection => 'Университет туралы';

  @override
  String get oppUniversityProgramsSection => 'Бағыттар';

  @override
  String get oppUniversityAdmissionChancesSection => 'Қабылдану мүмкіндіктері';

  @override
  String get oppUniversityAcceptanceRateLabel =>
      'Қабылдану деңгейі — шынайы баға';

  @override
  String oppUniversityEntThreshold(int score) {
    return 'ҰБТ ≥ $score балл';
  }

  @override
  String get oppUniversityRequirementsSection => 'Талаптар';

  @override
  String get oppUniversityCostSection => 'Құны және стипендиялар';

  @override
  String get oppUniversityAdmissionStepsSection => 'Қалай түсуге болады';

  @override
  String oppUniversityOpenWebsite(String label) {
    return 'Сайтты ашу: $label';
  }

  @override
  String get oppEventAppBarFallback => 'Іс-шара';

  @override
  String get oppEventNotFound => 'Іс-шара табылмады';

  @override
  String get oppEventDiagramSlotLabel => 'Іс-шара';

  @override
  String get oppEventAboutSection => 'Іс-шара туралы';

  @override
  String get oppEventPrizesSection => 'Жүлделер';

  @override
  String oppEventRegistrationDeadline(String deadline) {
    return 'Тіркелу мерзімі: $deadline';
  }

  @override
  String get oppEventHowToParticipateSection => 'Қалай қатысуға болады';

  @override
  String get oppEventAddToList => 'Іс-шаралар тізіміне қосу';

  @override
  String get oppEventSaved => 'Іс-шара сақталды';

  @override
  String get oppScholarshipAppBarFallback => 'Стипендия';

  @override
  String get oppScholarshipNotFound => 'Стипендия табылмады';

  @override
  String get oppScholarshipCoverageSection => 'Не қамтиды';

  @override
  String get oppScholarshipHowToGetSection => 'Қалай алуға болады';

  @override
  String get oppScholarshipRequiredStatsSection => 'Қажетті көрсеткіштер';

  @override
  String get oppScholarshipHowToBoostLabel => 'Оларға қалай жету керек:';

  @override
  String get oppScholarshipDocumentsSection => 'Қажетті құжаттар';

  @override
  String get oppScholarshipApplyCta => 'Өтінім беру';

  @override
  String get oppIdeaAppBarFallback => 'Жоба идеясы';

  @override
  String get oppIdeaNotFound => 'Жоба идеясы табылмады';

  @override
  String get oppIdeaWhatSection => 'Бұл қандай жоба';

  @override
  String get oppIdeaWhySection => 'Бұл неге сенікі';

  @override
  String get oppIdeaStepsSection => 'Қадамдар';

  @override
  String get oppIdeaOutcomeSection => 'Нәтижесінде не аласың';

  @override
  String get oppIdeaSaveIdea => 'Идеяны сақтау';

  @override
  String get oppIdeaSavedSnackbar => 'Идея профильге сақталды';

  @override
  String get oppApplyAppBarTitle => 'Өтінім беру';

  @override
  String get oppApplyFormTitle => 'Өтінімді толтырыңыз';

  @override
  String get oppApplyFormSubtitle =>
      'Барлық өрістер міндетті. Деректер жергілікті сақталады.';

  @override
  String get oppApplyFieldFullName => 'Аты-жөні';

  @override
  String get oppApplyHintFullName => 'Иванов Иван Иванович';

  @override
  String get oppApplyFieldContact => 'Байланыс (email немесе телефон)';

  @override
  String get oppApplyHintContact => 'example@mail.kz немесе +7 777 000 00 00';

  @override
  String get oppApplyFieldMotivation => 'Мотивациялық хат';

  @override
  String get oppApplyHintMotivation =>
      'Осы стипендияны неге алғыңыз келетінін және ол оқуыңызға қалай көмектесетінін айтыңыз...';

  @override
  String get oppApplySubmitButton => 'Өтінімді жіберу';

  @override
  String get oppApplyErrorFullNameEmpty => 'Аты-жөніңізді енгізіңіз';

  @override
  String get oppApplyErrorContactEmpty => 'Байланысты енгізіңіз';

  @override
  String get oppApplyErrorMotivationTooShort => 'Кем дегенде 20 таңба жазыңыз';

  @override
  String get oppApplySuccessTitle => 'Өтінім жіберілді!';

  @override
  String get oppApplySuccessBody =>
      'Біз сенің өтінімді сақтадық. Күйін «Профиль → Құжаттар» бөлімінен қадағала.';

  @override
  String get oppApplySuccessCardTitle => 'Өтінім қабылданды';

  @override
  String get oppApplySuccessCardSubtitle => 'Деректер жергілікті сақталды';

  @override
  String get oppApplySuccessBackButton => 'Стипендияларға оралу';

  @override
  String get oppCareerTestTitle => 'Өзіңнің мамандығыңды білу';

  @override
  String oppCareerTestProgressLabel(int current, int total) {
    return '$current / $total';
  }

  @override
  String get oppCareerTestCategoryLabel => 'Адамдармен жұмыс';

  @override
  String get oppCareerCategoryAnalytical => 'Аналитика';

  @override
  String get oppCareerCategoryCreative => 'Шығармашылық';

  @override
  String get oppCareerCategoryTechnical => 'Технологиялар';

  @override
  String get oppCareerCategoryLeadership => 'Басқару';

  @override
  String get oppCareerAnswerYes => 'Иә';

  @override
  String get oppCareerAnswerNo => 'Жоқ';

  @override
  String get oppCareerAnswerSometimes => 'Кейде';

  @override
  String get oppCareerAnswerMaybe => 'Мүмкін';

  @override
  String get oppCareerResultTitleDone => 'Сен тестті аяқтадың!';

  @override
  String get oppCareerResultTitleAlreadyDone => 'Тест бұрын өтілді!';

  @override
  String get oppCareerResultStrengthLabel => 'Сенің күшті жағың:';

  @override
  String get oppCareerResultInsightFallback =>
      'Өз дағдыларыңды дамытуды жалғастыр!';

  @override
  String get oppCareerResultCategoriesHeader => 'Санаттар бойынша нәтижелер:';

  @override
  String get oppCareerResultReturnTomorrow => 'Жаңа тест үшін ертең қайт';

  @override
  String get oppCareerResultHomeButton => 'Басты бетке';

  @override
  String get oppCareerInsightSocial =>
      'Сен туа біткен коммуникатормен! Сенің күшті жақтарың — эмпатия және ортақ тіл табу. Саған мыналар ыңғайлы: мұғалім, психолог, HR-менеджер, әлеуметтік қызметкер, PR-маман.';

  @override
  String get oppCareerInsightAnalytical =>
      'Сен жүйелі ойлайсың және деректермен жұмыс істеуді жақсы көресің. Назар аудар: деректер аналитигі, қаржышы, ғалым, бағдарламашы, экономист.';

  @override
  String get oppCareerInsightCreative =>
      'Сен дүниені өзгеше көресің және жаңа нәрсе жасай аласың. Сенің бағыттарың: дизайнер, суретші, сәулетші, режиссер, UX-маман, маркетолог.';

  @override
  String get oppCareerInsightTechnical =>
      'Сен барлық нәрсенің қалай жұмыс істейтінін білуді және нақты шешімдер жасауды жақсы көресің. Саған арналған мамандықтар: инженер, бағдарламашы, IT-маман, ғалым, зерттеуші.';

  @override
  String get oppCareerInsightLeadership =>
      'Сен адамдарды жетектей аласың және команда арқылы мақсатқа жете аласың. Саған ыңғайлы: менеджер, кәсіпкер, мемлекет қайраткері, топ-менеджер, стратег.';

  @override
  String get oppLessonIntroTitle => 'Ықтималдықтарды салыстыру';

  @override
  String get oppLessonIntroSubtitle =>
      'Оқиғалардың мүмкіндіктерін салыстыруды және нені сенімді, мүмкін емес немесе кездейсоқ деп есептеу керектігін үйрен.';

  @override
  String oppLessonStatTheoryCards(int count) {
    return '$count теория картасы';
  }

  @override
  String oppLessonStatQuestions(int count) {
    return '$count сұрақ';
  }

  @override
  String get oppLessonStatXp => '+50 XP';

  @override
  String get oppLessonStartButton => 'Сабақты бастау';

  @override
  String oppLessonTheoryPill(int current, int total) {
    return 'Теория  $current / $total';
  }

  @override
  String get oppLessonTheoryNextButton => 'Келесі';

  @override
  String get oppLessonTheoryToQuestionsButton => 'Сұрақтарға өту';

  @override
  String oppLessonQuestionPill(int current, int total) {
    return '$total сұрақтың $current-і';
  }

  @override
  String get oppLessonCheckButton => 'Тексеру';

  @override
  String get oppLessonTrueFalseTrue => 'Дұрыс';

  @override
  String get oppLessonTrueFalseFalse => 'Дұрыс емес';

  @override
  String get oppLessonFeedbackCorrect => 'Дұрыс!';

  @override
  String get oppLessonFeedbackIncorrect => 'Дұрыс емес';

  @override
  String oppLessonFeedbackXpBadge(int xp) {
    return '+$xp XP';
  }

  @override
  String get oppLessonWhyExpander => 'Неліктен?';

  @override
  String get oppLessonContinueButton => 'Жалғастыру';

  @override
  String get oppLessonCompleteTitle => 'Сабақ аяқталды!';

  @override
  String get oppLessonCompleteSubtitle =>
      'Жарайсың! Ты аяқтадың ықтималдықтар туралы сабақты.';

  @override
  String get oppLessonXpEarned => 'Жинаған XP';

  @override
  String oppLessonXpValue(int xp) {
    return '+$xp XP';
  }

  @override
  String get oppLessonCorrectAnswersLabel => 'Дұрыс жауаптар';

  @override
  String oppLessonCorrectAnswersValue(int correct, int total) {
    return '$total сұрақтан $correct';
  }

  @override
  String get oppLessonDoneButton => 'Дайын';

  @override
  String get oppLessonTheoryProbabilityTitle => 'Ықтималдық деген не?';

  @override
  String get oppLessonTheoryProbabilityBody =>
      'Ықтималдық — оқиғаның орын алу мүмкіндігін сипаттайтын 0-ден 1-ге дейінгі сан. 0 — оқиға мүмкін емес, 1 — оқиға міндетті түрде болады. «Аралықтағы» барлық оқиғалардың ықтималдығы 0-ден үлкен және 1-ден кіші.';

  @override
  String get oppLessonTheoryFormulaTitle => 'Классикалық формула';

  @override
  String get oppLessonTheoryFormulaBody =>
      'P(A) = m / n, мұнда m — қолайлы нәтижелер саны, n — тең мүмкінді нәтижелердің жалпы саны. Мысалы: тиын лақтырамыз. n = 2 (бас және жазу), m = 1 (бас). Демек P(бас) = 1/2 = 0,5.';

  @override
  String get oppLessonTheoryComparingTitle => 'Ықтималдықтарды салыстыру';

  @override
  String get oppLessonTheoryComparingBody =>
      'Ықтималдықтар кәдімгі бөлшектер сияқты салыстырылады. P(A) > P(B) — A оқиғасы B-ге қарағанда жиі болады дегенді білдіреді. Мысалы: қалтадан қызыл шар алу ықтималдығы (10-нан 3 қызыл) = 3/10 = 0,3, ал көк = 7/10 = 0,7. Көк ықтималырақ.';

  @override
  String get oppLessonTheoryCertainTitle => 'Сенімді және мүмкін емес оқиғалар';

  @override
  String get oppLessonTheoryCertainBody =>
      'Сенімді оқиға әрқашан болады (P = 1). Мысалы: кубикті лақтырғанда 1-ден 6-ға дейінгі сан түседі — бұл сенімді. Мүмкін емес оқиға ешқашан болмайды (P = 0). Мысалы: сол кубикте 7 түседі.';

  @override
  String get oppLessonQ0Text =>
      'Тиын лақтырылады. Бастың түсу ықтималдығы қандай?';

  @override
  String get oppLessonQ0Explanation =>
      'Тиынның екі тең мүмкінді нәтижесі бар: бас және жазу. Сондықтан бас түсу ықтималдығы = 1/2 = 0,5.';

  @override
  String get oppLessonQ1Text => 'Сенімді оқиғаның ықтималдығы 1-ге тең.';

  @override
  String get oppLessonQ1OptionTrue => 'Дұрыс';

  @override
  String get oppLessonQ1OptionFalse => 'Дұрыс емес';

  @override
  String get oppLessonQ1Explanation =>
      'Сенімді оқиға — міндетті түрде болатын оқиға. Анықтамасы бойынша, оның ықтималдығы 1-ге тең.';

  @override
  String get oppLessonQ2Text => 'Мүмкін емес оқиғаның ықтималдығы ____ тең.';

  @override
  String get oppLessonQ2Explanation =>
      'Мүмкін емес оқиға ешқашан болуы мүмкін емес. Оның ықтималдығы анықтамасы бойынша 0-ге тең.';

  @override
  String get profScreenTitle => 'Профиль';

  @override
  String get profAddDataPrompt => 'Өзің туралы мәліметті қос →';

  @override
  String get profEditTooltip => 'Деректерді өңдеу';

  @override
  String profGoalChip(int minutes) {
    return 'Мақсат: $minutes мин/күн';
  }

  @override
  String get profDocPackagesSectionTitle => 'Құжаттар пакеті';

  @override
  String get profDocPackagesSectionSubtitle =>
      'Дайын болған сайын құжаттарды белгіле және файлдарды тіркеп қой';

  @override
  String get profMyDocsSectionTitle => 'Менің құжаттарым';

  @override
  String get profMyDocsSectionSubtitle =>
      'Файлдарды тіркеп, ашып, куратормен бөліс';

  @override
  String get profCareerTestCardTitle => 'Кәсіптік бағдар тесті';

  @override
  String get profCareerTestCardSubtitleDuration => '~10–15 минут уақыт алады';

  @override
  String profCareerTestCardSubtitleRetake(String result) {
    return 'Нәтиже: $result. Қайта тапсырасың ба?';
  }

  @override
  String get profCareerTestDialogTitle => 'Кәсіптік бағдар тесті';

  @override
  String get profCareerTestDialogBody =>
      'Тест 10–15 минут алады. Шынайы жауап бер — нәтиже дәлірек болады.';

  @override
  String get profCareerTestDialogCancel => 'Бас тарту';

  @override
  String get profCareerTestDialogConfirm => 'Жалғастыру';

  @override
  String get profNewPackageTitle => 'Жаңа пакет';

  @override
  String get profNewPackageNameLabel => 'Пакет атауы';

  @override
  String get profNewPackageNameHint => 'Мысалы: NU 2026';

  @override
  String get profNewPackageDescLabel => 'Сипаттама (міндетті емес)';

  @override
  String get profNewPackageDescHint =>
      'Назарбаев Университетіне арналған құжаттар';

  @override
  String get profCreatePackageButton => 'Пакет жасау';

  @override
  String profPackageProgress(int attached, int total) {
    return '$attached / $total расталды';
  }

  @override
  String get profDocActionOpen => 'Ашу';

  @override
  String get profDocActionReplace => 'Ауыстыру';

  @override
  String get profDocActionRemove => 'Пакеттен алып тастау';

  @override
  String get profDocAttachButton => 'Тіркеу';

  @override
  String get profNoAttachedFiles => 'Тіркелген файлдар жоқ';

  @override
  String get profAttachFileButton => 'Файл тіркеу';

  @override
  String get profDocActionShare => 'Бөлісу';

  @override
  String get profDocActionDelete => 'Жою';

  @override
  String get profAddDocumentButton => 'Құжат қосу';

  @override
  String get profAddDocSheetTitle => 'Құжат қосу';

  @override
  String profAddDocSheetSubtitle(String packageName) {
    return '«$packageName» пакетіне';
  }

  @override
  String get profAddDocUploadNew => 'Жаңа файл жүктеу';

  @override
  String get profAddDocAddSlot => 'Файлсыз тармақ қосу';

  @override
  String get profAddDocFromMyDocs => 'Менің құжаттарымнан';

  @override
  String get profAddDocNoSavedFiles =>
      'Сақталған файлдар жоқ. Жаңа файл жүктесең — ол «Менің құжаттарым» бөліміне де қосылады.';

  @override
  String get profAddSlotDialogTitle => 'Жаңа тармақ';

  @override
  String get profAddSlotDialogHint => 'Мысалы: Ұсыныс хаты';

  @override
  String get profAddSlotDialogCancel => 'Бас тарту';

  @override
  String get profAddSlotDialogAdd => 'Қосу';

  @override
  String get profEditScreenTitle => 'Менің деректерім';

  @override
  String get profEditSectionPersonal => 'Жеке деректер';

  @override
  String get profEditFieldNameLabel => 'Аты';

  @override
  String get profEditFieldNameHint => 'Есімің кім?';

  @override
  String get profEditFieldGradeLabel => 'Сынып';

  @override
  String get profEditFieldGradeHint => '11 сынып';

  @override
  String get profEditFieldCityLabel => 'Қала';

  @override
  String get profEditFieldCityHint => 'Алматы, Астана...';

  @override
  String get profEditFieldGpaLabel => 'Орташа балл / ҮБК';

  @override
  String get profEditFieldGpaHint => '4.8';

  @override
  String get profEditFieldLanguagesLabel => 'Тілдер (үтірмен бөліп)';

  @override
  String get profEditFieldLanguagesHint => 'KZ, RU, EN';

  @override
  String get profEditSectionAcademic => 'Бағыттар мен қызығушылықтар';

  @override
  String get profEditFieldMajorsLabel => 'Оқу бағыттары (үтірмен бөліп)';

  @override
  String get profEditFieldMajorsHint => 'IT, Медицина, Қаржы...';

  @override
  String get profEditFieldInterestsLabel =>
      'Қызығушылықтар мен хоббилер (үтірмен бөліп)';

  @override
  String get profEditFieldInterestsHint => 'Математика, Дизайн, Музыка...';

  @override
  String get profEditSectionExams => 'Емтихан нәтижелері';

  @override
  String get profEditFieldIeltsLabel => 'IELTS балл';

  @override
  String get profEditFieldIeltsHint => '7.0';

  @override
  String get profEditFieldSatLabel => 'SAT балл';

  @override
  String get profEditFieldSatHint => '1400';

  @override
  String get profEditFieldToeflLabel => 'TOEFL балл';

  @override
  String get profEditFieldToeflHint => '100';

  @override
  String get profEditSaveButton => 'Сақтау';

  @override
  String get profEditSavedSnackbar => 'Деректер сақталды';

  @override
  String get profCareerTestScreenTitle => 'Кәсіптік бағдар';

  @override
  String profCareerTestProgress(int current, int total) {
    return '$current / $total';
  }

  @override
  String get profCareerTestWarning =>
      'Тест ~10–15 минут алады. Шынайы жауап бер — нәтиже дәлірек болады.';

  @override
  String profCareerTestQuestionLabel(int number) {
    return '$number-сұрақ';
  }

  @override
  String get profCareerTestAnswerNo => 'Жоқ';

  @override
  String get profCareerTestAnswerNeutral => 'Бейтарап';

  @override
  String get profCareerTestAnswerYes => 'Иә';

  @override
  String get profCareerResultTitle => 'Нәтиже дайын!';

  @override
  String get profCareerResultProfileLabel => 'Сенің профилің';

  @override
  String get profCareerResultSavedNote =>
      'Нәтиже профиліңде сақталды. Тестті кез келген уақытта қайта тапсыра аласың.';

  @override
  String get profCareerResultCloseButton => 'Жабу';

  @override
  String profNotifierLoadError(String error) {
    return 'Жүктеу қатесі: $error';
  }

  @override
  String profNotifierSaveError(String error) {
    return 'Сақтау қатесі: $error';
  }

  @override
  String get profSeedPackageName => 'ҚЗ стандартты пакеті';

  @override
  String get profSeedPackageDesc =>
      'Қазақстанның ЖОО-ларына түсуге арналған үлгілі құжаттар жиыны';

  @override
  String get profSeedItemId => 'Жеке куәлік / Туу туралы куәлік';

  @override
  String get profSeedItemTranscript => 'Аттестат / Үлгерім транскрипті';

  @override
  String get profSeedItemMedical => '086-У медициналық анықтама';

  @override
  String get profSeedItemPhotos => '3×4 фотосурет (6 дана)';

  @override
  String get profSeedItemUnt => 'ҰБТ / ЕГЭ сертификаты';

  @override
  String get profSeedItemIntlExam =>
      'IELTS / TOEFL / SAT сертификаты (бар болса)';

  @override
  String get profSeedItemMotivation => 'Мотивациялық хат';

  @override
  String get profSeedItemRecommendations => 'Ұсыныс хаттары (2 дана)';

  @override
  String get profSeedItemApplication => 'Қабылдау өтінімі';

  @override
  String get profSeedItemParentalConsent =>
      'Ата-ананың келісімі (кәмелетке толмағандар үшін)';

  @override
  String get profCareerResultEngineerResearcher => 'Инженер-зерттеуші';

  @override
  String get profCareerResultArchitectDesigner => 'Сәулетші / Өнім дизайнері';

  @override
  String get profCareerResultScientistInnovator => 'Ғалым-новатор';

  @override
  String get profCareerResultHrCoach => 'HR-менеджер / Тренер';

  @override
  String get profCareerResultCfo => 'Қаржы директоры';

  @override
  String get profCareerResultArtTherapistEducator =>
      'Арт-терапевт / Шығармашыл педагог';

  @override
  String get profCareerResultEngineerTechnologist => 'Инженер / Технолог';

  @override
  String get profCareerResultScientistAnalyst => 'Ғалым / Аналитик';

  @override
  String get profCareerResultCreativeDesigner => 'Шығармашыл тұлға / Дизайнер';

  @override
  String get profCareerResultTeacherPsychologist => 'Педагог / Психолог';

  @override
  String get profCareerResultEntrepreneurManager => 'Кәсіпкер / Менеджер';

  @override
  String get profCareerResultFinancistAdministrator => 'Қаржыгер / Әкімші';

  @override
  String get profCareerQ1 =>
      'Маған заттарды өз қолыммен жинастыру және жөндеу ұнайды';

  @override
  String get profCareerQ2 => 'Мен ашық ауада жұмыс істеуді жөн көремін';

  @override
  String get profCareerQ3 =>
      'Маған техникалық құрылғылар мен механизмдер қызықты';

  @override
  String get profCareerQ4 => 'Мен физикалық еңбекті ұнатамын';

  @override
  String get profCareerQ5 =>
      'Маған құралдармен және жабдықтармен жұмыс істеу ұнайды';

  @override
  String get profCareerQ6 =>
      'Маған күрделі есептер мен жұмбақтарды шешу ұнайды';

  @override
  String get profCareerQ7 =>
      'Мен ғылыми мақалалар оқуға уақыт бөлуді жақсы көремін';

  @override
  String get profCareerQ8 =>
      'Маған айналамыздағы әлем қалай жасалғанын зерттеу қызықты';

  @override
  String get profCareerQ9 =>
      'Мен деректерді талдап, заңдылықтар іздеуді ұнатамын';

  @override
  String get profCareerQ10 => 'Маған тәжірибелер жүргізу ұнайды';

  @override
  String get profCareerQ11 =>
      'Мен сурет салуды, жазуды немесе музыка ойнауды ұнатамын';

  @override
  String get profCareerQ12 => 'Маған әдемі немесе бірегей нәрсе жасау ұнайды';

  @override
  String get profCareerQ13 => 'Мен жиі стандартты емес шешімдер табамын';

  @override
  String get profCareerQ14 => 'Шығармашылық өзін-өзі білдіру маған маңызды';

  @override
  String get profCareerQ15 => 'Маған дизайн мен эстетика ұнайды';

  @override
  String get profCareerQ16 => 'Маған басқа адамдарға көмектесу ұнайды';

  @override
  String get profCareerQ17 =>
      'Мен басқалардың көңіл-күйі мен эмоцияларын жақсы сеземін';

  @override
  String get profCareerQ18 => 'Маған командада жұмыс істеу ұнайды';

  @override
  String get profCareerQ19 => 'Мен басқаларды оқытуды жақсы көремін';

  @override
  String get profCareerQ20 => 'Волонтерлік және қоғамға көмек маған маңызды';

  @override
  String get profCareerQ21 =>
      'Маған адамдарды сендіру және келіссөздер жүргізу ұнайды';

  @override
  String get profCareerQ22 => 'Мен жауапкершілік алып, басқаруға дайынмын';

  @override
  String get profCareerQ23 => 'Маған бизнес құру тартымды';

  @override
  String get profCareerQ24 => 'Маған жарысып, жеңу ұнайды';

  @override
  String get profCareerQ25 => 'Мен идеялар мен өнімдерді сата аламын';

  @override
  String get profCareerQ26 =>
      'Маған сандармен және құжаттармен жұмыс істеу ұнайды';

  @override
  String get profCareerQ27 => 'Мен тәртіп пен ұйымшылдықты бағалаймын';

  @override
  String get profCareerQ28 =>
      'Маған нақты ережелер мен нұсқаулықтарды ұстану ұнайды';

  @override
  String get profCareerQ29 =>
      'Маған бухгалтерия, қаржы немесе деректерді басқару қызықты';

  @override
  String get profCareerQ30 => 'Мен ақпаратты жүйелеп, жіктеуді ұнатамын';

  @override
  String get sharedNavHome => 'Басты бет';

  @override
  String get sharedNavUniversities => 'ЖОО';

  @override
  String get sharedNavEraly => 'Ералы';

  @override
  String get sharedNavOpportunities => 'Мүмкіндіктер';

  @override
  String get sharedNavProfile => 'Профиль';

  @override
  String get sharedNotifStudyReminderTitle => 'Оқу уақыты келді!';

  @override
  String get sharedNotifStudyBody10 =>
      'Тек 10 минут — және сен мақсатқа бір қадам жақынырақсың!';

  @override
  String get sharedNotifStudyBody20 =>
      'Бүгін 20 минут сабақ — сен жасай аласың!';

  @override
  String sharedNotifStudyBody30(int minutes) {
    return 'Бүгін $minutes минут оқу жоспарланған. Бастаймыз ба?';
  }

  @override
  String sharedNotifStudyBodyBig(int minutes) {
    return 'Бүгін үлкен мақсат: $minutes минут. Сәттілік!';
  }

  @override
  String sharedNotifCalendarNowTitle(String eventTitle) {
    return 'Қазір: $eventTitle';
  }

  @override
  String get sharedNotifCalendarNowBody => 'Іс-шара басталды!';

  @override
  String sharedNotifCalendarSoonTitle(String eventTitle) {
    return 'Жақында: $eventTitle';
  }

  @override
  String get sharedNotifCalendarSoonBody => 'Бүгінге жоспарланған.';

  @override
  String sharedNotifTodoNudgeTitle(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Бүгін $count тапсырмаң бар',
    );
    return '$_temp0';
  }

  @override
  String get sharedNotifChannelName => 'Күнделікті еске салулар';

  @override
  String get sharedNotifChannelDesc =>
      'Күнделікті оқу және алдағы іс-шаралар туралы еске салулар';

  @override
  String get uniTitle => 'ЖОО';

  @override
  String uniSubtitleKz(int count) {
    return 'Қазақстанның $count ЖОО-сы';
  }

  @override
  String get uniErrorLoad => 'ЖОО тізімін жүктеу мүмкін болмады';

  @override
  String get uniEmptyList => 'ЖОО тізімі бос';

  @override
  String get uniNoResults => 'Таңдалған сүзгілер бойынша ЖОО жоқ';

  @override
  String get uniFilterCity => 'Қала';

  @override
  String get uniFilterType => 'Түр';

  @override
  String get uniFilterReset => 'Тазарту';

  @override
  String get uniPickCityTitle => 'Қала таңдау';

  @override
  String get uniPickTypeTitle => 'Түр таңдау';

  @override
  String get uniFilterClearItem => 'Сүзгіні тазарту';

  @override
  String uniProgramCount(int count) {
    return '$count бағдарлама';
  }

  @override
  String uniCompetitionFrom(int score) {
    return 'конкурс $score б-дан';
  }

  @override
  String get uniTypeNational => 'Ұлттық';

  @override
  String get uniTypeState => 'Мемлекеттік';

  @override
  String get uniTypeAutonomous => 'Автономды';

  @override
  String get uniTypePrivate => 'Жеке';

  @override
  String get uniTypeInternational => 'Халықаралық';

  @override
  String get uniHubSubtitle => 'Қай ЖОО-ны зерттегіңді таңда';

  @override
  String get uniHubKzTitle => 'Қазақстан ЖОО-лары';

  @override
  String get uniHubKzSubtitle =>
      'Конкурстық баллдар мен ГБП бар 88+ ЖОО каталогы';

  @override
  String get uniHubAbroadTitle => 'Шетелдегі ЖОО-лар';

  @override
  String get uniHubAbroadSubtitle =>
      'Шетелдіктерге қаржылық көмек бар топ әлемдік университеттер';

  @override
  String get uniAbroadTitle => 'Шетелдегі ЖОО-лар';

  @override
  String uniAbroadCountSubtitle(int count) {
    return 'Әлемнің $count ЖОО-сы';
  }

  @override
  String get uniAbroadErrorLoad => 'Шетелдік ЖОО тізімін жүктеу мүмкін болмады';

  @override
  String get uniAbroadEmptyList => 'Шетелдік ЖОО тізімі бос';

  @override
  String get uniAbroadMatchBadge => 'сәйкестік';

  @override
  String uniAbroadTuitionPerYear(String price) {
    return '\$$price/жыл';
  }

  @override
  String get uniFinAidNeedBlind => 'Мұқтаждыққа қарамай қабылдау';

  @override
  String get uniFinAidGenerous => 'Мол қаржылық көмек';

  @override
  String get uniFinAidLimited => 'Шектеулі қаржылық көмек';

  @override
  String get uniFinAidNone => 'Қаржылық көмексіз';

  @override
  String get uniShortFinAidNeedBlind => 'need-blind';

  @override
  String get uniShortFinAidGenerous => 'мол гранттар';

  @override
  String get uniShortFinAidLimited => 'шект. көмек';

  @override
  String get uniShortFinAidNone => 'көмексіз';

  @override
  String get uniDetailErrorLoad => 'Деректерді жүктеу мүмкін болмады';

  @override
  String get uniDetailNotFound => 'ЖОО табылмады';

  @override
  String get uniDetailFinanceSection => 'Қаржы';

  @override
  String get uniDetailFinAidLabel => 'Қаржылық көмек';

  @override
  String get uniDetailTuitionLabel => 'Жылдық құны';

  @override
  String get uniDetailMajorsSection => 'Бағыттар';

  @override
  String uniDetailSourceLink(String url) {
    return 'Дереккөз: $url';
  }

  @override
  String get uniMajorCs => 'CS';

  @override
  String get uniMajorEngineering => 'Инженерия';

  @override
  String get uniMajorMathematics => 'Математика';

  @override
  String get uniMajorPhysics => 'Физика';

  @override
  String get uniMajorChemistry => 'Химия';

  @override
  String get uniMajorBiology => 'Биология';

  @override
  String get uniMajorMedicine => 'Медицина';

  @override
  String get uniMajorEconomics => 'Экономика';

  @override
  String get uniMajorBusiness => 'Бизнес';

  @override
  String get uniMajorPsychology => 'Психология';

  @override
  String get uniMajorPolitics => 'Саясаттану';

  @override
  String get uniDetailKzErrorLoad => 'ЖОО-ны жүктеу мүмкін болмады';

  @override
  String get uniDetailKzNotFound => 'ЖОО табылмады';

  @override
  String get uniDetailHasDormYes => 'Иә';

  @override
  String get uniDetailHasDormNo => 'Жоқ';

  @override
  String get uniDetailHasDormitory => 'Жатақхана бар';

  @override
  String get uniDetailStatPrograms => 'бағдарлама';

  @override
  String get uniDetailStatCompetition => 'конкурс б-дан';

  @override
  String get uniDetailStatDormitory => 'жатақхана';

  @override
  String get uniDetailAboutSection => 'ЖОО туралы';

  @override
  String get uniDetailInfoSection => 'Ақпарат';

  @override
  String uniDetailProgramsSection(int count) {
    return 'Бағдарламалар ($count)';
  }

  @override
  String get uniDetailProgramsNote =>
      'Балл — грантқа конкурсқа қатысудың ең аз шегі (ҰБТ). Бұл өту баллы емес. Толық мәліметті ашу үшін бағдарламаны басыңыз.';

  @override
  String uniDetailCompetitionFrom(int score) {
    return 'Конкурс $score б-дан';
  }

  @override
  String get uniDetailLanguagesLabel => 'Оқыту тілдері';

  @override
  String get uniDetailGrantPlacesLabel => 'Грант орындары';

  @override
  String get uniDetailTuitionKztLabel => 'Жылдық құны';

  @override
  String get uniDetailNoScoreData => 'Баллдар бойынша деректер әзірге жоқ.';

  @override
  String get uniDetailScoresByYear => 'Жылдар бойынша баллдар';

  @override
  String get uniDetailUnverified => 'расталмаған';

  @override
  String get uniDetailEmptyPrograms =>
      'Бұл ЖОО үшін бағдарламалар мен гранттар бойынша деректер әзірге жоқ.';

  @override
  String get uniDetailSourcesTitle => 'Деректер көздері';

  @override
  String get uniLangKz => 'қаз';

  @override
  String get uniLangRu => 'орыс';

  @override
  String get uniLangEn => 'ағылш';

  @override
  String get uniQuotaGeneral => 'Жалпы конкурс';

  @override
  String get uniQuotaRural => 'Ауыл квотасы';

  @override
  String get uniQuotaLyceum => 'Лицей квотасы';

  @override
  String get uniQuotaOrphan => 'Жетімдер квотасы';

  @override
  String get uniQuotaDisability => 'Мүгедектік квотасы';

  @override
  String get uniQuotaOralman => 'Қандастар квотасы';

  @override
  String get uniQuotaOther => 'Өзге квота';

  @override
  String get uniGrantMetricCutoff => 'Грантқа өту баллы';

  @override
  String get uniGrantMetricCompetitionMin =>
      'Грант конкурсына қатысудың ең аз шегі';

  @override
  String get uniGrantMetricPaidMin => 'Ақылы оқуға ең аз балл';

  @override
  String get uniGrantMetricNationalFloor => 'Табалдырық минимум (ЖҒБМ бұйрығы)';
}
