begin;
-- Static owner-derived writes preserve existing role/status decisions.
CREATE OR REPLACE FUNCTION private.complete_current_buyer_registration(buyer_payload jsonb)
 RETURNS jsonb
 LANGUAGE plpgsql
 SECURITY DEFINER
 SET search_path TO ''
AS $function$
declare
  identity_record private.auth_identities%rowtype;
  target_user public.users%rowtype;
  new_user_id bigint;
  new_buyer_id bigint;
  account_email text;
  requested_role text;
begin
  perform private.require_profile_editor();
  perform public.require_rate_limited_gateway();
  if not private.current_email_is_verified() then
    raise exception 'Email verification is required' using errcode = '42501';
  end if;

  select lower(email), lower(nullif(raw_user_meta_data ->> 'requested_role', ''))
  into account_email, requested_role from auth.users
  where id = (select auth.uid());
  if requested_role is distinct from 'buyer' then
    raise exception 'An authenticated Buyer account is required'
      using errcode = '42501';
  end if;

  insert into private.auth_identities (auth_user_id)
  values ((select auth.uid())) on conflict (auth_user_id) do nothing;
  select * into identity_record from private.auth_identities
  where auth_user_id = (select auth.uid()) for update;

  if identity_record.farmer_user_id is not null
     or identity_record.rider_id is not null then
    raise exception 'An account role is already assigned';
  end if;
  if nullif(btrim(buyer_payload ->> 'first_name'), '') is null
     or nullif(btrim(buyer_payload ->> 'last_name'), '') is null
     or nullif(btrim(buyer_payload ->> 'phone_number'), '') is null
     or nullif(btrim(buyer_payload ->> 'shipping_address'), '') is null then
    raise exception 'Buyer name, phone number, and shipping address are required';
  end if;

  if buyer_payload->>'accepted_policy' is distinct from 'true' then
    raise exception 'Accept the policy before completing signup' using errcode = '22023';
  end if;
  if nullif(btrim(buyer_payload->>'gender'), '') is null or
     nullif(buyer_payload->>'date_of_birth', '')::date is null then
    raise exception 'Gender and birth date are required' using errcode = '22023';
  end if;
  if identity_record.user_id is null then
    insert into public.users (
      first_name, last_name, extension_name, email, contact_number,
      account_status, gender, date_of_birth, accepted_policy_at
    ) values (
      btrim(buyer_payload ->> 'first_name'),
      btrim(buyer_payload ->> 'last_name'),
      nullif(btrim(buyer_payload ->> 'extension_name'), ''),
      account_email,
      btrim(buyer_payload ->> 'phone_number'),
      'active',
      nullif(btrim(buyer_payload ->> 'gender'), ''),
      nullif(buyer_payload ->> 'date_of_birth', '')::date, now()
    ) returning * into target_user;
    new_user_id := target_user.user_id;
  else
    update public.users set
      first_name = btrim(buyer_payload ->> 'first_name'),
      last_name = btrim(buyer_payload ->> 'last_name'),
      extension_name = nullif(btrim(buyer_payload ->> 'extension_name'), ''),
      email = account_email,
      contact_number = btrim(buyer_payload ->> 'phone_number'),
      accepted_policy_at = coalesce(accepted_policy_at, now()),
      gender = nullif(btrim(buyer_payload ->> 'gender'), ''),
      date_of_birth = nullif(buyer_payload ->> 'date_of_birth', '')::date,
      updated_at = now()
    where user_id = identity_record.user_id
    returning * into target_user;
    new_user_id := identity_record.user_id;
  end if;

  if identity_record.buyer_user_id is null then
    insert into public.buyers (user_id, shipping_address, user_type)
    values (new_user_id, btrim(buyer_payload->>'shipping_address'), 'buyer')
    returning buyer_user_id into new_buyer_id;
  else
    update public.buyers set shipping_address = btrim(buyer_payload->>'shipping_address')
    where buyer_user_id = identity_record.buyer_user_id and user_id = new_user_id
    returning buyer_user_id into new_buyer_id;
    if not found then raise exception 'Buyer identity is inconsistent'; end if;
  end if;
  update private.auth_identities set
    user_id = new_user_id,
    buyer_user_id = new_buyer_id
  where auth_user_id = (select auth.uid());
  update auth.users set raw_user_meta_data = raw_user_meta_data - 'signup_stage'
  where id = (select auth.uid());
  return to_jsonb(target_user);
