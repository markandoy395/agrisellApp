begin;

alter table public.farmers
  add column if not exists farm_details_skipped boolean not null default false;

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
  skip_farm boolean := coalesce((farmer_payload ->> 'farm_details_skipped')::boolean, false);
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
     or nullif(btrim(farmer_payload ->> 'phone_number'), '') is null then
    raise exception 'Farmer name and phone number are required';
  end if;
  if not skip_farm and (
     nullif(btrim(farmer_payload ->> 'farm_name'), '') is null
     or nullif(btrim(farmer_payload ->> 'farm_location'), '') is null
     or nullif(farmer_payload ->> 'latitude', '') is null
     or nullif(farmer_payload ->> 'longitude', '') is null
     or nullif(farmer_payload ->> 'years_of_experience', '') is null) then
    raise exception 'Farm details and years of experience are required';
  end if;
  if nullif(btrim(farmer_payload->>'gender'), '') is null
     or nullif(farmer_payload->>'date_of_birth', '')::date is null
     or nullif(btrim(farmer_payload->>'address_line'), '') is null
     or nullif(btrim(farmer_payload->>'barangay'), '') is null
     or nullif(btrim(farmer_payload->>'city_municipality'), '') is null
     or nullif(btrim(farmer_payload->>'province'), '') is null
     or (not skip_farm and ((farmer_payload->>'years_of_experience')::integer < 0
     or (farmer_payload->>'latitude')::numeric not between -90 and 90
     or (farmer_payload->>'longitude')::numeric not between -180 and 180)) then
    raise exception 'Complete valid personal and farm details' using errcode = '22023';
  end if;

  insert into public.farmers (
    auth_user_id, first_name, middle_name, last_name, suffix, phone_number,
    date_of_birth, gender, address_line, barangay, city_municipality,
    province, postal_code, years_of_experience, verification_status,
    account_status, registration_date, farm_details_skipped
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
    case when not skip_farm then nullif(farmer_payload ->> 'years_of_experience', '')::integer end,
    'pending', 'active', current_date, skip_farm
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
    years_of_experience = coalesce(excluded.years_of_experience, farmers.years_of_experience),
    farm_details_skipped = excluded.farm_details_skipped
  returning * into target_farmer;
  new_farmer_id := target_farmer.farmer_user_id;

  if not skip_farm then
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
  end if;
  update private.auth_identities set farmer_user_id = new_farmer_id
  where auth_user_id = (select auth.uid());
  update auth.users set raw_user_meta_data = raw_user_meta_data - 'signup_stage'
  where id = (select auth.uid());
  return to_jsonb(target_farmer);
end;
$function$;

revoke all on function private.complete_current_farmer_registration(jsonb) from public, anon;
grant execute on function private.complete_current_farmer_registration(jsonb) to authenticated, service_role;

create or replace function public.current_signup_profile_complete()
returns boolean language plpgsql security definer set search_path = '' as $$
declare caller uuid := private.require_profile_editor(); i private.auth_identities%rowtype;
begin
  select * into i from private.auth_identities where auth_user_id = caller;
  if not found then return false; end if;
  if i.buyer_user_id is not null then
    return exists (select 1 from public.users u join public.buyers b on b.user_id = u.user_id
      where u.user_id = i.user_id and b.buyer_user_id = i.buyer_user_id
      and nullif(btrim(u.first_name), '') is not null and nullif(btrim(u.last_name), '') is not null
      and nullif(btrim(u.contact_number), '') is not null and u.date_of_birth is not null
      and nullif(btrim(u.gender), '') is not null and nullif(btrim(b.shipping_address), '') is not null);
  elsif i.farmer_user_id is not null then
    return exists (select 1 from public.farmers f
      where f.farmer_user_id = i.farmer_user_id and f.auth_user_id = caller
      and nullif(btrim(f.first_name), '') is not null and nullif(btrim(f.last_name), '') is not null
      and nullif(btrim(f.phone_number), '') is not null and f.date_of_birth is not null
      and nullif(btrim(f.gender), '') is not null
      and nullif(btrim(f.address_line), '') is not null and nullif(btrim(f.barangay), '') is not null
      and nullif(btrim(f.city_municipality), '') is not null and nullif(btrim(f.province), '') is not null
      and (f.farm_details_skipped or (f.years_of_experience is not null and exists (
        select 1 from public.farms farm where farm.farmer_user_id = f.farmer_user_id
        and nullif(btrim(farm.farm_name), '') is not null
        and farm.gps_lat is not null and farm.gps_long is not null))));
  elsif i.rider_id is not null then
    return exists (select 1 from public.riders r where r.rider_id = i.rider_id
      and nullif(btrim(r.first_name), '') is not null and nullif(btrim(r.last_name), '') is not null
      and nullif(btrim(r.contact_number), '') is not null and r.date_of_birth is not null
      and nullif(btrim(r.gender), '') is not null and nullif(btrim(r.address_line), '') is not null
      and nullif(btrim(r.barangay), '') is not null and nullif(btrim(r.city_municipality), '') is not null
      and nullif(btrim(r.province), '') is not null and r.accepted_terms_at is not null
      and r.accepted_privacy_at is not null and r.confirmed_accuracy_at is not null);
  end if;
  return false;
end;
$$;
revoke all on function public.current_signup_profile_complete() from public, anon;
grant execute on function public.current_signup_profile_complete() to authenticated, service_role;

-- Approval is optional for product creation. Session, active account, farm
-- ownership, and category/farm consistency remain mandatory.
drop policy if exists categories_owner_insert on public.categories;
create policy categories_owner_insert on public.categories for insert to authenticated
with check (
  not coalesce((auth.jwt() ->> 'is_anonymous')::boolean, true)
  and coalesce((auth.jwt() ->> 'exp')::numeric, 0) > extract(epoch from now())
  and exists (
    select 1 from public.farms farm
    join public.farmers farmer using (farmer_user_id)
    where farm.farm_id = categories.farm_id
      and farmer.auth_user_id = (select auth.uid())
      and lower(farmer.account_status) = 'active'
      and lower(farmer.verification_status) in ('pending', 'verified', 'needs_information')
  )
);
drop policy if exists commodities_owner_insert on public.commodities;
create policy commodities_owner_insert on public.commodities for insert to authenticated
with check (
  not coalesce((auth.jwt() ->> 'is_anonymous')::boolean, true)
  and coalesce((auth.jwt() ->> 'exp')::numeric, 0) > extract(epoch from now())
  and exists (
    select 1 from public.categories category
    join public.farms farm on farm.farm_id = category.farm_id
    join public.farmers farmer using (farmer_user_id)
    where category.category_id = commodities.category_id
      and category.farm_id = commodities.farm_id
      and farmer.auth_user_id = (select auth.uid())
      and lower(farmer.account_status) = 'active'
      and lower(farmer.verification_status) in ('pending', 'verified', 'needs_information')
  )
);

commit;
