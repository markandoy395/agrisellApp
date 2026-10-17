begin;

-- Ensure farmer identity resolution falls back to public.farmers.auth_user_id
-- whenever private.auth_identities.farmer_user_id has not been populated yet.
create or replace function private.current_farmer_user_id()
returns bigint
language sql
stable
security definer
set search_path = ''
as $$
  select coalesce(
    (
      select identity.farmer_user_id
      from private.auth_identities as identity
      where identity.auth_user_id = (select auth.uid())
    ),
    private.current_authenticated_farmer_user_id()
  )
$$;

revoke all on function private.current_farmer_user_id() from public, anon;
grant execute on function private.current_farmer_user_id() to authenticated, service_role;

create or replace function private.owns_farm(target_farm_id bigint)
returns boolean
language sql
stable
security definer
set search_path = ''
as $$
  select exists (
    select 1
    from public.farms as farm
    where farm.farm_id = target_farm_id
      and farm.farmer_user_id = coalesce(
        private.current_farmer_user_id(),
        private.current_authenticated_farmer_user_id()
      )
  )
$$;

revoke all on function private.owns_farm(bigint) from public, anon;
grant execute on function private.owns_farm(bigint) to authenticated, service_role;

-- On public.farms, check farmer_user_id directly rather than querying
-- public.farms via private.owns_farm(farm_id), which cannot see a newly
-- inserted farm row inside a STABLE function during INSERT WITH CHECK.
drop policy if exists account_owner_insert_boundary on public.farms;
create policy account_owner_insert_boundary on public.farms
  as restrictive for insert to authenticated
  with check (
    farmer_user_id = coalesce(
      private.current_farmer_user_id(),
      private.current_authenticated_farmer_user_id()
    )
  );

drop policy if exists account_owner_update_boundary on public.farms;
create policy account_owner_update_boundary on public.farms
  as restrictive for update to authenticated
  using (
    farmer_user_id = coalesce(
      private.current_farmer_user_id(),
      private.current_authenticated_farmer_user_id()
    )
  )
  with check (
    farmer_user_id = coalesce(
      private.current_farmer_user_id(),
      private.current_authenticated_farmer_user_id()
    )
  );

drop policy if exists account_owner_delete_boundary on public.farms;
create policy account_owner_delete_boundary on public.farms
  as restrictive for delete to authenticated
  using (
    farmer_user_id = coalesce(
      private.current_farmer_user_id(),
      private.current_authenticated_farmer_user_id()
    )
  );

-- Align commodity photo uploads in farmer-media with categories/commodities
-- so active pending, verified, and needs_information farmers can upload photos.
drop policy if exists farmer_media_insert on storage.objects;
drop policy if exists farmer_media_update on storage.objects;

create policy farmer_media_insert on storage.objects
  for insert to authenticated
  with check (
    bucket_id = 'farmer-media'
    and (storage.foldername(name))[1] = (select auth.uid())::text
    and (
      (storage.foldername(name))[2] is distinct from 'commodities'
      or exists (
        select 1
        from public.farmers as farmer
        where farmer.auth_user_id = (select auth.uid())
          and lower(farmer.account_status) = 'active'
          and lower(farmer.verification_status) in (
            'pending',
            'verified',
            'needs_information'
          )
      )
    )
  );

create policy farmer_media_update on storage.objects
  for update to authenticated
  using (
    bucket_id = 'farmer-media'
    and (storage.foldername(name))[1] = (select auth.uid())::text
  )
  with check (
    bucket_id = 'farmer-media'
    and (storage.foldername(name))[1] = (select auth.uid())::text
    and (
      (storage.foldername(name))[2] is distinct from 'commodities'
      or exists (
        select 1
        from public.farmers as farmer
        where farmer.auth_user_id = (select auth.uid())
          and lower(farmer.account_status) = 'active'
          and lower(farmer.verification_status) in (
            'pending',
            'verified',
            'needs_information'
          )
      )
    )
  );

notify pgrst, 'reload schema';
commit;

