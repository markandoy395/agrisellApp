begin;

-- The public wrappers must be able to enter the locked private workflow.
-- Authentication and farmer ownership are still revalidated inside the
-- private function using auth.uid(), while the private functions remain
-- unavailable for direct client execution.
create or replace function public.cancel_current_farmer_order(
  p_seller_order_id text,
  p_cancellation_reason text
) returns jsonb language sql security definer set search_path = '' as $$
  select private.cancel_current_farmer_order(
    p_seller_order_id, p_cancellation_reason
  )
$$;

create or replace function public.current_account_cancellation_snapshots()
returns jsonb language sql stable security definer set search_path = '' as $$
  select private.current_account_cancellation_snapshots()
$$;

revoke all on function private.cancel_current_farmer_order(text, text),
  private.current_account_cancellation_snapshots()
  from public, anon, authenticated;
revoke all on function public.cancel_current_farmer_order(text, text),
  public.current_account_cancellation_snapshots()
  from public, anon;
grant execute on function public.cancel_current_farmer_order(text, text),
  public.current_account_cancellation_snapshots()
  to authenticated;

notify pgrst, 'reload schema';

commit;
