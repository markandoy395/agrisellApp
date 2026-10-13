// Isolated PostgreSQL regression; never connects to the hosted database.
const assert = require('node:assert/strict');
const fs = require('node:fs');
const { PGlite } = require('../../.dart-local/chat-sql/node_modules/@electric-sql/pglite');
const migration = 'supabase/migrations/20261013110000_enable_motorcycle_capacity_batching.sql';
const a = '00000000-0000-0000-0000-000000000001';
const b = '00000000-0000-0000-0000-000000000002';
async function main() {
  const db = new PGlite();
  await db.exec(`
    create role anon; create role authenticated;
    create schema auth; create schema private;
    create function auth.jwt() returns jsonb language sql stable as $$
      select coalesce(nullif(current_setting('request.jwt.claims',true),''),'{}')::jsonb
    $$;
    create function auth.uid() returns uuid language sql stable as $$ select (auth.jwt()->>'sub')::uuid $$;
    create function public.require_rate_limited_gateway() returns void language sql as $$ select $$;
    create function private.current_rider_id() returns uuid language sql stable as $$ select auth.uid() $$;
    create function private.can_manage_rider_delivery_limit(bigint) returns boolean language sql as $$ select false $$;
    create table private.rider_delivery_limit_configuration (
      vehicle_type text primary key, recommended_limit integer, configured_limit integer,
      updated_at timestamptz, updated_by uuid
    );
    insert into private.rider_delivery_limit_configuration values
      ('motorcycle',3,1,now(),null),('van',10,2,now(),'${a}');
    create table public.riders (rider_id uuid primary key, vehicle_type text,
      maximum_active_deliveries integer default 1, capacity_kg numeric, logistics_company_id bigint);
    insert into public.riders values ('${a}','motorcycle',1,null,null),('${b}','motorcycle',5,10,null);
    create table public.deliveries(delivery_id bigint primary key,delivery_status text);
    create table private.rider_delivery_assignments(delivery_id bigint,rider_id uuid);
    create table private.order_delivery_fulfillments(delivery_id bigint,total_weight_kg numeric,representative_order_id bigint,seller_order_id text,buyer_user_id bigint);
    create table public.orders(order_id bigint,client_order_id text,seller_farm_id bigint,cart_item_id bigint);
    create table public.cart_items(cart_item_id bigint,cart_id bigint,commodity_id bigint,quantity numeric);
    create table public.carts(cart_id bigint,buyer_user_id bigint);
    create table public.commodities(commodity_id bigint,unit_type text);
    insert into public.carts values(1,1);
    insert into public.commodities values(1,'kg'),(2,'kg'),(3,'sack');
    create function private.validate_delivery_batch_acceptance(p_delivery_id bigint,p_rider_id uuid)
      returns void language plpgsql security definer set search_path='' as $$
      declare active_count integer:=0; rider_record public.riders%rowtype;
      begin select * into rider_record from public.riders where rider_id=p_rider_id;
        if active_count >= greatest(rider_record.maximum_active_deliveries,1) then
          raise exception 'limit'; end if;
      end $$;
    alter table public.riders enable row level security;
    create policy owner_access on public.riders to authenticated
      using(rider_id=auth.uid()) with check(rider_id=auth.uid());
    grant usage on schema public,auth to authenticated;
    grant select,delete on public.riders to authenticated;
    grant update(vehicle_type) on public.riders to authenticated;
  `);
  await db.exec(fs.readFileSync(migration, 'utf8'));
  assert.deepEqual((await db.query('select maximum_active_deliveries,capacity_kg,maximum_capacity_kg from public.riders order by rider_id')).rows,
    [{maximum_active_deliveries:3,capacity_kg:null,maximum_capacity_kg:'30.000'},
     {maximum_active_deliveries:5,capacity_kg:'10',maximum_capacity_kg:'30.000'}]);
  const claims = async (sub=a,extra={}) => db.query("select set_config('request.jwt.claims',$1,false)",
    [JSON.stringify({sub,is_anonymous:false,exp:4102444800,...extra})]);
  await claims();
  await db.exec('set role authenticated');
  await db.query('select public.set_current_rider_capacity($1)',[3]);
  assert.equal((await db.query('select capacity_kg from public.riders')).rows[0].capacity_kg,'3');
  await assert.rejects(db.query('select public.set_current_rider_capacity($1)',[31]),{code:'22023'});
  await assert.rejects(db.query('select public.set_current_rider_capacity($1)',[-1]),{code:'22023'});
  await assert.rejects(db.query('select public.set_current_rider_capacity($1)',['NaN']),{code:'22023'});
  await assert.rejects(db.query('select public.set_current_rider_capacity($1)',['Infinity']),{code:'22023'});
  await assert.rejects(db.query('select public.set_current_rider_capacity($1)',["3; update public.riders set capacity_kg=999 --"]),{code:'22P02'});
  assert.equal((await db.query('update public.riders set vehicle_type=$1 where rider_id=$2 returning rider_id',["motorcycle %_' --",b])).rows.length,0);
  assert.equal((await db.query('delete from public.riders where rider_id=$1 returning rider_id',[b])).rows.length,0);
  await assert.rejects(db.query('update public.riders set maximum_capacity_kg=999'),{code:'42501'});
  await claims(a,{is_anonymous:true});
  await assert.rejects(db.query('select public.set_current_rider_capacity(3)'),{code:'42501'});
  await claims(a,{exp:1});
  await assert.rejects(db.query('select public.set_current_rider_capacity(3)'),{code:'42501'});
  await db.exec('reset role');
  await db.exec('set role anon');
  await assert.rejects(db.query('select public.set_current_rider_capacity(3)'),{code:'42501'});
  await db.exec('reset role');
  await claims();
  for(let id=1;id<=4;id++) {
    await db.query("insert into public.deliveries values($1,'accepted')",[id]);
    await db.query('insert into private.order_delivery_fulfillments values($1,1,$1,$2,1)',[id,`order-${id}`]);
    await db.query('insert into public.orders values($1,$2,1,$1)',[id,`order-${id}`]);
    await db.query('insert into public.cart_items values($1,1,1,1)',[id]);
  }
  for(let id=1;id<=3;id++) {
    await db.query('select private.validate_rider_cargo_capacity($1,$2)',[id,a]);
    await db.query('insert into private.rider_delivery_assignments values($1,$2)',[id,a]);
  }
  await assert.rejects(db.query('select private.validate_rider_cargo_capacity($1,$2)',[4,b]),{code:'42501'});
  await assert.rejects(db.query('select private.validate_rider_cargo_capacity($1,$2)',[4,a]),{code:'22023'});
  // A second item in the same order counts; the stale cached 1 kg is ignored.
  await db.exec("insert into public.orders values(10,'order-4',1,10); insert into public.cart_items values(10,1,2,2)");
  assert.equal((await db.query('select private.delivery_order_cargo_kg(4) as kg')).rows[0].kg,'3');
  await db.exec("insert into public.carts values(2,2); insert into public.cart_items values(11,2,1,999),(12,1,1,999); insert into public.orders values(11,'order-4',1,11),(12,'order-4',2,12)");
  assert.equal((await db.query('select private.delivery_order_cargo_kg(4) as kg')).rows[0].kg,'3');
  await db.exec('update public.cart_items set commodity_id=3 where cart_item_id=10');
  assert.equal((await db.query('select private.delivery_order_cargo_kg(4) as kg')).rows[0].kg,null);
  await assert.rejects(db.query('select private.validate_rider_cargo_capacity($1,$2)',[4,a]),{code:'22023'});
  await db.exec('set role authenticated');
  await assert.rejects(db.query('select public.set_current_rider_capacity(2)'),{code:'22023'});
  await db.exec('reset role');
  assert.equal((await db.query("select configured_limit from private.rider_delivery_limit_configuration where vehicle_type='van'")).rows[0].configured_limit,2);
  await db.close();
  process.stdout.write('Rider capacity SQL: ceilings, required entry, combined weight, ownership, hostile values, anonymous/expired denial passed.\n');
}
main().catch((e) => { process.stderr.write(`Rider capacity regression failed: ${e.code || e.name}\n`); process.exitCode=1; });
