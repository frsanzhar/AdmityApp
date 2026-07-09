import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_kk.dart';
import 'app_localizations_ru.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'gen/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('kk'),
    Locale('ru'),
  ];

  /// No description provided for @appTitle.
  ///
  /// In ru, this message translates to:
  /// **'Admity'**
  String get appTitle;

  /// No description provided for @languageSectionTitle.
  ///
  /// In ru, this message translates to:
  /// **'Язык приложения'**
  String get languageSectionTitle;

  /// No description provided for @languageSystem.
  ///
  /// In ru, this message translates to:
  /// **'Как в системе'**
  String get languageSystem;

  /// No description provided for @languageRussian.
  ///
  /// In ru, this message translates to:
  /// **'Русский'**
  String get languageRussian;

  /// No description provided for @languageKazakh.
  ///
  /// In ru, this message translates to:
  /// **'Қазақша'**
  String get languageKazakh;

  /// No description provided for @languageEnglish.
  ///
  /// In ru, this message translates to:
  /// **'English'**
  String get languageEnglish;

  /// No description provided for @authWelcomeTitle.
  ///
  /// In ru, this message translates to:
  /// **'Добро пожаловать'**
  String get authWelcomeTitle;

  /// No description provided for @authCreateAccountTitle.
  ///
  /// In ru, this message translates to:
  /// **'Создать аккаунт'**
  String get authCreateAccountTitle;

  /// No description provided for @authSignInSubtitle.
  ///
  /// In ru, this message translates to:
  /// **'Войдите, чтобы продолжить'**
  String get authSignInSubtitle;

  /// No description provided for @authSignUpSubtitle.
  ///
  /// In ru, this message translates to:
  /// **'Введите данные, чтобы начать'**
  String get authSignUpSubtitle;

  /// No description provided for @authEmailLabel.
  ///
  /// In ru, this message translates to:
  /// **'Email'**
  String get authEmailLabel;

  /// No description provided for @authPasswordLabel.
  ///
  /// In ru, this message translates to:
  /// **'Пароль'**
  String get authPasswordLabel;

  /// No description provided for @authEmailRequired.
  ///
  /// In ru, this message translates to:
  /// **'Введите email'**
  String get authEmailRequired;

  /// No description provided for @authEmailInvalid.
  ///
  /// In ru, this message translates to:
  /// **'Некорректный email'**
  String get authEmailInvalid;

  /// No description provided for @authPasswordRequired.
  ///
  /// In ru, this message translates to:
  /// **'Введите пароль'**
  String get authPasswordRequired;

  /// No description provided for @authPasswordMinLength.
  ///
  /// In ru, this message translates to:
  /// **'Минимум 6 символов'**
  String get authPasswordMinLength;

  /// No description provided for @authSignInButton.
  ///
  /// In ru, this message translates to:
  /// **'Войти'**
  String get authSignInButton;

  /// No description provided for @authSignUpButton.
  ///
  /// In ru, this message translates to:
  /// **'Зарегистрироваться'**
  String get authSignUpButton;

  /// No description provided for @authAlreadyHaveAccount.
  ///
  /// In ru, this message translates to:
  /// **'Уже есть аккаунт? Войти'**
  String get authAlreadyHaveAccount;

  /// No description provided for @authNoAccount.
  ///
  /// In ru, this message translates to:
  /// **'Нет аккаунта? Зарегистрироваться'**
  String get authNoAccount;

  /// No description provided for @authOrDivider.
  ///
  /// In ru, this message translates to:
  /// **'или'**
  String get authOrDivider;

  /// No description provided for @authContinueWithGoogle.
  ///
  /// In ru, this message translates to:
  /// **'Продолжить с Google'**
  String get authContinueWithGoogle;

  /// No description provided for @authContinueWithApple.
  ///
  /// In ru, this message translates to:
  /// **'Продолжить с Apple'**
  String get authContinueWithApple;

  /// No description provided for @authContinueAsGuest.
  ///
  /// In ru, this message translates to:
  /// **'Продолжить как гость'**
  String get authContinueAsGuest;

  /// No description provided for @authErrorSignIn.
  ///
  /// In ru, this message translates to:
  /// **'Не удалось войти. Проверьте подключение и попробуйте снова.'**
  String get authErrorSignIn;

  /// No description provided for @authErrorCreateAccount.
  ///
  /// In ru, this message translates to:
  /// **'Не удалось создать аккаунт. Проверьте подключение и попробуйте снова.'**
  String get authErrorCreateAccount;

  /// No description provided for @authErrorGoogleNotConfigured.
  ///
  /// In ru, this message translates to:
  /// **'Вход через Google ещё не настроен. Добавьте GOOGLE_WEB_CLIENT_ID.'**
  String get authErrorGoogleNotConfigured;

  /// No description provided for @authErrorCancelled.
  ///
  /// In ru, this message translates to:
  /// **'Вход отменён.'**
  String get authErrorCancelled;

  /// No description provided for @authErrorGoogleTokenFailed.
  ///
  /// In ru, this message translates to:
  /// **'Не удалось получить токен Google. Попробуйте снова.'**
  String get authErrorGoogleTokenFailed;

  /// No description provided for @authErrorGoogleSignIn.
  ///
  /// In ru, this message translates to:
  /// **'Не удалось войти через Google. Попробуйте снова.'**
  String get authErrorGoogleSignIn;

  /// No description provided for @authErrorAppleTokenFailed.
  ///
  /// In ru, this message translates to:
  /// **'Не удалось получить токен Apple. Попробуйте снова.'**
  String get authErrorAppleTokenFailed;

  /// No description provided for @authErrorAppleSignIn.
  ///
  /// In ru, this message translates to:
  /// **'Не удалось войти через Apple. Попробуйте снова.'**
  String get authErrorAppleSignIn;

  /// No description provided for @authErrorAppleRaw.
  ///
  /// In ru, this message translates to:
  /// **'Apple Sign In: {message}'**
  String authErrorAppleRaw(String message);

  /// No description provided for @authErrorGuestFailed.
  ///
  /// In ru, this message translates to:
  /// **'Не удалось создать гостевой профиль.'**
  String get authErrorGuestFailed;

  /// No description provided for @authErrorInvalidCredentials.
  ///
  /// In ru, this message translates to:
  /// **'Неверный email или пароль.'**
  String get authErrorInvalidCredentials;

  /// No description provided for @authErrorEmailNotConfirmed.
  ///
  /// In ru, this message translates to:
  /// **'Подтвердите email по ссылке из письма.'**
  String get authErrorEmailNotConfirmed;

  /// No description provided for @authErrorEmailAlreadyRegistered.
  ///
  /// In ru, this message translates to:
  /// **'Этот email уже зарегистрирован. Попробуйте войти.'**
  String get authErrorEmailAlreadyRegistered;

  /// No description provided for @authErrorPasswordTooShort.
  ///
  /// In ru, this message translates to:
  /// **'Пароль должен содержать не менее 6 символов.'**
  String get authErrorPasswordTooShort;

  /// No description provided for @authErrorRateLimit.
  ///
  /// In ru, this message translates to:
  /// **'Слишком много попыток. Подождите немного и повторите.'**
  String get authErrorRateLimit;

  /// No description provided for @homeGreeting.
  ///
  /// In ru, this message translates to:
  /// **'Привет!'**
  String get homeGreeting;

  /// No description provided for @homeGreetingSubtitle.
  ///
  /// In ru, this message translates to:
  /// **'Готов к новым знаниям?'**
  String get homeGreetingSubtitle;

  /// No description provided for @homeStreakSemanticLabel.
  ///
  /// In ru, this message translates to:
  /// **'Серия: {count} {dayWord}'**
  String homeStreakSemanticLabel(int count, String dayWord);

  /// No description provided for @homeStreakStart.
  ///
  /// In ru, this message translates to:
  /// **'Начни свою серию!'**
  String get homeStreakStart;

  /// No description provided for @homeStreakActive.
  ///
  /// In ru, this message translates to:
  /// **'Серия — {count, plural, one{{count} день} few{{count} дня} many{{count} дней} other{{count} дня}}'**
  String homeStreakActive(int count);

  /// No description provided for @homeStreakDayDone.
  ///
  /// In ru, this message translates to:
  /// **'День завершён!'**
  String get homeStreakDayDone;

  /// No description provided for @homeStreakDayNotDone.
  ///
  /// In ru, this message translates to:
  /// **'Ещё не завершён'**
  String get homeStreakDayNotDone;

  /// No description provided for @homeStreakWeekSummary.
  ///
  /// In ru, this message translates to:
  /// **'{count} из 7 дней на этой неделе'**
  String homeStreakWeekSummary(int count);

  /// No description provided for @homeWeekdayMon.
  ///
  /// In ru, this message translates to:
  /// **'Пн'**
  String get homeWeekdayMon;

  /// No description provided for @homeWeekdayTue.
  ///
  /// In ru, this message translates to:
  /// **'Вт'**
  String get homeWeekdayTue;

  /// No description provided for @homeWeekdayWed.
  ///
  /// In ru, this message translates to:
  /// **'Ср'**
  String get homeWeekdayWed;

  /// No description provided for @homeWeekdayThu.
  ///
  /// In ru, this message translates to:
  /// **'Чт'**
  String get homeWeekdayThu;

  /// No description provided for @homeWeekdayFri.
  ///
  /// In ru, this message translates to:
  /// **'Пт'**
  String get homeWeekdayFri;

  /// No description provided for @homeWeekdaySat.
  ///
  /// In ru, this message translates to:
  /// **'Сб'**
  String get homeWeekdaySat;

  /// No description provided for @homeWeekdaySun.
  ///
  /// In ru, this message translates to:
  /// **'Вс'**
  String get homeWeekdaySun;

  /// No description provided for @homeCalendarMonthJan.
  ///
  /// In ru, this message translates to:
  /// **'Январь'**
  String get homeCalendarMonthJan;

  /// No description provided for @homeCalendarMonthFeb.
  ///
  /// In ru, this message translates to:
  /// **'Февраль'**
  String get homeCalendarMonthFeb;

  /// No description provided for @homeCalendarMonthMar.
  ///
  /// In ru, this message translates to:
  /// **'Март'**
  String get homeCalendarMonthMar;

  /// No description provided for @homeCalendarMonthApr.
  ///
  /// In ru, this message translates to:
  /// **'Апрель'**
  String get homeCalendarMonthApr;

  /// No description provided for @homeCalendarMonthMay.
  ///
  /// In ru, this message translates to:
  /// **'Май'**
  String get homeCalendarMonthMay;

  /// No description provided for @homeCalendarMonthJun.
  ///
  /// In ru, this message translates to:
  /// **'Июнь'**
  String get homeCalendarMonthJun;

  /// No description provided for @homeCalendarMonthJul.
  ///
  /// In ru, this message translates to:
  /// **'Июль'**
  String get homeCalendarMonthJul;

  /// No description provided for @homeCalendarMonthAug.
  ///
  /// In ru, this message translates to:
  /// **'Август'**
  String get homeCalendarMonthAug;

  /// No description provided for @homeCalendarMonthSep.
  ///
  /// In ru, this message translates to:
  /// **'Сентябрь'**
  String get homeCalendarMonthSep;

  /// No description provided for @homeCalendarMonthOct.
  ///
  /// In ru, this message translates to:
  /// **'Октябрь'**
  String get homeCalendarMonthOct;

  /// No description provided for @homeCalendarMonthNov.
  ///
  /// In ru, this message translates to:
  /// **'Ноябрь'**
  String get homeCalendarMonthNov;

  /// No description provided for @homeCalendarMonthDec.
  ///
  /// In ru, this message translates to:
  /// **'Декабрь'**
  String get homeCalendarMonthDec;

  /// No description provided for @homeCalendarAgendaMonthGenJan.
  ///
  /// In ru, this message translates to:
  /// **'января'**
  String get homeCalendarAgendaMonthGenJan;

  /// No description provided for @homeCalendarAgendaMonthGenFeb.
  ///
  /// In ru, this message translates to:
  /// **'февраля'**
  String get homeCalendarAgendaMonthGenFeb;

  /// No description provided for @homeCalendarAgendaMonthGenMar.
  ///
  /// In ru, this message translates to:
  /// **'марта'**
  String get homeCalendarAgendaMonthGenMar;

  /// No description provided for @homeCalendarAgendaMonthGenApr.
  ///
  /// In ru, this message translates to:
  /// **'апреля'**
  String get homeCalendarAgendaMonthGenApr;

  /// No description provided for @homeCalendarAgendaMonthGenMay.
  ///
  /// In ru, this message translates to:
  /// **'мая'**
  String get homeCalendarAgendaMonthGenMay;

  /// No description provided for @homeCalendarAgendaMonthGenJun.
  ///
  /// In ru, this message translates to:
  /// **'июня'**
  String get homeCalendarAgendaMonthGenJun;

  /// No description provided for @homeCalendarAgendaMonthGenJul.
  ///
  /// In ru, this message translates to:
  /// **'июля'**
  String get homeCalendarAgendaMonthGenJul;

  /// No description provided for @homeCalendarAgendaMonthGenAug.
  ///
  /// In ru, this message translates to:
  /// **'августа'**
  String get homeCalendarAgendaMonthGenAug;

  /// No description provided for @homeCalendarAgendaMonthGenSep.
  ///
  /// In ru, this message translates to:
  /// **'сентября'**
  String get homeCalendarAgendaMonthGenSep;

  /// No description provided for @homeCalendarAgendaMonthGenOct.
  ///
  /// In ru, this message translates to:
  /// **'октября'**
  String get homeCalendarAgendaMonthGenOct;

  /// No description provided for @homeCalendarAgendaMonthGenNov.
  ///
  /// In ru, this message translates to:
  /// **'ноября'**
  String get homeCalendarAgendaMonthGenNov;

  /// No description provided for @homeCalendarAgendaMonthGenDec.
  ///
  /// In ru, this message translates to:
  /// **'декабря'**
  String get homeCalendarAgendaMonthGenDec;

  /// No description provided for @homeCalendarWeekdayFullMon.
  ///
  /// In ru, this message translates to:
  /// **'Понедельник'**
  String get homeCalendarWeekdayFullMon;

  /// No description provided for @homeCalendarWeekdayFullTue.
  ///
  /// In ru, this message translates to:
  /// **'Вторник'**
  String get homeCalendarWeekdayFullTue;

  /// No description provided for @homeCalendarWeekdayFullWed.
  ///
  /// In ru, this message translates to:
  /// **'Среда'**
  String get homeCalendarWeekdayFullWed;

  /// No description provided for @homeCalendarWeekdayFullThu.
  ///
  /// In ru, this message translates to:
  /// **'Четверг'**
  String get homeCalendarWeekdayFullThu;

  /// No description provided for @homeCalendarWeekdayFullFri.
  ///
  /// In ru, this message translates to:
  /// **'Пятница'**
  String get homeCalendarWeekdayFullFri;

  /// No description provided for @homeCalendarWeekdayFullSat.
  ///
  /// In ru, this message translates to:
  /// **'Суббота'**
  String get homeCalendarWeekdayFullSat;

  /// No description provided for @homeCalendarWeekdayFullSun.
  ///
  /// In ru, this message translates to:
  /// **'Воскресенье'**
  String get homeCalendarWeekdayFullSun;

  /// No description provided for @homeCalendarNoEvents.
  ///
  /// In ru, this message translates to:
  /// **'Событий нет. Добавьте первое!'**
  String get homeCalendarNoEvents;

  /// No description provided for @homeCalendarEralyBadge.
  ///
  /// In ru, this message translates to:
  /// **'Ералы'**
  String get homeCalendarEralyBadge;

  /// No description provided for @homeCalendarAddEvent.
  ///
  /// In ru, this message translates to:
  /// **'Добавить событие'**
  String get homeCalendarAddEvent;

  /// No description provided for @homeEventSheetTitleNew.
  ///
  /// In ru, this message translates to:
  /// **'Новое событие'**
  String get homeEventSheetTitleNew;

  /// No description provided for @homeEventSheetTitleEdit.
  ///
  /// In ru, this message translates to:
  /// **'Редактировать событие'**
  String get homeEventSheetTitleEdit;

  /// No description provided for @homeEventSheetFieldTitleLabel.
  ///
  /// In ru, this message translates to:
  /// **'Название'**
  String get homeEventSheetFieldTitleLabel;

  /// No description provided for @homeEventSheetFieldTitleHint.
  ///
  /// In ru, this message translates to:
  /// **'Что запланировано?'**
  String get homeEventSheetFieldTitleHint;

  /// No description provided for @homeEventSheetFieldDescLabel.
  ///
  /// In ru, this message translates to:
  /// **'Описание'**
  String get homeEventSheetFieldDescLabel;

  /// No description provided for @homeEventSheetFieldDescHint.
  ///
  /// In ru, this message translates to:
  /// **'Подробности (необязательно)'**
  String get homeEventSheetFieldDescHint;

  /// No description provided for @homeEventSheetSave.
  ///
  /// In ru, this message translates to:
  /// **'Сохранить'**
  String get homeEventSheetSave;

  /// No description provided for @homeEventSheetDelete.
  ///
  /// In ru, this message translates to:
  /// **'Удалить событие'**
  String get homeEventSheetDelete;

  /// No description provided for @homeTodayTaskTitle.
  ///
  /// In ru, this message translates to:
  /// **'Задание на сегодня'**
  String get homeTodayTaskTitle;

  /// No description provided for @homeTodayTaskBody.
  ///
  /// In ru, this message translates to:
  /// **'Урок: Сравнение вероятностей — продолжи с того места, где остановился.'**
  String get homeTodayTaskBody;

  /// No description provided for @homeTodayTaskContinue.
  ///
  /// In ru, this message translates to:
  /// **'Продолжить'**
  String get homeTodayTaskContinue;

  /// No description provided for @homeTaskListTitle.
  ///
  /// In ru, this message translates to:
  /// **'Сегодняшние задачи'**
  String get homeTaskListTitle;

  /// No description provided for @homeTaskListEmpty.
  ///
  /// In ru, this message translates to:
  /// **'Задач нет. Нажмите + чтобы добавить.'**
  String get homeTaskListEmpty;

  /// No description provided for @homeTaskSheetTitleNew.
  ///
  /// In ru, this message translates to:
  /// **'Новая задача'**
  String get homeTaskSheetTitleNew;

  /// No description provided for @homeTaskSheetTitleEdit.
  ///
  /// In ru, this message translates to:
  /// **'Редактировать'**
  String get homeTaskSheetTitleEdit;

  /// No description provided for @homeTaskSheetFieldTitleLabel.
  ///
  /// In ru, this message translates to:
  /// **'Название'**
  String get homeTaskSheetFieldTitleLabel;

  /// No description provided for @homeTaskSheetFieldTitleHint.
  ///
  /// In ru, this message translates to:
  /// **'Что нужно сделать?'**
  String get homeTaskSheetFieldTitleHint;

  /// No description provided for @homeTaskSheetFieldDescLabel.
  ///
  /// In ru, this message translates to:
  /// **'Описание'**
  String get homeTaskSheetFieldDescLabel;

  /// No description provided for @homeTaskSheetFieldDescHint.
  ///
  /// In ru, this message translates to:
  /// **'Подробности (необязательно)'**
  String get homeTaskSheetFieldDescHint;

  /// No description provided for @homeTaskSheetNoDescription.
  ///
  /// In ru, this message translates to:
  /// **'Описание не добавлено.'**
  String get homeTaskSheetNoDescription;

  /// No description provided for @homeTaskSheetSave.
  ///
  /// In ru, this message translates to:
  /// **'Сохранить'**
  String get homeTaskSheetSave;

  /// No description provided for @homeTaskSheetDelete.
  ///
  /// In ru, this message translates to:
  /// **'Удалить задачу'**
  String get homeTaskSheetDelete;

  /// No description provided for @homeDefaultTodo1Title.
  ///
  /// In ru, this message translates to:
  /// **'Пройти урок по математике'**
  String get homeDefaultTodo1Title;

  /// No description provided for @homeDefaultTodo1Desc.
  ///
  /// In ru, this message translates to:
  /// **'Раздел «Сравнение вероятностей» — примерно 15 минут.'**
  String get homeDefaultTodo1Desc;

  /// No description provided for @homeDefaultTodo2Title.
  ///
  /// In ru, this message translates to:
  /// **'Изучить стипендии БОЛАШАК'**
  String get homeDefaultTodo2Title;

  /// No description provided for @homeDefaultTodo2Desc.
  ///
  /// In ru, this message translates to:
  /// **'Проверить требования для поступления и дедлайн подачи документов.'**
  String get homeDefaultTodo2Desc;

  /// No description provided for @homeDefaultTodo3Title.
  ///
  /// In ru, this message translates to:
  /// **'Обновить профиль'**
  String get homeDefaultTodo3Title;

  /// No description provided for @homeDefaultTodo3Desc.
  ///
  /// In ru, this message translates to:
  /// **'Добавить последние оценки и загрузить актуальные документы.'**
  String get homeDefaultTodo3Desc;

  /// No description provided for @homeDefaultTodo4Title.
  ///
  /// In ru, this message translates to:
  /// **'Прочитать о ЕНТ требованиях'**
  String get homeDefaultTodo4Title;

  /// No description provided for @homeDefaultTodo4Desc.
  ///
  /// In ru, this message translates to:
  /// **'Минимальные баллы по каждому предмету для поступления.'**
  String get homeDefaultTodo4Desc;

  /// No description provided for @homeCareerCardTitle.
  ///
  /// In ru, this message translates to:
  /// **'Узнай свою профессию'**
  String get homeCareerCardTitle;

  /// No description provided for @homeCareerCardSubtitle.
  ///
  /// In ru, this message translates to:
  /// **'Ежедневный тест — 3 минуты'**
  String get homeCareerCardSubtitle;

  /// No description provided for @homeCareerCardButton.
  ///
  /// In ru, this message translates to:
  /// **'Пройти тест'**
  String get homeCareerCardButton;

  /// No description provided for @eralyName.
  ///
  /// In ru, this message translates to:
  /// **'Ералы'**
  String get eralyName;

  /// No description provided for @eralySubtitle.
  ///
  /// In ru, this message translates to:
  /// **'AI-наставник'**
  String get eralySubtitle;

  /// No description provided for @eralyTypingText.
  ///
  /// In ru, this message translates to:
  /// **'Ералы думает...'**
  String get eralyTypingText;

  /// No description provided for @eralyReviewEventsButton.
  ///
  /// In ru, this message translates to:
  /// **'Проверить все мероприятия'**
  String get eralyReviewEventsButton;

  /// No description provided for @eralyOpenPlanButton.
  ///
  /// In ru, this message translates to:
  /// **'Открыть план'**
  String get eralyOpenPlanButton;

  /// No description provided for @eralyToneStrictLabel.
  ///
  /// In ru, this message translates to:
  /// **'Строгий\nнаставник'**
  String get eralyToneStrictLabel;

  /// No description provided for @eralyToneStrictDescription.
  ///
  /// In ru, this message translates to:
  /// **'Прямо и по делу'**
  String get eralyToneStrictDescription;

  /// No description provided for @eralyToneFriendlyLabel.
  ///
  /// In ru, this message translates to:
  /// **'Дружеский\nнаставник'**
  String get eralyToneFriendlyLabel;

  /// No description provided for @eralyToneFriendlyDescription.
  ///
  /// In ru, this message translates to:
  /// **'Тепло и поддержка'**
  String get eralyToneFriendlyDescription;

  /// No description provided for @eralyInputHint.
  ///
  /// In ru, this message translates to:
  /// **'Напиши Ералы...'**
  String get eralyInputHint;

  /// No description provided for @eralyTonePrompt.
  ///
  /// In ru, this message translates to:
  /// **'Привет! Я Ералы — твой AI-наставник по поступлению. Прежде чем начать, выбери, как мне с тобой общаться:'**
  String get eralyTonePrompt;

  /// No description provided for @eralyGreetingStrict.
  ///
  /// In ru, this message translates to:
  /// **'Хорошо. Работаем серьёзно: ставим цели, держим дисциплину и не отвлекаемся на лишнее. Расскажи — куда поступаешь и что уже сделал для этого?'**
  String get eralyGreetingStrict;

  /// No description provided for @eralyGreetingFriendly.
  ///
  /// In ru, this message translates to:
  /// **'Отлично! Я рядом — буду поддерживать и помогать на каждом шаге. Расскажи о себе: куда хочешь поступить и с чего начнём?'**
  String get eralyGreetingFriendly;

  /// No description provided for @eralyEventsProposedAnnounce.
  ///
  /// In ru, this message translates to:
  /// **'Я подготовил {count} мероприятия. Нажми «Проверить все мероприятия», чтобы просмотреть и изменить время.'**
  String eralyEventsProposedAnnounce(int count);

  /// No description provided for @eralyEventsProposeLoading.
  ///
  /// In ru, this message translates to:
  /// **'Отлично! Дай мне секунду — предложу несколько мероприятий...'**
  String get eralyEventsProposeLoading;

  /// No description provided for @eralyEventsSaved.
  ///
  /// In ru, this message translates to:
  /// **'Все мероприятия сохранены в календарь! Ты можешь просмотреть их в разделе «Главная». Чем ещё могу помочь?'**
  String get eralyEventsSaved;

  /// No description provided for @eralyPlanGenerating.
  ///
  /// In ru, this message translates to:
  /// **'Составляю план — одну секунду...'**
  String get eralyPlanGenerating;

  /// No description provided for @eralyPlanReady.
  ///
  /// In ru, this message translates to:
  /// **'Готово! Я составил план «{topic}» из {lessonCount} уроков. Прокрути вниз, чтобы увидеть его. Если хочешь что-то изменить — спроси!'**
  String eralyPlanReady(String topic, int lessonCount);

  /// No description provided for @eralyQuestionResources.
  ///
  /// In ru, this message translates to:
  /// **'Хорошо, начнём! Какие учебные материалы у тебя есть? (книги, онлайн-курсы, приложения — перечисли, что имеется)'**
  String get eralyQuestionResources;

  /// No description provided for @eralyQuestionTime.
  ///
  /// In ru, this message translates to:
  /// **'Понял. Сколько времени в неделю ты можешь уделять подготовке? (например: «2 часа в день» или «10 часов в неделю»)'**
  String get eralyQuestionTime;

  /// No description provided for @eralyQuestionInternet.
  ///
  /// In ru, this message translates to:
  /// **'Есть ли у тебя стабильный доступ к интернету для онлайн-ресурсов? (да / нет)'**
  String get eralyQuestionInternet;

  /// No description provided for @eralyOfflineIeltsStrict.
  ///
  /// In ru, this message translates to:
  /// **'IELTS. Сначала скажи: какие материалы уже есть? Без чёткого инвентаря план не построить.'**
  String get eralyOfflineIeltsStrict;

  /// No description provided for @eralyOfflineIeltsFriendly.
  ///
  /// In ru, this message translates to:
  /// **'IELTS — отличная цель! Давай составим персональный план. Для начала: какие материалы у тебя уже есть? (учебники, приложения, курсы — перечисли всё)'**
  String get eralyOfflineIeltsFriendly;

  /// No description provided for @eralyOfflineSatStrict.
  ///
  /// In ru, this message translates to:
  /// **'SAT требует системной работы. Какими ресурсами пользуешься? Перечисли конкретно.'**
  String get eralyOfflineSatStrict;

  /// No description provided for @eralyOfflineSatFriendly.
  ///
  /// In ru, this message translates to:
  /// **'SAT — серьёзный шаг! Я помогу разбить подготовку на чёткие уроки. Расскажи, какими ресурсами ты пользуешься?'**
  String get eralyOfflineSatFriendly;

  /// No description provided for @eralyOfflineEntStrict.
  ///
  /// In ru, this message translates to:
  /// **'ЕНТ — главный экзамен. Сколько недель до него? Назови точную дату — составим план без воды.'**
  String get eralyOfflineEntStrict;

  /// No description provided for @eralyOfflineEntFriendly.
  ///
  /// In ru, this message translates to:
  /// **'ЕНТ — ключевой экзамен. Хочешь составить поурочный план? Напиши, сколько времени у тебя есть до экзамена.'**
  String get eralyOfflineEntFriendly;

  /// No description provided for @eralyOfflinePlanStrict.
  ///
  /// In ru, this message translates to:
  /// **'Назови тему или экзамен. Потом задам три вопроса — и составлю план без лишних слов.'**
  String get eralyOfflinePlanStrict;

  /// No description provided for @eralyOfflinePlanFriendly.
  ///
  /// In ru, this message translates to:
  /// **'Конечно, помогу составить план! Назови тему или экзамен, и я задам несколько вопросов, чтобы сделать план под тебя.'**
  String get eralyOfflinePlanFriendly;

  /// No description provided for @eralyOfflineEventsStrict.
  ///
  /// In ru, this message translates to:
  /// **'Укажи тему мероприятий. Предложу конкретные даты — ты проверяешь и подтверждаешь.'**
  String get eralyOfflineEventsStrict;

  /// No description provided for @eralyOfflineEventsFriendly.
  ///
  /// In ru, this message translates to:
  /// **'С удовольствием помогу! Напиши тему или цель мероприятий — я предложу несколько конкретных дат и могу поставить их в календарь.'**
  String get eralyOfflineEventsFriendly;

  /// No description provided for @eralyOfflineScholarshipStrict.
  ///
  /// In ru, this message translates to:
  /// **'Стипендии: казахстанские или зарубежные? Ответь кратко — подберу варианты под профиль.'**
  String get eralyOfflineScholarshipStrict;

  /// No description provided for @eralyOfflineScholarshipFriendly.
  ///
  /// In ru, this message translates to:
  /// **'Стипендии — моя любимая тема! Расскажи: ты смотришь на казахстанские программы или зарубежные? Это поможет мне точнее подобрать варианты.'**
  String get eralyOfflineScholarshipFriendly;

  /// No description provided for @eralyOfflineUniversityStrict.
  ///
  /// In ru, this message translates to:
  /// **'Конкретно: в какую страну и в какой университет целишься? Чем точнее — тем полезнее анализ.'**
  String get eralyOfflineUniversityStrict;

  /// No description provided for @eralyOfflineUniversityFriendly.
  ///
  /// In ru, this message translates to:
  /// **'Поступление — большой шаг, и я рядом. В какую страну или университет ты целишься? Или пока только изучаешь варианты?'**
  String get eralyOfflineUniversityFriendly;

  /// No description provided for @eralyOfflineGreetingStrict.
  ///
  /// In ru, this message translates to:
  /// **'Начнём. Куда поступаешь и что уже сделал? Конкретика — основа работы.'**
  String get eralyOfflineGreetingStrict;

  /// No description provided for @eralyOfflineGreetingFriendly.
  ///
  /// In ru, this message translates to:
  /// **'Привет! Расскажи немного о себе — куда хочешь поступить, что уже пробовал делать для этого? Чем больше ты расскажешь, тем точнее я смогу помочь.'**
  String get eralyOfflineGreetingFriendly;

  /// No description provided for @eralyOfflineFollowUpStrict1.
  ///
  /// In ru, this message translates to:
  /// **'Уточни задачу: экзамен, поступление или что-то другое? Коротко.'**
  String get eralyOfflineFollowUpStrict1;

  /// No description provided for @eralyOfflineFollowUpStrict2.
  ///
  /// In ru, this message translates to:
  /// **'Понял. Скажи конкретнее — это для ЕНТ, международного экзамена или вуза?'**
  String get eralyOfflineFollowUpStrict2;

  /// No description provided for @eralyOfflineFollowUpStrict3.
  ///
  /// In ru, this message translates to:
  /// **'Хорошо. Что именно нужно — план, анализ шансов или список стипендий?'**
  String get eralyOfflineFollowUpStrict3;

  /// No description provided for @eralyOfflineFollowUpFriendly1.
  ///
  /// In ru, this message translates to:
  /// **'Интересно! Расскажи подробнее — я хочу понять, чем именно помочь.'**
  String get eralyOfflineFollowUpFriendly1;

  /// No description provided for @eralyOfflineFollowUpFriendly2.
  ///
  /// In ru, this message translates to:
  /// **'Хороший вопрос. Уточни, пожалуйста: ты спрашиваешь про экзамены, поступление или что-то другое?'**
  String get eralyOfflineFollowUpFriendly2;

  /// No description provided for @eralyOfflineFollowUpFriendly3.
  ///
  /// In ru, this message translates to:
  /// **'Понял. Чтобы дать точный ответ, скажи: это для ЕНТ, международного экзамена или для чего-то ещё?'**
  String get eralyOfflineFollowUpFriendly3;

  /// No description provided for @eralyOfflineEventTitle1.
  ///
  /// In ru, this message translates to:
  /// **'Старт: {topic}'**
  String eralyOfflineEventTitle1(String topic);

  /// No description provided for @eralyOfflineEventDescription1.
  ///
  /// In ru, this message translates to:
  /// **'Первое знакомство с темой — изучи ключевые понятия и составь список вопросов.'**
  String get eralyOfflineEventDescription1;

  /// No description provided for @eralyOfflineEventTitle2.
  ///
  /// In ru, this message translates to:
  /// **'Практика: {topic}'**
  String eralyOfflineEventTitle2(String topic);

  /// No description provided for @eralyOfflineEventDescription2.
  ///
  /// In ru, this message translates to:
  /// **'Практическое занятие — реши 10–15 задач или сделай пробный тест.'**
  String get eralyOfflineEventDescription2;

  /// No description provided for @eralyOfflineEventTitle3.
  ///
  /// In ru, this message translates to:
  /// **'Повторение: {topic}'**
  String eralyOfflineEventTitle3(String topic);

  /// No description provided for @eralyOfflineEventDescription3.
  ///
  /// In ru, this message translates to:
  /// **'Итоговое повторение — закрепи слабые места и проверь прогресс.'**
  String get eralyOfflineEventDescription3;

  /// No description provided for @eralyOfflinePlanNotes.
  ///
  /// In ru, this message translates to:
  /// **'Базовый офлайн-план. Подключитесь к интернету, чтобы Ералы составил план под ваши материалы и расписание.'**
  String get eralyOfflinePlanNotes;

  /// No description provided for @eralyOfflinePlanLesson1Title.
  ///
  /// In ru, this message translates to:
  /// **'Введение в {topic}'**
  String eralyOfflinePlanLesson1Title(String topic);

  /// No description provided for @eralyOfflinePlanLesson2Title.
  ///
  /// In ru, this message translates to:
  /// **'Ключевые концепции {topic}'**
  String eralyOfflinePlanLesson2Title(String topic);

  /// No description provided for @eralyOfflinePlanLesson3Title.
  ///
  /// In ru, this message translates to:
  /// **'Практические упражнения'**
  String get eralyOfflinePlanLesson3Title;

  /// No description provided for @eralyOfflinePlanLesson4Title.
  ///
  /// In ru, this message translates to:
  /// **'Разбор ошибок и слабых мест'**
  String get eralyOfflinePlanLesson4Title;

  /// No description provided for @eralyOfflinePlanLesson5Title.
  ///
  /// In ru, this message translates to:
  /// **'Пробный тест и итоговое повторение'**
  String get eralyOfflinePlanLesson5Title;

  /// No description provided for @eralyParsedEventFallbackTitle.
  ///
  /// In ru, this message translates to:
  /// **'Событие {number}'**
  String eralyParsedEventFallbackTitle(int number);

  /// No description provided for @eralyParsedLessonFallbackTitle.
  ///
  /// In ru, this message translates to:
  /// **'Урок {number}'**
  String eralyParsedLessonFallbackTitle(int number);

  /// No description provided for @onbIntro.
  ///
  /// In ru, this message translates to:
  /// **'Поступление в университет — это большой шаг. Admity поможет пройти его уверенно.'**
  String get onbIntro;

  /// No description provided for @onbWhoAreYou.
  ///
  /// In ru, this message translates to:
  /// **'Кто ты?'**
  String get onbWhoAreYou;

  /// No description provided for @onbRoleStudentLabel.
  ///
  /// In ru, this message translates to:
  /// **'Я учусь'**
  String get onbRoleStudentLabel;

  /// No description provided for @onbRoleStudentDesc.
  ///
  /// In ru, this message translates to:
  /// **'Готовлюсь к поступлению'**
  String get onbRoleStudentDesc;

  /// No description provided for @onbRoleParentLabel.
  ///
  /// In ru, this message translates to:
  /// **'Родитель'**
  String get onbRoleParentLabel;

  /// No description provided for @onbRoleParentDesc.
  ///
  /// In ru, this message translates to:
  /// **'Помогаю ребёнку поступить'**
  String get onbRoleParentDesc;

  /// No description provided for @onbRoleTeacherLabel.
  ///
  /// In ru, this message translates to:
  /// **'Учитель'**
  String get onbRoleTeacherLabel;

  /// No description provided for @onbRoleTeacherDesc.
  ///
  /// In ru, this message translates to:
  /// **'Готовлю учеников к вузу'**
  String get onbRoleTeacherDesc;

  /// No description provided for @onbNextButton.
  ///
  /// In ru, this message translates to:
  /// **'Далее'**
  String get onbNextButton;

  /// No description provided for @onbMascotGreetingName.
  ///
  /// In ru, this message translates to:
  /// **'Привет! Я — Ералы,'**
  String get onbMascotGreetingName;

  /// No description provided for @onbMascotGreetingDesc.
  ///
  /// In ru, this message translates to:
  /// **'твой персональный наставник по поступлению. Расскажу, что нужно знать, и помогу не пропустить ни одной возможности.'**
  String get onbMascotGreetingDesc;

  /// No description provided for @onbMotivationTitle.
  ///
  /// In ru, this message translates to:
  /// **'Какова твоя цель?'**
  String get onbMotivationTitle;

  /// No description provided for @onbMotivationSubtitle.
  ///
  /// In ru, this message translates to:
  /// **'Это поможет подобрать правильный путь'**
  String get onbMotivationSubtitle;

  /// No description provided for @onbMotivationTopKzLabel.
  ///
  /// In ru, this message translates to:
  /// **'Поступить в топ-вуз Казахстана'**
  String get onbMotivationTopKzLabel;

  /// No description provided for @onbMotivationTopKzDesc.
  ///
  /// In ru, this message translates to:
  /// **'НУ, КБТУ, КазНУ и другие'**
  String get onbMotivationTopKzDesc;

  /// No description provided for @onbMotivationAbroadLabel.
  ///
  /// In ru, this message translates to:
  /// **'Поступить в вуз за рубежом'**
  String get onbMotivationAbroadLabel;

  /// No description provided for @onbMotivationAbroadDesc.
  ///
  /// In ru, this message translates to:
  /// **'США, Европа, Азия и другие страны'**
  String get onbMotivationAbroadDesc;

  /// No description provided for @onbMotivationExploreLabel.
  ///
  /// In ru, this message translates to:
  /// **'Профориентация'**
  String get onbMotivationExploreLabel;

  /// No description provided for @onbMotivationExploreDesc.
  ///
  /// In ru, this message translates to:
  /// **'Ещё выбираю направление'**
  String get onbMotivationExploreDesc;

  /// No description provided for @onbAgeTitle.
  ///
  /// In ru, this message translates to:
  /// **'Сколько тебе лет?'**
  String get onbAgeTitle;

  /// No description provided for @onbAgeSubtitle.
  ///
  /// In ru, this message translates to:
  /// **'Поможет подобрать контент по возрасту.'**
  String get onbAgeSubtitle;

  /// No description provided for @onbAgeHint.
  ///
  /// In ru, this message translates to:
  /// **'16'**
  String get onbAgeHint;

  /// No description provided for @onbSubjectTitle.
  ///
  /// In ru, this message translates to:
  /// **'Какие предметы интересны как Major?'**
  String get onbSubjectTitle;

  /// No description provided for @onbSubjectSubtitle.
  ///
  /// In ru, this message translates to:
  /// **'Можно выбрать несколько'**
  String get onbSubjectSubtitle;

  /// No description provided for @onbSubjectPsychologyLabel.
  ///
  /// In ru, this message translates to:
  /// **'Психология'**
  String get onbSubjectPsychologyLabel;

  /// No description provided for @onbSubjectPsychologyDesc.
  ///
  /// In ru, this message translates to:
  /// **'Поведение и психика'**
  String get onbSubjectPsychologyDesc;

  /// No description provided for @onbSubjectPoliticsLabel.
  ///
  /// In ru, this message translates to:
  /// **'Политика'**
  String get onbSubjectPoliticsLabel;

  /// No description provided for @onbSubjectPoliticsDesc.
  ///
  /// In ru, this message translates to:
  /// **'Политология и дипломатия'**
  String get onbSubjectPoliticsDesc;

  /// No description provided for @onbSubjectEconomicsLabel.
  ///
  /// In ru, this message translates to:
  /// **'Экономика'**
  String get onbSubjectEconomicsLabel;

  /// No description provided for @onbSubjectEconomicsDesc.
  ///
  /// In ru, this message translates to:
  /// **'Финансы и бизнес'**
  String get onbSubjectEconomicsDesc;

  /// No description provided for @onbSubjectChemistryLabel.
  ///
  /// In ru, this message translates to:
  /// **'Химия'**
  String get onbSubjectChemistryLabel;

  /// No description provided for @onbSubjectChemistryDesc.
  ///
  /// In ru, this message translates to:
  /// **'Реакции и вещества'**
  String get onbSubjectChemistryDesc;

  /// No description provided for @onbSubjectBiologyLabel.
  ///
  /// In ru, this message translates to:
  /// **'Биология'**
  String get onbSubjectBiologyLabel;

  /// No description provided for @onbSubjectBiologyDesc.
  ///
  /// In ru, this message translates to:
  /// **'Жизнь и медицина'**
  String get onbSubjectBiologyDesc;

  /// No description provided for @onbSubjectPhysicsLabel.
  ///
  /// In ru, this message translates to:
  /// **'Физика'**
  String get onbSubjectPhysicsLabel;

  /// No description provided for @onbSubjectPhysicsDesc.
  ///
  /// In ru, this message translates to:
  /// **'Механика и кванты'**
  String get onbSubjectPhysicsDesc;

  /// No description provided for @onbSubjectMathLabel.
  ///
  /// In ru, this message translates to:
  /// **'Математика'**
  String get onbSubjectMathLabel;

  /// No description provided for @onbSubjectMathDesc.
  ///
  /// In ru, this message translates to:
  /// **'Алгебра и анализ'**
  String get onbSubjectMathDesc;

  /// No description provided for @onbTrustTitle.
  ///
  /// In ru, this message translates to:
  /// **'Построено с экспертами ведущих вузов'**
  String get onbTrustTitle;

  /// No description provided for @onbTrustSubtitle.
  ///
  /// In ru, this message translates to:
  /// **'Контент разработан при участии методистов университетов Казахстана и международных партнёров.'**
  String get onbTrustSubtitle;

  /// No description provided for @onbConfidenceTitle.
  ///
  /// In ru, this message translates to:
  /// **'Насколько ты уверен, что поступишь?'**
  String get onbConfidenceTitle;

  /// No description provided for @onbConfidenceSubtitle.
  ///
  /// In ru, this message translates to:
  /// **'Честный ответ поможет правильно составить план'**
  String get onbConfidenceSubtitle;

  /// No description provided for @onbConfidence100Label.
  ///
  /// In ru, this message translates to:
  /// **'Уверен на 100%'**
  String get onbConfidence100Label;

  /// No description provided for @onbConfidence100Desc.
  ///
  /// In ru, this message translates to:
  /// **'Знаю, что поступлю'**
  String get onbConfidence100Desc;

  /// No description provided for @onbConfidenceMostlyYesLabel.
  ///
  /// In ru, this message translates to:
  /// **'Скорее да'**
  String get onbConfidenceMostlyYesLabel;

  /// No description provided for @onbConfidenceMostlyYesDesc.
  ///
  /// In ru, this message translates to:
  /// **'Хороший шанс есть'**
  String get onbConfidenceMostlyYesDesc;

  /// No description provided for @onbConfidenceNotSureLabel.
  ///
  /// In ru, this message translates to:
  /// **'Ещё не уверен'**
  String get onbConfidenceNotSureLabel;

  /// No description provided for @onbConfidenceNotSureDesc.
  ///
  /// In ru, this message translates to:
  /// **'Нужно больше подготовки'**
  String get onbConfidenceNotSureDesc;

  /// No description provided for @onbConfidenceJustStartingLabel.
  ///
  /// In ru, this message translates to:
  /// **'Только начинаю'**
  String get onbConfidenceJustStartingLabel;

  /// No description provided for @onbConfidenceJustStartingDesc.
  ///
  /// In ru, this message translates to:
  /// **'Ещё не разобрался с целями'**
  String get onbConfidenceJustStartingDesc;

  /// No description provided for @onbStatsTitle.
  ///
  /// In ru, this message translates to:
  /// **'Твои академические показатели'**
  String get onbStatsTitle;

  /// No description provided for @onbStatsSubtitle.
  ///
  /// In ru, this message translates to:
  /// **'Необязательно — можно пропустить. Это нужно для честной оценки шансов.'**
  String get onbStatsSubtitle;

  /// No description provided for @onbStatsGpaLabel.
  ///
  /// In ru, this message translates to:
  /// **'ГПА / Средний балл'**
  String get onbStatsGpaLabel;

  /// No description provided for @onbStatsGpaHint.
  ///
  /// In ru, this message translates to:
  /// **'Например: 4.8'**
  String get onbStatsGpaHint;

  /// No description provided for @onbStatsIeltsLabel.
  ///
  /// In ru, this message translates to:
  /// **'IELTS (если есть)'**
  String get onbStatsIeltsLabel;

  /// No description provided for @onbStatsIeltsHint.
  ///
  /// In ru, this message translates to:
  /// **'Например: 7.0'**
  String get onbStatsIeltsHint;

  /// No description provided for @onbStatsSatLabel.
  ///
  /// In ru, this message translates to:
  /// **'SAT (если есть)'**
  String get onbStatsSatLabel;

  /// No description provided for @onbStatsSatHint.
  ///
  /// In ru, this message translates to:
  /// **'Например: 1400'**
  String get onbStatsSatHint;

  /// No description provided for @onbTopicUniverseTitle.
  ///
  /// In ru, this message translates to:
  /// **'Всё, что нужно — уже здесь'**
  String get onbTopicUniverseTitle;

  /// No description provided for @onbTopicUniverseMascotCaption.
  ///
  /// In ru, this message translates to:
  /// **'Я знаю, с чего начать'**
  String get onbTopicUniverseMascotCaption;

  /// No description provided for @onbGoalTitle.
  ///
  /// In ru, this message translates to:
  /// **'Сколько времени в день?'**
  String get onbGoalTitle;

  /// No description provided for @onbGoalMinUnit.
  ///
  /// In ru, this message translates to:
  /// **'мин'**
  String get onbGoalMinUnit;

  /// No description provided for @onbGoal10Subtitle.
  ///
  /// In ru, this message translates to:
  /// **'Немного, но каждый день'**
  String get onbGoal10Subtitle;

  /// No description provided for @onbGoal20Subtitle.
  ///
  /// In ru, this message translates to:
  /// **'Стабильный прогресс'**
  String get onbGoal20Subtitle;

  /// No description provided for @onbGoal30Subtitle.
  ///
  /// In ru, this message translates to:
  /// **'Хороший темп'**
  String get onbGoal30Subtitle;

  /// No description provided for @onbGoal60Subtitle.
  ///
  /// In ru, this message translates to:
  /// **'Погружение'**
  String get onbGoal60Subtitle;

  /// No description provided for @onbScheduleTitle.
  ///
  /// In ru, this message translates to:
  /// **'Когда удобнее?'**
  String get onbScheduleTitle;

  /// No description provided for @onbScheduleMorningLabel.
  ///
  /// In ru, this message translates to:
  /// **'Утро'**
  String get onbScheduleMorningLabel;

  /// No description provided for @onbScheduleMorningSubtitle.
  ///
  /// In ru, this message translates to:
  /// **'До начала дня'**
  String get onbScheduleMorningSubtitle;

  /// No description provided for @onbScheduleDayLabel.
  ///
  /// In ru, this message translates to:
  /// **'День'**
  String get onbScheduleDayLabel;

  /// No description provided for @onbScheduleDaySubtitle.
  ///
  /// In ru, this message translates to:
  /// **'В свободное время'**
  String get onbScheduleDaySubtitle;

  /// No description provided for @onbScheduleEveningLabel.
  ///
  /// In ru, this message translates to:
  /// **'Вечер'**
  String get onbScheduleEveningLabel;

  /// No description provided for @onbScheduleEveningSubtitle.
  ///
  /// In ru, this message translates to:
  /// **'После учёбы'**
  String get onbScheduleEveningSubtitle;

  /// No description provided for @onbScheduleFlexLabel.
  ///
  /// In ru, this message translates to:
  /// **'Когда получится'**
  String get onbScheduleFlexLabel;

  /// No description provided for @onbScheduleFlexSubtitle.
  ///
  /// In ru, this message translates to:
  /// **'Гибкий график'**
  String get onbScheduleFlexSubtitle;

  /// No description provided for @onbNotificationsTitle.
  ///
  /// In ru, this message translates to:
  /// **'Напоминания'**
  String get onbNotificationsTitle;

  /// No description provided for @onbNotificationsBody.
  ///
  /// In ru, this message translates to:
  /// **'Хочешь, чтобы Admity напоминал о занятиях?'**
  String get onbNotificationsBody;

  /// No description provided for @onbNotificationsEnableButton.
  ///
  /// In ru, this message translates to:
  /// **'Включить'**
  String get onbNotificationsEnableButton;

  /// No description provided for @onbNotificationsSkipButton.
  ///
  /// In ru, this message translates to:
  /// **'Пропустить'**
  String get onbNotificationsSkipButton;

  /// No description provided for @onbThreeStepTitle.
  ///
  /// In ru, this message translates to:
  /// **'Твой план на три шага'**
  String get onbThreeStepTitle;

  /// No description provided for @onbPlanStep1Title.
  ///
  /// In ru, this message translates to:
  /// **'Изучи основы'**
  String get onbPlanStep1Title;

  /// No description provided for @onbPlanStep1Desc.
  ///
  /// In ru, this message translates to:
  /// **'Разберём базу по твоему предмету'**
  String get onbPlanStep1Desc;

  /// No description provided for @onbPlanStep2Title.
  ///
  /// In ru, this message translates to:
  /// **'Практикуй'**
  String get onbPlanStep2Title;

  /// No description provided for @onbPlanStep2Desc.
  ///
  /// In ru, this message translates to:
  /// **'Задачи, тесты, разборы ошибок'**
  String get onbPlanStep2Desc;

  /// No description provided for @onbPlanStep3Title.
  ///
  /// In ru, this message translates to:
  /// **'Проверь себя'**
  String get onbPlanStep3Title;

  /// No description provided for @onbPlanStep3Desc.
  ///
  /// In ru, this message translates to:
  /// **'Финальный skill-check и анализ результатов'**
  String get onbPlanStep3Desc;

  /// No description provided for @onbCreatePlanButton.
  ///
  /// In ru, this message translates to:
  /// **'Создать мой план'**
  String get onbCreatePlanButton;

  /// No description provided for @onbPlanCreationTitle.
  ///
  /// In ru, this message translates to:
  /// **'Создаём твой план…'**
  String get onbPlanCreationTitle;

  /// No description provided for @onbPlanCreationCard1.
  ///
  /// In ru, this message translates to:
  /// **'Анализируем твой профиль'**
  String get onbPlanCreationCard1;

  /// No description provided for @onbPlanCreationCard2.
  ///
  /// In ru, this message translates to:
  /// **'Подбираем вузы и направления'**
  String get onbPlanCreationCard2;

  /// No description provided for @onbPlanCreationCard3.
  ///
  /// In ru, this message translates to:
  /// **'Строим персональный путь'**
  String get onbPlanCreationCard3;

  /// No description provided for @onbPlanCreationAlmost.
  ///
  /// In ru, this message translates to:
  /// **'Почти готово…'**
  String get onbPlanCreationAlmost;

  /// No description provided for @onbFinishTitle.
  ///
  /// In ru, this message translates to:
  /// **'Всё готово!'**
  String get onbFinishTitle;

  /// No description provided for @onbFinishSubtitle.
  ///
  /// In ru, this message translates to:
  /// **'Твой персональный план создан. Начинаем?'**
  String get onbFinishSubtitle;

  /// No description provided for @onbFinishStartButton.
  ///
  /// In ru, this message translates to:
  /// **'Начать'**
  String get onbFinishStartButton;

  /// No description provided for @onbReminderTitle.
  ///
  /// In ru, this message translates to:
  /// **'Время учиться с Admity 🎓'**
  String get onbReminderTitle;

  /// No description provided for @onbReminderBody.
  ///
  /// In ru, this message translates to:
  /// **'Удели {minutes} мин подготовке к поступлению — ты на верном пути!'**
  String onbReminderBody(int minutes);

  /// No description provided for @onbStudyPlanCareerTest.
  ///
  /// In ru, this message translates to:
  /// **'Пройди профориентационный тест, чтобы подтвердить интерес к {major}'**
  String onbStudyPlanCareerTest(String major);

  /// No description provided for @onbStudyPlanUpdateProfile.
  ///
  /// In ru, this message translates to:
  /// **'Убедись, что профиль — ЕНТ, ГПА, оценки — актуален и точен'**
  String get onbStudyPlanUpdateProfile;

  /// No description provided for @onbStudyPlanExploreRequirements.
  ///
  /// In ru, this message translates to:
  /// **'Изучи вступительные требования и проходные баллы по направлению {major}'**
  String onbStudyPlanExploreRequirements(String major);

  /// No description provided for @onbStudyPlanTargetList.
  ///
  /// In ru, this message translates to:
  /// **'Составь список целевых вузов (Казахстан и/или за рубежом) с дедлайнами'**
  String get onbStudyPlanTargetList;

  /// No description provided for @onbStudyPlanDailyTime.
  ///
  /// In ru, this message translates to:
  /// **'Выдели {timeLabel} ежедневное время для подготовки и придерживайся расписания'**
  String onbStudyPlanDailyTime(String timeLabel);

  /// No description provided for @onbStudyPlanPracticeTests.
  ///
  /// In ru, this message translates to:
  /// **'Практикуй тестовые задания ЕНТ / международные экзамены по выбранным предметам'**
  String get onbStudyPlanPracticeTests;

  /// No description provided for @onbStudyPlanIntlDocs.
  ///
  /// In ru, this message translates to:
  /// **'Подготовь документы для международных заявок: эссе, рекомендации, языковые сертификаты'**
  String get onbStudyPlanIntlDocs;

  /// No description provided for @onbStudyPlanLocalDocs.
  ///
  /// In ru, this message translates to:
  /// **'Собери пакет документов: аттестат, транскрипт, рекомендательные письма'**
  String get onbStudyPlanLocalDocs;

  /// No description provided for @onbStudyPlanTimeMorning.
  ///
  /// In ru, this message translates to:
  /// **'утром'**
  String get onbStudyPlanTimeMorning;

  /// No description provided for @onbStudyPlanTimeDay.
  ///
  /// In ru, this message translates to:
  /// **'днём'**
  String get onbStudyPlanTimeDay;

  /// No description provided for @onbStudyPlanTimeEvening.
  ///
  /// In ru, this message translates to:
  /// **'вечером'**
  String get onbStudyPlanTimeEvening;

  /// No description provided for @onbStudyPlanTimeFlex.
  ///
  /// In ru, this message translates to:
  /// **'в удобное время'**
  String get onbStudyPlanTimeFlex;

  /// No description provided for @onbStudyPlanDefaultMajor.
  ///
  /// In ru, this message translates to:
  /// **'выбранному направлению'**
  String get onbStudyPlanDefaultMajor;

  /// No description provided for @oppScreenTitle.
  ///
  /// In ru, this message translates to:
  /// **'Возможности'**
  String get oppScreenTitle;

  /// No description provided for @oppTabScholarships.
  ///
  /// In ru, this message translates to:
  /// **'Стипендии'**
  String get oppTabScholarships;

  /// No description provided for @oppTabEvents.
  ///
  /// In ru, this message translates to:
  /// **'Мероприятия'**
  String get oppTabEvents;

  /// No description provided for @oppTabProjectIdeas.
  ///
  /// In ru, this message translates to:
  /// **'Идеи проектов'**
  String get oppTabProjectIdeas;

  /// No description provided for @oppFilterCityDefault.
  ///
  /// In ru, this message translates to:
  /// **'Город'**
  String get oppFilterCityDefault;

  /// No description provided for @oppFilterFieldDefault.
  ///
  /// In ru, this message translates to:
  /// **'Направление'**
  String get oppFilterFieldDefault;

  /// No description provided for @oppFilterAccessibilityDefault.
  ///
  /// In ru, this message translates to:
  /// **'Доступность'**
  String get oppFilterAccessibilityDefault;

  /// No description provided for @oppFilterReset.
  ///
  /// In ru, this message translates to:
  /// **'Сбросить'**
  String get oppFilterReset;

  /// No description provided for @oppFilterResetAll.
  ///
  /// In ru, this message translates to:
  /// **'Сбросить фильтр'**
  String get oppFilterResetAll;

  /// No description provided for @oppPickerCityTitle.
  ///
  /// In ru, this message translates to:
  /// **'Выбрать город'**
  String get oppPickerCityTitle;

  /// No description provided for @oppPickerFieldTitle.
  ///
  /// In ru, this message translates to:
  /// **'Выбрать направление'**
  String get oppPickerFieldTitle;

  /// No description provided for @oppPickerAccessibilityTitle.
  ///
  /// In ru, this message translates to:
  /// **'Выбрать доступность'**
  String get oppPickerAccessibilityTitle;

  /// No description provided for @oppCardMoreDetails.
  ///
  /// In ru, this message translates to:
  /// **'Подробнее'**
  String get oppCardMoreDetails;

  /// No description provided for @oppScholarshipsEmpty.
  ///
  /// In ru, this message translates to:
  /// **'Нет стипендий по выбранным фильтрам'**
  String get oppScholarshipsEmpty;

  /// No description provided for @oppEventsBannerNearby.
  ///
  /// In ru, this message translates to:
  /// **'рядом с тобой — {city}'**
  String oppEventsBannerNearby(String city);

  /// No description provided for @oppEventsBannerSetCity.
  ///
  /// In ru, this message translates to:
  /// **'Укажи свой город в профиле, чтобы видеть мероприятия рядом'**
  String get oppEventsBannerSetCity;

  /// No description provided for @oppEventLocalBadge.
  ///
  /// In ru, this message translates to:
  /// **'Рядом'**
  String get oppEventLocalBadge;

  /// No description provided for @oppIdeasBannerInterest.
  ///
  /// In ru, this message translates to:
  /// **'по твоему интересу: {interest}'**
  String oppIdeasBannerInterest(String interest);

  /// No description provided for @oppIdeasBannerAddInterests.
  ///
  /// In ru, this message translates to:
  /// **'Добавь интересы в профиле — покажем идеи специально для тебя'**
  String get oppIdeasBannerAddInterests;

  /// No description provided for @oppAcademicFieldMathematics.
  ///
  /// In ru, this message translates to:
  /// **'Математика'**
  String get oppAcademicFieldMathematics;

  /// No description provided for @oppAcademicFieldEngineering.
  ///
  /// In ru, this message translates to:
  /// **'Инженерия'**
  String get oppAcademicFieldEngineering;

  /// No description provided for @oppAcademicFieldMedicine.
  ///
  /// In ru, this message translates to:
  /// **'Медицина'**
  String get oppAcademicFieldMedicine;

  /// No description provided for @oppAcademicFieldEconomics.
  ///
  /// In ru, this message translates to:
  /// **'Экономика'**
  String get oppAcademicFieldEconomics;

  /// No description provided for @oppAcademicFieldArts.
  ///
  /// In ru, this message translates to:
  /// **'Искусство'**
  String get oppAcademicFieldArts;

  /// No description provided for @oppAcademicFieldLaw.
  ///
  /// In ru, this message translates to:
  /// **'Право'**
  String get oppAcademicFieldLaw;

  /// No description provided for @oppAcademicFieldInformatics.
  ///
  /// In ru, this message translates to:
  /// **'Информатика'**
  String get oppAcademicFieldInformatics;

  /// No description provided for @oppAcademicFieldNatural.
  ///
  /// In ru, this message translates to:
  /// **'Естественные науки'**
  String get oppAcademicFieldNatural;

  /// No description provided for @oppAccessibilityEasy.
  ///
  /// In ru, this message translates to:
  /// **'Легко'**
  String get oppAccessibilityEasy;

  /// No description provided for @oppAccessibilityMedium.
  ///
  /// In ru, this message translates to:
  /// **'Средне'**
  String get oppAccessibilityMedium;

  /// No description provided for @oppAccessibilityHard.
  ///
  /// In ru, this message translates to:
  /// **'Сложно'**
  String get oppAccessibilityHard;

  /// No description provided for @oppDifficultyEasy.
  ///
  /// In ru, this message translates to:
  /// **'Легко'**
  String get oppDifficultyEasy;

  /// No description provided for @oppDifficultyHard.
  ///
  /// In ru, this message translates to:
  /// **'Сложно'**
  String get oppDifficultyHard;

  /// No description provided for @oppUniversityAppBarFallback.
  ///
  /// In ru, this message translates to:
  /// **'Университет'**
  String get oppUniversityAppBarFallback;

  /// No description provided for @oppUniversityNotFound.
  ///
  /// In ru, this message translates to:
  /// **'Университет не найден'**
  String get oppUniversityNotFound;

  /// No description provided for @oppUniversityAboutSection.
  ///
  /// In ru, this message translates to:
  /// **'О университете'**
  String get oppUniversityAboutSection;

  /// No description provided for @oppUniversityProgramsSection.
  ///
  /// In ru, this message translates to:
  /// **'Направления'**
  String get oppUniversityProgramsSection;

  /// No description provided for @oppUniversityAdmissionChancesSection.
  ///
  /// In ru, this message translates to:
  /// **'Шансы поступления'**
  String get oppUniversityAdmissionChancesSection;

  /// No description provided for @oppUniversityAcceptanceRateLabel.
  ///
  /// In ru, this message translates to:
  /// **'Уровень приёма — реалистичная оценка'**
  String get oppUniversityAcceptanceRateLabel;

  /// No description provided for @oppUniversityEntThreshold.
  ///
  /// In ru, this message translates to:
  /// **'ЕНТ ≥ {score} баллов'**
  String oppUniversityEntThreshold(int score);

  /// No description provided for @oppUniversityRequirementsSection.
  ///
  /// In ru, this message translates to:
  /// **'Требования'**
  String get oppUniversityRequirementsSection;

  /// No description provided for @oppUniversityCostSection.
  ///
  /// In ru, this message translates to:
  /// **'Стоимость и стипендии'**
  String get oppUniversityCostSection;

  /// No description provided for @oppUniversityAdmissionStepsSection.
  ///
  /// In ru, this message translates to:
  /// **'Как поступить'**
  String get oppUniversityAdmissionStepsSection;

  /// No description provided for @oppUniversityOpenWebsite.
  ///
  /// In ru, this message translates to:
  /// **'Открыть сайт: {label}'**
  String oppUniversityOpenWebsite(String label);

  /// No description provided for @oppEventAppBarFallback.
  ///
  /// In ru, this message translates to:
  /// **'Мероприятие'**
  String get oppEventAppBarFallback;

  /// No description provided for @oppEventNotFound.
  ///
  /// In ru, this message translates to:
  /// **'Мероприятие не найдено'**
  String get oppEventNotFound;

  /// No description provided for @oppEventDiagramSlotLabel.
  ///
  /// In ru, this message translates to:
  /// **'Мероприятие'**
  String get oppEventDiagramSlotLabel;

  /// No description provided for @oppEventAboutSection.
  ///
  /// In ru, this message translates to:
  /// **'О мероприятии'**
  String get oppEventAboutSection;

  /// No description provided for @oppEventPrizesSection.
  ///
  /// In ru, this message translates to:
  /// **'Призы'**
  String get oppEventPrizesSection;

  /// No description provided for @oppEventRegistrationDeadline.
  ///
  /// In ru, this message translates to:
  /// **'Дедлайн регистрации: {deadline}'**
  String oppEventRegistrationDeadline(String deadline);

  /// No description provided for @oppEventHowToParticipateSection.
  ///
  /// In ru, this message translates to:
  /// **'Как участвовать'**
  String get oppEventHowToParticipateSection;

  /// No description provided for @oppEventAddToList.
  ///
  /// In ru, this message translates to:
  /// **'Добавить в список мероприятий'**
  String get oppEventAddToList;

  /// No description provided for @oppEventSaved.
  ///
  /// In ru, this message translates to:
  /// **'Мероприятие сохранено'**
  String get oppEventSaved;

  /// No description provided for @oppScholarshipAppBarFallback.
  ///
  /// In ru, this message translates to:
  /// **'Стипендия'**
  String get oppScholarshipAppBarFallback;

  /// No description provided for @oppScholarshipNotFound.
  ///
  /// In ru, this message translates to:
  /// **'Стипендия не найдена'**
  String get oppScholarshipNotFound;

  /// No description provided for @oppScholarshipCoverageSection.
  ///
  /// In ru, this message translates to:
  /// **'Что покрывает'**
  String get oppScholarshipCoverageSection;

  /// No description provided for @oppScholarshipHowToGetSection.
  ///
  /// In ru, this message translates to:
  /// **'Как получить'**
  String get oppScholarshipHowToGetSection;

  /// No description provided for @oppScholarshipRequiredStatsSection.
  ///
  /// In ru, this message translates to:
  /// **'Нужные показатели'**
  String get oppScholarshipRequiredStatsSection;

  /// No description provided for @oppScholarshipHowToBoostLabel.
  ///
  /// In ru, this message translates to:
  /// **'Как их добить:'**
  String get oppScholarshipHowToBoostLabel;

  /// No description provided for @oppScholarshipDocumentsSection.
  ///
  /// In ru, this message translates to:
  /// **'Требуемые документы'**
  String get oppScholarshipDocumentsSection;

  /// No description provided for @oppScholarshipApplyCta.
  ///
  /// In ru, this message translates to:
  /// **'Подать заявку'**
  String get oppScholarshipApplyCta;

  /// No description provided for @oppIdeaAppBarFallback.
  ///
  /// In ru, this message translates to:
  /// **'Идея проекта'**
  String get oppIdeaAppBarFallback;

  /// No description provided for @oppIdeaNotFound.
  ///
  /// In ru, this message translates to:
  /// **'Идея проекта не найдена'**
  String get oppIdeaNotFound;

  /// No description provided for @oppIdeaWhatSection.
  ///
  /// In ru, this message translates to:
  /// **'Что за проект'**
  String get oppIdeaWhatSection;

  /// No description provided for @oppIdeaWhySection.
  ///
  /// In ru, this message translates to:
  /// **'Почему это твоё'**
  String get oppIdeaWhySection;

  /// No description provided for @oppIdeaStepsSection.
  ///
  /// In ru, this message translates to:
  /// **'Шаги'**
  String get oppIdeaStepsSection;

  /// No description provided for @oppIdeaOutcomeSection.
  ///
  /// In ru, this message translates to:
  /// **'Что получишь в итоге'**
  String get oppIdeaOutcomeSection;

  /// No description provided for @oppIdeaSaveIdea.
  ///
  /// In ru, this message translates to:
  /// **'Сохранить идею'**
  String get oppIdeaSaveIdea;

  /// No description provided for @oppIdeaSavedSnackbar.
  ///
  /// In ru, this message translates to:
  /// **'Идея сохранена в профиль'**
  String get oppIdeaSavedSnackbar;

  /// No description provided for @oppApplyAppBarTitle.
  ///
  /// In ru, this message translates to:
  /// **'Подача заявки'**
  String get oppApplyAppBarTitle;

  /// No description provided for @oppApplyFormTitle.
  ///
  /// In ru, this message translates to:
  /// **'Заполните заявку'**
  String get oppApplyFormTitle;

  /// No description provided for @oppApplyFormSubtitle.
  ///
  /// In ru, this message translates to:
  /// **'Все поля обязательны. Данные хранятся локально.'**
  String get oppApplyFormSubtitle;

  /// No description provided for @oppApplyFieldFullName.
  ///
  /// In ru, this message translates to:
  /// **'ФИО'**
  String get oppApplyFieldFullName;

  /// No description provided for @oppApplyHintFullName.
  ///
  /// In ru, this message translates to:
  /// **'Иванов Иван Иванович'**
  String get oppApplyHintFullName;

  /// No description provided for @oppApplyFieldContact.
  ///
  /// In ru, this message translates to:
  /// **'Контакт (email или телефон)'**
  String get oppApplyFieldContact;

  /// No description provided for @oppApplyHintContact.
  ///
  /// In ru, this message translates to:
  /// **'example@mail.kz или +7 777 000 00 00'**
  String get oppApplyHintContact;

  /// No description provided for @oppApplyFieldMotivation.
  ///
  /// In ru, this message translates to:
  /// **'Мотивационное письмо'**
  String get oppApplyFieldMotivation;

  /// No description provided for @oppApplyHintMotivation.
  ///
  /// In ru, this message translates to:
  /// **'Расскажите, почему вы хотите получить эту стипендию и как она поможет вашему обучению...'**
  String get oppApplyHintMotivation;

  /// No description provided for @oppApplySubmitButton.
  ///
  /// In ru, this message translates to:
  /// **'Отправить заявку'**
  String get oppApplySubmitButton;

  /// No description provided for @oppApplyErrorFullNameEmpty.
  ///
  /// In ru, this message translates to:
  /// **'Введите ФИО'**
  String get oppApplyErrorFullNameEmpty;

  /// No description provided for @oppApplyErrorContactEmpty.
  ///
  /// In ru, this message translates to:
  /// **'Введите контакт'**
  String get oppApplyErrorContactEmpty;

  /// No description provided for @oppApplyErrorMotivationTooShort.
  ///
  /// In ru, this message translates to:
  /// **'Напишите не менее 20 символов'**
  String get oppApplyErrorMotivationTooShort;

  /// No description provided for @oppApplySuccessTitle.
  ///
  /// In ru, this message translates to:
  /// **'Заявка отправлена!'**
  String get oppApplySuccessTitle;

  /// No description provided for @oppApplySuccessBody.
  ///
  /// In ru, this message translates to:
  /// **'Мы сохранили твою заявку. Следи за статусом в разделе «Профиль → Документы».'**
  String get oppApplySuccessBody;

  /// No description provided for @oppApplySuccessCardTitle.
  ///
  /// In ru, this message translates to:
  /// **'Заявка принята'**
  String get oppApplySuccessCardTitle;

  /// No description provided for @oppApplySuccessCardSubtitle.
  ///
  /// In ru, this message translates to:
  /// **'Данные сохранены локально'**
  String get oppApplySuccessCardSubtitle;

  /// No description provided for @oppApplySuccessBackButton.
  ///
  /// In ru, this message translates to:
  /// **'Вернуться к стипендиям'**
  String get oppApplySuccessBackButton;

  /// No description provided for @oppCareerTestTitle.
  ///
  /// In ru, this message translates to:
  /// **'Узнай свою профессию'**
  String get oppCareerTestTitle;

  /// No description provided for @oppCareerTestProgressLabel.
  ///
  /// In ru, this message translates to:
  /// **'{current} / {total}'**
  String oppCareerTestProgressLabel(int current, int total);

  /// No description provided for @oppCareerTestCategoryLabel.
  ///
  /// In ru, this message translates to:
  /// **'Работа с людьми'**
  String get oppCareerTestCategoryLabel;

  /// No description provided for @oppCareerCategoryAnalytical.
  ///
  /// In ru, this message translates to:
  /// **'Аналитика'**
  String get oppCareerCategoryAnalytical;

  /// No description provided for @oppCareerCategoryCreative.
  ///
  /// In ru, this message translates to:
  /// **'Творчество'**
  String get oppCareerCategoryCreative;

  /// No description provided for @oppCareerCategoryTechnical.
  ///
  /// In ru, this message translates to:
  /// **'Технологии'**
  String get oppCareerCategoryTechnical;

  /// No description provided for @oppCareerCategoryLeadership.
  ///
  /// In ru, this message translates to:
  /// **'Управление'**
  String get oppCareerCategoryLeadership;

  /// No description provided for @oppCareerAnswerYes.
  ///
  /// In ru, this message translates to:
  /// **'Да'**
  String get oppCareerAnswerYes;

  /// No description provided for @oppCareerAnswerNo.
  ///
  /// In ru, this message translates to:
  /// **'Нет'**
  String get oppCareerAnswerNo;

  /// No description provided for @oppCareerAnswerSometimes.
  ///
  /// In ru, this message translates to:
  /// **'Иногда'**
  String get oppCareerAnswerSometimes;

  /// No description provided for @oppCareerAnswerMaybe.
  ///
  /// In ru, this message translates to:
  /// **'Возможно'**
  String get oppCareerAnswerMaybe;

  /// No description provided for @oppCareerResultTitleDone.
  ///
  /// In ru, this message translates to:
  /// **'Ты прошёл тест!'**
  String get oppCareerResultTitleDone;

  /// No description provided for @oppCareerResultTitleAlreadyDone.
  ///
  /// In ru, this message translates to:
  /// **'Тест уже пройден!'**
  String get oppCareerResultTitleAlreadyDone;

  /// No description provided for @oppCareerResultStrengthLabel.
  ///
  /// In ru, this message translates to:
  /// **'Твоя сильная сторона:'**
  String get oppCareerResultStrengthLabel;

  /// No description provided for @oppCareerResultInsightFallback.
  ///
  /// In ru, this message translates to:
  /// **'Продолжай развивать свои навыки!'**
  String get oppCareerResultInsightFallback;

  /// No description provided for @oppCareerResultCategoriesHeader.
  ///
  /// In ru, this message translates to:
  /// **'Результаты по категориям:'**
  String get oppCareerResultCategoriesHeader;

  /// No description provided for @oppCareerResultReturnTomorrow.
  ///
  /// In ru, this message translates to:
  /// **'Возвращайся завтра за новым тестом'**
  String get oppCareerResultReturnTomorrow;

  /// No description provided for @oppCareerResultHomeButton.
  ///
  /// In ru, this message translates to:
  /// **'На главную'**
  String get oppCareerResultHomeButton;

  /// No description provided for @oppCareerInsightSocial.
  ///
  /// In ru, this message translates to:
  /// **'Ты прирождённый коммуникатор! Твои сильные стороны — эмпатия и умение находить общий язык. Тебе подойдут профессии: педагог, психолог, HR-менеджер, социальный работник, PR-специалист.'**
  String get oppCareerInsightSocial;

  /// No description provided for @oppCareerInsightAnalytical.
  ///
  /// In ru, this message translates to:
  /// **'Ты мыслишь системно и любишь разбираться в данных. Обрати внимание на: аналитик данных, финансист, учёный, программист, экономист.'**
  String get oppCareerInsightAnalytical;

  /// No description provided for @oppCareerInsightCreative.
  ///
  /// In ru, this message translates to:
  /// **'Ты видишь мир иначе и умеешь создавать что-то новое. Твои направления: дизайнер, художник, архитектор, режиссёр, UX-специалист, маркетолог.'**
  String get oppCareerInsightCreative;

  /// No description provided for @oppCareerInsightTechnical.
  ///
  /// In ru, this message translates to:
  /// **'Ты любишь разбираться в том, как всё устроено, и создавать реальные решения. Профессии для тебя: инженер, программист, IT-специалист, учёный, исследователь.'**
  String get oppCareerInsightTechnical;

  /// No description provided for @oppCareerInsightLeadership.
  ///
  /// In ru, this message translates to:
  /// **'Ты умеешь вести за собой людей и достигать целей через команду. Тебе подойдут: менеджер, предприниматель, государственный деятель, топ-менеджер, стратег.'**
  String get oppCareerInsightLeadership;

  /// No description provided for @oppLessonIntroTitle.
  ///
  /// In ru, this message translates to:
  /// **'Сравнение вероятностей'**
  String get oppLessonIntroTitle;

  /// No description provided for @oppLessonIntroSubtitle.
  ///
  /// In ru, this message translates to:
  /// **'Научись сравнивать шансы событий и понимать, что является достоверным, невозможным или случайным.'**
  String get oppLessonIntroSubtitle;

  /// No description provided for @oppLessonStatTheoryCards.
  ///
  /// In ru, this message translates to:
  /// **'{count} карточки теории'**
  String oppLessonStatTheoryCards(int count);

  /// No description provided for @oppLessonStatQuestions.
  ///
  /// In ru, this message translates to:
  /// **'{count} вопроса'**
  String oppLessonStatQuestions(int count);

  /// No description provided for @oppLessonStatXp.
  ///
  /// In ru, this message translates to:
  /// **'+50 XP'**
  String get oppLessonStatXp;

  /// No description provided for @oppLessonStartButton.
  ///
  /// In ru, this message translates to:
  /// **'Начать урок'**
  String get oppLessonStartButton;

  /// No description provided for @oppLessonTheoryPill.
  ///
  /// In ru, this message translates to:
  /// **'Теория  {current} / {total}'**
  String oppLessonTheoryPill(int current, int total);

  /// No description provided for @oppLessonTheoryNextButton.
  ///
  /// In ru, this message translates to:
  /// **'Далее'**
  String get oppLessonTheoryNextButton;

  /// No description provided for @oppLessonTheoryToQuestionsButton.
  ///
  /// In ru, this message translates to:
  /// **'К вопросам'**
  String get oppLessonTheoryToQuestionsButton;

  /// No description provided for @oppLessonQuestionPill.
  ///
  /// In ru, this message translates to:
  /// **'Вопрос {current} из {total}'**
  String oppLessonQuestionPill(int current, int total);

  /// No description provided for @oppLessonCheckButton.
  ///
  /// In ru, this message translates to:
  /// **'Проверить'**
  String get oppLessonCheckButton;

  /// No description provided for @oppLessonTrueFalseTrue.
  ///
  /// In ru, this message translates to:
  /// **'Верно'**
  String get oppLessonTrueFalseTrue;

  /// No description provided for @oppLessonTrueFalseFalse.
  ///
  /// In ru, this message translates to:
  /// **'Неверно'**
  String get oppLessonTrueFalseFalse;

  /// No description provided for @oppLessonFeedbackCorrect.
  ///
  /// In ru, this message translates to:
  /// **'Верно!'**
  String get oppLessonFeedbackCorrect;

  /// No description provided for @oppLessonFeedbackIncorrect.
  ///
  /// In ru, this message translates to:
  /// **'Неверно'**
  String get oppLessonFeedbackIncorrect;

  /// No description provided for @oppLessonFeedbackXpBadge.
  ///
  /// In ru, this message translates to:
  /// **'+{xp} XP'**
  String oppLessonFeedbackXpBadge(int xp);

  /// No description provided for @oppLessonWhyExpander.
  ///
  /// In ru, this message translates to:
  /// **'Почему?'**
  String get oppLessonWhyExpander;

  /// No description provided for @oppLessonContinueButton.
  ///
  /// In ru, this message translates to:
  /// **'Продолжить'**
  String get oppLessonContinueButton;

  /// No description provided for @oppLessonCompleteTitle.
  ///
  /// In ru, this message translates to:
  /// **'Урок пройден!'**
  String get oppLessonCompleteTitle;

  /// No description provided for @oppLessonCompleteSubtitle.
  ///
  /// In ru, this message translates to:
  /// **'Отличная работа! Ты завершил урок о вероятностях.'**
  String get oppLessonCompleteSubtitle;

  /// No description provided for @oppLessonXpEarned.
  ///
  /// In ru, this message translates to:
  /// **'Заработано XP'**
  String get oppLessonXpEarned;

  /// No description provided for @oppLessonXpValue.
  ///
  /// In ru, this message translates to:
  /// **'+{xp} XP'**
  String oppLessonXpValue(int xp);

  /// No description provided for @oppLessonCorrectAnswersLabel.
  ///
  /// In ru, this message translates to:
  /// **'Правильных ответов'**
  String get oppLessonCorrectAnswersLabel;

  /// No description provided for @oppLessonCorrectAnswersValue.
  ///
  /// In ru, this message translates to:
  /// **'{correct} из {total}'**
  String oppLessonCorrectAnswersValue(int correct, int total);

  /// No description provided for @oppLessonDoneButton.
  ///
  /// In ru, this message translates to:
  /// **'Готово'**
  String get oppLessonDoneButton;

  /// No description provided for @oppLessonTheoryProbabilityTitle.
  ///
  /// In ru, this message translates to:
  /// **'Что такое вероятность?'**
  String get oppLessonTheoryProbabilityTitle;

  /// No description provided for @oppLessonTheoryProbabilityBody.
  ///
  /// In ru, this message translates to:
  /// **'Вероятность — это число от 0 до 1, которое описывает, насколько вероятно наступление события. Число 0 означает, что событие невозможно, а число 1 означает, что оно обязательно произойдёт. Все события «между» имеют вероятность строго больше 0 и меньше 1.'**
  String get oppLessonTheoryProbabilityBody;

  /// No description provided for @oppLessonTheoryFormulaTitle.
  ///
  /// In ru, this message translates to:
  /// **'Классическая формула'**
  String get oppLessonTheoryFormulaTitle;

  /// No description provided for @oppLessonTheoryFormulaBody.
  ///
  /// In ru, this message translates to:
  /// **'P(A) = m / n, где m — количество благоприятных исходов, n — общее количество равновозможных исходов. Пример: бросаем монету. n = 2 (орёл и решка), m = 1 (орёл). Значит P(орёл) = 1/2 = 0,5.'**
  String get oppLessonTheoryFormulaBody;

  /// No description provided for @oppLessonTheoryComparingTitle.
  ///
  /// In ru, this message translates to:
  /// **'Сравнение вероятностей'**
  String get oppLessonTheoryComparingTitle;

  /// No description provided for @oppLessonTheoryComparingBody.
  ///
  /// In ru, this message translates to:
  /// **'Вероятности сравниваются так же, как обычные дроби. P(A) > P(B) значит, что событие A произойдёт чаще, чем B. Например: вероятность вытащить красный шар из мешка (3 красных из 10) = 3/10 = 0,3, а синий = 7/10 = 0,7. Синий вероятнее.'**
  String get oppLessonTheoryComparingBody;

  /// No description provided for @oppLessonTheoryCertainTitle.
  ///
  /// In ru, this message translates to:
  /// **'Достоверные и невозможные события'**
  String get oppLessonTheoryCertainTitle;

  /// No description provided for @oppLessonTheoryCertainBody.
  ///
  /// In ru, this message translates to:
  /// **'Достоверное событие происходит всегда (P = 1). Пример: при броске кубика выпадет число от 1 до 6 — это достоверно. Невозможное событие не происходит никогда (P = 0). Пример: на том же кубике выпадет 7.'**
  String get oppLessonTheoryCertainBody;

  /// No description provided for @oppLessonQ0Text.
  ///
  /// In ru, this message translates to:
  /// **'Бросают монету. Какова вероятность выпадения орла?'**
  String get oppLessonQ0Text;

  /// No description provided for @oppLessonQ0Explanation.
  ///
  /// In ru, this message translates to:
  /// **'Монета имеет два равновероятных исхода: орёл и решка. Поэтому вероятность орла = 1/2 = 0.5.'**
  String get oppLessonQ0Explanation;

  /// No description provided for @oppLessonQ1Text.
  ///
  /// In ru, this message translates to:
  /// **'Вероятность достоверного события равна 1.'**
  String get oppLessonQ1Text;

  /// No description provided for @oppLessonQ1OptionTrue.
  ///
  /// In ru, this message translates to:
  /// **'Верно'**
  String get oppLessonQ1OptionTrue;

  /// No description provided for @oppLessonQ1OptionFalse.
  ///
  /// In ru, this message translates to:
  /// **'Неверно'**
  String get oppLessonQ1OptionFalse;

  /// No description provided for @oppLessonQ1Explanation.
  ///
  /// In ru, this message translates to:
  /// **'Достоверное событие — то, которое обязательно произойдёт. По определению, его вероятность равна 1.'**
  String get oppLessonQ1Explanation;

  /// No description provided for @oppLessonQ2Text.
  ///
  /// In ru, this message translates to:
  /// **'Вероятность невозможного события равна ____.'**
  String get oppLessonQ2Text;

  /// No description provided for @oppLessonQ2Explanation.
  ///
  /// In ru, this message translates to:
  /// **'Невозможное событие не может произойти никогда. Его вероятность равна 0 по определению.'**
  String get oppLessonQ2Explanation;

  /// No description provided for @profScreenTitle.
  ///
  /// In ru, this message translates to:
  /// **'Профиль'**
  String get profScreenTitle;

  /// No description provided for @profAddDataPrompt.
  ///
  /// In ru, this message translates to:
  /// **'Добавь данные о себе →'**
  String get profAddDataPrompt;

  /// No description provided for @profEditTooltip.
  ///
  /// In ru, this message translates to:
  /// **'Редактировать данные'**
  String get profEditTooltip;

  /// No description provided for @profGoalChip.
  ///
  /// In ru, this message translates to:
  /// **'Цель: {minutes} мин/день'**
  String profGoalChip(int minutes);

  /// No description provided for @profDocPackagesSectionTitle.
  ///
  /// In ru, this message translates to:
  /// **'Пакет документов'**
  String get profDocPackagesSectionTitle;

  /// No description provided for @profDocPackagesSectionSubtitle.
  ///
  /// In ru, this message translates to:
  /// **'Отмечай документы по мере готовности и прикрепляй файлы'**
  String get profDocPackagesSectionSubtitle;

  /// No description provided for @profMyDocsSectionTitle.
  ///
  /// In ru, this message translates to:
  /// **'Мои документы'**
  String get profMyDocsSectionTitle;

  /// No description provided for @profMyDocsSectionSubtitle.
  ///
  /// In ru, this message translates to:
  /// **'Прикрепляй файлы, открывай и делись с куратором'**
  String get profMyDocsSectionSubtitle;

  /// No description provided for @profCareerTestCardTitle.
  ///
  /// In ru, this message translates to:
  /// **'Тест на профориентацию'**
  String get profCareerTestCardTitle;

  /// No description provided for @profCareerTestCardSubtitleDuration.
  ///
  /// In ru, this message translates to:
  /// **'Займёт ~10–15 минут'**
  String get profCareerTestCardSubtitleDuration;

  /// No description provided for @profCareerTestCardSubtitleRetake.
  ///
  /// In ru, this message translates to:
  /// **'Результат: {result}. Пройти снова?'**
  String profCareerTestCardSubtitleRetake(String result);

  /// No description provided for @profCareerTestDialogTitle.
  ///
  /// In ru, this message translates to:
  /// **'Тест на профориентацию'**
  String get profCareerTestDialogTitle;

  /// No description provided for @profCareerTestDialogBody.
  ///
  /// In ru, this message translates to:
  /// **'Тест займёт 10–15 минут. Отвечай честно — так результат будет точнее.'**
  String get profCareerTestDialogBody;

  /// No description provided for @profCareerTestDialogCancel.
  ///
  /// In ru, this message translates to:
  /// **'Отмена'**
  String get profCareerTestDialogCancel;

  /// No description provided for @profCareerTestDialogConfirm.
  ///
  /// In ru, this message translates to:
  /// **'Продолжить'**
  String get profCareerTestDialogConfirm;

  /// No description provided for @profNewPackageTitle.
  ///
  /// In ru, this message translates to:
  /// **'Новый пакет'**
  String get profNewPackageTitle;

  /// No description provided for @profNewPackageNameLabel.
  ///
  /// In ru, this message translates to:
  /// **'Название пакета'**
  String get profNewPackageNameLabel;

  /// No description provided for @profNewPackageNameHint.
  ///
  /// In ru, this message translates to:
  /// **'Например: NU 2026'**
  String get profNewPackageNameHint;

  /// No description provided for @profNewPackageDescLabel.
  ///
  /// In ru, this message translates to:
  /// **'Описание (необязательно)'**
  String get profNewPackageDescLabel;

  /// No description provided for @profNewPackageDescHint.
  ///
  /// In ru, this message translates to:
  /// **'Документы для Назарбаев Университета'**
  String get profNewPackageDescHint;

  /// No description provided for @profCreatePackageButton.
  ///
  /// In ru, this message translates to:
  /// **'Создать пакет'**
  String get profCreatePackageButton;

  /// No description provided for @profPackageProgress.
  ///
  /// In ru, this message translates to:
  /// **'{attached} / {total} подтверждено'**
  String profPackageProgress(int attached, int total);

  /// No description provided for @profDocActionOpen.
  ///
  /// In ru, this message translates to:
  /// **'Открыть'**
  String get profDocActionOpen;

  /// No description provided for @profDocActionReplace.
  ///
  /// In ru, this message translates to:
  /// **'Заменить'**
  String get profDocActionReplace;

  /// No description provided for @profDocActionRemove.
  ///
  /// In ru, this message translates to:
  /// **'Убрать из пакета'**
  String get profDocActionRemove;

  /// No description provided for @profDocAttachButton.
  ///
  /// In ru, this message translates to:
  /// **'Прикрепить'**
  String get profDocAttachButton;

  /// No description provided for @profNoAttachedFiles.
  ///
  /// In ru, this message translates to:
  /// **'Нет прикреплённых файлов'**
  String get profNoAttachedFiles;

  /// No description provided for @profAttachFileButton.
  ///
  /// In ru, this message translates to:
  /// **'Прикрепить файл'**
  String get profAttachFileButton;

  /// No description provided for @profDocActionShare.
  ///
  /// In ru, this message translates to:
  /// **'Поделиться'**
  String get profDocActionShare;

  /// No description provided for @profDocActionDelete.
  ///
  /// In ru, this message translates to:
  /// **'Удалить'**
  String get profDocActionDelete;

  /// No description provided for @profAddDocumentButton.
  ///
  /// In ru, this message translates to:
  /// **'Добавить документ'**
  String get profAddDocumentButton;

  /// No description provided for @profAddDocSheetTitle.
  ///
  /// In ru, this message translates to:
  /// **'Добавить документ'**
  String get profAddDocSheetTitle;

  /// No description provided for @profAddDocSheetSubtitle.
  ///
  /// In ru, this message translates to:
  /// **'в пакет «{packageName}»'**
  String profAddDocSheetSubtitle(String packageName);

  /// No description provided for @profAddDocUploadNew.
  ///
  /// In ru, this message translates to:
  /// **'Загрузить новый файл'**
  String get profAddDocUploadNew;

  /// No description provided for @profAddDocAddSlot.
  ///
  /// In ru, this message translates to:
  /// **'Добавить пункт без файла'**
  String get profAddDocAddSlot;

  /// No description provided for @profAddDocFromMyDocs.
  ///
  /// In ru, this message translates to:
  /// **'Из моих документов'**
  String get profAddDocFromMyDocs;

  /// No description provided for @profAddDocNoSavedFiles.
  ///
  /// In ru, this message translates to:
  /// **'Пока нет сохранённых файлов. Загрузи новый — он появится и в разделе «Мои документы».'**
  String get profAddDocNoSavedFiles;

  /// No description provided for @profAddSlotDialogTitle.
  ///
  /// In ru, this message translates to:
  /// **'Новый пункт'**
  String get profAddSlotDialogTitle;

  /// No description provided for @profAddSlotDialogHint.
  ///
  /// In ru, this message translates to:
  /// **'Например: Рекомендательное письмо'**
  String get profAddSlotDialogHint;

  /// No description provided for @profAddSlotDialogCancel.
  ///
  /// In ru, this message translates to:
  /// **'Отмена'**
  String get profAddSlotDialogCancel;

  /// No description provided for @profAddSlotDialogAdd.
  ///
  /// In ru, this message translates to:
  /// **'Добавить'**
  String get profAddSlotDialogAdd;

  /// No description provided for @profEditScreenTitle.
  ///
  /// In ru, this message translates to:
  /// **'Мои данные'**
  String get profEditScreenTitle;

  /// No description provided for @profEditSectionPersonal.
  ///
  /// In ru, this message translates to:
  /// **'Личные данные'**
  String get profEditSectionPersonal;

  /// No description provided for @profEditFieldNameLabel.
  ///
  /// In ru, this message translates to:
  /// **'Имя'**
  String get profEditFieldNameLabel;

  /// No description provided for @profEditFieldNameHint.
  ///
  /// In ru, this message translates to:
  /// **'Как тебя зовут?'**
  String get profEditFieldNameHint;

  /// No description provided for @profEditFieldGradeLabel.
  ///
  /// In ru, this message translates to:
  /// **'Класс'**
  String get profEditFieldGradeLabel;

  /// No description provided for @profEditFieldGradeHint.
  ///
  /// In ru, this message translates to:
  /// **'11 класс'**
  String get profEditFieldGradeHint;

  /// No description provided for @profEditFieldCityLabel.
  ///
  /// In ru, this message translates to:
  /// **'Город'**
  String get profEditFieldCityLabel;

  /// No description provided for @profEditFieldCityHint.
  ///
  /// In ru, this message translates to:
  /// **'Алматы, Астана...'**
  String get profEditFieldCityHint;

  /// No description provided for @profEditFieldGpaLabel.
  ///
  /// In ru, this message translates to:
  /// **'Средний балл / ГПА'**
  String get profEditFieldGpaLabel;

  /// No description provided for @profEditFieldGpaHint.
  ///
  /// In ru, this message translates to:
  /// **'4.8'**
  String get profEditFieldGpaHint;

  /// No description provided for @profEditFieldLanguagesLabel.
  ///
  /// In ru, this message translates to:
  /// **'Языки (через запятую)'**
  String get profEditFieldLanguagesLabel;

  /// No description provided for @profEditFieldLanguagesHint.
  ///
  /// In ru, this message translates to:
  /// **'KZ, RU, EN'**
  String get profEditFieldLanguagesHint;

  /// No description provided for @profEditSectionAcademic.
  ///
  /// In ru, this message translates to:
  /// **'Направления и интересы'**
  String get profEditSectionAcademic;

  /// No description provided for @profEditFieldMajorsLabel.
  ///
  /// In ru, this message translates to:
  /// **'Направления учёбы (через запятую)'**
  String get profEditFieldMajorsLabel;

  /// No description provided for @profEditFieldMajorsHint.
  ///
  /// In ru, this message translates to:
  /// **'IT, Медицина, Финансы...'**
  String get profEditFieldMajorsHint;

  /// No description provided for @profEditFieldInterestsLabel.
  ///
  /// In ru, this message translates to:
  /// **'Интересы и хобби (через запятую)'**
  String get profEditFieldInterestsLabel;

  /// No description provided for @profEditFieldInterestsHint.
  ///
  /// In ru, this message translates to:
  /// **'Математика, Дизайн, Музыка...'**
  String get profEditFieldInterestsHint;

  /// No description provided for @profEditSectionExams.
  ///
  /// In ru, this message translates to:
  /// **'Результаты экзаменов'**
  String get profEditSectionExams;

  /// No description provided for @profEditFieldIeltsLabel.
  ///
  /// In ru, this message translates to:
  /// **'IELTS балл'**
  String get profEditFieldIeltsLabel;

  /// No description provided for @profEditFieldIeltsHint.
  ///
  /// In ru, this message translates to:
  /// **'7.0'**
  String get profEditFieldIeltsHint;

  /// No description provided for @profEditFieldSatLabel.
  ///
  /// In ru, this message translates to:
  /// **'SAT балл'**
  String get profEditFieldSatLabel;

  /// No description provided for @profEditFieldSatHint.
  ///
  /// In ru, this message translates to:
  /// **'1400'**
  String get profEditFieldSatHint;

  /// No description provided for @profEditFieldToeflLabel.
  ///
  /// In ru, this message translates to:
  /// **'TOEFL балл'**
  String get profEditFieldToeflLabel;

  /// No description provided for @profEditFieldToeflHint.
  ///
  /// In ru, this message translates to:
  /// **'100'**
  String get profEditFieldToeflHint;

  /// No description provided for @profEditSaveButton.
  ///
  /// In ru, this message translates to:
  /// **'Сохранить'**
  String get profEditSaveButton;

  /// No description provided for @profEditSavedSnackbar.
  ///
  /// In ru, this message translates to:
  /// **'Данные сохранены'**
  String get profEditSavedSnackbar;

  /// No description provided for @profCareerTestScreenTitle.
  ///
  /// In ru, this message translates to:
  /// **'Профориентация'**
  String get profCareerTestScreenTitle;

  /// No description provided for @profCareerTestProgress.
  ///
  /// In ru, this message translates to:
  /// **'{current} / {total}'**
  String profCareerTestProgress(int current, int total);

  /// No description provided for @profCareerTestWarning.
  ///
  /// In ru, this message translates to:
  /// **'Тест займёт ~10–15 минут. Ответь честно — результат будет точнее.'**
  String get profCareerTestWarning;

  /// No description provided for @profCareerTestQuestionLabel.
  ///
  /// In ru, this message translates to:
  /// **'Вопрос {number}'**
  String profCareerTestQuestionLabel(int number);

  /// No description provided for @profCareerTestAnswerNo.
  ///
  /// In ru, this message translates to:
  /// **'Нет'**
  String get profCareerTestAnswerNo;

  /// No description provided for @profCareerTestAnswerNeutral.
  ///
  /// In ru, this message translates to:
  /// **'Нейтрально'**
  String get profCareerTestAnswerNeutral;

  /// No description provided for @profCareerTestAnswerYes.
  ///
  /// In ru, this message translates to:
  /// **'Да'**
  String get profCareerTestAnswerYes;

  /// No description provided for @profCareerResultTitle.
  ///
  /// In ru, this message translates to:
  /// **'Результат готов!'**
  String get profCareerResultTitle;

  /// No description provided for @profCareerResultProfileLabel.
  ///
  /// In ru, this message translates to:
  /// **'Твой профиль'**
  String get profCareerResultProfileLabel;

  /// No description provided for @profCareerResultSavedNote.
  ///
  /// In ru, this message translates to:
  /// **'Результат сохранён в твоём профиле. Ты можешь пройти тест снова в любое время.'**
  String get profCareerResultSavedNote;

  /// No description provided for @profCareerResultCloseButton.
  ///
  /// In ru, this message translates to:
  /// **'Закрыть'**
  String get profCareerResultCloseButton;

  /// No description provided for @profNotifierLoadError.
  ///
  /// In ru, this message translates to:
  /// **'Ошибка загрузки: {error}'**
  String profNotifierLoadError(String error);

  /// No description provided for @profNotifierSaveError.
  ///
  /// In ru, this message translates to:
  /// **'Ошибка сохранения: {error}'**
  String profNotifierSaveError(String error);

  /// No description provided for @profSeedPackageName.
  ///
  /// In ru, this message translates to:
  /// **'Стандартный пакет КЗ'**
  String get profSeedPackageName;

  /// No description provided for @profSeedPackageDesc.
  ///
  /// In ru, this message translates to:
  /// **'Типовой набор документов для поступления в вузы Казахстана'**
  String get profSeedPackageDesc;

  /// No description provided for @profSeedItemId.
  ///
  /// In ru, this message translates to:
  /// **'Удостоверение личности / Свидетельство о рождении'**
  String get profSeedItemId;

  /// No description provided for @profSeedItemTranscript.
  ///
  /// In ru, this message translates to:
  /// **'Аттестат / Транскрипт оценок'**
  String get profSeedItemTranscript;

  /// No description provided for @profSeedItemMedical.
  ///
  /// In ru, this message translates to:
  /// **'Медицинская справка 086-У'**
  String get profSeedItemMedical;

  /// No description provided for @profSeedItemPhotos.
  ///
  /// In ru, this message translates to:
  /// **'Фотографии 3×4 (6 шт.)'**
  String get profSeedItemPhotos;

  /// No description provided for @profSeedItemUnt.
  ///
  /// In ru, this message translates to:
  /// **'Сертификат ЕНТ / ЕГЭ'**
  String get profSeedItemUnt;

  /// No description provided for @profSeedItemIntlExam.
  ///
  /// In ru, this message translates to:
  /// **'Сертификат IELTS / TOEFL / SAT (при наличии)'**
  String get profSeedItemIntlExam;

  /// No description provided for @profSeedItemMotivation.
  ///
  /// In ru, this message translates to:
  /// **'Мотивационное письмо'**
  String get profSeedItemMotivation;

  /// No description provided for @profSeedItemRecommendations.
  ///
  /// In ru, this message translates to:
  /// **'Рекомендательные письма (2 шт.)'**
  String get profSeedItemRecommendations;

  /// No description provided for @profSeedItemApplication.
  ///
  /// In ru, this message translates to:
  /// **'Заявление о поступлении'**
  String get profSeedItemApplication;

  /// No description provided for @profSeedItemParentalConsent.
  ///
  /// In ru, this message translates to:
  /// **'Согласие родителей (для несовершеннолетних)'**
  String get profSeedItemParentalConsent;

  /// No description provided for @profCareerResultEngineerResearcher.
  ///
  /// In ru, this message translates to:
  /// **'Инженер-исследователь'**
  String get profCareerResultEngineerResearcher;

  /// No description provided for @profCareerResultArchitectDesigner.
  ///
  /// In ru, this message translates to:
  /// **'Архитектор / Дизайнер продуктов'**
  String get profCareerResultArchitectDesigner;

  /// No description provided for @profCareerResultScientistInnovator.
  ///
  /// In ru, this message translates to:
  /// **'Учёный-новатор'**
  String get profCareerResultScientistInnovator;

  /// No description provided for @profCareerResultHrCoach.
  ///
  /// In ru, this message translates to:
  /// **'HR-менеджер / Тренер'**
  String get profCareerResultHrCoach;

  /// No description provided for @profCareerResultCfo.
  ///
  /// In ru, this message translates to:
  /// **'Финансовый директор'**
  String get profCareerResultCfo;

  /// No description provided for @profCareerResultArtTherapistEducator.
  ///
  /// In ru, this message translates to:
  /// **'Арт-терапевт / Педагог-творец'**
  String get profCareerResultArtTherapistEducator;

  /// No description provided for @profCareerResultEngineerTechnologist.
  ///
  /// In ru, this message translates to:
  /// **'Инженер / Технолог'**
  String get profCareerResultEngineerTechnologist;

  /// No description provided for @profCareerResultScientistAnalyst.
  ///
  /// In ru, this message translates to:
  /// **'Учёный / Аналитик'**
  String get profCareerResultScientistAnalyst;

  /// No description provided for @profCareerResultCreativeDesigner.
  ///
  /// In ru, this message translates to:
  /// **'Творческий деятель / Дизайнер'**
  String get profCareerResultCreativeDesigner;

  /// No description provided for @profCareerResultTeacherPsychologist.
  ///
  /// In ru, this message translates to:
  /// **'Педагог / Психолог'**
  String get profCareerResultTeacherPsychologist;

  /// No description provided for @profCareerResultEntrepreneurManager.
  ///
  /// In ru, this message translates to:
  /// **'Предприниматель / Менеджер'**
  String get profCareerResultEntrepreneurManager;

  /// No description provided for @profCareerResultFinancistAdministrator.
  ///
  /// In ru, this message translates to:
  /// **'Финансист / Администратор'**
  String get profCareerResultFinancistAdministrator;

  /// No description provided for @profCareerQ1.
  ///
  /// In ru, this message translates to:
  /// **'Мне нравится собирать и чинить вещи своими руками'**
  String get profCareerQ1;

  /// No description provided for @profCareerQ2.
  ///
  /// In ru, this message translates to:
  /// **'Я предпочитаю работу на свежем воздухе'**
  String get profCareerQ2;

  /// No description provided for @profCareerQ3.
  ///
  /// In ru, this message translates to:
  /// **'Мне интересны технические устройства и механизмы'**
  String get profCareerQ3;

  /// No description provided for @profCareerQ4.
  ///
  /// In ru, this message translates to:
  /// **'Я люблю физический труд'**
  String get profCareerQ4;

  /// No description provided for @profCareerQ5.
  ///
  /// In ru, this message translates to:
  /// **'Мне нравится работать с инструментами и оборудованием'**
  String get profCareerQ5;

  /// No description provided for @profCareerQ6.
  ///
  /// In ru, this message translates to:
  /// **'Мне нравится решать сложные задачи и головоломки'**
  String get profCareerQ6;

  /// No description provided for @profCareerQ7.
  ///
  /// In ru, this message translates to:
  /// **'Я с удовольствием провожу время за чтением научных статей'**
  String get profCareerQ7;

  /// No description provided for @profCareerQ8.
  ///
  /// In ru, this message translates to:
  /// **'Мне интересно изучать, как устроен мир вокруг нас'**
  String get profCareerQ8;

  /// No description provided for @profCareerQ9.
  ///
  /// In ru, this message translates to:
  /// **'Я люблю анализировать данные и искать закономерности'**
  String get profCareerQ9;

  /// No description provided for @profCareerQ10.
  ///
  /// In ru, this message translates to:
  /// **'Мне нравится проводить эксперименты'**
  String get profCareerQ10;

  /// No description provided for @profCareerQ11.
  ///
  /// In ru, this message translates to:
  /// **'Я люблю рисовать, писать или музицировать'**
  String get profCareerQ11;

  /// No description provided for @profCareerQ12.
  ///
  /// In ru, this message translates to:
  /// **'Мне нравится создавать что-то красивое или оригинальное'**
  String get profCareerQ12;

  /// No description provided for @profCareerQ13.
  ///
  /// In ru, this message translates to:
  /// **'Я часто нахожу нестандартные решения'**
  String get profCareerQ13;

  /// No description provided for @profCareerQ14.
  ///
  /// In ru, this message translates to:
  /// **'Творческое самовыражение важно для меня'**
  String get profCareerQ14;

  /// No description provided for @profCareerQ15.
  ///
  /// In ru, this message translates to:
  /// **'Мне нравится дизайн и эстетика'**
  String get profCareerQ15;

  /// No description provided for @profCareerQ16.
  ///
  /// In ru, this message translates to:
  /// **'Мне нравится помогать другим людям'**
  String get profCareerQ16;

  /// No description provided for @profCareerQ17.
  ///
  /// In ru, this message translates to:
  /// **'Я хорошо чувствую настроение и эмоции других'**
  String get profCareerQ17;

  /// No description provided for @profCareerQ18.
  ///
  /// In ru, this message translates to:
  /// **'Мне нравится работать в команде'**
  String get profCareerQ18;

  /// No description provided for @profCareerQ19.
  ///
  /// In ru, this message translates to:
  /// **'Я с удовольствием обучаю других'**
  String get profCareerQ19;

  /// No description provided for @profCareerQ20.
  ///
  /// In ru, this message translates to:
  /// **'Волонтёрство и помощь обществу важны для меня'**
  String get profCareerQ20;

  /// No description provided for @profCareerQ21.
  ///
  /// In ru, this message translates to:
  /// **'Мне нравится убеждать людей и вести переговоры'**
  String get profCareerQ21;

  /// No description provided for @profCareerQ22.
  ///
  /// In ru, this message translates to:
  /// **'Я готов брать на себя ответственность и руководить'**
  String get profCareerQ22;

  /// No description provided for @profCareerQ23.
  ///
  /// In ru, this message translates to:
  /// **'Меня привлекает создание бизнеса'**
  String get profCareerQ23;

  /// No description provided for @profCareerQ24.
  ///
  /// In ru, this message translates to:
  /// **'Мне нравится соревноваться и побеждать'**
  String get profCareerQ24;

  /// No description provided for @profCareerQ25.
  ///
  /// In ru, this message translates to:
  /// **'Я умею продавать идеи и продукты'**
  String get profCareerQ25;

  /// No description provided for @profCareerQ26.
  ///
  /// In ru, this message translates to:
  /// **'Мне нравится работать с цифрами и документами'**
  String get profCareerQ26;

  /// No description provided for @profCareerQ27.
  ///
  /// In ru, this message translates to:
  /// **'Я ценю порядок и организованность'**
  String get profCareerQ27;

  /// No description provided for @profCareerQ28.
  ///
  /// In ru, this message translates to:
  /// **'Мне нравится следовать чётким правилам и инструкциям'**
  String get profCareerQ28;

  /// No description provided for @profCareerQ29.
  ///
  /// In ru, this message translates to:
  /// **'Мне интересна бухгалтерия, финансы или управление данными'**
  String get profCareerQ29;

  /// No description provided for @profCareerQ30.
  ///
  /// In ru, this message translates to:
  /// **'Я люблю систематизировать и классифицировать информацию'**
  String get profCareerQ30;

  /// No description provided for @sharedNavHome.
  ///
  /// In ru, this message translates to:
  /// **'Главная'**
  String get sharedNavHome;

  /// No description provided for @sharedNavUniversities.
  ///
  /// In ru, this message translates to:
  /// **'Вузы'**
  String get sharedNavUniversities;

  /// No description provided for @sharedNavEraly.
  ///
  /// In ru, this message translates to:
  /// **'Ералы'**
  String get sharedNavEraly;

  /// No description provided for @sharedNavOpportunities.
  ///
  /// In ru, this message translates to:
  /// **'Возможности'**
  String get sharedNavOpportunities;

  /// No description provided for @sharedNavProfile.
  ///
  /// In ru, this message translates to:
  /// **'Профиль'**
  String get sharedNavProfile;

  /// No description provided for @sharedNotifStudyReminderTitle.
  ///
  /// In ru, this message translates to:
  /// **'Время учиться!'**
  String get sharedNotifStudyReminderTitle;

  /// No description provided for @sharedNotifStudyBody10.
  ///
  /// In ru, this message translates to:
  /// **'Всего 10 минут — и ты на шаг ближе к цели!'**
  String get sharedNotifStudyBody10;

  /// No description provided for @sharedNotifStudyBody20.
  ///
  /// In ru, this message translates to:
  /// **'20 минут занятий сегодня — ты справишься!'**
  String get sharedNotifStudyBody20;

  /// No description provided for @sharedNotifStudyBody30.
  ///
  /// In ru, this message translates to:
  /// **'Запланировано {minutes} минут учёбы. Начнём?'**
  String sharedNotifStudyBody30(int minutes);

  /// No description provided for @sharedNotifStudyBodyBig.
  ///
  /// In ru, this message translates to:
  /// **'Большая цель сегодня: {minutes} минут. Удачи!'**
  String sharedNotifStudyBodyBig(int minutes);

  /// No description provided for @sharedNotifCalendarNowTitle.
  ///
  /// In ru, this message translates to:
  /// **'Сейчас: {eventTitle}'**
  String sharedNotifCalendarNowTitle(String eventTitle);

  /// No description provided for @sharedNotifCalendarNowBody.
  ///
  /// In ru, this message translates to:
  /// **'Событие начинается!'**
  String get sharedNotifCalendarNowBody;

  /// No description provided for @sharedNotifCalendarSoonTitle.
  ///
  /// In ru, this message translates to:
  /// **'Скоро: {eventTitle}'**
  String sharedNotifCalendarSoonTitle(String eventTitle);

  /// No description provided for @sharedNotifCalendarSoonBody.
  ///
  /// In ru, this message translates to:
  /// **'Запланировано на сегодня.'**
  String get sharedNotifCalendarSoonBody;

  /// No description provided for @sharedNotifTodoNudgeTitle.
  ///
  /// In ru, this message translates to:
  /// **'{count, plural, one{У тебя {count} задача на сегодня} few{У тебя {count} задачи на сегодня} many{У тебя {count} задач на сегодня} other{У тебя {count} задач на сегодня}}'**
  String sharedNotifTodoNudgeTitle(int count);

  /// No description provided for @sharedNotifChannelName.
  ///
  /// In ru, this message translates to:
  /// **'Ежедневные напоминания'**
  String get sharedNotifChannelName;

  /// No description provided for @sharedNotifChannelDesc.
  ///
  /// In ru, this message translates to:
  /// **'Напоминания о ежедневной учёбе и предстоящих событиях'**
  String get sharedNotifChannelDesc;

  /// No description provided for @uniTitle.
  ///
  /// In ru, this message translates to:
  /// **'Вузы'**
  String get uniTitle;

  /// No description provided for @uniSubtitleKz.
  ///
  /// In ru, this message translates to:
  /// **'{count} вузов Казахстана'**
  String uniSubtitleKz(int count);

  /// No description provided for @uniErrorLoad.
  ///
  /// In ru, this message translates to:
  /// **'Не удалось загрузить список вузов'**
  String get uniErrorLoad;

  /// No description provided for @uniEmptyList.
  ///
  /// In ru, this message translates to:
  /// **'Список вузов пуст'**
  String get uniEmptyList;

  /// No description provided for @uniNoResults.
  ///
  /// In ru, this message translates to:
  /// **'Нет вузов по выбранным фильтрам'**
  String get uniNoResults;

  /// No description provided for @uniFilterCity.
  ///
  /// In ru, this message translates to:
  /// **'Город'**
  String get uniFilterCity;

  /// No description provided for @uniFilterType.
  ///
  /// In ru, this message translates to:
  /// **'Тип'**
  String get uniFilterType;

  /// No description provided for @uniFilterReset.
  ///
  /// In ru, this message translates to:
  /// **'Сбросить'**
  String get uniFilterReset;

  /// No description provided for @uniPickCityTitle.
  ///
  /// In ru, this message translates to:
  /// **'Выбрать город'**
  String get uniPickCityTitle;

  /// No description provided for @uniPickTypeTitle.
  ///
  /// In ru, this message translates to:
  /// **'Выбрать тип'**
  String get uniPickTypeTitle;

  /// No description provided for @uniFilterClearItem.
  ///
  /// In ru, this message translates to:
  /// **'Сбросить фильтр'**
  String get uniFilterClearItem;

  /// No description provided for @uniProgramCount.
  ///
  /// In ru, this message translates to:
  /// **'{count, plural, one{{count} программа} few{{count} программы} many{{count} программ} other{{count} программ}}'**
  String uniProgramCount(int count);

  /// No description provided for @uniCompetitionFrom.
  ///
  /// In ru, this message translates to:
  /// **'конкурс от {score} б.'**
  String uniCompetitionFrom(int score);

  /// No description provided for @uniTypeNational.
  ///
  /// In ru, this message translates to:
  /// **'Национальный'**
  String get uniTypeNational;

  /// No description provided for @uniTypeState.
  ///
  /// In ru, this message translates to:
  /// **'Государственный'**
  String get uniTypeState;

  /// No description provided for @uniTypeAutonomous.
  ///
  /// In ru, this message translates to:
  /// **'Автономный'**
  String get uniTypeAutonomous;

  /// No description provided for @uniTypePrivate.
  ///
  /// In ru, this message translates to:
  /// **'Частный'**
  String get uniTypePrivate;

  /// No description provided for @uniTypeInternational.
  ///
  /// In ru, this message translates to:
  /// **'Международный'**
  String get uniTypeInternational;

  /// No description provided for @uniHubSubtitle.
  ///
  /// In ru, this message translates to:
  /// **'Выбери, какие вузы хочешь изучить'**
  String get uniHubSubtitle;

  /// No description provided for @uniHubKzTitle.
  ///
  /// In ru, this message translates to:
  /// **'Вузы Казахстана'**
  String get uniHubKzTitle;

  /// No description provided for @uniHubKzSubtitle.
  ///
  /// In ru, this message translates to:
  /// **'Каталог 88+ вузов с конкурсными баллами и ГОП'**
  String get uniHubKzSubtitle;

  /// No description provided for @uniHubAbroadTitle.
  ///
  /// In ru, this message translates to:
  /// **'Вузы за рубежом'**
  String get uniHubAbroadTitle;

  /// No description provided for @uniHubAbroadSubtitle.
  ///
  /// In ru, this message translates to:
  /// **'Топ мировые университеты с финансовой помощью для иностранцев'**
  String get uniHubAbroadSubtitle;

  /// No description provided for @uniAbroadTitle.
  ///
  /// In ru, this message translates to:
  /// **'Вузы за рубежом'**
  String get uniAbroadTitle;

  /// No description provided for @uniAbroadCountSubtitle.
  ///
  /// In ru, this message translates to:
  /// **'{count} вузов мира'**
  String uniAbroadCountSubtitle(int count);

  /// No description provided for @uniAbroadErrorLoad.
  ///
  /// In ru, this message translates to:
  /// **'Не удалось загрузить список зарубежных вузов'**
  String get uniAbroadErrorLoad;

  /// No description provided for @uniAbroadEmptyList.
  ///
  /// In ru, this message translates to:
  /// **'Список зарубежных вузов пуст'**
  String get uniAbroadEmptyList;

  /// No description provided for @uniAbroadMatchBadge.
  ///
  /// In ru, this message translates to:
  /// **'совпадение'**
  String get uniAbroadMatchBadge;

  /// No description provided for @uniAbroadTuitionPerYear.
  ///
  /// In ru, this message translates to:
  /// **'\${price}/год'**
  String uniAbroadTuitionPerYear(String price);

  /// No description provided for @uniFinAidNeedBlind.
  ///
  /// In ru, this message translates to:
  /// **'Нужд-слепой приём'**
  String get uniFinAidNeedBlind;

  /// No description provided for @uniFinAidGenerous.
  ///
  /// In ru, this message translates to:
  /// **'Щедрая финпомощь'**
  String get uniFinAidGenerous;

  /// No description provided for @uniFinAidLimited.
  ///
  /// In ru, this message translates to:
  /// **'Ограниченная помощь'**
  String get uniFinAidLimited;

  /// No description provided for @uniFinAidNone.
  ///
  /// In ru, this message translates to:
  /// **'Без финпомощи'**
  String get uniFinAidNone;

  /// No description provided for @uniShortFinAidNeedBlind.
  ///
  /// In ru, this message translates to:
  /// **'need-blind'**
  String get uniShortFinAidNeedBlind;

  /// No description provided for @uniShortFinAidGenerous.
  ///
  /// In ru, this message translates to:
  /// **'щедрые гранты'**
  String get uniShortFinAidGenerous;

  /// No description provided for @uniShortFinAidLimited.
  ///
  /// In ru, this message translates to:
  /// **'лимит. помощь'**
  String get uniShortFinAidLimited;

  /// No description provided for @uniShortFinAidNone.
  ///
  /// In ru, this message translates to:
  /// **'без помощи'**
  String get uniShortFinAidNone;

  /// No description provided for @uniDetailErrorLoad.
  ///
  /// In ru, this message translates to:
  /// **'Не удалось загрузить данные'**
  String get uniDetailErrorLoad;

  /// No description provided for @uniDetailNotFound.
  ///
  /// In ru, this message translates to:
  /// **'Вуз не найден'**
  String get uniDetailNotFound;

  /// No description provided for @uniDetailFinanceSection.
  ///
  /// In ru, this message translates to:
  /// **'Финансы'**
  String get uniDetailFinanceSection;

  /// No description provided for @uniDetailFinAidLabel.
  ///
  /// In ru, this message translates to:
  /// **'Финансовая помощь'**
  String get uniDetailFinAidLabel;

  /// No description provided for @uniDetailTuitionLabel.
  ///
  /// In ru, this message translates to:
  /// **'Стоимость в год'**
  String get uniDetailTuitionLabel;

  /// No description provided for @uniDetailMajorsSection.
  ///
  /// In ru, this message translates to:
  /// **'Направления'**
  String get uniDetailMajorsSection;

  /// No description provided for @uniDetailSourceLink.
  ///
  /// In ru, this message translates to:
  /// **'Источник: {url}'**
  String uniDetailSourceLink(String url);

  /// No description provided for @uniMajorCs.
  ///
  /// In ru, this message translates to:
  /// **'CS'**
  String get uniMajorCs;

  /// No description provided for @uniMajorEngineering.
  ///
  /// In ru, this message translates to:
  /// **'Инженерия'**
  String get uniMajorEngineering;

  /// No description provided for @uniMajorMathematics.
  ///
  /// In ru, this message translates to:
  /// **'Математика'**
  String get uniMajorMathematics;

  /// No description provided for @uniMajorPhysics.
  ///
  /// In ru, this message translates to:
  /// **'Физика'**
  String get uniMajorPhysics;

  /// No description provided for @uniMajorChemistry.
  ///
  /// In ru, this message translates to:
  /// **'Химия'**
  String get uniMajorChemistry;

  /// No description provided for @uniMajorBiology.
  ///
  /// In ru, this message translates to:
  /// **'Биология'**
  String get uniMajorBiology;

  /// No description provided for @uniMajorMedicine.
  ///
  /// In ru, this message translates to:
  /// **'Медицина'**
  String get uniMajorMedicine;

  /// No description provided for @uniMajorEconomics.
  ///
  /// In ru, this message translates to:
  /// **'Экономика'**
  String get uniMajorEconomics;

  /// No description provided for @uniMajorBusiness.
  ///
  /// In ru, this message translates to:
  /// **'Бизнес'**
  String get uniMajorBusiness;

  /// No description provided for @uniMajorPsychology.
  ///
  /// In ru, this message translates to:
  /// **'Психология'**
  String get uniMajorPsychology;

  /// No description provided for @uniMajorPolitics.
  ///
  /// In ru, this message translates to:
  /// **'Политология'**
  String get uniMajorPolitics;

  /// No description provided for @uniDetailKzErrorLoad.
  ///
  /// In ru, this message translates to:
  /// **'Не удалось загрузить вуз'**
  String get uniDetailKzErrorLoad;

  /// No description provided for @uniDetailKzNotFound.
  ///
  /// In ru, this message translates to:
  /// **'Вуз не найден'**
  String get uniDetailKzNotFound;

  /// No description provided for @uniDetailHasDormYes.
  ///
  /// In ru, this message translates to:
  /// **'Да'**
  String get uniDetailHasDormYes;

  /// No description provided for @uniDetailHasDormNo.
  ///
  /// In ru, this message translates to:
  /// **'Нет'**
  String get uniDetailHasDormNo;

  /// No description provided for @uniDetailHasDormitory.
  ///
  /// In ru, this message translates to:
  /// **'Есть общежитие'**
  String get uniDetailHasDormitory;

  /// No description provided for @uniDetailStatPrograms.
  ///
  /// In ru, this message translates to:
  /// **'программ'**
  String get uniDetailStatPrograms;

  /// No description provided for @uniDetailStatCompetition.
  ///
  /// In ru, this message translates to:
  /// **'конкурс от, б.'**
  String get uniDetailStatCompetition;

  /// No description provided for @uniDetailStatDormitory.
  ///
  /// In ru, this message translates to:
  /// **'общежитие'**
  String get uniDetailStatDormitory;

  /// No description provided for @uniDetailAboutSection.
  ///
  /// In ru, this message translates to:
  /// **'О вузе'**
  String get uniDetailAboutSection;

  /// No description provided for @uniDetailInfoSection.
  ///
  /// In ru, this message translates to:
  /// **'Информация'**
  String get uniDetailInfoSection;

  /// No description provided for @uniDetailProgramsSection.
  ///
  /// In ru, this message translates to:
  /// **'Программы ({count})'**
  String uniDetailProgramsSection(int count);

  /// No description provided for @uniDetailProgramsNote.
  ///
  /// In ru, this message translates to:
  /// **'Балл — минимум для участия в конкурсе на грант (НЦТ). Это не проходной балл. Нажми на программу, чтобы раскрыть детали.'**
  String get uniDetailProgramsNote;

  /// No description provided for @uniDetailCompetitionFrom.
  ///
  /// In ru, this message translates to:
  /// **'Конкурс от {score} б.'**
  String uniDetailCompetitionFrom(int score);

  /// No description provided for @uniDetailLanguagesLabel.
  ///
  /// In ru, this message translates to:
  /// **'Языки обучения'**
  String get uniDetailLanguagesLabel;

  /// No description provided for @uniDetailGrantPlacesLabel.
  ///
  /// In ru, this message translates to:
  /// **'Грантовых мест'**
  String get uniDetailGrantPlacesLabel;

  /// No description provided for @uniDetailTuitionKztLabel.
  ///
  /// In ru, this message translates to:
  /// **'Стоимость в год'**
  String get uniDetailTuitionKztLabel;

  /// No description provided for @uniDetailNoScoreData.
  ///
  /// In ru, this message translates to:
  /// **'Данных по баллам пока нет.'**
  String get uniDetailNoScoreData;

  /// No description provided for @uniDetailScoresByYear.
  ///
  /// In ru, this message translates to:
  /// **'Баллы по годам'**
  String get uniDetailScoresByYear;

  /// No description provided for @uniDetailUnverified.
  ///
  /// In ru, this message translates to:
  /// **'не подтверждено'**
  String get uniDetailUnverified;

  /// No description provided for @uniDetailEmptyPrograms.
  ///
  /// In ru, this message translates to:
  /// **'Для этого вуза пока нет данных по программам и грантам.'**
  String get uniDetailEmptyPrograms;

  /// No description provided for @uniDetailSourcesTitle.
  ///
  /// In ru, this message translates to:
  /// **'Источники данных'**
  String get uniDetailSourcesTitle;

  /// No description provided for @uniLangKz.
  ///
  /// In ru, this message translates to:
  /// **'каз'**
  String get uniLangKz;

  /// No description provided for @uniLangRu.
  ///
  /// In ru, this message translates to:
  /// **'рус'**
  String get uniLangRu;

  /// No description provided for @uniLangEn.
  ///
  /// In ru, this message translates to:
  /// **'англ'**
  String get uniLangEn;

  /// No description provided for @uniQuotaGeneral.
  ///
  /// In ru, this message translates to:
  /// **'Общий конкурс'**
  String get uniQuotaGeneral;

  /// No description provided for @uniQuotaRural.
  ///
  /// In ru, this message translates to:
  /// **'Сельская квота'**
  String get uniQuotaRural;

  /// No description provided for @uniQuotaLyceum.
  ///
  /// In ru, this message translates to:
  /// **'Квота лицеев'**
  String get uniQuotaLyceum;

  /// No description provided for @uniQuotaOrphan.
  ///
  /// In ru, this message translates to:
  /// **'Квота сирот'**
  String get uniQuotaOrphan;

  /// No description provided for @uniQuotaDisability.
  ///
  /// In ru, this message translates to:
  /// **'Квота по инвалидности'**
  String get uniQuotaDisability;

  /// No description provided for @uniQuotaOralman.
  ///
  /// In ru, this message translates to:
  /// **'Квота кандасов'**
  String get uniQuotaOralman;

  /// No description provided for @uniQuotaOther.
  ///
  /// In ru, this message translates to:
  /// **'Иная квота'**
  String get uniQuotaOther;

  /// No description provided for @uniGrantMetricCutoff.
  ///
  /// In ru, this message translates to:
  /// **'Проходной балл на грант'**
  String get uniGrantMetricCutoff;

  /// No description provided for @uniGrantMetricCompetitionMin.
  ///
  /// In ru, this message translates to:
  /// **'Минимум для участия в конкурсе на грант'**
  String get uniGrantMetricCompetitionMin;

  /// No description provided for @uniGrantMetricPaidMin.
  ///
  /// In ru, this message translates to:
  /// **'Минимум на платное'**
  String get uniGrantMetricPaidMin;

  /// No description provided for @uniGrantMetricNationalFloor.
  ///
  /// In ru, this message translates to:
  /// **'Пороговый минимум (приказ МНВО)'**
  String get uniGrantMetricNationalFloor;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['en', 'kk', 'ru'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'kk':
      return AppLocalizationsKk();
    case 'ru':
      return AppLocalizationsRu();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
