begin;

create or replace function public.update_current_rider_delivery_status(
  p_delivery_id bigint,
  p_previous_status text,
  p_new_status text,
  p_idempotency_key text,
  p_remarks text default null,
  p_latitude double precision default null,
  p_longitude double precision default null
) returns jsonb language plpgsql security definer set search_path = '' as $$
declare current_rider uuid;
begin
  if auth.uid() is null
    or coalesce(auth.jwt()->>'is_anonymous', 'false') <> 'false'
    or coalesce((auth.jwt()->>'exp')::numeric, 0) <= extract(epoch from now()) then
    raise exception 'Authentication required' using errcode = '42501';
  end if;
  perform public.require_rate_limited_gateway();
  current_rider := private.current_rider_id();
  if current_rider is null or not exists (
    select 1 from private.rider_delivery_assignments
    where delivery_id = p_delivery_id and rider_id = current_rider
  ) then
    raise exception 'Only the assigned rider can update this delivery'
      using errcode = '42501';
  end if;
  if p_new_status in ('picked_up', 'completed') then
    raise exception 'Use the dedicated pickup or delivery confirmation flow'
      using errcode = '22023';
  end if;
  return private.update_delivery_status(
    p_delivery_id, p_previous_status, p_new_status, p_idempotency_key,
    p_remarks, p_latitude, p_longitude
  );
end;
$$;
revoke all on function public.update_current_rider_delivery_status(
  bigint,text,text,text,text,double precision,double precision
) from public,anon;
grant execute on function public.update_current_rider_delivery_status(
  bigint,text,text,text,text,double precision,double precision
) to authenticated;
notify pgrst, 'reload schema';
commit;
