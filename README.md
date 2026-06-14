# Admity

**Agentic admissions mentor for students from the regions of Kazakhstan.**
Honest chancing (real ЕНТ thresholds + Common Data Set logic), real scholarship
matching, and **Eraly** — an AI mentor that guides and corrects but never does
the student's work. Built with Flutter, Riverpod, Supabase, go_router.

> Audience: teenagers (14–18), often on budget Android phones, weak-to-moderate
> English, limited internet. The app is multilingual (Kazakh / Russian / English),
> privacy-first for minors, and designed to feel premium without looking like
> "another AI app".

---

## Быстрый старт (TL;DR на русском)

```bash
# 1. Поставить зависимости
flutter pub get

# 2. Сгенерировать переводы (KZ/RU/EN)
flutter gen-l10n

# 3. Запустить БЕЗ бэкенда (offline-light) — приложение работает без Supabase
flutter run -d chrome

# 4. Запустить С Supabase (после настройки, см. раздел ниже)
flutter run -d chrome --dart-define-from-file=env.json
```

Сейчас готов **Шаг 1 (каркас)**: запускается пустой, но настоящий «скелет»
с темой, навигацией, локализацией и инициализацией Supabase. Настоящие экраны
(профориентация, чансинг, стипендии, интенсивы, эссе, чат Ералы) — на следующих
шагах. Supabase подключать **не обязательно** прямо сейчас.

---

## Requirements

| Tool | Version used | Status on this machine |
|---|---|---|
| Flutter (stable) | 3.41.6 | ✅ installed |
| Dart | 3.11.4 | ✅ installed |
| Chrome (web target) | — | ✅ present |
| macOS desktop target | — | ✅ present |
| Xcode (iOS builds) | — | ❌ not installed (only needed for iOS) |
| Android SDK / `adb` | — | ❌ not installed (only needed for Android) |

You can develop the whole app against the **web** target. To later build for
iOS install Xcode; for Android install Android Studio + the Android SDK.

## Run

The app is **mobile-first (Android + iOS)** and runs fully offline-light (no
backend needed — bundled seed data + a local JSON store).

```bash
flutter pub get
flutter gen-l10n

# iOS Simulator (after the one-time iOS setup below)
open -a Simulator
flutter run                       # picks the booted simulator

# Android emulator (after installing Android Studio + an AVD)
flutter run

# Quick look in the browser (no Xcode/Android needed)
flutter run -d chrome
```

### One-time iOS setup (you have Xcode installed)

```bash
# Point the toolchain at the full Xcode app (not just Command Line Tools)
sudo xcode-select -s /Applications/Xcode.app/Contents/Developer
sudo xcodebuild -runFirstLaunch
xcodebuild -downloadPlatform iOS          # iOS simulator runtime

# CocoaPods (Flutter iOS plugins need it)
sudo gem install cocoapods                # or: brew install cocoapods

flutter doctor                            # should now show iOS ✓
cd ios && pod install && cd ..            # first time only
flutter run                               # on a booted simulator
```

### One-time Android setup

Install Android Studio → SDK + an emulator (AVD), then `flutter run`. `flutter
doctor --android-licenses` to accept licenses.

## Connect Supabase (when you're ready)

The app runs fine without Supabase (it logs a warning and skips init). To enable
the backend:

1. **Create a project** at <https://supabase.com> → New project. Pick a region
   close to Kazakhstan (e.g. EU/Frankfurt) and save the database password.
2. **Copy your credentials**: Supabase dashboard → *Project Settings → API*.
   - **Project URL** → `SUPABASE_URL` (e.g. `https://abcd1234.supabase.co`)
   - **Project API keys → `anon` `public`** → `SUPABASE_ANON_KEY`
3. **Create `env.json`** in the project root (it is gitignored — never commit it):
   ```json
   {
     "SUPABASE_URL": "https://YOUR-REF.supabase.co",
     "SUPABASE_ANON_KEY": "eyJhbGciOi...your-anon-key..."
   }
   ```
   See `.env.example` for the template.
4. **Run with the creds:**
   ```bash
   flutter run -d chrome --dart-define-from-file=env.json
   ```
   On startup you should see `Supabase initialized.` in the logs instead of the
   "not configured" warning.

> The `anon` key is a **public** client key — that is by design. Data is
> protected by **Row-Level Security** policies (added with the schema in Step 3),
> so the key alone exposes nothing. The **LLM API key is never in the client** —
> Eraly runs server-side in a Supabase Edge Function (Step 13).

### Where each secret lives

