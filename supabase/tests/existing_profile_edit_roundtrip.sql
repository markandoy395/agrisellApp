-- Run as migration owner against existing accounts. No fixtures or permanent
-- changes: all edits roll back. Only a pass result is returned, never row data.
begin;
set local lock_timeout = '3s';
set local statement_timeout = '30s';
create temporary table edit_audit_actors on commit drop as
with candidates as (
  select 'buyer' as account_role, i.auth_user_id,
         i.user_id::text as target_id, i.buyer_user_id as buyer_id,
         row_number() over (order by i.user_id) as position
  from private.auth_identities i join public.users u on u.user_id = i.user_id
  where i.buyer_user_id is not null
  union all
  select 'farmer', i.auth_user_id, i.farmer_user_id::text, null::bigint,
         row_number() over (order by i.farmer_user_id)
  from private.auth_identities i
  join public.farmers f on f.farmer_user_id = i.farmer_user_id
  where i.farmer_user_id is not null
  union all
  select 'rider', i.auth_user_id, i.rider_id::text, null::bigint,
         row_number() over (order by i.rider_id)
  from private.auth_identities i join public.riders r on r.rider_id = i.rider_id
  where i.rider_id is not null
)
select * from candidates where position <= 2;
grant select on edit_audit_actors to authenticated;

do $$ begin
  if exists (
    select role_name from (values ('buyer'), ('farmer'), ('rider')) roles(role_name)
    where (select count(*) from edit_audit_actors a
           where a.account_role = roles.role_name) <> 2
  ) then
    raise exception 'Two existing mapped accounts per role are required';
  end if;
end $$;

set local role authenticated;
do $audit$
declare
  actor record;
  other_id text;
  affected integer;
  visible integer;
  saved_name text;
  literal_name constant text := 'Audit %_* O''Neil; --';
begin
  for actor in select * from edit_audit_actors loop
    select target_id into strict other_id from edit_audit_actors
    where account_role = actor.account_role and target_id <> actor.target_id;
    perform set_config('request.jwt.claim.sub', actor.auth_user_id::text, true);
    perform set_config('request.jwt.claims', jsonb_build_object(
      'sub', actor.auth_user_id, 'role', 'authenticated',
      'exp', extract(epoch from now() + interval '1 hour'),
      'is_anonymous', false)::text, true);

    if actor.account_role = 'buyer' then
      update public.users set first_name = literal_name
      where user_id = actor.target_id::bigint;
      get diagnostics affected = row_count;
      select first_name into saved_name from public.users
      where user_id = actor.target_id::bigint;
      select count(*) into visible from public.users where user_id = other_id::bigint;
    elsif actor.account_role = 'farmer' then
      update public.farmers set first_name = literal_name
      where farmer_user_id = actor.target_id::bigint;
      get diagnostics affected = row_count;
      select first_name into saved_name from public.farmers
      where farmer_user_id = actor.target_id::bigint;
      select count(*) into visible from public.farmers where farmer_user_id = other_id::bigint;
    else
      update public.riders set first_name = literal_name
      where rider_id = actor.target_id::uuid;
      get diagnostics affected = row_count;
      select first_name into saved_name from public.riders
      where rider_id = actor.target_id::uuid;
      select count(*) into visible from public.riders where rider_id = other_id::uuid;
    end if;
    if affected <> 1 or saved_name is distinct from literal_name then
      raise exception 'Owner edit/read-back failed for %', actor.account_role;
    end if;
    if visible <> 0 then
      raise exception 'Cross-account profile read succeeded for %', actor.account_role;
    end if;

    if actor.account_role = 'buyer' then
      update public.users set first_name = literal_name where user_id = other_id::bigint;
    elsif actor.account_role = 'farmer' then
      update public.farmers set first_name = literal_name where farmer_user_id = other_id::bigint;
    else
      update public.riders set first_name = literal_name where rider_id = other_id::uuid;
    end if;
    get diagnostics affected = row_count;
    if affected <> 0 then
      raise exception 'Cross-account profile update succeeded for %', actor.account_role;
    end if;

    begin
      if actor.account_role = 'buyer' then
        delete from public.users where user_id = other_id::bigint;
      elsif actor.account_role = 'farmer' then
        delete from public.farmers where farmer_user_id = other_id::bigint;
      else
        delete from public.riders where rider_id = other_id::uuid;
      end if;
      get diagnostics affected = row_count;
    exception when insufficient_privilege then
      -- A table privilege denial is also an effective delete boundary.
      affected := 0;
    end;
    if affected <> 0 then
      raise exception 'Cross-account profile delete succeeded for %', actor.account_role;
    end if;

    perform set_config('request.jwt.claims', jsonb_build_object(
      'sub', actor.auth_user_id, 'role', 'authenticated',
      'exp', extract(epoch from now() + interval '1 hour'),
      'is_anonymous', true)::text, true);
    if actor.account_role = 'buyer' then
      select count(*) into visible from public.users where user_id = actor.target_id::bigint;
    elsif actor.account_role = 'farmer' then
      select count(*) into visible from public.farmers where farmer_user_id = actor.target_id::bigint;
    else
      select count(*) into visible from public.riders where rider_id = actor.target_id::uuid;
    end if;
    if visible <> 0 then
      raise exception 'Anonymous authenticated profile access succeeded for %', actor.account_role;
    end if;
  end loop;
end;
$audit$;
reset role;
select 'passed: owner literal name edit/read-back, cross-account read/update/delete denial, anonymous session read denial; all edits rolled back' as result;
rollback;
