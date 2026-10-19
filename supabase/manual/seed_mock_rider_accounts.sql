-- Part 1. Run with seed_mock_rider_deliveries.sql and seed_mock_rider_activity.sql
-- in one transaction. The final part commits. Requires marketplace_mock_v1 data.
-- Logins: mock.rider01@example.com through 30; password AgrisellTest!2026.
begin;
set local lock_timeout = '5s';
set local statement_timeout = '90s';
select pg_advisory_xact_lock(hashtext('rider_mock_v1'));
select set_config('request.jwt.claims', '{"role":"service_role"}', true);
select set_config('request.jwt.claim.role', 'service_role', true);
-- Prevent synthetic test events from dispatching push requests. Restored before commit.
alter table public.notifications disable trigger notifications_dispatch_push_after_insert;
create temporary table mock_rider_context (
  n integer, auth_id uuid, rider_id uuid, buyer_id bigint, buyer_auth uuid,
  farmer_id bigint, farmer_auth uuid, farm_id bigint, commodity_id bigint,
  price numeric, cart_id bigint
) on commit drop;

do $accounts$
declare
  n integer; a uuid; r uuid; buyer_record record; product_record record;
  email_value text; phone_value text; cart_value bigint;
begin
  for n in 1..30 loop
    email_value := 'mock.rider' || lpad(n::text, 2, '0') || '@example.com';
    phone_value := '093' || lpad(n::text, 8, '0');
    select id into a from auth.users where email = email_value;
    if a is not null then
      if not exists (select 1 from auth.users where id = a
        and raw_app_meta_data ->> 'test_seed' = 'rider_mock_v1') then
        raise exception 'Mock rider email collision';
      end if;
      select rider_id into r from private.auth_identities where auth_user_id = a;
    else
      a := extensions.gen_random_uuid(); r := extensions.gen_random_uuid();
      insert into auth.users (instance_id, id, aud, role, email, encrypted_password,
        email_confirmed_at, raw_app_meta_data, raw_user_meta_data, created_at,
        updated_at, confirmation_token, recovery_token, email_change_token_new, email_change)
      values ('00000000-0000-0000-0000-000000000000', a, 'authenticated',
        'authenticated', email_value,
        extensions.crypt('AgrisellTest!2026', extensions.gen_salt('bf')), now(),
        '{"provider":"email","providers":["email"],"test_seed":"rider_mock_v1"}',
        jsonb_build_object('requested_role', 'rider', 'first_name', 'Sample Rider',
          'last_name', lpad(n::text, 2, '0')), now(), now(), '', '', '', '');
      insert into auth.identities (provider_id, user_id, identity_data, provider,
        created_at, updated_at) values (a::text, a,
        jsonb_build_object('sub', a::text, 'email', email_value, 'email_verified', true),
        'email', now(), now());
      insert into public.riders (rider_id, first_name, last_name, full_name,
        email, contact_number, license_number, vehicle_type, vehicle_plate_number,
        employment_status, availability_status, gps_lat, gps_long,
        date_of_birth, gender, address_line, barangay, city_municipality,
        province, postal_code, location_label, accepted_terms_at,
        accepted_privacy_at, confirmed_accuracy_at, maximum_active_deliveries,
        capacity_kg, maximum_capacity_kg, vehicle_brand, vehicle_model,
        vehicle_color, registration_number, total_deliveries)
      values (r, 'Sample Rider', lpad(n::text, 2, '0'), 'Sample Rider ' || n,
        email_value, phone_value, 'SAMPLE-LICENSE-' || n,
        case n % 3 when 1 then 'motorcycle' when 2 then 'tricycle' else 'van' end,
        'TEST-' || lpad(n::text, 3, '0'), 'active', 'offline',
        8.15 + n * 0.001, 125.12 + n * 0.001, '1995-01-15',
        case when n % 2 = 0 then 'Female' else 'Male' end,
        'Sample Lot ' || n, 'San Jose', 'Malaybalay', 'Bukidnon', '8700',
        'Sample test location, Malaybalay', now(), now(), now(), 3,
        30, 100, 'Sample Brand', 'Test Model', 'Green', 'SAMPLE-REG-' || n, 20);
      insert into private.auth_identities (auth_user_id, rider_id) values (a, r);
      insert into public.rider_locations (rider_id, latitude, longitude,
        accuracy_meters, heading, speed_kph, location_updated_at)
      values (r, 8.15 + n * 0.001, 125.12 + n * 0.001, 10, 90, 0, now());
      insert into public.rider_documents (rider_id, vehicle_id, document_type,
        document_number, file_path, verification_status, expiry_date)
      select r, case when d like 'vehicle_%' then r end, d,
        'SAMPLE-ONLY-' || n, a::text || '/sample-rider-document.png',
        'verified', current_date + 365
      from unnest(array['drivers_license','valid_id','profile_selfie',
        'vehicle_or','vehicle_cr','vehicle_photo']) d;
    end if;
    if r is null then raise exception 'Missing mock rider identity'; end if;
    select i.buyer_user_id, a.id into strict buyer_record
    from auth.users a join private.auth_identities i on i.auth_user_id = a.id
    where a.email = 'mock.buyer' || lpad(n::text, 2, '0') || '@example.com'
      and a.raw_app_meta_data ->> 'test_seed' = 'marketplace_mock_v1';
    select f.farmer_user_id, f.auth_user_id, farm.farm_id,
      c.commodity_id, c.price_per_unit into strict product_record
    from auth.users a join public.farmers f on f.auth_user_id = a.id
    join public.farms farm using (farmer_user_id)
    join public.commodities c using (farm_id)
    where a.email = 'mock.farmer' || lpad(n::text, 2, '0') || '@example.com'
      and a.raw_app_meta_data ->> 'test_seed' = 'marketplace_mock_v1'
      and c.availability_status = 'ready_now'
    order by c.commodity_id limit 1;
    select cart_id into cart_value from public.carts
    where buyer_user_id = buyer_record.buyer_user_id and cart_status = 'sample_rider_test';
    if cart_value is null then
      insert into public.carts (buyer_user_id, cart_status)
      values (buyer_record.buyer_user_id, 'sample_rider_test') returning cart_id into cart_value;
    end if;
    insert into mock_rider_context values (n, a, r, buyer_record.buyer_user_id,
      buyer_record.id, product_record.farmer_user_id, product_record.auth_user_id,
      product_record.farm_id, product_record.commodity_id,
      product_record.price_per_unit, cart_value);
  end loop;
end;
$accounts$;
