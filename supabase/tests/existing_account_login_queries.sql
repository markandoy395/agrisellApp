-- Exercise the sign-in profile queries with existing identities only.
-- Returns no account details and rolls back all session settings and temp data.
begin;
create temporary table login_audit_accounts as
select auth_user_id from private.auth_identities where auth_user_id is not null;
grant select on login_audit_accounts to authenticated;
set local role authenticated;
do $audit$
declare
  actor record;
  identity jsonb;
begin
  for actor in select * from login_audit_accounts loop
    perform set_config('request.jwt.claim.sub', actor.auth_user_id::text, true);
    perform set_config('request.jwt.claims', jsonb_build_object(
      'sub', actor.auth_user_id, 'role', 'authenticated', 'is_anonymous', false)::text, true);
    perform first_name,last_name,suffix,phone_number,date_of_birth,
      account_status,verification_status,profile_image_url
      from public.farmers where auth_user_id = actor.auth_user_id;
    perform public.current_application_role();
    identity := public.current_query_owner();
    perform shipping_address,gps_lat,gps_long from public.buyers
      where buyer_user_id = (identity->>'buyer_user_id')::bigint;
    perform first_name,last_name,email,contact_number,employment_status,profile_photo_url
      from public.riders where rider_id::text = identity->>'rider_id';
    perform first_name,last_name,extension_name,email,contact_number,
      date_of_birth,account_status,profile_photo_url
      from public.users where user_id = (identity->>'user_id')::bigint;
  end loop;
end;
$audit$;
reset role;
rollback;
