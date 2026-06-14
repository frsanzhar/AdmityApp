-- 0003_revoke_rls_auto_enable.sql
--
-- Security hardening (idempotent).
--
-- `public.rls_auto_enable()` is an event-trigger function that auto-enables RLS
-- on newly created `public` tables. It is SECURITY DEFINER and was callable by
-- the `anon`/`authenticated` roles via the REST RPC surface, which triggers the
-- Supabase security advisor (0028/0029). It never needs to be called from the
-- API — the event trigger fires on DDL as its owner regardless of EXECUTE
-- grants — so we revoke direct EXECUTE. Behavior of the trigger is unchanged.
--
-- Safe to run multiple times.

do $$
begin
  if exists (
    select 1 from pg_proc p
    join pg_namespace n on n.oid = p.pronamespace
    where n.nspname = 'public' and p.proname = 'rls_auto_enable'
  ) then
    revoke execute on function public.rls_auto_enable()
      from anon, authenticated, public;
  end if;
end
$$;
