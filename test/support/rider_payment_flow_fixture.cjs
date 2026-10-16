const fs = require('node:fs');
const { PGlite } = require('../../.dart-local/chat-sql/node_modules/@electric-sql/pglite');
const owner = '00000000-0000-0000-0000-000000000001';
const other = '00000000-0000-0000-0000-000000000002';
const riderOwner = '30000000-0000-0000-0000-000000000001';
const riderOther = '30000000-0000-0000-0000-000000000002';
async function fixture() {
  const db = new PGlite();
  await db.exec(`
    create role anon; create role authenticated; create role service_role;
    create schema auth; create schema private;
    grant usage on schema public,private,auth to authenticated,anon,service_role;
    create function auth.jwt() returns jsonb language sql stable as $$
      select coalesce(nullif(current_setting('request.jwt.claims',true),''),'{}')::jsonb $$;
    create function auth.uid() returns uuid language sql stable as $$ select (auth.jwt()->>'sub')::uuid $$;
    create function auth.role() returns text language sql stable as $$ select auth.jwt()->>'role' $$;
    create table private.auth_identities(auth_user_id uuid,rider_id uuid);
    insert into private.auth_identities values('${owner}','${riderOwner}'),('${other}','${riderOther}');
    create function private.current_rider_id() returns uuid language sql stable security definer as $$
      select rider_id from private.auth_identities where auth_user_id=auth.uid() $$;
    create function private.current_farmer_user_id() returns bigint language sql stable as $$
      select case when auth.jwt()->>'farmer' = 'true' then 1::bigint end $$;
    create function public.require_rate_limited_gateway() returns void language plpgsql as $$
      begin if current_setting('test.gateway',true) is distinct from 'on' then
      raise exception 'Gateway required' using errcode='42501'; end if; end $$;
    create table auth.users(id uuid primary key,email text,raw_user_meta_data jsonb);
    insert into auth.users values('${owner}','owner@example.test','{}'),('${other}','other@example.test','{}');
    create table public.farmers(auth_id uuid,farm_name text);
    create table public.notifications(recipient_auth_user_id uuid,title text,description text,
      notification_type text,category text,destination text,metadata jsonb);
    create table public.deliveries(delivery_id bigint primary key,delivery_status text);
    create table private.rider_delivery_assignments(delivery_id bigint unique,rider_id uuid);
    create table public.rider_assignment_requests(request_id bigint primary key,
      delivery_id bigint,rider_id uuid,status text,proposed_delivery_fee numeric,requested_at timestamptz default now());
    create table public.delivery_payments(delivery_id bigint unique references public.deliveries,
      delivery_fee numeric,additional_fee numeric,deduction_amount numeric,final_earning numeric,
      earning_status text,payout_status text);
    create function private.current_rider_deliveries(boolean) returns jsonb language sql stable as $$
      select coalesce(jsonb_agg(to_jsonb(d)), '[]'::jsonb) from public.deliveries d $$;
    insert into public.deliveries values(1,'accepted'),(2,'accepted'),(3,'accepted'),(4,'completed');
    insert into private.rider_delivery_assignments values(1,'${riderOwner}'),(2,'${riderOwner}'),(3,'${riderOther}'),(4,'${riderOwner}');
    insert into public.rider_assignment_requests values
      (1,1,'${riderOwner}','accepted',50,now()),(2,2,'${riderOwner}','accepted',80,now()),
      (3,3,'${riderOther}','accepted',900,now()),(4,4,'${riderOwner}','accepted',null,now());
  `);
  for (const name of ['20260919240000_add_payout_cash_out_requests_rpc.sql',
    '20260919250000_add_admin_payout_requests_management_rpc.sql']) {
    await db.exec(fs.readFileSync(`supabase/migrations/${name}`,'utf8'));
  }
  await db.exec(`alter function public.submit_payout_request(numeric,text,text,text,text,text,text)
    rename to api_impl_20260925_submit_payout_request;
    alter function public.api_impl_20260925_submit_payout_request(numeric,text,text,text,text,text,text) set schema private;
    grant insert on public.payout_requests to authenticated;
    grant execute on function private.api_impl_20260925_submit_payout_request(numeric,text,text,text,text,text,text) to authenticated;
    insert into public.user_withdrawal_methods(method_id,user_id,user_role,payout_method,account_name,account_number)
      values('10000000-0000-0000-0000-000000000001','${owner}','rider','gcash','Owner','09123456789'),
      ('10000000-0000-0000-0000-000000000002','${other}','rider','gcash','Other','09999999999');
  `);
  for (const name of ['20261013130000_record_completed_rider_earnings.sql',
    '20261015100000_complete_rider_payment_flow.sql']) {
    await db.exec(fs.readFileSync(`supabase/migrations/${name}`,'utf8'));
  }
  async function claims(sub = owner, extra = {}) {
    await db.query("select set_config('request.jwt.claims',$1,false)",[
      JSON.stringify({sub,role:'authenticated',exp:Math.floor(Date.now()/1000)+3600,...extra}),
    ]);
    await db.exec("select set_config('test.gateway','on',false)");
  }
  return { db, claims, owner, other };
}
module.exports = { fixture };
