-- Run only after distributing and verifying a client built with
-- --dart-define=SUPABASE_RATE_LIMIT_GATEWAY=true.
-- Older direct REST clients will receive 403 after activation.
begin;
do $$
begin
  if not exists (select 1 from private.api_gateway_configuration
    where singleton and secret_hash is not null) then
    raise exception 'Configure and verify API_GATEWAY_SECRET before activation';
  end if;
end;
$$;
update private.api_gateway_configuration set enforced = true where singleton;
commit;

-- Compatibility rollback, if a client rollout needs to be reversed:
-- update private.api_gateway_configuration set enforced = false where singleton;
