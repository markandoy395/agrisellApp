-- Rolled-back smoke check using existing riders; no fixtures or private output.
begin;
do $metadata$
begin
  if pg_get_functiondef('private.api_impl_current_rider_nearby_deliveries(double precision,double precision,double precision,integer)'::regprocedure)
      like '%rider.service_radius_km%' then
    raise exception 'Removed rider radius column is still referenced';
  end if;
  if has_function_privilege('anon',
      'private.api_impl_current_rider_nearby_deliveries(double precision,double precision,double precision,integer)', 'EXECUTE') then
    raise exception 'Anonymous implementation access remains';
  end if;
end;
$metadata$;
create temporary table rider_loading_callers as
select identity.auth_user_id
from private.auth_identities identity
join public.riders rider on rider.rider_id = identity.rider_id
limit 3;
grant select on rider_loading_callers to authenticated;
set local role authenticated;
do $requests$
declare actor record; result jsonb; checked integer := 0;
begin
  for actor in select * from rider_loading_callers loop
    perform set_config('request.jwt.claim.sub', actor.auth_user_id::text, true);
    perform set_config('request.jwt.claims', jsonb_build_object(
      'sub', actor.auth_user_id, 'role', 'authenticated', 'is_anonymous', false,
      'exp', extract(epoch from now()) + 300)::text, true);
    result := public.current_rider_nearby_deliveries(16.4, 120.6, 15, 50);
    if jsonb_typeof(result) <> 'array' or jsonb_array_length(result) > 50 then
      raise exception 'Unexpected rider request result';
    end if;
    checked := checked + 1;
    perform set_config('request.jwt.claims', jsonb_build_object(
      'sub', actor.auth_user_id, 'is_anonymous', true,
      'exp', extract(epoch from now()) + 300)::text, true);
    begin
      perform public.current_rider_nearby_deliveries(16.4, 120.6, 15, 50);
      raise exception 'Anonymous session was accepted';
    exception when insufficient_privilege then null;
    end;
    perform set_config('request.jwt.claims', jsonb_build_object(
      'sub', actor.auth_user_id, 'is_anonymous', false, 'exp', 1)::text, true);
    begin
      perform public.current_rider_nearby_deliveries(16.4, 120.6, 15, 50);
      raise exception 'Expired session was accepted';
    exception when insufficient_privilege then null;
    end;
  end loop;
  if checked = 0 then raise exception 'No existing rider available for smoke check'; end if;
end;
$requests$;
reset role;
select 'passed' as rider_request_loading;
rollback;
