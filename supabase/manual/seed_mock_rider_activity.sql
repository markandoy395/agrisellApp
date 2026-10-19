-- Part 3. Completes and commits the rider seed transaction.
insert into public.rider_delivery_messages (delivery_id, party, sender_role,
  sender_auth_id, message_kind, body, idempotency_key, sent_at)
select d.delivery_id, party,
  case when s.n % 2 = 0 then 'rider' when party = 'support' then 'support' else 'participant' end,
  case when s.n % 2 = 0 then d.auth_id when party = 'buyer' then d.buyer_auth
    when party = 'seller' then d.farmer_auth end,
  'text', '[Sample] Rider chat message ' || s.n || ': ' ||
  case when s.n % 2 = 0 then 'Thanks! I will keep you updated about this delivery.'
    else 'Please handle the produce carefully and check the delivery address.' end,
  'sample-rider-' || d.delivery_id || '-' || party || '-' || s.n,
  now() - interval '1 day' + s.n * interval '1 hour' + d.slot * interval '1 minute'
from mock_rider_deliveries d cross join unnest(array['buyer','seller','support']) party
cross join generate_series(1, 20) s(n)
where d.slot <= 25 and not exists (select 1 from public.rider_delivery_messages m
  where m.delivery_id = d.delivery_id and m.party = party
    and m.idempotency_key = 'sample-rider-' || d.delivery_id || '-' || party || '-' || s.n);

insert into public.user_withdrawal_methods (user_id, user_role, payout_method,
  account_name, account_number, bank_name, is_default)
select auth_id, 'rider', method, 'SAMPLE RIDER ' || n,
  case when method = 'gcash' then '093' || lpad(n::text, 8, '0')
    else 'SAMPLE-BANK-' || n end,
  case when method = 'bank_transfer' then 'Sample Bank (testing only)' end,
  method = 'gcash'
from mock_rider_context c cross join unnest(array['gcash','bank_transfer']) method
where not exists (select 1 from public.user_withdrawal_methods m
  where m.user_id = c.auth_id and m.payout_method = method);

do $payouts$
declare c record; j integer; d record; request_value uuid; status_value text;
begin
  for c in select * from mock_rider_context loop
    for j in 1..4 loop
      status_value := (array['paid','pending','approved','rejected'])[j];
      if exists (select 1 from public.payout_requests where user_id = c.auth_id
        and notes = '[Sample] Rider payout history ' || j) then continue; end if;
      select * into strict d from mock_rider_deliveries
      where rider_id = c.rider_id and slot = j;
      insert into public.payout_requests (user_id, user_role, amount, payout_method,
        account_name, account_number, status, notes, rejection_reason,
        payout_reference, paid_at, created_at)
      values (c.auth_id, 'rider', 70 + j * 2, 'gcash', 'SAMPLE RIDER ' || c.n,
        '093' || lpad(c.n::text, 8, '0'), status_value,
        '[Sample] Rider payout history ' || j,
        case when j = 4 then '[Sample] Please confirm the test account details.' end,
        case when j = 1 then 'SAMPLE-PAYOUT-' || c.n end,
        case when j = 1 then now() - interval '1 day' end,
        now() - j * interval '1 day') returning request_id into request_value;
      if j <= 3 then
        insert into private.rider_payout_allocations (request_id, delivery_id, amount)
        values (request_value, d.delivery_id, 70 + j * 2);
        update public.delivery_payments set payout_status =
          case when j = 1 then 'paid' else 'processing' end,
          paid_at = case when j = 1 then now() - interval '1 day' end
        where delivery_id = d.delivery_id;
      end if;
    end loop;
  end loop;
end;
$payouts$;

insert into public.rider_incidents (report_id, rider_id, delivery_id, report_type,
  category, stage, description, status, reported_at, reporter_role,
  reporter_auth_id, reporter_name, reporter_email, resolution_notes)
select 'sample-rider-report-' || c.n || '-' || s.n, c.rider_id, d.delivery_id,
  case when s.n % 2 = 0 then 'delivery_problem' else 'safety_report' end,
  'other', 'delivery', '[Sample] Performance testing report ' || s.n ||
    '. This is a test record and does not describe a real incident.',
  (array['submitted','underReview','waitingForInformation','resolved','rejected','escalated'])[s.n],
  now() - s.n * interval '1 day', 'rider', c.auth_id, 'Sample Rider ' || c.n,
  'mock.rider' || lpad(c.n::text, 2, '0') || '@example.com',
  case when s.n = 4 then '[Sample] Test issue resolved.' end
from mock_rider_context c cross join generate_series(1, 6) s(n)
join mock_rider_deliveries d on d.n = c.n and d.slot = 21
on conflict (report_id) do nothing;

insert into public.notifications (recipient_auth_user_id, title, description,
  notification_type, category, destination, metadata, created_at, read_at)
select c.auth_id, '[Sample] ' || (array['Delivery request','New message',
  'Earnings update','Safety report update','Account update'])[1 + s.n % 5] || ' #' || s.n,
  'Sample rider alert ' || s.n || ' for testing the app. No real delivery or payment action is required.',
  (array['delivery_request','new_message','payment_update','verification_update',
    'verification_update'])[1 + s.n % 5],
  (array['orders','messages','system','system','system'])[1 + s.n % 5],
  case when s.n % 5 = 1 then 'messages' else 'none' end,
  jsonb_build_object('test_seed','rider_mock_v1','sample_alert',s.n,
    'delivery_id',d.delivery_id::text,
    'conversation_id','delivery:' || d.delivery_id || ':buyer',
    'report_id','sample-rider-report-' || c.n || '-1'),
  now() - s.n * interval '10 minutes',
  case when s.n % 3 = 0 then now() - s.n * interval '5 minutes' end
from mock_rider_context c cross join generate_series(1, 500) s(n)
join mock_rider_deliveries d on d.n = c.n and d.slot = 21
where not exists (select 1 from public.notifications existing
  where existing.recipient_auth_user_id = c.auth_id
    and existing.metadata ->> 'test_seed' = 'rider_mock_v1'
    and existing.metadata ->> 'sample_alert' = s.n::text);

alter table public.notifications enable trigger notifications_dispatch_push_after_insert;
do $$
begin
  if (select count(*) from mock_rider_context) <> 30
    or (select count(*) from mock_rider_deliveries) <> 900 then
    raise exception 'Incomplete rider fixtures; rolling back';
  end if;
end $$;
select (select count(*) from mock_rider_context) as riders,
  (select count(*) from mock_rider_deliveries) as deliveries,
  (select count(*) from mock_rider_deliveries where status = 'completed') as completed,
  (select count(*) from public.rider_delivery_messages m
    join mock_rider_deliveries d using (delivery_id)) as messages,
  (select count(*) from public.notifications where metadata ->> 'test_seed' = 'rider_mock_v1') as alerts;
commit;
