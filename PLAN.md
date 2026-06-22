# Admity — Build Plan

> PM: Opus (this session). Agents: Sonnet 4.6 (`.claude/agents/`).
> Design source of truth: `docs/DESIGN_SYSTEM.md` (Brilliant-style). Architecture: `CLAUDE.md`.
> **Gate after every phase:** `flutter analyze` clean + `flutter test` green. PM reviews before next phase.

> ✅ **ALL PHASES 0–7 COMPLETE** (2026-06-22). analyze clean, 184 tests green. Repo: github.com/frsanzhar/admity-flutter (private).

## Agents
| Agent | Owns |
|---|---|
| `design-system-engineer` | tokens, theme, Onest, base components, MascotSlot, TopicDiagramSlot, AppBottomNav |
| `frontend-screens` | screen layout per §7 |
| `ai-mentor-engineer` | Ералы chat, event proposals, topic plans, Edge Function |
| `backend-supabase` | schema, RLS, local-first storage (Hive/Isar) |
| `motion-animation` | animations (last) |
| `qa-tester` | widget/golden tests + anti-gotcha + §8 anti-slop audit |

## Hard rules (all agents, all phases — §8)
- Colors ONLY from `AppColors`. Font ONLY Onest (with Cyrillic).
- Dark `PrimaryButton` for normal actions; `FeaturedButton` gradient ONLY for featured CTAs.
- Every mascot spot = `MascotSlot` (`// TODO(mascot)`); every 3D spot = `TopicDiagramSlot` (`// TODO(3d)`).
- Scrollable screens: `SafeArea > SingleChildScrollView > Column(mainAxisSize: .min)`. Never stretch-in-scroll.
- Plain Riverpod, NO codegen. One accent per screen.

## Navigation (§5) — DONE
5 tabs wired in `lib/core/router/app_router.dart`:
**Главная** `/home` · **Курсы** `/courses` · **Ералы** `/mentor` (accent center) · **Возможности** `/opportunities` · **Профиль** `/profile`.
(Шансы + Университеты live INSIDE Возможности, not separate tabs.) Temporary stock `NavigationBar`; Phase 1 swaps in `AppBottomNav`.

---

## Phase 0 — Design system  ·  `design-system-engineer`
- [ ] `AppColors` (§1, exact Dart constants), `ctaGradient`.
- [ ] Onest typography with full Cyrillic (§2) + type scale; theme wires it as default.
- [ ] `AppTokens` ThemeExtension (§3 radii/gaps/padding/shadow).
- [ ] `AppScaffold`, `PrimaryButton`, `FeaturedButton`, `AppCard`.
- [ ] `StreakBadge`, `KeyBadge`, `ProgressRing`, `LessonNode`.
- [ ] `MascotSlot` (§6), `TopicDiagramSlot` (§6) — placeholders with TODO markers.
- [ ] `AppBottomNav` (§5, accent center tab).
- [ ] Widget/golden tests for components. **Gate.**

## Phase 1 — Shell + Home  ·  `frontend-screens`
- [ ] App shell uses `AppBottomNav`. Splash `/` structure (§7.1, static + `// TODO(motion)`).
- [ ] Home `/home` (§7.2): greeting + `StreakBadge`, "Задание на сегодня" card, today's to-do list (checkboxes), `MascotSlot`. **Gate.**

## Phase 2 — Courses  ·  `frontend-screens`
- [ ] `/courses` (§7.3): course tabs w/ active underline, today's course/level header, central `TopicDiagramSlot` with swipe-right = pick lesson, vertical `LessonNode` path, bottom box (diagram + title) + `FeaturedButton` "Start the Lesson" → `/lesson`. **Gate.**

## Phase 3 — Lesson  ·  `frontend-screens`
- [ ] `/lesson` (§7.4): intro (display title + illustration) → answer-choice steps (cards, Draw/Check) → ✓/✗ feedback + "Why?" → "Lesson complete!" with XP + `MascotSlot`. **Gate.**

## Phase 4 — Opportunities  ·  `frontend-screens` (+ `backend-supabase` for data)
- [ ] `/opportunities` (§7.6): scholarships + universities; filters (city, field, price, accessibility, docs); scholarship detail (requirements, coverage, how-to, stats + how to reach them); in-app application form; "Мероприятия рядом" + "Идеи проектов". **Gate.**

## Phase 5 — Ералы  ·  `ai-mentor-engineer`
- [ ] `/mentor` (§7.5): chat; event proposals with MANDATORY «Проверить все мероприятия» + flexible per-event time edit → calendar; topic plans (IELTS etc.) via guided questions; server-side Edge Function. **Gate.**

## Phase 6 — Profile  ·  `backend-supabase` (+ `frontend-screens`)
- [ ] `/profile` (§7.7): settings, edit self-data, notes, documents as a "package"; local-first storage (Hive/Isar); optional Supabase sync. **Gate.**

## Phase 7 — Motion (Rive)  ·  `motion-animation`
**Tech: Rive (`rive` package) ONLY — NOT Lottie, NOT hand-coded animations.**
Why: state-driven *interactive* animations driven by Rive **State Machines**, and one `.riv` file works across all platforms (the Brilliant approach).
- [ ] Add `rive` dependency; set up `assets/rive/` + loading helpers.
- [ ] **Mascot** — Rive State Machine swapped into `MascotSlot` (idle / happy / fly-down / celebrate states), replacing the placeholder blob.
- [ ] **Splash light-sweep + fly-up** (§7.1) via a Rive State Machine.
- [ ] **Lesson feedback** ✓/✗ (correct / incorrect states) (§7.4).
- [ ] **Streak** animation (`StreakBadge`).
- [ ] Node-path + swipe transitions where they fit.
- [ ] Drive states from app state (inputs/triggers), not timers. Respect `reduceMotion` (static fallback frame). **Gate.**

> Phase 7 layers Rive OVER finished screens — it does NOT restructure them. `MascotSlot`,
> `TopicDiagramSlot`, and all `// TODO(mascot)` / `// TODO(motion)` placeholders stay AS-IS
> through Phases 0–6; Rive replaces them only in Phase 7.

---
`qa-tester` runs the gate audit at the end of each phase. PM signs off before advancing.
