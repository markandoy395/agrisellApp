// Isolated fixtures only. Never connects to the hosted database.
const assert=require('node:assert/strict'),fs=require('node:fs');
const {PGlite}=require('../../.dart-local/chat-sql/node_modules/@electric-sql/pglite');
const a='10000000-0000-0000-0000-000000000001',b='10000000-0000-0000-0000-000000000002';
async function main(){
 const db=new PGlite();
 await db.exec(`create role authenticated;create role anon;create role service_role;
 create schema private;create schema auth;create schema extensions;
 create function auth.jwt() returns jsonb language sql stable as $$
 select coalesce(current_setting('request.jwt.claims',true),'{}')::jsonb $$;
 create function auth.uid() returns uuid language sql stable as $$ select (auth.jwt()->>'sub')::uuid $$;
 create function auth.role() returns text language sql stable as $$ select auth.jwt()->>'role' $$;
 -- Deterministic digest shim for PGlite; hosted uses the existing pgcrypto digest.
 create function extensions.digest(text,text) returns bytea language sql immutable as $$
 select decode(md5($1)||md5($1),'hex') $$;
 create table private.api_gateway_configuration(singleton boolean,secret_hash text);
 insert into private.api_gateway_configuration values(true,encode(extensions.digest('gateway','sha256'),'hex'));
 create table public.marketplace_conversations(conversation_id bigint generated always as identity,
 buyer_user_id bigint,farmer_user_id bigint,farm_id bigint,commodity_id bigint,order_id bigint);
 create unique index chat_unique on public.marketplace_conversations
 (buyer_user_id,farm_id,commodity_id,order_id) nulls not distinct;
 create table public.marketplace_messages(conversation_id bigint,body text);
 create table public.rider_delivery_messages(delivery_id bigint,party text,sender_auth_id uuid,
 idempotency_key text,body text);
 create unique index rider_key on public.rider_delivery_messages(sender_auth_id,idempotency_key)
 where idempotency_key is not null;
 create function private.current_buyer_user_id() returns bigint language sql stable as $$
 select case auth.uid() when '${a}'::uuid then 1 when '${b}'::uuid then 2 end $$;
 create function private.can_access_marketplace_conversation(bigint) returns boolean language sql stable as $$
 select auth.uid() in ('${a}'::uuid,'${b}'::uuid) and $1 between 1 and 20 $$;
 create function private.can_access_rider_delivery_conversation(bigint,text) returns boolean language sql stable as $$
 select auth.uid() in ('${a}'::uuid,'${b}'::uuid) and $1=7 and $2='seller' $$;`);
 await db.exec(fs.readFileSync('supabase/migrations/20260917110000_admin_distributed_rate_limits.sql','utf8'));
 await db.exec(fs.readFileSync('supabase/migrations/20261016100000_shared_chat_limits.sql','utf8'));
 await db.exec(`alter table public.marketplace_messages enable row level security;
 alter table public.rider_delivery_messages enable row level security;
 alter table public.marketplace_conversations enable row level security;`);
 await db.exec(fs.readFileSync('supabase/tests/shared_chat_limits.sql','utf8'));
 const claims=(id=a,overrides={})=>db.query("select set_config('request.jwt.claims',$1,false)",
 [JSON.stringify({sub:id,role:'authenticated',is_anonymous:false,exp:4102444800,...overrides})]);
 const gateway=()=>db.query("select set_config('request.headers',$1,false)",[JSON.stringify({'x-agrisell-api-gateway':'gateway'})]);
 const send=(id=1,text='Hello')=>db.query('insert into public.marketplace_messages values($1,$2)',[id,text]);
 await claims();await gateway();
 await send(1,'😀'.repeat(500));
 await assert.rejects(send(1,'😀'.repeat(501)),{code:'22001'});
 for(let i=1;i<10;i++)await send();
 await assert.rejects(send(),{code:'PT429'});
 await claims(b);await send(); // Account B has its own minute quota.
 await claims();
 for(let i=2;i<=10;i++)for(let j=0;j<10;j++)await send(i,"literal %_' --");
 await assert.rejects(send(11),{code:'PT429'});
 // Marketplace and delivery messages share the same daily account quota.
 await assert.rejects(db.query('insert into public.rider_delivery_messages values(7,$1,$2,$3,$4)',
 ['seller',a,'cross-channel','Hi']),{code:'PT429'});
 await claims(b);
 for(let i=0;i<5;i++)await db.query('insert into public.marketplace_conversations(buyer_user_id,farm_id) values(2,$1)',[i]);
 await assert.rejects(db.exec('insert into public.marketplace_conversations(buyer_user_id,farm_id) values(2,9)'),{code:'PT429'});
 await db.exec('insert into public.marketplace_conversations(buyer_user_id,farm_id) values(2,0) on conflict do nothing');
 await assert.rejects(db.exec('insert into public.marketplace_conversations(buyer_user_id,farm_id) values(1,9)'),{code:'42501'});
 // Direct REST/RPC paths without the gateway cannot bypass committed attempts.
 await db.exec("select set_config('request.headers','{}',false)");
 await assert.rejects(send(3),{code:'PT403'});
 await gateway();
 await assert.rejects(send(99),{code:'42501'});
 await db.query('insert into public.rider_delivery_messages values(7,$1,$2,$3,$4)', ['seller',b,'retry','Hi']);
 for(let i=0;i<20;i++)await db.query(`insert into public.rider_delivery_messages values(7,$1,$2,$3,$4)
 on conflict(sender_auth_id,idempotency_key) where idempotency_key is not null
 do update set idempotency_key=excluded.idempotency_key`,['seller',b,'retry','Hi']);
 for(const override of [{sub:null},{is_anonymous:true},{exp:1}]){
 await claims(a,override);await assert.rejects(send(3),{code:'PT401'});}
 await claims(null,{role:'anon'});await assert.rejects(send(),{code:'PT401'});
 await db.close();console.log('Passed: Unicode length, account/conversation/day quotas, cross-channel quota, new/reopened threads, retries, ownership, gateway bypass and invalid sessions.');
}
main().catch(e=>{console.error(e.message);process.exitCode=1;});
