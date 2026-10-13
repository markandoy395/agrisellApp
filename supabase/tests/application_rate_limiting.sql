-- Run as migration owner. All counter fixtures and settings are rolled back.
begin;
do $audit$
declare
  result record;
  attempt integer;
  hash text := repeat('a', 64);
begin
  if has_function_privilege('authenticated',
    'public.admin_consume_rate_limit(text,text,integer,integer)', 'EXECUTE') or
    has_function_privilege('anon',
    'public.admin_consume_rate_limit(text,text,integer,integer)', 'EXECUTE') then
    raise exception 'End users can control rate counters';
  end if;
  delete from private.admin_rate_limit_buckets where scope = 'rollback-rate-audit';
  for attempt in 1..4 loop
    select * into result from public.admin_consume_rate_limit('rollback-rate-audit', hash, 3, 60);
    if result.allowed is distinct from (attempt <= 3) then
      raise exception 'Rate limit was not enforced';
    end if;
  end loop;
  if result.retry_after_seconds < 1 or result.remaining <> 0 then
    raise exception 'Invalid retry metadata';
  end if;
  select * into result from public.admin_consume_rate_limit('rollback-rate-audit', repeat('b',64),3,60);
  if not result.allowed then raise exception 'Another account shares the same allowance'; end if;
  update private.admin_rate_limit_buckets set window_started_at = now() - interval '61 seconds'
    where scope = 'rollback-rate-audit' and key_hash = hash;
  select * into result from public.admin_consume_rate_limit('rollback-rate-audit',hash,3,60);
  if not result.allowed or result.remaining <> 2 then raise exception 'Expired window did not reset'; end if;
end;
$audit$;

-- Verify the optional bypass blocker without enabling it for installed clients.
update private.api_gateway_configuration set enforced = true,
  secret_hash = encode(extensions.digest('rollback-only-proof', 'sha256'), 'hex')
  where singleton;
set local role authenticated;
do $boundary$
begin
  perform set_config('request.jwt.claims',
    '{"role":"authenticated","sub":"00000000-0000-0000-0000-000000000001","is_anonymous":false}', true);
  perform set_config('request.jwt.claim.sub', '00000000-0000-0000-0000-000000000001', true);
  perform set_config('request.headers', '{}', true);
  begin
    perform public.require_rate_limited_gateway();
    raise exception 'Direct API bypass was accepted';
  exception when sqlstate 'PT403' then null;
  end;
  perform set_config('request.headers', '{"x-agrisell-api-gateway":"spoofed"}', true);
  begin
    perform public.require_rate_limited_gateway();
    raise exception 'Spoofed gateway marker was accepted';
  exception when sqlstate 'PT403' then null;
  end;
  perform set_config('request.headers', '{"x-agrisell-api-gateway":"rollback-only-proof"}', true);
  perform public.require_rate_limited_gateway();
  perform set_config('request.jwt.claims',
    '{"role":"authenticated","sub":"00000000-0000-0000-0000-000000000001","is_anonymous":true}', true);
  begin
    perform public.require_rate_limited_gateway();
    raise exception 'Anonymous session was accepted';
  exception when sqlstate 'PT401' then null;
  end;
end;
$boundary$;
reset role;
rollback;
