-- Explicit test seed: 30 farmers, 30 buyers, and 90 products (3 per farmer).
-- Run as the database owner. Re-running skips this seed's existing accounts.
-- Login: mock.farmer01@example.com / mock.buyer01@example.com, through 30.
-- Password for these synthetic accounts only: AgrisellTest!2026
begin;

do $seed$
declare
  seed_tag constant text := 'marketplace_mock_v1';
  role_name text;
  n integer;
  p integer;
  email_value text;
  auth_id uuid;
  app_user_id bigint;
  buyer_id bigint;
  farmer_id bigint;
  farm_id_value bigint;
  category_id_value bigint;
  metadata jsonb;
  first_name_value text;
  last_name_value text;
  phone_value text;
  address_value text;
  product_name text;
  category_name_value text;
  product_names text[] := array[
    'Tomatoes', 'Eggplant', 'Pechay', 'Carrots', 'Squash',
    'Cucumber', 'String Beans', 'Sweet Potato', 'Bananas', 'Mangoes',
    'Papaya', 'Pineapple', 'Calamansi', 'Watermelon', 'Avocado',
    'Rice', 'Corn', 'Peanuts', 'Mung Beans', 'Coffee Beans',
    'Ginger', 'Garlic', 'Onions', 'Chili Peppers', 'Lemongrass',
    'Lettuce', 'Cabbage', 'Broccoli', 'Bitter Gourd', 'Okra'
  ];
  first_names text[] := array['Maria', 'Jose', 'Ana', 'Carlo', 'Elena', 'Paolo',
    'Rosa', 'Miguel', 'Liza', 'Ramon'];
  last_names text[] := array['Santos', 'Reyes', 'Cruz', 'Garcia', 'Ramos',
    'Mendoza', 'Torres', 'Flores', 'Navarro', 'Castillo'];
