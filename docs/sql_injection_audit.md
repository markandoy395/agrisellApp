# Database query parameterization audit - 2026-10-04

The app's Flutter database calls and notification Edge Function use Supabase's
structured table/filter methods and RPC parameter objects. No application SQL
string is constructed from user input. The inventory is `.query-audit.txt`.
There is no separate ORM, raw PostgreSQL driver, SQLite database, or Firestore
database in the application to convert.

The audit covered client filters, RPC names/arguments, database function bodies,
migration dynamic SQL, and the deployed public/private function definitions.
Static SQL and PL/pgSQL queries use parameters/variables as values; concatenating
a search pattern or message value inside a static statement does not turn that
value into executable SQL. Runtime SQL construction was found only in the rider
dashboard, and it already bound its rider ID through `EXECUTE ... USING`.

The refactor makes runtime query behavior stricter:

- Rider dashboard earnings use static SQL against `public.delivery_payments`.
  Its existing caller-derived rider ID and result fields are preserved. The
  historical compatibility table choice and dynamic execution are removed.
- Voucher lookup uses `current_checkout_voucher(p_code)` with a JSON RPC argument
  and static case-insensitive equality. `%`, `_`, `*`, quotes, comments, and SQL
  fragments remain literal code text. They cannot expand the match or execute.
  Missing, disabled, or ambiguous duplicate codes return no voucher.
- The public voucher wrapper invokes a private implementation with a fixed
  schema and query. It rejects missing/anonymous callers and returns only the
  published enabled campaign fields needed by checkout. Existing RPC-only
  catalogue access is preserved without granting direct table access.

Schema migration SQL still uses controlled dynamic DDL. Table/column identifiers
are quoted with `%I` or come from PostgreSQL `regclass`/`regprocedure` objects.
Policy bodies, role lists, and wrapper templates come from fixed migration
definitions or database metadata, never request values. Historical applied
migrations are preserved; the new migration changes the current implementation.

