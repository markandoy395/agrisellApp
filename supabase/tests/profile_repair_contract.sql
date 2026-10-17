-- Existing accounts only. Every profile mutation and test gateway configuration
-- is rolled back. Returns no identifying data. Run as migration owner.
begin;
set local lock_timeout = '3s';
set local statement_timeout = '30s';
update private.api_gateway_configuration
set secret_hash = encode(extensions.digest('profile-repair-test', 'sha256'), 'hex')
where singleton;
select set_config('request.headers', '{"x-agrisell-api-gateway":"profile-repair-test"}', true);
create temporary table repair_actors on commit drop as
select i.auth_user_id, i.user_id, i.buyer_user_id, i.farmer_user_id, i.rider_id,
  u.account_status as buyer_status, f.account_status as farmer_status,
  f.verification_status, r.employment_status, r.vehicle_type,
  r.maximum_capacity_kg, r.capacity_kg,
  coalesce(nullif(r.contact_number, ''), nullif(f.phone_number, ''),
    nullif(u.contact_number, ''),
    '0999' || lpad(row_number() over (order by i.auth_user_id)::text, 7, '0')) as test_phone,
  exists (select 1 from private.rider_delivery_assignments assignment
    join public.deliveries delivery using (delivery_id)
    where assignment.rider_id = i.rider_id and delivery.delivery_status in
      ('accepted','going_to_pickup','arrived_at_pickup','picked_up',
       'going_to_delivery','arrived_at_delivery')) as has_active_cargo
from private.auth_identities i
left join public.users u on u.user_id = i.user_id
left join public.farmers f on f.farmer_user_id = i.farmer_user_id
left join public.riders r on r.rider_id = i.rider_id
where i.buyer_user_id is not null or i.farmer_user_id is not null or i.rider_id is not null;
grant select on repair_actors to authenticated;
-- Only temporary verification metadata is supplied; never create an account.
update auth.users u set email_confirmed_at = coalesce(email_confirmed_at, now()),
  raw_user_meta_data = raw_user_meta_data || jsonb_build_object('requested_role',
    case when a.buyer_user_id is not null then 'buyer'
         when a.farmer_user_id is not null then 'farmer' else 'rider' end)
from repair_actors a where u.id = a.auth_user_id;
set local role authenticated;
do $audit$
declare
  a record; payload jsonb; saved jsonb; before_vehicle jsonb; after_vehicle jsonb;
  denied boolean; checked integer := 0;
  literal_value constant text := 'Audit %_* O''Neil; --';
