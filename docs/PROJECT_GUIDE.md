# Admity — полное руководство по проекту

> **Admity** — агентный ИИ-наставник по поступлению для школьников из регионов Казахстана (14–18 лет).
> Честный «чансинг» (реальные пороги ЕНТ + логика Common Data Set), подбор стипендий и ИИ-ментор
> **Ералы (Eraly)**, который направляет, но никогда не пишет работу за ученика.
> Flutter + Riverpod + go_router + Supabase. Мультиязычный (KZ / RU / EN), privacy-first для несовершеннолетних.

Этот документ — единая точка входа для нового разработчика: что это за продукт, как устроен код, как
запустить приложение и **как подключить базу данных с нуля**. Все факты сверены с исходниками в репозитории.

---

## Содержание

1. [Обзор продукта](#1-обзор-продукта)
2. [Архитектура](#2-архитектура)
3. [Навигация и состояние](#3-навигация-и-состояние)
4. [Данные и оффлайн](#4-данные-и-оффлайн)
5. [Бэкенд: Supabase](#5-бэкенд-supabase)
6. [Как подключить базу данных (пошагово)](#6-как-подключить-базу-данных-пошагово)
7. [Запуск проекта](#7-запуск-проекта)
8. [Локализация](#8-локализация)
9. [Тестирование](#9-тестирование)
10. [Дизайн-система и бренд](#10-дизайн-система-и-бренд)
11. [Известные ограничения / гейчи](#11-известные-ограничения--гейчи)
12. [Структура каталогов](#12-структура-каталогов)

---

## 1. Обзор продукта

**Admity** (`pubspec.yaml`: `name: admity`, `version: 1.0.0+1`) — это «agentic admissions mentor for students
from the regions of Kazakhstan». Цель — дать подростку из любого аула или райцентра тот же уровень навигации
по поступлению, что есть у детей из дорогих частных школ больших городов.

**Аудитория:** школьники 14–18 лет, часто на бюджетных Android-телефонах, со слабым-средним английским и
ограниченным интернетом. Поэтому приложение:

- **мобильное-в-первую-очередь** (Android + iOS), но полностью работает и в вебе для разработки;
- **мультиязычное** — казахский / русский / английский (`lib/l10n/app_kk.arb`, `app_ru.arb`, `app_en.arb`);
- **offline-light** — работает целиком без бэкенда благодаря встроенным seed-данным и локальному JSON-хранилищу;
- **privacy-first для несовершеннолетних** — данные ученика защищены Row-Level Security в Supabase
  (см. раздел 5), а ключ LLM никогда не попадает в клиент.

### Три столпа продукта

1. **Честный чансинг (`честный chancing`).** Никаких выдуманных процентов. Для Казахстана —
   пороги гранта и реальные проходные баллы прошлых лет с пометкой «проверь у первоисточника»
   (`lib/features/chancing_kz/`). Для мира — диапазоны 25–75 перцентиля и категория reach / target / likely
   по логике Common Data Set (`lib/features/chancing_world/`). Категории честны по определению:
   `KzChance` (`belowThreshold` / `atRisk` / `safe`) и `WorldChance` (`reach` / `target` / `likely`),
   см. `lib/shared/models/chance_category.dart`.

2. **Стипендии.** Честный матчинг с понятным объяснением, *почему* программа подходит или не подходит
   (`lib/features/scholarships/`). Жёсткие блокеры (возраст, гражданство, опыт работы, уровень обучения)
   никогда не прячутся за «мягким» совпадением. Каталог включает Государственный грант РК, Болашак,
   Chevening, Stipendium Hungaricum, Global Korea Scholarship и др.

3. **Ментор Ералы (Eraly).** ИИ-наставник, который координирует суб-агентов (Профориентатор, Чансинг-КЗ,
   Чансинг-Мир, Скаут-стипендий, Тренер-интенсивов, Редактор эссе — см. `SubAgent` в
   `lib/features/eraly_chat/domain/chat_models.dart`). Работает на сервере через Supabase Edge Function
   (`supabase/functions/eraly/index.ts`).

### Принцип «Ералы не пишет за тебя»

Главный продуктовый принцип, зашитый и на сервере, и на клиенте:

> «НАПРАВЛЯЮ, НЕ ДЕЛАЮ ЗА УЧЕНИКА» — Ералы помогает и корректирует, но **никогда** не выполняет работу
> за ученика и не выдаёт готовый текст эссе под копирование.

- На **сервере** этот принцип задан в системном промпте Edge Function (`ERALY_SYSTEM_PROMPT`).
- На **клиенте** он продублирован и работает даже офлайн: `EralyClient._isGhostwritingRequest()`
  в `lib/core/ai/eraly_client.dart` распознаёт просьбы «напиши эссе за меня» на KZ / RU / EN
  (включая казахский корень `жаз`, фразы «за меня / орныма / for me», глаголы `напиши / write / generate`)
  и вместо ответа возвращает мягкий отказ `_ghostwritingRefusal()` с тремя наводящими вопросами.
  Это поведение покрыто тестами (`test/domain/eraly_client_test.dart`).

---

## 2. Архитектура

### Feature-first, многослойная

Приложение построено по принципу **feature-first**: каждая фича — отдельная папка в `lib/features/`,
внутри неё три слоя `data/` · `domain/` · `presentation/`. Кросс-фичевый код вынесен в `lib/core/`
(инфраструктура) и `lib/shared/` (общие виджеты и модели).

```
lib/
  main.dart                 # entry point → bootstrap()
  bootstrap.dart            # биндинги + LocalStore + initSupabase() + runApp(ProviderScope)
  app.dart                  # MaterialApp.router (тема, l10n, роутинг) — чистая функция состояния
  core/                     # инфраструктура (без бизнес-логики фич)
  features/                 # одна папка на фичу, каждая с data/domain/presentation
  l10n/                     # *.arb источники + сгенерированный AppLocalizations
  shared/                   # widgets/ + models/ — кросс-фичевый код
```

### Поток запуска

`main.dart` → `bootstrap()`:

1. `WidgetsFlutterBinding.ensureInitialized()`;
2. ловит глобальные ошибки через `FlutterError.onError` → `AppLogger`;
3. `final store = await LocalStore.load();` — загружает (или создаёт) JSON-хранилище;
4. `await initSupabase();` — инициализирует Supabase, **если** заданы креды (иначе no-op, см. раздел 5/6);
5. `runApp(ProviderScope(overrides: [localStoreProvider.overrideWithValue(store)], child: AdmityApp()))`.

`AdmityApp` (`lib/app.dart`) — `ConsumerWidget`, который читает `appRouterProvider` и
`localeControllerProvider` и рендерит `MaterialApp.router` с темами `AppTheme.light` / `AppTheme.dark`
(`themeMode` по умолчанию `ThemeMode.system`).

### Каталог `core/`

| Папка / файл | Назначение |
|---|---|
| `core/ai/eraly_client.dart` | Клиент Ералы. Вызывает Edge Function `eraly` через `Supabase.instance.client.functions.invoke('eraly', …)`; офлайн-фолбэк и локальная защита от ghost-writing. `eralyClientProvider`. |
| `core/env/app_env.dart` | `AppEnv` — compile-time конфиг: `supabaseUrl`, `supabaseAnonKey` (через `String.fromEnvironment`), геттер `hasSupabase`. |
| `core/l10n/locale_controller.dart` | `LocaleController` (`Notifier<Locale?>`, `null` = язык устройства), `localeControllerProvider`. |
| `core/router/app_router.dart` | `appRouterProvider` — `GoRouter` со `StatefulShellRoute.indexedStack` (5 вкладок) + полноэкранные detail-маршруты. |
| `core/router/app_routes.dart` | `AppRoutes` — централизованные пути и имена всех маршрутов. |
| `core/router/scaffold_with_nav_bar.dart` | `ScaffoldWithNavBar` — оболочка с нижним `NavigationBar` (5 вкладок). |
| `core/storage/local_store.dart` | `LocalStore` — JSON-файл `admity_store.json` для оффлайн-персистентности; `localStoreProvider`. |
| `core/supabase/supabase_bootstrap.dart` | `initSupabase()` — инициализация Supabase или graceful no-op. |
| `core/supabase/supabase_providers.dart` | `supabaseClientProvider`, `authStateChangesProvider` (`StreamProvider<AuthState>`). |
| `core/theme/` | Дизайн-токены и темы: `app_colors.dart`, `app_theme.dart`, `app_theme_extension.dart` (`AppTokens`), `app_spacing.dart`, `app_radii.dart`, `app_typography.dart`, `app_durations.dart`. |
| `core/utils/app_logger.dart` | `AppLogger` — логирование без `print`. |
| `core/error/` | Зарезервировано под failures / result-типы (`.gitkeep`, пока пусто). |

### Каталог `features/` — все фичи

Каждая фича перечислена с её назначением. Многие `data/`, `domain/`, `presentation/` содержат `.gitkeep`
там, где слой пока пуст или не нужен.

| Фича | Назначение | Ключевые файлы |
|---|---|---|
| `onboarding/` | Приветствие + 5-шаговый онбординг, заполняющий профиль. | `presentation/onboarding_screen.dart` |
| `auth/` | Вход (magic-link) + гостевой режим, минор-ориентированное согласие. | `presentation/auth_screen.dart` |
| `dashboard/` | Главный экран (вкладка «Главная»). | `presentation/dashboard_screen.dart` |
| `career_test/` | Профориентация RIASEC + Big Five → кластеры специальностей. | `domain/career_scoring.dart`, `career_items.dart`, `career_models.dart`; `presentation/career_providers.dart`, `career_test_screen.dart` |
| `chancing_kz/` | Чансинг по ЕНТ: пороги + реальные проходные баллы. | `domain/ent_chancing.dart`, `ent_models.dart`; `data/ent_cutoffs_seed.dart`; `presentation/ent_providers.dart`, `chances_hub_screen.dart`, `chancing_kz_screen.dart` |
| `chancing_world/` | Чансинг по миру: логика Common Data Set (диапазоны, факторы). | `domain/cds_chancing.dart`, `cds_models.dart`; `data/cds_seed.dart`; `presentation/cds_providers.dart`, `chancing_world_screen.dart` |
| `universities/` | Каталог вузов (КЗ + мир), деталь вуза, личный «college list». | `domain/university.dart`; `data/universities_seed.dart`; `presentation/universities_providers.dart`, `universities_screen.dart`, `university_detail_screen.dart`, `college_list_screen.dart` |
| `scholarships/` | Подбор стипендий с честной фильтрацией eligibility. | `domain/scholarship_matcher.dart`, `scholarship_models.dart`; `data/scholarships_seed.dart`; `presentation/scholarships_providers.dart`, `scholarships_screen.dart` |
| `gap_closer/` | Задачи «закрыть пробелы» с дедлайнами, генерируемые из профиля. | `domain/gap_generator.dart`, `gap_task.dart`; `presentation/gap_providers.dart`, `gap_screen.dart` |
| `project_ideas/` | Реалистичные проекты с нулевым бюджетом, тегированные по RIASEC. | `domain/project_suggester.dart`, `project_idea.dart`; `data/project_ideas_seed.dart`; `presentation/project_ideas_screen.dart` |
| `intensives/` | Интенсивы: флагман «Эссе за 14 дней» + треки, XP / стрики / заморозки. | `domain/intensive_engine.dart`, `intensive_models.dart`; `data/intensives_seed.dart`; `presentation/intensives_providers.dart`, `intensive_screen.dart`, `intensive_day_screen.dart`, `learn_hub_screen.dart` |
| `essay_review/` | Локальная проверка эссе по рубрике (онлайн-разбор — у Ералы). | `domain/rubric_scorer.dart`, `essay_models.dart`; `presentation/essay_screen.dart` |
| `eraly_chat/` | Чат с Ералы (вкладка «Ералы»). | `domain/chat_models.dart`; `presentation/chat_providers.dart`, `eraly_chat_screen.dart` |
| `profile/` | Профиль ученика + приватные «интересные факты обо мне». | `presentation/profile_providers.dart`, `profile_screen.dart` |
| `design_showcase/` | Витрина дизайн-системы (`/design`), не в основной навигации. | `presentation/design_showcase_screen.dart` |

### Каталог `shared/`

- **`shared/models/`**
  - `profile.dart` — `Profile` (модель ученика) + enum `TargetGeo` (`kz`/`eu`/`us`/`asia`);
  - `chance_category.dart` — enum'ы `KzChance`, `WorldChance`, `BandPosition`.
- **`shared/widgets/`** — кросс-фичевые виджеты:
  `bento_card.dart` (`BentoCard`), `eraly_avatar.dart` (маскот), `chance_pill.dart`, `progress_ring.dart`,
  `score_bar_chart.dart` (единственный потребитель `fl_chart`), `gamification_badges.dart`,
  `nav_card.dart`, `primary_button.dart`, `section_header.dart`, `selectable_chip.dart`,
  `source_note.dart`, `async_value_view.dart`.

### Дизайн-система (кратко; подробно — раздел 10)

- **`AppColors`** (`core/theme/app_colors.dart`) — сырые брендовые токены: тёплая земляная палитра
  казахской степи (terracotta `#C8633B`, teal `#1E6E62`, amber `#E8A93C`, sand/cream/graphite), без
  «дженерик-AI-градиента».
- **`AppTokens`** (`core/theme/app_theme_extension.dart`) — `ThemeExtension`, который добавляет к
  Material `ColorScheme` брендовые семантические токены: `xp`, `streak`, `success`, `warning`, `danger`,
  `info`, `surfaceRaised`, `surfaceSunken`, `textMuted`, `chanceReach`/`chanceTarget`/`chanceLikely`,
  `cardShadow`. Доступ через `context.tokens` (extension `AppTokensX` там же; также `context.colors`,
  `context.text`).
- **`AppSpacing`** (4-pt сетка: `xxs…xxxl`, `screen = 20`), **`AppRadii`** (`sm…xl`, `pill`, готовые
  `BorderRadius`), **`AppTypography`** (редакционная шкала; шрифтовые семейства пока `null`, т.к. `.ttf`
  ещё не подключены), **`AppDurations`** (`fast`/`medium`/`slow`/`celebrate`).
- **`BentoCard`** (`shared/widgets/bento_card.dart`) — основная поверхность: мягкая скруглённая карточка с
  брендовой тенью, опциональным акцентом-полосой и лёгким haptic при нажатии.
- **Маскот Ералы** (`shared/widgets/eraly_avatar.dart`) — `EralyAvatar`, **кастомно отрисованный**
  (`CustomPainter`, степная птица-фезер в terracotta), а не emoji/иконка. Имеет 4 состояния
  (`EralyState.idle/celebrate/encourage/thinking`) с анимациями `flutter_animate`. Публичный API намеренно
  совпадает с будущим Rive-виджетом, чтобы код фич не менялся, когда подключат `.riv`.

---

## 3. Навигация и состояние

### go_router

Маршрутизация описана декларативно в `lib/core/router/app_router.dart`. `appRouterProvider` —
`Provider<GoRouter>`. Стартовая локация выбирается по профилю:

```dart
initialLocation: onboarded ? AppRoutes.dashboard : AppRoutes.onboarding
```

(`onboarded` читается из `profileProvider`.)

#### Оболочка из 5 вкладок (`StatefulShellRoute.indexedStack`)

Корневой `StatefulShellRoute.indexedStack` рендерит `ScaffoldWithNavBar` и сохраняет состояние каждой
вкладки (стек на ветку). Пять вкладок (`scaffold_with_nav_bar.dart`):

| # | Вкладка (RU) | Маршрут | Имя | Экран |
|---|---|---|---|---|
| 0 | **Главная** | `/` | `dashboard` | `DashboardScreen` |
| 1 | **Шансы** | `/chances` | `chances` | `ChancesHubScreen` |
| 2 | **Учёба** | `/learn` | `learn` | `LearnHubScreen` |
| 3 | **Ералы** | `/eraly` | `eraly` | `EralyChatScreen` |
| 4 | **Профиль** | `/profile` | `profile` | `ProfileScreen` |

#### Полноэкранные detail-маршруты

Поверх оболочки (через `parentNavigatorKey: _rootKey`) открываются полноэкранные маршруты — все имена и пути
заданы в `AppRoutes` (`app_routes.dart`):

`onboarding`, `auth`, `careerTest` (`/career-test`), `chancingKz` (`/chancing-kz`),
`chancingWorld` (`/chancing-world`), `universities`, `universityDetail` (`/university/:slug`),
`scholarships`, `collegeList` (`/college-list`), `gap` (`/gap`), `projects` (`/projects`),
`essay` (`/essay`), `design` (`/design`), `intensive` (`/intensive/:slug`),
`intensiveDay` (`/intensive/:slug/day/:day`). (`notes` объявлен в `AppRoutes`, но как полноэкранный
маршрут пока не зарегистрирован.)

### Riverpod — паттерны провайдеров

Состояние — единственный источник истины через **flutter_riverpod 3.x**. UI — чистая функция состояния
провайдеров: никаких `setState` для бизнес-логики, никаких глобальных синглтонов. `ProviderScope`
поднимается один раз в `bootstrap.dart`.

Используются **обычные, идиоматичные провайдеры без кодогенерации**:

- `Provider` / `Provider.family` — для неизменяемых seed-данных и производных значений;
- `NotifierProvider` (`Notifier<T>`) — для изменяемого состояния, которое персистится в `LocalStore`;
- `StreamProvider` — для потока auth-состояния (`authStateChangesProvider`).

#### Почему нет кодогенерации (`@riverpod` / drift)

Спецификация просила `riverpod_generator`, но на этой машине (Flutter **3.41.6** / Dart **3.11.4**)
тулчейн кодогенерации **неразрешим**: `riverpod_generator` требует `analyzer ^12` (которому нужен
`meta ^1.18`), а Flutter SDK пинит `meta 1.17.0`. `drift_dev` конфликтует так же. Поэтому каркас
использует обычные провайдеры Riverpod 3.x — функционально идентично и обратимо: миграция горстки
провайдеров на `@riverpod` механическая, как только пины `analyzer`/`meta` сойдутся. Runtime-зависимости
`drift` и `sqlite3_flutter_libs` объявлены в `pubspec.yaml`, но их кодогенерация (`drift_dev`) отложена —
оффлайн-кэш сейчас реализован через `LocalStore` (JSON). См. также раздел 11.

#### Ключевые провайдеры по фичам

| Фича / файл | Провайдеры |
|---|---|
| `core` | `appRouterProvider`, `localeControllerProvider`, `localStoreProvider`, `supabaseClientProvider`, `authStateChangesProvider`, `eralyClientProvider` |
| `profile/presentation/profile_providers.dart` | `profileProvider` (`NotifierProvider<ProfileController, Profile>`, ключ `'profile'`), `notesProvider` (`NotifierProvider<NotesController, List<String>>`, ключ `'personal_notes'`) |
| `chancing_kz/presentation/ent_providers.dart` | `entScoreProvider` (`NotifierProvider<EntScoreController, EntScore?>`, ключ `'ent_score'`), `entCutoffsProvider` (`Provider<List<EntCutoff>>` → seed) |
| `chancing_world/presentation/cds_providers.dart` | `cdsProvider` (→ seed), `cdsByKeyProvider` (`Provider.family`), `satScoreProvider` (`NotifierProvider<SatScoreController, int?>`, хранится в `'test_scores'`) |
| `scholarships/presentation/scholarships_providers.dart` | `scholarshipsProvider` (→ seed), `eligibilityContextProvider` (из профиля; возраст ≈ `6 + grade`), `scholarshipMatchesProvider` (matcher) |
| `career_test/presentation/career_providers.dart` | `careerProvider` (`NotifierProvider<CareerController, CareerResult?>`, ключ `'career_answers'` — хранит сырые ответы и пересчитывает детерминированно) |
| `universities/presentation/universities_providers.dart` | `universitiesProvider` (→ seed), `uniSearchProvider` (`Notifier<String>`), `filteredUniversitiesProvider`, `collegeListProvider` (`Notifier<Set<String>>`, ключ `'college_list'`) |
| `gap_closer/presentation/gap_providers.dart` | `gapTasksProvider` (`Notifier<List<GapTask>>`, ключ `'gap_tasks'`, метод `regenerate()`) |
| `intensives/presentation/intensives_providers.dart` | `intensivesProvider` (→ seed), `intensiveBySlugProvider` (`family`), `intensiveProgressProvider` (`Notifier<Map<String, IntensiveProgress>>`, ключ `'intensive_progress'`) |
| `eraly_chat/presentation/chat_providers.dart` | `chatProvider` (`NotifierProvider<ChatController, List<ChatMessage>>`, in-memory; собирает контекст профиля для Ералы) |

---

## 4. Данные и оффлайн

### LocalStore — JSON-хранилище

`lib/core/storage/local_store.dart` — крошечный key/value-стор поверх одного JSON-файла. Это и есть
«offline-light persistence» данных самого ученика (профиль, заметки, баллы, прогресс).

- Файл: `admity_store.json` в `getApplicationDocumentsDirectory()`.
- Чтения **синхронные** (из памяти): `readJson(key)`, `readList(key)`.
- Записи: `put(key, value)`, `remove(key)` — дебаунс-сброс на диск (`_persist()`, fire-and-forget).
- **Никогда не бросает исключений**: `LocalStore.load()` при ошибке откатывается к
  `LocalStore.inMemory()` (полезно в тестах и без файловой системы).
- Провайдер `localStoreProvider` по умолчанию возвращает in-memory-вариант, но в `bootstrap.dart`
  переопределяется реальным инстансом:
  `ProviderScope(overrides: [localStoreProvider.overrideWithValue(store)], …)`.

> Когда Supabase подключён, репозитории должны писать сквозь в Postgres как источник истины, а `LocalStore`
> остаётся оффлайн-кэшем. (Сейчас фичи работают через `LocalStore`; сквозная запись в Supabase —
> следующий шаг.)

#### Ключи в LocalStore

| Ключ | Что хранит | Где задаётся |
|---|---|---|
| `profile` | сериализованный `Profile` | `ProfileController` |
| `personal_notes` | `List<String>` — «интересные факты обо мне» | `NotesController` |
| `ent_score` | сериализованный `EntScore` | `EntScoreController` |
| `test_scores` | `{ sat_score: int? }` | `SatScoreController` |
| `career_answers` | `{ riasec: [...], big_five: [...] }` (сырые ответы) | `CareerController` |
| `college_list` | `List<String>` (slug'и вузов) | `CollegeListController` |
| `gap_tasks` | `List<GapTask>` (JSON) | `GapTasksController` |
| `intensive_progress` | `Map<slug, IntensiveProgress>` (JSON) | `IntensiveProgressController` |

### (Де)сериализация профиля

Модель `Profile` (`lib/shared/models/profile.dart`) — иммутабельная, с `fromJson` / `toJson` / `copyWith`.
Поля и их JSON-ключи (совпадают с колонками таблицы `profiles` в Supabase, см. раздел 5):

| Поле Dart | JSON-ключ | Тип |
|---|---|---|
| `userId` | `user_id` | `String?` |
| `fullName` | `full_name` | `String?` |
| `region` | `region` | `String?` |
| `grade` | `grade` | `int?` |
| `locale` | `locale` | `String?` |
| `gpa` | `gpa` | `double?` |
| `targetGeos` | `target_geo` | `Set<TargetGeo>` ↔ `List<String>` (по `.name`) |
| `interests` | `interests` | `Set<String>` ↔ `List<String>` |
| `onboarded` | `onboarded` | `bool` (default `false`) |

`ProfileController` (`profile_providers.dart`) в `build()` читает ключ `profile` из `LocalStore` и
строит `Profile.fromJson` (или пустой `Profile()`); `save(profile)` обновляет состояние и пишет
`profile.toJson()` в стор. `NotesController` хранит приватные заметки под ключом `personal_notes` —
они используются Ералы для поиска тем эссе и идей проектов.

### Seed-данные (встроены как Dart-константы)

Справочные данные зашиты прямо в код как `const`-списки, поэтому приложение работает целиком офлайн
(гостевой режим). Каждый seed дублирует то, что лежит в `supabase/seed.sql`.

| Seed-файл | Константа | Содержимое |
|---|---|---|
| `features/chancing_kz/data/ent_cutoffs_seed.dart` | `kEntCutoffsSeed` | Реальные проходные ЕНТ 2024 (КазНМУ им. Асфендиярова: Общая медицина 124, Стоматология 136, Педиатрия 111; Мед. университет Астаны; КБТУ IT 110; КазНПУ им. Абая). Источники: KazNMU, testcenter.kz, el.kz, nur.kz. |
| `features/chancing_world/data/cds_seed.dart` | `kCdsSeed` | CDS-снимки (Harvard, MIT, University of Michigan, Arizona State): acceptance rate, SAT/ACT 25–75, факторы C7 (`veryImportant`/`important`/`considered`/`notConsidered`). Источник: commondataset.org. |
| `features/universities/data/universities_seed.dart` | `kUniversitiesSeed` | Каталог вузов КЗ + мир (NU, КБТУ, SDU, Harvard, MIT, ASU и др.): язык, программы, рейтинг, стоимость, заметки по фин-помощи. |
| `features/scholarships/data/scholarships_seed.dart` | `kScholarshipsSeed` | Стипендии: Государственный грант РК, Болашак, Chevening, Stipendium Hungaricum, Global Korea Scholarship и др. — с уровнями, покрытием, дедлайнами, ограничениями. |
| `features/intensives/data/intensives_seed.dart` | `kEssayIntensive`, `kIntensivesSeed` | Интенсив «Эссе за 14 дней» (`essay-14`), расписанный по дням с целями, шагами, XP и rubric-проверками. |
| `features/project_ideas/data/project_ideas_seed.dart` | `kProjectIdeasSeed` | Реалистичные проекты с нулевым бюджетом, тегированные RIASEC-кодами. |
| `features/career_test/domain/career_items.dart` | `kRiasecItems`, `kBigFiveItems` | Банки пунктов RIASEC (формат активности) и Big Five (формат согласия). |

> Все справочные числа помечены годом. В UI они показываются с оговоркой «проверь у первоисточника» —
> проходные баллы, дедлайны и суммы меняются ежегодно.

### Гостевой режим (offline-light)

Приложение полностью функционально без входа и без бэкенда:

- стартует в онбординг, заполняет профиль локально;
- на экране входа (`auth_screen.dart`) есть кнопка **«Продолжить как гость»** → `context.go(AppRoutes.onboarding)`;
- весь чансинг, стипендии, интенсивы, эссе-рубрика работают на seed-данных и `LocalStore`;
- чат Ералы без бэкенда отдаёт «принципиальный офлайн-фолбэк» (`EralyClient._offlineFallback`), и при этом
  локальная защита от ghost-writing всё равно срабатывает.

---

## 5. Бэкенд: Supabase

Весь бэкенд лежит в `supabase/`. Приложение **полностью работает без него** (см. разделы 4 и 6) —
Supabase нужен для реальной авторизации, кросс-устройственной синхронизации и живого чата Ералы.

```
supabase/
  README.md                 # инструкция по настройке бэкенда
  migrations/0001_init.sql  # схема + RLS
  seed.sql                  # справочные данные (зеркало Dart seed)
  functions/eraly/index.ts  # Edge Function «Ералы» (Deno)
```

### Схема (`supabase/migrations/0001_init.sql`)

Таблицы делятся на **данные ученика** (заблокированы на владельца через RLS) и **справочные данные**
(только чтение для авторизованных).

#### Таблицы данных ученика (RLS: `auth.uid() = user_id`)

| Таблица | Ключевые колонки |
|---|---|
| `profiles` | `user_id uuid PK → auth.users(id)`, `full_name`, `region`, `grade int`, `locale`, `gpa numeric`, `target_geo text[]`, `interests text[]`, `onboarded bool`, `created_at` |
| `personal_notes` | `id uuid PK`, `user_id`, `content text`, `created_at` |
| `career_results` | `id`, `user_id`, `riasec_code`, `riasec_scores jsonb`, `big_five jsonb`, `recommended_clusters jsonb`, `taken_at` |
| `ent_scores` | `id`, `user_id`, `history`, `math_literacy`, `reading_literacy`, `profile1_subject/score`, `profile2_subject/score`, `total`, `is_predicted bool`, `updated_at` |
| `college_list` | `id`, `user_id`, `university_slug`, `category`, `status`, `notes`, `unique(user_id, university_slug)` |
| `gap_tasks` | `id`, `user_id`, `title`, `description`, `due_date date`, `linked_intensive_slug`, `is_done bool` |
| `intensive_progress` | `id`, `user_id`, `intensive_slug`, `current_day`, `xp`, `streak_count`, `streak_freezes` (default 2), `last_active`, `completed_days jsonb`, `unique(user_id, intensive_slug)` |
| `essays` | `id`, `user_id`, `kind text`, `draft_text`, `rubric_feedback jsonb`, `updated_at` |
| `chat_threads` | `id`, `user_id`, `title`, `created_at` |
| `chat_messages` | `id`, `thread_id → chat_threads`, `user_id`, `role text check (role in ('user','eraly'))`, `content`, `created_at` |

#### Справочные таблицы (RLS: чтение для `authenticated`)

| Таблица | Ключевые колонки |
|---|---|
| `universities` | `slug PK`, `name`, `country`, `scope check (scope in ('kz','world'))`, `ranking`, `tuition`, `languages text[]`, `programs text[]`, `fin_aid_notes`, `is_need_blind_full_need bool`, `cds_university_key` |
| `scholarships` | `slug PK`, `name`, `country`, `levels text[]`, `covers text[]`, `deadline`, `eligibility`, `source_url`, `year`, `requires_work_years`, `age_max`, `requires_kz_citizen bool`, `note` |
| `ent_cutoffs` | `id`, `university`, `specialty`, `year`, `gov_threshold int`, `real_cutoff int` |
| `cds_snapshots` | `university`+`year` PK, `acceptance_rate numeric`, `sat_25/75`, `act_25/75`, `gpa_avg`, `factors jsonb` |
| `intensives` | `slug PK`, `title`, `description`, `days jsonb` |

### Row-Level Security (RLS)

RLS включён для **всех** таблиц через два `do $$ … $$` блока в конце миграции:

- **Таблицы ученика** (`profiles`, `personal_notes`, `career_results`, `ent_scores`, `college_list`,
  `gap_tasks`, `intensive_progress`, `essays`, `chat_threads`, `chat_messages`) получают по две политики:
  - `<t>_owner_select` — `for select using (auth.uid() = user_id)`;
  - `<t>_owner_modify` — `for all using (auth.uid() = user_id) with check (auth.uid() = user_id)`.

  То есть строка видна и изменяема **только** её владельцу — это критично для приватности несовершеннолетних.

- **Справочные таблицы** (`universities`, `scholarships`, `ent_cutoffs`, `cds_snapshots`, `intensives`)
  получают политику `<t>_read` — `for select to authenticated using (true)`. Запись в них — только через
  service role (миграция/seed на стороне сервера).

### Seed (`supabase/seed.sql`)

Зеркалит встроенные Dart seed-данные: `ent_cutoffs`, `cds_snapshots`, `universities`, `scholarships`.
Все `insert … on conflict do nothing`. Числа помечены годом и должны перепроверяться у первоисточника
каждый сезон.

### Edge Function «Ералы» (`supabase/functions/eraly/index.ts`)

Серверная функция на Deno (`Deno.serve`). **Ключ LLM живёт только здесь** — в клиент он никогда не попадает.

- **Запрос:** `POST` с телом `{ message: string, history: {role,content}[], profile: object }`;
  **ответ:** `{ reply: string }`. Поддержан CORS-preflight (`OPTIONS`).
- **Модель:** по умолчанию `claude-sonnet-4-6` (константа `DEFAULT_MODEL`); можно переопределить через
  секрет `ERALY_MODEL` (например, `claude-opus-4-8` для максимального качества). Это валидные актуальные
  идентификаторы моделей Anthropic.
- **Системный промпт** `ERALY_SYSTEM_PROMPT` задаёт идентичность Ералы, главный принцип «направляю, не
  делаю за ученика», правила честности данных (диапазоны/категории, пометки годом и «проверь у
  первоисточника»), опорные факты по ЕНТ/CDS/стипендиям и правила тона/безопасности для несовершеннолетних.
- Структурированный контекст ученика добавляется к системному промпту как `КОНТЕКСТ УЧЕНИКА (JSON)`.
- Вызывает Anthropic Messages API:
  - URL `https://api.anthropic.com/v1/messages`;
  - заголовки `x-api-key: <ANTHROPIC_API_KEY>`, `anthropic-version: 2023-06-01`, `content-type: application/json`;
  - тело `{ model, max_tokens: 1024, system, messages }`.
- **Секреты функции** (server-side): `ANTHROPIC_API_KEY` (обязательно), `ERALY_MODEL` (опционально).
  Если `ANTHROPIC_API_KEY` не задан — функция вернёт `500`.

Клиент (`lib/core/ai/eraly_client.dart`) вызывает её через `supabase.functions.invoke('eraly', body: …)`.
Если Supabase не настроен или вызов упал — клиент показывает офлайн-ответ, а защита от ghost-writing
действует всегда.

---

## 6. Как подключить базу данных (пошагово)

Это самый практический раздел. Приложение работает без Supabase, но чтобы включить реальную авторизацию,
синхронизацию и живой чат Ералы — пройдите шаги ниже. (Краткая версия также есть в `README.md` и
`supabase/README.md`.)

### Шаг 0. Как приложение читает креды

Креды задаются **на этапе сборки** через `String.fromEnvironment` — никаких секретов в коде нет:

```dart
// lib/core/env/app_env.dart
abstract final class AppEnv {
  static const String supabaseUrl = String.fromEnvironment('SUPABASE_URL');
  static const String supabaseAnonKey = String.fromEnvironment('SUPABASE_ANON_KEY');
  static bool get hasSupabase => supabaseUrl.isNotEmpty && supabaseAnonKey.isNotEmpty;
}
```

Значит, их нужно передавать флагами `--dart-define` или `--dart-define-from-file` при `flutter run` /
`flutter build`. Если они не заданы — `hasSupabase == false`, и `initSupabase()` просто логирует
предупреждение и не падает (offline-light).

### Шаг 1. Создать проект Supabase

1. Зайдите на <https://supabase.com> → **New project**.
2. Выберите регион поближе к Казахстану (например, EU / Frankfurt) и сохраните пароль БД.

### Шаг 2. Получить `SUPABASE_URL` и `SUPABASE_ANON_KEY`

В дашборде: **Project Settings → API**.

- **Project URL** → `SUPABASE_URL` (например, `https://abcd1234.supabase.co`);
- **Project API keys → `anon` `public`** → `SUPABASE_ANON_KEY` (это JWT вида `eyJhbGciOi...`).

> `anon`-ключ — **публичный** клиентский ключ, это by design. Данные защищены политиками Row-Level
> Security (см. раздел 5), поэтому сам ключ ничего не раскрывает. **Ключ LLM никогда не в клиенте** —
> Ералы работает на сервере в Edge Function.

### Шаг 3. Описать переменные и создать `env.json`

Создайте файл `env.json` в корне проекта (он **в `.gitignore`** — `env.json`, `*.env.json`, `.env` —
никогда не коммитьте его). Шаблон в `.env.example`. Формат для `--dart-define-from-file` — это JSON:

```json
{
  "SUPABASE_URL": "https://YOUR-REF.supabase.co",
  "SUPABASE_ANON_KEY": "eyJhbGciOi...your-anon-key..."
}
```

Где какой секрет живёт:

| Секрет | Куда кладётся | Коммитится? |
|---|---|---|
| `SUPABASE_URL` | `env.json` → `--dart-define-from-file` | ❌ нет |
| `SUPABASE_ANON_KEY` | `env.json` → `--dart-define-from-file` | ❌ нет |
| `ANTHROPIC_API_KEY` (ключ LLM) | секрет Edge Function (server-side) | ❌ никогда в приложении |
| `ERALY_MODEL` (опционально) | секрет Edge Function | ❌ |

### Шаг 4. Запустить приложение с кредами

**Вариант A — файл (рекомендуется):**

```bash
flutter run -d chrome --dart-define-from-file=env.json
# или удобный скрипт:
./tool/run_web.sh env.json
```

**Вариант B — отдельные define'ы:**

```bash
flutter run -d chrome \
  --dart-define=SUPABASE_URL=https://YOUR-REF.supabase.co \
  --dart-define=SUPABASE_ANON_KEY=eyJhbGciOi...your-anon-key...
```

На старте в логах вместо предупреждения «not configured» вы увидите `Supabase initialized.`
(`initSupabase()` в `lib/core/supabase/supabase_bootstrap.dart`). После этого на экране входа
активируется кнопка magic-link, а чат Ералы пойдёт в живую Edge Function вместо офлайн-фолбэка.

### Шаг 5. Применить схему + RLS (миграция)

Установите Supabase CLI и примените миграцию (`supabase/migrations/0001_init.sql`):

```bash
# macOS
brew install supabase/tap/supabase

supabase login
supabase link --project-ref YOUR-PROJECT-REF

supabase db push          # применяет migrations/0001_init.sql
```

Альтернатива без CLI: откройте дашборд → **SQL Editor** и вставьте содержимое
`migrations/0001_init.sql`, затем выполните.

После применения каждая таблица ученика (`profiles`, `personal_notes`, `ent_scores`, …) защищена RLS:
строка видна только при `auth.uid() = user_id`. Справочные таблицы доступны на чтение авторизованным.
Так данные несовершеннолетних защищены на уровне БД.

### Шаг 6. Залить справочные данные (seed)

```bash
psql "$DATABASE_URL" -f supabase/seed.sql      # или вставьте seed.sql в SQL Editor
```

(`DATABASE_URL` — строка подключения из дашборда; либо просто вставьте `seed.sql` в SQL Editor.)

### Шаг 7. Развернуть Edge Function «Ералы» и задать её секреты

Ключ LLM задаётся как **секрет функции** (server-side) и никогда не попадает в клиент:

```bash
# Секреты (только на сервере)
supabase secrets set ANTHROPIC_API_KEY=sk-ant-...
supabase secrets set ERALY_MODEL=claude-sonnet-4-6   # опционально; claude-opus-4-8 для макс. качества

# Деплой функции
supabase functions deploy eraly
```

После этого `supabase.functions.invoke('eraly')` из `EralyClient` будет дергать живую функцию.

### Шаг 8. Как `initSupabase()` ведёт себя без кредов (offline-light)

```dart
// lib/core/supabase/supabase_bootstrap.dart
Future<void> initSupabase() async {
  if (!AppEnv.hasSupabase) {
    _logger.warn('Supabase not configured ... Running offline-light without a backend.');
    return;                       // graceful no-op — приложение запускается без бэкенда
  }
  await Supabase.initialize(url: AppEnv.supabaseUrl, anonKey: AppEnv.supabaseAnonKey);
  _logger.info('Supabase initialized.');
}
```

Если попытаться прочитать `supabaseClientProvider` без настройки — он бросит понятный `StateError`, чтобы
ошибка проявилась громко на этапе разработки.

### Готовые шаблоны для копирования

**`env.json`** (для `--dart-define-from-file`):

```json
{
  "SUPABASE_URL": "https://YOUR-REF.supabase.co",
  "SUPABASE_ANON_KEY": "eyJhbGciOi...your-anon-key..."
}
```

**`--dart-define` (одной строкой):**

```bash
flutter run -d chrome \
  --dart-define=SUPABASE_URL=https://YOUR-REF.supabase.co \
  --dart-define=SUPABASE_ANON_KEY=eyJhbGciOi...your-anon-key...
```

---

## 7. Запуск проекта

### Предварительные требования

| Инструмент | Версия / статус |
|---|---|
| Flutter (stable) | **3.41.6** — установлен |
| Dart | **3.11.4** — установлен |
| Chrome (web-таргет) | присутствует |
| macOS desktop-таргет | присутствует |
| Xcode (сборки iOS) | нужен **только** для iOS |
| Android SDK / `adb` | пока не настроен (нужен только для Android) |

Весь продукт можно разрабатывать против **веб-таргета**. Для iOS поставьте Xcode; для Android —
Android Studio + Android SDK.

### Базовые команды

```bash
flutter pub get          # поставить зависимости
flutter gen-l10n         # сгенерировать переводы KZ/RU/EN (см. l10n.yaml)

# Веб (offline-light, без бэкенда) — самый быстрый способ посмотреть
flutter run -d chrome

# Веб с подключённым Supabase
flutter run -d chrome --dart-define-from-file=env.json
# или удобный скрипт-обёртка:
./tool/run_web.sh            # без бэкенда
./tool/run_web.sh env.json   # с Supabase
```

`tool/run_web.sh` — простой launcher: без аргумента запускает offline-light, с переданным файлом —
`flutter run -d chrome --dart-define-from-file=<файл>`.

### iOS (разовая настройка)

```bash
sudo xcode-select -s /Applications/Xcode.app/Contents/Developer   # указать на полный Xcode
sudo xcodebuild -runFirstLaunch
xcodebuild -downloadPlatform iOS                                  # runtime симулятора iOS

sudo gem install cocoapods         # или: brew install cocoapods

flutter doctor                     # должно показать iOS ✓
cd ios && pod install && cd ..     # только первый раз
open -a Simulator
flutter run                        # на запущенном симуляторе (или: flutter run -d <ios-sim>)
```

### Android (разовая настройка)

Установите Android Studio → SDK + эмулятор (AVD), затем `flutter run`.
`flutter doctor --android-licenses` — принять лицензии.

### Сборка

```bash
flutter build web                                   # offline-light
flutter build web --dart-define-from-file=env.json  # с бэкендом
# iOS/Android — после установки соответствующего тулчейна:
# flutter build ipa --dart-define-from-file=env.json
# flutter build apk --dart-define-from-file=env.json
```

---

## 8. Локализация

### Конфигурация (`l10n.yaml`)

```yaml
arb-dir: lib/l10n
template-arb-file: app_en.arb
output-localization-file: app_localizations.dart
output-class: AppLocalizations
output-dir: lib/l10n
nullable-getter: false   # AppLocalizations.of(context) — non-nullable, fail-fast
```

`pubspec.yaml` содержит `flutter: generate: true`, поэтому типизированный класс `AppLocalizations`
генерируется из `.arb`-файлов командой `flutter gen-l10n`.

### Источники переводов

- `lib/l10n/app_en.arb` — шаблон (английский, со всеми `@`-описаниями ключей);
- `lib/l10n/app_ru.arb` — русский;
- `lib/l10n/app_kk.arb` — казахский.

Сгенерированные файлы (`app_localizations.dart`, `app_localizations_en.dart`, `_ru.dart`, `_kk.dart`)
лежат рядом, но **в `.gitignore`** (`/lib/l10n/app_localizations*.dart`) — их нужно пересоздавать через
`flutter gen-l10n` после редактирования `.arb`.

### Подключение и переключение языка

В `lib/app.dart`:

```dart
locale: ref.watch(localeControllerProvider),
supportedLocales: AppLocalizations.supportedLocales,
localizationsDelegates: AppLocalizations.localizationsDelegates,
```

`LocaleController` (`lib/core/l10n/locale_controller.dart`) — `Notifier<Locale?>`: `null` означает
«следовать языку устройства», а пользователь может явно выбрать KZ / RU / EN через `setLocale(...)`.
Независимо от выбранного языка интерфейса, **Ералы отвечает на языке каждого сообщения ученика**.

> Примечание: многие строки в UI и навигации сейчас заданы прямо в коде на русском (например, подписи
> вкладок «Главная/Шансы/Учёба/Ералы/Профиль» в `scaffold_with_nav_bar.dart`), а `.arb`-словари пока
> покрывают часть строк (онбординг, навигация, общие действия, названия языков). Шаблон `app_en.arb`
> содержит ~15 ключей сообщений.

---

## 9. Тестирование

Тесты лежат в `test/`. Доменная логика (чансинг, скоринг, интенсивы, рубрика) — чистый детерминированный
Dart, поэтому покрывается обычными unit-тестами без мока сети.

```bash
flutter test
```

| Файл теста | Что покрывает |
|---|---|
| `test/domain/ent_chancing_test.dart` | Движок чансинга ЕНТ (`EntChancing`): пороги, реальные проходные, категории `belowThreshold`/`atRisk`/`safe`. |
| `test/domain/cds_chancing_test.dart` | Движок CDS (`CdsChancing`): тиры селективности, позиция в полосе 25–75, категории reach/target/likely; перцентиль не экстраполируется за пределы полосы. |
| `test/domain/scholarship_matcher_test.dart` | Матчер стипендий: Chevening отфильтрован для школьника (нужен опыт), Болашак неприемлем для бакалавриата и показывает оговорку, GKS подходит 17-летнему и исключает 25-летнего, eligible-программы сортируются выше и не показывают блокер-оговорку. |
| `test/domain/career_scoring_test.dart` | Скоринг RIASEC + Big Five (`CareerScoring`) и вывод кластеров. |
| `test/domain/intensive_engine_test.dart` | Движок интенсивов (`IntensiveEngine`): XP только за пройденную rubric-проверку, стрики, заморозка стрика, защита от «фарма» повторным завершением дня. |
| `test/domain/rubric_scorer_test.dart` | Локальная рубрика эссе (`LocalRubricScorer`): экономия слов, клише, конкретика, show-don't-tell, структура. |
| `test/domain/eraly_client_test.dart` | Локальная защита от ghost-writing (KZ/RU/EN): отказ на «жазып бер / напиши эссе за меня / write my personal statement / generate my essay», но «Как улучшить моё эссе?» — это не ghost-writing. |
| `test/widget_test.dart` | Приложение загружается в онбординг для нового (не онбордженного) пользователя (находит «Давай познакомимся» и «Далее»). |

> По README: `flutter analyze` чист при строгом `very_good_analysis` (`--fatal-infos`), доменные unit-тесты
> + app-boot widget-тест проходят, `flutter build web` собирается полностью.

---

## 10. Дизайн-система и бренд

### Палитра (`lib/core/theme/app_colors.dart`)

Тёплая земляная идентичность казахской степи, намеренно без «дженерик-AI» фиолетово-синего градиента.

| Токен | HEX | Роль |
|---|---|---|
| `terracotta` | `#C8633B` | основное действие |
| `terracottaDark` / `terracottaSoft` | `#A34E2C` / `#E89B7C` | акценты |
| `teal` / `tealSoft` | `#1E6E62` / `#5DA89B` | вторичный акцент (рост / путь) |
| `amber` / `amberSoft` | `#E8A93C` / `#F3CD86` | XP / стрик |
| `olive` | `#6E8B3D` | успех |
| `burntOrange` | `#D98A2B` | предупреждение / at-risk |
| `clay` | `#B4452F` | опасность / ниже порога |
| `sand` / `cream` / `sandAlt` | `#F6F1E7` / `#FFFBF3` / `#EDE6D6` | светлые поверхности |
| `inkLight` / `inkMutedLight` | `#231F1A` / `#6B6358` | текст на светлом |
| `graphite` / `graphiteRaised` / `graphiteAlt` | `#1C1A17` / `#262320` / `#322E29` | тёмные поверхности (тёплый графит) |
| `inkDark` / `inkMutedDark` | `#F4EEE3` / `#B3A99B` | текст на тёмном |

### Темы (`lib/core/theme/app_theme.dart`)

`AppTheme.light` / `AppTheme.dark` строятся из `ColorScheme.fromSeed(seedColor: terracotta, …)` с
явными `primary` (terracotta), `secondary` (teal), `tertiary` (amber), `error` (clay). Кастомизированы
`appBarTheme`, `cardTheme`, `filledButtonTheme` (высота 54), `chipTheme` (pill), `inputDecorationTheme`,
`navigationBarTheme` (высота 68), `dividerTheme`, `progressIndicatorTheme`. `InkSparkle.splashFactory`.

### Токены

- **`AppTokens`** (`app_theme_extension.dart`) — `ThemeExtension` с брендовыми семантическими цветами
  (XP/стрик/чансинг-категории/тени), две фабрики `AppTokens.light()` / `.dark()`, корректный `lerp`.
  Доступ: `Theme.of(context).extension<AppTokens>()!` или helper `context.tokens` (extension `AppTokensX`).
- **`AppSpacing`** — 4-pt сетка (`xxs=4 … xxxl=64`, `screen=20`).
- **`AppRadii`** — `sm=10 … xl=24`, `pill=999` + готовые `Radius`/`BorderRadius`.
- **`AppTypography`** — редакционная шкала (`displayLarge`…`labelSmall`); семейства `displayFamily`/
  `bodyFamily` пока `null` (платформенный шрифт), т.к. `.ttf` ещё не подключены — точки подключения
  зарезервированы в `pubspec.yaml` (закомментированный блок `fonts:` — Clash Display / Inter).
- **`AppDurations`** — `fast=150ms`, `medium=280ms`, `slow=450ms`, `celebrate=900ms`.

### `BentoCard` и Eraly mascot

- **`BentoCard`** (`shared/widgets/bento_card.dart`) — основная поверхность бенто-сеток: скруглённая
  карточка с брендовой тенью (`tokens.cardShadow`), опциональной акцент-полосой слева, лёгким
  `HapticFeedback.selectionClick()` при нажатии.
- **`EralyAvatar`** (`shared/widgets/eraly_avatar.dart`) — кастомно-отрисованный маскот (`CustomPainter`):
  тёплая фигура-щит/перо в terracotta, гребень степной птицы, лицо с выражением по состоянию.
  Состояния `EralyState.idle / celebrate / encourage / thinking` управляют мимикой и анимацией
  (`flutter_animate`). API совпадает с будущим Rive-виджетом (`assets/rive/eraly.riv` запланирован).

### Бренд-ассеты (`assets/brand/`)

Статические бренд-ассеты присутствуют в репозитории:

| Файл | Назначение |
|---|---|
| `assets/brand/admity_icon.png` | full-bleed иконка приложения (terracotta) |
| `assets/brand/admity_mark.png` | прозрачный знак (terracotta-плитка + птица) |
| `assets/brand/admity_splash.png` | прозрачный знак для нативного splash |

Сгенерированы скриптом `tool/gen_logo.py` (Python + Pillow), который повторяет геометрию маскота и палитру
из `lib/core/theme/app_colors.dart`, чтобы статические ассеты совпадали с рантайм-вектором.

> Внимание: в `pubspec.yaml` блок `flutter: assets:` пока закомментирован (объявление пустых папок ломает
> сборку). Чтобы бандлить `assets/brand/*` в приложение, нужно раскомментировать/добавить декларацию
> ассетов в `pubspec.yaml`.

---

## 11. Известные ограничения / гейчи

1. **Нет кодогенерации Riverpod / drift (намеренно).** На Flutter 3.41.6 / Dart 3.11.4 тулчейн кодогенерации
   неразрешим: `riverpod_generator` требует `analyzer ^12` (→ `meta ^1.18`), а Flutter SDK пинит
   `meta 1.17.0`; `drift_dev` конфликтует так же. Поэтому используются обычные провайдеры Riverpod 3.x,
   а `LocalStore` (JSON) заменяет drift-кэш. Миграция на `@riverpod` обратима, когда пины сойдутся.
   Зависимости `drift` и `sqlite3_flutter_libs` объявлены, но `drift_dev` отложен. См. раздел 3.

2. **Тулчейн iOS требует разовой настройки.** Нужен полный Xcode:
   `sudo xcode-select -s /Applications/Xcode.app/Contents/Developer`, затем `pod install` (CocoaPods).
   См. раздел 7.

3. **Android SDK пока не настроен.** Для запуска на Android нужны Android Studio + SDK + AVD
   (`flutter doctor --android-licenses`).

4. **Симулятор «idle-out».** iOS-симулятор может «засыпать» при простое — после долгой паузы перезапустите
   `flutter run` / разбудите симулятор.

5. **Безобидное предупреждение `native_assets ... required define SdkRoot`.** Может всплывать в сборках —
   это не ошибка проекта.

6. **15 пакетов запинены, но устаревшие.** Часть зависимостей в `pubspec.yaml` зафиксированы на текущих
   совместимых версиях и не обновляются до новейших (в т.ч. из-за пинов `analyzer`/`meta`, см. п.1) —
   это сделано осознанно ради стабильной сборки на данном SDK.

7. **Бренд-ассеты не забандлены.** `assets/brand/*` лежат в репозитории, но декларация `flutter: assets:`
   в `pubspec.yaml` закомментирована — раскомментируйте её, чтобы использовать ассеты в рантайме (раздел 10).

8. **`anonKey` помечен deprecated в supabase_flutter.** В `supabase_bootstrap.dart` стоит
   `// ignore: deprecated_member_use` — JWT anon-ключ остаётся валидным; мигрировать на `publishableKey`
   при ротации кредов.

---

## 12. Структура каталогов

Дерево с однострочными пояснениями (сгенерировано из `find lib -type f` + корень репозитория).

```
Admity/
├─ README.md                         # обзор + быстрый старт (EN/RU)
├─ pubspec.yaml                      # зависимости и конфиг Flutter
├─ pubspec.lock                      # зафиксированные версии
├─ l10n.yaml                         # конфиг flutter gen-l10n
├─ analysis_options.yaml             # very_good_analysis (строгий линт)
├─ .env.example                      # шаблон для env.json (Supabase креды)
├─ .gitignore                        # игнорит env.json, генерируемый l10n, *.g.dart и т.д.
├─ tool/
│  ├─ run_web.sh                     # launcher: flutter run -d chrome [--dart-define-from-file]
│  └─ gen_logo.py                    # генерация assets/brand/* из геометрии маскота
├─ assets/
│  └─ brand/
│     ├─ admity_icon.png             # иконка приложения
│     ├─ admity_mark.png             # знак (прозрачный)
│     └─ admity_splash.png           # знак для splash
├─ supabase/
│  ├─ README.md                      # настройка бэкенда
│  ├─ migrations/0001_init.sql       # схема + RLS
│  ├─ seed.sql                       # справочные данные (зеркало Dart seed)
│  └─ functions/eraly/index.ts       # Edge Function «Ералы» (Deno → Anthropic API)
├─ test/
│  ├─ domain/                        # unit-тесты доменной логики (7 файлов)
│  └─ widget_test.dart               # app-boot тест
├─ android/ · ios/ · web/            # платформенные обвязки Flutter
└─ lib/
   ├─ main.dart                      # entry → bootstrap()
   ├─ bootstrap.dart                 # биндинги + LocalStore + initSupabase() + runApp(ProviderScope)
   ├─ app.dart                       # MaterialApp.router (тема/l10n/роутинг)
   ├─ core/
   │  ├─ ai/eraly_client.dart        # клиент Ералы + офлайн-фолбэк + анти-ghost-writing
   │  ├─ env/app_env.dart            # AppEnv (compile-time креды)
   │  ├─ error/.gitkeep              # зарезервировано под failures/result-типы
   │  ├─ l10n/locale_controller.dart # переключатель языка
   │  ├─ router/
   │  │  ├─ app_router.dart          # GoRouter: 5-вкладочная оболочка + detail-маршруты
   │  │  ├─ app_routes.dart          # пути и имена маршрутов
   │  │  └─ scaffold_with_nav_bar.dart # нижняя навигация (5 вкладок)
   │  ├─ storage/local_store.dart    # JSON key/value стор + localStoreProvider
   │  ├─ supabase/
   │  │  ├─ supabase_bootstrap.dart  # initSupabase() (или graceful no-op)
   │  │  └─ supabase_providers.dart  # supabaseClientProvider, authStateChangesProvider
   │  ├─ theme/                      # AppColors, AppTheme, AppTokens, AppSpacing/Radii/Typography/Durations
   │  └─ utils/app_logger.dart       # логирование без print
   ├─ features/
   │  ├─ onboarding/                 # 5-шаговый онбординг → профиль
   │  ├─ auth/                       # magic-link + гостевой режим
   │  ├─ dashboard/                  # вкладка «Главная»
   │  ├─ career_test/                # RIASEC + Big Five → кластеры
   │  ├─ chancing_kz/                # чансинг ЕНТ (движок + seed + UI)
   │  ├─ chancing_world/             # чансинг CDS (движок + seed + UI)
   │  ├─ universities/               # каталог вузов + деталь + college list
   │  ├─ scholarships/               # честный матчинг стипендий
   │  ├─ gap_closer/                 # задачи «закрыть пробелы»
   │  ├─ project_ideas/              # идеи проектов по RIASEC
   │  ├─ intensives/                 # «Эссе за 14 дней» + треки, XP/стрики
   │  ├─ essay_review/               # локальная рубрика эссе
   │  ├─ eraly_chat/                 # чат Ералы (вкладка «Ералы»)
   │  ├─ profile/                    # профиль + приватные заметки
   │  └─ design_showcase/            # витрина дизайн-системы (/design)
   ├─ l10n/
   │  ├─ app_en.arb / app_ru.arb / app_kk.arb   # источники переводов
   │  └─ app_localizations*.dart     # генерируемые (в .gitignore)
   └─ shared/
      ├─ models/                     # profile.dart, chance_category.dart
      └─ widgets/                    # BentoCard, EralyAvatar, ChancePill, ProgressRing, ScoreBarChart, …
```

> Внутри каждой фичи действует структура `data/` · `domain/` · `presentation/`; пустые слои помечены
> `.gitkeep`.

---

## 13. Безопасность — почему приложению можно доверять

Все утверждения основаны на фактическом коде (схема БД, Edge Function, клиент, конфигурация сборки) и
проверены аудитом. **Краткий вывод:** захардкоженных секретов нет (проверено grep по `sk-ant-`,
`eyJhbGci`, `service_role`, `api_key`, `token`); архитектура «secrets only on the server» соблюдена.

### 13.1. Секреты и ключи
- **Ключ LLM — только на сервере.** `ANTHROPIC_API_KEY` читается в Edge Function через `Deno.env.get`
  (`supabase/functions/eraly/index.ts`). Клиент **никогда** его не видит — он вызывает функцию через
  `supabase.functions.invoke('eraly')` (`lib/core/ai/eraly_client.dart`). Ключ невозможно извлечь из APK/IPA.
- **Anon-ключ — публичный по дизайну** (`app_env.dart`): это клиентский JWT, защищённый не секретностью,
  а RLS (§13.2). Подаётся на сборке через `--dart-define-from-file=env.json`; `env.json`/`.env` — в `.gitignore`.
- **Service-role-ключ** в приложении не используется (наполнение справочников — вне клиента).

### 13.2. Row-Level Security (главный контур)
Включён для **всех** таблиц (`supabase/migrations/0001_init.sql`). Для таблиц данных ученика (`profiles`,
`personal_notes`, `career_results`, `ent_scores`, `college_list`, `gap_tasks`, `intensive_progress`,
`essays`, `chat_threads`, `chat_messages`):
```sql
create policy <t>_owner_select on public.<t> for select using (auth.uid() = user_id);
create policy <t>_owner_modify on public.<t> for all
  using (auth.uid() = user_id) with check (auth.uid() = user_id);
```
`auth.uid()` — id из проверенного JWT; `user_id` — владелец строки. Даже с валидным anon-ключом нельзя
прочитать или подменить чужой профиль/баллы/эссе/переписку. Справочные таблицы (`universities`,
`scholarships`, `ent_cutoffs`, `cds_snapshots`, `intensives`) — read-only для `authenticated`.

### 13.3. Приватность несовершеннолетних
Изоляция через RLS; системный промпт Ералы знает, что пользователи несовершеннолетние (без
медицинских/юридических диагнозов, мягкое направление к взрослому при кризисе); принцип «направляю, не
пишу за ученика» продублирован на клиенте (`_isGhostwritingRequest`) и работает офлайн; к LLM уходит
только профиль-контекст + сообщение + история, а не вся БД.

### 13.4. Данные на устройстве
- **LocalStore** — нешифрованный JSON в песочнице приложения; там только **собственные** данные ученика.
- **flutter_secure_storage** — для токенов (Keychain/Keystore). Правило: токены → secure storage; обычные
  данные → LocalStore.
- **Фото табеля/камеры остаются на устройстве** — `image_picker` сохраняет только **путь к файлу** (ключи
  `gpa_report_photo`, `intensive_camera_evidence`); файлы не уходят в сеть без явной синхронизации
  (отражено в строках разрешений `Info.plist`: «Фото остаётся на устройстве»).

### 13.5. Транспорт
Весь трафик Supabase и Edge Function → Anthropic идёт по **HTTPS/TLS**. iOS ATS включён (нет
`NSAllowsArbitraryLoads`); Android не разрешает cleartext (нет `usesCleartextTraffic`). Внешние ссылки
(стипендии) открываются во внешнем браузере, не в in-app WebView.

### 13.6. Чего мы НЕ делаем
Нет рекламы. Нет сторонних трекеров/аналитики (только локальный `AppLogger`, без отправки PII).
Offline-first. Вход — **Apple** (нативный, без пароля) и **Gmail c одноразовым кодом** (`signInWithOtp`
→ `verifyOTP`); пароли на клиенте не хранятся, сессию хранит `supabase_flutter`.

### 13.7. Харднинг (сделано в этой итерации)
Закрыты главные открытые зоны из прошлого аудита:
- **Edge Function `eraly` теперь требует JWT.** Читает `Authorization: Bearer <jwt>`, валидирует через
  `auth.getUser()`, отклоняет анонимные/невалидные вызовы (`401`) и привязывает запрос к `user_id`. Клиент
  `supabase.functions.invoke('eraly')` подставляет JWT автоматически — менять код приложения не нужно,
  но для онлайн-чата с Ералы пользователь должен быть авторизован (офлайн-фолбэк не затронут).
- **Rate-limit + лимит размера.** ~20/мин и ~200/день на пользователя через новую таблицу `rate_limits`
  (RLS-locked) + `SECURITY DEFINER` функцию `bump_rate_limit()`; превышение → `429`, тело > 16 КБ → `413`.
  Миграция: `supabase/migrations/0002_rate_limits.sql`.
- **CORS сужен** — вместо `*` теперь allowlist из env `ALLOWED_ORIGINS` (по умолчанию браузерные origin
  запрещены; нативное приложение не шлёт `Origin` и работает как раньше).
- **Минимизация PII к LLM** — `eraly_client.dart` больше не отправляет ФИО, регион, email, локаль,
  свободный текст мотивации; GPA огрубляется в `gpa_band`. Остаётся только неидентифицирующий контекст
  (класс, интересы, цели, направление мечты).

**Остаётся как дальнейшие улучшения:** шифровать чувствительные локальные данные (`allowBackup=false` на
Android, complete Data Protection на iOS); хранить сессии Supabase в `flutter_secure_storage`; добавить
интеграционные RLS-тесты; экран политики приватности и (по юрисдикции) родительское согласие; реальная
настройка провайдеров входа (Apple capability в Xcode + Apple/Email-OTP в дашборде Supabase — см. §15).

---

## 14. Что нового в этой итерации

Поверх базовых 14 шагов (всё офлайн; `flutter analyze` чисто с `fatal-infos`; тесты зелёные):

- **Главная — живой контент:** «Цитата дня» (`lib/features/quotes/`, 60+ цитат, меняется ежедневно,
  избранное); мини-игры **«Слово дня»** (Wordle RU — `lib/features/games/wordle/`, клавиатура, стрик,
  шаринг) и **«Угадай вуз»** (GeoGuessr по реальным вузам — `lib/features/games/guess_uni/`); плитка
  «Калькулятор GPA».
- **Онбординг — 11 анимированных шагов:** приветствие с логотипом, `flutter_animate`-входы; новые вопросы
  (мечта, английский, часы на учёбу, бюджет, мотивация). На шаге GPA — **GPA-помощник**
  (`lib/features/gpa/`): не знаешь GPA → **сфотографируй табель** (камера/галерея) **или заполни таблицу
  оценок** → приложение само считает GPA (5-балльная и 4.0) и вписывает его.
- **Профориентация:** расширенный банк (36 RIASEC + 20 Big Five), **рекомендации специальностей** в
  результате, новый мини-тест **«Ценности и мотиваторы»** (`/values-test`).
- **Интенсивы — задания, которые тебя оценивают:** **камера/видео** (фото списка фактов, 60-сек
  самопрезентация, чтение эссе вслух) и **мгновенная самооценка** (впиши абзац → оценка по рубрике офлайн,
  переиспользует `RubricScorer`).
- **Бренд:** анимация входа (splash) + нативный логотип/иконка (`tool/gen_logo.py`, `assets/brand/`).
- **Новые маршруты:** `/splash`, `/games/wordle`, `/games/guess-uni`, `/gpa`, `/values-test`.
  **Новая зависимость:** `image_picker` (+ строки разрешений в `ios/Runner/Info.plist`).

Запуск — без изменений: `flutter run -d ios|android|chrome` (`--dart-define-from-file=env.json` для
Supabase). Платформы и БД — §6–7; краткая выжимка — `docs/SUMMARY.md`.

---

## 15. Что нового (вторая волна)

- **Детали вуза переработаны** (`lib/features/universities/`): на странице вуза теперь acceptance rate
  (с `ProgressRing` и пометкой года/«оценка»), миссия и ценности, заметные факты, программы, стоимость и
  финпомощь, кнопка «Сайт вуза», и **отдельная секция «Кейсы поступивших»** — карточки с профилем,
  «что сработало» и исходом, каждая честно помечена «Иллюстративный пример» (композитные, не реальные
  люди). Модель `University` расширена (`acceptanceRate` как доля 0..1, `mission`, `values`,
  `notableFacts`, `website`, `admittedCases`) — обратносовместимо.
- **Календарь** (`lib/features/calendar/`): карточка «Ближайшие дедлайны» на Главной + полноэкранный
  месяц (`/calendar`, `table_calendar`). События = дедлайны грантов из seed стипендий + окна ЕНТ +
  ориентиры Common App/UCAS (помечены «ориентир»). Полностью офлайн (RU-даты заданы вручную, без
  `initializeDateFormatting`).
- **Вход через Apple и Gmail-OTP** (`lib/features/auth/`): см. §15.1 по настройке.
- **Интенсивы — настоящие уроки** (`lib/features/intensives/`): каждый день = микро-урок с теорией и
  разборами (`lessonSections`), списком **реальных материалов** (`resources`, ссылки на Khan Academy,
  College Essay Guy, Common App, British Council, IELTS.org…), практикой, рубрикой и интерактивным
  заданием. **6 треков** (добавлены «IELTS старт за 14 дней» и «Лидерство и проекты для портфолио»).
- **Полировка анимаций игр** (Wordle: флип-плитки/победный bounce/плавная клавиатура; «Угадай вуз»:
  кросс-фейд подсказок, стаггер-кнопки, пульс/шейк фидбэка, поп счёта).
- **Безопасность Edge Function** — см. §13.7 (JWT, rate-limit, CORS, минимизация PII).

### 15.1. Что включить в Supabase (для админа БД)

1. **Миграции:** `supabase db push` (применит `0001_init.sql` + новый `0002_rate_limits.sql`). RLS на
   `rate_limits` запрещает клиентский доступ; функция дергает `bump_rate_limit()` под service-role.
2. **Email-OTP (Gmail):** включить Email-провайдер; в шаблоне письма оставить `{{ .Token }}`, чтобы
   приходил 6-значный код (приложение зовёт `verifyOTP(type: OtpType.email)`).
3. **Sign in with Apple:** включить Apple-провайдер (Services ID/bundle id, Team ID, Key ID, `.p8`).
   В Xcode добавить таргету Runner capability **Sign in with Apple** (файл-заготовка
   `ios/Runner/Runner.entitlements` уже есть) и включить «Sign in with Apple» у App ID в Apple Developer.
4. **Секреты Edge Function:** `ANTHROPIC_API_KEY` (обязательно), `ERALY_MODEL` (опц.), `ALLOWED_ORIGINS`
   (только если будет веб-клиент). Затем `supabase functions deploy eraly`. Детали — `supabase/README.md`.

Без этой настройки приложение работает в офлайн-режиме (вход можно «Пропустить», Ералы даёт офлайн-
фолбэк) — ничего не падает.

---

*Документ описывает состояние репозитория `/Users/sanjarzhumagaliyev/Projects/Admity` и сверен с исходным
кодом. Справочные данные (баллы, дедлайны, суммы) помечены годом и должны перепроверяться у первоисточника.*
