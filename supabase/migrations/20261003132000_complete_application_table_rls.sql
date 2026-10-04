begin;

-- Supabase manages auth/storage/system schemas. Extension-owned relations are
-- also outside the application schema contract. Do not FORCE RLS: trusted
-- owner-run account provisioning and existing checked definer RPCs need it.
do $tables$
declare
  target record;
  owner_column text;
  predicate text;
begin
  for target in
    select c.oid, n.nspname, c.relname
    from pg_class c join pg_namespace n on n.oid = c.relnamespace
    where n.nspname in ('public', 'private') and c.relkind in ('r', 'p')
      and not exists (select 1 from pg_depend d
        where d.classid = 'pg_class'::regclass and d.objid = c.oid and d.deptype = 'e')
  loop
    execute format('alter table %I.%I enable row level security', target.nspname, target.relname);
    execute format('create policy application_table_requires_login on %I.%I '
      'as restrictive for all to public '
      'using ((select auth.role()) = ''service_role'' or '
      '((select auth.uid()) is not null and '
      'coalesce((select auth.jwt())->>''is_anonymous'', ''false'') = ''false'')) '
      'with check ((select auth.role()) = ''service_role'' or '
      '((select auth.uid()) is not null and '
      'coalesce((select auth.jwt())->>''is_anonymous'', ''false'') = ''false''))',
      target.nspname, target.relname);

    if target.nspname = 'private' then
      -- Internal tables are accessed through checked RPC implementations running
      -- as the owner, never directly by end-user database roles.
      predicate := 'false';
    elsif exists (
      select 1 from pg_policy p where p.polrelid = target.oid
        and p.polname in ('account_owner_boundary', 'account_participant_boundary',
          'account_owner_update_boundary', 'account_admin_boundary')
    ) then
      continue; -- Explicit owner/participant classification from 130000.
    elsif target.relname in ('logistics_companies', 'manual_home_banners') then
      -- Shared authenticated reads retain their existing permissive policies.
      -- Only the backend can change this reference/catalogue data.
      execute format('create policy application_shared_insert_boundary on %I.%I '
        'as restrictive for insert to authenticated with check (false)', target.nspname, target.relname);
      execute format('create policy application_shared_update_boundary on %I.%I '
        'as restrictive for update to authenticated using (false) with check (false)', target.nspname, target.relname);
      execute format('create policy application_shared_delete_boundary on %I.%I '
        'as restrictive for delete to authenticated using (false)', target.nspname, target.relname);
      continue;
    else
      -- For unclassified UUID-owned records use an actual ownership column.
      -- Never compare bigint application IDs to the UUID from auth.uid().
      select a.attname into owner_column from pg_attribute a
      where a.attrelid = target.oid and a.attnum > 0 and not a.attisdropped
        and a.atttypid = 'uuid'::regtype
        and a.attname in ('owner_id', 'auth_user_id', 'auth_id', 'user_id')
      order by case a.attname when 'owner_id' then 1 when 'auth_user_id' then 2
        when 'auth_id' then 3 else 4 end limit 1;
      predicate := case when owner_column is null then 'false'
        else format('%I = (select auth.uid())', owner_column) end;
    end if;
    -- Unknown tables without an ownership contract remain inaccessible. A new
    -- feature must deliberately classify them and define permissive policies.
    execute format('create policy application_default_owner_boundary on %I.%I '
      'as restrictive for all to authenticated using (%s) with check (%s)',
      target.nspname, target.relname, predicate, predicate);
  end loop;
end;
$tables$;

-- Also block non-row operations (e.g. TRUNCATE), which RLS does not filter.
revoke all on all tables in schema public, private from public, anon;
revoke all on all sequences in schema public, private from public, anon;
revoke all on schema public, private from public, anon;
revoke truncate, references, trigger on all tables in schema public, private from authenticated;

notify pgrst, 'reload schema';
commit;
