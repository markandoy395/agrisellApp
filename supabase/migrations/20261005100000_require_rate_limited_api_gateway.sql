begin;

-- Shared counters already exist and are consumed in separate committed service
-- requests. This avoids GET read-only transactions and failed-request rollback.
alter table private.admin_rate_limit_buckets enable row level security;
revoke all on private.admin_rate_limit_buckets from public, anon, authenticated;
revoke all on function public.admin_consume_rate_limit(text, text, integer, integer)
  from public, anon, authenticated;
grant execute on function public.admin_consume_rate_limit(text, text, integer, integer)
  to service_role;

create table private.api_gateway_configuration (
  singleton boolean primary key default true check (singleton),
  secret_hash text check (secret_hash ~ '^[0-9a-f]{64}$'),
  enforced boolean not null default false,
  check (not enforced or secret_hash is not null)
);
insert into private.api_gateway_configuration(singleton) values (true);
alter table private.api_gateway_configuration enable row level security;
revoke all on private.api_gateway_configuration from public, anon, authenticated;
grant select, insert, update on private.api_gateway_configuration to service_role;
create policy application_table_requires_login on private.api_gateway_configuration
as restrictive for all to public
using ((select auth.role()) = 'service_role' or (
  (select auth.uid()) is not null and
  coalesce((select auth.jwt())->>'is_anonymous', 'false') = 'false'))
with check ((select auth.role()) = 'service_role' or (
  (select auth.uid()) is not null and
  coalesce((select auth.jwt())->>'is_anonymous', 'false') = 'false'));
create policy application_default_owner_boundary on private.api_gateway_configuration
as restrictive for all to authenticated using (false) with check (false);

create function public.require_rate_limited_gateway()
returns void language plpgsql security definer set search_path = '' as $$
declare
  configuration private.api_gateway_configuration%rowtype;
  supplied text;
begin
  if (select auth.role()) = 'service_role' then return; end if;
  if (select auth.uid()) is null or
    coalesce((select auth.jwt())->>'is_anonymous', 'false') <> 'false' then
    raise sqlstate 'PT401' using message = 'Authentication required';
  end if;
  select * into configuration from private.api_gateway_configuration where singleton;
  -- Staged rollout: enable only after the gateway secret and function deployment
  -- are verified and a compatible client is ready. No client can change this row.
  if not found then
    raise sqlstate 'PT503' using message = 'API protection is unavailable';
  end if;
  if not configuration.enforced then return; end if;
  supplied := coalesce(nullif(current_setting('request.headers', true), ''), '{}')::jsonb
    ->>'x-agrisell-api-gateway';
  if supplied is null or length(supplied) > 256 or
    encode(extensions.digest(supplied, 'sha256'), 'hex') <> configuration.secret_hash then
    raise sqlstate 'PT403' using message = 'Use the authenticated application API';
  end if;
end;
$$;
revoke all on function public.require_rate_limited_gateway() from public, anon;
grant execute on function public.require_rate_limited_gateway() to authenticated, service_role;

-- Preserve an independently configured pre-request contract rather than silently
-- replacing it. Only this project's known hook may be replaced on later runs.
do $$
begin
  if exists (select 1 from pg_db_role_setting s join pg_roles r on r.oid = s.setrole,
    lateral unnest(s.setconfig) setting
    where r.rolname = 'authenticator' and setting like 'pgrst.db_pre_request=%'
    and setting not in ('pgrst.db_pre_request=',
      'pgrst.db_pre_request=public.require_rate_limited_gateway')) then
    raise exception 'Existing API pre-request hook requires explicit composition';
  end if;
end;
$$;
alter role authenticator set pgrst.db_pre_request = 'public.require_rate_limited_gateway';

-- The app has no GraphQL client. Deny this alternate Data API entry point so it
-- cannot bypass the gateway; add a checked relay before enabling it in future.
revoke usage on schema graphql_public from public, anon, authenticated;
revoke execute on all functions in schema graphql_public from public, anon, authenticated;

notify pgrst, 'reload config';
notify pgrst, 'reload schema';
commit;
