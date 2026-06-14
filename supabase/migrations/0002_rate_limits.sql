-- Admity — per-user rate limiting for the `eraly` Edge Function (U5).
--
-- The Edge Function calls bump_rate_limit() once per scope ("minute"/"day")
-- per request. The function is SECURITY DEFINER and the table denies all
-- client access via RLS, so a counter can never be read or tampered with from
-- the app — only the server-side function (and the service role) touch it.
--
-- Buckets are coarse text keys so a single upsert is race-safe under a unique
-- index:  minute -> 'yyyy-MM-ddTHH:mm', day -> 'yyyy-MM-dd'.

create table if not exists public.rate_limits (
  user_id     uuid not null references auth.users(id) on delete cascade,
  scope       text not null check (scope in ('minute', 'day')),
  bucket      text not null,
  count       int  not null default 0,
  updated_at  timestamptz not null default now(),
  primary key (user_id, scope, bucket)
);

-- Cheap reclamation of stale rows (old minute/day buckets pile up otherwise).
create index if not exists rate_limits_updated_at_idx
  on public.rate_limits (updated_at);

-- RLS: enable with NO policies => every client (anon/authenticated) is denied.
-- A SECURITY DEFINER function and the service role still bypass this.
alter table public.rate_limits enable row level security;

-- Atomically increment and return the new count for (user, scope, bucket).
-- SECURITY DEFINER lets the server bump counters without granting the client
-- any direct table access. search_path is pinned to defeat hijacking.
create or replace function public.bump_rate_limit(
  p_user_id uuid,
  p_scope   text,
  p_bucket  text
) returns int
language plpgsql
security definer
set search_path = public, pg_temp
as $$
declare
  new_count int;
begin
  insert into public.rate_limits as r (user_id, scope, bucket, count, updated_at)
    values (p_user_id, p_scope, p_bucket, 1, now())
  on conflict (user_id, scope, bucket) do update
    set count = r.count + 1,
        updated_at = now()
  returning r.count into new_count;

  return new_count;
end;
$$;

-- Only the service role may invoke the bumper; nothing client-facing can.
revoke all on function public.bump_rate_limit(uuid, text, text) from public;
revoke all on function public.bump_rate_limit(uuid, text, text) from anon;
revoke all on function public.bump_rate_limit(uuid, text, text) from authenticated;
grant execute on function public.bump_rate_limit(uuid, text, text)
  to service_role;
