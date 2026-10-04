// Isolated PostgreSQL execution of the chat migration; no hosted connection.
// Install @electric-sql/pglite under .dart-local/chat-sql before running.
const assert = require('node:assert/strict');
const fs = require('node:fs');
const { PGlite } = require('../../.dart-local/chat-sql/node_modules/@electric-sql/pglite');

async function main() {
  const db = new PGlite();
  await db.exec(`
    create role anon; create role authenticated; create role service_role;
    create schema auth; create schema private;
    grant usage on schema public, private, auth to authenticated;
    create function auth.uid() returns uuid language sql stable as $$
      select nullif(current_setting('request.jwt.claim.sub', true), '')::uuid
    $$;
    create function auth.jwt() returns jsonb language sql stable as $$
      select coalesce(nullif(current_setting('request.jwt.claims', true), ''), '{}')::jsonb
    $$;
    create table private.auth_identities(auth_user_id uuid, buyer_user_id bigint, farmer_user_id bigint);
    create function private.current_buyer_user_id() returns bigint language sql stable as $$
      select buyer_user_id from private.auth_identities where auth_user_id = auth.uid()
    $$;
    create function private.current_farmer_user_id() returns bigint language sql stable as $$
      select farmer_user_id from private.auth_identities where auth_user_id = auth.uid()
    $$;
    create table public.marketplace_conversations(conversation_id bigint, buyer_user_id bigint,
      farmer_user_id bigint, farm_id bigint, commodity_id bigint, order_id bigint,
      updated_at timestamptz, buyer_last_read_at timestamptz, farmer_last_read_at timestamptz);
    create table public.buyers(buyer_user_id bigint, user_id bigint);
    create table public.users(user_id bigint, first_name text, last_name text, profile_photo_url text);
    create table public.farmers(farmer_user_id bigint, auth_user_id uuid,
      first_name text, last_name text, profile_image_url text);
    create table public.farms(farm_id bigint, farm_name text, farm_location text,
      barangay text, city_municipality text, province text);
    create table public.orders(order_id bigint, client_order_id text, order_status text, cart_item_id bigint);
    create table public.cart_items(cart_item_id bigint, commodity_id bigint, quantity numeric, price_at_time numeric);
    create table public.commodities(commodity_id bigint, commodity_name text, image_url text,
      unit_type text, price_per_unit numeric);
    create table public.marketplace_messages(conversation_id bigint, message_id bigint,
      body text, sent_at timestamptz, sender_role text);
    create function public.current_marketplace_conversations() returns jsonb language sql as $$
      select '[]'::jsonb
    $$;
    revoke all on function public.current_marketplace_conversations() from public, anon;
    grant execute on function public.current_marketplace_conversations() to authenticated;
    insert into private.auth_identities values
      ('00000000-0000-0000-0000-000000000001', 1, null),
      ('00000000-0000-0000-0000-000000000002', null, 2),
      ('00000000-0000-0000-0000-000000000003', 3, null);
    insert into public.buyers values (1, 1), (3, 3);
    insert into public.users values (1, 'Buyer', 'One', null), (3, 'Buyer', 'Other', null);
    insert into public.farmers values (2, '00000000-0000-0000-0000-000000000002', 'Farmer', 'Two', null);
    insert into public.farms values (2, 'Farm', 'Purok 4', 'San Jose', 'La Trinidad', 'Benguet');
    insert into public.marketplace_conversations values (1, 1, 2, 2, null, null, now(), null, null);
  `);
  await db.exec(fs.readFileSync('supabase/migrations/20261004100000_complete_marketplace_chat_address.sql', 'utf8'));
  await db.exec(`create or replace function public.current_marketplace_conversations()
    returns jsonb language sql security invoker set search_path = '' as $$
      select private.current_marketplace_conversations()
    $$;`);
  await db.exec('begin');
  await db.exec(fs.readFileSync('supabase/tests/marketplace_chat_address.sql', 'utf8'));
  await db.exec('rollback');

  // Exercise real authenticated/anonymous roles, beyond owner-run assertions.
  await db.exec(`set role authenticated;
    select set_config('request.jwt.claim.sub', '00000000-0000-0000-0000-000000000001', false);
    select set_config('request.jwt.claims', '{"sub":"00000000-0000-0000-0000-000000000001","is_anonymous":false,"exp":4102444800}', false);`);
  const { rows } = await db.query('select public.current_marketplace_conversations() as conversations');
  assert.equal(rows[0].conversations[0].farm_location, 'Purok 4, San Jose, La Trinidad, Benguet');
  await db.exec('reset role; set role anon');
  await assert.rejects(db.query('select public.current_marketplace_conversations()'), { code: '42501' });
  await db.exec('reset role');
  await db.close();
  console.log('Isolated PostgreSQL checks passed: full/blank/duplicate/hostile addresses, buyer/farmer access, unrelated-account denial, missing/anonymous/expired sessions, and anonymous role denial.');
}
main().catch((error) => { console.error(error.message); process.exitCode = 1; });
