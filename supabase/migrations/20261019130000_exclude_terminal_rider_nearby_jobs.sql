begin;
-- Preserve authentication, ownership, distance checks, and the bounded response.
-- History remains available through current_rider_deliveries(false).
do $migration$
declare
  body text := pg_get_functiondef(
    'private.api_impl_current_rider_nearby_deliveries(double precision,double precision,double precision,integer)'::regprocedure
  );
  old_fragment constant text := ') as item
    ), pickup_coordinates as (';
  new_fragment constant text := ') as item
      where item ->> ''delivery_status'' not in (''completed'',''cancelled'',''failed'')
    ), pickup_coordinates as (';
begin
  if position('where item ->> ''delivery_status'' not in' in body) > 0 then return; end if;
  if position(old_fragment in body) = 0 then
    raise exception 'Nearby rider query changed; review before applying';
  end if;
  execute replace(body, old_fragment, new_fragment);
end;
$migration$;
notify pgrst, 'reload schema';
commit;
