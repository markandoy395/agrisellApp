-- Run only after the Flutter release using normalized delivery entities is
-- deployed and the verification migration reports no incomplete locations.
begin;

do $$
declare incomplete_location_ids bigint[];
declare incomplete_payment_ids bigint[];
begin
  select array_agg(delivery.delivery_id order by delivery.delivery_id)
  into incomplete_location_ids
  from public.deliveries delivery
  where not exists (
    select 1 from public.delivery_locations location
    where location.delivery_id = delivery.delivery_id
      and location.location_type = 'pickup'
  ) or not exists (
    select 1 from public.delivery_locations location
    where location.delivery_id = delivery.delivery_id
      and location.location_type = 'dropoff'
  );

  select array_agg(delivery.delivery_id order by delivery.delivery_id)
  into incomplete_payment_ids
  from public.deliveries delivery
  where not exists (
    select 1 from public.delivery_payments payment
    where payment.delivery_id = delivery.delivery_id
  );

  if incomplete_location_ids is not null or incomplete_payment_ids is not null then
    raise exception
      'Delivery cleanup blocked. Missing location IDs: %. Missing payment IDs: %',
      coalesce(incomplete_location_ids, '{}'::bigint[]),
      coalesce(incomplete_payment_ids, '{}'::bigint[]);
  end if;
end;
$$;

alter table public.deliveries
  drop column if exists pickup_location,
  drop column if exists dropoff_location,
  drop column if exists pickup_lat,
  drop column if exists pickup_long,
  drop column if exists dropoff_lat,
  drop column if exists dropoff_long,
  drop column if exists pickup_instructions,
  drop column if exists delivery_instructions,
  drop column if exists required_vehicle_types,
  drop column if exists handling_requirements,
  drop column if exists package_dimensions,
  drop column if exists cancellation_conditions,
  drop column if exists transport_compatibility_group,
  drop column if exists transport_compatibility_groups,
  drop column if exists requires_exclusive_transport,
  drop column if exists route_payload,
  drop column if exists workflow_state,
  drop column if exists proof_references,
  drop column if exists status_history,
  drop column if exists problem_records,
  drop column if exists offline_actions,
  drop column if exists batch_reference,
  drop column if exists pickup_sequence,
  drop column if exists delivery_sequence,
  drop column if exists batch_route,
  drop column if exists earning_breakdown,
  drop column if exists earning_status,
  drop column if exists payout_status,
  drop column if exists final_earning,
  drop column if exists estimated_earning,
  drop column if exists fee_breakdown,
  drop column if exists pickup_to_delivery_distance_km,
  drop column if exists pickup_to_delivery_minutes,
  drop column if exists estimated_delivery_time,
  drop column if exists actual_delivery_time,
  drop column if exists vehicle_types,
  drop column if exists cold_chain_available;

-- delivery_fee remains temporarily for safe pre-assignment request cards.
-- Remove it only after available-delivery fee projection is server-owned.
commit;
