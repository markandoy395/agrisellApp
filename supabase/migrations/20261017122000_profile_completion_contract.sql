begin;
create or replace function public.current_signup_profile_complete()
returns boolean language plpgsql security definer set search_path = '' as $$
declare caller uuid := private.require_profile_editor(); i private.auth_identities%rowtype;
begin
  select * into i from private.auth_identities where auth_user_id = caller;
  if not found then return false; end if;
  if i.buyer_user_id is not null then
    return exists (select 1 from public.users u join public.buyers b on b.user_id = u.user_id
      where u.user_id = i.user_id and b.buyer_user_id = i.buyer_user_id
      and nullif(btrim(u.first_name), '') is not null and nullif(btrim(u.last_name), '') is not null
      and nullif(btrim(u.contact_number), '') is not null and u.date_of_birth is not null
      and nullif(btrim(u.gender), '') is not null and nullif(btrim(b.shipping_address), '') is not null);
  elsif i.farmer_user_id is not null then
    return exists (select 1 from public.farmers f join public.farms farm using(farmer_user_id)
      where f.farmer_user_id = i.farmer_user_id and f.auth_user_id = caller
      and nullif(btrim(f.first_name), '') is not null and nullif(btrim(f.last_name), '') is not null
      and nullif(btrim(f.phone_number), '') is not null and f.date_of_birth is not null
      and nullif(btrim(f.gender), '') is not null and f.years_of_experience is not null
      and nullif(btrim(f.address_line), '') is not null and nullif(btrim(f.barangay), '') is not null
      and nullif(btrim(f.city_municipality), '') is not null and nullif(btrim(f.province), '') is not null
      and nullif(btrim(farm.farm_name), '') is not null and farm.gps_lat is not null and farm.gps_long is not null);
  elsif i.rider_id is not null then
    return exists (select 1 from public.riders r where r.rider_id = i.rider_id
      and nullif(btrim(r.first_name), '') is not null and nullif(btrim(r.last_name), '') is not null
      and nullif(btrim(r.contact_number), '') is not null and r.date_of_birth is not null
      and nullif(btrim(r.gender), '') is not null and nullif(btrim(r.address_line), '') is not null
      and nullif(btrim(r.barangay), '') is not null and nullif(btrim(r.city_municipality), '') is not null
      and nullif(btrim(r.province), '') is not null and r.accepted_terms_at is not null
      and r.accepted_privacy_at is not null and r.confirmed_accuracy_at is not null);
  end if;
  return false;
end;
$$;
revoke all on function public.current_signup_profile_complete() from public, anon;
grant execute on function public.current_signup_profile_complete() to authenticated, service_role;
commit;
