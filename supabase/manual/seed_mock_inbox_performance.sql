-- Performance fixtures for marketplace_mock_v1 accounts only.
-- 30 conversations per account, 50 extra messages per thread, 500 extra alerts.
-- Existing sample inbox records are retained. Re-runs do not add duplicates.
begin;
set local lock_timeout = '5s';
set local statement_timeout = '90s';
select pg_advisory_xact_lock(hashtext('marketplace_mock_v1'));
select set_config('request.jwt.claims', '{"role":"service_role"}', true);
select set_config('request.jwt.claim.role', 'service_role', true);

create temporary table performance_accounts on commit drop as
select a.id as auth_id, i.buyer_user_id, i.farmer_user_id
from auth.users a join private.auth_identities i on i.auth_user_id = a.id
where a.raw_app_meta_data ->> 'test_seed' = 'marketplace_mock_v1';
do $$
begin
  if (select count(*) from performance_accounts where buyer_user_id is not null) <> 30
    or (select count(*) from performance_accounts where farmer_user_id is not null) <> 30 then
    raise exception 'Expected 30 mock buyers and 30 mock farmers';
  end if;
end $$;

create temporary table performance_pairs on commit drop as
select b.buyer_user_id, f.farmer_user_id, p.farm_id, p.commodity_id
from performance_accounts b cross join performance_accounts f
cross join lateral (
  select farm.farm_id, c.commodity_id from public.farms farm
  join public.commodities c using (farm_id)
  where farm.farmer_user_id = f.farmer_user_id
    and c.availability_status = 'ready_now'
  order by c.commodity_id limit 1
) p
where b.buyer_user_id is not null and f.farmer_user_id is not null;
create unique index on performance_pairs (buyer_user_id, farm_id, commodity_id);

insert into public.marketplace_conversations (
  buyer_user_id, farmer_user_id, farm_id, commodity_id,
  buyer_last_read_at, farmer_last_read_at, created_at, updated_at
)
select buyer_user_id, farmer_user_id, farm_id, commodity_id,
  now() - interval '7 days', now() - interval '7 days',
  now() - interval '14 days', now()
from performance_pairs p
where not exists (select 1 from public.marketplace_conversations c
  where c.buyer_user_id = p.buyer_user_id and c.farm_id = p.farm_id
    and c.commodity_id = p.commodity_id and c.order_id is null);

create temporary table performance_threads on commit drop as
select c.conversation_id, c.buyer_user_id, c.farmer_user_id
from public.marketplace_conversations c join performance_pairs p
  on p.buyer_user_id = c.buyer_user_id and p.farm_id = c.farm_id
  and p.commodity_id = c.commodity_id
where c.order_id is null;

insert into public.marketplace_messages (conversation_id, sender_role, body, sent_at)
select t.conversation_id, case when s.n % 2 = 1 then 'buyer' else 'farmer' end,
  '[Sample] Performance message ' || lpad(s.n::text, 3, '0') || ': ' ||
  case s.n % 5
    when 0 then 'Thank you! I will review the available produce in the app.'
    when 1 then 'Hello, is this produce available for ordering this week?'
    when 2 then 'Yes, fresh stock is available. Please check the listing for current prices.'
    when 3 then 'I am comparing quantities and delivery options before placing an order.'
    else 'We pack the produce carefully. You can confirm the details through the app.'
  end,
  now() - interval '5 days' + s.n * interval '2 hours'
    + (t.conversation_id % 60) * interval '1 minute'
from performance_threads t cross join generate_series(1, 50) s(n)
where not exists (select 1 from public.marketplace_messages m
  where m.conversation_id = t.conversation_id
    and m.body like '[Sample] Performance message ' || lpad(s.n::text, 3, '0') || ':%');

-- Keep thread previews ordered by their actual newest message. Do not reset reads.
update public.marketplace_conversations c set updated_at = summary.latest
from (select m.conversation_id, max(m.sent_at) as latest
  from public.marketplace_messages m join performance_threads t using (conversation_id)
  group by m.conversation_id) summary
where c.conversation_id = summary.conversation_id;

-- Avoid 30,000 synthetic push requests. This transactional DDL holds a table
-- lock, restores the existing trigger before commit, and rolls back on failure.
alter table public.notifications disable trigger notifications_dispatch_push_after_insert;
insert into public.notifications (recipient_auth_user_id, title, description,
  created_at, read_at, notification_type, category, destination, metadata)
select a.auth_id,
  '[Sample] ' || case s.n % 3 when 0 then 'Marketplace update'
    when 1 then 'New message' else 'Fresh produce available' end || ' #' || s.n,
  'Performance test alert ' || s.n || '. ' || case s.n % 3
    when 0 then 'Your sample account is ready to explore the marketplace.'
    when 1 then 'Open Messages to view your sample conversations.'
    else 'Browse the sample produce listings and compare available quantities.' end,
  now() - s.n * interval '20 minutes',
  case when s.n % 3 = 0 then now() - s.n * interval '10 minutes' end,
  case when s.n % 3 = 1 then 'new_message' else 'verification_update' end,
  case s.n % 3 when 0 then 'system' when 1 then 'messages' else 'products' end,
  case s.n % 3 when 0 then 'none' when 1 then 'messages' else 'products' end,
  jsonb_build_object('test_seed', 'marketplace_mock_performance_v1', 'sample_alert', s.n,
    'conversation_id', (select min(t.conversation_id)::text from performance_threads t
      where t.buyer_user_id = a.buyer_user_id or t.farmer_user_id = a.farmer_user_id))
from performance_accounts a cross join generate_series(1, 500) s(n)
where not exists (select 1 from public.notifications existing
  where existing.recipient_auth_user_id = a.auth_id
    and existing.metadata ->> 'test_seed' = 'marketplace_mock_performance_v1'
    and existing.metadata ->> 'sample_alert' = s.n::text);
alter table public.notifications enable trigger notifications_dispatch_push_after_insert;

do $$
begin
  if (select count(*) from performance_threads) <> 900
    or (select count(*) from public.marketplace_messages m
      join performance_threads t using (conversation_id)
      where m.body like '[Sample] Performance message %') <> 45000
    or (select count(*) from public.notifications n
      join performance_accounts a on a.auth_id = n.recipient_auth_user_id
      where n.metadata ->> 'test_seed' = 'marketplace_mock_performance_v1') <> 30000 then
    raise exception 'Performance fixture counts do not match; rolling back';
  end if;
end $$;
select (select count(*) from performance_threads) as conversations,
  (select count(*) from public.marketplace_messages m
    join performance_threads t using (conversation_id)) as total_messages,
  (select count(*) from public.notifications n
    join performance_accounts a on a.auth_id = n.recipient_auth_user_id
    where n.metadata ->> 'test_seed' in
      ('marketplace_mock_performance_v1', 'marketplace_mock_messages_v1')) as sample_alerts;
commit;
