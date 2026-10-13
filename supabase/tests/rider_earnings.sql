-- Read-only deployment assertions. Behavioral fixtures belong in a test DB.
begin;
do $$
begin
  if not exists (select 1 from pg_trigger
    where tgrelid = 'public.deliveries'::regclass
      and tgname = 'record_rider_earning_on_completion' and not tgisinternal) then
    raise exception 'Rider earning completion trigger missing';
  end if;
  if not (select relrowsecurity from pg_class
    where oid = 'public.delivery_payments'::regclass) then
    raise exception 'Delivery payments require RLS';
  end if;
  if has_function_privilege('authenticated',
      'private.record_completed_rider_earning(bigint)', 'EXECUTE')
    or has_function_privilege('anon',
      'public.current_rider_deliveries(boolean)', 'EXECUTE') then
    raise exception 'Untrusted earning mutation or anonymous read privilege';
  end if;
  if not has_function_privilege('authenticated',
    'public.current_rider_deliveries(boolean)', 'EXECUTE') then
    raise exception 'Authenticated rider feed unavailable';
  end if;
  if has_table_privilege('authenticated', 'public.delivery_payments', 'UPDATE')
    or has_table_privilege('authenticated', 'public.delivery_payments', 'DELETE')
    or has_table_privilege('authenticated', 'public.delivery_payments', 'INSERT') then
    raise exception 'Rider payment writes must remain server-only';
  end if;
end;
$$;
rollback;
