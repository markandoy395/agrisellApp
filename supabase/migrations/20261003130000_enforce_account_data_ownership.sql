begin;

-- UUID login IDs are distinct from the numeric application account IDs.
create or replace function public.current_query_owner()
returns jsonb language sql stable security definer set search_path = '' as $$
  select jsonb_build_object(
    'auth_user_id', auth.uid(), 'user_id', private.current_user_id(),
    'buyer_user_id', private.current_buyer_user_id(),
    'farmer_user_id', private.current_farmer_user_id(),
    'rider_id', private.current_rider_id()
  ) where auth.uid() is not null
    and coalesce(auth.jwt()->>'is_anonymous', 'false') = 'false'
$$;
revoke all on function public.current_query_owner() from public, anon;
grant execute on function public.current_query_owner() to authenticated;

create or replace function private.account_is_delivery_participant(target_id bigint)
returns boolean language sql stable security definer set search_path = '' as $$
  select exists (select 1 from public.deliveries d where d.delivery_id = target_id
    and (private.owns_order(d.order_id) or exists (
      select 1 from private.rider_delivery_assignments a
      where a.delivery_id = d.delivery_id and a.rider_id = private.current_rider_id())))
$$;
create or replace function private.account_is_chat_participant(target_id bigint)
returns boolean language sql stable security definer set search_path = '' as $$
  select exists (select 1 from public.marketplace_conversations c
    join public.farmers f on f.farmer_user_id = c.farmer_user_id
    where c.conversation_id = target_id and (
      c.buyer_user_id = private.current_buyer_user_id() or f.auth_user_id = auth.uid()))
$$;
revoke all on function private.account_is_delivery_participant(bigint),
  private.account_is_chat_participant(bigint) from public, anon;
grant execute on function private.account_is_delivery_participant(bigint),
  private.account_is_chat_participant(bigint) to authenticated;

-- Restrictive policies intersect existing permissive policies. An unrelated
-- permissive policy (including an admin policy) cannot widen personal access.
-- Backend service_role operations retain their existing RLS bypass.
do $ownership$
declare
  target record;
begin
  for target in select * from (values
    ('users', 'user_id = (select private.current_user_id())'),
    ('buyers', 'buyer_user_id = (select private.current_buyer_user_id())'),
    ('farmers', 'auth_user_id = (select auth.uid())'),
    ('riders', 'rider_id = (select private.current_rider_id())'),
    ('carts', 'buyer_user_id = (select private.current_buyer_user_id())'),
    ('cart_items', 'private.owns_cart(cart_id)'),
    ('notification_devices', 'user_id = (select auth.uid())'),
    ('notifications', 'recipient_auth_user_id = (select auth.uid())'),
    ('user_withdrawal_methods', 'user_id = (select auth.uid())'),
    ('payout_requests', 'user_id = (select auth.uid())'),
    ('support_tickets', 'user_id = (select private.current_user_id())'),
    ('support_messages', 'exists (select 1 from public.support_tickets t '
      'where t.ticket_id = support_messages.ticket_id '
      'and t.user_id = (select private.current_user_id()))'),
    ('rider_documents', 'rider_id = (select private.current_rider_id())'),
    ('rider_vehicles', 'rider_id = (select private.current_rider_id())'),
    ('rider_locations', 'rider_id = (select private.current_rider_id())'),
    ('rider_incidents', 'reporter_auth_id = (select auth.uid()) or '
      '(reporter_auth_id is null and rider_id = (select private.current_rider_id()))'),
    ('rider_conversation_reads', 'rider_id = (select private.current_rider_id())'),
    ('delivery_payments', 'private.rider_owns_delivery(delivery_id)'),
    ('farmer_review_appeals', 'farmer_user_id = coalesce('
      'private.current_farmer_user_id(), private.current_authenticated_farmer_user_id())'),
    ('farm_followers', 'buyer_user_id = (select private.current_buyer_user_id())')
  ) as mapping(table_name, predicate)
  loop
    if to_regclass('public.' || target.table_name) is null then
      -- The final ERD embeds vehicles in riders; earlier schemas used this table.
      if target.table_name = 'rider_vehicles' then continue; end if;
      raise exception 'Ownership table missing: %', target.table_name;
    end if;
    begin
      execute format('alter table public.%I enable row level security', target.table_name);
      execute format('create policy account_owner_boundary on public.%I '
        'as restrictive for all to authenticated using (auth.uid() is not null '
        'and (%s)) with check (auth.uid() is not null and (%s))',
        target.table_name, target.predicate, target.predicate);
    exception when others then
      raise exception 'Ownership policy failed for public.% [%]: %',
        target.table_name, sqlstate, sqlerrm using errcode = sqlstate;
    end;
  end loop;
end;
$ownership$;

-- Reads of transaction records belong to the buyer/seller/rider participants,
-- not every account. Catalogue rows remain shared; mutations stay owner-bound.
do $participants$
declare
  target record;
