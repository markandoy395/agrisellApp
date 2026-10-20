begin;
create or replace function private.can_publish_farmer_product(target_farm_id bigint)
returns boolean language sql stable security definer set search_path = '' as $$
  select auth.uid() is not null
    and coalesce(auth.jwt()->>'is_anonymous','false') = 'false'
    and coalesce((auth.jwt()->>'exp')::numeric,0) > extract(epoch from now())
    and exists (select 1 from public.farmers f join public.farms farm using (farmer_user_id)
      where farm.farm_id = target_farm_id and f.auth_user_id = auth.uid()
        and lower(f.account_status) = 'active' and lower(f.verification_status) = 'verified')
$$;
revoke all on function private.can_publish_farmer_product(bigint) from public, anon;
grant execute on function private.can_publish_farmer_product(bigint) to authenticated;
create policy verified_farmer_product_insert on public.commodities
  as restrictive for insert to authenticated
  with check (private.is_admin() or private.can_publish_farmer_product(farm_id));
create policy verified_farmer_category_insert on public.categories
  as restrictive for insert to authenticated
  with check (private.is_admin() or private.can_publish_farmer_product(farm_id));

-- Personal/signup images remain available before approval; product uploads do not.
create or replace function private.can_upload_farmer_product()
returns boolean language sql stable security definer set search_path = '' as $$
  select auth.uid() is not null
    and coalesce(auth.jwt()->>'is_anonymous','false') = 'false'
    and coalesce((auth.jwt()->>'exp')::numeric,0) > extract(epoch from now())
    and exists (select 1 from public.farmers where auth_user_id = auth.uid()
      and lower(account_status) = 'active' and lower(verification_status) = 'verified')
$$;
revoke all on function private.can_upload_farmer_product() from public, anon;
grant execute on function private.can_upload_farmer_product() to authenticated;
create policy verified_farmer_product_upload on storage.objects
  as restrictive for insert to authenticated with check (
    bucket_id <> 'farmer-media' or (storage.foldername(name))[2] is distinct from 'commodities'
    or private.can_upload_farmer_product());
create policy verified_farmer_product_replace on storage.objects
  as restrictive for update to authenticated using (
    bucket_id <> 'farmer-media' or (storage.foldername(name))[2] is distinct from 'commodities'
    or private.can_upload_farmer_product()) with check (
    bucket_id <> 'farmer-media' or (storage.foldername(name))[2] is distinct from 'commodities'
    or private.can_upload_farmer_product());

-- Inventory RPCs are security-definer; enforce approval inside their implementation.
do $patch$
declare
  definition text := pg_get_functiondef('private.add_current_farmer_inventory_lot(bigint,numeric,text,date,date,date,text,text,text)'::regprocedure);
  marker constant text := '  if not private.owns_farm(commodity_record.farm_id)';
