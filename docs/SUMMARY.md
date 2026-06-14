# Admity — что сделано и как запускать

Короткий рабочий документ: что изменилось в этой итерации и как поднять приложение на **iOS**, **Android** и подключить **Supabase**.
Полный технический гайд (архитектура, все фичи, схема БД, тесты) — в [PROJECT_GUIDE.md](PROJECT_GUIDE.md).

---

## 1. Что сделано в этой сессии

| # | Задача | Что сделано | Файлы |
|---|--------|-------------|-------|
| 1 | **Пустая Главная** | Найдена и устранена причина: ошибка раскладки «бесконечная высота» от `Row(crossAxisAlignment: stretch)` внутри прокручиваемого списка **молча проглатывалась** (в `bootstrap.dart` переопределён `FlutterError.onError` → ошибки идут в `dart:developer`, без красного экрана). Дашборд — стартовая ветка `IndexedStack`, поэтому не перерисовывался и оставался пустым. Двойную карточку обернул в `IntrinsicHeight`, тело перевёл на `SafeArea → SingleChildScrollView → Column(mainAxisSize: min)`. | `lib/features/dashboard/presentation/dashboard_screen.dart` |
| 2 | **Выравнивание** | Онбординг «висел» в нижней половине из-за `AnimatedSwitcher` (по умолчанию центрирует). Добавил `layoutBuilder` с `Alignment.topCenter` — контент прижат к верху. | `lib/features/onboarding/presentation/onboarding_screen.dart` |
| 3 | **Анимация входа** | Брендовый сплэш: векторный логотип (маскот «Ералы» на терракотовой плитке) пружинит, мерцает и «дышит»; вордмарк **Admity** + слоган всплывают. На `flutter_animate`. После анимации роутер уводит на дашборд/онбординг. | `lib/features/splash/presentation/splash_screen.dart`, `lib/shared/widgets/admity_logo.dart` |
| 4 | **Логотип при запуске** | Нативный launch screen (`flutter_native_splash`) + иконка приложения (`flutter_launcher_icons`), сгенерированы из брендовых ассетов. | `tool/gen_logo.py`, `assets/brand/*`, конфиг в `pubspec.yaml` |
| 5 | **Документация** | Полный гайд проекта + этот саммари. | `docs/PROJECT_GUIDE.md`, `docs/SUMMARY.md` |

Проверки: `flutter analyze` — чисто (с `fatal-infos`); `flutter test` — **42/42** проходят.

> ⚠️ Важно для будущей отладки: из-за переопределённого `FlutterError.onError` **пустой экран обычно означает ошибку раскладки, а не исключение** — проверяйте constraints (особенно `stretch` внутри скроллов), а не только стек ошибок.

---

## 2. Базовая подготовка (один раз / после `git pull`)

```bash
cd ~/Projects/Admity
flutter pub get          # зависимости
flutter gen-l10n         # типизированные локализации (kk/ru/en) из lib/l10n/*.arb
```

Окружение: **Flutter 3.41.6 / Dart 3.11.4**.
Приложение полностью работает **без бэкенда** (offline-light, гостевой режим) — Supabase нужен только для авторизации, синхронизации и AI-ментора «Ералы».

Идентификатор приложения (Android `applicationId` и iOS bundle id): **`kz.admity.admity`**.

---

## 3. iOS

Тулчейн уже настроен (Xcode 26.2 ✓, симулятор работает).

```bash
# список устройств
flutter devices

# запуск на симуляторе (создаст/использует загруженный iPhone-симулятор)
open -a Simulator
flutter run -d ios

# или на конкретный симулятор по UDID
xcrun simctl list devices available | grep iPhone
flutter run -d <UDID>

# с подключённой Supabase (см. раздел 5)
flutter run -d <UDID> --dart-define-from-file=env.json
```

Если Xcode переставлялся и сборка не идёт:

