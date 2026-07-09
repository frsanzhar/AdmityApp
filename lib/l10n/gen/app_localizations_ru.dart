// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Russian (`ru`).
class AppLocalizationsRu extends AppLocalizations {
  AppLocalizationsRu([String locale = 'ru']) : super(locale);

  @override
  String get appTitle => 'Admity';

  @override
  String get languageSectionTitle => 'Язык приложения';

  @override
  String get languageSystem => 'Как в системе';

  @override
  String get languageRussian => 'Русский';

  @override
  String get languageKazakh => 'Қазақша';

  @override
  String get languageEnglish => 'English';

  @override
  String get authWelcomeTitle => 'Добро пожаловать';

  @override
  String get authCreateAccountTitle => 'Создать аккаунт';

  @override
  String get authSignInSubtitle => 'Войдите, чтобы продолжить';

  @override
  String get authSignUpSubtitle => 'Введите данные, чтобы начать';

  @override
  String get authEmailLabel => 'Email';

  @override
  String get authPasswordLabel => 'Пароль';

  @override
  String get authEmailRequired => 'Введите email';

  @override
  String get authEmailInvalid => 'Некорректный email';

  @override
  String get authPasswordRequired => 'Введите пароль';

  @override
  String get authPasswordMinLength => 'Минимум 6 символов';

  @override
  String get authSignInButton => 'Войти';

  @override
  String get authSignUpButton => 'Зарегистрироваться';

  @override
  String get authAlreadyHaveAccount => 'Уже есть аккаунт? Войти';

  @override
  String get authNoAccount => 'Нет аккаунта? Зарегистрироваться';

  @override
  String get authOrDivider => 'или';

  @override
  String get authContinueWithGoogle => 'Продолжить с Google';

  @override
  String get authContinueWithApple => 'Продолжить с Apple';

  @override
  String get authContinueAsGuest => 'Продолжить как гость';

  @override
  String get authErrorSignIn =>
      'Не удалось войти. Проверьте подключение и попробуйте снова.';

  @override
  String get authErrorCreateAccount =>
      'Не удалось создать аккаунт. Проверьте подключение и попробуйте снова.';

  @override
  String get authErrorGoogleNotConfigured =>
      'Вход через Google ещё не настроен. Добавьте GOOGLE_WEB_CLIENT_ID.';

  @override
  String get authErrorCancelled => 'Вход отменён.';

  @override
  String get authErrorGoogleTokenFailed =>
      'Не удалось получить токен Google. Попробуйте снова.';

  @override
  String get authErrorGoogleSignIn =>
      'Не удалось войти через Google. Попробуйте снова.';

  @override
  String get authErrorAppleTokenFailed =>
      'Не удалось получить токен Apple. Попробуйте снова.';

  @override
  String get authErrorAppleSignIn =>
      'Не удалось войти через Apple. Попробуйте снова.';

  @override
  String authErrorAppleRaw(String message) {
    return 'Apple Sign In: $message';
  }

  @override
  String get authErrorGuestFailed => 'Не удалось создать гостевой профиль.';

  @override
  String get authErrorInvalidCredentials => 'Неверный email или пароль.';

  @override
  String get authErrorEmailNotConfirmed =>
      'Подтвердите email по ссылке из письма.';

  @override
  String get authErrorEmailAlreadyRegistered =>
      'Этот email уже зарегистрирован. Попробуйте войти.';

  @override
  String get authErrorPasswordTooShort =>
      'Пароль должен содержать не менее 6 символов.';

  @override
  String get authErrorRateLimit =>
      'Слишком много попыток. Подождите немного и повторите.';

  @override
  String get homeGreeting => 'Привет!';

  @override
  String get homeGreetingSubtitle => 'Готов к новым знаниям?';

  @override
  String homeStreakSemanticLabel(int count, String dayWord) {
    return 'Серия: $count $dayWord';
  }

  @override
  String get homeStreakStart => 'Начни свою серию!';