begin
  for target in select * from (values
    ('orders', 'private.owns_order(order_id)'),
    ('order_items', 'private.owns_order(order_id)'),
    ('payments', 'private.can_access_payment(payment_id)'),
    ('marketplace_conversations', 'private.account_is_chat_participant(conversation_id)'),
    ('marketplace_messages', 'private.account_is_chat_participant(conversation_id)'),
    ('rider_delivery_messages', 'private.account_is_delivery_participant(delivery_id)'),
    ('rider_ratings', 'rider_id = private.current_rider_id() or reviewer_auth_id = auth.uid()'),
    ('rider_assignment_requests', 'farmer_user_id = private.current_farmer_user_id() '
      'or rider_id = private.current_rider_id()'),
    ('deliveries', 'private.account_is_delivery_participant(delivery_id)'),
    ('delivery_proofs', 'private.account_is_delivery_participant(delivery_id)'),
    ('delivery_locations', 'private.account_is_delivery_participant(delivery_id)'),
    ('delivery_requirements', 'private.account_is_delivery_participant(delivery_id)'),
    ('delivery_status_history', 'private.account_is_delivery_participant(delivery_id)')
  ) as mapping(table_name, predicate)
  loop
    if to_regclass('public.' || target.table_name) is not null then
      execute format('create policy account_participant_boundary on public.%I '
        'as restrictive for select to authenticated using (%s)',
        target.table_name, target.predicate);
    end if;
  end loop;
  for target in select * from (values
    ('farms', 'private.owns_farm(farm_id)'),
    ('categories', 'private.owns_farm(farm_id)'),
    ('commodities', 'private.owns_farm(farm_id)'),
    ('product_sales', 'private.owns_farm(farm_id)'),
    ('product_sale_items', 'exists (select 1 from public.product_sales s '
      'where s.sale_id = product_sale_items.sale_id and private.owns_farm(s.farm_id))'),
    ('reviews', 'buyer_user_id = (select private.current_buyer_user_id())'),
    ('rider_delivery_messages', 'sender_auth_id = (select auth.uid()) '
      'and private.account_is_delivery_participant(delivery_id)'),
    ('rider_ratings', 'reviewer_auth_id = (select auth.uid()) '
      'and private.account_is_delivery_participant(delivery_id)'),
    ('commodity_inventory_lots', 'exists (select 1 from public.commodities c '
      'where c.commodity_id = commodity_inventory_lots.commodity_id and private.owns_farm(c.farm_id))')
  ) as mapping(table_name, predicate)
  loop
    if to_regclass('public.' || target.table_name) is not null then
      execute format('create policy account_owner_update_boundary on public.%I '
        'as restrictive for update to authenticated using (%s) with check (%s)',
        target.table_name, target.predicate, target.predicate);
      execute format('create policy account_owner_delete_boundary on public.%I '
        'as restrictive for delete to authenticated using (%s)',
        target.table_name, target.predicate);
      execute format('create policy account_owner_insert_boundary on public.%I '
        'as restrictive for insert to authenticated with check (%s)',
        target.table_name, target.predicate);
    end if;
  end loop;
end;
$participants$;

create policy account_delivery_creator_boundary on public.deliveries
  as restrictive for insert to authenticated
  with check (private.owns_order(order_id));

create policy account_delivery_mutation_boundary on public.deliveries
  as restrictive for update to authenticated
  using (private.account_is_delivery_participant(delivery_id))
  with check (private.account_is_delivery_participant(delivery_id));

create policy account_delivery_delete_boundary on public.deliveries
  as restrictive for delete to authenticated
  using (private.owns_order(order_id));

-- Never let normal authenticated users invoke privileged administration RPCs.
do $admin$
declare target record;
begin
  for target in select p.oid::regprocedure as signature
    from pg_proc p join pg_namespace n on n.oid = p.pronamespace
    where n.nspname in ('public', 'private') and p.prokind = 'f'
      and p.proname like 'admin\_%' escape '\'
  loop
    execute format('revoke all on function %s from public, anon, authenticated', target.signature);
    execute format('grant execute on function %s to service_role', target.signature);
  end loop;
end;
$admin$;

-- Administration records are served by the trusted backend, not user sessions.
do $admin_tables$
declare target record;
begin
  for target in select c.relname from pg_class c
    join pg_namespace n on n.oid = c.relnamespace
    where n.nspname = 'public' and c.relkind in ('r', 'p')
      and c.relname like 'admin\_%' escape '\'
  loop
    execute format('alter table public.%I enable row level security', target.relname);
    execute format('create policy account_admin_boundary on public.%I '
      'as restrictive for all to authenticated using (false) with check (false)', target.relname);
  end loop;
end;
$admin_tables$;

notify pgrst, 'reload schema';
commit;
