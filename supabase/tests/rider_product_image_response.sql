-- Read-only rolled-back checks using existing accounts; no synthetic fixtures.
begin;
do $$
declare identity record; response jsonb; item jsonb;
begin
  for identity in
    select distinct ids.auth_user_id, ids.rider_id
    from private.auth_identities ids
    join private.rider_delivery_assignments assignment on assignment.rider_id=ids.rider_id
    where ids.auth_user_id is not null limit 3
  loop
    perform set_config('request.jwt.claims', jsonb_build_object(
      'sub',identity.auth_user_id,'role','authenticated','is_anonymous',false,
      'exp',extract(epoch from now()+interval '5 minutes'))::text,true);
    response := private.current_rider_deliveries(false);
    for item in select value from jsonb_array_elements(response) loop
      if not exists(select 1 from private.rider_delivery_assignments a
        where a.delivery_id=(item->>'delivery_id')::bigint and a.rider_id=identity.rider_id)
        or not item ? 'product_image_url' then
        raise exception 'Invalid assigned rider response';
      end if;
    end loop;
  end loop;
  perform set_config('request.jwt.claims','{"role":"anon"}',true);
  begin
    perform private.current_rider_deliveries(true);
    raise exception 'Missing session unexpectedly allowed';
  exception when insufficient_privilege then null;
  end;
end;
$$;
rollback;
