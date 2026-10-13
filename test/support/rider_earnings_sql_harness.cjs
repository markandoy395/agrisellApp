const assert = require('node:assert/strict');
const fs = require('node:fs');
const { PGlite } = require('../../.dart-local/chat-sql/node_modules/@electric-sql/pglite');
const a = '00000000-0000-0000-0000-000000000001';
const b = '00000000-0000-0000-0000-000000000002';
async function main() {
  const db = new PGlite();
  await db.exec(`
    create role anon; create role authenticated;
    create schema auth; create schema private;
    create function auth.jwt() returns jsonb language sql stable as $$
      select coalesce(nullif(current_setting('request.jwt.claims',true),''),'{}')::jsonb $$;
    create function auth.uid() returns uuid language sql stable as $$ select (auth.jwt()->>'sub')::uuid $$;
    create function private.current_rider_id() returns uuid language sql stable as $$ select auth.uid() $$;
    create function public.require_rate_limited_gateway() returns void language plpgsql as $$
      begin if current_setting('test.gateway',true) is distinct from 'on' then
        raise exception 'Gateway required' using errcode='42501'; end if; end $$;
    create table public.deliveries(delivery_id bigint primary key,delivery_status text);
    create table private.rider_delivery_assignments(delivery_id bigint unique,rider_id uuid);
    create table public.rider_assignment_requests(
      request_id bigint primary key,delivery_id bigint,rider_id uuid,status text,
      proposed_delivery_fee numeric,requested_at timestamptz default now());
    create table public.delivery_payments(
      delivery_payment_id bigint generated always as identity primary key,
      delivery_id bigint unique,delivery_fee numeric,additional_fee numeric,
      deduction_amount numeric,final_earning numeric,earning_status text,payout_status text);
    alter table public.delivery_payments enable row level security;
    create function private.current_rider_deliveries(boolean) returns jsonb language sql stable as $$
      select coalesce(jsonb_agg(to_jsonb(d)), '[]'::jsonb) from public.deliveries d $$;
    insert into public.deliveries values(75,'completed'),(76,'completed'),(77,'accepted'),(78,'completed'),(79,'completed');
    insert into private.rider_delivery_assignments values
      (75,'${a}'),(76,'${b}'),(77,'${a}'),(78,'${a}'),(79,'${a}');
    insert into public.rider_assignment_requests(request_id,delivery_id,rider_id,status,proposed_delivery_fee) values
      (1,75,'${a}','accepted',50),(2,76,'${b}','accepted',80),
      (3,77,'${a}','accepted',40),(4,78,'${a}','accepted',null),
      (5,79,'${a}','accepted',90),(6,75,'${b}','pending',999);
    insert into public.delivery_payments(delivery_id,delivery_fee,additional_fee,deduction_amount,final_earning,earning_status,payout_status)
      values(79,90,15,5,100,'approved','paid');
  `);
  const migration = fs.readFileSync('supabase/migrations/20261013130000_record_completed_rider_earnings.sql','utf8');
  await db.exec(migration);
  const payment = async id => (await db.query('select * from public.delivery_payments where delivery_id=$1',[id])).rows[0];
  assert.equal(Number((await payment(75)).final_earning), 50);
  assert.equal((await payment(75)).payout_status, 'unpaid');
  assert.equal(await payment(77), undefined);
  assert.equal(await payment(78), undefined);
  assert.equal(Number((await payment(79)).final_earning), 100);
  assert.equal((await payment(79)).payout_status, 'paid');
  await db.exec("update public.deliveries set delivery_status='completed' where delivery_id=77");
  assert.equal(Number((await payment(77)).final_earning), 40);
  await db.exec("update public.deliveries set delivery_status='completed' where delivery_id=77");
  await db.exec(migration);
  assert.equal((await db.query('select count(*)::int as n from public.delivery_payments')).rows[0].n, 4);
  const claims = async (sub = a, extra = {}) => db.query(
    "select set_config('request.jwt.claims',$1,false)",
    [JSON.stringify({sub,is_anonymous:false,exp:4102444800,...extra})],
  );
  await claims(); await db.exec("set test.gateway='on'; set role authenticated");
  const read = async () => (await db.query('select public.current_rider_deliveries(false) as data')).rows[0].data;
  let rows = await read();
  assert.equal(Number(rows.find(x=>x.delivery_id===75).payment.final_earning),50);
  assert.equal(rows.find(x=>x.delivery_id===76).payment,null);
  await claims(b); rows = await read();
  assert.equal(rows.find(x=>x.delivery_id===75).payment,null);
  assert.equal(Number(rows.find(x=>x.delivery_id===76).payment.final_earning),80);
  for (const statement of [
    'select private.record_completed_rider_earning(75)',
    "update public.delivery_payments set final_earning=999 where delivery_id=75",
    'delete from public.delivery_payments where delivery_id=75',
    'select * from public.delivery_payments',
  ]) await assert.rejects(db.query(statement),{code:'42501'});
  for (const extra of [{is_anonymous:true},{exp:1},{sub:null}]) {
    await claims(a,extra); await assert.rejects(read(),{code:'42501'});
  }
  await claims(); await db.exec("set test.gateway='off'");
  await assert.rejects(read(),{code:'42501'});
  await db.exec('reset role; set role anon');
  await assert.rejects(read(),{code:'42501'});
  await db.close();
  process.stdout.write('Rider earnings SQL: completion, backfill, replay, missing fee, preserved payouts, owner isolation, tampering, anonymous/expired and gateway guards passed.\n');
}
main().catch(error => { process.stderr.write(`Rider earnings SQL failed: ${error.code || error.name}: ${error.message}\n`); process.exitCode=1; });
