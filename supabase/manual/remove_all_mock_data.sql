-- Remove only the marketplace_mock_v1 and rider_mock_v1 account graphs.
-- Delete their uploaded files through Storage API before committing this SQL.
-- Foreign keys stay enabled. Never truncate or reset shared application tables.
begin;
set local lock_timeout = '5s';
set local statement_timeout = '90s';
select pg_advisory_xact_lock(hashtext('marketplace_mock_v1'));
select pg_advisory_xact_lock(hashtext('rider_mock_v1'));
create temporary table cleanup_auth on commit drop as
select id from auth.users where raw_app_meta_data ->> 'test_seed'
  in ('marketplace_mock_v1','rider_mock_v1');
create temporary table cleanup_profiles on commit drop as
select i.* from private.auth_identities i join cleanup_auth a on a.id=i.auth_user_id;
create temporary table cleanup_farms on commit drop as
select farm_id from public.farms where farmer_user_id in
  (select farmer_user_id from cleanup_profiles);
create temporary table cleanup_products on commit drop as
select commodity_id from public.commodities where farm_id in (select farm_id from cleanup_farms);
create temporary table cleanup_carts on commit drop as
select cart_id from public.carts where buyer_user_id in (select buyer_user_id from cleanup_profiles);
create temporary table cleanup_cart_items on commit drop as
select cart_item_id from public.cart_items where cart_id in (select cart_id from cleanup_carts)
  or commodity_id in (select commodity_id from cleanup_products);
create temporary table cleanup_orders on commit drop as
select order_id,client_order_id from public.orders
where cart_item_id in (select cart_item_id from cleanup_cart_items)
  or seller_farm_id in (select farm_id from cleanup_farms);
create temporary table cleanup_deliveries on commit drop as
select delivery_id from public.deliveries where order_id in (select order_id from cleanup_orders);
create temporary table cleanup_conversations on commit drop as
select conversation_id from public.marketplace_conversations
where buyer_user_id in (select buyer_user_id from cleanup_profiles)
  or farmer_user_id in (select farmer_user_id from cleanup_profiles)
  or commodity_id in (select commodity_id from cleanup_products)
  or farm_id in (select farm_id from cleanup_farms)
  or order_id in (select order_id from cleanup_orders);
create temporary table cleanup_counts on commit drop as
select (select count(*) from cleanup_auth) as accounts,
  (select count(*) from cleanup_products) as products,
  (select count(*) from cleanup_deliveries) as deliveries,
  (select count(*) from public.marketplace_messages where conversation_id in
    (select conversation_id from cleanup_conversations)) +
  (select count(*) from public.rider_delivery_messages where delivery_id in
    (select delivery_id from cleanup_deliveries)) as messages,
  (select count(*) from public.notifications where recipient_auth_user_id in
    (select id from cleanup_auth) or order_id in (select order_id from cleanup_orders)) as alerts;
create temporary table preserved_counts on commit drop as
select (select count(*) from auth.users where id not in (select id from cleanup_auth)) as accounts,
  (select count(*) from public.users where user_id not in
    (select user_id from cleanup_profiles where user_id is not null)) as users,
  (select count(*) from public.commodities where commodity_id not in
    (select commodity_id from cleanup_products)) as products,
  (select count(*) from public.deliveries where delivery_id not in
    (select delivery_id from cleanup_deliveries)) as deliveries,
  (select count(*) from public.admins) as admins;
do $$ begin
  if exists (select 1 from public.admins a join cleanup_profiles i using(user_id)) then
    raise exception 'Mock graph contains an admin; cleanup aborted';
  end if;
end $$;

delete from public.notifications where recipient_auth_user_id in (select id from cleanup_auth)
  or order_id in (select order_id from cleanup_orders);
delete from public.marketplace_conversations where conversation_id in
  (select conversation_id from cleanup_conversations);
delete from private.rider_payout_allocations where delivery_id in
  (select delivery_id from cleanup_deliveries) or request_id in
  (select request_id from public.payout_requests where user_id in (select id from cleanup_auth));
