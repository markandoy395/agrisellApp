begin;
do $test$
declare signature text; target regprocedure;
begin
  foreach signature in array array[
    'public.send_marketplace_message_once(bigint,text,uuid)',
    'public.submit_farmer_payout_once(numeric,text,text,text,uuid,text,text)',
    'public.current_account_order_bundle()'
  ] loop
    target := signature::regprocedure;
    if has_function_privilege('anon',target,'EXECUTE') then
      raise exception 'Anonymous execution remains: %',signature;
    end if;
    if not has_function_privilege('authenticated',target,'EXECUTE') then
      raise exception 'Authenticated contract missing: %',signature;
    end if;
    if not exists(select 1 from pg_proc p where p.oid=target
      and p.prosecdef and 'search_path=""'=any(p.proconfig)) then
      raise exception 'Unsafe function configuration: %',signature;
    end if;
  end loop;
  if has_table_privilege('authenticated','private.application_operation_receipts',
    'SELECT,INSERT,UPDATE,DELETE,TRUNCATE,REFERENCES,TRIGGER') then
    raise exception 'Receipt table is directly accessible';
  end if;
  if has_function_privilege('authenticated',
    'private.lock_operation_receipt(text,uuid,jsonb)','EXECUTE') then
    raise exception 'Internal receipt helper is directly accessible';
  end if;
end;
$test$;
rollback;