| Secret | Where it goes | Committed? |
|---|---|---|
| `SUPABASE_URL` | `env.json` → `--dart-define-from-file` | ❌ no |
| `SUPABASE_ANON_KEY` | `env.json` → `--dart-define-from-file` | ❌ no |
| LLM / model API key | Supabase Edge Function secret (server-side) | ❌ never in app |

Read in code via compile-time constants in `lib/core/env/app_env.dart`
(`String.fromEnvironment`). No secrets are hardcoded anywhere.

## Project structure (feature-first, layered)

```
lib/
  main.dart                 # entry → bootstrap()
  bootstrap.dart            # bindings + Supabase init + runApp(ProviderScope)
  app.dart                  # MaterialApp.router (theme, l10n, routing)
  core/
    env/                    # AppEnv — compile-time config (dart-define)
    l10n/                   # locale controller (KZ/RU/EN switch)
    router/                 # go_router config + route names
    supabase/               # client init + providers (auth stream)
    theme/                  # color tokens + light/dark ThemeData (full DS = Step 2)
    utils/                  # AppLogger (no print)
    error/                  # failures / result types (later)
  features/                 # one folder per feature, each with data/domain/presentation
    onboarding/  auth/  dashboard/        # have placeholder screens
    career_test/ chancing_kz/ chancing_world/
    universities/ scholarships/ gap_closer/
    project_ideas/ intensives/ essay_review/
    eraly_chat/  profile/                 # scaffolded (empty layers)
  l10n/                     # *.arb sources + generated AppLocalizations
  shared/
    widgets/  models/       # cross-feature UI + domain models
```

## Architecture notes

- **State**: Riverpod is the single source of truth. UI is a pure function of
  provider state — no `setState` for business logic, no global singletons.
- **Navigation**: declarative go_router; route names centralized in `AppRoutes`.
- **Backend**: Supabase (Postgres + Auth + Storage + Realtime + RLS). The client
  never holds the LLM key — Eraly is a server-side Edge Function.
- **i18n**: every user-facing string comes from `.arb` files (`kk`, `ru`, `en`).
  Regenerate with `flutter gen-l10n` after editing them.
- **Lint**: `very_good_analysis` (strict). CI runs
  `flutter analyze --fatal-infos --fatal-warnings`.

### ⚠️ Decision: Riverpod **without** code-gen (for now)

The spec asks for `riverpod_generator`. With this Flutter SDK (3.41.6 / Dart
3.11.4) the codegen toolchain is currently **unresolvable**: `riverpod_generator`
requires `analyzer ^12` (which needs `meta ^1.18`), but the Flutter SDK pins
`meta 1.17.0`. `drift_dev` collides the same way. So the scaffold uses **plain,
fully-idiomatic Riverpod 3.x providers** (`NotifierProvider`, `Provider`,
`StreamProvider`). This is functionally identical and reversible — migrating a
handful of providers to `@riverpod` is mechanical once the analyzer/meta pins
realign. `drift` (runtime) is declared but its codegen (`drift_dev`) is deferred
for the same reason until offline cache is actually wired.

## Build status — all 14 steps implemented ✅

1. ✅ Scaffold (deps, structure, go_router, Supabase init, l10n kk/ru/en)
2. ✅ Design system + `/design` showcase (tokens, ThemeExtension, bento, Eraly mascot)
3. ✅ Supabase schema + RLS + seed (`supabase/migrations`, `seed.sql`)
4. ✅ Auth (magic-link / guest) + 5-step onboarding → `profiles`
5. ✅ Profile + private "facts about me" notes
6. ✅ Career test (RIASEC + Big Five) + results → major clusters
7. ✅ Chancing engines — ЕНТ + CDS (pure, unit-tested) + `fl_chart` UI
8. ✅ Universities explorer + detail + college list
9. ✅ Scholarships matcher (honest eligibility filtering)
10. ✅ Gap-closer (dated tasks) + project ideas
11. ✅ Intensives — full 14-day «Эссе за 14 дней» + 3 tracks, XP/streak/freeze
12. ✅ Essay review (local rubric + Eraly online, never ghost-writes)
13. ✅ Eraly chat + Edge Function (`supabase/functions/eraly`)
14. ✅ Polish — haptics, tactile motion, dark mode, calm warm palette

**Verification:** `flutter analyze` clean (strict `very_good_analysis`,
`--fatal-infos`), 31 domain unit tests + app-boot widget test pass, full
`flutter build web` succeeds. Domain logic (chancing, scoring, intensives) is
pure Dart and deterministic.

## Test

```bash
flutter test
```
