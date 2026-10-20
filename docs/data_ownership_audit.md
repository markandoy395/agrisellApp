# Account data ownership audit - 2026-10-03

## Scope and interpretation

Reviewed Flutter table queries, RPC call sites and their migration-defined
implementations, realtime notification subscriptions, storage references, and the
notification webhook. The searchable inventory is `.query-audit.txt`. Hosted
table/column and RPC metadata was inspected, the pending migrations were deployed,
and database authentication/RLS/profile-isolation assertions were executed.

Private account data must belong to the authenticated caller. The existing
marketplace also requires shared catalogue listings, published reviews, logistics
company information, eligible delivery offers, and buyer/seller/rider transaction
participation. Those intentional reads remain available to their authorized
audience. Literal owner-only reads across every table would disable those features.
An unrelated account must not access private profiles, addresses, documents,
wallet records, notifications, support threads, safety reports, or transactions.

## Query coverage

| Query family | Ownership boundary |
| --- | --- |
| Account loader and profile updates | Current numeric `user_id`; farmer `auth_user_id`; rider ID resolved from authenticated identity |
| Buyer address and voucher order eligibility | Current server-derived `buyer_user_id`; orders joined to that buyer's cart |
| Farmer registration, farm, category, commodity CRUD | Farmer resolved from login UUID; farm/category/commodity writes bound to that owner's farm |
| Farmer discounts and inventory restocking RPCs | Owned farm/commodity checks; fixed `farmer_load_sales` to reject unrelated farms by returning no rows |
| Rider profile, vehicle, location, document CRUD | Auth-derived rider ID; document updates/deletes additionally filter `rider_id`; location and rider arguments validated |
| Notifications, realtime feed, device token writes | Recipient/login UUID validated; cloud reads and mutations filter recipient |
| Support tickets and messages | Current user RPCs; direct message reads join tickets and filter current numeric `user_id` |
| Safety report reads/writes | Current reporter UUID; legacy reports without reporter belong only to their rider; report ID collision cannot overwrite another reporter's record |
| Orders, payments, reviews, cancellation, refunds, disputes | Current-account/current-buyer/current-farmer RPCs derive the caller; target order checks remain server-side |
| Marketplace and rider chats | Conversation participants; reads retain party rules; writes bind sender to caller |
| Delivery evidence, completion, ratings, rider assignment | Current-rider/current-participant RPCs; proof table reads additionally filter the current rider |
| Delivery tracking | New participant-checked RPC exposes limited tracking fields; no direct rider/location table fallback |
| Wallet withdrawal methods and payouts | Existing RPCs bind UUID to caller; additional restrictive owner policies |
| Shared products, deals, reviews, banners, logistics | Intentional authenticated marketplace reads; farmer catalogue mutations require ownership |
| Storage | Rider document mutation paths require login UUID prefix; existing storage policies enforce object permissions |
| Notification webhook | Trusted server secret; reads only target recipient tokens; existing authenticated machine-call boundary retained |
| Administration | Normal user sessions denied admin RPC execution and admin table access; trusted service role retains backend access |

`QueryOwner` resolves numeric application IDs through `current_query_owner`, whose
identity comes from `auth.uid()`. Login UUIDs are not interchangeable with numeric
user/buyer IDs. Missing login, anonymous users, conflicting rider/UUID arguments,
and account changes during identity lookup fail closed. Existing correctly scoped
queries keep their guards rather than adding nonexistent `user_id` columns.

