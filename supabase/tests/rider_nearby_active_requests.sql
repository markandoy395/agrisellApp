-- Rolled-back check using existing riders; does not create or change fixtures.
begin;
create temporary table nearby_callers on commit drop as
select i.auth_user_id, r.gps_lat, r.gps_long from private.auth_identities i
join public.riders r using (rider_id)
where r.gps_lat is not null and r.gps_long is not null limit 3;
grant select on nearby_callers to authenticated;
set local role authenticated;
do $audit$
declare actor record; result jsonb; checked integer := 0;
begin
  for actor in select * from nearby_callers loop
    perform set_config('request.jwt.claim.sub', actor.auth_user_id::text, true);
    perform set_config('request.jwt.claims', jsonb_build_object(
      'sub', actor.auth_user_id, 'role', 'authenticated', 'is_anonymous', false,
      'exp', extract(epoch from now()) + 300)::text, true);
    result := public.current_rider_nearby_deliveries(actor.gps_lat, actor.gps_long, 15, 50);
    if jsonb_typeof(result) <> 'array' or jsonb_array_length(result) > 50 then
      raise exception 'Nearby response exceeded its bound';
    end if;
    if exists (select 1 from jsonb_array_elements(result) item
      where item ->> 'delivery_status' in ('completed','cancelled','failed')) then
      raise exception 'Terminal history consumed a nearby delivery slot';
    end if;
    checked := checked + 1;
  end loop;
  if checked = 0 then raise exception 'An existing rider with coordinates is required'; end if;
end;
$audit$;
reset role;
select 'passed' as rider_nearby_active_requests;
rollback;
