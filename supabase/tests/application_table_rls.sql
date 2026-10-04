-- Run after all October authentication/ownership migrations as migration owner.
-- This audits deployed metadata, not just the migration text.
begin;
do $audit$
declare target record;
begin
  for target in
    select c.oid, c.oid::regclass as name, n.nspname, c.relname, c.relrowsecurity
    from pg_class c join pg_namespace n on n.oid = c.relnamespace
    where n.nspname in ('public', 'private') and c.relkind in ('r', 'p')
      and not exists (select 1 from pg_depend d
        where d.classid = 'pg_class'::regclass and d.objid = c.oid and d.deptype = 'e')
  loop
    if not target.relrowsecurity then raise exception 'RLS missing: %', target.name; end if;
    if has_table_privilege('anon', target.oid, 'SELECT,INSERT,UPDATE,DELETE,TRUNCATE,REFERENCES,TRIGGER')
      or has_any_column_privilege('anon', target.oid, 'SELECT,INSERT,UPDATE,REFERENCES') then
      raise exception 'Anonymous grants remain: %', target.name;
    end if;
    if has_table_privilege('authenticated', target.oid, 'TRUNCATE,REFERENCES,TRIGGER') then
      raise exception 'End-user non-row privilege remains: %', target.name;
    end if;
    if not exists (select 1 from pg_policy p where p.polrelid = target.oid
      and p.polname = 'application_table_requires_login' and not p.polpermissive
      and p.polcmd = '*' and p.polroles = array[0::oid]
      and p.polqual is not null and p.polwithcheck is not null) then
      raise exception 'Restrictive login boundary missing: %', target.name;
    end if;
    if not exists (select 1 from pg_policy p where p.polrelid = target.oid
      and not p.polpermissive and p.polname in (
        'account_owner_boundary', 'account_participant_boundary',
        'account_owner_update_boundary', 'account_admin_boundary',
        'application_default_owner_boundary', 'application_shared_update_boundary')) then
      raise exception 'Table lacks an explicit ownership/shared/default-deny classification: %', target.name;
    end if;
    if target.nspname = 'private' and not exists (
      select 1 from pg_policy p where p.polrelid = target.oid
        and p.polname = 'application_default_owner_boundary'
        and pg_get_expr(p.polqual, p.polrelid) = 'false'
        and pg_get_expr(p.polwithcheck, p.polrelid) = 'false') then
      raise exception 'Internal table permits direct user access: %', target.name;
    end if;
  end loop;
end;
$audit$;
rollback;
