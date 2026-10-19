-- Run after seed_mock_rider_accounts.sql, in the same transaction.
-- Adds 30 active jobs and 50 requests per mock rider. Re-running skips jobs.
-- Existing pending requests in this load dataset get a fresh 59-minute window.
do $load$
declare
  c record; j integer; item_value bigint; order_value bigint; delivery_value bigint;
  status_value text; client_value text;
  proof_hash text := extensions.crypt('123456', extensions.gen_salt('bf'));
begin
  for c in select * from mock_rider_context loop
    -- Mock-only inventory ensures these test orders have real allocated stock.
    if not exists (select 1 from public.commodity_inventory_lots
      where commodity_id = c.commodity_id and lot_code = 'SAMPLE-RIDER-LOAD') then
      insert into public.commodity_inventory_lots (commodity_id, date_type,
        quantity_received, quantity_remaining, harvested_at, sell_until,
        lot_code, storage_instructions, created_by)
      values (c.commodity_id, 'fresh_produce', 1000, 1000, current_date,
        current_date + 30, 'SAMPLE-RIDER-LOAD',
        '[Sample] Extra inventory for rider list performance testing', c.farmer_auth);
      update public.commodities set available_quantity = available_quantity + 1000
      where commodity_id = c.commodity_id;
    end if;
    update public.riders set maximum_active_deliveries = 50,
      capacity_kg = least(maximum_capacity_kg, 100)
    where rider_id = c.rider_id;
    for j in 1..80 loop
      client_value := 'sample-rider-load-v1-' || lpad(c.n::text, 2, '0') || '-' || j;
      if exists (select 1 from public.orders where client_order_id = client_value) then
        continue;
      end if;
      status_value := case when j > 30 then 'available' else
        (array['accepted','going_to_pickup','arrived_at_pickup',
          'picked_up','going_to_delivery','arrived_at_delivery'])[1 + (j - 1) % 6] end;
      insert into public.cart_items (cart_id, commodity_id, quantity, price_at_time)
      values (c.cart_id, c.commodity_id, 1, c.price) returning cart_item_id into item_value;
      insert into public.orders (cart_item_id, client_order_id, checkout_reference,
        seller_farm_id, order_date, order_status, payment_status, payment_method,
        delivery_address, contact_number, delivery_latitude, delivery_longitude,
        stock_reserved_at)
      values (item_value, client_value, client_value, c.farm_id, now(),
        case when status_value in ('picked_up','going_to_delivery','arrived_at_delivery')
          then 'shipping' else 'readyForPickup' end,
        'pending', 'cash_on_delivery', 'Sample drop-off ' || j || ', Malaybalay',
        '09200000001', 8.16 + c.n * 0.001 + j * 0.00001,
        125.13 + c.n * 0.001 + j * 0.00001, now())
      returning order_id into order_value;
      insert into public.order_items (order_id, quantity, unit_price, total_price)
      values (order_value, 1, c.price, c.price);
      insert into public.deliveries (order_id, delivery_status, distance_km,
        estimated_delivery_time, vehicle_types, pickup_location,
        dropoff_location, delivery_deadline)
      values (order_value, status_value, 1 + j * 0.1, now() + interval '2 hours',
        'motorcycle', 'Sample Mock Farm ' || c.n || ', Malaybalay',
        'Sample drop-off ' || j || ', Malaybalay', now() + interval '4 hours')
      returning delivery_id into delivery_value;
      insert into private.order_delivery_fulfillments (buyer_user_id,
        seller_order_id, representative_order_id, delivery_id,
        pickup_lat, pickup_long, dropoff_lat, dropoff_long,
        pickup_contact, dropoff_contact, total_weight_kg,
        required_vehicle_type, handling_notes, ready_at)
      values (c.buyer_id, client_value, order_value, delivery_value,
        8.15 + c.n * 0.001, 125.12 + c.n * 0.001,
        8.16 + c.n * 0.001 + j * 0.00001,
        125.13 + c.n * 0.001 + j * 0.00001,
        '09100000001','09200000001',1,'motorcycle',
        '[Sample] Rider list performance test. Keep produce dry.',now());
      insert into public.rider_assignment_requests (delivery_id,seller_order_id,
        rider_id,farmer_user_id,status,requested_schedule,proposed_delivery_fee,
        requested_at,expires_at,responded_at)
      values (delivery_value,client_value,c.rider_id,c.farmer_id,
        case when j <= 30 then 'accepted' else 'pending' end,
        now() + interval '30 minutes',80 + j,now(),now() + interval '59 minutes',
        case when j <= 30 then now() end);
      if j <= 30 then
        insert into private.rider_delivery_assignments (delivery_id,rider_id)
        values (delivery_value,c.rider_id);
        insert into private.delivery_status_events (delivery_id,idempotency_key,
          previous_status,new_status,remarks,latitude,longitude)
        values (delivery_value,'sample-load-' || delivery_value,'available',
          status_value,'[Sample] Active delivery performance fixture',
          8.15 + c.n * 0.001,125.12 + c.n * 0.001);
        if status_value in ('picked_up','going_to_delivery','arrived_at_delivery') then
          insert into public.delivery_proofs (delivery_id,rider_id,proof_stage,
            proof_type,confirmation_code_hash,confirmed_at,remarks)
          values (delivery_value,c.rider_id,'pickup','confirmation_code',proof_hash,
            now(),'[Sample] Pickup confirmed; code 123456');
        end if;
      end if;
    end loop;
  end loop;
end;
$load$;

update public.rider_assignment_requests r set requested_at = now(),
  expires_at = now() + interval '59 minutes', requested_schedule = now() + interval '30 minutes'
from public.deliveries d join public.orders o using (order_id)
where d.delivery_id = r.delivery_id and d.delivery_status = 'available'
  and r.status = 'pending' and o.client_order_id like 'sample-rider-load-v1-%'
  and r.rider_id in (select rider_id from mock_rider_context)
  and not exists (select 1 from private.rider_delivery_assignments a
    where a.delivery_id = r.delivery_id);

alter table public.notifications enable trigger notifications_dispatch_push_after_insert;
select (select count(*) from public.deliveries d
  join private.rider_delivery_assignments a using (delivery_id)
  where a.rider_id in (select rider_id from mock_rider_context)
    and d.delivery_status in ('accepted','going_to_pickup','arrived_at_pickup',
      'picked_up','going_to_delivery','arrived_at_delivery')) as active_jobs,
  (select count(*) from public.rider_assignment_requests r
    join public.deliveries d using (delivery_id)
    where r.rider_id in (select rider_id from mock_rider_context)
      and r.status = 'pending' and r.expires_at > now()
      and d.delivery_status = 'available') as fresh_requests;
commit;
