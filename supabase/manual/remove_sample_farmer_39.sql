-- Remove the sample farmer Benjomark Andoy (farmer ID 39) and owned data.
-- Restrictive foreign keys abort the transaction if other records depend on
-- these fixtures. Never disable constraints or reset unrelated application data.
begin;
set local lock_timeout = '5s';
set local statement_timeout = '60s';
select pg_advisory_xact_lock(hashtext('remove_sample_farmer_39'));

create temporary table mock_auth on commit drop as
select a.id from auth.users a join public.farmers f on f.auth_user_id = a.id
where f.farmer_user_id = 39 and f.first_name = 'Benjomark' and f.last_name = 'Andoy';
create temporary table mock_profiles on commit drop as
select i.* from private.auth_identities i join mock_auth a on a.id = i.auth_user_id;
create temporary table mock_farms on commit drop as
select f.farm_id from public.farms f
join mock_profiles i using (farmer_user_id);
create temporary table mock_products on commit drop as
select c.commodity_id from public.commodities c join mock_farms f using (farm_id);
create temporary table mock_cleanup_counts on commit drop as
select (select count(*) from mock_auth) as accounts,
  (select count(*) from mock_profiles where farmer_user_id is not null) as farmers,
  (select count(*) from mock_profiles where buyer_user_id is not null) as buyers,
  (select count(*) from mock_products) as products;
create temporary table preserved_counts on commit drop as
select
  (select count(*) from auth.users where id not in (select id from mock_auth)) as accounts,
  (select count(*) from public.users where user_id not in
    (select user_id from mock_profiles where user_id is not null)) as users,
  (select count(*) from public.commodities where commodity_id not in
    (select commodity_id from mock_products)) as products;

do $$
begin
  if exists (select 1 from public.admins a join mock_profiles i using (user_id)) then
    raise exception 'Seed account is an administrator; cleanup aborted';
  end if;
end $$;

delete from private.commodity_restock_history
where commodity_id in (select commodity_id from mock_products);
delete from public.commodity_inventory_lots
where commodity_id in (select commodity_id from mock_products);
delete from public.cart_items
where commodity_id in (select commodity_id from mock_products)
  or cart_id in (select cart_id from public.carts where buyer_user_id in
    (select buyer_user_id from mock_profiles));
delete from public.carts
where buyer_user_id in (select buyer_user_id from mock_profiles);
delete from public.commodities
where commodity_id in (select commodity_id from mock_products);
delete from public.categories where farm_id in (select farm_id from mock_farms);
delete from public.farms where farm_id in (select farm_id from mock_farms);
delete from private.auth_identities where auth_user_id in (select id from mock_auth);
delete from public.buyers
where buyer_user_id in (select buyer_user_id from mock_profiles);
delete from public.farmers
where farmer_user_id in (select farmer_user_id from mock_profiles);
delete from public.users where user_id in (select user_id from mock_profiles);
delete from auth.users where id in (select id from mock_auth);

do $$
begin
  if exists (select 1 from auth.users
      where id in (select id from mock_auth))
    or exists (select 1 from public.commodities
      where commodity_id in (select commodity_id from mock_products)) then
    raise exception 'Sample farmer cleanup is incomplete';
  end if;
  if (select count(*) from auth.users) <> (select accounts from preserved_counts)
    or (select count(*) from public.users) <> (select users from preserved_counts)
    or (select count(*) from public.commodities) <> (select products from preserved_counts) then
    raise exception 'Unrelated account/product count changed; cleanup aborted';
  end if;
end $$;

-- Counts remain available until the transaction commits.
select * from mock_cleanup_counts;
commit;

