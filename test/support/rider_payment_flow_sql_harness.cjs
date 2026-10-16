const assert = require('node:assert/strict');
const { fixture } = require('./rider_payment_flow_fixture.cjs');
async function main() {
  const {db,claims,owner,other} = await fixture();
  const one = '10000000-0000-0000-0000-000000000001';
  const two = '10000000-0000-0000-0000-000000000002';
  const key = n => `20000000-0000-0000-0000-${String(n).padStart(12,'0')}`;
  const call = async (sql,args=[]) => (await db.query(sql,args)).rows[0]?.result;
  const wallet = () => call('select public.current_rider_wallet() result');
  const submit = (amount,n,method=one) => call('select public.submit_rider_payout_request($1,$2,$3) result',[method,amount,key(n)]);
  const action = (id,action,reference=null) => call('select public.admin_update_payout_request($1,$2) result',[
    {request_id:id,action,payout_reference:reference,rejection_reason:"literal ' ; -- %_"},'Test administrator',
  ]);
  const admin = () => claims(owner,{role:'service_role'});
  const status = async id => (await db.query('select payout_status from public.delivery_payments where delivery_id=$1',[id])).rows[0]?.payout_status;
  await claims();
  assert.deepEqual(await wallet(),{reconciliation_required:false,available:0,reserved:0,paid:0});
  await assert.rejects(submit(1,1),/exceeds/);
  await db.exec("update public.deliveries set delivery_status='completed' where delivery_id in (1,2,3)");
  assert.deepEqual(await wallet(),{reconciliation_required:false,available:130,reserved:0,paid:0});
  assert.equal((await db.query('select count(*)::int n from public.delivery_payments where delivery_id=4')).rows[0].n,0);
  await assert.rejects(submit(1,1,two),/owned/);
  for (const amount of [0,-1,0.001,'NaN','Infinity',131]) await assert.rejects(submit(amount,1));
  const first = await submit(30,1);
  assert.equal((await submit(30,1)).requestId,first.requestId);
  await assert.rejects(submit(31,1),/already used/);
  assert.deepEqual(await wallet(),{reconciliation_required:false,available:100,reserved:30,paid:0});
  await assert.rejects(submit(101,2),/exceeds/);
  await assert.rejects(action(first.requestId,'approve'),/Trusted/);
  await admin();
  await assert.rejects(action(first.requestId,'mark_paid','REF-1'),/transition/);
  await action(first.requestId,'approve');
  await action(first.requestId,'approve');
  await assert.rejects(action(first.requestId,'mark_paid'),/reference/i);
  await action(first.requestId,'mark_paid','REF-1');
  await action(first.requestId,'mark_paid','REF-1');
  await assert.rejects(action(first.requestId,'reject'),/cannot/);
  assert.equal(await status(1),'unpaid'); // Partial payment does not mark the delivery fully paid.
  await claims();
  assert.deepEqual(await wallet(),{reconciliation_required:false,available:100,reserved:0,paid:30});
  const second = await submit(100,2);
  assert.deepEqual(await wallet(),{reconciliation_required:false,available:0,reserved:100,paid:30});
  await assert.rejects(submit(0.01,3),/exceeds/);
  await admin();
  await action(second.requestId,'approve');
  await assert.rejects(action(second.requestId,'mark_paid','REF-1'),/unique/);
  await action(second.requestId,'reject');
  await action(second.requestId,'reject');
  await claims();
  assert.deepEqual(await wallet(),{reconciliation_required:false,available:100,reserved:0,paid:30});
  const third = await submit(100,3);
  await admin();
  await action(third.requestId,'approve');
  await assert.rejects(db.exec('update public.delivery_payments set final_earning=0 where delivery_id=1'),/reserved/);
  await assert.rejects(db.exec("update public.deliveries set delivery_status='cancelled' where delivery_id=1"),/reserved/);
  await assert.rejects(db.exec('delete from private.rider_delivery_assignments where delivery_id=1'),/reserved/);
  await assert.rejects(db.exec('delete from public.delivery_payments where delivery_id=1'),/foreign key/);
  await action(third.requestId,'mark_paid',"REF-' ; -- %_");
  assert.equal(await status(1),'paid');
  assert.equal(await status(2),'paid');
  await claims();
  assert.deepEqual(await wallet(),{reconciliation_required:false,available:0,reserved:0,paid:130});
  const history = await call("select public.current_user_payout_requests('rider') result");
  assert.equal(history.length,3);
  assert.equal(history.find(r=>r.requestId===third.requestId).payoutReference,"REF-' ; -- %_");
  await claims(other);
  assert.deepEqual(await wallet(),{reconciliation_required:false,available:900,reserved:0,paid:0});
  assert.equal((await call("select public.current_user_payout_requests('rider') result")).length,0);
  await assert.rejects(submit(1,4,one),/owned/);
  await claims(owner,{is_anonymous:true}); await assert.rejects(wallet(),/Authentication/);
  await claims(owner,{exp:1}); await assert.rejects(wallet(),/Authentication/);
  await claims(null); await assert.rejects(wallet(),/Authentication/);
  await claims(); await db.exec("select set_config('test.gateway','off',false)");
  await assert.rejects(wallet(),/Gateway/); await assert.rejects(submit(1,5),/Gateway/);
  await claims();
  await db.exec('set role authenticated');
  await assert.rejects(db.exec(`insert into public.payout_requests(user_id,user_role,amount,payout_method,account_name,account_number)
    values('${owner}','rider',1000,'gcash','Fake','123')`),/permission denied/);
  await assert.rejects(call("select private.api_impl_20260925_submit_payout_request(1,'gcash','Fake','123',null,null,'rider') result"),/permission denied/);
  await assert.rejects(call("select public.submit_payout_request(1,'gcash','Fake','123',null,null,'rider') result"),/rider cash-out/);
  await assert.rejects(action(first.requestId,'approve'),/permission denied/);
  await assert.rejects(db.exec('select * from private.rider_payout_allocations'),/permission denied/);
  await db.exec('reset role');
  await assert.rejects(db.exec(`insert into public.rider_assignment_requests(request_id,status,proposed_delivery_fee)
    values(99,'pending',null)`),/positive agreed/);
  await assert.rejects(db.exec('update public.rider_assignment_requests set proposed_delivery_fee=1000 where request_id=1'),/cannot be changed/);
  await admin();
  const listing = await call('select public.admin_get_payout_requests() result');
  assert.equal(listing.requests.find(r=>r.request_id===third.requestId).deliveries.length,2);
  assert.equal(listing.summary.total_paid_amount,130);
  assert.equal((await db.query('select count(*)::int n from public.notifications')).rows[0].n,6);
  await db.exec(`insert into public.rider_assignment_requests(request_id,delivery_id,status,proposed_delivery_fee)
    values(98,1,'pending',null)`);
  assert.equal(Number((await db.query('select proposed_delivery_fee from public.rider_assignment_requests where request_id=98')).rows[0].proposed_delivery_fee),50);
  await db.exec('set role anon');
  await assert.rejects(wallet(),/permission denied/);
  await assert.rejects(submit(1,99),/permission denied/);
  await db.exec('reset role');
  await claims('00000000-0000-0000-0000-000000000099');
  await assert.rejects(wallet(),/Rider account/);
  await claims();
  await db.exec(`insert into public.deliveries values(5,'accepted');
    insert into private.rider_delivery_assignments select 5,rider_id from private.auth_identities where auth_user_id='${owner}';
    insert into public.rider_assignment_requests(request_id,delivery_id,rider_id,status,proposed_delivery_fee)
      select 5,5,rider_id,'accepted',25 from private.auth_identities where auth_user_id='${owner}';
    update public.deliveries set delivery_status='completed' where delivery_id=5;
    insert into public.payout_requests(request_id,user_id,user_role,amount,payout_method,account_name,account_number,status)
      values('${key(100)}','${owner}','rider',10,'gcash','Owner','09123456789','paid');`);
  assert.equal((await wallet()).available,0);
  assert.equal((await wallet()).reconciliation_required,true);
  await assert.rejects(submit(1,101),/exceeds/);
  // Reconciliation is an explicit trusted accounting operation, never an app mutation.
  await db.exec(`insert into private.rider_payout_allocations values('${key(100)}',5,10)`);
  assert.deepEqual(await wallet(),{reconciliation_required:false,available:15,reserved:0,paid:140});
  await db.exec(require('node:fs').readFileSync('supabase/tests/rider_payment_flow.sql','utf8'));
  await db.close();
  console.log('Rider payment flow SQL passed: fees, completion, reservations, partial/full payouts, rejection release, replay, overdraft, references, literal hostile data, account isolation, ACL and session/gateway denial.');
}
main().catch(error=>{ console.error(error); process.exitCode=1; });
