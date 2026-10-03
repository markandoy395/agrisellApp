begin;

-- Auth endpoints live outside these application schemas. Signup, email OTP,
-- password recovery, and Auth provisioning triggers keep working.
grant usage on schema public, private to authenticated, service_role;
revoke all on schema public, private from public, anon;

-- Preserve existing effective authenticated/service privileges when removing
-- PUBLIC inheritance. Never grant a function previously denied to those roles.
do $functions$
declare
  routine record;
  permitted_authenticated boolean;
  permitted_service boolean;
begin
  for routine in
    select p.oid, p.oid::regprocedure as signature
    from pg_proc p join pg_namespace n on n.oid = p.pronamespace
    where n.nspname in ('public', 'private') and p.prokind = 'f'
  loop
    permitted_authenticated := has_function_privilege(
      'authenticated', routine.oid, 'EXECUTE');
    permitted_service := has_function_privilege(
      'service_role', routine.oid, 'EXECUTE');
    execute format('revoke all on function %s from public, anon', routine.signature);
    if permitted_authenticated then
      execute format('grant execute on function %s to authenticated', routine.signature);
    end if;
    if permitted_service then
      execute format('grant execute on function %s to service_role', routine.signature);
    end if;
  end loop;
end;
$functions$;

revoke all on all tables in schema public, private from public, anon;
revoke all on all sequences in schema public, private from public, anon;

-- Cover column grants as well as table-level grants.
do $columns$
declare
  relation record;
begin
  for relation in
    select n.nspname, c.relname,
      string_agg(quote_ident(a.attname), ', ' order by a.attnum) as columns
    from pg_class c join pg_namespace n on n.oid = c.relnamespace
    join pg_attribute a on a.attrelid = c.oid
    where n.nspname in ('public', 'private')
      and c.relkind in ('r', 'p', 'v', 'm', 'f')
      and a.attnum > 0 and not a.attisdropped
    group by n.nspname, c.relname
  loop
    execute format(
      'revoke select (%s), insert (%s), update (%s), references (%s) '
      'on %I.%I from public, anon',
      relation.columns, relation.columns, relation.columns, relation.columns,
      relation.nspname, relation.relname);
  end loop;
end;
$columns$;

-- RLS remains the authorization layer for authenticated table access.
do $rls$
declare
  relation record;
begin
  for relation in
    select c.oid::regclass as name
    from pg_class c join pg_namespace n on n.oid = c.relnamespace
    where n.nspname = 'public' and c.relkind in ('r', 'p')
  loop
    execute format('alter table %s enable row level security', relation.name);
  end loop;
end;
$rls$;

-- PostgreSQL grants PUBLIC execution globally by default, so revoke globally
-- for the roles that create application objects, plus schema-specific defaults.
do $defaults$
declare
  owner_name text;
  schema_name text;
begin
  for owner_name in
    select rolname from pg_roles
    where rolname in (current_user, 'postgres', 'supabase_admin')
      and pg_has_role(current_user, oid, 'MEMBER')
  loop
    execute format('alter default privileges for role %I '
      'revoke execute on functions from public, anon', owner_name);
    foreach schema_name in array array['public', 'private'] loop
      execute format('alter default privileges for role %I in schema %I '
        'revoke all on tables from public, anon', owner_name, schema_name);
      execute format('alter default privileges for role %I in schema %I '
        'revoke all on sequences from public, anon', owner_name, schema_name);
      execute format('alter default privileges for role %I in schema %I '
        'revoke execute on functions from public, anon', owner_name, schema_name);
    end loop;
  end loop;
end;
$defaults$;

-- Public downloads bypass object RLS. Keep all application buckets private.
update storage.buckets set public = false where public;

-- Restrictive policies also cover existing permissive PUBLIC/anon policies.
create policy application_storage_requires_login on storage.objects
  as restrictive for all to public
  using (
    auth.role() = 'service_role' or
    (auth.uid() is not null and coalesce(auth.jwt()->>'is_anonymous', 'false') = 'false')
  )
  with check (
    auth.role() = 'service_role' or
    (auth.uid() is not null and coalesce(auth.jwt()->>'is_anonymous', 'false') = 'false')
  );
create policy application_bucket_listing_requires_login on storage.buckets
  as restrictive for select to public
  using (
    auth.role() = 'service_role' or
    (auth.uid() is not null and coalesce(auth.jwt()->>'is_anonymous', 'false') = 'false')
  );

-- Marketplace photos were formerly fetched from the public farmer-media bucket.
-- Verification files in that bucket retain their existing owner-only policies.
create policy authenticated_marketplace_media_read on storage.objects
  for select to authenticated
  using (
    bucket_id = 'farmer-media' and
    ((storage.filename(name)) in ('profile.jpg', 'farm.jpg') or
      (storage.foldername(name))[2] = 'commodities')
  );

notify pgrst, 'reload schema';
commit;
