// Isolated PostgreSQL fixtures; never connects to a hosted database.
const assert = require('node:assert/strict');
const fs = require('node:fs');
const { PGlite } = require('../../.dart-local/chat-sql/node_modules/@electric-sql/pglite');
const a = '10000000-0000-0000-0000-000000000001';
const b = '10000000-0000-0000-0000-000000000002';
async function main() {
  const db = new PGlite();
  await db.exec(`
    create role anon; create role authenticated;
    create schema auth; create schema private;
    grant usage on schema auth, private to authenticated, anon;
    create function auth.jwt() returns jsonb language sql stable as $$
      select current_setting('request.jwt.claims')::jsonb $$;
    create function auth.uid() returns uuid language sql stable as $$
      select (auth.jwt()->>'sub')::uuid $$;
    create function private.current_rider_id() returns uuid language sql stable as $$
      select case when auth.uid() in ('${a}'::uuid,'${b}'::uuid) then auth.uid() end $$;
    create table public.deliveries(delivery_id bigint, created_at timestamptz default now(),
      delivery_status text, pickup_location text, dropoff_location text, cold_chain_available boolean);
    create table private.rider_delivery_assignments(delivery_id bigint,rider_id uuid);
    create table private.order_delivery_fulfillments(delivery_id bigint,total_weight_kg numeric,
      ready_at timestamptz,pickup_lat numeric,pickup_long numeric,pickup_contact text,
      dropoff_lat numeric,dropoff_long numeric,dropoff_contact text,required_vehicle_type text,
      handling_notes text,seller_order_id text,buyer_user_id bigint,representative_order_id bigint);
    create table public.rider_assignment_requests(request_id bigint,delivery_id bigint,rider_id uuid,
      status text,expires_at timestamptz,requested_at timestamptz default now(),
      requested_schedule timestamptz,proposed_delivery_fee numeric);
    create table public.orders(order_id bigint,cart_item_id bigint,client_order_id text,
      payment_method text,payment_status text,total_amount numeric,seller_farm_id bigint);
    create table public.cart_items(cart_item_id bigint,commodity_id bigint,cart_id bigint,quantity numeric);
    create table public.commodities(commodity_id bigint,farm_id bigint,commodity_name text,unit_type text,image_url text);
    create table public.farms(farm_id bigint,farmer_user_id bigint,farm_name text,city_municipality text);
    create table public.farmers(farmer_user_id bigint,first_name text,last_name text);
    create table public.carts(cart_id bigint,buyer_user_id bigint);
    create table public.buyers(buyer_user_id bigint,user_id bigint);
    create table public.users(user_id bigint,first_name text,last_name text);
    create table private.delivery_status_events(delivery_id bigint,idempotency_key text,changed_at timestamptz);
    insert into public.farms values(1,1,'Farm','City'),(2,2,'Other Farm','City');
    insert into public.farmers values(1,'Farmer','One'),(2,'Farmer','Two');
    insert into public.buyers values(1,1),(2,2);
    insert into public.users values(1,'Buyer','One'),(2,'Buyer','Two');
    insert into public.carts values(1,1),(2,2);
    insert into public.commodities values(1,1,'Tomatoes','kg','https://example.test/literal_%_''--.jpg'),
      (2,1,'Rice','kg',null),(3,1,'Other buyer','kg','https://example.test/private.jpg'),
      (0,2,'Other seller','kg','https://example.test/other-seller.jpg');
    insert into public.cart_items values(1,1,1,5),(2,2,1,2),(3,3,2,1),(4,0,1,1);
    insert into public.orders values(1,1,'order-a','cash','pending',10,1),
      (2,2,'order-empty','cash','pending',10,1),(3,3,'order-a','cash','pending',10,1),
      (4,4,'order-a','cash','pending',10,2);
    insert into public.deliveries(delivery_id,delivery_status) values
      (1,'accepted'),(2,'available'),(3,'accepted'),(4,'available'),(5,'available');
    insert into private.rider_delivery_assignments values(1,'${a}'),(3,'${b}');
    insert into private.order_delivery_fulfillments(delivery_id,seller_order_id,buyer_user_id,representative_order_id)
      values(1,'order-a',1,1),(2,'order-empty',1,2),(3,'order-a',2,3),
        (4,'order-a',1,1),(5,'order-a',1,1);
    insert into public.rider_assignment_requests(request_id,delivery_id,rider_id,status,expires_at)
      values(2,2,'${a}','pending',now()+interval '1 hour'),
        (4,4,'${a}','pending',now()-interval '1 hour');
  `);
  await db.exec(fs.readFileSync('supabase/migrations/20261015120000_include_rider_product_images.sql','utf8'));
  await db.exec('grant execute on function private.current_rider_deliveries(boolean) to authenticated');
  const claims = (sub=a, overrides={}) => db.query(
    "select set_config('request.jwt.claims',$1,false)",
    [JSON.stringify({sub,is_anonymous:false,exp:4102444800,...overrides})]);
  const load = async available => (await db.query(
    'select private.current_rider_deliveries($1) result',[available])).rows[0].result;
  await claims();
  await db.exec('set role authenticated');
  await assert.rejects(load(true), {code:'42703'});
  await db.exec('reset role');
  await db.exec(fs.readFileSync('supabase/migrations/20261015130000_fix_rider_product_image_farm_join.sql','utf8'));
  await db.exec('set role authenticated');
  const rows = await load(true);
  assert.deepEqual(rows.map(x=>x.delivery_id).sort(),[1,2]);
  assert.equal(rows.find(x=>x.delivery_id===1).product_image_url,"https://example.test/literal_%_'--.jpg");
  assert.equal(rows.find(x=>x.delivery_id===2).product_image_url,null);
  assert.deepEqual((await load(false)).map(x=>x.delivery_id),[1]);
  await claims(b);
  assert.deepEqual((await load(true)).map(x=>x.delivery_id),[3]);
  assert.equal((await load(true))[0].product_image_url,'https://example.test/private.jpg');
  for(const overrides of [{sub:null},{is_anonymous:true},{exp:1},{sub:'10000000-0000-0000-0000-000000000003'}]) {
    await claims(a,overrides);
    await assert.rejects(load(true),{code:'42501'});
  }
  await db.exec('reset role; set role anon');
  await claims(null);
  await assert.rejects(load(true),{code:'42501'});
  await db.close();
  console.log('Passed: original 42703 reproduction, assigned/selected images, buyer/seller isolation, literal URLs, missing images, expired requests and invalid sessions.');
}
main().catch(error=>{console.error(error);process.exitCode=1;});
