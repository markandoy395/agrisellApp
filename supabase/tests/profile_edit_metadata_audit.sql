-- Read-only schema and authorization metadata; no account values are returned.
begin read only;
with columns as (
  select table_name, column_name, data_type, is_nullable,
         has_column_privilege('authenticated', format('public.%I', table_name),
           column_name, 'SELECT') as can_select,
         has_column_privilege('authenticated', format('public.%I', table_name),
           column_name, 'UPDATE') as can_update
  from information_schema.columns
  where table_schema = 'public'
    and table_name in ('users', 'buyers', 'farmers', 'farms', 'riders',
      'rider_documents', 'rider_vehicles')
), policies as (
  select schemaname, tablename, policyname, permissive, roles, cmd, qual, with_check
  from pg_policies where schemaname in ('public', 'storage')
    and tablename in ('users', 'buyers', 'farmers', 'farms', 'riders',
      'rider_documents', 'rider_vehicles', 'objects')
), functions as (
  select n.nspname as schema_name, p.proname as function_name,
         pg_get_functiondef(p.oid) as definition,
         has_function_privilege('authenticated', p.oid, 'EXECUTE') as can_execute,
         has_function_privilege('anon', p.oid, 'EXECUTE') as anon_can_execute
  from pg_proc p join pg_namespace n on n.oid = p.pronamespace
  where n.nspname in ('public', 'private') and p.proname in (
    'complete_current_buyer_registration', 'complete_current_farmer_registration',
    'create_current_rider_registration', 'set_current_rider_capacity',
    'set_current_buyer_shipping_address_location', 'current_query_owner',
    'sync_farmer_farm_size')
), triggers as (
  select c.relname as table_name, t.tgname as trigger_name,
         pg_get_triggerdef(t.oid) as definition
  from pg_trigger t join pg_class c on c.oid = t.tgrelid
  join pg_namespace n on n.oid = c.relnamespace
  where n.nspname = 'public' and not t.tgisinternal
    and c.relname in ('users', 'buyers', 'farmers', 'farms', 'riders',
      'rider_documents')
), relations as (
  select n.nspname as schema_name, c.relname as table_name,
         c.relrowsecurity as rls_enabled, c.relforcerowsecurity as rls_forced
  from pg_class c join pg_namespace n on n.oid = c.relnamespace
  where n.nspname = 'public' and c.relname in (
    'users', 'buyers', 'farmers', 'farms', 'riders', 'rider_documents',
    'rider_vehicles') and c.relkind in ('r', 'p')
), data_checks as (
  select 'farm_crop_count_mismatch' as check_name, count(*) as affected
  from public.farms where total_crops is distinct from cardinality(main_crops)
  union all
  select 'farm_rows_with_sq_m_unit', count(*) from public.farms
  where farm_size_unit = 'sq m'
)
select jsonb_build_object(
  'columns', (select jsonb_agg(to_jsonb(c)) from columns c),
  'policies', (select jsonb_agg(to_jsonb(p)) from policies p),
  'functions', (select jsonb_agg(to_jsonb(f)) from functions f),
  'triggers', (select jsonb_agg(to_jsonb(t)) from triggers t),
  'data_checks', (select jsonb_agg(to_jsonb(d)) from data_checks d),
  'relations', (select jsonb_agg(to_jsonb(r)) from relations r)
) as audit;
rollback;