begin
  for a in select * from repair_actors loop
    perform set_config('request.jwt.claim.sub', a.auth_user_id::text, true);
    perform set_config('request.jwt.claims', jsonb_build_object(
      'sub', a.auth_user_id, 'role', 'authenticated', 'is_anonymous', false,
      'exp', extract(epoch from now() + interval '1 hour'))::text, true);
    if a.buyer_user_id is not null then
      payload := jsonb_build_object('first_name', literal_value, 'last_name', 'Audit',
        'phone_number', a.test_phone, 'date_of_birth', '1990-01-01',
        'gender', 'Other', 'shipping_address', literal_value, 'accepted_policy', true);
      saved := public.complete_current_buyer_registration(payload);
      if saved->>'first_name' is distinct from literal_value or
         saved->>'account_status' is distinct from a.buyer_status or not exists (
           select 1 from public.buyers where buyer_user_id = a.buyer_user_id
             and shipping_address = literal_value) then
        raise exception 'Buyer retry did not save literal details or preserve status';
      end if;
      denied := false;
      begin perform public.complete_current_buyer_registration(payload || '{"accepted_policy":false}');
      exception when sqlstate '22023' then denied := true; end;
      if not denied then raise exception 'Buyer consent was bypassed'; end if;
    elsif a.farmer_user_id is not null then
      payload := jsonb_build_object('first_name', literal_value, 'last_name', 'Audit',
        'phone_number', a.test_phone, 'date_of_birth', '1990-01-01', 'gender', 'Other',
        'address_line', literal_value, 'barangay', 'Audit', 'city_municipality', 'Audit',
        'province', 'Audit', 'farm_name', literal_value, 'farm_location', literal_value,
        'latitude', 8.48, 'longitude', 124.65, 'years_of_experience', 3,
        'farm_size', 2500, 'farm_size_unit', 'sq m', 'main_crops', jsonb_build_array(literal_value));
      saved := public.complete_current_farmer_registration(payload);
      if saved->>'first_name' is distinct from literal_value or
         saved->>'account_status' is distinct from a.farmer_status or
         saved->>'verification_status' is distinct from a.verification_status or not exists (
           select 1 from public.farms where farmer_user_id = a.farmer_user_id
             and farm_name = literal_value and farm_size = 2500
             and farm_size_hectares = 0.25 and total_crops = cardinality(main_crops)) then
        raise exception 'Farmer retry, size conversion or crop count failed';
      end if;
    else
      payload := jsonb_build_object('first_name', literal_value, 'last_name', 'Audit',
        'contact_number', a.test_phone, 'date_of_birth', '1990-01-01', 'gender', 'Other',
        'address_line', literal_value, 'barangay', 'Audit', 'city_municipality', 'Audit',
        'province', 'Audit', 'vehicle_type', a.vehicle_type,
        'accepted_terms', true, 'accepted_privacy', true, 'confirmed_accuracy', true);
      saved := public.create_current_rider_registration(payload);
      if saved->>'first_name' is distinct from literal_value or
         saved->>'employment_status' is distinct from a.employment_status then
        raise exception 'Rider retry did not save details or preserve status';
      end if;
      denied := false;
      begin perform public.create_current_rider_registration(payload || '{"accepted_terms":false}');
      exception when sqlstate '22023' then denied := true; end;
      if not denied then raise exception 'Rider consent was bypassed'; end if;
      select to_jsonb(r) into before_vehicle from public.riders r where rider_id = a.rider_id;
      payload := jsonb_build_object('vehicle_type', a.vehicle_type, 'vehicle_brand', literal_value,
        'vehicle_model', literal_value, 'vehicle_color', 'Blue', 'plate_number', 'ABC 123',
        'registration_number', 'REG-123', 'capacity_kg', a.maximum_capacity_kg + 1);
      denied := false;
      begin perform public.update_current_rider_vehicle(payload);
      exception when sqlstate '22023' then denied := true; end;
      select to_jsonb(r) into after_vehicle from public.riders r where rider_id = a.rider_id;
      if not denied or before_vehicle is distinct from after_vehicle then
        raise exception 'Invalid capacity caused a partial vehicle save';
      end if;
      denied := false;
      begin perform public.update_current_rider_vehicle(payload || jsonb_build_object('rider_id', a.rider_id));
      exception when insufficient_privilege then denied := true; end;
      if not denied then raise exception 'Vehicle ownership tampering accepted'; end if;
      perform set_config('request.headers', '{}', true);
      denied := false;
      begin perform public.update_current_rider_vehicle(payload);
      exception when sqlstate 'PT403' then denied := true; end;
      if not denied then raise exception 'Direct vehicle API bypass accepted'; end if;
      denied := false;
      begin update public.riders set vehicle_model = 'bypass' where rider_id = a.rider_id;
      exception when sqlstate 'PT403' then denied := true; end;
      if not denied then raise exception 'Direct vehicle detail update bypass accepted'; end if;
      perform set_config('request.headers', '{"x-agrisell-api-gateway":"profile-repair-test"}', true);
      -- Preserve active cargo and its current capacity; unknown cargo can reject
      -- any capacity change, so a success check uses only riders without it.
      if not a.has_active_cargo then
        saved := public.update_current_rider_vehicle(payload || jsonb_build_object(
          'capacity_kg', coalesce(nullif(a.capacity_kg, 0), a.maximum_capacity_kg)));
        if saved->>'vehicle_model' is distinct from literal_value or
           saved->>'vehicle_color' is distinct from 'Blue' or
           saved->>'registration_number' is distinct from 'REG-123' then
          raise exception 'Vehicle details failed to persist';
        end if;
      end if;
    end if;
    if not public.current_signup_profile_complete() then
      raise exception 'Saved profile remains incomplete';
    end if;
    perform set_config('request.jwt.claims', jsonb_build_object(
      'sub', a.auth_user_id, 'role', 'authenticated', 'is_anonymous', true,
      'exp', extract(epoch from now() + interval '1 hour'))::text, true);
    denied := false;
    begin perform public.current_signup_profile_complete();
    exception when insufficient_privilege then denied := true; end;
    if not denied then raise exception 'Anonymous session reached profile completion'; end if;
    perform set_config('request.jwt.claims', jsonb_build_object(
      'sub', a.auth_user_id, 'role', 'authenticated', 'is_anonymous', false,
      'exp', extract(epoch from now() - interval '1 hour'))::text, true);
    denied := false;
    begin perform public.current_signup_profile_complete();
    exception when insufficient_privilege then denied := true; end;
    if not denied then raise exception 'Expired session reached profile completion'; end if;
    checked := checked + 1;
  end loop;
  if checked < 3 then raise exception 'Existing role accounts required'; end if;
end;
$audit$;
reset role;
select 'passed: signup retries, status preservation, literal values, farm units/crops, vehicle atomicity, ownership tampering, gateway and anonymous denial; rolled back' as result;
rollback;
