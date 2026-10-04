begin;

-- Format only the farm's participant-visible address, never the private home address.
create or replace function private.marketplace_farm_address(
  p_line text, p_barangay text, p_municipality text, p_province text
) returns text language sql immutable set search_path = '' as $$
  select coalesce(string_agg(part, ', ' order by position), 'Location unavailable')
  from (
    select distinct on (lower(btrim(value))) btrim(value) as part, position
    from unnest(string_to_array(coalesce(p_line, ''), ',') ||
      array[p_barangay, p_municipality, p_province])
      with ordinality as components(value, position)
    where nullif(btrim(value), '') is not null
    order by lower(btrim(value)), position
  ) as address_parts
$$;
revoke all on function private.marketplace_farm_address(text, text, text, text)
  from public, anon, authenticated;

create or replace function private.current_marketplace_conversations()
returns jsonb
language plpgsql stable security definer set search_path = '' as $$
begin
  if auth.uid() is null
    or coalesce(auth.jwt()->>'is_anonymous', 'false') <> 'false'
    or coalesce((auth.jwt()->>'exp')::numeric, 0) <= extract(epoch from now()) then
    raise exception 'Authentication required' using errcode = '42501';
  end if;
  return (
  with actor as (
    select private.current_buyer_user_id() as buyer_id,
      private.current_farmer_user_id() as farmer_id
  )
  select coalesce(jsonb_agg(jsonb_build_object(
    'conversation_id', conversation.conversation_id::text,
    'buyer_name', coalesce(nullif(btrim(concat_ws(' ', buyer_user.first_name,
      buyer_user.last_name)), ''), 'Buyer'),
    'buyer_image_url', buyer_user.profile_photo_url,
    'farmer_name', coalesce(nullif(btrim(concat_ws(' ', farmer.first_name,
      farmer.last_name)), ''), nullif(farm.farm_name, ''), 'Farmer'),
    'farmer_image_url', farmer.profile_image_url,
    'farm_name', coalesce(nullif(farm.farm_name, ''), 'Farm'),
    'farm_location', private.marketplace_farm_address(
      farm.farm_location, farm.barangay, farm.city_municipality, farm.province),
    'commodity_id', commodity.commodity_id::text,
    'product_name', commodity.commodity_name,
    'product_image_url', commodity.image_url,
    'unit_type', commodity.unit_type,
    'order_reference', order_record.client_order_id,
    'order_status', order_record.order_status,
    'quantity', cart_item.quantity,
    'unit_price', coalesce(cart_item.price_at_time, commodity.price_per_unit),
    'last_message', coalesce(last_message.body, ''),
    'last_message_at', coalesce(last_message.sent_at, conversation.updated_at),
    'unread_count', coalesce(unread.unread_count, 0)
  ) order by coalesce(last_message.sent_at, conversation.updated_at) desc), '[]'::jsonb)
  from public.marketplace_conversations as conversation
  cross join actor
  join public.buyers as buyer on buyer.buyer_user_id = conversation.buyer_user_id
  join public.users as buyer_user on buyer_user.user_id = buyer.user_id
  join public.farmers as farmer on farmer.farmer_user_id = conversation.farmer_user_id
  join public.farms as farm on farm.farm_id = conversation.farm_id
  left join public.orders as order_record on order_record.order_id = conversation.order_id
  left join public.cart_items as cart_item
    on cart_item.cart_item_id = order_record.cart_item_id
  left join public.commodities as commodity
    on commodity.commodity_id = coalesce(
      conversation.commodity_id,
      cart_item.commodity_id
    )
  left join lateral (
    select message.body, message.sent_at
    from public.marketplace_messages as message
    where message.conversation_id = conversation.conversation_id
    order by message.sent_at desc, message.message_id desc limit 1
  ) as last_message on true
  left join lateral (
    select count(*)::integer as unread_count
    from public.marketplace_messages as message
    where message.conversation_id = conversation.conversation_id
      and message.sender_role = case when actor.buyer_id is not null
        then 'farmer' else 'buyer' end
      and message.sent_at > coalesce(
        case when actor.buyer_id is not null then conversation.buyer_last_read_at
          else conversation.farmer_last_read_at end,
        '-infinity'::timestamptz
      )
  ) as unread on true
  where conversation.buyer_user_id = actor.buyer_id
    or conversation.farmer_user_id = actor.farmer_id
  );
end;
$$;


-- Preserve participant-only reads and deny anonymous execution.
revoke all on function private.current_marketplace_conversations() from public, anon;
grant execute on function private.current_marketplace_conversations() to authenticated, service_role;
notify pgrst, 'reload schema';
commit;
