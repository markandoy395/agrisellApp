begin;

alter table public.riders
  add column if not exists vehicle_brand text,
  add column if not exists vehicle_model text,
  add column if not exists vehicle_color text,
  add column if not exists registration_number text;
alter table public.users add column if not exists accepted_policy_at timestamptz;
grant select (vehicle_brand, vehicle_model, vehicle_color, registration_number)
  on public.riders to authenticated;
grant update (vehicle_brand, vehicle_model, vehicle_color, registration_number)
  on public.riders to authenticated;

create or replace function private.require_profile_editor()
returns uuid language plpgsql security definer set search_path = '' as $$
begin
  if auth.uid() is null or auth.role() <> 'authenticated'
     or coalesce(auth.jwt()->>'is_anonymous', 'false') <> 'false'
     or coalesce((auth.jwt()->>'exp')::numeric, 0) <= extract(epoch from now()) then
    raise exception 'Authentication required' using errcode = '42501';
  end if;
  return auth.uid();
end;
$$;
revoke all on function private.require_profile_editor() from public, anon;
grant execute on function private.require_profile_editor() to authenticated, service_role;

create or replace function private.profile_gateway_verified()
returns boolean language sql stable security definer set search_path = '' as $$
  select exists (select 1 from private.api_gateway_configuration c
    where c.singleton and c.secret_hash is not null and
      encode(extensions.digest(coalesce(
        coalesce(nullif(current_setting('request.headers', true), ''), '{}')::jsonb
          ->>'x-agrisell-api-gateway', ''), 'sha256'), 'hex') = c.secret_hash);
$$;
revoke all on function private.profile_gateway_verified() from public, anon;
grant execute on function private.profile_gateway_verified() to authenticated, service_role;

create or replace function private.update_current_rider_vehicle(vehicle_payload jsonb)
returns jsonb language plpgsql security definer set search_path = '' as $$
declare
  caller uuid := private.require_profile_editor();
  target uuid;
  current_vehicle public.riders%rowtype;
  plate text := nullif(upper(btrim(vehicle_payload->>'plate_number')), '');
begin
  perform public.require_rate_limited_gateway();
  if not private.profile_gateway_verified() then
    raise sqlstate 'PT403' using message = 'Use the protected profile API';
  end if;
  select rider_id into target from private.auth_identities where auth_user_id = caller;
  select * into current_vehicle from public.riders where rider_id = target for update;
  if not found then raise exception 'Rider identity required' using errcode = '42501'; end if;
  if vehicle_payload ?| array['rider_id','vehicle_id','verification_status',
      'employment_status','maximum_capacity_kg','logistics_company_id'] then
    raise exception 'Protected vehicle fields cannot be changed' using errcode = '42501';
  end if;
  if vehicle_payload->>'vehicle_type' is distinct from current_vehicle.vehicle_type then
    raise exception 'Vehicle type changes require verification' using errcode = '22023';
  end if;
  if nullif(btrim(vehicle_payload->>'vehicle_model'), '') is null or
     nullif(btrim(vehicle_payload->>'vehicle_color'), '') is null then
    raise exception 'Vehicle model and color are required' using errcode = '22023';
  end if;
  if current_vehicle.vehicle_type not in ('bicycle','eBike') and
     (plate is null or plate !~ '^[A-Z0-9 -]{3,20}$') then
    raise exception 'A valid vehicle plate is required' using errcode = '22023';
  end if;
  -- Existing capacity authorization, gateway, vehicle ceiling and active cargo
  -- checks run in the same transaction. Failure rolls back every vehicle edit.
  perform public.set_current_rider_capacity((vehicle_payload->>'capacity_kg')::numeric);
  update public.riders set
    vehicle_brand = nullif(btrim(vehicle_payload->>'vehicle_brand'), ''),
    vehicle_model = btrim(vehicle_payload->>'vehicle_model'),
    vehicle_color = btrim(vehicle_payload->>'vehicle_color'),
    registration_number = nullif(upper(btrim(vehicle_payload->>'registration_number')), ''),
    vehicle_plate_number = case when current_vehicle.vehicle_type in ('bicycle','eBike')
      then current_vehicle.vehicle_plate_number else plate end
  where rider_id = target returning * into current_vehicle;
  return to_jsonb(current_vehicle);
