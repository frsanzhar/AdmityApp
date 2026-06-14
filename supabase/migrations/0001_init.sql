-- Admity initial schema + Row-Level Security.
-- Reference tables (universities, scholarships, ent_cutoffs, cds_snapshots,
-- intensives) are world-readable by authenticated users and writable only by
-- the service role. Every table with student data is locked to its owner via
-- auth.uid() = user_id — critical for minors' privacy.

-- ──────────────────────────────────────────────────────────────────────────
-- Student data
-- ──────────────────────────────────────────────────────────────────────────

create table if not exists public.profiles (
  user_id     uuid primary key references auth.users(id) on delete cascade,
  full_name   text,
  region      text,
  grade       int,
  locale      text,
  gpa         numeric,
  target_geo  text[] not null default '{}',
  interests   text[] not null default '{}',
  onboarded   boolean not null default false,
  created_at  timestamptz not null default now()
);

create table if not exists public.personal_notes (
  id          uuid primary key default gen_random_uuid(),
  user_id     uuid not null references auth.users(id) on delete cascade,
  content     text not null,
  created_at  timestamptz not null default now()
);

create table if not exists public.career_results (
  id                    uuid primary key default gen_random_uuid(),
  user_id               uuid not null references auth.users(id) on delete cascade,
  riasec_code           text,
  riasec_scores         jsonb,
  big_five              jsonb,
  recommended_clusters  jsonb,
  taken_at              timestamptz not null default now()
);

create table if not exists public.ent_scores (
  id                uuid primary key default gen_random_uuid(),
  user_id           uuid not null references auth.users(id) on delete cascade,
  history           int,
  math_literacy     int,
  reading_literacy  int,
  profile1_subject  text,
  profile1_score    int,
  profile2_subject  text,
  profile2_score    int,
  total             int,
  is_predicted      boolean not null default false,
  updated_at        timestamptz not null default now()
);

create table if not exists public.college_list (
  id              uuid primary key default gen_random_uuid(),
  user_id         uuid not null references auth.users(id) on delete cascade,
  university_slug text not null,
  category        text,
  status          text,
  notes           text,
  unique (user_id, university_slug)
);

create table if not exists public.gap_tasks (
  id                    uuid primary key default gen_random_uuid(),
  user_id               uuid not null references auth.users(id) on delete cascade,
  title                 text not null,
  description           text,
  due_date              date,
  linked_intensive_slug text,
  is_done               boolean not null default false
);

create table if not exists public.intensive_progress (
  id              uuid primary key default gen_random_uuid(),
  user_id         uuid not null references auth.users(id) on delete cascade,
  intensive_slug  text not null,
  current_day     int not null default 1,
  xp              int not null default 0,
  streak_count    int not null default 0,
  streak_freezes  int not null default 2,
  last_active     timestamptz,
  completed_days  jsonb not null default '[]',
  unique (user_id, intensive_slug)
);

create table if not exists public.essays (
  id               uuid primary key default gen_random_uuid(),
  user_id          uuid not null references auth.users(id) on delete cascade,
  kind             text not null,
  draft_text       text,
  rubric_feedback  jsonb,
  updated_at       timestamptz not null default now()
);

create table if not exists public.chat_threads (
  id          uuid primary key default gen_random_uuid(),
  user_id     uuid not null references auth.users(id) on delete cascade,
  title       text,
  created_at  timestamptz not null default now()
);

create table if not exists public.chat_messages (
  id          uuid primary key default gen_random_uuid(),
  thread_id   uuid not null references public.chat_threads(id) on delete cascade,
  user_id     uuid not null references auth.users(id) on delete cascade,
  role        text not null check (role in ('user','eraly')),
  content     text not null,
  created_at  timestamptz not null default now()
);

-- ──────────────────────────────────────────────────────────────────────────
-- Reference data (read-only for students)
-- ──────────────────────────────────────────────────────────────────────────

create table if not exists public.universities (
  slug                    text primary key,
  name                    text not null,
  country                 text not null,
  scope                   text not null check (scope in ('kz','world')),
  ranking                 int,
  tuition                 text,
  languages               text[] not null default '{}',
  programs                text[] not null default '{}',
  fin_aid_notes           text,
  is_need_blind_full_need boolean not null default false,
  cds_university_key      text
);

create table if not exists public.scholarships (
  slug                 text primary key,
  name                 text not null,
  country              text not null,
  levels               text[] not null default '{}',
  covers               text[] not null default '{}',
  deadline             text,
  eligibility          text,
  source_url           text,
  year                 int,
  requires_work_years  int not null default 0,
  age_max              int,
  requires_kz_citizen  boolean not null default false,
  note                 text
);

create table if not exists public.ent_cutoffs (
  id            uuid primary key default gen_random_uuid(),
  university    text not null,
  specialty     text not null,
  year          int not null,
  gov_threshold int not null,
  real_cutoff   int
);

create table if not exists public.cds_snapshots (
  university       text not null,
  year             int not null,
  acceptance_rate  numeric not null,
  sat_25           int,
  sat_75           int,
  act_25           int,
  act_75           int,
  gpa_avg          numeric,
  factors          jsonb not null default '{}',
  primary key (university, year)
);

create table if not exists public.intensives (
  slug         text primary key,
  title        text not null,
  description  text,
  days         jsonb not null default '[]'
);

-- ──────────────────────────────────────────────────────────────────────────
-- Row-Level Security
-- ──────────────────────────────────────────────────────────────────────────

-- Student-owned tables: only the owner can see/modify their rows.
do $$
declare t text;
begin
  foreach t in array array[
    'profiles','personal_notes','career_results','ent_scores','college_list',
    'gap_tasks','intensive_progress','essays','chat_threads','chat_messages'
  ]
  loop
    execute format('alter table public.%I enable row level security;', t);
    execute format($f$
      create policy %1$s_owner_select on public.%1$I
        for select using (auth.uid() = user_id);
    $f$, t);
    execute format($f$
      create policy %1$s_owner_modify on public.%1$I
        for all using (auth.uid() = user_id) with check (auth.uid() = user_id);
    $f$, t);
  end loop;
end $$;

-- Reference tables: readable by any authenticated user; writes via service role.
do $$
declare t text;
begin
  foreach t in array array[
    'universities','scholarships','ent_cutoffs','cds_snapshots','intensives'
  ]
  loop
    execute format('alter table public.%I enable row level security;', t);
    execute format($f$
      create policy %1$s_read on public.%1$I
        for select to authenticated using (true);
    $f$, t);
  end loop;
end $$;
