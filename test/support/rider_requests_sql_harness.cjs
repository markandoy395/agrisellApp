// Isolated PostgreSQL regression. Never connects to the hosted database.
const assert = require('node:assert/strict');
const fs = require('node:fs');
const { PGlite } = require('../../.dart-local/chat-sql/node_modules/@electric-sql/pglite');
const migration = 'supabase/migrations/20261013100000_fix_rider_requests_radius.sql';
const a = '00000000-0000-0000-0000-000000000001';
const b = '00000000-0000-0000-0000-000000000002';

async function main() {
  const db = new PGlite();
  await db.exec(`
    create role anon; create role authenticated; create role service_role;
    create schema auth; create schema private;
    grant usage on schema public, private, auth to authenticated;
    create function auth.jwt() returns jsonb language sql stable as $$
      select coalesce(nullif(current_setting('request.jwt.claims',true),''),'{}')::jsonb
    $$;
    create function auth.uid() returns uuid language sql stable as $$
      select (auth.jwt()->>'sub')::uuid
    $$;
    create table public.riders(rider_id uuid primary key);
    insert into public.riders values ('${a}'), ('${b}');
    create function private.current_rider_id() returns uuid language sql stable as $$
      select auth.uid()
    $$;
    create table private.test_deliveries(owner uuid, item jsonb);
    create function private.current_rider_deliveries(boolean) returns jsonb
    language sql stable security definer set search_path='' as $$
      select coalesce(jsonb_agg(item),'[]'::jsonb) from private.test_deliveries
      where owner = private.current_rider_id()
    $$;
  `);
  const geo = fs.readFileSync('supabase/migrations/20260809100000_include_buyer_destination_in_rider_matching.sql', 'utf8');
  await db.exec(geo.slice(geo.indexOf('create or replace function'), geo.indexOf('$$;') + 3));
  const old = fs.readFileSync('supabase/migrations/20260819090000_add_bounded_rider_map_discovery.sql', 'utf8');
  await db.exec(old);
  const claims = async (sub = a, overrides = {}) => db.query(
    "select set_config('request.jwt.claims',$1,false)",
    [JSON.stringify({ sub, is_anonymous: false, exp: 4102444800, ...overrides })]);
  await claims();
  // Prove the original implementation fails on the actual removed column.
  await assert.rejects(db.query('select public.current_rider_nearby_deliveries(0,0)'), { code: '42703' });
  await db.exec('drop function public.current_rider_nearby_deliveries(double precision,double precision,double precision,integer)');
  await db.exec(fs.readFileSync(migration, 'utf8'));
  await db.exec(`create function public.current_rider_nearby_deliveries(
    double precision,double precision,double precision default 15,integer default 50)
    returns jsonb language sql security invoker set search_path='' as $$
      select private.api_impl_current_rider_nearby_deliveries($1,$2,$3,$4)
    $$;
    revoke all on function public.current_rider_nearby_deliveries(double precision,double precision,double precision,integer) from public,anon;
    grant execute on function public.current_rider_nearby_deliveries(double precision,double precision,double precision,integer) to authenticated;`);
  for (const [id, owner, latitude, assigned] of [
    [1, a, 0.01, false], [2, a, 1, false], [3, a, 2, true],
    [4, b, 0.01, false], [5, a, null, false], [6, a, null, true],
  ]) {
    await db.query('insert into private.test_deliveries values ($1,$2)', [owner, JSON.stringify({
      delivery_id: id, assigned_to_current_rider: assigned,
      address: "literal %_*' --", locations: [{ location_type: 'pickup', latitude, longitude: 0 }],
    })]);
  }
  await db.exec('set role authenticated');
  const load = async (radius = 15, limit = 50) => {
    const { rows } = await db.query('select public.current_rider_nearby_deliveries(0,0,$1,$2) as result', [radius, limit]);
    return rows[0].result;
  };
  assert.deepEqual((await load()).map(x => x.delivery_id).sort(), [1, 3, 6]);
  assert.equal((await load())[2].address, "literal %_*' --");
  assert.equal((await load(15, 1)).length, 1);
  // Maximum radius stays 100km, and assigned jobs remain visible outside it.
  assert.deepEqual((await load(10000)).map(x => x.delivery_id).sort(), [1, 3, 6]);
  assert.deepEqual((await load(0.01)).map(x => x.delivery_id).sort(), [3, 6]);
  await claims(b);
  assert.deepEqual((await load()).map(x => x.delivery_id), [4]);
  await claims('00000000-0000-0000-0000-000000000003');
  await assert.rejects(load(), { code: '42501' });
  for (const invalid of [{ is_anonymous: true }, { exp: 1 }, { sub: null }]) {
    await claims(a, invalid);
    await assert.rejects(load(), { code: '42501' });
  }
  await claims();
  await assert.rejects(load(-1), { code: '22023' });
  await assert.rejects(db.query('select public.current_rider_nearby_deliveries(91,0)'), { code: '22023' });
  await db.exec('reset role; set role anon');
  await assert.rejects(load(), { code: '42501' });
  await db.exec('reset role');
  await db.close();
  console.log('Passed: original 42703 reproduction, fixed RPC, distance/limit bounds, assigned jobs, missing pins, two-rider isolation, invalid/anonymous/expired sessions, and literal hostile data.');
}
main().catch(error => { console.error(error.message); process.exitCode = 1; });
