begin;

-- Preserve stable RPC signatures and their existing invoker wrappers while
-- hardening the privileged implementations moved by the September migration.
do $rpc_ownership$
declare
  target record;
  definition text;
  hardened text;
  safety_guarded boolean := false;
  sales_guarded boolean := false;
begin
  for target in select p.oid, p.proname, pg_get_functiondef(p.oid) as definition
    from pg_proc p join pg_namespace n on n.oid = p.pronamespace
    where n.nspname in ('public', 'private') and p.prokind = 'f' and p.prosecdef
      and p.proname in ('submit_safety_incident',
        'api_impl_20260925_submit_safety_incident', 'farmer_load_sales',
        'api_impl_20260925_farmer_load_sales')
  loop
    definition := target.definition;
    if target.proname like '%submit_safety_incident' then
      safety_guarded := true;
      hardened := replace(definition,
        '  returning * into saved_incident;',
        '  where public.rider_incidents.reporter_auth_id = current_user_id'
        || E'\n  returning * into saved_incident;\n'
        || '  if not found then raise exception ''Report not owned by this account'' '
        || 'using errcode = ''42501''; end if;');
    else
      sales_guarded := true;
      hardened := replace(definition, 'where sale.farm_id = p_farm_id',
        'where sale.farm_id = p_farm_id and private.owns_farm(p_farm_id)');
    end if;
    if hardened = definition then
      raise exception 'RPC implementation has changed; review ownership guard for %', target.proname;
    end if;
    execute hardened;
  end loop;
  if not safety_guarded or not sales_guarded then
    raise exception 'Required safety/sales RPC implementation missing; review migration prerequisites';
  end if;
end;
$rpc_ownership$;

-- Return just the tracking fields an order participant is entitled to see.
create or replace function public.current_delivery_tracking(
  p_delivery_id bigint default null, p_order_id bigint default null
) returns jsonb language sql stable security definer set search_path = '' as $$
  select jsonb_build_object(
    'delivery_id', d.delivery_id, 'rider_id', a.rider_id,
    'rider_name', concat_ws(' ', r.first_name, r.last_name),
    'rider_phone', r.contact_number, 'rider_vehicle', r.vehicle_type,
    'latitude', l.latitude, 'longitude', l.longitude,
    'speed_kph', l.speed_kph, 'heading', l.heading,
    'location_updated_at', l.location_updated_at
  )
  from public.deliveries d
  left join private.rider_delivery_assignments a on a.delivery_id = d.delivery_id
  left join public.riders r on r.rider_id = a.rider_id
  left join public.rider_locations l on l.rider_id = a.rider_id
  where auth.uid() is not null
    and private.account_is_delivery_participant(d.delivery_id)
    and ((p_delivery_id is not null and d.delivery_id = p_delivery_id) or
      (p_delivery_id is null and p_order_id is not null and d.order_id = p_order_id))
  order by d.created_at desc limit 1
$$;
revoke all on function public.current_delivery_tracking(bigint, bigint) from public, anon;
grant execute on function public.current_delivery_tracking(bigint, bigint) to authenticated;

-- An incident about rider A filed by user B is B's report, not A's private data.
-- Legacy rider-authored reports without a reporter ID remain owned by that rider.
create or replace function private.account_own_safety_incidents(p_status text)
returns jsonb language sql stable security definer set search_path = '' as $$
  select coalesce(jsonb_agg(to_jsonb(i) order by i.reported_at desc), '[]'::jsonb)
  from public.rider_incidents i
  where auth.uid() is not null and (
    i.reporter_auth_id = auth.uid() or
    (i.reporter_auth_id is null and i.rider_id = private.current_rider_id())
  ) and (
    nullif(btrim(p_status), '') is null or p_status = 'all' or
    (p_status = 'open' and i.status in ('submitted', 'underReview', 'waitingForInformation', 'escalated')) or
    (p_status = 'resolved' and i.status in ('resolved', 'rejected')) or
    lower(i.status) = lower(p_status)
  )
$$;
create or replace function public.get_my_safety_incidents(p_status text default null)
returns jsonb language sql stable security invoker set search_path = '' as $$
  select private.account_own_safety_incidents(p_status)
$$;
revoke all on function private.account_own_safety_incidents(text),
  public.get_my_safety_incidents(text) from public, anon;
grant execute on function private.account_own_safety_incidents(text),
  public.get_my_safety_incidents(text) to authenticated, service_role;
do $$ begin
  if to_regprocedure('private.api_impl_20260925_get_my_safety_incidents(text)') is not null then
    revoke execute on function private.api_impl_20260925_get_my_safety_incidents(text) from authenticated;
  end if;
end $$;

-- Generic legacy RPCs accept arbitrary IDs/payloads without a current-account
-- contract. The app uses the current-rider/current-buyer RPCs instead.
do $legacy$
declare target record;
begin
  for target in select p.oid::regprocedure as signature
    from pg_proc p join pg_namespace n on n.oid = p.pronamespace
    where n.nspname = 'public' and p.prokind = 'f' and p.proname in (
      'create_delivery', 'update_delivery_status', 'calculate_delivery_earning',
      'save_delivery_proof', 'save_delivery_confirmation_code'
    )
  loop
    execute format('revoke all on function %s from public, anon, authenticated', target.signature);
    execute format('grant execute on function %s to service_role', target.signature);
  end loop;
end;
$legacy$;

notify pgrst, 'reload schema';
commit;
