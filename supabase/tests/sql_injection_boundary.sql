-- Metadata and hostile-value checks; no application records are changed.
begin;
do $static_runtime$
begin
  if exists (select 1 from pg_proc p join pg_namespace n on n.oid = p.pronamespace
    where n.nspname in ('public', 'private') and p.prokind = 'f'
      and p.prosrc ~* '\mexecute[[:space:]]') then
    raise exception 'Application runtime function contains dynamic SQL; audit parameter binding';
  end if;
  if has_function_privilege('anon', 'public.current_checkout_voucher(text)', 'EXECUTE') then
    raise exception 'Anonymous voucher RPC execution remains';
  end if;
end;
$static_runtime$;

create temporary table voucher_test_caller as
select auth_user_id from private.auth_identities order by user_id limit 1;
-- Build expected published catalogue values as owner; callers have RPC access.
create temporary table voucher_test_cases as
select input.payload, (
  select case when count(*) = 1 then jsonb_agg(jsonb_build_object(
    'sale_id', s.sale_id, 'name', s.name, 'promo_code', s.promo_code,
    'discount_type', s.discount_type, 'discount_value', s.discount_value,
    'target_user_group', s.target_user_group, 'starts_at', s.starts_at,
    'ends_at', s.ends_at, 'is_enabled', s.is_enabled
  )) -> 0 else null::jsonb end
  from public.product_sales s where s.is_enabled
    and lower(s.promo_code) = lower(btrim(input.payload))
) as expected_sale
from unnest(array[
  '%', '_', '*', ''' OR 1=1 --', 'x''); SELECT pg_sleep(10); --',
  '%,_*,promo_code.eq.OTHER', 'quoted"value\with\backslashes'
]) input(payload);
create temporary table ordinary_voucher_test as
select min(promo_code) as code from public.product_sales
  where is_enabled and nullif(btrim(promo_code), '') is not null
    and promo_code = btrim(promo_code)
  group by lower(promo_code) having count(*) = 1 limit 1;
grant select on voucher_test_caller, voucher_test_cases, ordinary_voucher_test to authenticated;
set local role authenticated;
do $literal_values$
declare
  caller uuid;
  payload text;
  expected_sale jsonb;
  actual_sale jsonb;
  test_case record;
begin
  select auth_user_id into caller from voucher_test_caller;
  if caller is null then raise exception 'Existing account required for voucher check'; end if;
  perform set_config('request.jwt.claim.sub', caller::text, true);
  perform set_config('request.jwt.claims', jsonb_build_object(
    'sub', caller, 'role', 'authenticated', 'is_anonymous', false)::text, true);
  for test_case in select * from voucher_test_cases loop
    -- An exact code with punctuation is legitimate; compare to static equality.
    payload := test_case.payload;
    expected_sale := test_case.expected_sale;
    actual_sale := public.current_checkout_voucher(payload);
    if actual_sale is distinct from expected_sale then
      raise exception 'Voucher payload changed query semantics';
    end if;
  end loop;
  -- Also validate an ordinary existing voucher, if one is available.
  select code into payload from ordinary_voucher_test;
  if payload is not null and public.current_checkout_voucher(payload) is null then
    raise exception 'Existing exact voucher cannot be loaded';
  end if;
  perform set_config('request.jwt.claims', jsonb_build_object(
    'sub', caller, 'role', 'authenticated', 'is_anonymous', true)::text, true);
  if public.current_checkout_voucher(coalesce(payload, '%')) is not null then
    raise exception 'Anonymous authenticated voucher access remains';
  end if;
end;
$literal_values$;
reset role;
select 'passed' as sql_injection_boundary;
rollback;
