-- Read-only metadata assertions after deploying the status RPC correction.
begin;
do $$
begin
  if not has_function_privilege('authenticated',
    'public.update_current_rider_delivery_status(bigint,text,text,text,text,double precision,double precision)','EXECUTE') then
    raise exception 'Assigned-rider status RPC not executable';
  end if;
  if has_function_privilege('anon',
    'public.update_current_rider_delivery_status(bigint,text,text,text,text,double precision,double precision)','EXECUTE') then
    raise exception 'Anonymous status RPC access';
  end if;
  if has_function_privilege('authenticated',
    'public.update_delivery_status(bigint,text,text,text,text,double precision,double precision)','EXECUTE') then
    raise exception 'Legacy generic status RPC exposure';
  end if;
end;
$$;
rollback;