```bash
sudo xcode-select -s /Applications/Xcode.app/Contents/Developer
sudo xcodebuild -runFirstLaunch
cd ios && pod install && cd ..
```

Релизная сборка:

```bash
flutter build ios --release --dart-define-from-file=env.json   # затем архив через Xcode
```

> Реальный iPhone подключается по кабелю + Developer Mode на устройстве; беспроводное подключение требует включённого Developer Mode и одной сети.

---

## 4. Android

На этой машине **Android SDK ещё не установлен** (`flutter doctor` показывает `[✗] Android toolchain`). Поэтому сначала — разовая настройка.

### 4.1. Установка SDK (один раз)

1. Установить **Android Studio**: <https://developer.android.com/studio> — при первом запуске мастер сам поставит Android SDK, platform-tools и эмулятор.
2. Указать Flutter путь к SDK (если не подхватился автоматически):
   ```bash
   flutter config --android-sdk ~/Library/Android/sdk
   ```
3. Принять лицензии и проверить:
   ```bash
   flutter doctor --android-licenses   # ответить y на всё
   flutter doctor                       # [✓] Android toolchain
   ```

### 4.2. Эмулятор или устройство

```bash
# создать/запустить эмулятор из Android Studio (Device Manager) или:
flutter emulators                 # список
flutter emulators --launch <id>   # запустить

# реальное устройство: включить «Параметры разработчика» → «Отладка по USB»,
# подключить кабелем, разрешить отладку
flutter devices
```

### 4.3. Запуск и сборка

```bash
flutter run -d android                                   # debug
flutter run -d android --dart-define-from-file=env.json  # с Supabase

flutter build apk --release --dart-define-from-file=env.json     # APK
flutter build appbundle --release --dart-define-from-file=env.json  # AAB для Google Play
```

Сборки лежат в `build/app/outputs/`. `minSdk`/`compileSdk` наследуются от Flutter (`flutter.minSdkVersion` / `flutter.compileSdkVersion`).

> Для релиза в Play потребуется свой keystore и подпись (`android/key.properties` + `signingConfigs`) — на этом этапе ещё не настроено.

---

## 5. Supabase (Postgres + Auth + Storage + RLS + Edge Function)

Архитектура: данные ученика в Postgres под защитой **RLS**; AI-ключ **никогда не в клиенте** — «Ералы» работает в серверной Edge Function `eraly`.

### 5.1. Создать проект и получить ключи

1. Создать проект на <https://supabase.com> → **New project**.
2. **Project Settings → API**: скопировать **Project URL** и **anon public** ключ.

### 5.2. Прокинуть ключи в приложение

Ключи читаются на этапе сборки через `String.fromEnvironment` (`lib/core/env/app_env.dart`). Создать `env.json` в корне (он в `.gitignore`):

```json
{
  "SUPABASE_URL": "https://YOUR-PROJECT-ref.supabase.co",
  "SUPABASE_ANON_KEY": "eyJhbGciOi...ваш-anon-ключ..."
}
```

Запускать с флагом:

```bash
flutter run --dart-define-from-file=env.json
# (без флага приложение работает оффлайн: initSupabase() логирует warning и пропускается)
```

Шаблон — в [`.env.example`](../.env.example). anon-ключ публичный (его защищает RLS), но `env.json` всё равно не коммитим.

### 5.3. Накатить схему БД

Вариант А — через Supabase CLI:

```bash
brew install supabase/tap/supabase     # если ещё нет
supabase login
supabase link --project-ref YOUR-PROJECT-ref
supabase db push                        # применит supabase/migrations/0001_init.sql
# (опционально) залить справочные/демо-данные:
psql "$SUPABASE_DB_URL" -f supabase/seed.sql
```

Вариант Б — вручную: открыть **SQL Editor** в дашборде Supabase и выполнить содержимое
`supabase/migrations/0001_init.sql`, затем при желании `supabase/seed.sql`.

