begin;

-- The older local version 20260930100000 collides with the deployed admin
-- permission migration. Restore this missing schema under a distinct version.
-- Keep the entered amount separate from the normalized hectares used by
-- existing farm screens. Historical rows retain their current hectare value.
alter table public.farms
  add column if not exists farm_size numeric(16,3);

alter table public.farms
  alter column farm_size_hectares type numeric(24,8);

update public.farms
set farm_size = farm_size_hectares
where farm_size is null and farm_size_hectares is not null;

-- Earlier registrations could save free-text unit names. Keep their entered
-- amount and normalize the known spellings without touching unknown values.
update public.farms
set farm_size_unit = case lower(btrim(farm_size_unit))
    when 'hectares' then 'ha'
    when 'square meters' then 'sq m'
    else farm_size_unit
  end,
  farm_size_hectares = case lower(btrim(farm_size_unit))
    when 'sq m' then farm_size / 10000
    when 'square meters' then farm_size / 10000
    else farm_size_hectares
  end
where lower(btrim(farm_size_unit)) in ('hectares', 'square meters', 'sq m');

create or replace function private.sync_farmer_farm_size()
returns trigger
language plpgsql
set search_path = ''
as $$
begin
  if new.farm_size_unit = 'hectares' then
    new.farm_size_unit := 'ha';
  elsif new.farm_size_unit = 'square meters' then
    new.farm_size_unit := 'sq m';
  end if;

  if tg_op = 'INSERT' then
    -- Existing signup functions supply the entered amount in this column.
    new.farm_size := coalesce(new.farm_size, new.farm_size_hectares);
  elsif new.farm_size is not distinct from old.farm_size
    and new.farm_size_unit is not distinct from old.farm_size_unit
    and new.farm_size_hectares is distinct from old.farm_size_hectares then
    -- Existing farm edit screens edit the value in hectares.
    new.farm_size := new.farm_size_hectares;
    new.farm_size_unit := 'ha';
  end if;

  if new.farm_size_unit in ('ha', 'sq m') and new.farm_size is not null then
    if new.farm_size <= 0 then
      raise exception 'Farm size must be greater than zero';
    end if;
    new.farm_size_hectares := case new.farm_size_unit
      when 'sq m' then new.farm_size / 10000
      else new.farm_size
    end;
  end if;

  if tg_op = 'INSERT' or new.farm_size_unit is distinct from old.farm_size_unit then
    if new.farm_size_unit is not null and new.farm_size_unit not in ('ha', 'sq m') then
      raise exception 'Invalid farm size unit';
    end if;
  end if;
  return new;
end;
$$;

drop trigger if exists sync_farmer_farm_size on public.farms;
create trigger sync_farmer_farm_size
before insert or update of farm_size, farm_size_unit, farm_size_hectares
on public.farms
for each row execute function private.sync_farmer_farm_size();

commit;
