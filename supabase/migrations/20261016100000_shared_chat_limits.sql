begin;

-- Reuse the existing private atomic counter infrastructure. No client identities.
create function private.consume_chat_quota(scope text, suffix text, quota integer, seconds integer)
returns void language plpgsql security definer set search_path = '' as $$
declare result record; expected_hash text; supplied text;
begin
  if auth.uid() is null or coalesce(auth.jwt()->>'is_anonymous','false') <> 'false'
    or coalesce((auth.jwt()->>'exp')::numeric,0) <= extract(epoch from now()) then
    raise sqlstate 'PT401' using message = 'Sign in to use chat.';
  end if;
  select secret_hash into expected_hash from private.api_gateway_configuration where singleton;
  supplied := coalesce(nullif(current_setting('request.headers',true),''),'{}')::jsonb
    ->>'x-agrisell-api-gateway';
  if expected_hash is null then
    raise sqlstate 'PT503' using message = 'Chat protection is temporarily unavailable.';
  end if;
  if supplied is null or length(supplied)>256 or
    encode(extensions.digest(supplied,'sha256'),'hex') <> expected_hash then
    raise sqlstate 'PT403' using message = 'Update the app to use protected chat.';
  end if;
  select * into result from public.admin_consume_rate_limit(
    scope, encode(extensions.digest(auth.uid()::text || ':' || suffix,'sha256'),'hex'),
    quota, seconds);
  if result.allowed is distinct from true then
    perform set_config('response.headers',jsonb_build_array(jsonb_build_object(
      'Retry-After',greatest(1,coalesce(result.retry_after_seconds,60))::text))::text,true);
    raise sqlstate 'PT429' using message = 'Chat limit reached. Please wait before trying again.';
  end if;
end;
$$;
revoke all on function private.consume_chat_quota(text,text,integer,integer)
  from public,anon,authenticated;

create function private.enforce_shared_chat_limits() returns trigger
language plpgsql security definer set search_path = '' as $$
declare conversation_key text;
begin
  if auth.role() = 'service_role' then return new; end if;
  if auth.uid() is null or coalesce(auth.jwt()->>'is_anonymous','false') <> 'false'
    or coalesce((auth.jwt()->>'exp')::numeric,0) <= extract(epoch from now()) then
    raise sqlstate 'PT401' using message = 'Sign in to use chat.';
  end if;
  if tg_table_name = 'marketplace_conversations' then
    if new.buyer_user_id is distinct from private.current_buyer_user_id() then
      raise insufficient_privilege using message = 'Conversation access denied.';
    end if;
    -- Reopening the same thread is not creation and must remain possible.
    if exists(select 1 from public.marketplace_conversations c
      where c.buyer_user_id=new.buyer_user_id and c.farm_id=new.farm_id
        and c.commodity_id is not distinct from new.commodity_id
        and c.order_id is not distinct from new.order_id) then return new; end if;
    perform private.consume_chat_quota('chat-new-day','all',5,86400);
    return new;
  end if;
  if char_length(coalesce(new.body,'')) > 500 or btrim(coalesce(new.body,'')) = '' then
    raise sqlstate '22001' using message = 'Messages must contain 1–500 characters.';
  end if;
  if tg_table_name = 'marketplace_messages' then
    if private.can_access_marketplace_conversation(new.conversation_id) is distinct from true then
      raise insufficient_privilege using message = 'Conversation access denied.';
    end if;
    conversation_key := 'marketplace:' || new.conversation_id::text;
  else
    if new.sender_auth_id is distinct from auth.uid() or
      private.can_access_rider_delivery_conversation(new.delivery_id,new.party) is distinct from true then
      raise insufficient_privilege using message = 'Conversation access denied.';
    end if;
    if new.idempotency_key is not null and exists(select 1 from public.rider_delivery_messages m
      where m.sender_auth_id=auth.uid() and m.idempotency_key=new.idempotency_key) then
      return new;
    end if;
    conversation_key := 'delivery:' || new.delivery_id::text || ':' || new.party;
  end if;
  perform private.consume_chat_quota('chat-message-day','all',100,86400);
  perform private.consume_chat_quota('chat-message-minute',conversation_key,10,60);
  return new;
end;
$$;
revoke all on function private.enforce_shared_chat_limits() from public,anon,authenticated;

create trigger shared_chat_limits before insert on public.marketplace_messages
  for each row execute function private.enforce_shared_chat_limits();
create trigger shared_chat_limits before insert on public.rider_delivery_messages
  for each row execute function private.enforce_shared_chat_limits();
create trigger shared_chat_limits before insert on public.marketplace_conversations
  for each row execute function private.enforce_shared_chat_limits();
notify pgrst,'reload schema';
commit;