delete from public.payout_requests where user_id in (select id from cleanup_auth);
delete from private.admin_delivery_commands where delivery_id in (select delivery_id from cleanup_deliveries);
delete from private.delivery_location_history where delivery_id in (select delivery_id from cleanup_deliveries)
  or rider_id in (select rider_id from cleanup_profiles);
delete from private.rider_delivery_assignments where delivery_id in (select delivery_id from cleanup_deliveries);
delete from private.order_delivery_fulfillments where delivery_id in (select delivery_id from cleanup_deliveries);
delete from public.deliveries where delivery_id in (select delivery_id from cleanup_deliveries);
delete from private.gcash_verified_reference_claims where buyer_user_id in
  (select buyer_user_id from cleanup_profiles) or farmer_user_id in (select farmer_user_id from cleanup_profiles);
delete from private.order_acceptance_events where seller_order_id in
  (select client_order_id from cleanup_orders);
delete from private.seller_order_registry where buyer_user_id in
  (select buyer_user_id from cleanup_profiles) or seller_farm_id in (select farm_id from cleanup_farms);
delete from private.order_checkout_keys where buyer_user_id in (select buyer_user_id from cleanup_profiles);
delete from public.reviews where order_id in (select order_id from cleanup_orders)
  or commodity_id in (select commodity_id from cleanup_products)
  or buyer_user_id in (select buyer_user_id from cleanup_profiles)
  or farmer_user_id in (select farmer_user_id from cleanup_profiles);
delete from public.payments where order_id in (select order_id from cleanup_orders);
delete from private.order_inventory_lot_allocations where order_item_id in
  (select order_item_id from public.order_items where order_id in (select order_id from cleanup_orders));
delete from public.order_items where order_id in (select order_id from cleanup_orders);
delete from public.orders where order_id in (select order_id from cleanup_orders);
delete from public.cart_items where cart_item_id in (select cart_item_id from cleanup_cart_items);
delete from public.carts where cart_id in (select cart_id from cleanup_carts);
delete from private.commodity_restock_history where commodity_id in
  (select commodity_id from cleanup_products) or performed_by in (select id from cleanup_auth);
delete from public.commodity_inventory_lots where commodity_id in (select commodity_id from cleanup_products);
delete from public.commodities where commodity_id in (select commodity_id from cleanup_products);
delete from public.categories where farm_id in (select farm_id from cleanup_farms);
delete from public.farms where farm_id in (select farm_id from cleanup_farms);
delete from private.farmer_payouts where farmer_user_id in (select farmer_user_id from cleanup_profiles);
delete from public.rider_assignment_requests where rider_id in (select rider_id from cleanup_profiles)
  or farmer_user_id in (select farmer_user_id from cleanup_profiles);
delete from public.rider_incidents where reporter_auth_id in (select id from cleanup_auth);
delete from private.auth_identities where auth_user_id in (select id from cleanup_auth);
delete from public.buyers where buyer_user_id in (select buyer_user_id from cleanup_profiles);
delete from public.farmers where farmer_user_id in (select farmer_user_id from cleanup_profiles);
delete from public.riders where rider_id in (select rider_id from cleanup_profiles);
delete from public.users where user_id in (select user_id from cleanup_profiles);
delete from auth.users where id in (select id from cleanup_auth);

do $$ begin
  if exists (select 1 from auth.users where id in (select id from cleanup_auth))
    or exists (select 1 from public.commodities where commodity_id in (select commodity_id from cleanup_products))
    or exists (select 1 from public.deliveries where delivery_id in (select delivery_id from cleanup_deliveries)) then
    raise exception 'Mock cleanup incomplete';
  end if;
  if (select count(*) from auth.users) <> (select accounts from preserved_counts)
    or (select count(*) from public.users) <> (select users from preserved_counts)
    or (select count(*) from public.commodities) <> (select products from preserved_counts)
    or (select count(*) from public.deliveries) <> (select deliveries from preserved_counts)
    or (select count(*) from public.admins) <> (select admins from preserved_counts) then
    raise exception 'Unrelated record counts changed; cleanup aborted';
  end if;
end $$;
select * from cleanup_counts;
commit;
