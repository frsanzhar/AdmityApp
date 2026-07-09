-- App-side profile sync: stores the client's StudentProfile JSON per user.
-- Kept separate from the legacy `profiles` (CDS) table to avoid a schema clash.
-- (Applied to the live project on 2026-06-29; this file mirrors it for repro.)

create table if not exists public.app_profiles (
  id uuid primary key references auth.users(id) on delete cascade,
  email text,
  data jsonb not null default '{}'::jsonb,
  updated_at timestamptz not null default now()
);
alter table public.app_profiles add column if not exists email text;

alter table public.app_profiles enable row level security;

drop policy if exists "app_profiles_select_own" on public.app_profiles;
create policy "app_profiles_select_own"
  on public.app_profiles for select
  using (auth.uid() = id);

drop policy if exists "app_profiles_insert_own" on public.app_profiles;
create policy "app_profiles_insert_own"
  on public.app_profiles for insert
  with check (auth.uid() = id);

drop policy if exists "app_profiles_update_own" on public.app_profiles;
create policy "app_profiles_update_own"
  on public.app_profiles for update
  using (auth.uid() = id)
  with check (auth.uid() = id);

-- Auto-create an empty app_profiles row on new signup.
create or replace function public.handle_new_app_user()
returns trigger
language plpgsql
security definer
set search_path = public
as $$
begin
  insert into public.app_profiles (id, data)
  values (new.id, '{}'::jsonb)
  on conflict (id) do nothing;
  return new;
end;
$$;

drop trigger if exists on_auth_user_created_app on auth.users;
create trigger on_auth_user_created_app
  after insert on auth.users
  for each row execute function public.handle_new_app_user();
