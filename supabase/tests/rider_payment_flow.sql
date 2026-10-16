-- Read-only metadata assertions; safe to run as migration owner, rolled back.
begin;
do $$
declare signature text; target oid;
begin
  foreach signature in array array[
    'public.current_rider_wallet()',
    'public.submit_rider_payout_request(uuid,numeric,uuid,text)',
    'public.current_user_payout_requests(text)'
  ] loop
    target := to_regprocedure(signature);
    if target is null then raise exception 'Payment RPC missing: %',signature; end if;
    if has_function_privilege('anon',target,'EXECUTE') then
      raise exception 'Anonymous payment RPC grant: %',signature;
    end if;
    if not has_function_privilege('authenticated',target,'EXECUTE') then
      raise exception 'Authenticated payment RPC grant missing: %',signature;
    end if;
    if position('private.require_payment_session()' in pg_get_functiondef(target)) = 0 then
      raise exception 'Independent payment session guard missing: %',signature;
    end if;
  end loop;
  foreach signature in array array[
    'private.require_payment_session()',
    'private.rider_payment_balances(uuid,uuid)',
    'private.api_impl_20260925_submit_payout_request(numeric,text,text,text,text,text,text)',
    'private.admin_update_payout_request(jsonb,text)',
    'public.admin_update_payout_request(jsonb,text)',
    'private.admin_get_payout_requests()',
    'public.admin_get_payout_requests()'
  ] loop
    target := to_regprocedure(signature);
    if target is null then raise exception 'Internal payment function missing: %',signature; end if;
    if has_function_privilege('authenticated',target,'EXECUTE')
      or has_function_privilege('anon',target,'EXECUTE') then
      raise exception 'Untrusted internal payment execution: %',signature;
    end if;
  end loop;
  if has_table_privilege('authenticated','public.payout_requests','INSERT,UPDATE,DELETE')
    or has_any_column_privilege('authenticated','public.payout_requests','INSERT,UPDATE') then
    raise exception 'Direct payout request mutation bypass remains';
  end if;
  if has_table_privilege('authenticated','private.rider_payout_allocations','SELECT,INSERT,UPDATE,DELETE')
    or has_table_privilege('anon','private.rider_payout_allocations','SELECT,INSERT,UPDATE,DELETE') then
    raise exception 'Direct payout allocation access remains';
  end if;
  if not exists(select 1 from pg_class where oid='private.rider_payout_allocations'::regclass and relrowsecurity)
    or not exists(select 1 from pg_policy where polrelid='private.rider_payout_allocations'::regclass
      and polname='application_default_owner_boundary' and not polpermissive)
    or not exists(select 1 from pg_policy where polrelid='private.rider_payout_allocations'::regclass
      and polname='application_table_requires_login' and not polpermissive) then
    raise exception 'Allocation RLS boundary missing';
  end if;
  foreach signature in array array['guard_payout_transition','sync_rider_payout_earnings',
    'require_agreed_rider_fee','guard_reserved_delivery_earning',
    'guard_allocated_delivery_status','guard_allocated_delivery_assignment'] loop
    if not exists(select 1 from pg_trigger where tgname=signature and not tgisinternal and tgenabled='O') then
      raise exception 'Payment guard trigger missing: %',signature;
    end if;
  end loop;
end;
$$;
rollback;
