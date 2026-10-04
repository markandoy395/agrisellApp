begin;

-- The prior repair guarantees public.delivery_payments. Keep runtime SQL static.
CREATE OR REPLACE FUNCTION private.api_impl_current_rider_dashboard()
 RETURNS jsonb
 LANGUAGE plpgsql
 SECURITY DEFINER
 SET search_path TO ''
AS $function$
declare
  current_rider uuid := private.current_rider_id();
  current_auth uuid := auth.uid();
  dashboard jsonb;
  earned_today numeric := 0;
  pending_earnings numeric;
begin
  with stats as (
    select count(*) as total,
      count(*) filter (
        where delivery.delivery_status in ('completed', 'delivered')
      ) as completed,
      count(*) filter (
        where delivery.delivery_status in ('cancelled', 'failed')
      ) as cancelled,
      count(*) filter (
        where delivery.delivery_status in ('completed', 'delivered')
          and delivery.actual_delivery_time::date = current_date
      ) as completed_today,
      count(*) filter (
        where delivery.delivery_status in ('completed', 'delivered')
          and delivery.actual_delivery_time <= delivery.estimated_delivery_time
      ) as on_time
    from private.rider_delivery_assignments as assignment
    join public.deliveries as delivery on delivery.delivery_id = assignment.delivery_id
    where assignment.rider_id = current_rider
  )
  select jsonb_build_object(
    'today_completed_deliveries', stats.completed_today,
    'today_estimated_earnings', 0,
    'unread_message_count', (
      select count(*) from public.rider_delivery_messages as message
      where private.rider_owns_delivery(message.delivery_id)
        and message.sender_role <> 'rider'
        and message.sent_at > coalesce((
          select reads.last_read_at from public.rider_conversation_reads as reads
          where reads.rider_id = current_rider
            and reads.delivery_id = message.delivery_id
            and reads.party = message.party
        ), '-infinity')
    ),
    'unread_notification_count', (
      select count(*) from public.notifications as notification
      where notification.recipient_auth_user_id = current_auth
        and notification.read_at is null and notification.deleted_at is null
    ),
    'cancelled_or_failed_deliveries', stats.cancelled,
    'pending_earnings', null,
    'average_rating', coalesce((
      select avg(rating.rating) from public.rider_ratings as rating
      where rating.rider_id = current_rider
    ), 0),
    'completed_delivery_count', stats.completed,
    'on_time_delivery_rate', case when stats.completed = 0 then 0
      else stats.on_time * 100.0 / stats.completed end,
    'cancellation_rate', case when stats.total = 0 then 0
      else stats.cancelled * 100.0 / stats.total end,
    'unavailable_sections', jsonb_build_array('Earnings'),
    'fetched_at', now()
  ) into dashboard from stats;

  select
    coalesce(sum(payment.final_earning) filter (
      where delivery.delivery_status in ('completed', 'delivered')
        and (delivery.actual_delivery_time at time zone 'Asia/Manila')::date =
          (now() at time zone 'Asia/Manila')::date
        and payment.earning_status is distinct from 'cancelled'
    ), 0),
    coalesce(sum(payment.final_earning) filter (
      where payment.payout_status is distinct from 'paid'
        and payment.earning_status is distinct from 'cancelled'
    ), 0)
  into earned_today, pending_earnings
  from private.rider_delivery_assignments as assignment
  join public.deliveries as delivery on delivery.delivery_id = assignment.delivery_id
  left join public.delivery_payments as payment on payment.delivery_id = delivery.delivery_id
  where assignment.rider_id = current_rider;

  return dashboard || jsonb_build_object(
    'today_estimated_earnings', earned_today,
    'pending_earnings', pending_earnings,
    'unavailable_sections', '[]'::jsonb
  );
end;
$function$;

-- RPC arguments are data values. Equality keeps %, _, * and SQL syntax literal.
-- Aggregate to one scalar result; ambiguous duplicate codes are rejected.
create or replace function private.current_checkout_voucher(p_code text)
returns jsonb language sql stable security definer set search_path = '' as $$
  select case when count(*) = 1 then jsonb_agg(jsonb_build_object(
    'sale_id', sale.sale_id, 'name', sale.name, 'promo_code', sale.promo_code,
    'discount_type', sale.discount_type, 'discount_value', sale.discount_value,
    'target_user_group', sale.target_user_group, 'starts_at', sale.starts_at,
    'ends_at', sale.ends_at, 'is_enabled', sale.is_enabled
  )) -> 0 else null::jsonb end
  from public.product_sales sale
  where sale.is_enabled = true
    and lower(sale.promo_code) = lower(btrim(p_code))
    and auth.uid() is not null
    and coalesce(auth.jwt()->>'is_anonymous', 'false') = 'false'
$$;
-- Catalogue access is RPC-only in the deployed database; do not widen raw grants.
create or replace function public.current_checkout_voucher(p_code text)
returns jsonb language sql stable security invoker set search_path = '' as $$
  select private.current_checkout_voucher(p_code)
$$;
revoke all on function public.current_checkout_voucher(text),
  private.current_checkout_voucher(text) from public, anon;
grant execute on function public.current_checkout_voucher(text),
  private.current_checkout_voucher(text) to authenticated, service_role;

notify pgrst, 'reload schema';
commit;
