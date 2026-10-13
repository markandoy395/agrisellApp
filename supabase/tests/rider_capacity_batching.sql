-- After deployment, run as migration owner. Reads metadata and existing records;
-- no synthetic accounts and no persistent changes.
begin;
do $$
begin
  if exists(select 1 from public.riders where lower(vehicle_type)='motorcycle'
    and maximum_capacity_kg is distinct from 30) then
    raise exception 'Motorcycle ceiling is not configured';
  end if;
  if has_function_privilege('anon','public.set_current_rider_capacity(numeric)','EXECUTE') then
    raise exception 'Anonymous capacity RPC access';
  end if;
  if has_function_privilege('authenticated','private.validate_rider_cargo_capacity(bigint,uuid)','EXECUTE') then
    raise exception 'Capacity implementation exposed';
  end if;
  if has_column_privilege('authenticated','public.riders','maximum_capacity_kg','UPDATE')
    or has_column_privilege('authenticated','public.riders','maximum_active_deliveries','UPDATE') then
    raise exception 'Rider can edit protected limits';
  end if;
  if position('private.validate_rider_cargo_capacity' in
    pg_get_functiondef('private.validate_delivery_batch_acceptance(bigint,uuid)'::regprocedure))=0 then
    raise exception 'Acceptance capacity check missing';
  end if;
end;
$$;
rollback;