PostgreSQL documents both [automatic parameter substitution in static PL/pgSQL
and parameter binding with EXECUTE USING](https://www.postgresql.org/docs/17/plpgsql-statements.html).
Identifiers cannot be bound as ordinary values; identifier quoting remains
appropriate for controlled schema migrations.

## Verification

- All 8 Flutter lookup and existing deals/voucher regressions passed. Mock HTTP
  tests inspect actual request bodies for SQL fragments and punctuation and
  verify they remain one literal RPC argument, with no raw filter expression.
- Targeted Dart analysis found no issues. Formatting and whitespace checks
  passed. The two application sources are 16 and 169 physical lines and contain
  no prohibited inline styling.
- A hosted rolled-back preflight compared the old/new dashboard JSON for an
  existing rider in the same transaction and found identical output.
- `supabase/tests/sql_injection_boundary.sql` compares hostile voucher values to
  static literal equality, checks an ordinary existing code when available,
  rejects anonymous access, and asserts application runtime functions have no
  dynamic `EXECUTE` statements. It does not change application records.
- The migration deployed successfully to the linked hosted database. The
  injection test and the existing authentication and application-table RLS
  assertions all passed after deployment. Docker was unavailable for the CLI's
  optional local catalog cache; remote deployment and checks completed.

The database change is `20261003133000_parameterize_runtime_database_queries.sql`,
after the previous ownership/support repair migrations. The updated client
requires its new voucher RPC. Run the injection check and the existing
authentication/RLS assertions after deploying or changing database functions.
Keep future user data in structured SDK arguments or SQL parameters; never add
a general-purpose SQL execution RPC or concatenate input into command text.

## Gateway update â€” 2026-10-05

The counter helper uses a structured RPC parameter map. The gateway preserves
HTTP bodies/query parameters and caller JWTs, adding no SQL execution interface.
The new pre-request function uses static SQL and fixed schema names. Hosted
injection assertions passed after deployment. See [the staged rollout audit](rate_limiting_audit.md).

## Rider capacity setup — 2026-10-13 (deployment pending)

set_current_rider_capacity uses a Supabase numeric parameter map and static SQL;
hostile text cannot become executable commands. The migration patches a trusted
regprocedure definition with fixed literals, never request data. Local PGlite
checks reject hostile numeric input and preserve ownership. See
rider_capacity_batching.md; hosted post-change assertions have not run.

The pending cargo-weight aggregation uses fixed joins and static bound variables.
Unknown units remain unknown instead of being interpreted as weight or SQL.
No new public query path is added; see rider_capacity_batching.md.

The pending rider status RPC uses the existing parameter map and static SQL.
Hostile remarks remain literal data in isolated PostgreSQL/client tests. There
is no dynamic SQL or general query interface. See rider_status_rpc.md.

Rider earnings (2026-10-13): pending migration 20261013130000 augments existing current_rider_deliveries with caller-assigned payment snapshots, verifies authenticated/non-anonymous/unexpired session and gateway, and records agreed fees only through a server completion trigger. No client identity, dynamic SQL, new public endpoint, anonymous grant, or ordinary-user payment mutation. See docs/rider_earnings.md for isolated verification and outstanding hosted rollout/full-schema assertions.

Rider payment flow (2026-10-15, deployment pending): owner-scoped current_rider_wallet and submit_rider_payout_request use independent session/gateway guards, server method snapshots, account locks and private default-deny delivery allocations. Direct payout inserts and legacy rider submission are revoked; admin payment transitions require service-role backend access and completed transfer references. All parameters are bound/static SQL. See docs/rider_payment_flow.md for accounting, verification and rollout limits.

Rider pickup product image (2026-10-15, deployment pending): migration 20261015120000_include_rider_product_images.sql preserves existing selected/assigned delivery visibility and gateway/payment wrappers; private implementation independently rejects missing/anonymous/expired sessions and missing rider identity. Image is selected from actual ordered commodities scoped to fulfillment buyer and seller farm. No new endpoint, grants, tables or storage policy changes. Client maps the existing response field and retains authenticated storage requests. Isolated PostgreSQL access/missing-image/literal-URL tests pass; full-schema assertions and hosted/device verification remain pending. See docs/performance_optimization.md, Pickup product image correction.

2026-10-15 rider pickup/image hosted correction (deployed with explicit user approval): live private.current_rider_deliveries raised 42703 because fulfillment.seller_farm_id does not exist. Migration 20261015130000 fixes the join using representative_order_id -> orders.seller_farm_id, with buyer/farm scoping and unchanged selected/assigned visibility, session guards, fixed search path, grants, gateway/payment wrappers and storage policies. The existing status RPC was present and left unchanged. Hosted rolled-back response, status, authentication, RLS, SQL injection and existing-account isolation assertions pass. Isolated harness now reproduces the original error with actual schema columns and verifies buyer/seller/rider isolation. 27 Flutter tests pass for image/confirmation/snackbar behavior; actual device downloads and delivery mutations remain unverified. Supersedes earlier pending-image-deployment notes. See docs/rider_pickup_refresh_fix.md.

2026-10-16 shared chat limits (prepared, not deployed): buyer/farmer/rider message mutations use shared ChatRpc through application-api with caller JWT and bound parameters. New gateway attempt quotas are persistent and fail closed; SQL insert triggers independently validate sessions, participants, Unicode length and successful-write quotas with required gateway marker. No anonymous grants or client identity trust added. Limits: 500 code points/message, 10 attempts/account/conversation/minute, 100/account/24h, 5 new marketplace conversations/account/24h plus 30 start attempts. Existing rider threads remain assignment-derived. See docs/shared_chat_limits.md for local tests, compatibility constraints and outstanding hosted/device/security assertions.

2026-10-16 buyer catalog redesign: new AllProductsScreen uses guarded navigation plus central buyer role/status checks; quick-add independently checks valid session and buyer authorization. Existing catalog pagination/RPCs and basket sync remain unchanged, with bound parameters and no new backend access contracts. Production product imagery stays dynamic through the existing authenticated image loader. See docs/buyer_catalog_design.md for verification scope and Figma reference boundaries; no hosted data/security mutations were made.

2026-10-16 concurrency hardening (prepared, not deployed): owner-scoped retry receipts for buyer/farmer messages and farmer cash-out, independent session/participant/farmer checks, transaction advisory locks, default-deny private receipt RLS, bound/static SQL and caller JWT gateway transport. Shared order queues/cache writes reject account changes; stale callbacks and duplicate submissions are guarded across buyer/farmer/rider/shared flows. Consolidated order bundle retains existing owner RPCs and only falls back when missing. See docs/concurrency_hardening.md for exact scope, isolated fixture verification and outstanding full-schema/hosted/load checks.

