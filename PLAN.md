# Admity — Build Plan

> PM: Opus (this session). Agents: Sonnet 4.6 (`.claude/agents/`).
> Design source of truth: `docs/DESIGN_SYSTEM.md` (Brilliant-style). Architecture: `CLAUDE.md`.
> **Gate after every phase:** `flutter analyze` clean + `flutter test` green. PM reviews before next phase.

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

## Phase 7 — Motion  ·  `motion-animation`
- [ ] Splash light-sweep + fly-up; mascot fly-down on lesson start; lesson-complete celebration; node-path + swipe transitions. Respect reduceMotion. **Gate.**

---
`qa-tester` runs the gate audit at the end of each phase. PM signs off before advancing.
