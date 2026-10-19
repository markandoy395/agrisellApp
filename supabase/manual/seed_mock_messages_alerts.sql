-- Sample inboxes for the 60 marketplace_mock_v1 accounts only.
-- 60 conversations, 240 messages, 180 alerts. Safe to rerun without duplicates.
begin;
select pg_advisory_xact_lock(hashtext('marketplace_mock_v1'));
-- Trusted owner seed uses the existing service-role exemption in chat triggers.
select set_config('request.jwt.claims', '{"role":"service_role"}', true);
select set_config('request.jwt.claim.role', 'service_role', true);

create temporary table sample_inboxes on commit drop as
select a.id as auth_id, a.email, i.buyer_user_id, i.farmer_user_id,
  a.raw_user_meta_data ->> 'requested_role' as role_name
from auth.users a join private.auth_identities i on i.auth_user_id = a.id
where a.raw_app_meta_data ->> 'test_seed' = 'marketplace_mock_v1';

do $seed$
declare
  n integer;
  thread_index integer;
  message_index integer;
  alert_index integer;
  buyer_record record;
  farmer_record record;
  account_record record;
  product_record record;
  thread_id bigint;
  first_thread_id bigint;
  message_text text;
  seed_time timestamptz := now();
  alert_titles text[] := array['Sample: New message',
    'Sample: Fresh produce available', 'Sample: Welcome to AgriSell'];
begin
  if (select count(*) from sample_inboxes where role_name = 'buyer') <> 30
    or (select count(*) from sample_inboxes where role_name = 'farmer') <> 30 then
    raise exception 'Restore the 30 mock buyers and 30 mock farmers first';
  end if;

  for n in 1..30 loop
    select * into strict buyer_record from sample_inboxes
    where email = 'mock.buyer' || lpad(n::text, 2, '0') || '@example.com';
    for thread_index in 0..1 loop
      select * into strict farmer_record from sample_inboxes
      where email = 'mock.farmer' || lpad((1 + (n - 1 + thread_index) % 30)::text,
        2, '0') || '@example.com';
      select c.commodity_id, c.commodity_name, f.farm_id into strict product_record
      from public.farms f join public.commodities c using (farm_id)
      where f.farmer_user_id = farmer_record.farmer_user_id
        and c.availability_status = 'ready_now'
      order by c.commodity_id limit 1;

      select conversation_id into thread_id from public.marketplace_conversations
      where buyer_user_id = buyer_record.buyer_user_id
        and farm_id = product_record.farm_id
        and commodity_id = product_record.commodity_id and order_id is null;
      if thread_id is null then
        insert into public.marketplace_conversations (
          buyer_user_id, farmer_user_id, farm_id, commodity_id,
          buyer_last_read_at, farmer_last_read_at, created_at, updated_at
        ) values (buyer_record.buyer_user_id, farmer_record.farmer_user_id,
          product_record.farm_id, product_record.commodity_id,
          seed_time - interval '2 hours', seed_time - interval '2 hours',
          seed_time - interval '3 hours', seed_time - interval '30 minutes')
        returning conversation_id into thread_id;
      end if;
      for message_index in 1..4 loop
        message_text := case message_index
          when 1 then '[Sample] Hello! Is ' || product_record.commodity_name || ' available?'
          when 2 then '[Sample] Yes, we have fresh stock. How many kilograms would you like?'
          when 3 then '[Sample] I would like 2 kg. Can you confirm the quality and packaging?'
          else '[Sample] We select fresh produce and pack it carefully. You can order through the app.'
        end;
        if not exists (select 1 from public.marketplace_messages
          where conversation_id = thread_id and body = message_text) then
          insert into public.marketplace_messages (conversation_id, sender_role, body, sent_at)
          values (thread_id, case when message_index % 2 = 1 then 'buyer' else 'farmer' end,
            message_text, seed_time - interval '3 hours' + message_index * interval '30 minutes');
        end if;
      end loop;
    end loop;
  end loop;

  for account_record in select * from sample_inboxes loop
    select min(conversation_id) into first_thread_id from public.marketplace_conversations
    where (account_record.role_name = 'buyer' and buyer_user_id = account_record.buyer_user_id)
      or (account_record.role_name = 'farmer' and farmer_user_id = account_record.farmer_user_id);
    for alert_index in 1..3 loop
      if not exists (select 1 from public.notifications
        where recipient_auth_user_id = account_record.auth_id
          and metadata ->> 'test_seed' = 'marketplace_mock_messages_v1'
          and metadata ->> 'sample_alert' = alert_index::text) then
        insert into public.notifications (recipient_auth_user_id, title, description,
          created_at, read_at, notification_type, category, destination, metadata)
        values (account_record.auth_id, alert_titles[alert_index],
          case alert_index
            when 1 then 'Sample chat activity is ready. Open Messages to try your inbox.'
            when 2 then 'Explore the sample produce listings and test the marketplace.'
            else 'Your sample account is ready for testing messages and alerts.'
          end,
          seed_time - alert_index * interval '20 minutes',
          case when alert_index = 3 then seed_time - interval '10 minutes' end,
          case when alert_index = 1 then 'new_message' else 'verification_update' end,
          case alert_index when 1 then 'messages' when 2 then 'products' else 'system' end,
          case alert_index when 1 then 'messages' when 2 then 'products' else 'none' end,
          jsonb_build_object('test_seed', 'marketplace_mock_messages_v1',
            'sample_alert', alert_index, 'conversation_id', first_thread_id::text));
      end if;
    end loop;
  end loop;
end;
$seed$;

select (select count(*) from public.marketplace_conversations c
    join sample_inboxes b on b.buyer_user_id = c.buyer_user_id
    join sample_inboxes f on f.farmer_user_id = c.farmer_user_id) as sample_conversations,
  (select count(*) from public.marketplace_messages m
    join public.marketplace_conversations c using (conversation_id)
    join sample_inboxes b on b.buyer_user_id = c.buyer_user_id
    join sample_inboxes f on f.farmer_user_id = c.farmer_user_id
    where m.body like '[Sample]%') as sample_messages,
  (select count(*) from public.notifications
    where metadata ->> 'test_seed' = 'marketplace_mock_messages_v1') as sample_alerts;
commit;
