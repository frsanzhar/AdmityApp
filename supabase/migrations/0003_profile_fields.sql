-- Extend public.profiles with the onboarding fields added to the Profile model
-- after 0001, so the FULL student profile round-trips to Supabase via the
-- client's write-through sync (otherwise an upsert of the whole profile fails
-- on the missing columns). All nullable / defaulted so existing rows are fine.

alter table public.profiles
  add column if not exists dream_field         text,
  add column if not exists english_level       text,
  add column if not exists study_hours_per_day int,
  add column if not exists budget_sensitivity  text,
  add column if not exists motivation          text,
  add column if not exists uses_gpa_calculator boolean not null default false;
