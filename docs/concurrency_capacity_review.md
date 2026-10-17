# Concurrent users and simultaneous actions review

Review date: 2026-10-16. Scope: current working-tree Flutter code, SQL
migrations, Edge Function configuration and existing audit documents.

These are baseline findings from the review. Subsequent implementation and
remaining rollout/verification gaps are recorded in concurrency_hardening.md.

## Assessment

The application has a multi-user backend and meaningful concurrency protections.
It is not yet demonstrated to handle any particular number of simultaneous
users. Account count, active users, open tracking screens, and checkouts per
second are different capacity measures. No hosted load test, compute/connection
inspection, migration-state verification, or production mutation was performed.

## Simultaneous actions

| Scenario | Evidence and expected behavior | Remaining uncertainty |
| --- | --- | --- |
| Repeated Place Order taps on one screen | `checkout_screen_state.dart` sets `_isPlacingOrder` before awaiting and rejects another call while busy. | This protects that screen instance, not multiple devices or retries after an ambiguous network failure. |
| Buyers competing for stock | `20260729100003_harden_buyer_order_sync.sql` locks commodities in ID order; `20260729120000_add_order_payments_reviews.sql` checks stock under a row lock before deducting it. `20260828120000_add_batch_inventory_freshness.sql` also locks inventory lots and raises on insufficient stock. | Requires deployed migrations and real concurrent transaction tests. Popular products serialize competing writes and can increase wait times. |
| Riders accepting one delivery | Delivery acceptance migrations lock the delivery, check assignments/status and use idempotency keys. Batch validation also locks rider capacity. | Verify the deployed function chain with two actual concurrent test sessions, including same-rider capacity races. |
| Lost checkout response followed by retry | The database recognizes an existing client order ID, but `order_controller_placement.dart` generates a new timestamp-based ID on every new placement call. | A committed first request followed by a new attempt can create another order when sufficient stock remains. Preserve a durable checkout operation ID and reconcile before retrying. |
| Repeated rider messages | Migration `20260731141000_add_rider_delivery_messaging.sql` defines a unique sender/idempotency-key index. | Buyer/farmer `send_marketplace_message` calls carry no corresponding client retry key in the inspected repository; ambiguous retries need separate testing. |

These are source findings and expected behaviors, not proof that every hosted
workflow is correct. Existing RPC ownership and RLS checks must remain intact
when optimizing or introducing retry keys.

## Capacity risks, in priority order

1. **Tracking request volume and overlapping work.**
   `delivery_tracking_controller.dart` polls every 15 seconds and does not guard
   against an already-running fetch. `delivery_tracking_service.dart` requests
   a route on each fetch through `OsrmDeliveryRouteService`, whose default is
   `https://router.project-osrm.org`. The inspected route service has no cache.
   At 1,000 open tracking screens, steady polling schedules approximately 67
   tracking RPCs and up to 67 routing requests per second, plus initial loads,
   manual refreshes, gateway work and other app traffic. This is arithmetic,
   not a measured capacity limit. Prevent overlap, pause background polling,
   reuse routes until materially changed, stagger refreshes, and provision a
   routing service for the expected traffic.
2. **Checkout retry identity.** Persist one operation ID across uncertain
   responses/restarts, enforce its identity server-side, and reconcile an
   unknown outcome before allowing a fresh checkout. A busy button alone
   cannot provide this guarantee.
3. **Order request amplification.** `supabase_order_snapshot_loader.dart`
   makes seven sequential RPC attempts per load: orders, payments, reviews,
   expirations, cancellations, refunds and disputes. Its interface provides
   no pagination arguments. Consider a consistent consolidated snapshot and
   paginated history. Merely running all seven in parallel reduces waiting
   time but does not reduce database request volume.
4. **Staged quotas.** `agrisell_supabase.dart` enables the general relay only
   with `SUPABASE_RATE_LIMIT_GATEWAY`; the default is false. The existing
   `rate_limiting_audit.md` records staged direct-REST enforcement and separate
   Storage/Realtime coverage gaps. Chat uses its own gateway call path. Confirm
   hosted state and client compatibility before activation. Per-account quotas
   alone do not establish overall system capacity.
5. **Realtime refresh work.** Rider conversations subscribe to all events on
   `rider_delivery_messages` without a client filter, then reload conversations
   on delivered events. The repository coalesces overlapping refreshes, which
   helps. RLS still determines event visibility; this finding does not imply
   every rider receives every message. Measure authorized fan-out and query
   work before choosing narrower subscriptions or authorized Broadcast.
6. **Large result sets.** Product browsing has 24-item pagination and an
   account-scoped snapshot cache, which help. Other product APIs and message
   loaders have no client pagination parameters in the inspected paths;
   inspect their server limits and profile large histories before rollout.

Supabase documents authorization and throughput costs for Postgres Changes:
[Realtime benchmarks](https://supabase.com/docs/guides/realtime/benchmarks).

`NominatimGeocodingService` also targets the public OSM geocoder without a
shared limiter, but the source search found no call sites outside its own file.
Treat this as a latent integration constraint, not a confirmed active bottleneck.
If activated, obey the application-wide public-service limit:
[Nominatim usage policy](https://operations.osmfoundation.org/policies/nominatim/).

## Verification required before a capacity claim

Use an isolated staging database with production-like schema and data sizes.
Run mixed workloads at 50, 100, 250, 500 and 1,000 concurrent users; these are
test stages, not supported-user promises. Include browsing, chat, tracking,
uploads, orders and rider actions, with realistic idle periods and bursts.

Measure p50/p95/p99 latency, successful throughput, unexpected error rates,
429s, database CPU/I/O, connections, lock waits, deadlocks, Realtime lag and
external routing failures. Agree acceptance targets before testing.

Separately test last-stock races, repeated checkout IDs, response loss after
commit, restart/retry, competing delivery acceptance, simultaneous payout
requests, offline replay, account switching and owner/participant isolation.
Assert no negative stock, duplicate logical checkout, double assignment or
double allocation of payable funds. Use real independent transactions;
SQL-text contract tests and mocked repositories cannot prove these properties.

No application source, query, policy, schema or hosted configuration was changed
by this review. Existing unrelated working-tree edits were left in place.

Local verification: 25 tests passed across `checkout_place_order_test.dart`,
`product_inventory_lot_sql_contract_test.dart`,
`database_performance_optimization_sql_test.dart`,
`rate_limited_supabase_http_client_test.dart` and
`rider_batch_repository_phase13_test.dart`. These cover local UI/repository
behavior and SQL text contracts; they are not a load test or a live concurrent
database test. The first sandboxed Flutter attempt stalled without output and
was stopped; the permitted run outside the sandbox completed successfully.
Only this documentation file was added, so application-source line/style checks
and source formatting/analyzer runs are not applicable to the review change.
