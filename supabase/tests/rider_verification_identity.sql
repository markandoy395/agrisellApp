-- Existing-profile regression only. All changes are rolled back.
begin;
-- Gateway behavior is verified separately through authenticated HTTP calls.
-- This local transaction change allows SQL callers to exercise owner guards.
update private.api_gateway_configuration set enforced = false where singleton;
create temporary table verification_callers on commit drop as
select i.auth_user_id, i.rider_id from private.auth_identities i
join public.riders r using (rider_id) order by i.auth_user_id limit 2;
grant select on verification_callers to authenticated;
do $$ begin
  if (select count(*) from verification_callers) <> 2 then
    raise exception 'Two existing rider profiles are required';
  end if;
end $$;
set local role authenticated;
do $audit$
declare actor record; result jsonb;
begin
  for actor in select * from verification_callers loop
    perform set_config('request.jwt.claim.sub', actor.auth_user_id::text, true);
    perform set_config('request.jwt.claims', jsonb_build_object(
      'sub', actor.auth_user_id, 'role', 'authenticated', 'is_anonymous', false,
      'exp', extract(epoch from now()) + 300)::text, true);
    result := public.current_rider_verification_details();
    if result ->> 'rider_id' is distinct from actor.rider_id::text
      or result ->> 'found' is distinct from 'true' then
      raise exception 'Verification RPC did not return the caller profile';
    end if;
    if exists (select 1 from jsonb_array_elements(result -> 'documents') doc
      where not exists (select 1 from public.rider_documents d
        where d.document_id::text = doc ->> 'document_id'
          and d.rider_id = actor.rider_id)) then
      raise exception 'Verification returned a non-owner document';
    end if;
    perform set_config('request.jwt.claims', jsonb_build_object(
      'sub', actor.auth_user_id, 'role', 'authenticated', 'is_anonymous', true,
      'exp', extract(epoch from now()) + 300)::text, true);
    begin
      perform public.current_rider_verification_details();
      raise exception 'Anonymous verification access succeeded';
    exception when insufficient_privilege then null;
    end;
    perform set_config('request.jwt.claims', jsonb_build_object(
      'sub', actor.auth_user_id, 'role', 'authenticated', 'is_anonymous', false,
      'exp', 1)::text, true);
    begin
      perform public.current_rider_verification_details();
      raise exception 'Expired verification access succeeded';
    exception when insufficient_privilege then null;
    end;
  end loop;
end;
$audit$;
reset role;
select 'passed' as rider_verification_identity;
rollback;
