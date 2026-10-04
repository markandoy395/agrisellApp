-- Run after the migration. No account fixtures or persistent data changes.
-- The caller supplies BEGIN/ROLLBACK when verifying a hosted database.
do $address$
begin
  if private.marketplace_farm_address('Purok 4', 'San Jose', 'La Trinidad', 'Benguet')
    <> 'Purok 4, San Jose, La Trinidad, Benguet' then
    raise exception 'Incomplete farm address';
  end if;
  if private.marketplace_farm_address(' Purok 4, San Jose ', 'San Jose', '', null)
    <> 'Purok 4, San Jose' then
    raise exception 'Address components duplicated or blank';
  end if;
  if private.marketplace_farm_address(null, '', ' ', null) <> 'Location unavailable' then
    raise exception 'Missing address fallback changed';
  end if;
  if private.marketplace_farm_address('Purok %_ * ''; DROP TABLE farms; --', null, null, null)
    <> 'Purok %_ * ''; DROP TABLE farms; --' then
    raise exception 'Hostile address was not treated as literal data';
  end if;
  if has_function_privilege('anon', 'private.current_marketplace_conversations()', 'EXECUTE')
    or has_function_privilege('anon', 'public.current_marketplace_conversations()', 'EXECUTE') then
    raise exception 'Anonymous conversation execution permitted';
  end if;
end;
$address$;

do $participants$
declare
  target record;
  outsider uuid;
  rows jsonb;
begin
  select c.conversation_id, c.buyer_user_id, c.farmer_user_id,
    buyer.auth_user_id as buyer_auth, farmer.auth_user_id as farmer_auth,
    private.marketplace_farm_address(f.farm_location, f.barangay,
      f.city_municipality, f.province) as address
  into target
  from public.marketplace_conversations c
  join public.farms f on f.farm_id = c.farm_id
  join private.auth_identities buyer on buyer.buyer_user_id = c.buyer_user_id
  join public.farmers farmer on farmer.farmer_user_id = c.farmer_user_id
  limit 1;
  if not found then
    raise notice 'Participant checks skipped: no existing conversation';
  else
    perform set_config('request.jwt.claim.sub', target.buyer_auth::text, true);
    perform set_config('request.jwt.claims', jsonb_build_object('sub', target.buyer_auth,
      'role', 'authenticated', 'is_anonymous', false,
      'exp', extract(epoch from now()) + 3600)::text, true);
    rows := private.current_marketplace_conversations();
    if not exists (select 1 from jsonb_array_elements(rows) item
      where item->>'conversation_id' = target.conversation_id::text
        and item->>'farm_location' = target.address) then
      raise exception 'Buyer cannot read complete participant farm address';
    end if;
    perform set_config('request.jwt.claim.sub', target.farmer_auth::text, true);
    perform set_config('request.jwt.claims', jsonb_build_object('sub', target.farmer_auth,
      'role', 'authenticated', 'is_anonymous', false,
      'exp', extract(epoch from now()) + 3600)::text, true);
    rows := private.current_marketplace_conversations();
    if not exists (select 1 from jsonb_array_elements(rows) item
      where item->>'conversation_id' = target.conversation_id::text
        and item->>'farm_location' = target.address) then
      raise exception 'Farmer cannot read own conversation address';
    end if;
    select auth_user_id into outsider from private.auth_identities
    where auth_user_id not in (target.buyer_auth, target.farmer_auth)
      and buyer_user_id is distinct from target.buyer_user_id
      and farmer_user_id is distinct from target.farmer_user_id limit 1;
    if outsider is null then
      raise notice 'Unrelated-account check skipped: no existing outsider';
    else
      perform set_config('request.jwt.claim.sub', outsider::text, true);
      perform set_config('request.jwt.claims', jsonb_build_object('sub', outsider,
        'role', 'authenticated', 'is_anonymous', false,
        'exp', extract(epoch from now()) + 3600)::text, true);
      rows := private.current_marketplace_conversations();
      if exists (select 1 from jsonb_array_elements(rows) item
        where item->>'conversation_id' = target.conversation_id::text) then
        raise exception 'Unrelated account can read conversation address';
      end if;
    end if;
  end if;
  perform set_config('request.jwt.claim.sub', '', true);
  perform set_config('request.jwt.claims', '{}', true);
  begin
    perform private.current_marketplace_conversations();
    raise exception 'Missing session was accepted';
  exception when insufficient_privilege then null;
  end;
  perform set_config('request.jwt.claim.sub', '00000000-0000-0000-0000-000000000001', true);
  perform set_config('request.jwt.claims', '{"sub":"00000000-0000-0000-0000-000000000001","is_anonymous":true,"exp":4102444800}', true);
  begin
    perform private.current_marketplace_conversations();
    raise exception 'Anonymous session was accepted';
  exception when insufficient_privilege then null;
  end;
  perform set_config('request.jwt.claims', '{"sub":"00000000-0000-0000-0000-000000000001","is_anonymous":false,"exp":1}', true);
  begin
    perform private.current_marketplace_conversations();
    raise exception 'Expired session was accepted';
  exception when insufficient_privilege then null;
  end;
end;
$participants$;
