-- Run against a migrated database as postgres. Assertions roll back their
-- transaction and raise on any anonymous grant or public storage bucket.
begin;
do $audit$
declare
  exposed record;
begin
  if has_schema_privilege('anon', 'public', 'USAGE') or
     has_schema_privilege('anon', 'private', 'USAGE') then
    raise exception 'Anonymous application schema access remains';
  end if;
  for exposed in
    select c.oid, c.oid::regclass as name, n.nspname, c.relkind, c.relrowsecurity
    from pg_class c join pg_namespace n on n.oid = c.relnamespace
    where n.nspname in ('public', 'private')
      and c.relkind in ('r', 'p', 'v', 'm', 'f')
  loop
    if has_table_privilege('anon', exposed.oid, 'SELECT,INSERT,UPDATE,DELETE,TRUNCATE,REFERENCES,TRIGGER') or
       has_any_column_privilege('anon', exposed.oid, 'SELECT,INSERT,UPDATE,REFERENCES') then
      raise exception 'Anonymous table/column access remains: %', exposed.name;
    end if;
    if exposed.relkind in ('r', 'p') and
       exposed.nspname = 'public' and not exposed.relrowsecurity then
      raise exception 'Application table missing RLS: %', exposed.name;
    end if;
  end loop;
  for exposed in
    select p.oid, p.oid::regprocedure as name
    from pg_proc p join pg_namespace n on n.oid = p.pronamespace
    where n.nspname in ('public', 'private') and p.prokind = 'f'
  loop
    if has_function_privilege('anon', exposed.oid, 'EXECUTE') then
      raise exception 'Anonymous RPC execution remains: %', exposed.name;
    end if;
  end loop;
  if exists (select 1 from storage.buckets where public) then
    raise exception 'Public storage bucket remains';
  end if;
  if not exists (
    select 1 from pg_policies where schemaname = 'storage'
      and tablename = 'objects'
      and policyname = 'application_storage_requires_login'
      and permissive = 'RESTRICTIVE'
  ) then
    raise exception 'Storage authentication policy missing';
  end if;
end;
$audit$;
rollback;
