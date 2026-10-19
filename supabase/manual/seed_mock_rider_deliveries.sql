-- Part 2 of the rider seed. Requires the temporary context from Part 1.
create temporary table mock_rider_deliveries (
  rider_id uuid, auth_id uuid, delivery_id bigint, order_id bigint,
  n integer, slot integer, status text, buyer_auth uuid, farmer_auth uuid
) on commit drop;
do $deliveries$
declare
  c record; j integer; item_value bigint; order_value bigint; delivery_value bigint;
  status_value text; client_value text; occurred_at timestamptz;
begin
  for c in select * from mock_rider_context loop
    for j in 1..30 loop
      client_value := 'sample-rider-v1-' || lpad(c.n::text, 2, '0') || '-' || j;
      select d.delivery_id, o.order_id, d.delivery_status
      into delivery_value, order_value, status_value
      from public.orders o join public.deliveries d using (order_id)
      where o.client_order_id = client_value;
      if delivery_value is null then
        status_value := case when j <= 20 then 'completed'
          when j = 21 then (array['accepted','going_to_pickup','arrived_at_pickup',
            'picked_up','going_to_delivery','arrived_at_delivery'])[1 + (c.n - 1) % 6]
          when j <= 23 then 'cancelled' when j <= 25 then 'failed' else 'available' end;
        occurred_at := case when j <= 20 then now() - (j - 1) * interval '1 day'
          else now() end;
        insert into public.cart_items (cart_id, commodity_id, quantity, price_at_time)
        values (c.cart_id, c.commodity_id, 1, c.price) returning cart_item_id into item_value;
        insert into public.orders (cart_item_id, client_order_id, checkout_reference,
          seller_farm_id, order_date, created_at, order_status, payment_status,
          payment_method, delivery_address, contact_number, delivery_latitude,
          delivery_longitude, stock_reserved_at)
        values (item_value, client_value, client_value, c.farm_id,
          occurred_at - interval '3 hours', occurred_at - interval '3 hours',
          case when j <= 20 then 'delivered' when j <= 25 then 'shipping'
            else 'readyForPickup' end,
          case when j <= 20 then 'paid' else 'pending' end,
          'cash_on_delivery', 'Sample buyer address, Malaybalay, Bukidnon',
          '09200000001', 8.16 + c.n * 0.001, 125.13 + c.n * 0.001, occurred_at)
        returning order_id into order_value;
        insert into public.order_items (order_id, quantity, unit_price, total_price)
        values (order_value, 1, c.price, c.price);
        insert into public.deliveries (order_id, delivery_status, created_at,
          estimated_delivery_time, actual_delivery_time, distance_km,
          vehicle_types, pickup_location, dropoff_location, delivery_deadline)
        values (order_value, status_value, occurred_at - interval '2 hours',
          occurred_at + interval '1 hour', case when j <= 20 then occurred_at end,
          2 + j * 0.2, 'motorcycle', 'Sample Mock Farm ' || c.n || ', Malaybalay',
          'Sample buyer address, Malaybalay', occurred_at + interval '3 hours')
        returning delivery_id into delivery_value;
        insert into private.order_delivery_fulfillments (buyer_user_id, seller_order_id,
          representative_order_id, delivery_id, pickup_lat, pickup_long,
          dropoff_lat, dropoff_long, pickup_contact, dropoff_contact,
          total_weight_kg, required_vehicle_type, handling_notes, ready_at)
        values (c.buyer_id, client_value, order_value, delivery_value,
          8.15 + c.n * 0.001, 125.12 + c.n * 0.001,
          8.16 + c.n * 0.001, 125.13 + c.n * 0.001,
          '09100000001', '09200000001', 1, 'motorcycle',
          '[Sample] Keep produce upright and dry.', occurred_at - interval '2 hours');
        insert into public.rider_assignment_requests (delivery_id, seller_order_id,
          rider_id, farmer_user_id, status, requested_schedule, proposed_delivery_fee,
          requested_at, expires_at, responded_at)
        values (delivery_value, client_value, c.rider_id, c.farmer_id,
          case when j > 25 then 'pending' else 'accepted' end,
          occurred_at + interval '1 hour', 70 + j * 2,
          occurred_at - interval '10 minutes', occurred_at + interval '50 minutes',
          case when j <= 25 then occurred_at - interval '5 minutes' end);
        if j <= 25 then
          insert into private.rider_delivery_assignments (delivery_id, rider_id, assigned_at)
          values (delivery_value, c.rider_id, occurred_at - interval '90 minutes');
          insert into private.delivery_status_events (delivery_id, idempotency_key,
            previous_status, new_status, remarks, latitude, longitude, changed_at)
          values (delivery_value, 'sample-rider-' || delivery_value, 'available',
            status_value, '[Sample] Delivery history for testing',
            8.15 + c.n * 0.001, 125.12 + c.n * 0.001, occurred_at);
        end if;
        if j <= 20 then
          perform private.record_completed_rider_earning(delivery_value);
          insert into private.delivery_cash_collections (delivery_id, rider_id,
            amount_expected, amount_received, collection_confirmed, notes)
          values (delivery_value, c.rider_id, c.price, c.price, true,
            '[Sample] Synthetic collection; no real money received');
          insert into public.delivery_proofs (delivery_id, rider_id, proof_stage,
            proof_type, confirmation_code_hash, confirmed_at, remarks)
          select delivery_value, c.rider_id, stage, 'confirmation_code',
            extensions.crypt('123456', extensions.gen_salt('bf')), occurred_at,
            '[Sample] Test confirmation code: 123456'
          from unnest(array['pickup','delivery']) stage;
          insert into public.rider_ratings (delivery_id, rider_id, reviewer_auth_id,
            reviewer_role, rating, comment, created_at)
          values (delivery_value, c.rider_id,
            case when j % 2 = 0 then c.buyer_auth else c.farmer_auth end,
            case when j % 2 = 0 then 'buyer' else 'farmer' end,
            3 + j % 3, '[Sample] Produce arrived safely. Thank you!', occurred_at);
          insert into public.payments (order_id, amount, payment_method,
            transaction_reference, payment_date, payment_status)
          values (order_value, c.price, 'cash_on_delivery',
            'SAMPLE-COD-' || delivery_value, occurred_at, 'paid');
        elsif j = 21 and status_value in ('picked_up','going_to_delivery','arrived_at_delivery') then
          insert into public.delivery_proofs (delivery_id, rider_id, proof_stage,
            proof_type, confirmation_code_hash, confirmed_at, remarks)
          values (delivery_value, c.rider_id, 'pickup', 'confirmation_code',
            extensions.crypt('123456', extensions.gen_salt('bf')), now(),
            '[Sample] Pickup confirmed for active delivery');
        end if;
      end if;
      insert into mock_rider_deliveries values (c.rider_id, c.auth_id,
        delivery_value, order_value, c.n, j, status_value, c.buyer_auth, c.farmer_auth);
    end loop;
  end loop;
end;
$deliveries$;
