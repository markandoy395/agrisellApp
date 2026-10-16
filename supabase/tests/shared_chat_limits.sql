-- Read-only rollout assertions. No production account fixtures or mutations.
begin;
do $$
declare relation_name text; helper_name text;
begin
  foreach relation_name in array array[
    'marketplace_messages','rider_delivery_messages','marketplace_conversations'
  ] loop
    if not exists(select 1 from pg_catalog.pg_trigger t
      join pg_catalog.pg_class c on c.oid=t.tgrelid
      join pg_catalog.pg_namespace n on n.oid=c.relnamespace
      where n.nspname='public' and c.relname=relation_name
        and c.relrowsecurity and t.tgname='shared_chat_limits'
        and t.tgenabled='O' and not t.tgisinternal
        and t.tgfoid='private.enforce_shared_chat_limits()'::regprocedure) then
      raise exception 'Missing chat guard or RLS: %',relation_name;
    end if;
  end loop;
  foreach helper_name in array array[
    'private.consume_chat_quota(text,text,integer,integer)',
    'private.enforce_shared_chat_limits()'
  ] loop
    if has_function_privilege('anon',helper_name,'EXECUTE') or
      has_function_privilege('authenticated',helper_name,'EXECUTE') then
      raise exception 'Exposed internal chat helper: %',helper_name;
    end if;
    if not exists(select 1 from pg_catalog.pg_proc
      where oid=helper_name::regprocedure and prosecdef
        and array_to_string(proconfig,',') like '%search_path=""%') then
      raise exception 'Unsafe chat function configuration: %',helper_name;
    end if;
  end loop;
  if not exists(select 1 from private.api_gateway_configuration
    where singleton and secret_hash is not null) then
    raise exception 'Chat gateway is not configured';
  end if;
end;
$$;
rollback;
