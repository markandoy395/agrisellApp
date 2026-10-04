-- Run as the migration owner in a migrated LOCAL/TEST database, never production.
-- Fixtures and all writes are rolled back. Fail on cross-account read/write.
begin;
create temporary table ownership_test_fixture (
  auth_a uuid, auth_b uuid, user_a bigint, user_b bigint, buyer_a bigint, buyer_b bigint
);
grant select on ownership_test_fixture to authenticated;
do $fixtures$
declare
  a uuid := extensions.gen_random_uuid();
  b uuid := extensions.gen_random_uuid();
  ua bigint; ub bigint; ba bigint; bb bigint;
begin
  insert into auth.users (id, aud, role, email, email_confirmed_at,
    raw_app_meta_data, raw_user_meta_data)
  values
    (a, 'authenticated', 'authenticated', a::text || '@example.invalid', now(),
      '{"provider":"email","providers":["email"]}',
      '{"first_name":"Audit A","last_name":"Owner","requested_role":"buyer"}'),
    (b, 'authenticated', 'authenticated', b::text || '@example.invalid', now(),
      '{"provider":"email","providers":["email"]}',
      '{"first_name":"Audit B","last_name":"Owner","requested_role":"buyer"}');
  select user_id, buyer_user_id into ua, ba from private.auth_identities where auth_user_id = a;
  select user_id, buyer_user_id into ub, bb from private.auth_identities where auth_user_id = b;
  if ba is null then
    insert into public.buyers(user_id, user_type) values (ua, 'buyer') returning buyer_user_id into ba;
    update private.auth_identities set buyer_user_id = ba where auth_user_id = a;
  end if;
  if bb is null then
    insert into public.buyers(user_id, user_type) values (ub, 'buyer') returning buyer_user_id into bb;
    update private.auth_identities set buyer_user_id = bb where auth_user_id = b;
  end if;
  insert into ownership_test_fixture values (a, b, ua, ub, ba, bb);
  insert into public.notifications(recipient_auth_user_id,title,description)
    values (a, 'Audit A', 'Private A'), (b, 'Audit B', 'Private B');
  insert into public.rider_incidents(report_id, reporter_auth_id, reporter_role,
    report_type, category, description, status, reported_at)
    values ('audit-' || b, b, 'buyer', 'safety_report', 'safety', 'Private B', 'submitted', now());
end;
$fixtures$;

set local role authenticated;
do $account_a$
declare
  f record;
  changed integer;
begin
  select * into f from ownership_test_fixture;
  perform set_config('request.jwt.claim.sub', f.auth_a::text, true);
  perform set_config('request.jwt.claims', jsonb_build_object(
    'sub', f.auth_a, 'role', 'authenticated', 'is_anonymous', false)::text, true);
  if not exists (select 1 from public.users where user_id = f.user_a) then
    raise exception 'A cannot read its own profile';
  end if;
  if exists (select 1 from public.users where user_id = f.user_b) or
     exists (select 1 from public.buyers where buyer_user_id = f.buyer_b) or
     exists (select 1 from public.notifications where recipient_auth_user_id = f.auth_b) or
     exists (select 1 from public.rider_incidents where reporter_auth_id = f.auth_b) then
    raise exception 'A can read B personal data';
  end if;
  update public.users set first_name = 'Forbidden' where user_id = f.user_b;
  get diagnostics changed = row_count;
  if changed <> 0 then raise exception 'A updated B profile'; end if;
  update public.buyers set shipping_address = 'Forbidden' where buyer_user_id = f.buyer_b;
  get diagnostics changed = row_count;
  if changed <> 0 then raise exception 'A updated B address'; end if;
  begin
    delete from public.users where user_id = f.user_b;
    get diagnostics changed = row_count;
    if changed <> 0 then raise exception 'A deleted B profile'; end if;
  exception when insufficient_privilege then null;
  end;
  begin
    perform public.submit_safety_incident(
      'audit-' || f.auth_b, 'safety_report', 'safety', 'Forbidden', 'buyer',
      null, null, null, null, null, null, null, null, null, '[]'::jsonb, '[]'::jsonb);
    raise exception 'A submitted using B report ID without rejection';
  exception when insufficient_privilege then null;
  end;
  if jsonb_array_length(public.get_my_safety_incidents(null)) <> 0 then
    raise exception 'Safety RPC leaked B report';
  end if;
end;
$account_a$;

-- Reverse the roles: B also cannot read or mutate A.
do $account_b$
declare f record; changed integer;
begin
  select * into f from ownership_test_fixture;
  perform set_config('request.jwt.claim.sub', f.auth_b::text, true);
  perform set_config('request.jwt.claims', jsonb_build_object(
    'sub', f.auth_b, 'role', 'authenticated', 'is_anonymous', false)::text, true);
  if exists (select 1 from public.users where user_id = f.user_a) then
    raise exception 'B read A profile';
  end if;
  update public.users set first_name = 'Forbidden' where user_id = f.user_a;
  get diagnostics changed = row_count;
  if changed <> 0 then raise exception 'B updated A profile'; end if;
  if (select description from public.rider_incidents where reporter_auth_id = f.auth_b) <> 'Private B' then
    raise exception 'B report was modified by A';
  end if;
end;
$account_b$;

-- Supabase anonymous sign-ins use the authenticated role, not the anon role.
-- Even an anonymous JWT with a mapped account ID cannot read application rows.
do $anonymous_session$
declare f record;
begin
  select * into f from ownership_test_fixture;
  perform set_config('request.jwt.claim.sub', f.auth_a::text, true);
  perform set_config('request.jwt.claims', jsonb_build_object(
    'sub', f.auth_a, 'role', 'authenticated', 'is_anonymous', true)::text, true);
  if exists (select 1 from public.users where user_id = f.user_a) or
     exists (select 1 from public.buyers where buyer_user_id = f.buyer_a) or
     exists (select 1 from public.notifications where recipient_auth_user_id = f.auth_a) then
    raise exception 'Anonymous authenticated session can read application data';
  end if;
end;
$anonymous_session$;
rollback;