end;
$$;
create or replace function public.update_current_rider_vehicle(vehicle_payload jsonb)
returns jsonb language sql security invoker set search_path = '' as $$
  select private.update_current_rider_vehicle(vehicle_payload);
$$;
revoke all on function private.update_current_rider_vehicle(jsonb),
  public.update_current_rider_vehicle(jsonb) from public, anon;
grant execute on function private.update_current_rider_vehicle(jsonb),
  public.update_current_rider_vehicle(jsonb) to authenticated, service_role;

create or replace function private.guard_vehicle_detail_gateway()
returns trigger language plpgsql security definer set search_path = '' as $$
begin
  if auth.role() = 'authenticated' then
    perform private.require_profile_editor();
    if not private.profile_gateway_verified() then
      raise sqlstate 'PT403' using message = 'Use the protected profile API';
    end if;
  end if;
  return new;
end;
$$;
revoke all on function private.guard_vehicle_detail_gateway() from public, anon, authenticated;
drop trigger if exists guard_vehicle_detail_gateway on public.riders;
create trigger guard_vehicle_detail_gateway before update of
  vehicle_brand, vehicle_model, vehicle_color, registration_number on public.riders
for each row execute function private.guard_vehicle_detail_gateway();

create or replace function private.sync_rider_license_document()
returns trigger language plpgsql security definer set search_path = '' as $$
begin
  update public.rider_documents set document_number = new.license_number
  where rider_id = new.rider_id and document_type = 'drivers_license';
  return new;
end;
$$;
revoke all on function private.sync_rider_license_document() from public, anon, authenticated;
drop trigger if exists sync_rider_license_document on public.riders;
create trigger sync_rider_license_document after update of license_number
on public.riders for each row when (old.license_number is distinct from new.license_number)
execute function private.sync_rider_license_document();

create or replace function private.sync_farm_crop_count()
returns trigger language plpgsql set search_path = '' as $$
begin
  new.total_crops := cardinality(coalesce(new.main_crops, '{}'::text[]));
  return new;
end;
$$;
revoke all on function private.sync_farm_crop_count() from public, anon, authenticated;
drop trigger if exists sync_farm_crop_count on public.farms;
create trigger sync_farm_crop_count before insert or update of main_crops, total_crops
on public.farms for each row execute function private.sync_farm_crop_count();
update public.farms set total_crops = cardinality(coalesce(main_crops, '{}'::text[]))
where total_crops is distinct from cardinality(coalesce(main_crops, '{}'::text[]));

insert into storage.buckets(id, name, public, file_size_limit, allowed_mime_types)
values ('buyer-avatars', 'buyer-avatars', false, 5242880,
  array['image/jpeg','image/png','image/webp'])
on conflict(id) do update set public = false;
drop policy if exists buyer_avatar_owner on storage.objects;
create policy buyer_avatar_owner on storage.objects for select to authenticated
using (bucket_id = 'buyer-avatars' and (storage.foldername(name))[1] = auth.uid()::text
  and not coalesce((auth.jwt()->>'is_anonymous')::boolean, false));
drop policy if exists buyer_avatar_owner_boundary on storage.objects;
create policy buyer_avatar_owner_boundary on storage.objects as restrictive
for all to authenticated
using (bucket_id <> 'buyer-avatars' or
  ((storage.foldername(name))[1] = auth.uid()::text
   and not coalesce((auth.jwt()->>'is_anonymous')::boolean, false)))
with check (bucket_id <> 'buyer-avatars');

commit;
