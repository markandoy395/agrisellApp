-- Run as migration owner against a deployed database with two existing profiles.
-- Does not create accounts, change profile values, or return identifying data.
-- Cross-account mutations must affect zero rows; all work is rolled back.
begin;
create temporary table profile_isolation_accounts as
select identity.auth_user_id, identity.user_id
from private.auth_identities identity
join public.users u on u.user_id = identity.user_id
order by identity.user_id limit 2;
grant select on profile_isolation_accounts to authenticated;
do $$ begin
  if (select count(*) from profile_isolation_accounts) <> 2 then
    raise exception 'Two existing profiles required for deployed isolation check';
  end if;
end $$;

set local role authenticated;
do $isolation$
declare
  actor record;
  other_user_id bigint;
  changed integer;
  verified_identity jsonb;
begin
  for actor in select * from profile_isolation_accounts loop
    select user_id into other_user_id from profile_isolation_accounts
      where user_id <> actor.user_id;
    perform set_config('request.jwt.claim.sub', actor.auth_user_id::text, true);
    perform set_config('request.jwt.claims', jsonb_build_object(
      'sub', actor.auth_user_id, 'role', 'authenticated', 'is_anonymous', false)::text, true);
    if not exists (select 1 from public.users where user_id = actor.user_id) then
      raise exception 'Caller cannot read own profile';
    end if;
    if exists (select 1 from public.users where user_id = other_user_id) then
      raise exception 'Cross-account profile read succeeded';
    end if;
    verified_identity := public.current_query_owner();
    if verified_identity->>'auth_user_id' is distinct from actor.auth_user_id::text
      or (verified_identity->>'user_id')::bigint is distinct from actor.user_id then
      raise exception 'Current identity RPC returned another account';
    end if;
    update public.users set first_name = first_name where user_id = other_user_id;
    get diagnostics changed = row_count;
    if changed <> 0 then raise exception 'Cross-account profile update succeeded'; end if;
    begin
      delete from public.users where user_id = other_user_id;
      get diagnostics changed = row_count;
      if changed <> 0 then raise exception 'Cross-account profile delete succeeded'; end if;
    exception when insufficient_privilege then null;
    end;
    perform set_config('request.jwt.claims', jsonb_build_object(
      'sub', actor.auth_user_id, 'role', 'authenticated', 'is_anonymous', true)::text, true);
    if exists (select 1 from public.users where user_id = actor.user_id) then
      raise exception 'Anonymous authenticated JWT can read profiles';
    end if;
    if public.current_query_owner() is not null then
      raise exception 'Anonymous JWT can resolve an application identity';
    end if;
  end loop;
end;
$isolation$;
reset role;
select 'passed' as existing_account_profile_isolation;
rollback;
