# Concurrency hardening — 2026-10-16

## Context reviewed before extending the implementation

The app shares order state between buyer and farmer flows. Supabase is the
production backend; local repositories support caches and explicit test modes.
Rider acceptance, status updates, COD completion and offline replay already have
operation guards, retry keys and database locks. Those contracts were retained.
The role-specific code, session reset lifecycle, repository interfaces, existing
SQL wrappers and workflow tests were checked before extending the changes.

This change addresses confirmed gaps across the three roles. It is not proof
that every feature is free of concurrency defects or that production supports
a particular user count. The initial findings are in concurrency_capacity_review.md.

## Application changes

- Shared orders: identical in-flight actions share a result; conflicting order
  mutations and reloads run in order. Queued writes check account generation
  before dispatch. Late results/rollbacks cannot replace a different account's
  order list. Cache mutations require a valid matching session when Supabase
  is initialized, and owner checks repeat before cache writes.
  A production controller without a loaded account rejects mutations instead
  of reporting a local-only success.
- Checkout: a random operation UUID and payload fingerprint survive restart.
  Retries reuse seller order IDs and reconcile a previously saved checkout.
  Unknown failures retain identity; known database rejections release it so the
  user can correct stock/payment details. An unresolved checkout with different
  inputs fails closed rather than creating an unrelated replacement. Metadata
  persists in account-scoped preferences; no private request payload is stored
  by the operation metadata helper. This protects normal retries on one device;
  separately initiated purchases on two devices remain distinct operations.
- Shared chat: duplicate inbox/message loads share work. Late message reads
  cannot erase a newly sent message, and a post-send inbox read waits for older
  reads. Buyer/farmer message sends use durable retry UUIDs through the gateway.
  Rider's existing sender/idempotency-key mechanism remains in place.
- Shared support/safety: reject repeat in-flight submissions; ignore late data
  and errors after disposal/session changes. Older loads cannot overwrite newly
  created tickets, replies or incidents. These are submission guards, not new
  durable server retry receipts for support/safety requests.
- Farmer: profile saves reject overlap; verification/follow counts discard older
  responses. Assignment refreshes discard outdated responses, cancellation
  callbacks respect lifecycle/account changes, and cash-out requests use the
  new retry-safe gateway RPC.
- Rider: analytics results respect request ordering and disposal, wallet actions
  share in-flight work, active-delivery refreshes coalesce and reject stale
  results, and safety synchronization avoids simultaneous replay of one report.
  Existing acceptance, batch capacity and offline delivery commands are preserved.
- Tracking: polls/manual refreshes share an in-flight fetch; background polling
  stops. A bounded per-service route cache reuses recent routes with unchanged
  destination and nearby origin. Cache limits are 16 entries and two minutes,
  with a 50 m origin tolerance. Moving riders may still require frequent routes.
  Tracking now honors RIDER_ROUTING_URL, retaining the existing default origin.

## Database and gateway changes: prepared, not deployed

Migration `20261016110000_concurrent_operations.sql` adds:

1. An internal default-deny RLS receipt table keyed by authenticated owner,
   operation kind and retry UUID. Payload hashes reject changed-input replay.
   Transaction advisory locks serialize duplicate keys; receipt and mutation
   commit together. Keys are retry identities, never evidence of ownership.
2. `send_marketplace_message_once`: independently checks session and conversation
   access before returning either an existing receipt or the existing message
   RPC's result. Existing participant checks and shared chat quotas still apply.
3. `submit_farmer_payout_once`: requires an actual farmer identity and delegates
   to the existing farmer payout contract. This adds retry deduplication; it
   does not introduce a different farmer balance/disbursement model.
4. `current_account_order_bundle`: obtains the existing seven caller-scoped
   order/payment/review/expiration/cancellation/refund/dispute results in one
   database snapshot and HTTP request. Existing server query work/history size
   still exists. Only a genuinely missing bundle function enables legacy reads;
   authorization, rate and network errors do not trigger a broader fallback.

The message retry route shares quota keys with the original message route in
`application-api`. The new payout and message mutation transport always uses
that gateway and preserves caller JWTs and structured parameter maps. There is
no fallback to the unprotected legacy mutation after a failure.

Deploy the migration and updated application-api before distributing this client.
The migration depends on the existing October security/payment and shared chat
contracts. New message/payout RPCs fail if absent; order reads retain missing-RPC
compatibility. Existing clients still using older endpoints do not gain the new
retry guarantee. No hosted schema, secrets, gateway settings or APK was changed.

## Verification and practical limits

Local Flutter regression checks cover order placement/recovery, concurrent
actions, background tracking, route caching, shared support/chat, rider analytics,
farmer workflows, wallet behavior, offline recovery and account switching.
Node gateway tests include quota-key equivalence for retry-safe chat.

Completed regression groups: 90 and 71 Flutter tests (161 across 28 files),
plus a final focused rerun of 35 tests after inbox/stale-load adjustments.
All passed. All 11 Node gateway tests and the isolated SQL harness passed.
The 40 touched application sources are at most 187 physical lines and have no
prohibited inline style constructors. Formatting and diff whitespace checks
passed. An earlier full focused Dart analysis returned no issues; a subsequent
broad final pass stalled and was stopped in favor of a smaller final pass.
The smaller final analysis completed with no issues.
The final authentication/ownership/checkout group passed 23 tests (seven are
checkout rechecks), bringing unique Flutter regression coverage to 177 tests
across 31 files. Signed-out navigation, session loss, account isolation and
owner helper contracts remain covered. This is focused coverage, not the full
repository test suite.

The isolated PGlite harness applies the actual migration, exercises replay,
changed-input rejection, caller/role/session/gateway denial, literal hostile
values and owner isolation, and runs application_table_rls.sql plus the new
concurrent_operations.sql metadata assertions. It uses fixture implementations
for existing business RPCs and hashing; it does not validate the entire migrated
schema, hosted cryptographic configuration, or independent concurrent sessions.

The full local PostgreSQL endpoint at 127.0.0.1:54322 was unavailable. Therefore
authentication_boundary.sql, sql_injection_boundary.sql,
existing_account_profile_isolation.sql and account_data_isolation.sql remain
pending against a complete local/test database, as does application_table_rls.sql
against that complete schema. No synthetic production fixtures were created.

Production readiness still requires migration/gateway rollout, real independent
transaction races, production-like load tests, database/query-plan metrics,
provider provisioning, and device/network verification. The earlier staged
general rate-limit rollout and separate Storage/Realtime gaps remain; this
change does not activate hosted enforcement or replace every subscription.
Support/safety uncertain-response retries, other mutation idempotency contracts,
and large-history pagination need further workflow-specific work; button guards
alone do not provide durable deduplication for those paths.