Схема включает таблицы данных ученика (профиль, заметки, баллы, прогресс) с политиками RLS вида `auth.uid() = user_id` и справочные таблицы. Подробности — в [PROJECT_GUIDE.md](PROJECT_GUIDE.md) (раздел «Бэкенд: Supabase») и `supabase/README.md`.

### 5.4. Развернуть Edge Function «Ералы» (AI-ментор)

```bash
supabase functions deploy eraly

# секреты функции (НЕ в клиенте!):
supabase secrets set ANTHROPIC_API_KEY=sk-ant-...        # обязательно
supabase secrets set ERALY_MODEL=claude-sonnet-4-6        # опционально; для макс. качества: claude-opus-4-8
```

Функция (`supabase/functions/eraly/index.ts`) вызывает Anthropic API серверно (`anthropic-version: 2023-06-01`). Клиент дергает её через `Supabase.instance.client.functions.invoke('eraly', ...)` (`lib/core/ai/eraly_client.dart`). Без задеплоенной функции чат «Ералы» показывает дружелюбную заглушку.

### 5.5. Проверка

Запустить с `--dart-define-from-file=env.json`, зарегистрироваться/войти, открыть вкладку **Ералы** — если функция и ключ на месте, придёт ответ модели; данные профиля синхронизируются в Postgres под RLS.

---

## 6. Перегенерация бренд-ассетов (если меняли логотип/цвета)

```bash
python3 tool/gen_logo.py                 # пересоздать assets/brand/*.png из брендовых цветов
dart run flutter_native_splash:create    # нативный launch screen (iOS/Android)
dart run flutter_launcher_icons          # иконки приложения (iOS/Android)
```

Конфиги `flutter_native_splash` и `flutter_launcher_icons` — в `pubspec.yaml`. Векторная версия логотипа для in-app анимации — `lib/shared/widgets/admity_logo.dart`.

---

## 7. Контроль качества

```bash
flutter analyze        # должно быть "No issues found!" (включён fatal-infos)
flutter test           # доменные тесты движков шансов/стипендий + boot-тест
```

---

## 8. Шпаргалка команд

```bash
flutter pub get
flutter gen-l10n
flutter run -d ios     --dart-define-from-file=env.json
flutter run -d android --dart-define-from-file=env.json
flutter run -d chrome                      # web, оффлайн, без бэкенда
flutter build apk      --release --dart-define-from-file=env.json
flutter build appbundle --release --dart-define-from-file=env.json
flutter build ios      --release --dart-define-from-file=env.json
flutter analyze && flutter test
```

---

## 9. Публикация в приватный GitHub-репозиторий

Репозиторий уже инициализирован локально с первым коммитом на ветке `main`
(`git log` это покажет). `.gitignore` исключает `env.json`/`.env`, `.dart_tool/`,
`build/`, `ios/Pods/` — секреты и артефакты в историю НЕ попадают.

**Вариант A — через GitHub CLI (быстрее всего):**
```bash
brew install gh            # если ещё не установлен
gh auth login              # GitHub.com → HTTPS → войти в браузере (твой аккаунт)
# создаёт приватный репо, добавляет remote и пушит текущую ветку:
gh repo create admity --private --source=. --remote=origin --push
```

**Вариант B — вручную через github.com:**
1. Открой <https://github.com/new>, имя `admity`, выбери **Private**, НЕ добавляй
   README/.gitignore/лицензию (репозиторий уже не пустой локально).
2. Привяжи remote и запушь:
```bash
git remote add origin https://github.com/<твой-логин>/admity.git
# или по SSH: git remote add origin git@github.com:<твой-логин>/admity.git
git push -u origin main
```

Дальнейшие изменения: `git add -A && git commit -m "..." && git push`.

> Авторизацию в GitHub (вход в твой аккаунт) нужно сделать тебе самому — я
> намеренно не вхожу в твои аккаунты. Локальный git уже готов, остаётся только
> один из вариантов выше.
