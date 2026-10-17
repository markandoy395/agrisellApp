// Isolated wrapper tests. Underlying business RPCs and digest use fixture stubs.
const assert = require('node:assert/strict');
const fs = require('node:fs');
const { PGlite } = require('../../.dart-local/chat-sql/node_modules/@electric-sql/pglite');
const owner = '10000000-0000-4000-8000-000000000001';
const other = '10000000-0000-4000-8000-000000000002';
const key = '20000000-0000-4000-8000-000000000001';
async function main() {
  const db = new PGlite();
  await db.exec(`
    create role anon; create role authenticated;
    create schema auth; create schema private; create schema extensions;
    create table auth.users(id uuid primary key);
    insert into auth.users values('${owner}'),('${other}');
    grant usage on schema auth,private,extensions to authenticated,anon;
    create function auth.jwt() returns jsonb language sql stable as $$
      select coalesce(nullif(current_setting('request.jwt.claims',true),''),'{}')::jsonb $$;
    create function auth.uid() returns uuid language sql stable as $$
      select (auth.jwt()->>'sub')::uuid $$;
    create function extensions.digest(text,text) returns bytea language sql immutable as $$
      select decode(md5($1),'hex') $$;
    create function public.require_rate_limited_gateway() returns void language plpgsql as $$
      begin if current_setting('test.gateway',true) is distinct from 'valid' then
        raise insufficient_privilege; end if; end $$;
    create function private.current_farmer_user_id() returns bigint language sql stable as $$
      select case when auth.jwt()->>'app_role'='farmer' then 1::bigint end $$;
    create function private.can_access_marketplace_conversation(bigint) returns boolean
      language sql stable as $$ select $1=1 and auth.uid()='${owner}'::uuid $$;
    create sequence public.message_counter;
    create sequence public.payout_counter;
    create function public.send_marketplace_message(bigint,text) returns jsonb language sql as $$
      select jsonb_build_object('id',nextval('public.message_counter'),'body',$2,'owner',auth.uid()) $$;
    create function public.submit_payout_request(numeric,text,text,text,text,text,text) returns jsonb
      language sql as $$ select jsonb_build_object('requestId',nextval('public.payout_counter'),
        'amount',$1,'notes',$6,'owner',auth.uid()) $$;
    grant execute on all functions in schema auth to authenticated,anon;
  `);
  for (const name of ['orders','payment_snapshots','review_snapshots','expiration_snapshots',
    'cancellation_snapshots','refund_snapshots','dispute_snapshots']) {
    await db.exec(`create function public.current_account_${name}() returns jsonb language sql stable as $$
      select jsonb_build_array(jsonb_build_object('owner',auth.uid())) $$;`);
  }
  await db.exec(fs.readFileSync('supabase/migrations/20261016110000_concurrent_operations.sql','utf8'));
  await db.exec('grant usage on schema public to authenticated,anon');
  async function session(id=owner, extra={}) {
    await db.exec('reset role');
    await db.query("select set_config('request.jwt.claims',$1,false),set_config('test.gateway','valid',false)",
      [JSON.stringify({sub:id,exp:4102444800,is_anonymous:false,app_role:'farmer',...extra})]);
    await db.exec('set role authenticated');
  }
  async function denied(action, code) {
    await assert.rejects(action, error => !code || error.code === code);
  }
  const literal = "literal_%_*' ; -- SELECT private data";
  const send = (text=literal, requestKey=key) => db.query(
    'select public.send_marketplace_message_once(1,$1,$2) result',[text,requestKey]);
  await session();
  const sent = (await send()).rows[0].result;
  assert.equal(sent.body,literal);
  assert.deepEqual((await send()).rows[0].result,sent);
  await denied(() => send('changed'), '22023');
  await denied(() => db.query('select * from private.application_operation_receipts'), '42501');
  await denied(() => db.query("delete from private.application_operation_receipts"), '42501');
  await denied(() => db.query("update private.application_operation_receipts set result='{}'"), '42501');
  await denied(() => db.query(`insert into private.application_operation_receipts
    (owner_id,operation,request_key,payload_hash,result)
    values($1,'marketplace_message',$2,decode('00','hex'),'{}')`,[other,key]), '42501');
  await session(other);
  await denied(send, '42501');
  await session(owner,{is_anonymous:true});
  await denied(send,'PT401');
  await session(owner,{exp:1});
  await denied(send,'PT401');
  await session(null);
  await denied(send,'PT401');
  await session();
  await db.exec("set test.gateway='invalid'");
  await denied(send,'42501');
  await session();
  await db.exec('set role anon');
  await denied(send,'42501');
  await session();
  const payout = () => db.query("select public.submit_farmer_payout_once(25,'gcash','name','09123456789',$1,null,$2) result",[key,literal]);
  const saved = (await payout()).rows[0].result;
  assert.deepEqual((await payout()).rows[0].result,saved);
  assert.equal(saved.notes,literal);
  await session(other);
  const otherSaved = (await payout()).rows[0].result;
  assert.notEqual(otherSaved.requestId,saved.requestId);
  assert.equal(otherSaved.owner,other);
  await session(other,{app_role:'rider'});
  await denied(payout,'42501');
  await session();
  const bundle = (await db.query('select public.current_account_order_bundle() value')).rows[0].value;
  assert.equal(Object.keys(bundle).length,7);
  for (const values of Object.values(bundle)) assert.equal(values[0].owner,owner);
  await session(other);
  const otherBundle = (await db.query('select public.current_account_order_bundle() value')).rows[0].value;
  for (const values of Object.values(otherBundle)) assert.equal(values[0].owner,other);
  await db.exec('reset role');
  await db.exec(fs.readFileSync('supabase/tests/application_table_rls.sql','utf8'));
  await db.exec(fs.readFileSync('supabase/tests/concurrent_operations.sql','utf8'));
  assert.equal((await db.query('select last_value from public.message_counter')).rows[0].last_value,1);
  await db.close();
  console.log('Concurrent operation wrappers: replay, payload tampering, caller/role/gateway denial, isolation and RLS checks passed.');
}
main().catch(error => {console.error(error);process.exitCode=1;});
