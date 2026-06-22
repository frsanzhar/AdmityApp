# Admity

> Status: **greenfield**. This directory is a fresh start. Treat everything below as
> intended design, not implemented fact — verify against the actual tree before
> asserting any file, feature, or behavior exists.

## What it is

Admity is an agentic **admissions-mentor** app for Kazakhstan-region teens (14–18),
shipping **cross-platform on iOS and Android** (mobile-first, Flutter).

Core ideas:
- **Honest chancing** — real ЕНТ thresholds + Common Data Set logic, never inflated odds.
- **Scholarship matching** against the student's profile.
- **"Eraly"** — an AI mentor that guides and corrects but **never writes essays for the
  student**. It coaches; it does not ghostwrite.
- **Multilingual**: KZ / RU / EN.
- **Privacy-first for minors** — minimal PII, data on-device by default, server-side RLS.

## Intended stack

- **Flutter** (mobile-first: Android + iOS).
- **State**: plain idiomatic **Riverpod 3.x** providers (`NotifierProvider`, `Provider`,
  `StreamProvider`). **Do not use `@riverpod` codegen** — see toolchain note below.
- **Nav**: `go_router` (`StatefulShellRoute.indexedStack` for the tab shell + full-screen
  detail routes).
- **Backend**: Supabase (Postgres / Auth / Storage / **RLS**). Reference data also bundled
  as Dart seed constants so the app works fully offline (guest mode).
- **Charts**: `fl_chart`.
- **AI**: LLM calls are **server-side only** via a Supabase **Edge Function**. The LLM API
  key is **never** in the client. Client sends minimized payloads (no name/email/region;
  GPA as a band, not a raw number).

## Architecture

- **Feature-first**: `lib/features/<feature>/{data,domain,presentation}`.
- Shared/core in `lib/core/` and `lib/shared/`.
- Offline-first: local persistence is the source of truth; Supabase is write-through /
  two-way sync when configured. Everything degrades gracefully to a no-op when Supabase
  isn't wired (`!hasSupabase`), errors swallowed, local store stays authoritative.
- Bundle id: `kz.admity.admity`.

## Toolchain gotchas (carry these forward — they cost real time before)

1. **No Riverpod / drift codegen on this SDK.** On Flutter 3.41.x / Dart 3.11.x,
   `riverpod_generator` wants `analyzer ^12` (→ `meta ^1.18`) but the Flutter SDK pins
   `meta 1.17.0`; `drift_dev` collides the same way. So: hand-written Riverpod providers,
   no `riverpod_annotation`/`riverpod_generator`. Revisit only after the analyzer/meta
   pins realign.

2. **Blank screen ≠ no error.** If `bootstrap.dart` routes `FlutterError.onError` through a
   logger (`dart:developer`), **layout errors don't print to stdout and don't show a red
   ErrorWidget** — the RenderObject just paints nothing. A blank screen means *check
   layout constraints first*, not exceptions. Classic trap: `CrossAxisAlignment.stretch`
   on a `Row`/`Column` inside a scroll view → infinite-height error → swallowed → whole
   viewport blank. Fix: wrap in `IntrinsicHeight`, and prefer
   `SafeArea > SingleChildScrollView > Column(mainAxisSize: .min)` over a bare `ListView`
   body. The initial `indexedStack` branch is the most likely victim (it never relayouts).
   Add a widget test that fails on swallowed layout errors for any new dashboard-style
   screen.

3. **Dates**: hand-roll RU/KZ date formatting; **do not** call
   `initializeDateFormatting` casually — getting it wrong crashes to a blank screen.

4. **Project folder size is cache, not the app.** `build/` + `.dart_tool/` can balloon to
   multiple GB. `flutter clean` → ~11 MB, then `flutter pub get`. Real installable size:
   release APK split-per-abi ≈ 28–33 MB (arm64 ≈ 31 MB). Ship an **app bundle**
   (`flutter build appbundle`) for Play. Don't chase the folder GB number.

## Dev workflow

- Run: `flutter run -d emulator-5554` (Android) / an iOS sim, or `flutter run -d chrome`
  for quick offline-light checks. Add `--dart-define-from-file=env.json` for Supabase.
- Before claiming done: `flutter analyze` clean (project uses `very_good_analysis`,
  fatal-infos) **and** the test suite green. Domain logic (chancing engines, rubric
  scoring) should be pure + unit-tested.
- Emulators idle out between build and install — relaunch and `adb wait-for-device`
  before installing.

## Guardrails specific to this product

- **Never** have Eraly write or substantially draft a student's essay — coach only.
  Watch for ghostwriting bypasses across KZ/RU/EN (e.g. KK "жаз" = "write").
- Keep the LLM key server-side; keep client payloads PII-minimized.
- Honest odds only. No inflated acceptance chances.
- This app is for minors — default to less data collection, on-device storage, and RLS.
