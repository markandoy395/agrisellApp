begin;

-- Cargo ceilings are application policy; the rider must declare a lower usable
-- capacity after allowing for occupants, accessories and the vehicle/rack rating.
alter table private.rider_delivery_limit_configuration
  add column if not exists maximum_capacity_kg numeric(12,3)
  check (maximum_capacity_kg > 0 and maximum_capacity_kg <= 100000);
insert into private.rider_delivery_limit_configuration
  (vehicle_type, recommended_limit, configured_limit, maximum_capacity_kg)
values ('bicycle', 3, 3, 25), ('ebike', 3, 3, 25)
on conflict (vehicle_type) do update set maximum_capacity_kg = excluded.maximum_capacity_kg;
update private.rider_delivery_limit_configuration set maximum_capacity_kg =
  case vehicle_type when 'motorcycle' then 30 when 'tricycle' then 200
    when 'car' then 200 when 'van' then 1000 when 'truck' then 1500 end
where vehicle_type in ('motorcycle','tricycle','car','van','truck');
update private.rider_delivery_limit_configuration
set configured_limit = recommended_limit, updated_at = now()
where configured_limit = 1 and updated_by is null;

alter table public.riders add column if not exists maximum_capacity_kg numeric(12,3);
update public.riders as rider set
  maximum_capacity_kg = policy.maximum_capacity_kg,
  capacity_kg = case when rider.capacity_kg > 0 and
    rider.capacity_kg <= policy.maximum_capacity_kg then rider.capacity_kg else null end,
  maximum_active_deliveries = case when rider.maximum_active_deliveries = 1
    then policy.configured_limit else rider.maximum_active_deliveries end
from private.rider_delivery_limit_configuration as policy
where lower(replace(btrim(rider.vehicle_type), '-', '')) = policy.vehicle_type;

create or replace function private.apply_rider_vehicle_delivery_defaults()
returns trigger language plpgsql security definer set search_path = '' as $$
declare policy private.rider_delivery_limit_configuration%rowtype;
begin
  select * into policy from private.rider_delivery_limit_configuration
  where vehicle_type = lower(replace(btrim(new.vehicle_type), '-', ''));
  new.maximum_capacity_kg := policy.maximum_capacity_kg;
  if tg_op = 'INSERT' then
    if new.maximum_active_deliveries = 1 and policy.configured_limit is not null then
      new.maximum_active_deliveries := policy.configured_limit;
    end if;
  elsif new.vehicle_type is distinct from old.vehicle_type then
    new.capacity_kg := null;
  end if;
  if new.capacity_kg is not null and (new.capacity_kg <= 0 or
      new.maximum_capacity_kg is null or new.capacity_kg > new.maximum_capacity_kg) then
    raise exception 'Capacity must be positive and within the vehicle cargo ceiling' using errcode='22023';
  end if;
  return new;
end;
$$;
revoke all on function private.apply_rider_vehicle_delivery_defaults() from public,anon,authenticated;
drop trigger if exists rider_vehicle_delivery_defaults on public.riders;
create trigger rider_vehicle_delivery_defaults before insert or update of vehicle_type,capacity_kg,maximum_capacity_kg
on public.riders for each row execute function private.apply_rider_vehicle_delivery_defaults();

-- Compute from all persisted order lines; cached fulfillment weight may be
-- stale or may incorrectly treat pieces/sacks as kilograms. Unknown mass denies.
create or replace function private.delivery_order_cargo_kg(p_delivery_id bigint)
returns numeric language sql stable security invoker set search_path='' as $$
  select case when count(*)=0 or count(*) filter (
    where lower(btrim(coalesce(commodity.unit_type,''))) not in ('kg','kilogram','kilograms')
      or item.quantity is null or item.quantity <= 0
  ) > 0 then null else sum(item.quantity::numeric) end
  from private.order_delivery_fulfillments fulfillment
  join public.orders representative on representative.order_id=fulfillment.representative_order_id
  join public.orders orders on orders.client_order_id=fulfillment.seller_order_id
    and orders.seller_farm_id=representative.seller_farm_id
  join public.cart_items item on item.cart_item_id=orders.cart_item_id
  join public.carts cart on cart.cart_id=item.cart_id and cart.buyer_user_id=fulfillment.buyer_user_id
  join public.commodities commodity on commodity.commodity_id=item.commodity_id
  where fulfillment.delivery_id=p_delivery_id;
$$;
revoke all on function private.delivery_order_cargo_kg(bigint) from public,anon,authenticated;

create or replace function private.validate_rider_cargo_capacity(p_delivery_id bigint,p_rider_id uuid)
returns void language plpgsql security definer set search_path='' as $$
declare
  rider public.riders%rowtype;
  target_weight numeric;
  active_weight numeric;
  unknown_count integer;
