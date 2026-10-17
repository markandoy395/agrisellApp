-- Read-only aggregate checks. Never returns names, contacts, addresses or IDs.
begin read only;
with profiles as (
  select 'buyer' as role, to_jsonb(u) || to_jsonb(b) as data
  from private.auth_identities i
  join public.users u on u.user_id = i.user_id
  join public.buyers b on b.buyer_user_id = i.buyer_user_id
  union all
  select 'farmer', to_jsonb(f) from public.farmers f
  union all
  select 'rider', to_jsonb(r) from public.riders r
  union all
  select 'farm', to_jsonb(f) from public.farms f
), fields(role, field) as (
  values
    ('buyer', 'first_name'), ('buyer', 'last_name'),
    ('buyer', 'extension_name'), ('buyer', 'contact_number'),
    ('buyer', 'date_of_birth'), ('buyer', 'gender'),
    ('buyer', 'shipping_address'),
    ('farmer', 'first_name'), ('farmer', 'middle_name'),
    ('farmer', 'last_name'), ('farmer', 'suffix'),
    ('farmer', 'phone_number'), ('farmer', 'date_of_birth'),
    ('farmer', 'gender'), ('farmer', 'address_line'),
    ('farmer', 'barangay'), ('farmer', 'city_municipality'),
    ('farmer', 'province'), ('farmer', 'postal_code'),
    ('farmer', 'years_of_experience'), ('farmer', 'profile_image_url'),
    ('rider', 'first_name'), ('rider', 'middle_name'),
    ('rider', 'last_name'), ('rider', 'date_of_birth'),
    ('rider', 'gender'), ('rider', 'contact_number'),
    ('rider', 'address_line'), ('rider', 'barangay'),
    ('rider', 'city_municipality'), ('rider', 'province'),
    ('rider', 'postal_code'), ('rider', 'location_label'),
    ('rider', 'location_notes'), ('rider', 'gps_lat'),
    ('rider', 'gps_long'), ('rider', 'gps_accuracy_meters'),
    ('rider', 'location_captured_at'), ('rider', 'vehicle_type'),
    ('rider', 'vehicle_plate_number'), ('rider', 'license_number'),
    ('rider', 'accepted_terms_at'), ('rider', 'accepted_privacy_at'),
    ('rider', 'confirmed_accuracy_at'), ('rider', 'profile_photo_url'),
    ('farm', 'farm_name'), ('farm', 'farm_location'), ('farm', 'barangay'),
    ('farm', 'city_municipality'), ('farm', 'province'), ('farm', 'gps_lat'),
    ('farm', 'gps_long'), ('farm', 'farm_size_hectares'),
    ('farm', 'farm_size_unit'), ('farm', 'farming_type'),
    ('farm', 'irrigation_type'), ('farm', 'ownership_type'),
    ('farm', 'main_crops'), ('farm', 'total_crops'), ('farm', 'farm_images')
), field_counts as (
  select f.role, f.field, count(p.role) as profiles,
         count(p.role) filter (
           where nullif(btrim(p.data ->> f.field), '') is null
             or p.data -> f.field = '[]'::jsonb
         ) as empty_values
  from fields f left join profiles p on p.role = f.role
  group by f.role, f.field
), link_checks as (
  select 'farmer_without_farm' as check_name, count(*) as affected
  from public.farmers f where not exists (
    select 1 from public.farms farm where farm.farmer_user_id = f.farmer_user_id
  )
  union all
  select 'identity_without_buyer', count(*) from private.auth_identities i
  where i.buyer_user_id is not null and not exists (
    select 1 from public.buyers b where b.buyer_user_id = i.buyer_user_id
  )
  union all
  select 'identity_without_rider', count(*) from private.auth_identities i
  where i.rider_id is not null and not exists (
    select 1 from public.riders r where r.rider_id = i.rider_id
  )
  union all
  select 'staged_auth_with_buyer_profile', count(*)
  from private.auth_identities i join auth.users a on a.id = i.auth_user_id
  where i.buyer_user_id is not null and a.raw_user_meta_data ? 'signup_stage'
  union all
  select 'staged_auth_with_farmer_profile', count(*)
  from private.auth_identities i join auth.users a on a.id = i.auth_user_id
  where i.farmer_user_id is not null and a.raw_user_meta_data ? 'signup_stage'
)
select jsonb_build_object(
  'field_counts', (select jsonb_agg(to_jsonb(f)) from field_counts f),
  'link_checks', (select jsonb_agg(to_jsonb(c)) from link_checks c)
) as audit;
rollback;