end;
$function$;


CREATE OR REPLACE FUNCTION private.complete_current_farmer_registration(farmer_payload jsonb)
 RETURNS jsonb
 LANGUAGE plpgsql
 SECURITY DEFINER
 SET search_path TO ''
AS $function$
declare
  identity_record private.auth_identities%rowtype;
  target_farmer public.farmers%rowtype;
  new_farmer_id bigint;
  requested_role text;
begin
  perform private.require_profile_editor();
  perform public.require_rate_limited_gateway();
  if not private.current_email_is_verified() then
    raise exception 'Email verification is required' using errcode = '42501';
  end if;

  select lower(nullif(raw_user_meta_data ->> 'requested_role', ''))
  into requested_role from auth.users where id = (select auth.uid());
  if requested_role is distinct from 'farmer' then
    raise exception 'An authenticated Farmer account is required'
      using errcode = '42501';
  end if;

  insert into private.auth_identities (auth_user_id)
  values ((select auth.uid())) on conflict (auth_user_id) do nothing;
  select * into identity_record from private.auth_identities
  where auth_user_id = (select auth.uid()) for update;

  if identity_record.buyer_user_id is not null
     or identity_record.rider_id is not null then
    raise exception 'An account role is already assigned';
  end if;
  if nullif(btrim(farmer_payload ->> 'first_name'), '') is null
     or nullif(btrim(farmer_payload ->> 'last_name'), '') is null
     or nullif(btrim(farmer_payload ->> 'phone_number'), '') is null
     or nullif(btrim(farmer_payload ->> 'farm_name'), '') is null
     or nullif(btrim(farmer_payload ->> 'farm_location'), '') is null
     or nullif(farmer_payload ->> 'latitude', '') is null
     or nullif(farmer_payload ->> 'longitude', '') is null
     or nullif(farmer_payload ->> 'years_of_experience', '') is null then
    raise exception 'Farmer details, farm location, and years of experience are required';
  end if;
  if nullif(btrim(farmer_payload->>'gender'), '') is null
     or nullif(farmer_payload->>'date_of_birth', '')::date is null
     or nullif(btrim(farmer_payload->>'address_line'), '') is null
     or nullif(btrim(farmer_payload->>'barangay'), '') is null
     or nullif(btrim(farmer_payload->>'city_municipality'), '') is null
     or nullif(btrim(farmer_payload->>'province'), '') is null
     or (farmer_payload->>'years_of_experience')::integer < 0
     or (farmer_payload->>'latitude')::numeric not between -90 and 90
     or (farmer_payload->>'longitude')::numeric not between -180 and 180 then
    raise exception 'Complete valid personal and farm details' using errcode = '22023';
  end if;

  insert into public.farmers (
    auth_user_id, first_name, middle_name, last_name, suffix, phone_number,
    date_of_birth, gender, address_line, barangay, city_municipality,
    province, postal_code, years_of_experience, verification_status,
    account_status, registration_date
  ) values (
    (select auth.uid()), btrim(farmer_payload ->> 'first_name'),
    nullif(btrim(farmer_payload ->> 'middle_name'), ''),
    btrim(farmer_payload ->> 'last_name'),
    nullif(btrim(farmer_payload ->> 'suffix'), ''),
    btrim(farmer_payload ->> 'phone_number'),
    nullif(farmer_payload ->> 'date_of_birth', '')::date,
    nullif(btrim(farmer_payload ->> 'gender'), ''),
    nullif(btrim(farmer_payload ->> 'address_line'), ''),
    nullif(btrim(farmer_payload ->> 'barangay'), ''),
    nullif(btrim(farmer_payload ->> 'city_municipality'), ''),
    nullif(btrim(farmer_payload ->> 'province'), ''),
    nullif(btrim(farmer_payload ->> 'postal_code'), ''),
    nullif(farmer_payload ->> 'years_of_experience', '')::integer,
    'pending', 'active', current_date
  ) on conflict (auth_user_id) do update set
    first_name = excluded.first_name,
    middle_name = excluded.middle_name,
    last_name = excluded.last_name,
    suffix = excluded.suffix,
    phone_number = excluded.phone_number,
    date_of_birth = excluded.date_of_birth,
    gender = excluded.gender,
    address_line = excluded.address_line,
    barangay = excluded.barangay,
    city_municipality = excluded.city_municipality,
    province = excluded.province,
    postal_code = excluded.postal_code,
    years_of_experience = excluded.years_of_experience
  returning * into target_farmer;
  new_farmer_id := target_farmer.farmer_user_id;

  update public.farms set
    farm_name = btrim(farmer_payload->>'farm_name'),
    farm_location = btrim(farmer_payload->>'farm_location'),
    barangay = nullif(btrim(farmer_payload->>'farm_barangay'), ''),
    city_municipality = nullif(btrim(farmer_payload->>'farm_city_municipality'), ''),
    province = nullif(btrim(farmer_payload->>'farm_province'), ''),
    gps_lat = (farmer_payload->>'latitude')::numeric,
    gps_long = (farmer_payload->>'longitude')::numeric,
    farm_size = (farmer_payload->>'farm_size')::numeric,
    farm_size_unit = btrim(farmer_payload->>'farm_size_unit'),
    main_crops = array(select jsonb_array_elements_text(coalesce(farmer_payload->'main_crops','[]'::jsonb))),
    farming_type = nullif(btrim(farmer_payload->>'farming_type'), ''),
    irrigation_type = nullif(btrim(farmer_payload->>'irrigation_type'), ''),
    ownership_type = nullif(btrim(farmer_payload->>'ownership_type'), '')
  where farm_id = (select farm_id from public.farms where farmer_user_id = new_farmer_id order by farm_id limit 1);
  if not found then
  insert into public.farms (
    farmer_user_id, farm_name, farm_location, barangay, city_municipality,
    province, gps_lat, gps_long, total_crops, farm_size_hectares,
    farm_size_unit, farming_type, irrigation_type, ownership_type, main_crops
  ) values (
    new_farmer_id, btrim(farmer_payload ->> 'farm_name'),
    btrim(farmer_payload ->> 'farm_location'),
    nullif(btrim(farmer_payload ->> 'farm_barangay'), ''),
    nullif(btrim(farmer_payload ->> 'farm_city_municipality'), ''),
    nullif(btrim(farmer_payload ->> 'farm_province'), ''),
    (farmer_payload ->> 'latitude')::numeric,
    (farmer_payload ->> 'longitude')::numeric,
    coalesce(nullif(farmer_payload ->> 'total_crops', '')::integer,
      jsonb_array_length(coalesce(farmer_payload -> 'main_crops', '[]'::jsonb))),
    nullif(farmer_payload ->> 'farm_size', '')::numeric,
    nullif(btrim(farmer_payload ->> 'farm_size_unit'), ''),
    nullif(btrim(farmer_payload ->> 'farming_type'), ''),
    nullif(btrim(farmer_payload ->> 'irrigation_type'), ''),
    nullif(btrim(farmer_payload ->> 'ownership_type'), ''),
    array(select jsonb_array_elements_text(
      coalesce(farmer_payload -> 'main_crops', '[]'::jsonb)))
  );
  end if;
  update private.auth_identities set farmer_user_id = new_farmer_id
  where auth_user_id = (select auth.uid());
  update auth.users set raw_user_meta_data = raw_user_meta_data - 'signup_stage'
  where id = (select auth.uid());
  return to_jsonb(target_farmer);