begin
  if auth.uid() is null or coalesce(auth.jwt()->>'is_anonymous','false') <> 'false'
    or coalesce((auth.jwt()->>'exp')::numeric,0) <= extract(epoch from now()) then
    raise exception 'Authentication required' using errcode='42501';
  end if;
  select * into rider from public.riders where rider_id=p_rider_id for update;
  if private.current_rider_id() is distinct from p_rider_id
    and not private.can_manage_rider_delivery_limit(rider.logistics_company_id) then
    raise exception 'Rider identity required' using errcode='42501';
  end if;
  if rider.capacity_kg is null or rider.capacity_kg <= 0 or rider.maximum_capacity_kg is null
    or rider.capacity_kg > rider.maximum_capacity_kg then
    raise exception 'Set your vehicle cargo capacity before accepting deliveries' using errcode='22023';
  end if;
  target_weight := private.delivery_order_cargo_kg(p_delivery_id);
  select coalesce(sum(weight.kg),0), count(*) filter(where weight.kg is null or weight.kg <= 0)
    into active_weight,unknown_count
  from private.rider_delivery_assignments a join public.deliveries d using(delivery_id)
  cross join lateral (select private.delivery_order_cargo_kg(a.delivery_id) as kg) weight
  where a.rider_id=p_rider_id and d.delivery_status in
    ('accepted','going_to_pickup','arrived_at_pickup','picked_up','going_to_delivery','arrived_at_delivery');
  if target_weight is null or target_weight <= 0 or unknown_count > 0 then
    raise exception 'cargo_weight_unknown' using errcode='22023';
  end if;
  if active_weight + target_weight > rider.capacity_kg then
    raise exception 'capacity_conflict' using errcode='22023';
  end if;
end;
$$;
revoke all on function private.validate_rider_cargo_capacity(bigint,uuid) from public,anon,authenticated;

-- Bind the check to the existing server-side acceptance validator without
-- replacing its authorization, idempotency, COD, deadline or route rules.
do $$
declare body text;
begin
  body := pg_get_functiondef('private.validate_delivery_batch_acceptance(bigint,uuid)'::regprocedure);
  if position('private.validate_rider_cargo_capacity' in body)=0 then
    if position('if active_count >= greatest' in body)=0 then
      raise exception 'Unexpected acceptance validator definition';
    end if;
    body := replace(body,'if active_count >= greatest',
      'perform private.validate_rider_cargo_capacity(p_delivery_id,p_rider_id);' || chr(10) || '  if active_count >= greatest');
    execute body;
  end if;
end;
$$;

create or replace function public.set_current_rider_capacity(p_capacity_kg numeric)
returns jsonb language plpgsql security definer set search_path='' as $$
declare
  current_rider uuid;
  rider public.riders%rowtype;
  active_weight numeric;
  unknown_count integer;
begin
  if auth.uid() is null or coalesce(auth.jwt()->>'is_anonymous','false') <> 'false'
    or coalesce((auth.jwt()->>'exp')::numeric,0) <= extract(epoch from now()) then
    raise exception 'Authentication required' using errcode='42501';
  end if;
  perform public.require_rate_limited_gateway();
  current_rider := private.current_rider_id();
  select * into rider from public.riders where rider_id=current_rider for update;
  if not found then raise exception 'Rider identity required' using errcode='42501'; end if;
  if p_capacity_kg is null or p_capacity_kg <= 0 or rider.maximum_capacity_kg is null
    or p_capacity_kg > rider.maximum_capacity_kg then
    raise exception 'Capacity must be positive and within the vehicle cargo ceiling' using errcode='22023';
  end if;
  select coalesce(sum(weight.kg),0), count(*) filter(where weight.kg is null or weight.kg <= 0)
    into active_weight,unknown_count
  from private.rider_delivery_assignments a join public.deliveries d using(delivery_id)
  cross join lateral (select private.delivery_order_cargo_kg(a.delivery_id) as kg) weight
  where a.rider_id=current_rider and d.delivery_status in
    ('accepted','going_to_pickup','arrived_at_pickup','picked_up','going_to_delivery','arrived_at_delivery');
  if unknown_count > 0 or p_capacity_kg < active_weight then
    raise exception 'Capacity cannot be below the weight of your active deliveries' using errcode='22023';
  end if;
  update public.riders set capacity_kg=p_capacity_kg where rider_id=current_rider;
  return jsonb_build_object('capacity_kg',p_capacity_kg,'maximum_capacity_kg',rider.maximum_capacity_kg);
end;
$$;
revoke all on function public.set_current_rider_capacity(numeric) from public,anon;
grant execute on function public.set_current_rider_capacity(numeric) to authenticated;
alter table private.rider_delivery_limit_configuration enable row level security;
revoke all on private.rider_delivery_limit_configuration from public,anon,authenticated;
notify pgrst,'reload schema';
commit;