begin
  if position(marker in definition) = 0 then raise exception 'Inventory ownership guard changed'; end if;
  execute replace(definition, marker,
    '  if not private.is_admin() and not private.can_publish_farmer_product(commodity_record.farm_id) then
    raise exception ''Farmer approval is required before adding stock'' using errcode = ''42501'';
  end if;
' || marker);
end;
$patch$;
alter table private.application_operation_receipts
  drop constraint application_operation_receipts_operation_check;
alter table private.application_operation_receipts
  add constraint application_operation_receipts_operation_check
  check (operation in ('marketplace_message','farmer_payout','farmer_product_publish'));

create function public.publish_current_farmer_product(
  p_request_key uuid, p_product jsonb, p_lot jsonb
) returns jsonb language plpgsql security definer set search_path = '' as $$
declare
  farmer_id bigint;
  farm_id_value bigint := (p_product->>'farm_id')::bigint;
  category_id_value bigint;
  saved public.commodities%rowtype;
  receipt jsonb;
  payload jsonb := jsonb_build_array(p_product,p_lot);
  quantity_value numeric := (p_product->>'available_quantity')::numeric;
  price_value numeric := (p_product->>'price_per_unit')::numeric;
  minimum_value numeric := (p_product->>'minimum_order_quantity')::numeric;
begin
  perform private.require_operation_session();
  select farmer_user_id into farmer_id from public.farmers
  where auth_user_id = auth.uid() and lower(account_status) = 'active'
    and lower(verification_status) = 'verified' for share;
  if farmer_id is null then
    raise exception 'A verified active farmer account is required' using errcode = '42501';
  end if;
  perform 1 from public.farms where farm_id = farm_id_value
    and farmer_user_id = farmer_id for update;
  if not found then raise exception 'Farm access denied' using errcode = '42501'; end if;
  receipt := private.lock_operation_receipt('farmer_product_publish',p_request_key,payload);
  if receipt is not null then return receipt; end if;
  if nullif(btrim(p_product->>'commodity_name'),'') is null
    or nullif(btrim(p_product->>'category_name'),'') is null
    or nullif(btrim(p_product->>'description'),'') is null
    or length(p_product->>'description') > 300
    or quantity_value is null or quantity_value <= 0 or quantity_value > 1000000
    or scale(quantity_value) > 3 or quantity_value::text in ('NaN','Infinity','-Infinity')
    or price_value is null or price_value <= 0 or price_value::text in ('NaN','Infinity','-Infinity')
    or minimum_value is null or minimum_value <= 0 or minimum_value > quantity_value
    or minimum_value::text in ('NaN','Infinity','-Infinity') then
    raise exception 'Complete valid product and quantity details' using errcode = '22023';
  end if;
  if p_product->>'image_url' is null or p_product->>'image_url' !~ (
      '/farmer-media/' || auth.uid()::text || '/commodities/' || p_request_key || '-[0-9a-f]{64}[.]jpg$') then
    raise exception 'An owned product image is required' using errcode = '22023';
  end if;
  select category_id into category_id_value from public.categories
  where farm_id = farm_id_value and category_name = btrim(p_product->>'category_name')
  order by category_id limit 1;
  if category_id_value is null then
    insert into public.categories(farm_id,category_name)
    values(farm_id_value,btrim(p_product->>'category_name')) returning category_id into category_id_value;
  end if;
  insert into public.commodities(category_id,farm_id,commodity_name,description,
    price_per_unit,unit_type,available_quantity,harvest_date,production_status,
    availability_status,is_organic,image_url,commodity_status,minimum_order_quantity,
    grade_quality,inventory_date_type)
  values(category_id_value,farm_id_value,btrim(p_product->>'commodity_name'),p_product->>'description',
    price_value,p_product->>'unit_type',0,(p_product->>'harvest_date')::date,
    p_product->>'production_status',p_product->>'availability_status',
    coalesce((p_product->>'is_organic')::boolean,false),p_product->>'image_url',
    'available',minimum_value,p_product->>'grade_quality',p_lot->>'date_type')
  returning * into saved;
  perform private.add_current_farmer_inventory_lot(saved.commodity_id,quantity_value,
    p_lot->>'date_type',(p_lot->>'harvested_at')::date,(p_lot->>'sell_until')::date,
    (p_lot->>'expires_at')::date,p_lot->>'lot_code',p_lot->>'storage_instructions','Initial product stock');
  select * into saved from public.commodities where commodity_id = saved.commodity_id;
  receipt := to_jsonb(saved);
  insert into private.application_operation_receipts(owner_id,operation,request_key,payload_hash,result)
  values(auth.uid(),'farmer_product_publish',p_request_key,extensions.digest(payload::text,'sha256'),receipt);
  return receipt;
end;
$$;
revoke all on function public.publish_current_farmer_product(uuid,jsonb,jsonb) from public,anon;
grant execute on function public.publish_current_farmer_product(uuid,jsonb,jsonb) to authenticated;
notify pgrst,'reload schema';
commit;