begin
  perform pg_advisory_xact_lock(hashtext(seed_tag));
  foreach role_name in array array['farmer', 'buyer'] loop
    for n in 1..30 loop
      email_value := 'mock.' || role_name || lpad(n::text, 2, '0') || '@example.com';
      auth_id := null;
      select id into auth_id from auth.users where email = email_value;
      if auth_id is not null then
        if not exists (select 1 from auth.users where id = auth_id
          and raw_app_meta_data ->> 'test_seed' = seed_tag) then
          raise exception 'Mock email collision: %; no changes committed', email_value;
        end if;
        continue;
      end if;

      auth_id := extensions.gen_random_uuid();
      first_name_value := first_names[1 + (n - 1) % 10];
      last_name_value := 'Mock ' || last_names[1 + (n + 2) % 10] || ' ' || n;
      phone_value := '09' || lpad((case when role_name = 'farmer' then 100000000
        else 200000000 end + n)::text, 9, '0');
      address_value := 'Mock Lot ' || n || ', San Jose, Malaybalay, Bukidnon';
      metadata := jsonb_build_object(
        'requested_role', role_name, 'first_name', first_name_value,
        'last_name', last_name_value, 'phone_number', phone_value,
        'date_of_birth', '1990-01-15', 'gender', case when n % 2 = 0
          then 'Male' else 'Female' end,
        'address_line', 'Mock Lot ' || n, 'barangay', 'San Jose',
        'city_municipality', 'Malaybalay', 'province', 'Bukidnon',
        'postal_code', '8700', 'years_of_experience', 1 + n % 20,
        'farm_name', 'Mock Farm ' || lpad(n::text, 2, '0'),
        'farm_location', address_value, 'farm_barangay', 'San Jose',
        'farm_city_municipality', 'Malaybalay', 'farm_province', 'Bukidnon',
        'latitude', 8.15 + n * 0.001, 'longitude', 125.12 + n * 0.001,
        'farm_size', 1 + n * 0.1, 'farm_size_unit', 'hectares',
        'farming_type', 'Mixed farming', 'irrigation_type', 'Rainfed',
        'ownership_type', 'Owned', 'main_crops', jsonb_build_array(product_names[n]));

      -- Use the existing signup trigger to provision the correct role/identity.
      insert into auth.users (instance_id, id, aud, role, email, encrypted_password,
        email_confirmed_at, raw_app_meta_data, raw_user_meta_data,
        created_at, updated_at, confirmation_token, recovery_token,
        email_change_token_new, email_change)
      values ('00000000-0000-0000-0000-000000000000', auth_id,
        'authenticated', 'authenticated', email_value,
        extensions.crypt('AgrisellTest!2026', extensions.gen_salt('bf')),
        now(), jsonb_build_object('provider', 'email', 'providers',
          jsonb_build_array('email'), 'test_seed', seed_tag), metadata,
        now(), now(), '', '', '', '');
      insert into auth.identities (provider_id, user_id, identity_data, provider,
        created_at, updated_at)
      values (auth_id::text, auth_id, jsonb_build_object('sub', auth_id::text,
        'email', email_value, 'email_verified', true, 'phone_verified', false),
        'email', now(), now());

      if role_name = 'buyer' then
        select user_id, buyer_user_id into app_user_id, buyer_id
          from private.auth_identities where auth_user_id = auth_id;
        if buyer_id is null then raise exception 'Buyer provisioning failed'; end if;
        update public.users set accepted_policy_at = now() where user_id = app_user_id;
        update public.buyers set shipping_address = address_value,
          loyalty_points = n * 10,
          preferred_payment_method = case when n % 2 = 0 then 'GCash' else 'COD' end,
          gps_lat = 8.15 + n * 0.001, gps_long = 125.12 + n * 0.001
          where buyer_user_id = buyer_id;
      else
        select farmer_user_id into farmer_id from private.auth_identities
          where auth_user_id = auth_id;
        if farmer_id is null then raise exception 'Farmer provisioning failed'; end if;
        update public.farmers set verification_status = 'verified'
          where farmer_user_id = farmer_id;
        select farm_id into farm_id_value from public.farms
          where farmer_user_id = farmer_id order by farm_id limit 1;
        if farm_id_value is null then raise exception 'Farm provisioning failed'; end if;
        category_name_value := case when n <= 8 then 'Vegetables'
          when n <= 15 then 'Fruits' when n <= 20 then 'Grains'
          when n <= 25 then 'Herbs and Spices' else 'Vegetables' end;
        insert into public.categories (category_name, description, status, farm_id)
          values (category_name_value, 'Mock marketplace testing category',
            'active', farm_id_value) returning category_id into category_id_value;
        for p in 1..3 loop
          product_name := product_names[n] || case p when 1 then ' (Mock Fresh)'
            when 2 then ' (Mock Organic)' else ' (Mock Pre-order)' end;
          insert into public.commodities (category_id, farm_id, commodity_name,
            description, price_per_unit, unit_type, available_quantity,
            harvest_date, production_status, availability_status, is_organic,
            commodity_status, minimum_order_quantity, grade_quality,
            inventory_date_type)
          values (category_id_value, farm_id_value, product_name,
            'Synthetic product for marketplace testing from Mock Farm ' || n,
            25 + n * 3 + p * 5, 'kg', 40 + n * 5 + p * 10,
            timezone('Asia/Manila', now())::date + case when p = 3 then 7 else 0 end,
            case when p = 3 then 'harvesting_soon' else 'harvested' end,
            case when p = 3 then 'pre_order' else 'ready_now' end,
            p = 2, 'available', 1, 'A', 'fresh_produce');
        end loop;
      end if;
    end loop;
  end loop;
  -- Buyer home reads sellable inventory batches rather than the product's
  -- available_quantity alone. Repair missing batches when re-running the seed.
  insert into public.commodity_inventory_lots (
    commodity_id, date_type, quantity_received, quantity_remaining,
    harvested_at, sell_until, lot_code, storage_instructions, created_by
  )
  select c.commodity_id, c.inventory_date_type,
    c.available_quantity, c.available_quantity, c.harvest_date,
    greatest(c.harvest_date, timezone('Asia/Manila', now())::date) + 30,
    'MOCK-' || c.commodity_id, 'Synthetic inventory for marketplace testing', a.id
  from public.commodities c
  join public.farms f using (farm_id)
  join public.farmers farmer using (farmer_user_id)
  join auth.users a on a.id = farmer.auth_user_id
  where a.raw_app_meta_data ->> 'test_seed' = seed_tag
    and c.available_quantity > 0
    and not exists (select 1 from public.commodity_inventory_lots l
      where l.commodity_id = c.commodity_id);

  if (select count(*) from public.commodities c
      join public.farms f using (farm_id)
      join public.farmers farmer using (farmer_user_id)
      join auth.users a on a.id = farmer.auth_user_id
      where a.raw_app_meta_data ->> 'test_seed' = seed_tag
        and exists (select 1 from public.commodity_inventory_lots l
          where l.commodity_id = c.commodity_id
            and private.inventory_lot_is_marketable(l, current_date))) <> 90 then
    raise exception 'Expected sellable inventory for all 90 mock products';
  end if;
  if (select count(*) from auth.users where raw_app_meta_data ->> 'test_seed' = seed_tag) <> 60
    or (select count(*) from public.commodities c join public.farms f using (farm_id)
      join public.farmers farmer using (farmer_user_id) join auth.users a
      on a.id = farmer.auth_user_id where a.raw_app_meta_data ->> 'test_seed' = seed_tag) <> 90 then
    raise exception 'Expected 60 mock accounts and 90 products; rolling back';
  end if;
end;
$seed$;

commit;

select a.raw_user_meta_data ->> 'requested_role' as role, count(*) as mock_accounts
from auth.users a where a.raw_app_meta_data ->> 'test_seed' = 'marketplace_mock_v1'
group by 1 order by 1;
