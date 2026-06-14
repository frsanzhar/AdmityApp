# Admity — Supabase backend

This folder holds the database schema, seed data, and the `eraly` Edge Function.
The Flutter app runs fully **offline-light without any of this** (bundled seed +
local JSON store). Set it up when you want real auth, cross-device sync, and the
live Eraly chat.

## Prerequisites

```bash
# Install the Supabase CLI (macOS)
brew install supabase/tap/supabase

# Log in and link to your project (get the ref from the dashboard URL)
supabase login
supabase link --project-ref YOUR-PROJECT-REF
```

## 1. Apply the schema + RLS

```bash
supabase db push                      # applies all migrations/*.sql
# or paste each migrations/000N_*.sql into the dashboard SQL editor in order
```

This runs:

- `migrations/0001_init.sql` — schema + Row-Level Security.
- `migrations/0002_rate_limits.sql` — the `rate_limits` table and the
  `bump_rate_limit()` SECURITY DEFINER function used by the Eraly function for
  per-user rate limiting (see step 3).

Every student table (`profiles`, `personal_notes`, `ent_scores`, …) has
**Row-Level Security** so a row is only ever visible to `auth.uid() = user_id`.
Reference tables (`universities`, `scholarships`, `ent_cutoffs`,
`cds_snapshots`, `intensives`) are read-only for authenticated users. The
`rate_limits` table has RLS enabled with **no policies**, so the client can
never read or write it — only the server-side `bump_rate_limit()` function
(SECURITY DEFINER) and the service role touch it.

## 2. Seed the reference data

```bash
psql "$DATABASE_URL" -f seed.sql      # or paste seed.sql in the SQL editor
```

## 3. Deploy the Eraly Edge Function

The LLM key lives **only** here — never in the app.

```bash
# Secrets (server-side only)
supabase secrets set ANTHROPIC_API_KEY=sk-ant-...
supabase secrets set ERALY_MODEL=claude-sonnet-4-6   # optional; opus-4-8 for max quality
supabase secrets set ALLOWED_ORIGINS=https://app.example.com  # optional; see "CORS" below

# Deploy
supabase functions deploy eraly
```

`SUPABASE_URL`, `SUPABASE_ANON_KEY`, and `SUPABASE_SERVICE_ROLE_KEY` are
**auto-injected** by the platform into every Edge Function — you do not set
them yourself. The function uses the anon key + the caller's `Authorization`
header to verify the JWT, and the service-role key only to bump the rate-limit
counters (never returned to the client).

The app calls it via `supabase.functions.invoke('eraly')` (see
`lib/core/ai/eraly_client.dart`). The function embeds the full Eraly system
prompt (identity, the "I guide, I don't do the work" principle, honest-chancing
rules, sub-agent coordination) and calls the Anthropic Messages API.

### Security hardening (U5)

The function is locked down so it cannot be abused as an open LLM proxy:

- **Requires authentication.** Every call must carry a valid Supabase Auth JWT
  (`Authorization: Bearer <jwt>`). The function validates it via
  `auth.getUser()` and binds the request to the authenticated `user_id`.
  Missing/invalid tokens get `401`. `supabase.functions.invoke` attaches the
  signed-in user's JWT automatically, so the mobile app needs no changes — but
  Eraly chat now requires the user to be signed in.
- **Rate limiting.** Per user: ~20 requests/minute and ~200/day, counted via
  `bump_rate_limit()` (migration `0002_rate_limits.sql`). Over-limit calls get
  `429`. Counters fail open on a transient DB error so a blip never blocks a
  student mid-chat.
- **Body cap.** Requests larger than 16 KB get `413`.
- **CORS allowlist.** `Access-Control-Allow-Origin` is no longer `*`. Browser
  origins are denied by default; set `ALLOWED_ORIGINS` (comma-separated) to
  permit specific web origins. The native mobile app sends no `Origin` header,
  so it is unaffected by the allowlist and keeps working without setting it.
- **PII minimization.** The client (`eraly_client.dart`) strips the student's
  full name and exact region/city and coarsens GPA into a band before sending
  the profile to the function; the function never adds the user id to the
  prompt. Only non-identifying signal (grade, interests, target geos, GPA band,
  dream field) reaches Anthropic.

## 4. Point the app at Supabase

Create `env.json` in the project root (gitignored) and run:

```bash
flutter run --dart-define-from-file=env.json
```

```json
{
  "SUPABASE_URL": "https://YOUR-REF.supabase.co",
  "SUPABASE_ANON_KEY": "eyJhbGciOi..."
}
```

With these set you'll see `Supabase initialized.` in the logs, the Auth screen's
magic-link button activates, and Eraly chat talks to the live function instead of
the offline fallback.
