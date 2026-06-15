-- Cloud-sync support for the rest of the student data + Supabase Realtime.
--
-- (1) Unique keys so the client can upsert (PostgREST ON CONFLICT needs a
--     unique index/constraint). Idempotent via `create unique index if not
--     exists`. intensive_progress / college_list already declare their unique
--     keys in 0001; profiles uses its user_id PK; personal_notes & chat_messages
--     are replace/insert-only and need none.
create unique index if not exists ent_scores_user_key
  on public.ent_scores (user_id);

create unique index if not exists career_results_user_key
  on public.career_results (user_id);

create unique index if not exists essays_user_kind_key
  on public.essays (user_id, kind);

create unique index if not exists chat_threads_user_key
  on public.chat_threads (user_id);

-- (2) Columns the local models need to round-trip.
--   career_results stores the DERIVED result; the client also needs the raw
--   answers to rebuild local state and re-score deterministically.
alter table public.career_results
  add column if not exists raw_answers jsonb;

--   gap_tasks ids are deterministic client strings (not uuids); keep them so
--   done-state survives a round-trip and regenerate() can match by id.
alter table public.gap_tasks
  add column if not exists client_id text;

create unique index if not exists gap_tasks_user_client_key
  on public.gap_tasks (user_id, client_id);

-- (3) Realtime: enable full row images + add every student table to the
--     supabase_realtime publication so other devices get live updates. Fully
--     idempotent so re-running the migration is safe.
do $$
declare
  t text;
  student_tables text[] := array[
    'profiles','personal_notes','ent_scores','career_results','gap_tasks',
    'intensive_progress','college_list','essays','chat_threads','chat_messages'
  ];
begin
  foreach t in array student_tables loop
    -- Full replica identity so UPDATE/DELETE realtime payloads carry the row
    -- (needed for the user_id filter to match on deletes).
    execute format('alter table public.%I replica identity full;', t);

    if exists (select 1 from pg_publication where pubname = 'supabase_realtime')
       and not exists (
         select 1 from pg_publication_tables
         where pubname = 'supabase_realtime'
           and schemaname = 'public'
           and tablename = t
       )
    then
      execute format(
        'alter publication supabase_realtime add table public.%I;', t
      );
    end if;
  end loop;
end $$;
