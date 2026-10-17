begin;

-- Retry receipts are internal. Client-supplied IDs never establish ownership.
create table private.application_operation_receipts (
  owner_id uuid not null references auth.users(id) on delete cascade,
  operation text not null check (operation in ('marketplace_message','farmer_payout')),
  request_key uuid not null,
  payload_hash bytea not null,
  result jsonb not null,
  created_at timestamptz not null default now(),
  primary key (owner_id, operation, request_key)
);
alter table private.application_operation_receipts enable row level security;
revoke all on private.application_operation_receipts from public, anon, authenticated;
create policy application_default_owner_boundary
  on private.application_operation_receipts as restrictive for all to authenticated
  using (false) with check (false);
create policy application_table_requires_login
  on private.application_operation_receipts as restrictive for all to public
  using (auth.uid() is not null and coalesce(auth.jwt()->>'is_anonymous','false')='false')
  with check (auth.uid() is not null and coalesce(auth.jwt()->>'is_anonymous','false')='false');

create function private.require_operation_session()
returns void language plpgsql security definer set search_path = '' as $$
begin
  if auth.uid() is null or coalesce(auth.jwt()->>'is_anonymous','false') <> 'false'
    or coalesce((auth.jwt()->>'exp')::numeric,0) <= extract(epoch from now()) then
    raise sqlstate 'PT401' using message = 'Sign in before continuing.';
  end if;
  perform public.require_rate_limited_gateway();
end;
$$;
revoke all on function private.require_operation_session() from public,anon,authenticated;

create function private.lock_operation_receipt(kind text, request_key uuid, payload jsonb)
returns jsonb language plpgsql security definer set search_path = '' as $$
declare receipt private.application_operation_receipts%rowtype;
begin
  perform private.require_operation_session();
  if request_key is null then raise exception 'A retry key is required' using errcode='22023'; end if;
  perform pg_catalog.pg_advisory_xact_lock(pg_catalog.hashtextextended(
    auth.uid()::text || ':' || kind || ':' || request_key::text,161100));
  select * into receipt from private.application_operation_receipts r
    where r.owner_id=auth.uid() and r.operation=kind and r.request_key=lock_operation_receipt.request_key;
  if found then
    if receipt.payload_hash <> extensions.digest(payload::text,'sha256') then
      raise exception 'The retry key belongs to a different request' using errcode='22023';
    end if;
    return receipt.result;
  end if;
  return null;
end;
$$;
revoke all on function private.lock_operation_receipt(text,uuid,jsonb) from public,anon,authenticated;

create function public.send_marketplace_message_once(
  conversation_id bigint, body text, p_request_key uuid
) returns jsonb language plpgsql security definer set search_path = '' as $$
declare payload jsonb := jsonb_build_array(conversation_id,body); saved jsonb;
begin
  perform private.require_operation_session();
  if private.can_access_marketplace_conversation(conversation_id) is distinct from true then
    raise insufficient_privilege using message='Conversation access denied.';
  end if;
  saved := private.lock_operation_receipt('marketplace_message',p_request_key,payload);
  if saved is not null then return saved; end if;
  saved := public.send_marketplace_message(conversation_id,body);
  insert into private.application_operation_receipts(owner_id,operation,request_key,payload_hash,result)
    values(auth.uid(),'marketplace_message',p_request_key,extensions.digest(payload::text,'sha256'),saved);
  return saved;
end;
$$;
revoke all on function public.send_marketplace_message_once(bigint,text,uuid) from public,anon;
grant execute on function public.send_marketplace_message_once(bigint,text,uuid) to authenticated;

create function public.submit_farmer_payout_once(
  p_amount numeric, p_payout_method text, p_account_name text, p_account_number text,
  p_request_key uuid, p_bank_name text default null, p_notes text default null
) returns jsonb language plpgsql security definer set search_path = '' as $$
declare payload jsonb := jsonb_build_array(p_amount,p_payout_method,p_account_name,p_account_number,p_bank_name,p_notes);
  saved jsonb;
begin
  perform private.require_operation_session();
  if private.current_farmer_user_id() is null then
    raise insufficient_privilege using message='A farmer account is required.';
  end if;
  saved := private.lock_operation_receipt('farmer_payout',p_request_key,payload);
  if saved is not null then return saved; end if;
  saved := public.submit_payout_request(p_amount,p_payout_method,p_account_name,p_account_number,p_bank_name,p_notes,'farmer');
  insert into private.application_operation_receipts(owner_id,operation,request_key,payload_hash,result)
    values(auth.uid(),'farmer_payout',p_request_key,extensions.digest(payload::text,'sha256'),saved);
  return saved;
end;
$$;
revoke all on function public.submit_farmer_payout_once(numeric,text,text,text,uuid,text,text) from public,anon;
grant execute on function public.submit_farmer_payout_once(numeric,text,text,text,uuid,text,text) to authenticated;

-- One caller-scoped snapshot in one database statement rather than seven HTTP requests.
create function public.current_account_order_bundle()
returns jsonb language plpgsql stable security definer set search_path = '' as $$
begin
  perform private.require_operation_session();
  return jsonb_build_object(
    'orders',public.current_account_orders(),
    'payments',public.current_account_payment_snapshots(),
    'reviews',public.current_account_review_snapshots(),
    'expirations',public.current_account_expiration_snapshots(),
    'cancellations',public.current_account_cancellation_snapshots(),
    'refunds',public.current_account_refund_snapshots(),
    'disputes',public.current_account_dispute_snapshots());
end;
$$;
revoke all on function public.current_account_order_bundle() from public,anon;
grant execute on function public.current_account_order_bundle() to authenticated;
notify pgrst,'reload schema';
commit;
