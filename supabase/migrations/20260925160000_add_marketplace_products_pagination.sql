-- Migration: Add marketplace products pagination index and cursor RPC
-- Optimizes infinite scrolling with O(log N) composite seek

begin;

-- Composite index to support deterministic cursor seek on available marketplace commodities
create index if not exists idx_commodities_marketplace_cursor
  on public.commodities (created_at desc, commodity_id desc)
  where lower(coalesce(commodity_status, '')) = 'available';

-- Function: marketplace_products_paginated
-- Supports chunked cursor-based pagination with limit and optional farm filter
create or replace function public.marketplace_products_paginated(
  p_limit int default 24,
  p_last_created_at timestamptz default null,
  p_last_commodity_id bigint default null,
  p_farm_id bigint default null
)
returns table (
  commodity_id bigint,
  commodity_name text,
  description text,
  price_per_unit numeric,
  effective_price numeric,
  unit_type text,
  image_url text,
  harvest_date date,
  available_quantity numeric,
  farm_id bigint,
  commodity_status text,
  availability_status text,
  production_status text,
  rating numeric,
  category_name text,
  created_at timestamptz
)
language sql
stable
security definer
set search_path = ''
as $$
  select
    commodity.commodity_id,
    commodity.commodity_name,
    commodity.description,
    commodity.price_per_unit,
    private.effective_commodity_price(commodity.commodity_id, private.current_buyer_user_id()),
    commodity.unit_type,
    commodity.image_url,
    commodity.harvest_date,
    lot_summary.marketable_quantity,
    commodity.farm_id,
    commodity.commodity_status,
    commodity.availability_status,
    commodity.production_status,
    commodity.rating,
    category.category_name,
    commodity.created_at
  from public.commodities as commodity
  left join public.categories as category
    on category.category_id = commodity.category_id
      and category.farm_id = commodity.farm_id
  cross join lateral (
    select coalesce(sum(lot.quantity_remaining) filter (
      where private.inventory_lot_is_marketable(lot, current_date)
    ), 0) as marketable_quantity
    from public.commodity_inventory_lots as lot
    where lot.commodity_id = commodity.commodity_id
  ) as lot_summary
  where lower(coalesce(commodity.commodity_status, '')) = 'available'
    and lot_summary.marketable_quantity > 0
    and commodity.availability_status <> 'not_accepting_orders'
    and (p_farm_id is null or commodity.farm_id = p_farm_id)
    and (
      p_last_created_at is null
      or (commodity.created_at, commodity.commodity_id) < (p_last_created_at, p_last_commodity_id)
    )
  order by commodity.created_at desc, commodity.commodity_id desc
  limit greatest(1, least(coalesce(p_limit, 24), 100));
$$;

grant execute on function public.marketplace_products_paginated(int, timestamptz, bigint, bigint)
  to anon, authenticated, service_role;

commit;
