Admity

Honest admissions mentor for teens in Kazakhstan.

Admity helps students in grades 8–12 figure out where they can realistically get in — Kazakh and international universities — using real ЕНТ thresholds and real numbers instead of inflated promises. It comes with an AI mentor, Eraly, who coaches you through the process but never writes your essays for you.

Built with Flutter for iOS and Android. Available in Russian, Kazakh and English.

<!-- Add screenshots from appstore/screenshots here -->
Features
Honest chancing. Real ЕНТ score and GPA thresholds per program, with sources. No rounded-up odds.
Universities & scholarships. Catalog of universities in Kazakhstan and abroad, state grant thresholds, tuition, and scholarship matching against your profile. Filter by city, field, price and score.
Eraly, the AI mentor. Answers questions about exams, universities and scholarships; asks guiding questions instead of giving finished answers; proposes calendar events for you to confirm. It reviews structure, ideas and mistakes in your writing, and never drafts an essay for you (this is enforced across KZ / RU / EN, including phrasing that tries to get around it).
Prep plans. Lesson-by-lesson plans for IELTS, SAT and ЕНТ built around your schedule, pointing to free resources.
Career test. A short quiz that feeds into Eraly's recommendations.
Documents. Assemble an application package (transcript, recommendation letters, motivation letter) in the app. Files stay on the device.
Guest mode. Browse the catalog and take the career test without an account. Only the AI mentor requires sign-in.
Offline-first. Local storage is the source of truth; Supabase syncs when configured, and the app degrades gracefully when it isn't.
Privacy by design

Admity is built for minors, so it collects as little as possible.

Data lives on the device by default; server-side access is protected with Postgres Row Level Security.
LLM calls go through a Supabase Edge Function only. The API key is never shipped in the client.
Requests to the model are minimized: no name, email or region, and GPA is sent as a band rather than an exact number.
No ads, no analytics SDKs, no selling data.

See PRIVACY_POLICY.md and HOSTING_POLICY.md.

Tech stack
Area	Choice
Framework	Flutter (Android + iOS)
State	Riverpod 3.x, hand-written providers (no codegen)
Navigation	go_router with StatefulShellRoute.indexedStack
Backend	Supabase: Postgres, Auth, Storage, RLS, Edge Functions
Charts	fl_chart
Animation	Rive
Lints	very_good_analysis
Localization	Flutter l10n (KZ / RU / EN)
App structure

Five tabs: Home, Courses, Eraly (center), Opportunities, Profile. Universities and admission chances live inside Opportunities.

lib/
  core/           # router, theme, shared infrastructure
  shared/         # shared widgets and utilities
  features/
    <feature>/
      data/
      domain/
      presentation/
supabase/         # schema, RLS policies, edge functions
tools/
  scrape_universities/   # scripts for collecting university data
docs/             # design system and other documentation
test/

Features are organized feature-first. Domain logic (chancing engines, rubric scoring) is kept pure and unit-tested.

Getting started
Prerequisites
Flutter 3.41.x (Dart 3.11.x)
Android Studio / Xcode, plus an emulator or device
A Supabase project, if you want sync, auth and the AI mentor (optional for offline and guest mode)
Setup
bash
git clone https://github.com/frsanzhar/AdmityApp.git
cd AdmityApp
flutter pub get
cp env.example.json env.json   # then fill in your Supabase values

See AUTH_SETUP.md for configuring sign-in.

Run
bash
# Android emulator / device
flutter run -d <device-id> --dart-define-from-file=env.json

# Quick check in the browser, offline mode
flutter run -d chrome

Without Supabase configured, the app runs in local-only mode.

Test and analyze
bash
flutter analyze   # must be clean
flutter test
Build
bash
flutter build appbundle   # Google Play
flutter build ios         # App Store

Bundle id: kz.admity.app.

Documentation
CLAUDE.md: product principles, architecture, toolchain notes
PLAN.md: build plan by phase
docs/DESIGN_SYSTEM.md: colors, typography, components
STORE_LISTING.md: App Store listing copy
AUTH_SETUP.md: authentication setup
Toolchain notes
No Riverpod or drift codegen. On the current Flutter SDK, riverpod_generator and drift_dev conflict with the SDK-pinned meta version, so providers are written by hand.
Blank screen usually means a layout error, not a crash. Check layout constraints first (for example CrossAxisAlignment.stretch inside a scroll view).
A huge project folder is just cache. flutter clean brings it back to about 11 MB. The real release APK is about 30 MB.
