-- Read-only deployment checks; behavioral tests run in an isolated local database.
begin;
do $audit$
declare signature text; target oid;
begin
  foreach signature in array array[
    'public.publish_current_farmer_product(uuid,jsonb,jsonb)',
    'private.can_publish_farmer_product(bigint)',
    'private.can_upload_farmer_product()'
  ] loop
    target := to_regprocedure(signature);
    if target is null then raise exception 'Publication function missing: %',signature; end if;
    if has_function_privilege('anon',target,'EXECUTE') then
      raise exception 'Anonymous publication access: %',signature;
    end if;
  end loop;
  if not exists (select 1 from pg_policies where schemaname='public'
    and tablename='commodities' and policyname='verified_farmer_product_insert'
    and permissive='RESTRICTIVE' and cmd='INSERT') then
    raise exception 'Restrictive publication approval policy missing';
  end if;
  if not exists (select 1 from pg_policies where schemaname='storage'
    and tablename='objects' and policyname='verified_farmer_product_upload'
    and permissive='RESTRICTIVE') then
    raise exception 'Product upload approval policy missing';
  end if;
  if pg_get_functiondef('private.add_current_farmer_inventory_lot(bigint,numeric,text,date,date,date,text,text,text)'::regprocedure)
    not like '%private.can_publish_farmer_product(commodity_record.farm_id)%' then
    raise exception 'Stock RPC approval check missing';
  end if;
  if has_table_privilege('authenticated','private.application_operation_receipts','INSERT') then
    raise exception 'Publication receipts writable by clients';
  end if;
end;
$audit$;
select 'passed' as farmer_publication_contract;
rollback;
