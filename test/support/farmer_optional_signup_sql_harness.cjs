// Isolated PostgreSQL fixtures. Never connects to a hosted database.
const assert = require('node:assert/strict');
const fs = require('node:fs');
const { PGlite } = require('../../.dart-local/chat-sql/node_modules/@electric-sql/pglite');
const a = '10000000-0000-0000-0000-000000000001';
const b = '10000000-0000-0000-0000-000000000002';
async function main() {
  const db = new PGlite();
  await db.exec(`
    create role anon; create role authenticated; create role service_role;
    create schema auth; create schema private;
    create function auth.jwt() returns jsonb language sql stable as $$
      select current_setting('request.jwt.claims',true)::jsonb $$;
    create function auth.uid() returns uuid language sql stable as $$
      select (auth.jwt()->>'sub')::uuid $$;
    create function private.require_profile_editor() returns uuid language plpgsql as $$
    begin
      if auth.uid() is null or coalesce((auth.jwt()->>'is_anonymous')::boolean,true)
        or (auth.jwt()->>'exp')::numeric <= extract(epoch from now()) then
        raise exception 'Authentication required' using errcode='42501';
      end if;
      return auth.uid();
    end $$;
    create function private.current_email_is_verified() returns boolean language sql as $$
      select coalesce((auth.jwt()->>'email_verified')::boolean,false) $$;
    create function public.require_rate_limited_gateway() returns void language plpgsql as $$
    begin
      if auth.jwt()->>'gateway' is distinct from 'true' then
        raise exception 'Gateway required' using errcode='42501';
      end if;
    end $$;
    create table auth.users(id uuid primary key,raw_user_meta_data jsonb);
    create table private.auth_identities(auth_user_id uuid primary key,
      user_id bigint,buyer_user_id bigint,farmer_user_id bigint,rider_id bigint);
    create table public.farmers(farmer_user_id bigint generated always as identity primary key,
      auth_user_id uuid unique,first_name text,middle_name text,last_name text,suffix text,
      phone_number text,date_of_birth date,gender text,address_line text,barangay text,
      city_municipality text,province text,postal_code text,years_of_experience integer,
      verification_status text,account_status text,registration_date date);
    create table public.farms(farm_id bigint generated always as identity primary key,
      farmer_user_id bigint,farm_name text not null,farm_location text,barangay text,
      city_municipality text,province text,gps_lat numeric,gps_long numeric,
      total_crops integer,farm_size_hectares numeric,farm_size numeric,farm_size_unit text,
      farming_type text,irrigation_type text,ownership_type text,main_crops text[]);
    create table public.categories(category_id bigint primary key,farm_id bigint,category_name text);
    create table public.commodities(commodity_id bigint primary key,farm_id bigint,category_id bigint);
    grant usage on schema public,auth to authenticated;
    grant select on public.farmers,public.farms to authenticated;
    grant select,insert,update,delete on public.categories,public.commodities to authenticated;
    alter table public.categories enable row level security;
    alter table public.commodities enable row level security;
    create policy category_read on public.categories for select to authenticated using (
      exists(select 1 from public.farms f join public.farmers r using(farmer_user_id)
        where f.farm_id=categories.farm_id and r.auth_user_id=auth.uid()));
    create policy commodity_read on public.commodities for select to authenticated using (
      exists(select 1 from public.farms f join public.farmers r using(farmer_user_id)
        where f.farm_id=commodities.farm_id and r.auth_user_id=auth.uid()));
    insert into auth.users values('${a}','{"requested_role":"farmer"}'),
      ('${b}','{"requested_role":"farmer"}');
  `);
  await db.exec(fs.readFileSync('supabase/migrations/20261017130000_optional_farmer_farm_details_and_uploads.sql','utf8'));
  const claims = (sub=a, overrides={}) => db.query(
    "select set_config('request.jwt.claims',$1,false)",
    [JSON.stringify({sub,is_anonymous:false,exp:4102444800,email_verified:true,gateway:true,...overrides})]);
  const payload = {first_name:'Ana',last_name:"Reyes'--",phone_number:'09171234567',
    date_of_birth:'2000-01-01',gender:'female',address_line:'Street',barangay:'Barangay',
    city_municipality:'City',province:'Province',farm_details_skipped:true};
  const complete = (data=payload) => db.query(
    'select private.complete_current_farmer_registration($1::jsonb) as result', [JSON.stringify(data)]);
  const denied = async (query) => assert.rejects(query, /required|row-level security|permission denied|assigned|valid|details/i);
  await claims();
  await complete({...payload,auth_user_id:b,farmer_user_id:999});
  assert.equal((await db.query('select auth_user_id from public.farmers')).rows[0].auth_user_id,a);
  await complete(); // Retry creates exactly one farmer and no placeholder farm.
  assert.equal((await db.query('select count(*)::int as n from public.farmers')).rows[0].n,1);
  assert.equal((await db.query('select count(*)::int as n from public.farms')).rows[0].n,0);
  assert.equal((await db.query('select public.current_signup_profile_complete() as ok')).rows[0].ok,true);
  assert.equal((await db.query('select last_name from public.farmers')).rows[0].last_name,"Reyes'--");
  await denied(complete({...payload,first_name:''}));
  await denied(complete({...payload,farm_details_skipped:false}));
  await claims(a,{is_anonymous:true}); await denied(complete());
  await claims(a,{sub:null}); await denied(complete());
  await claims(a,{exp:1}); await denied(complete());
  await claims(a,{email_verified:false}); await denied(complete());
  await claims(a,{gateway:false}); await denied(complete());
  await claims(b); await complete({...payload,first_name:'Other',farm_details_skipped:false,
    farm_name:'Other farm',farm_location:'Other address',latitude:8,longitude:124,
    years_of_experience:1,farm_size:2,farm_size_unit:'ha',main_crops:['Rice']});
  assert.equal((await db.query('select public.current_signup_profile_complete() as ok')).rows[0].ok,true);
  await claims(a);
  await db.exec(`insert into public.farms(farmer_user_id,farm_name) values(1,'Own farm');
    insert into public.categories values(20,1,'Other category');`);
  // Farm 1 belongs to B; farm 2 belongs to A. The migration must enforce this mapping.
  await db.exec('set role authenticated');
  await db.exec("insert into public.categories values(10,2,'Rice_%_' || chr(39) || '--')");
  await db.exec('insert into public.commodities values(10,2,10)');
  await denied(db.exec("insert into public.categories values(11,1,'Stolen')"));
  await denied(db.exec('insert into public.commodities values(11,1,20)'));
  await denied(db.exec('insert into public.commodities values(12,2,20)'));
  assert.equal((await db.query('select * from public.commodities where commodity_id=10')).rows.length,1);
  await claims(b);
  assert.equal((await db.query('select * from public.commodities where commodity_id=10')).rows.length,0);
  assert.equal((await db.query('update public.commodities set farm_id=1 where commodity_id=10 returning *')).rows.length,0);
  assert.equal((await db.query('delete from public.commodities where commodity_id=10 returning *')).rows.length,0);
  await claims(a,{is_anonymous:true});
  await denied(db.exec("insert into public.categories values(12,2,'Anonymous')"));
  await claims(a,{exp:1});
  await denied(db.exec('insert into public.commodities values(16,2,10)'));
  await claims(null); await denied(db.exec('insert into public.commodities values(13,2,10)'));
  await db.exec('set role anon'); await denied(db.exec('select * from public.commodities'));
  await db.exec('reset role'); await claims();
  for (const status of ['suspended','disabled','rejected']) {
    await db.query('update public.farmers set account_status=$1 where farmer_user_id=1',[status]);
    await db.exec('set role authenticated');
    await denied(db.exec('insert into public.commodities values(14,2,10)'));
    await db.exec('reset role');
  }
  await db.exec("update public.farmers set account_status='active',verification_status='verified' where farmer_user_id=1; set role authenticated");
  await db.exec('insert into public.commodities values(15,2,10)');
  await db.exec('reset role');
  await db.exec("update public.farmers set verification_status='needs_information' where farmer_user_id=1; set role authenticated");
  await db.exec('insert into public.commodities values(17,2,10)');
  await db.exec('reset role');
  await db.exec("update public.farmers set verification_status='rejected' where farmer_user_id=1; set role authenticated");
  await denied(db.exec('insert into public.commodities values(18,2,10)'));
  await db.exec('reset role');
  await db.close();
  console.log('PASS: optional signup, retries, profile completion, pending/verified uploads, ownership, anonymous and blocked accounts');
}
main().catch(error => { console.error(error.message); process.exitCode=1; });
