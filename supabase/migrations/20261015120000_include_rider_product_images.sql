begin;

-- Preserve selected/assigned rider visibility and payment wrappers. Only return
-- an actual ordered-product image from the fulfillment seller and buyer.
create or replace function private.current_rider_deliveries(
  include_available boolean default true
) returns jsonb language plpgsql stable security definer set search_path = '' as $$
begin
  if auth.uid() is null
    or coalesce(auth.jwt()->>'is_anonymous', 'false') <> 'false'
    or coalesce((auth.jwt()->>'exp')::numeric, 0) <= extract(epoch from now())
    or private.current_rider_id() is null then
    raise exception 'Valid rider session required' using errcode = '42501';
  end if;
  return (
  select coalesce(jsonb_agg(
    to_jsonb(delivery) || jsonb_build_object(
      'assigned_to_current_rider', assignment.rider_id is not null,
      'assignment_request_id', selected_request.request_id,
      'assignment_request_status', selected_request.status,
      'assignment_request_expires_at', selected_request.expires_at,
      'requested_schedule', selected_request.requested_schedule,
      'proposed_delivery_fee', selected_request.proposed_delivery_fee,
      'payment_method', order_summary.payment_method,
      'payment_status', order_summary.payment_status,
      'amount_to_collect', case
        when order_summary.payment_method = 'cash_on_delivery'
          then order_summary.order_total else null end,
      'goods_summary', order_summary.goods_summary,
      'product_image_url', order_summary.product_image_url,
      'seller_name', order_summary.seller_name,
      'buyer_name', order_summary.buyer_name,
      'total_weight_kg', fulfillment.total_weight_kg,
      'required_capacity_kg', fulfillment.total_weight_kg,
      'service_area', order_summary.pickup_municipality,
      'delivery_fee', selected_request.proposed_delivery_fee,
      'expires_at', selected_request.expires_at,
      'locations', case when fulfillment.delivery_id is null then '[]'::jsonb
        else jsonb_build_array(
          jsonb_build_object(
            'location_id', 'pickup-' || delivery.delivery_id,
            'delivery_id', delivery.delivery_id,
            'location_type', 'pickup', 'address', delivery.pickup_location,
            'latitude', fulfillment.pickup_lat,
            'longitude', fulfillment.pickup_long,
            'contact_number', fulfillment.pickup_contact,
            'sequence_number', 1, 'created_at', fulfillment.ready_at,
            'updated_at', fulfillment.ready_at
          ),
          jsonb_build_object(
            'location_id', 'dropoff-' || delivery.delivery_id,
            'delivery_id', delivery.delivery_id,
            'location_type', 'dropoff', 'address', delivery.dropoff_location,
            'latitude', fulfillment.dropoff_lat,
            'longitude', fulfillment.dropoff_long,
            'contact_number', fulfillment.dropoff_contact,
            'sequence_number', 1, 'created_at', fulfillment.ready_at,
            'updated_at', fulfillment.ready_at
          )
        ) end,
      'requirement', case when fulfillment.delivery_id is null then null
        else jsonb_build_object(
          'requirement_id', 'requirement-' || delivery.delivery_id,
          'delivery_id', delivery.delivery_id,
          'required_vehicle_type', fulfillment.required_vehicle_type,
          'minimum_capacity_kg', fulfillment.total_weight_kg,
          'requires_cooling', coalesce(delivery.cold_chain_available, false),
          'requires_fragile_handling', true,
          'requires_waterproof_cover', true,
          'requires_special_handling', true,
          'handling_notes', fulfillment.handling_notes,
          'cancellation_conditions',
            'Cancellation closes once the selected rider accepts.',
          'created_at', fulfillment.ready_at,
          'updated_at', fulfillment.ready_at
        ) end,
      'history', coalesce((
        select jsonb_agg(
          to_jsonb(event) || jsonb_build_object(
            'status_history_id', event.idempotency_key,
            'created_at', event.changed_at
          ) order by event.changed_at
        )
        from private.delivery_status_events as event
        where event.delivery_id = delivery.delivery_id
      ), '[]'::jsonb)
    ) order by delivery.created_at desc
  ), '[]'::jsonb)
  from public.deliveries as delivery
  left join private.rider_delivery_assignments as assignment
    on assignment.delivery_id = delivery.delivery_id
      and assignment.rider_id = private.current_rider_id()
  left join private.order_delivery_fulfillments as fulfillment
    on fulfillment.delivery_id = delivery.delivery_id
  left join lateral (
    select request_record.*
    from public.rider_assignment_requests as request_record
    where request_record.delivery_id = delivery.delivery_id
      and request_record.rider_id = private.current_rider_id()
      and (
        request_record.status = 'accepted'
        or (request_record.status = 'pending'
          and request_record.expires_at > now())
      )
    order by request_record.requested_at desc limit 1
  ) as selected_request on true
  left join lateral (
    select
      (array_agg(order_record.payment_method
        order by order_record.order_id))[1] as payment_method,
      (array_agg(order_record.payment_status
        order by order_record.order_id))[1] as payment_status,
      sum(order_record.total_amount) as order_total,
      (array_agg(nullif(btrim(commodity.image_url), '')
        order by commodity.commodity_id) filter (
          where farm.farm_id = fulfillment.seller_farm_id
            and nullif(btrim(commodity.image_url), '') is not null
        ))[1] as product_image_url,
      string_agg(format('%s %s %s', cart_item.quantity,
        coalesce(commodity.unit_type, 'unit'), commodity.commodity_name),
        ', ' order by commodity.commodity_name) as goods_summary,
      coalesce(nullif(btrim(farmer.first_name || ' ' || farmer.last_name), ''),
        farm.farm_name, 'Farmer') as seller_name,
      coalesce(nullif(btrim(app_user.first_name || ' ' || app_user.last_name), ''),
        'Buyer') as buyer_name,
      farm.city_municipality as pickup_municipality
    from public.orders as order_record
    join public.cart_items as cart_item
      on cart_item.cart_item_id = order_record.cart_item_id
    join public.commodities as commodity
      on commodity.commodity_id = cart_item.commodity_id
    join public.farms as farm on farm.farm_id = commodity.farm_id
    join public.farmers as farmer
      on farmer.farmer_user_id = farm.farmer_user_id
    join public.carts as cart on cart.cart_id = cart_item.cart_id
    join public.buyers as buyer on buyer.buyer_user_id = cart.buyer_user_id
    join public.users as app_user on app_user.user_id = buyer.user_id
    where order_record.client_order_id = fulfillment.seller_order_id
      and cart.buyer_user_id = fulfillment.buyer_user_id
    group by farmer.first_name, farmer.last_name, farm.farm_name,
      app_user.first_name, app_user.last_name, farm.city_municipality
  ) as order_summary on true
  where assignment.rider_id is not null or (
    include_available and delivery.delivery_status = 'available'
    and fulfillment.delivery_id is not null
    and selected_request.status = 'pending'
    and not exists (
      select 1 from private.rider_delivery_assignments as claimed
      where claimed.delivery_id = delivery.delivery_id
    )
  )
);
end;
$$;

-- Existing grants and outer gateway quotas remain unchanged.
notify pgrst, 'reload schema';
commit;

