# Rider earnings correction

Home and Earnings explain the agreed fee, completion requirements, pending versus
paid payout, and the separate obligation to remit cash collected for products.
No per-kilometer rates, commissions, or guaranteed bonuses have been invented.

The completed-delivery mapper previously discarded payment snapshots and their
payout status. The delivery bundle now accepts the server's nested `payment`
only when its delivery ID matches, and completed history carries that snapshot
through to analytics. Recorded final earnings are already net; adjustments are
not subtracted a second time.

## Database repair awaiting deployment

`20261013130000_record_completed_rider_earnings.sql` records a missing earning
transactionally when a delivery becomes completed. The fee comes from the latest
accepted assignment request for the actually assigned rider. It creates a
calculated, unpaid payment; it does not transfer money or mark payout paid.
Unique delivery IDs and `ON CONFLICT DO NOTHING` prevent duplicate credit and
preserve existing approvals, deductions, and payouts. The migration also repairs
historical completed deliveries with a positive agreed fee and no payment row.
Missing/zero fees are not assigned a rate or funded automatically. These need
business review; collected product cash is never used as a delivery fee.

The existing `current_rider_deliveries` endpoint retains its existing visibility
function and adds payment details only for the current assigned rider. It checks
non-anonymous, unexpired authentication and the rate-limited gateway independently.
No client owner ID is accepted. Internal recording functions grant no execution
to ordinary users; direct payment writes remain prohibited. No new RPC endpoint,
table, rate-limit bypass, or anonymous privilege is introduced.

## Verification and rollout

The isolated PGlite harness `test/support/rider_earnings_sql_harness.cjs` applies
the actual migration with fixture identity/gateway/visibility helpers. It checks
completion, historical repair, replay, missing fees, preservation of paid amounts,
account switching, cross-account payment privacy, direct mutation denial,
anonymous/expired callers, and gateway rejection. This does not validate the
hosted schema, real gateway counters, actual transfers, or every production RLS
policy. Flutter regressions exercise remote response to repository to analytics.

Before deployment run the project assertions in a local/test database:
authentication_boundary.sql, application_table_rls.sql, sql_injection_boundary.sql,
existing_account_profile_isolation.sql, account_data_isolation.sql, and
rider_earnings.sql. Do not create synthetic fixtures in production.
After approved deployment run rolled-back metadata assertions and verify one
legitimate completed delivery and its payout status. Hosted deployment and these
full-schema assertions have not been performed in this task.

Local full-schema assertion attempt on 2026-10-13 failed with ECONNREFUSED at 127.0.0.1:54322. The local Supabase database is not running; the remaining project-wide SQL assertions require that environment.

Rider payment flow (2026-10-15, deployment pending): owner-scoped current_rider_wallet and submit_rider_payout_request use independent session/gateway guards, server method snapshots, account locks and private default-deny delivery allocations. Direct payout inserts and legacy rider submission are revoked; admin payment transitions require service-role backend access and completed transfer references. All parameters are bound/static SQL. See docs/rider_payment_flow.md for accounting, verification and rollout limits.