The migration adds restrictive owner and participant policies, so older permissive
policies cannot widen direct table access. It separately hardens privileged RPCs
because a security-definer function can bypass RLS. See Supabase's official
[RLS documentation](https://supabase.com/docs/guides/database/postgres/row-level-security)
and [API security guidance](https://supabase.com/docs/guides/api/securing-your-api).

## Hosted deployment and verification

The preceding `20261003120000_require_authenticated_application_access.sql` was
already applied. The following migrations were successfully deployed after a
single rolled-back preflight against the actual hosted schema:

1. `20261003125000_restore_missing_support_schema.sql`
2. `20261003130000_enforce_account_data_ownership.sql`
3. `20261003131000_scope_private_data_rpcs.sql`
4. `20261003132000_complete_application_table_rls.sql`

The CLI hid the PostgreSQL error even with debug output. A rolled-back query
through the linked database API identified the actual remaining failure:
`Ownership table missing: support_tickets`. Both support tables and the customer
support RPCs were missing. The repair restores the existing support migration's
schema and API signatures, uses current identity helpers, rejects anonymous
customer RPC callers, and retains backend-only administration permissions.
Existing rows are preserved when this repair runs on a database with those tables.

Final-ERD compatibility corrections also use the private rider assignment table,
derive rider identity without the removed `riders.auth_id` column, and handle the
historical optional vehicle table. The updated client must be released with these
database changes; current identity and tracking calls depend on the new RPCs.
The RPC patch deliberately fails if the known implementation changed, instead
of silently omitting an ownership guard.

These deployed checks passed:

- `supabase/tests/authentication_boundary.sql`: no anonymous application schema,
  table/column or RPC access; application RLS enabled; storage buckets private.
- `supabase/tests/application_table_rls.sql`: every application table has RLS and
  a restrictive login/ownership/participant/shared/default-deny classification;
  ordinary users have no TRUNCATE/REFERENCES/TRIGGER privileges.
- `supabase/tests/existing_account_profile_isolation.sql`: two existing accounts
  can read their own profiles and resolve their own identity; cross-account
  profile reads, updates, and deletes are blocked in both directions. Anonymous
  authenticated JWTs cannot read profiles or resolve application identity. All
  work was rolled back and no account/profile values were changed.

The push succeeded. Its optional local pg-delta catalog cache could not be built
because Docker Desktop is unavailable; this did not prevent database deployment.

Run `supabase/tests/account_data_isolation.sql` as the migration owner in a migrated
local/test database. It creates two temporary test accounts, impersonates each,
asserts private profile/address/notification/report isolation, attempts cross-user
updates/deletes and report ID tampering, checks the other report is unchanged,
and rolls back the transaction. Also run `authentication_boundary.sql`.
After schema changes, rerun `supabase/tests/application_table_rls.sql`.
It checks every public/private application table for enabled RLS, a restrictive
login policy, an explicit owner/participant/shared/default-deny classification,
absence of anonymous grants, and absence of end-user TRUNCATE/REFERENCES/TRIGGER
privileges. The two-account test also checks an anonymous authenticated JWT.

The final migration covers both public and private application tables, including
partitioned tables. All receive a restrictive login policy that rejects missing
users and Supabase anonymous sign-ins. Internal tables deny direct end-user access;
checked owner-run RPCs and the trusted service role continue to serve backend work.
Unclassified UUID-owned tables require their actual ownership column to equal
`auth.uid()` for both visibility and writes. Unclassified tables without an owner
contract deny access. Shared logistics/banner data permits existing authenticated
reads and rejects client writes. No application table is intentionally readable
by anonymous callers. Supabase-managed schemas and extension-owned relations are
outside this application-table migration. New table migrations must explicitly
enable RLS and classify their access; rerun the metadata audit after schema changes.

Firebase is used for messaging only (`firebase_core`/`firebase_messaging`); there
are no Firestore or Realtime Database clients or database rules to modify here.
Supabase distinguishes [anonymous sign-ins](https://supabase.com/docs/guides/auth/auth-anonymous)
from the `anon` database role, so the login policy checks both the user ID and JWT
`is_anonymous` claim.

Complete live A/B HTTP tests for every private table and RPC, including rider
documents/location, carts, notifications, support, payouts, conversations, orders,
tracking, and evidence. Attempt unrelated IDs, owner-field changes, and conflicting
upsert IDs. Owner reads/writes must succeed, unrelated reads must return no private
records, and unauthorized writes must fail or affect zero rows. Verify authorized
transaction participants and shared marketplace flows still work. Check realtime
and authenticated storage requests using both accounts as well.

## Local verification

Dart analysis of `lib` reported no issues. Ownership and rider GPS regression
tests passed (7 tests); notification cache, tracking, support, safety, and delivery
repository regressions also passed (30 tests). Mock HTTP tests verify the actual
numeric owner filters, rider/document filters, and rejection before unauthorized
requests. Analysis of the changed delivery sources and regression tests also passed.

After correcting the reported deployment failure, all 7 ownership regression
tests passed, including a new proof-query test for the final ERD. Targeted Dart
analysis reported no issues; the changed proof source is 111 physical lines and
has no prohibited inline styling.
After correcting rider identity resolution, all 8 ownership/GPS regression tests
passed and targeted analysis reported no issues. The three changed application
sources are 53, 191, and 149 lines with no prohibited inline styling.

All application source files modified for this ownership audit satisfy the
200-line limit and contain no prohibited inline style definitions. Dart formatting
and whitespace checks were performed on the audit files. Existing unrelated edits
were preserved.

PostgreSQL/Docker are unavailable locally, but the linked database query API
allowed migration preflight and the three deployed checks above. The synthetic
account fixture suite remains for a local/staging database; it was not run on
production. Full live HTTP A/B coverage of every RPC, realtime subscription, and
storage object remains outstanding. Database checks do not replace application
release or Edge Function deployment and end-to-end testing.

## Chat farm address correction - 2026-10-04

Migration `20261004100000_complete_marketplace_chat_address.sql` combines
the participant-visible farm address line (purok), barangay, municipality, and
province in the existing conversation response. It does not expose the farmer's
private residential address. Conversation predicates still resolve buyer/farmer
identity server-side; unauthenticated, anonymous, and expired sessions are rejected.
No new table or client-side profile query is introduced. The formatter treats
address components as static SQL values and removes blank/duplicate components.

The local Supabase database is unavailable. The hosted rollback test was rejected
by automatic approval review because it temporarily changes a shared database
function and reads existing participant records. Hosted assertions and deployment
remain pending explicit approval. The proposed hosted check creates no account
fixtures and rolls back all function changes. No production data has been changed.

Before deployment, run `marketplace_chat_address.sql` and the authentication,
application-table RLS, SQL-injection, and existing-account profile assertions. Run
`account_data_isolation.sql` only in a local/test database. Local Flutter and
SQL-contract checks do not replace database execution or end-to-end verification.

Local verification for this correction: 13 Flutter/repository/SQL-contract tests
passed and focused Dart analysis found no issues. An isolated in-memory PostgreSQL
engine executed the migration and `marketplace_chat_address.sql` against local
fixtures, checking complete/blank/duplicate/hostile address values, buyer/farmer
reads, unrelated-account denial, missing/anonymous/expired session rejection, and
real authenticated/anonymous role execution. This minimal test schema does not
replace the full Supabase assertion suite or hosted verification. Run the harness
with `node test/support/marketplace_chat_address_sql_harness.cjs` after installing
`@electric-sql/pglite` under `.dart-local/chat-sql`.

## Account handoff and order cache — 2026-10-13

Login now starts order-history loading in the background. The existing load
generation check still rejects obsolete results; an additional check prevents
queued outgoing loads from reaching the repository after a logout or switch.
`CachedOrderRepository.load` verifies the requested auth UUID with `QueryOwner`
before remote reads, cache writes, and fallback reads while a remote session is
present. A changed identity aborts that load. Existing participant RPCs and RLS
policies remain unchanged. The account handoff removes old private routes and
clears account state on backend identity changes.

Local handoff, navigation, and queued-load regression tests passed. No database
changes or hosted cross-account assertions were run for this client correction;
real account switching and refresh-token behavior still require device validation.

## Rider Requests radius repair — 2026-10-13

Hosted inspection confirmed that the bounded rider-delivery RPC referenced the
removed `riders.service_radius_km` column (42703). Migration
`20261013100000_fix_rider_requests_radius.sql` uses the bounded radius argument
and preserves the existing current-rider delivery source and assignment checks.
Missing, anonymous, and expired sessions are rejected before privileged reads.
No table RLS or ownership mapping changes. The migration was applied to the
linked database; the existing-rider RPC smoke test passed. An isolated PostgreSQL
harness checks two-rider source isolation and geographic bounds using fixtures.
It does not establish coverage of every production participant path. Full
`account_data_isolation.sql` still requires a migrated local/test database;
synthetic account fixtures were not run on production.

## Rider capacity setup � 2026-10-13 (deployment pending)

Capacity updates identify the current rider from the session; no owner or role
parameter is accepted. Combined active cargo weight is scoped to that rider.
The acceptance helper requires rider ownership or the existing trusted delivery
manager contract. Existing participant policies and grants are retained. Local
ownership/tampering tests passed; full local isolation was unavailable and the
hosted deployment was rejected pending explicit approval. See
rider_capacity_batching.md for scope and rollout.

The pending October 13 cargo check recomputes item mass through seller-order,
seller-farm and buyer-cart filters. Scalar helper execution is private; caller
authorization remains in the capacity validator. Local tests exclude another
buyer's and another farm's rows. See rider_capacity_batching.md for unsupported
non-kg mass and the unapproved deployment.

## Rider status update RPC � 2026-10-13 (deployment pending)

The new current-rider status endpoint checks private.rider_delivery_assignments
against the server current-rider mapping before reading/mutating a delivery or
returning history. Clients supply the delivery ID but no rider identity. Local
checks verify the other rider's status/history remain unchanged after denial.
No legacy generic RPC or table privilege is restored. See rider_status_rpc.md.

Rider earnings (2026-10-13): pending migration 20261013130000 augments existing current_rider_deliveries with caller-assigned payment snapshots, verifies authenticated/non-anonymous/unexpired session and gateway, and records agreed fees only through a server completion trigger. No client identity, dynamic SQL, new public endpoint, anonymous grant, or ordinary-user payment mutation. See docs/rider_earnings.md for isolated verification and outstanding hosted rollout/full-schema assertions.

Rider payment flow (2026-10-15, deployment pending): owner-scoped current_rider_wallet and submit_rider_payout_request use independent session/gateway guards, server method snapshots, account locks and private default-deny delivery allocations. Direct payout inserts and legacy rider submission are revoked; admin payment transitions require service-role backend access and completed transfer references. All parameters are bound/static SQL. See docs/rider_payment_flow.md for accounting, verification and rollout limits.

## Buyer catalogue startup snapshot (2026-10-15)

The first marketplace page may be restored from a 15-minute local snapshot only for the matching non-anonymous, unexpired Supabase session. It includes marketplace rows, farm details and buyer-specific sale prices. Account reset/logout/switch invalidates queued writes and removes the snapshot. Fresh queries retain existing RPC authorization and bound parameters. See docs/startup_performance.md for scope and verification limits.

Rider pickup product image (2026-10-15, deployment pending): migration 20261015120000_include_rider_product_images.sql preserves existing selected/assigned delivery visibility and gateway/payment wrappers; private implementation independently rejects missing/anonymous/expired sessions and missing rider identity. Image is selected from actual ordered commodities scoped to fulfillment buyer and seller farm. No new endpoint, grants, tables or storage policy changes. Client maps the existing response field and retains authenticated storage requests. Isolated PostgreSQL access/missing-image/literal-URL tests pass; full-schema assertions and hosted/device verification remain pending. See docs/performance_optimization.md, Pickup product image correction.

2026-10-15 pickup saved image previews: existing proof object keys now render via the configured project's authenticated delivery-proofs object URL and existing storageImageHeaders origin/session checks. No signed/public URLs, new queries, grants or storage policy changes. Offline pickup file lookup validates generated image filenames in app documents and the 8 MB bound; owner-scoped recovery/private guarded navigation remain unchanged. Local tests cover unsafe paths, absent images, reference changes and decode behavior; hosted storage participant/owner denial and device verification remain unverified. See docs/performance_optimization.md, Pickup reference image verification.

2026-10-15 all rider reference image audit: catalogue thumbnails share RiderProductImage and retain authenticated project-storage/origin-restricted headers. Delivery-detail evidence now resolves existing private object keys and offline pickup references through safe image helpers. No query, schema, policy or grant changes in this follow-up. 37 local tests pass; live remote reads and hosted RLS remain unverified. Prepared product-image migration remains undeployed. See docs/rider_reference_image_audit.md.

2026-10-15 rider pickup/image hosted correction (deployed with explicit user approval): live private.current_rider_deliveries raised 42703 because fulfillment.seller_farm_id does not exist. Migration 20261015130000 fixes the join using representative_order_id -> orders.seller_farm_id, with buyer/farm scoping and unchanged selected/assigned visibility, session guards, fixed search path, grants, gateway/payment wrappers and storage policies. The existing status RPC was present and left unchanged. Hosted rolled-back response, status, authentication, RLS, SQL injection and existing-account isolation assertions pass. Isolated harness now reproduces the original error with actual schema columns and verifies buyer/seller/rider isolation. 27 Flutter tests pass for image/confirmation/snackbar behavior; actual device downloads and delivery mutations remain unverified. Supersedes earlier pending-image-deployment notes. See docs/rider_pickup_refresh_fix.md.

2026-10-15 pickup completion follow-up: existing offline evidence uploader now resolves pickup files through PickupProofStorage.resolveLocalPhoto (documents root), retains strict generated filenames, and validates reference delivery/stage before the existing upload. No new queries, policies or RPCs. Completion maps DeliveryDataException to domain failures so specific server messages reach the form. Hosted inspection was read-only; no delivery mutation or upload tested there. 35 focused local tests pass including HTTP-fixture completion and offline multipart upload/cleanup. See docs/rider_pickup_refresh_fix.md.

2026-10-16 shared chat limits (prepared, not deployed): buyer/farmer/rider message mutations use shared ChatRpc through application-api with caller JWT and bound parameters. New gateway attempt quotas are persistent and fail closed; SQL insert triggers independently validate sessions, participants, Unicode length and successful-write quotas with required gateway marker. No anonymous grants or client identity trust added. Limits: 500 code points/message, 10 attempts/account/conversation/minute, 100/account/24h, 5 new marketplace conversations/account/24h plus 30 start attempts. Existing rider threads remain assignment-derived. See docs/shared_chat_limits.md for local tests, compatibility constraints and outstanding hosted/device/security assertions.

2026-10-16 buyer catalog redesign: new AllProductsScreen uses guarded navigation plus central buyer role/status checks; quick-add independently checks valid session and buyer authorization. Existing catalog pagination/RPCs and basket sync remain unchanged, with bound parameters and no new backend access contracts. Production product imagery stays dynamic through the existing authenticated image loader. See docs/buyer_catalog_design.md for verification scope and Figma reference boundaries; no hosted data/security mutations were made.

2026-10-16 concurrency hardening (prepared, not deployed): owner-scoped retry receipts for buyer/farmer messages and farmer cash-out, independent session/participant/farmer checks, transaction advisory locks, default-deny private receipt RLS, bound/static SQL and caller JWT gateway transport. Shared order queues/cache writes reject account changes; stale callbacks and duplicate submissions are guarded across buyer/farmer/rider/shared flows. Consolidated order bundle retains existing owner RPCs and only falls back when missing. See docs/concurrency_hardening.md for exact scope, isolated fixture verification and outstanding full-schema/hosted/load checks.


Profile persistence repair (2026-10-17): new profile completeness/vehicle RPCs
resolve auth.uid() through the existing identity mapping. Protected vehicle
writes require the persistent quota gateway. The buyer avatar handler validates
current_query_owner against the verified caller and uses caller JWT/RLS for
profile updates; private owner-prefixed storage rejects ordinary client writes.
Existing owner boundaries remain. Location cache and pending sync are scoped to
the current authenticated account. See docs/profile_edit_persistence_audit.md for
rolled-back hosted isolation/repair assertions and remaining device-test limits.



2026-10-19: Rider sample-data testing exposed stale rider verification columns. The verification-details RPC now resolves private.current_rider_id(), returns only caller-owned documents and review actions, requires the existing profile-session and gateway guards, and maps employment status as the app already does. No new public destination or anonymous grant. See docs/mock_rider_testing.md and supabase/tests/rider_verification_identity.sql.


2026-10-19: Nearby rider deliveries exclude completed/cancelled/failed rows before applying the existing response limit. Owner checks, session guards, distance filters, and RPC grants are unchanged. History remains on current_rider_deliveries. Mock-only load fixtures add active deliveries and fresh assignment requests; see docs/mock_rider_testing.md and supabase/tests/rider_nearby_active_requests.sql.


2026-10-20 farmer publication: restrictive verified-owner product/category insert and product-image policies; internal stock RPC approval guard; publish_current_farmer_product validates session/gateway/status/ownership, creates category/product/initial lot atomically, and uses private owner-scoped retry receipts. All values are static SQL parameters. Verification refresh uses the caller-filtered farmer realtime feed plus guarded polling, and ignores late account/disposal responses. See docs/farmer_publication_fix.md; local behavioral tests and hosted metadata/boundary assertions are distinguished there.

