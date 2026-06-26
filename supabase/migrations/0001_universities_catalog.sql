-- Admity — universities catalog (honest admissions reference for Kazakhstan).
--
-- Design notes:
--   * Normalised: вуз ↔ ГОП (education program) ↔ offering ↔ threshold.
--   * "Honest chancing": grant cutoffs live in `grant_thresholds`, every row
--     carries `source_url` + `is_verified` so nothing is shown as fact until a
--     human/scraper has cited a primary source. Never fabricate a score.
--   * In KZ the grant competition is largely NATIONAL per-ГОП, so
--     `grant_thresholds.university_id` is NULLABLE: NULL = national ГОП cutoff,
--     non-null = a university-specific admitted range when that detail exists.
--   * Clients read only (RLS select=true). Writes go through the service role
--     (migrations / import script), which bypasses RLS — no anon write policy.
--
-- This is the server master copy. The app ships the same data as an offline
-- JSON asset (assets/data/universities.json) generated from these tables, so
-- guest/offline mode works with no network (see docs/UNIVERSITIES_DATA.md).

-- ── universities ──────────────────────────────────────────────────────────────
create table if not exists public.universities (
  id            text primary key,                 -- slug: 'nu', 'kbtu', 'kaznu'
  name_ru       text not null,
  name_kz       text,
  name_en       text,
  city          text not null,
  type          text                               -- null = not confidently known
                  check (type is null or type in ('national','state','autonomous',
                                                  'private','international')),
  website       text,
  has_dormitory boolean,
  description   text,
  source_url    text,                              -- provenance
  updated_at    timestamptz not null default now()
);

-- ── education_programs (ГОП — группы образовательных программ) ────────────────
create table if not exists public.education_programs (
  code                  text primary key,          -- 'B057'
  name_ru               text not null,
  name_kz               text,
  field                 text,                       -- maps to Dart AcademicField
  ent_profile_subject_1 text,                       -- профильный предмет 1
  ent_profile_subject_2 text,                       -- профильный предмет 2
  source_url            text,
  updated_at            timestamptz not null default now()
);

-- ── university_programs (offering: which вуз teaches which ГОП) ───────────────
create table if not exists public.university_programs (
  id                   bigint generated always as identity primary key,
  university_id        text not null references public.universities(id)
                          on delete cascade,
  program_code         text not null references public.education_programs(code)
                          on delete cascade,
  tuition_per_year_kzt integer,                     -- платное, тг/год; null=unknown
  languages            text[],                      -- {'ru','kz','en'}
  grant_places         integer,                     -- грант-места, если известно
  source_url           text,
  updated_at           timestamptz not null default now(),
  unique (university_id, program_code)
);

-- ── grant_thresholds (пороговые / проходные баллы) ───────────────────────────
create table if not exists public.grant_thresholds (
  id            bigint generated always as identity primary key,
  program_code  text not null references public.education_programs(code)
                  on delete cascade,
  university_id text references public.universities(id) on delete cascade, -- null=national
  year          integer not null,
  quota_type    text not null default 'general'
                  check (quota_type in ('general','rural','lyceum','orphan',
                                        'disability','oralman','other')),
  -- WHAT the score means — these are distinct concepts in KZ and must not be
  -- conflated: 'cutoff' = проходной (последний зачисленный на грант, итог
  -- конкурса); 'competition_min' = минимальный балл для допуска к конкурсу;
  -- 'paid_min' = минимум на платное; 'national_floor' = пороговый минимум приказа.
  metric        text not null default 'cutoff'
                  check (metric in ('cutoff','competition_min',
                                    'paid_min','national_floor')),
  min_score     integer,
  max_score     integer,
  is_verified   boolean not null default false,     -- честность: сверено с первоисточником
  source_url    text not null,
  note          text,
  updated_at    timestamptz not null default now(),
  unique (program_code, university_id, year, quota_type, metric)
);

create index if not exists grant_thresholds_program_year_idx
  on public.grant_thresholds (program_code, year);
create index if not exists university_programs_university_idx
  on public.university_programs (university_id);

-- ── RLS: public read, no public write ────────────────────────────────────────
alter table public.universities        enable row level security;
alter table public.education_programs   enable row level security;
alter table public.university_programs  enable row level security;
alter table public.grant_thresholds     enable row level security;

create policy "public read universities"        on public.universities
  for select using (true);
create policy "public read education_programs"  on public.education_programs
  for select using (true);
create policy "public read university_programs" on public.university_programs
  for select using (true);
create policy "public read grant_thresholds"    on public.grant_thresholds
  for select using (true);
-- No insert/update/delete policies for anon: writes only via service role.