  @override
  String homeStreakActive(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count дня',
      many: '$count дней',
      few: '$count дня',
      one: '$count день',
    );
    return 'Серия — $_temp0';
  }

  @override
  String get homeStreakDayDone => 'День завершён!';

  @override
  String get homeStreakDayNotDone => 'Ещё не завершён';

  @override
  String homeStreakWeekSummary(int count) {
    return '$count из 7 дней на этой неделе';
  }

  @override
  String get homeWeekdayMon => 'Пн';

  @override
  String get homeWeekdayTue => 'Вт';

  @override
  String get homeWeekdayWed => 'Ср';

  @override
  String get homeWeekdayThu => 'Чт';

  @override
  String get homeWeekdayFri => 'Пт';

  @override
  String get homeWeekdaySat => 'Сб';

  @override
  String get homeWeekdaySun => 'Вс';

  @override
  String get homeCalendarMonthJan => 'Январь';

  @override
  String get homeCalendarMonthFeb => 'Февраль';

  @override
  String get homeCalendarMonthMar => 'Март';

  @override
  String get homeCalendarMonthApr => 'Апрель';

  @override
  String get homeCalendarMonthMay => 'Май';

  @override
  String get homeCalendarMonthJun => 'Июнь';

  @override
  String get homeCalendarMonthJul => 'Июль';

  @override
  String get homeCalendarMonthAug => 'Август';

  @override
  String get homeCalendarMonthSep => 'Сентябрь';

  @override
  String get homeCalendarMonthOct => 'Октябрь';

  @override
  String get homeCalendarMonthNov => 'Ноябрь';

  @override
  String get homeCalendarMonthDec => 'Декабрь';

  @override
  String get homeCalendarAgendaMonthGenJan => 'января';

  @override
  String get homeCalendarAgendaMonthGenFeb => 'февраля';

  @override
  String get homeCalendarAgendaMonthGenMar => 'марта';

  @override
  String get homeCalendarAgendaMonthGenApr => 'апреля';

  @override
  String get homeCalendarAgendaMonthGenMay => 'мая';

  @override
  String get homeCalendarAgendaMonthGenJun => 'июня';

  @override
  String get homeCalendarAgendaMonthGenJul => 'июля';

  @override
  String get homeCalendarAgendaMonthGenAug => 'августа';

  @override
  String get homeCalendarAgendaMonthGenSep => 'сентября';

  @override
  String get homeCalendarAgendaMonthGenOct => 'октября';

  @override
  String get homeCalendarAgendaMonthGenNov => 'ноября';

  @override
  String get homeCalendarAgendaMonthGenDec => 'декабря';

  @override
  String get homeCalendarWeekdayFullMon => 'Понедельник';

  @override
  String get homeCalendarWeekdayFullTue => 'Вторник';

  @override
  String get homeCalendarWeekdayFullWed => 'Среда';

  @override
  String get homeCalendarWeekdayFullThu => 'Четверг';

  @override
  String get homeCalendarWeekdayFullFri => 'Пятница';

  @override
  String get homeCalendarWeekdayFullSat => 'Суббота';

  @override
  String get homeCalendarWeekdayFullSun => 'Воскресенье';

  @override
  String get homeCalendarNoEvents => 'Событий нет. Добавьте первое!';

  @override
  String get homeCalendarEralyBadge => 'Ералы';

  @override
  String get homeCalendarAddEvent => 'Добавить событие';

  @override
  String get homeEventSheetTitleNew => 'Новое событие';

  @override
  String get homeEventSheetTitleEdit => 'Редактировать событие';

  @override
  String get homeEventSheetFieldTitleLabel => 'Название';

  @override
  String get homeEventSheetFieldTitleHint => 'Что запланировано?';

  @override
  String get homeEventSheetFieldDescLabel => 'Описание';

  @override
  String get homeEventSheetFieldDescHint => 'Подробности (необязательно)';

  @override
  String get homeEventSheetSave => 'Сохранить';

  @override
  String get homeEventSheetDelete => 'Удалить событие';

  @override
  String get homeTodayTaskTitle => 'Задание на сегодня';

  @override
  String get homeTodayTaskBody =>
      'Урок: Сравнение вероятностей — продолжи с того места, где остановился.';

  @override
  String get homeTodayTaskContinue => 'Продолжить';

  @override
  String get homeTaskListTitle => 'Сегодняшние задачи';

  @override
  String get homeTaskListEmpty => 'Задач нет. Нажмите + чтобы добавить.';

  @override
  String get homeTaskSheetTitleNew => 'Новая задача';

  @override
  String get homeTaskSheetTitleEdit => 'Редактировать';

  @override
  String get homeTaskSheetFieldTitleLabel => 'Название';

  @override
  String get homeTaskSheetFieldTitleHint => 'Что нужно сделать?';

  @override
  String get homeTaskSheetFieldDescLabel => 'Описание';

  @override
  String get homeTaskSheetFieldDescHint => 'Подробности (необязательно)';

  @override
  String get homeTaskSheetNoDescription => 'Описание не добавлено.';

  @override
  String get homeTaskSheetSave => 'Сохранить';

  @override
  String get homeTaskSheetDelete => 'Удалить задачу';

  @override
  String get homeDefaultTodo1Title => 'Пройти урок по математике';

  @override
  String get homeDefaultTodo1Desc =>
      'Раздел «Сравнение вероятностей» — примерно 15 минут.';

  @override
  String get homeDefaultTodo2Title => 'Изучить стипендии БОЛАШАК';

  @override
  String get homeDefaultTodo2Desc =>
      'Проверить требования для поступления и дедлайн подачи документов.';

  @override
  String get homeDefaultTodo3Title => 'Обновить профиль';

  @override
  String get homeDefaultTodo3Desc =>
      'Добавить последние оценки и загрузить актуальные документы.';

  @override
  String get homeDefaultTodo4Title => 'Прочитать о ЕНТ требованиях';

  @override
  String get homeDefaultTodo4Desc =>
      'Минимальные баллы по каждому предмету для поступления.';

  @override
  String get homeCareerCardTitle => 'Узнай свою профессию';

  @override
  String get homeCareerCardSubtitle => 'Ежедневный тест — 3 минуты';

  @override
  String get homeCareerCardButton => 'Пройти тест';

  @override
  String get eralyName => 'Ералы';

  @override
  String get eralySubtitle => 'AI-наставник';

  @override
  String get eralyTypingText => 'Ералы думает...';

  @override
  String get eralyReviewEventsButton => 'Проверить все мероприятия';

  @override
  String get eralyOpenPlanButton => 'Открыть план';

  @override
  String get eralyToneStrictLabel => 'Строгий\nнаставник';

  @override
  String get eralyToneStrictDescription => 'Прямо и по делу';

  @override
  String get eralyToneFriendlyLabel => 'Дружеский\nнаставник';

  @override
  String get eralyToneFriendlyDescription => 'Тепло и поддержка';

  @override
  String get eralyInputHint => 'Напиши Ералы...';

  @override
  String get eralyTonePrompt =>
      'Привет! Я Ералы — твой AI-наставник по поступлению. Прежде чем начать, выбери, как мне с тобой общаться:';

  @override
  String get eralyGreetingStrict =>
      'Хорошо. Работаем серьёзно: ставим цели, держим дисциплину и не отвлекаемся на лишнее. Расскажи — куда поступаешь и что уже сделал для этого?';

  @override
  String get eralyGreetingFriendly =>
      'Отлично! Я рядом — буду поддерживать и помогать на каждом шаге. Расскажи о себе: куда хочешь поступить и с чего начнём?';

  @override
  String eralyEventsProposedAnnounce(int count) {
    return 'Я подготовил $count мероприятия. Нажми «Проверить все мероприятия», чтобы просмотреть и изменить время.';
  }

  @override
  String get eralyEventsProposeLoading =>
      'Отлично! Дай мне секунду — предложу несколько мероприятий...';

  @override
  String get eralyEventsSaved =>
      'Все мероприятия сохранены в календарь! Ты можешь просмотреть их в разделе «Главная». Чем ещё могу помочь?';

  @override
  String get eralyPlanGenerating => 'Составляю план — одну секунду...';

  @override
  String eralyPlanReady(String topic, int lessonCount) {
    return 'Готово! Я составил план «$topic» из $lessonCount уроков. Прокрути вниз, чтобы увидеть его. Если хочешь что-то изменить — спроси!';
  }

  @override
  String get eralyQuestionResources =>
      'Хорошо, начнём! Какие учебные материалы у тебя есть? (книги, онлайн-курсы, приложения — перечисли, что имеется)';

  @override
  String get eralyQuestionTime =>
      'Понял. Сколько времени в неделю ты можешь уделять подготовке? (например: «2 часа в день» или «10 часов в неделю»)';

  @override
  String get eralyQuestionInternet =>
      'Есть ли у тебя стабильный доступ к интернету для онлайн-ресурсов? (да / нет)';

  @override
  String get eralyOfflineIeltsStrict =>
      'IELTS. Сначала скажи: какие материалы уже есть? Без чёткого инвентаря план не построить.';

  @override
  String get eralyOfflineIeltsFriendly =>
      'IELTS — отличная цель! Давай составим персональный план. Для начала: какие материалы у тебя уже есть? (учебники, приложения, курсы — перечисли всё)';

  @override
  String get eralyOfflineSatStrict =>
      'SAT требует системной работы. Какими ресурсами пользуешься? Перечисли конкретно.';

  @override
  String get eralyOfflineSatFriendly =>
      'SAT — серьёзный шаг! Я помогу разбить подготовку на чёткие уроки. Расскажи, какими ресурсами ты пользуешься?';

  @override
  String get eralyOfflineEntStrict =>
      'ЕНТ — главный экзамен. Сколько недель до него? Назови точную дату — составим план без воды.';

  @override
  String get eralyOfflineEntFriendly =>
      'ЕНТ — ключевой экзамен. Хочешь составить поурочный план? Напиши, сколько времени у тебя есть до экзамена.';

  @override
  String get eralyOfflinePlanStrict =>
      'Назови тему или экзамен. Потом задам три вопроса — и составлю план без лишних слов.';

  @override
  String get eralyOfflinePlanFriendly =>
      'Конечно, помогу составить план! Назови тему или экзамен, и я задам несколько вопросов, чтобы сделать план под тебя.';

  @override
  String get eralyOfflineEventsStrict =>
      'Укажи тему мероприятий. Предложу конкретные даты — ты проверяешь и подтверждаешь.';

  @override
  String get eralyOfflineEventsFriendly =>
      'С удовольствием помогу! Напиши тему или цель мероприятий — я предложу несколько конкретных дат и могу поставить их в календарь.';

  @override
  String get eralyOfflineScholarshipStrict =>
      'Стипендии: казахстанские или зарубежные? Ответь кратко — подберу варианты под профиль.';

  @override
  String get eralyOfflineScholarshipFriendly =>
      'Стипендии — моя любимая тема! Расскажи: ты смотришь на казахстанские программы или зарубежные? Это поможет мне точнее подобрать варианты.';

  @override
  String get eralyOfflineUniversityStrict =>
      'Конкретно: в какую страну и в какой университет целишься? Чем точнее — тем полезнее анализ.';

  @override
  String get eralyOfflineUniversityFriendly =>
      'Поступление — большой шаг, и я рядом. В какую страну или университет ты целишься? Или пока только изучаешь варианты?';

  @override
  String get eralyOfflineGreetingStrict =>
      'Начнём. Куда поступаешь и что уже сделал? Конкретика — основа работы.';

  @override
  String get eralyOfflineGreetingFriendly =>
      'Привет! Расскажи немного о себе — куда хочешь поступить, что уже пробовал делать для этого? Чем больше ты расскажешь, тем точнее я смогу помочь.';

  @override
  String get eralyOfflineFollowUpStrict1 =>
      'Уточни задачу: экзамен, поступление или что-то другое? Коротко.';

  @override
  String get eralyOfflineFollowUpStrict2 =>
      'Понял. Скажи конкретнее — это для ЕНТ, международного экзамена или вуза?';

  @override
  String get eralyOfflineFollowUpStrict3 =>
      'Хорошо. Что именно нужно — план, анализ шансов или список стипендий?';

  @override
  String get eralyOfflineFollowUpFriendly1 =>
      'Интересно! Расскажи подробнее — я хочу понять, чем именно помочь.';

  @override
  String get eralyOfflineFollowUpFriendly2 =>
      'Хороший вопрос. Уточни, пожалуйста: ты спрашиваешь про экзамены, поступление или что-то другое?';

  @override
  String get eralyOfflineFollowUpFriendly3 =>
      'Понял. Чтобы дать точный ответ, скажи: это для ЕНТ, международного экзамена или для чего-то ещё?';

  @override
  String eralyOfflineEventTitle1(String topic) {
    return 'Старт: $topic';
  }

  @override
  String get eralyOfflineEventDescription1 =>
      'Первое знакомство с темой — изучи ключевые понятия и составь список вопросов.';

  @override
  String eralyOfflineEventTitle2(String topic) {
    return 'Практика: $topic';
  }

  @override
  String get eralyOfflineEventDescription2 =>
      'Практическое занятие — реши 10–15 задач или сделай пробный тест.';

  @override
  String eralyOfflineEventTitle3(String topic) {
    return 'Повторение: $topic';
  }

  @override
  String get eralyOfflineEventDescription3 =>
      'Итоговое повторение — закрепи слабые места и проверь прогресс.';

  @override
  String get eralyOfflinePlanNotes =>
      'Базовый офлайн-план. Подключитесь к интернету, чтобы Ералы составил план под ваши материалы и расписание.';

  @override
  String eralyOfflinePlanLesson1Title(String topic) {
    return 'Введение в $topic';
  }

  @override
  String eralyOfflinePlanLesson2Title(String topic) {
    return 'Ключевые концепции $topic';
  }

  @override
  String get eralyOfflinePlanLesson3Title => 'Практические упражнения';

  @override
  String get eralyOfflinePlanLesson4Title => 'Разбор ошибок и слабых мест';

  @override
  String get eralyOfflinePlanLesson5Title =>
      'Пробный тест и итоговое повторение';

  @override
  String eralyParsedEventFallbackTitle(int number) {
    return 'Событие $number';
  }

  @override
  String eralyParsedLessonFallbackTitle(int number) {
    return 'Урок $number';
  }

  @override
  String get onbIntro =>
      'Поступление в университет — это большой шаг. Admity поможет пройти его уверенно.';

  @override
  String get onbWhoAreYou => 'Кто ты?';

  @override
  String get onbRoleStudentLabel => 'Я учусь';

  @override
  String get onbRoleStudentDesc => 'Готовлюсь к поступлению';

  @override
  String get onbRoleParentLabel => 'Родитель';

  @override
  String get onbRoleParentDesc => 'Помогаю ребёнку поступить';

  @override
  String get onbRoleTeacherLabel => 'Учитель';

  @override
  String get onbRoleTeacherDesc => 'Готовлю учеников к вузу';

  @override
  String get onbNextButton => 'Далее';

  @override
  String get onbMascotGreetingName => 'Привет! Я — Ералы,';

  @override
  String get onbMascotGreetingDesc =>
      'твой персональный наставник по поступлению. Расскажу, что нужно знать, и помогу не пропустить ни одной возможности.';

  @override
  String get onbMotivationTitle => 'Какова твоя цель?';

  @override
  String get onbMotivationSubtitle => 'Это поможет подобрать правильный путь';

  @override
  String get onbMotivationTopKzLabel => 'Поступить в топ-вуз Казахстана';

  @override
  String get onbMotivationTopKzDesc => 'НУ, КБТУ, КазНУ и другие';

  @override
  String get onbMotivationAbroadLabel => 'Поступить в вуз за рубежом';

  @override
  String get onbMotivationAbroadDesc => 'США, Европа, Азия и другие страны';

  @override
  String get onbMotivationExploreLabel => 'Профориентация';

  @override
  String get onbMotivationExploreDesc => 'Ещё выбираю направление';

  @override
  String get onbAgeTitle => 'Сколько тебе лет?';

  @override
  String get onbAgeSubtitle => 'Поможет подобрать контент по возрасту.';

  @override
  String get onbAgeHint => '16';

  @override
  String get onbSubjectTitle => 'Какие предметы интересны как Major?';

  @override
  String get onbSubjectSubtitle => 'Можно выбрать несколько';

  @override
  String get onbSubjectPsychologyLabel => 'Психология';

  @override
  String get onbSubjectPsychologyDesc => 'Поведение и психика';

  @override
  String get onbSubjectPoliticsLabel => 'Политика';

  @override
  String get onbSubjectPoliticsDesc => 'Политология и дипломатия';

  @override
  String get onbSubjectEconomicsLabel => 'Экономика';

  @override
  String get onbSubjectEconomicsDesc => 'Финансы и бизнес';

  @override
  String get onbSubjectChemistryLabel => 'Химия';

  @override
  String get onbSubjectChemistryDesc => 'Реакции и вещества';

  @override
  String get onbSubjectBiologyLabel => 'Биология';

  @override
  String get onbSubjectBiologyDesc => 'Жизнь и медицина';

  @override
  String get onbSubjectPhysicsLabel => 'Физика';

  @override
  String get onbSubjectPhysicsDesc => 'Механика и кванты';

  @override
  String get onbSubjectMathLabel => 'Математика';

  @override
  String get onbSubjectMathDesc => 'Алгебра и анализ';

  @override
  String get onbTrustTitle => 'Построено с экспертами ведущих вузов';

  @override
  String get onbTrustSubtitle =>
      'Контент разработан при участии методистов университетов Казахстана и международных партнёров.';

  @override
  String get onbConfidenceTitle => 'Насколько ты уверен, что поступишь?';

  @override
  String get onbConfidenceSubtitle =>
      'Честный ответ поможет правильно составить план';

  @override
  String get onbConfidence100Label => 'Уверен на 100%';

  @override
  String get onbConfidence100Desc => 'Знаю, что поступлю';

  @override
  String get onbConfidenceMostlyYesLabel => 'Скорее да';

  @override
  String get onbConfidenceMostlyYesDesc => 'Хороший шанс есть';

  @override
  String get onbConfidenceNotSureLabel => 'Ещё не уверен';

  @override
  String get onbConfidenceNotSureDesc => 'Нужно больше подготовки';

  @override
  String get onbConfidenceJustStartingLabel => 'Только начинаю';

  @override
  String get onbConfidenceJustStartingDesc => 'Ещё не разобрался с целями';

  @override
  String get onbStatsTitle => 'Твои академические показатели';

  @override
  String get onbStatsSubtitle =>
      'Необязательно — можно пропустить. Это нужно для честной оценки шансов.';

  @override
  String get onbStatsGpaLabel => 'ГПА / Средний балл';

  @override
  String get onbStatsGpaHint => 'Например: 4.8';

  @override
  String get onbStatsIeltsLabel => 'IELTS (если есть)';

  @override
  String get onbStatsIeltsHint => 'Например: 7.0';

  @override
  String get onbStatsSatLabel => 'SAT (если есть)';

  @override
  String get onbStatsSatHint => 'Например: 1400';

  @override
  String get onbTopicUniverseTitle => 'Всё, что нужно — уже здесь';

  @override
  String get onbTopicUniverseMascotCaption => 'Я знаю, с чего начать';

  @override
  String get onbGoalTitle => 'Сколько времени в день?';

  @override
  String get onbGoalMinUnit => 'мин';

  @override
  String get onbGoal10Subtitle => 'Немного, но каждый день';

  @override
  String get onbGoal20Subtitle => 'Стабильный прогресс';

  @override
  String get onbGoal30Subtitle => 'Хороший темп';

  @override
  String get onbGoal60Subtitle => 'Погружение';

  @override
  String get onbScheduleTitle => 'Когда удобнее?';

  @override
  String get onbScheduleMorningLabel => 'Утро';

  @override
  String get onbScheduleMorningSubtitle => 'До начала дня';

  @override
  String get onbScheduleDayLabel => 'День';

  @override
  String get onbScheduleDaySubtitle => 'В свободное время';

  @override
  String get onbScheduleEveningLabel => 'Вечер';

  @override
  String get onbScheduleEveningSubtitle => 'После учёбы';

  @override
  String get onbScheduleFlexLabel => 'Когда получится';

  @override
  String get onbScheduleFlexSubtitle => 'Гибкий график';

  @override
  String get onbNotificationsTitle => 'Напоминания';

  @override
  String get onbNotificationsBody =>
      'Хочешь, чтобы Admity напоминал о занятиях?';

  @override
  String get onbNotificationsEnableButton => 'Включить';

  @override
  String get onbNotificationsSkipButton => 'Пропустить';

  @override
  String get onbThreeStepTitle => 'Твой план на три шага';

  @override
  String get onbPlanStep1Title => 'Изучи основы';

  @override
  String get onbPlanStep1Desc => 'Разберём базу по твоему предмету';

  @override
  String get onbPlanStep2Title => 'Практикуй';

  @override
  String get onbPlanStep2Desc => 'Задачи, тесты, разборы ошибок';

  @override
  String get onbPlanStep3Title => 'Проверь себя';

  @override
  String get onbPlanStep3Desc => 'Финальный skill-check и анализ результатов';

  @override
  String get onbCreatePlanButton => 'Создать мой план';

  @override
  String get onbPlanCreationTitle => 'Создаём твой план…';

  @override
  String get onbPlanCreationCard1 => 'Анализируем твой профиль';

  @override
  String get onbPlanCreationCard2 => 'Подбираем вузы и направления';

  @override
  String get onbPlanCreationCard3 => 'Строим персональный путь';

  @override
  String get onbPlanCreationAlmost => 'Почти готово…';

  @override
  String get onbFinishTitle => 'Всё готово!';

  @override
  String get onbFinishSubtitle => 'Твой персональный план создан. Начинаем?';

  @override
  String get onbFinishStartButton => 'Начать';

  @override
  String get onbReminderTitle => 'Время учиться с Admity 🎓';

  @override
  String onbReminderBody(int minutes) {
    return 'Удели $minutes мин подготовке к поступлению — ты на верном пути!';
  }

  @override
  String onbStudyPlanCareerTest(String major) {
    return 'Пройди профориентационный тест, чтобы подтвердить интерес к $major';
  }

  @override
  String get onbStudyPlanUpdateProfile =>
      'Убедись, что профиль — ЕНТ, ГПА, оценки — актуален и точен';

  @override
  String onbStudyPlanExploreRequirements(String major) {
    return 'Изучи вступительные требования и проходные баллы по направлению $major';
  }

  @override
  String get onbStudyPlanTargetList =>
      'Составь список целевых вузов (Казахстан и/или за рубежом) с дедлайнами';

  @override
  String onbStudyPlanDailyTime(String timeLabel) {
    return 'Выдели $timeLabel ежедневное время для подготовки и придерживайся расписания';
  }

  @override
  String get onbStudyPlanPracticeTests =>
      'Практикуй тестовые задания ЕНТ / международные экзамены по выбранным предметам';

  @override
  String get onbStudyPlanIntlDocs =>
      'Подготовь документы для международных заявок: эссе, рекомендации, языковые сертификаты';

  @override
  String get onbStudyPlanLocalDocs =>
      'Собери пакет документов: аттестат, транскрипт, рекомендательные письма';

  @override
  String get onbStudyPlanTimeMorning => 'утром';

  @override
  String get onbStudyPlanTimeDay => 'днём';

  @override
  String get onbStudyPlanTimeEvening => 'вечером';

  @override
  String get onbStudyPlanTimeFlex => 'в удобное время';

  @override
  String get onbStudyPlanDefaultMajor => 'выбранному направлению';

  @override
  String get oppScreenTitle => 'Возможности';

  @override
  String get oppTabScholarships => 'Стипендии';

  @override
  String get oppTabEvents => 'Мероприятия';

  @override
  String get oppTabProjectIdeas => 'Идеи проектов';

  @override
  String get oppFilterCityDefault => 'Город';

  @override
  String get oppFilterFieldDefault => 'Направление';

  @override
  String get oppFilterAccessibilityDefault => 'Доступность';

  @override
  String get oppFilterReset => 'Сбросить';

  @override
  String get oppFilterResetAll => 'Сбросить фильтр';

  @override
  String get oppPickerCityTitle => 'Выбрать город';

  @override
  String get oppPickerFieldTitle => 'Выбрать направление';

  @override
  String get oppPickerAccessibilityTitle => 'Выбрать доступность';

  @override
  String get oppCardMoreDetails => 'Подробнее';

  @override
  String get oppScholarshipsEmpty => 'Нет стипендий по выбранным фильтрам';

  @override
  String oppEventsBannerNearby(String city) {
    return 'рядом с тобой — $city';
  }

  @override
  String get oppEventsBannerSetCity =>
      'Укажи свой город в профиле, чтобы видеть мероприятия рядом';

  @override
  String get oppEventLocalBadge => 'Рядом';

  @override
  String oppIdeasBannerInterest(String interest) {
    return 'по твоему интересу: $interest';
  }

  @override
  String get oppIdeasBannerAddInterests =>
      'Добавь интересы в профиле — покажем идеи специально для тебя';

  @override
  String get oppAcademicFieldMathematics => 'Математика';

  @override
  String get oppAcademicFieldEngineering => 'Инженерия';

  @override
  String get oppAcademicFieldMedicine => 'Медицина';

  @override
  String get oppAcademicFieldEconomics => 'Экономика';

  @override
  String get oppAcademicFieldArts => 'Искусство';

  @override
  String get oppAcademicFieldLaw => 'Право';

  @override
  String get oppAcademicFieldInformatics => 'Информатика';

  @override
  String get oppAcademicFieldNatural => 'Естественные науки';

  @override
  String get oppAccessibilityEasy => 'Легко';

  @override
  String get oppAccessibilityMedium => 'Средне';

  @override
  String get oppAccessibilityHard => 'Сложно';

  @override
  String get oppDifficultyEasy => 'Легко';

  @override
  String get oppDifficultyHard => 'Сложно';

  @override
  String get oppUniversityAppBarFallback => 'Университет';

  @override
  String get oppUniversityNotFound => 'Университет не найден';

  @override
  String get oppUniversityAboutSection => 'О университете';

  @override
  String get oppUniversityProgramsSection => 'Направления';

  @override
  String get oppUniversityAdmissionChancesSection => 'Шансы поступления';

  @override
  String get oppUniversityAcceptanceRateLabel =>
      'Уровень приёма — реалистичная оценка';

  @override
  String oppUniversityEntThreshold(int score) {
    return 'ЕНТ ≥ $score баллов';
  }

  @override
  String get oppUniversityRequirementsSection => 'Требования';

  @override
  String get oppUniversityCostSection => 'Стоимость и стипендии';

  @override
  String get oppUniversityAdmissionStepsSection => 'Как поступить';

  @override
  String oppUniversityOpenWebsite(String label) {
    return 'Открыть сайт: $label';
  }

  @override
  String get oppEventAppBarFallback => 'Мероприятие';

  @override
  String get oppEventNotFound => 'Мероприятие не найдено';

  @override
  String get oppEventDiagramSlotLabel => 'Мероприятие';

  @override
  String get oppEventAboutSection => 'О мероприятии';

  @override
  String get oppEventPrizesSection => 'Призы';

  @override
  String oppEventRegistrationDeadline(String deadline) {
    return 'Дедлайн регистрации: $deadline';
  }

  @override
  String get oppEventHowToParticipateSection => 'Как участвовать';

  @override
  String get oppEventAddToList => 'Добавить в список мероприятий';

  @override
  String get oppEventSaved => 'Мероприятие сохранено';

  @override
  String get oppScholarshipAppBarFallback => 'Стипендия';

  @override
  String get oppScholarshipNotFound => 'Стипендия не найдена';

  @override
  String get oppScholarshipCoverageSection => 'Что покрывает';

  @override
  String get oppScholarshipHowToGetSection => 'Как получить';

  @override
  String get oppScholarshipRequiredStatsSection => 'Нужные показатели';

  @override
  String get oppScholarshipHowToBoostLabel => 'Как их добить:';

  @override
  String get oppScholarshipDocumentsSection => 'Требуемые документы';

  @override
  String get oppScholarshipApplyCta => 'Подать заявку';

  @override
  String get oppIdeaAppBarFallback => 'Идея проекта';

  @override
  String get oppIdeaNotFound => 'Идея проекта не найдена';

  @override
  String get oppIdeaWhatSection => 'Что за проект';

  @override
  String get oppIdeaWhySection => 'Почему это твоё';

  @override
  String get oppIdeaStepsSection => 'Шаги';

  @override
  String get oppIdeaOutcomeSection => 'Что получишь в итоге';

  @override
  String get oppIdeaSaveIdea => 'Сохранить идею';

  @override
  String get oppIdeaSavedSnackbar => 'Идея сохранена в профиль';

  @override
  String get oppApplyAppBarTitle => 'Подача заявки';

  @override
  String get oppApplyFormTitle => 'Заполните заявку';

  @override
  String get oppApplyFormSubtitle =>
      'Все поля обязательны. Данные хранятся локально.';

  @override
  String get oppApplyFieldFullName => 'ФИО';

  @override
  String get oppApplyHintFullName => 'Иванов Иван Иванович';

  @override
  String get oppApplyFieldContact => 'Контакт (email или телефон)';

  @override
  String get oppApplyHintContact => 'example@mail.kz или +7 777 000 00 00';

  @override
  String get oppApplyFieldMotivation => 'Мотивационное письмо';

  @override
  String get oppApplyHintMotivation =>
      'Расскажите, почему вы хотите получить эту стипендию и как она поможет вашему обучению...';

  @override
  String get oppApplySubmitButton => 'Отправить заявку';

  @override
  String get oppApplyErrorFullNameEmpty => 'Введите ФИО';

  @override
  String get oppApplyErrorContactEmpty => 'Введите контакт';

  @override
  String get oppApplyErrorMotivationTooShort => 'Напишите не менее 20 символов';

  @override
  String get oppApplySuccessTitle => 'Заявка отправлена!';

  @override
  String get oppApplySuccessBody =>
      'Мы сохранили твою заявку. Следи за статусом в разделе «Профиль → Документы».';

  @override
  String get oppApplySuccessCardTitle => 'Заявка принята';

  @override
  String get oppApplySuccessCardSubtitle => 'Данные сохранены локально';

  @override
  String get oppApplySuccessBackButton => 'Вернуться к стипендиям';

  @override
  String get oppCareerTestTitle => 'Узнай свою профессию';

  @override
  String oppCareerTestProgressLabel(int current, int total) {
    return '$current / $total';
  }

  @override
  String get oppCareerTestCategoryLabel => 'Работа с людьми';

  @override
  String get oppCareerCategoryAnalytical => 'Аналитика';

  @override
  String get oppCareerCategoryCreative => 'Творчество';

  @override
  String get oppCareerCategoryTechnical => 'Технологии';

  @override
  String get oppCareerCategoryLeadership => 'Управление';

  @override
  String get oppCareerAnswerYes => 'Да';

  @override
  String get oppCareerAnswerNo => 'Нет';

  @override
  String get oppCareerAnswerSometimes => 'Иногда';

  @override
  String get oppCareerAnswerMaybe => 'Возможно';

  @override
  String get oppCareerResultTitleDone => 'Ты прошёл тест!';

  @override
  String get oppCareerResultTitleAlreadyDone => 'Тест уже пройден!';

  @override
  String get oppCareerResultStrengthLabel => 'Твоя сильная сторона:';

  @override
  String get oppCareerResultInsightFallback =>
      'Продолжай развивать свои навыки!';

  @override
  String get oppCareerResultCategoriesHeader => 'Результаты по категориям:';

  @override
  String get oppCareerResultReturnTomorrow =>
      'Возвращайся завтра за новым тестом';

  @override
  String get oppCareerResultHomeButton => 'На главную';

  @override
  String get oppCareerInsightSocial =>
      'Ты прирождённый коммуникатор! Твои сильные стороны — эмпатия и умение находить общий язык. Тебе подойдут профессии: педагог, психолог, HR-менеджер, социальный работник, PR-специалист.';

  @override
  String get oppCareerInsightAnalytical =>
      'Ты мыслишь системно и любишь разбираться в данных. Обрати внимание на: аналитик данных, финансист, учёный, программист, экономист.';

  @override
  String get oppCareerInsightCreative =>
      'Ты видишь мир иначе и умеешь создавать что-то новое. Твои направления: дизайнер, художник, архитектор, режиссёр, UX-специалист, маркетолог.';

  @override
  String get oppCareerInsightTechnical =>
      'Ты любишь разбираться в том, как всё устроено, и создавать реальные решения. Профессии для тебя: инженер, программист, IT-специалист, учёный, исследователь.';

  @override
  String get oppCareerInsightLeadership =>
      'Ты умеешь вести за собой людей и достигать целей через команду. Тебе подойдут: менеджер, предприниматель, государственный деятель, топ-менеджер, стратег.';

  @override
  String get oppLessonIntroTitle => 'Сравнение вероятностей';

  @override
  String get oppLessonIntroSubtitle =>
      'Научись сравнивать шансы событий и понимать, что является достоверным, невозможным или случайным.';

  @override
  String oppLessonStatTheoryCards(int count) {
    return '$count карточки теории';
  }

  @override
  String oppLessonStatQuestions(int count) {
    return '$count вопроса';
  }

  @override
  String get oppLessonStatXp => '+50 XP';

  @override
  String get oppLessonStartButton => 'Начать урок';

  @override
  String oppLessonTheoryPill(int current, int total) {
    return 'Теория  $current / $total';
  }

  @override
  String get oppLessonTheoryNextButton => 'Далее';

  @override
  String get oppLessonTheoryToQuestionsButton => 'К вопросам';

  @override
  String oppLessonQuestionPill(int current, int total) {
    return 'Вопрос $current из $total';
  }

  @override
  String get oppLessonCheckButton => 'Проверить';

  @override
  String get oppLessonTrueFalseTrue => 'Верно';

  @override
  String get oppLessonTrueFalseFalse => 'Неверно';

  @override
  String get oppLessonFeedbackCorrect => 'Верно!';

  @override
  String get oppLessonFeedbackIncorrect => 'Неверно';

  @override
  String oppLessonFeedbackXpBadge(int xp) {
    return '+$xp XP';
  }

  @override
  String get oppLessonWhyExpander => 'Почему?';

  @override
  String get oppLessonContinueButton => 'Продолжить';

  @override
  String get oppLessonCompleteTitle => 'Урок пройден!';

  @override
  String get oppLessonCompleteSubtitle =>
      'Отличная работа! Ты завершил урок о вероятностях.';

  @override
  String get oppLessonXpEarned => 'Заработано XP';

  @override
  String oppLessonXpValue(int xp) {
    return '+$xp XP';
  }

  @override
  String get oppLessonCorrectAnswersLabel => 'Правильных ответов';

  @override
  String oppLessonCorrectAnswersValue(int correct, int total) {
    return '$correct из $total';
  }

  @override
  String get oppLessonDoneButton => 'Готово';

  @override
  String get oppLessonTheoryProbabilityTitle => 'Что такое вероятность?';

  @override
  String get oppLessonTheoryProbabilityBody =>
      'Вероятность — это число от 0 до 1, которое описывает, насколько вероятно наступление события. Число 0 означает, что событие невозможно, а число 1 означает, что оно обязательно произойдёт. Все события «между» имеют вероятность строго больше 0 и меньше 1.';

  @override
  String get oppLessonTheoryFormulaTitle => 'Классическая формула';

  @override
  String get oppLessonTheoryFormulaBody =>
      'P(A) = m / n, где m — количество благоприятных исходов, n — общее количество равновозможных исходов. Пример: бросаем монету. n = 2 (орёл и решка), m = 1 (орёл). Значит P(орёл) = 1/2 = 0,5.';

  @override
  String get oppLessonTheoryComparingTitle => 'Сравнение вероятностей';

  @override
  String get oppLessonTheoryComparingBody =>
      'Вероятности сравниваются так же, как обычные дроби. P(A) > P(B) значит, что событие A произойдёт чаще, чем B. Например: вероятность вытащить красный шар из мешка (3 красных из 10) = 3/10 = 0,3, а синий = 7/10 = 0,7. Синий вероятнее.';

  @override
  String get oppLessonTheoryCertainTitle => 'Достоверные и невозможные события';

  @override
  String get oppLessonTheoryCertainBody =>
      'Достоверное событие происходит всегда (P = 1). Пример: при броске кубика выпадет число от 1 до 6 — это достоверно. Невозможное событие не происходит никогда (P = 0). Пример: на том же кубике выпадет 7.';

  @override
  String get oppLessonQ0Text =>
      'Бросают монету. Какова вероятность выпадения орла?';

  @override
  String get oppLessonQ0Explanation =>
      'Монета имеет два равновероятных исхода: орёл и решка. Поэтому вероятность орла = 1/2 = 0.5.';

  @override
  String get oppLessonQ1Text => 'Вероятность достоверного события равна 1.';

  @override
  String get oppLessonQ1OptionTrue => 'Верно';

  @override
  String get oppLessonQ1OptionFalse => 'Неверно';

  @override
  String get oppLessonQ1Explanation =>
      'Достоверное событие — то, которое обязательно произойдёт. По определению, его вероятность равна 1.';

  @override
  String get oppLessonQ2Text => 'Вероятность невозможного события равна ____.';

  @override
  String get oppLessonQ2Explanation =>
      'Невозможное событие не может произойти никогда. Его вероятность равна 0 по определению.';

  @override
  String get profScreenTitle => 'Профиль';

  @override
  String get profAddDataPrompt => 'Добавь данные о себе →';

  @override
  String get profEditTooltip => 'Редактировать данные';

  @override
  String profGoalChip(int minutes) {
    return 'Цель: $minutes мин/день';
  }

  @override
  String get profDocPackagesSectionTitle => 'Пакет документов';

  @override
  String get profDocPackagesSectionSubtitle =>
      'Отмечай документы по мере готовности и прикрепляй файлы';

  @override
  String get profMyDocsSectionTitle => 'Мои документы';

  @override
  String get profMyDocsSectionSubtitle =>
      'Прикрепляй файлы, открывай и делись с куратором';

  @override
  String get profCareerTestCardTitle => 'Тест на профориентацию';

  @override
  String get profCareerTestCardSubtitleDuration => 'Займёт ~10–15 минут';

  @override
  String profCareerTestCardSubtitleRetake(String result) {
    return 'Результат: $result. Пройти снова?';
  }

  @override
  String get profCareerTestDialogTitle => 'Тест на профориентацию';

  @override
  String get profCareerTestDialogBody =>
      'Тест займёт 10–15 минут. Отвечай честно — так результат будет точнее.';

  @override
  String get profCareerTestDialogCancel => 'Отмена';

  @override
  String get profCareerTestDialogConfirm => 'Продолжить';

  @override
  String get profNewPackageTitle => 'Новый пакет';

  @override
  String get profNewPackageNameLabel => 'Название пакета';

  @override
  String get profNewPackageNameHint => 'Например: NU 2026';

  @override
  String get profNewPackageDescLabel => 'Описание (необязательно)';

  @override
  String get profNewPackageDescHint => 'Документы для Назарбаев Университета';

  @override
  String get profCreatePackageButton => 'Создать пакет';

  @override
  String profPackageProgress(int attached, int total) {
    return '$attached / $total подтверждено';
  }

  @override
  String get profDocActionOpen => 'Открыть';

  @override
  String get profDocActionReplace => 'Заменить';

  @override
  String get profDocActionRemove => 'Убрать из пакета';

  @override
  String get profDocAttachButton => 'Прикрепить';

  @override
  String get profNoAttachedFiles => 'Нет прикреплённых файлов';

  @override
  String get profAttachFileButton => 'Прикрепить файл';

  @override
  String get profDocActionShare => 'Поделиться';

  @override
  String get profDocActionDelete => 'Удалить';

  @override
  String get profAddDocumentButton => 'Добавить документ';

  @override
  String get profAddDocSheetTitle => 'Добавить документ';

  @override
  String profAddDocSheetSubtitle(String packageName) {
    return 'в пакет «$packageName»';
  }

  @override
  String get profAddDocUploadNew => 'Загрузить новый файл';

  @override
  String get profAddDocAddSlot => 'Добавить пункт без файла';

  @override
  String get profAddDocFromMyDocs => 'Из моих документов';

  @override
  String get profAddDocNoSavedFiles =>
      'Пока нет сохранённых файлов. Загрузи новый — он появится и в разделе «Мои документы».';

  @override
  String get profAddSlotDialogTitle => 'Новый пункт';

  @override
  String get profAddSlotDialogHint => 'Например: Рекомендательное письмо';

  @override
  String get profAddSlotDialogCancel => 'Отмена';

  @override
  String get profAddSlotDialogAdd => 'Добавить';

  @override
  String get profEditScreenTitle => 'Мои данные';

  @override
  String get profEditSectionPersonal => 'Личные данные';

  @override
  String get profEditFieldNameLabel => 'Имя';

  @override
  String get profEditFieldNameHint => 'Как тебя зовут?';

  @override
  String get profEditFieldGradeLabel => 'Класс';

  @override
  String get profEditFieldGradeHint => '11 класс';

  @override
  String get profEditFieldCityLabel => 'Город';

  @override
  String get profEditFieldCityHint => 'Алматы, Астана...';

  @override
  String get profEditFieldGpaLabel => 'Средний балл / ГПА';

  @override
  String get profEditFieldGpaHint => '4.8';

  @override
  String get profEditFieldLanguagesLabel => 'Языки (через запятую)';

  @override
  String get profEditFieldLanguagesHint => 'KZ, RU, EN';

  @override
  String get profEditSectionAcademic => 'Направления и интересы';

  @override
  String get profEditFieldMajorsLabel => 'Направления учёбы (через запятую)';

  @override
  String get profEditFieldMajorsHint => 'IT, Медицина, Финансы...';

  @override
  String get profEditFieldInterestsLabel => 'Интересы и хобби (через запятую)';

  @override
  String get profEditFieldInterestsHint => 'Математика, Дизайн, Музыка...';

  @override
  String get profEditSectionExams => 'Результаты экзаменов';

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
  String get profEditSaveButton => 'Сохранить';

  @override
  String get profEditSavedSnackbar => 'Данные сохранены';

  @override
  String get profCareerTestScreenTitle => 'Профориентация';

  @override
  String profCareerTestProgress(int current, int total) {
    return '$current / $total';
  }

  @override
  String get profCareerTestWarning =>
      'Тест займёт ~10–15 минут. Ответь честно — результат будет точнее.';

  @override
  String profCareerTestQuestionLabel(int number) {
    return 'Вопрос $number';
  }

  @override
  String get profCareerTestAnswerNo => 'Нет';

  @override
  String get profCareerTestAnswerNeutral => 'Нейтрально';

  @override
  String get profCareerTestAnswerYes => 'Да';

  @override
  String get profCareerResultTitle => 'Результат готов!';

  @override
  String get profCareerResultProfileLabel => 'Твой профиль';

  @override
  String get profCareerResultSavedNote =>
      'Результат сохранён в твоём профиле. Ты можешь пройти тест снова в любое время.';

  @override
  String get profCareerResultCloseButton => 'Закрыть';

  @override
  String profNotifierLoadError(String error) {
    return 'Ошибка загрузки: $error';
  }

  @override
  String profNotifierSaveError(String error) {
    return 'Ошибка сохранения: $error';
  }

  @override
  String get profSeedPackageName => 'Стандартный пакет КЗ';

  @override
  String get profSeedPackageDesc =>
      'Типовой набор документов для поступления в вузы Казахстана';

  @override
  String get profSeedItemId =>
      'Удостоверение личности / Свидетельство о рождении';

  @override
  String get profSeedItemTranscript => 'Аттестат / Транскрипт оценок';

  @override
  String get profSeedItemMedical => 'Медицинская справка 086-У';

  @override
  String get profSeedItemPhotos => 'Фотографии 3×4 (6 шт.)';

  @override
  String get profSeedItemUnt => 'Сертификат ЕНТ / ЕГЭ';

  @override
  String get profSeedItemIntlExam =>
      'Сертификат IELTS / TOEFL / SAT (при наличии)';

  @override
  String get profSeedItemMotivation => 'Мотивационное письмо';

  @override
  String get profSeedItemRecommendations => 'Рекомендательные письма (2 шт.)';

  @override
  String get profSeedItemApplication => 'Заявление о поступлении';

  @override
  String get profSeedItemParentalConsent =>
      'Согласие родителей (для несовершеннолетних)';

  @override
  String get profCareerResultEngineerResearcher => 'Инженер-исследователь';

  @override
  String get profCareerResultArchitectDesigner =>
      'Архитектор / Дизайнер продуктов';

  @override
  String get profCareerResultScientistInnovator => 'Учёный-новатор';

  @override
  String get profCareerResultHrCoach => 'HR-менеджер / Тренер';

  @override
  String get profCareerResultCfo => 'Финансовый директор';

  @override
  String get profCareerResultArtTherapistEducator =>
      'Арт-терапевт / Педагог-творец';

  @override
  String get profCareerResultEngineerTechnologist => 'Инженер / Технолог';

  @override
  String get profCareerResultScientistAnalyst => 'Учёный / Аналитик';

  @override
  String get profCareerResultCreativeDesigner =>
      'Творческий деятель / Дизайнер';

  @override
  String get profCareerResultTeacherPsychologist => 'Педагог / Психолог';

  @override
  String get profCareerResultEntrepreneurManager =>
      'Предприниматель / Менеджер';

  @override
  String get profCareerResultFinancistAdministrator =>
      'Финансист / Администратор';

  @override
  String get profCareerQ1 =>
      'Мне нравится собирать и чинить вещи своими руками';

  @override
  String get profCareerQ2 => 'Я предпочитаю работу на свежем воздухе';

  @override
  String get profCareerQ3 => 'Мне интересны технические устройства и механизмы';

  @override
  String get profCareerQ4 => 'Я люблю физический труд';

  @override
  String get profCareerQ5 =>
      'Мне нравится работать с инструментами и оборудованием';

  @override
  String get profCareerQ6 => 'Мне нравится решать сложные задачи и головоломки';

  @override
  String get profCareerQ7 =>
      'Я с удовольствием провожу время за чтением научных статей';

  @override
  String get profCareerQ8 =>
      'Мне интересно изучать, как устроен мир вокруг нас';

  @override
  String get profCareerQ9 =>
      'Я люблю анализировать данные и искать закономерности';

  @override
  String get profCareerQ10 => 'Мне нравится проводить эксперименты';

  @override
  String get profCareerQ11 => 'Я люблю рисовать, писать или музицировать';

  @override
  String get profCareerQ12 =>
      'Мне нравится создавать что-то красивое или оригинальное';

  @override
  String get profCareerQ13 => 'Я часто нахожу нестандартные решения';

  @override
  String get profCareerQ14 => 'Творческое самовыражение важно для меня';

  @override
  String get profCareerQ15 => 'Мне нравится дизайн и эстетика';

  @override
  String get profCareerQ16 => 'Мне нравится помогать другим людям';

  @override
  String get profCareerQ17 => 'Я хорошо чувствую настроение и эмоции других';

  @override
  String get profCareerQ18 => 'Мне нравится работать в команде';

  @override
  String get profCareerQ19 => 'Я с удовольствием обучаю других';

  @override
  String get profCareerQ20 => 'Волонтёрство и помощь обществу важны для меня';

  @override
  String get profCareerQ21 => 'Мне нравится убеждать людей и вести переговоры';

  @override
  String get profCareerQ22 =>
      'Я готов брать на себя ответственность и руководить';

  @override
  String get profCareerQ23 => 'Меня привлекает создание бизнеса';

  @override
  String get profCareerQ24 => 'Мне нравится соревноваться и побеждать';

  @override
  String get profCareerQ25 => 'Я умею продавать идеи и продукты';

  @override
  String get profCareerQ26 => 'Мне нравится работать с цифрами и документами';

  @override
  String get profCareerQ27 => 'Я ценю порядок и организованность';

  @override
  String get profCareerQ28 =>
      'Мне нравится следовать чётким правилам и инструкциям';

  @override
  String get profCareerQ29 =>
      'Мне интересна бухгалтерия, финансы или управление данными';

  @override
  String get profCareerQ30 =>
      'Я люблю систематизировать и классифицировать информацию';

  @override
  String get sharedNavHome => 'Главная';

  @override
  String get sharedNavUniversities => 'Вузы';

  @override
  String get sharedNavEraly => 'Ералы';

  @override
  String get sharedNavOpportunities => 'Возможности';

  @override
  String get sharedNavProfile => 'Профиль';

  @override
  String get sharedNotifStudyReminderTitle => 'Время учиться!';

  @override
  String get sharedNotifStudyBody10 =>
      'Всего 10 минут — и ты на шаг ближе к цели!';

  @override
  String get sharedNotifStudyBody20 =>
      '20 минут занятий сегодня — ты справишься!';

  @override
  String sharedNotifStudyBody30(int minutes) {
    return 'Запланировано $minutes минут учёбы. Начнём?';
  }

  @override
  String sharedNotifStudyBodyBig(int minutes) {
    return 'Большая цель сегодня: $minutes минут. Удачи!';
  }

  @override
  String sharedNotifCalendarNowTitle(String eventTitle) {
    return 'Сейчас: $eventTitle';
  }

  @override
  String get sharedNotifCalendarNowBody => 'Событие начинается!';

  @override
  String sharedNotifCalendarSoonTitle(String eventTitle) {
    return 'Скоро: $eventTitle';
  }

  @override
  String get sharedNotifCalendarSoonBody => 'Запланировано на сегодня.';

  @override
  String sharedNotifTodoNudgeTitle(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'У тебя $count задач на сегодня',
      many: 'У тебя $count задач на сегодня',
      few: 'У тебя $count задачи на сегодня',
      one: 'У тебя $count задача на сегодня',
    );
    return '$_temp0';
  }

  @override
  String get sharedNotifChannelName => 'Ежедневные напоминания';

  @override
  String get sharedNotifChannelDesc =>
      'Напоминания о ежедневной учёбе и предстоящих событиях';

  @override
  String get uniTitle => 'Вузы';

  @override
  String uniSubtitleKz(int count) {
    return '$count вузов Казахстана';
  }

  @override
  String get uniErrorLoad => 'Не удалось загрузить список вузов';

  @override
  String get uniEmptyList => 'Список вузов пуст';

  @override
  String get uniNoResults => 'Нет вузов по выбранным фильтрам';

  @override
  String get uniFilterCity => 'Город';

  @override
  String get uniFilterType => 'Тип';

  @override
  String get uniFilterReset => 'Сбросить';

  @override
  String get uniPickCityTitle => 'Выбрать город';

  @override
  String get uniPickTypeTitle => 'Выбрать тип';

  @override
  String get uniFilterClearItem => 'Сбросить фильтр';

  @override
  String uniProgramCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count программ',
      many: '$count программ',
      few: '$count программы',
      one: '$count программа',
    );
    return '$_temp0';
  }

  @override
  String uniCompetitionFrom(int score) {
    return 'конкурс от $score б.';
  }

  @override
  String get uniTypeNational => 'Национальный';

  @override
  String get uniTypeState => 'Государственный';

  @override
  String get uniTypeAutonomous => 'Автономный';

  @override
  String get uniTypePrivate => 'Частный';

  @override
  String get uniTypeInternational => 'Международный';

  @override
  String get uniHubSubtitle => 'Выбери, какие вузы хочешь изучить';

  @override
  String get uniHubKzTitle => 'Вузы Казахстана';

  @override
  String get uniHubKzSubtitle =>
      'Каталог 88+ вузов с конкурсными баллами и ГОП';

  @override
  String get uniHubAbroadTitle => 'Вузы за рубежом';

  @override
  String get uniHubAbroadSubtitle =>
      'Топ мировые университеты с финансовой помощью для иностранцев';

  @override
  String get uniAbroadTitle => 'Вузы за рубежом';

  @override
  String uniAbroadCountSubtitle(int count) {
    return '$count вузов мира';
  }

  @override
  String get uniAbroadErrorLoad =>
      'Не удалось загрузить список зарубежных вузов';

  @override
  String get uniAbroadEmptyList => 'Список зарубежных вузов пуст';

  @override
  String get uniAbroadMatchBadge => 'совпадение';

  @override
  String uniAbroadTuitionPerYear(String price) {
    return '\$$price/год';
  }

  @override
  String get uniFinAidNeedBlind => 'Нужд-слепой приём';

  @override
  String get uniFinAidGenerous => 'Щедрая финпомощь';

  @override
  String get uniFinAidLimited => 'Ограниченная помощь';

  @override
  String get uniFinAidNone => 'Без финпомощи';

  @override
  String get uniShortFinAidNeedBlind => 'need-blind';

  @override
  String get uniShortFinAidGenerous => 'щедрые гранты';

  @override
  String get uniShortFinAidLimited => 'лимит. помощь';

  @override
  String get uniShortFinAidNone => 'без помощи';

  @override
  String get uniDetailErrorLoad => 'Не удалось загрузить данные';

  @override
  String get uniDetailNotFound => 'Вуз не найден';

  @override
  String get uniDetailFinanceSection => 'Финансы';

  @override
  String get uniDetailFinAidLabel => 'Финансовая помощь';

  @override
  String get uniDetailTuitionLabel => 'Стоимость в год';

  @override
  String get uniDetailMajorsSection => 'Направления';

  @override
  String uniDetailSourceLink(String url) {
    return 'Источник: $url';
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
  String get uniMajorPolitics => 'Политология';

  @override
  String get uniDetailKzErrorLoad => 'Не удалось загрузить вуз';

  @override
  String get uniDetailKzNotFound => 'Вуз не найден';

  @override
  String get uniDetailHasDormYes => 'Да';

  @override
  String get uniDetailHasDormNo => 'Нет';

  @override
  String get uniDetailHasDormitory => 'Есть общежитие';

  @override
  String get uniDetailStatPrograms => 'программ';

  @override
  String get uniDetailStatCompetition => 'конкурс от, б.';

  @override
  String get uniDetailStatDormitory => 'общежитие';

  @override
  String get uniDetailAboutSection => 'О вузе';

  @override
  String get uniDetailInfoSection => 'Информация';

  @override
  String uniDetailProgramsSection(int count) {
    return 'Программы ($count)';
  }

  @override
  String get uniDetailProgramsNote =>
      'Балл — минимум для участия в конкурсе на грант (НЦТ). Это не проходной балл. Нажми на программу, чтобы раскрыть детали.';

  @override
  String uniDetailCompetitionFrom(int score) {
    return 'Конкурс от $score б.';
  }

  @override
  String get uniDetailLanguagesLabel => 'Языки обучения';

  @override
  String get uniDetailGrantPlacesLabel => 'Грантовых мест';

  @override
  String get uniDetailTuitionKztLabel => 'Стоимость в год';

  @override
  String get uniDetailNoScoreData => 'Данных по баллам пока нет.';

  @override
  String get uniDetailScoresByYear => 'Баллы по годам';

  @override
  String get uniDetailUnverified => 'не подтверждено';

  @override
  String get uniDetailEmptyPrograms =>
      'Для этого вуза пока нет данных по программам и грантам.';

  @override
  String get uniDetailSourcesTitle => 'Источники данных';

  @override
  String get uniLangKz => 'каз';

  @override
  String get uniLangRu => 'рус';

  @override
  String get uniLangEn => 'англ';

  @override
  String get uniQuotaGeneral => 'Общий конкурс';

  @override
  String get uniQuotaRural => 'Сельская квота';

  @override
  String get uniQuotaLyceum => 'Квота лицеев';

  @override
  String get uniQuotaOrphan => 'Квота сирот';

  @override
  String get uniQuotaDisability => 'Квота по инвалидности';

  @override
  String get uniQuotaOralman => 'Квота кандасов';

  @override
  String get uniQuotaOther => 'Иная квота';

  @override
  String get uniGrantMetricCutoff => 'Проходной балл на грант';

  @override
  String get uniGrantMetricCompetitionMin =>
      'Минимум для участия в конкурсе на грант';

  @override
  String get uniGrantMetricPaidMin => 'Минимум на платное';

  @override
  String get uniGrantMetricNationalFloor => 'Пороговый минимум (приказ МНВО)';
}