end;
$function$;


CREATE OR REPLACE FUNCTION private.create_current_rider_registration(rider_payload jsonb)
 RETURNS jsonb
 LANGUAGE plpgsql
 SECURITY DEFINER
 SET search_path TO ''
AS $function$
declare
  identity_record private.auth_identities%rowtype;
  target_rider public.riders%rowtype;
  account_email text;
  requested_role text;
  selected_company_id bigint;
begin
  perform private.require_profile_editor();
  perform public.require_rate_limited_gateway();
  if not private.current_email_is_verified() then
    raise exception 'Email verification is required' using errcode = '42501';
  end if;
  if nullif(btrim(rider_payload->>'first_name'), '') is null
     or nullif(btrim(rider_payload->>'last_name'), '') is null
     or nullif(btrim(rider_payload->>'contact_number'), '') is null
     or nullif(btrim(rider_payload->>'vehicle_type'), '') is null
     or nullif(btrim(rider_payload->>'gender'), '') is null
     or nullif(rider_payload->>'date_of_birth', '')::date is null
     or nullif(btrim(rider_payload->>'address_line'), '') is null
     or nullif(btrim(rider_payload->>'barangay'), '') is null
     or nullif(btrim(rider_payload->>'city_municipality'), '') is null
     or nullif(btrim(rider_payload->>'province'), '') is null
     or rider_payload->>'accepted_terms' is distinct from 'true'
     or rider_payload->>'accepted_privacy' is distinct from 'true'
     or rider_payload->>'confirmed_accuracy' is distinct from 'true' then
    raise exception 'Complete Rider details and accept the agreements' using errcode = '22023';
  end if;
  select * into identity_record from private.auth_identities
  where auth_user_id = (select auth.uid()) for update;

  if not found then
    select lower(nullif(raw_user_meta_data ->> 'requested_role', ''))
    into requested_role from auth.users where id = (select auth.uid());
    if requested_role is distinct from 'rider' then
      raise exception 'An authenticated Rider account is required';
    end if;
    insert into private.auth_identities (auth_user_id)
    values ((select auth.uid()))
    returning * into identity_record;
  end if;

  if identity_record.buyer_user_id is not null
     or identity_record.farmer_user_id is not null then
    raise exception 'An account role is already assigned';
  end if;
  if identity_record.rider_id is not null then
    if rider_payload->>'vehicle_type' is distinct from
       (select vehicle_type from public.riders where rider_id = identity_record.rider_id) then
      raise exception 'Vehicle type changes require verification' using errcode = '22023';
    end if;
    update public.riders set
      first_name = btrim(rider_payload->>'first_name'),
      last_name = btrim(rider_payload->>'last_name'),
      contact_number = btrim(rider_payload->>'contact_number'),
      vehicle_type = btrim(rider_payload->>'vehicle_type'),
      middle_name = nullif(btrim(rider_payload->>'middle_name'), ''),
      gender = nullif(btrim(rider_payload->>'gender'), ''),
      location_label = nullif(btrim(rider_payload->>'location_label'), ''),
      location_notes = nullif(btrim(rider_payload->>'location_notes'), ''),
      address_line = nullif(btrim(rider_payload->>'address_line'), ''),
      barangay = nullif(btrim(rider_payload->>'barangay'), ''),
      city_municipality = nullif(btrim(rider_payload->>'city_municipality'), ''),
      province = nullif(btrim(rider_payload->>'province'), ''),
      postal_code = nullif(btrim(rider_payload->>'postal_code'), ''),
      license_number = nullif(upper(btrim(rider_payload->>'license_number')), ''),
      vehicle_plate_number = nullif(upper(btrim(rider_payload->>'vehicle_plate_number')), ''),
      gps_lat = nullif(rider_payload->>'gps_lat', '')::numeric,
      gps_long = nullif(rider_payload->>'gps_long', '')::numeric,
      gps_accuracy_meters = nullif(rider_payload->>'gps_accuracy_meters', '')::numeric,
      date_of_birth = nullif(rider_payload->>'date_of_birth', '')::date,
      location_captured_at = nullif(rider_payload->>'location_captured_at', '')::timestamptz,
      full_name = concat_ws(' ', btrim(rider_payload->>'first_name'), nullif(btrim(rider_payload->>'middle_name'), ''), btrim(rider_payload->>'last_name')),
      accepted_terms_at = coalesce(accepted_terms_at, case when rider_payload->>'accepted_terms' = 'true' then now() end),
      accepted_privacy_at = coalesce(accepted_privacy_at, case when rider_payload->>'accepted_privacy' = 'true' then now() end),
      confirmed_accuracy_at = coalesce(confirmed_accuracy_at, case when rider_payload->>'confirmed_accuracy' = 'true' then now() end)
    where rider_id = identity_record.rider_id returning * into target_rider;
    update auth.users set raw_user_meta_data = raw_user_meta_data - 'signup_stage' - 'rider_application' where id = auth.uid();
    return to_jsonb(target_rider);
  end if;
  select lower(email) into account_email from auth.users
  where id = identity_record.auth_user_id;
  if nullif(btrim(rider_payload ->> 'first_name'), '') is null
     or nullif(btrim(rider_payload ->> 'last_name'), '') is null
     or nullif(btrim(rider_payload ->> 'contact_number'), '') is null
     or nullif(btrim(rider_payload ->> 'vehicle_type'), '') is null then
    raise exception 'Rider name, contact, and vehicle type are required';
  end if;

  selected_company_id := nullif(
    btrim(rider_payload ->> 'logistics_company_id'), ''
  )::bigint;
  if selected_company_id is not null and not exists (
    select 1 from public.logistics_companies as company
    where company.logistics_company_id = selected_company_id
      and coalesce(lower(nullif(btrim(company.status), '')), 'active') = 'active'
  ) then
    raise exception 'The selected logistics company is unavailable';
  end if;

  insert into public.riders (
    logistics_company_id, license_number, full_name, vehicle_type,
    vehicle_plate_number, availability_status, first_name, middle_name,
    last_name, contact_number, email, gps_lat, gps_long,
    gps_accuracy_meters, location_captured_at, location_label, location_notes,
    address_line, barangay, city_municipality, province, postal_code,
    date_of_birth, gender, total_deliveries, employment_status,
    profile_photo_url, accepted_terms_at, accepted_privacy_at,
    confirmed_accuracy_at
  ) values (
    selected_company_id,
    nullif(upper(btrim(rider_payload ->> 'license_number')), ''),
    concat_ws(' ', btrim(rider_payload ->> 'first_name'),
      nullif(btrim(rider_payload ->> 'middle_name'), ''),
      btrim(rider_payload ->> 'last_name')),
    btrim(rider_payload ->> 'vehicle_type'),
    nullif(upper(btrim(rider_payload ->> 'vehicle_plate_number')), ''),
    'offline', btrim(rider_payload ->> 'first_name'),
    nullif(btrim(rider_payload ->> 'middle_name'), ''),
    btrim(rider_payload ->> 'last_name'),
    btrim(rider_payload ->> 'contact_number'), account_email,
    nullif(rider_payload ->> 'gps_lat', '')::numeric,
    nullif(rider_payload ->> 'gps_long', '')::numeric,
    nullif(rider_payload ->> 'gps_accuracy_meters', '')::numeric,
    nullif(rider_payload ->> 'location_captured_at', '')::timestamptz,
    nullif(btrim(rider_payload ->> 'location_label'), ''),
    nullif(btrim(rider_payload ->> 'location_notes'), ''),
    nullif(btrim(rider_payload ->> 'address_line'), ''),
    nullif(btrim(rider_payload ->> 'barangay'), ''),
    nullif(btrim(rider_payload ->> 'city_municipality'), ''),
    nullif(btrim(rider_payload ->> 'province'), ''),
    nullif(btrim(rider_payload ->> 'postal_code'), ''),
    nullif(rider_payload ->> 'date_of_birth', '')::date,
    nullif(btrim(rider_payload ->> 'gender'), ''),
    0, 'active', null,
    case when rider_payload ->> 'accepted_terms' = 'true' then now() end,
    case when rider_payload ->> 'accepted_privacy' = 'true' then now() end,
    case when rider_payload ->> 'confirmed_accuracy' = 'true' then now() end
  ) returning * into target_rider;

  update private.auth_identities set rider_id = target_rider.rider_id
  where auth_user_id = identity_record.auth_user_id;
  update auth.users
  set raw_user_meta_data = raw_user_meta_data - 'rider_application'
  where id = identity_record.auth_user_id;
  return to_jsonb(target_rider);
end;
$function$;


revoke all on function private.complete_current_buyer_registration(jsonb), private.complete_current_farmer_registration(jsonb), private.create_current_rider_registration(jsonb) from public, anon;
grant execute on function private.complete_current_buyer_registration(jsonb), private.complete_current_farmer_registration(jsonb), private.create_current_rider_registration(jsonb) to authenticated, service_role;
commit;
