# Authentication audit — 2026-10-03

## Scope and changes

Audited the Flutter application's navigation constructors, named routes, session
lifecycle, database/storage access, Supabase migrations and configuration, and
the sole Edge Function in this repository. This repository has no separate web
admin server or custom REST server to inspect. Hosted policies and deployments
were subsequently inspected and the authentication/ownership migrations were
deployed during the account ownership audit. Hosted authentication assertions
passed; see `docs/data_ownership_audit.md` for deployment details.

- Both navigation factories guard every destination. Only the explicitly listed
  login, signup, OTP, password recovery, splash, and signup receipt screens are
  public. Newly added destinations default to private. The regression test rejects
  raw route constructors in feature code, except the two central login redirects.
- Named buyer/farmer routes retain their role gates. Role gates now observe
  session changes and redirect signed-out users to login before private widgets
  mount. An authenticated user still needs the existing role/status authorization.
- Session validation requires a matching, non-anonymous, unexpired Supabase
  session, rather than trusting the cached account alone. Local authentication is
  available only through the existing explicit testing mode.
- Sign-out events clear account state. The root navigation scope removes all
  pages and dialogs on session loss and clears image caches. It checks token
  expiry every second; remote revocation is detected when Supabase reports it or
  the backend rejects the token.
- Storage image requests use the project's authenticated object endpoint and
  bearer headers. Headers are never attached to another origin. Existing stored
  public/signed URLs are converted when rendering. Client document/photo/proof
  loaders no longer mint signed download links.
- `send-notification` is a database webhook, not a user-facing endpoint. It
  requires the server-only webhook secret and rejects missing/blank configuration.
  `verify_jwt = false` is intentional for this authenticated machine caller.
  Normal users must not be allowed to send arbitrary notification payloads.

## Database deployment and verification

`supabase/migrations/20261003120000_require_authenticated_application_access.sql`
has been applied to the hosted database, followed by the support repair and
ownership/RLS migrations. The hosted `authentication_boundary.sql` check passed.
Deploy the updated `send-notification` function with its existing secret.

The migration denies `anon` and `PUBLIC` application-schema usage, table/column
and sequence privileges, and RPC execution in `public` and `private`; enables RLS
on application tables; makes storage buckets private; and adds restrictive
authentication policies for storage. Existing authenticated function execution
and service-role function execution are preserved, including existing denials.
Marketplace photo reads are permitted for authenticated users, while farmer
verification files retain their existing owner policies.

Future-object defaults are tightened for creator roles the migration runner can
act as. Application-schema usage is denied to anonymous callers regardless of
those creator defaults. Future migrations must not regrant anonymous schema access
or make storage buckets public. Auth endpoints remain available for login,
signup, email verification, and password recovery.

After deployment, run `supabase/tests/authentication_boundary.sql` against that
database as the migration owner. It raises if anonymous schema/table/column/RPC
privileges, missing public-table RLS, public buckets, or the missing restrictive
storage policy are found. The verification transaction rolls back.

Also verify HTTP behavior with a publishable key and no user bearer token:

1. REST table reads/writes and marketplace/private RPC calls must return errors
   without application data. Test both no Authorization and an anon-key bearer.
2. GraphQL queries for application data must not return application rows; GraphQL
   still relies on the same underlying object privileges.
3. Public storage URLs must fail after buckets become private. Authenticated
   image requests must succeed only under their object policies.
4. Notification POSTs with no/wrong webhook secret must return 401. A valid
   server-secret request should preserve the notification dispatch flow.
5. Test buyer, farmer, and rider login, direct route entry, logout with an open
   dialog, back navigation, remembered-session restoration, signup, and recovery.

Previously issued signed download URLs are bearer capabilities and may remain
usable until their expiry; this change stops issuing new ones in the app. Cached
files or copies already downloaded cannot be recalled. No live guarantee is
possible until the migration/function changes and HTTP checks are completed.

Supabase references: [API grants and RLS](https://supabase.com/docs/guides/api/securing-your-api),
[private buckets](https://supabase.com/docs/guides/storage/buckets/fundamentals),
and [authenticated downloads](https://supabase.com/docs/guides/storage/serving/downloads).

## Local verification

Flutter analysis reported no issues. Authentication-boundary, role-gate, session,
account-switching, role-selection/signup, recovery, home-navigation, basket-seller,
farmer-dashboard/product-navigation, sale-products, and delivery-evidence tests
passed. The farmer navigation fixture now signs in as a verified farmer.
The two webhook-secret regression tests passed under Node 24.

All 36 application source files touched by this audit are at most 200 physical
lines and have no inline CSS or prohibited Flutter style definitions. Dart
formatting and whitespace checks passed for the audit's files. Existing unrelated
working-tree edits were preserved.

Database assertions subsequently passed through the linked Supabase query API;
this environment has no local PostgreSQL or Docker. Deno was unavailable during
the original audit, so its authentication helper was tested with Node. Both
current Edge Function entry points were checked with Deno through npm on 2026-10-05.

## Rate limiting and login diagnostics — 2026-10-05

See [the rate-limit audit](rate_limiting_audit.md) for deployment, compatibility
mode, coverage gaps and verification. Full hosted sign-in profile queries passed
without changing account records. Updated Android messages distinguish backend
and profile failures from connection failures; the reported login issue still
needs device reproduction before the underlying cause can be confirmed.

## Account selection and login handoff — 2026-10-13

Switching now removes outgoing private routes before restoring the selected
session in the public login flow. The selected email stays attached to that
form when the Supabase identity changes or restoration fails. The navigation
scope preserves this explicitly named login route during a handoff; private
page gates still require a valid matching session. Logout opens the same public
flow with the active email and disables sign-in until logout completes. Add
account starts with an empty identifier. Switching updates the remembered email.

Order history loads after activation without holding up login navigation. Its
generation checks discard obsolete loads, and the cache repository checks the
current owner before fetching, caching, or falling back to an account snapshot.
The auth listener clears outgoing private state when the backend identity
changes. No RLS, RPC, or hosted configuration changes are involved.

Local regression coverage includes remembered email selection, public login
preservation during session loss, logout/back navigation, delayed or failed
order loading, and cancellation of queued loads after logout/switching. Device
sign-in and refresh-token rotation remain to be verified with real accounts.

## Rider Requests RPC repair — 2026-10-13

The deployed nearby-deliveries implementation referenced a removed radius column.
The targeted repair preserves its public signature and existing rider identity
mapping while explicitly requiring a non-anonymous JWT with an unexpired `exp`
before privileged reads. No anonymous execution grants were added. Local
PostgreSQL tests and the hosted existing-rider smoke test verify anonymous and
expired-session rejection. See `docs/rider_request_loading.md` for rollout scope.

## Rider capacity setup � 2026-10-13 (deployment pending)

The prepared set_current_rider_capacity numeric RPC independently requires a
non-anonymous unexpired caller, resolves private.current_rider_id server-side,
checks the existing API gateway hook and returns only capacity metadata. Private
helpers are not executable by end users. Trigger defaults preserve table RLS;
trusted count/ceiling columns remain read-only. Local checks passed; no hosted
migration was applied. See docs/rider_capacity_batching.md for approval and tests.

## Rider home capacity navigation � 2026-10-13

The Home setup CTA uses agrisellPageRoute/AuthPageGate for the existing private
Vehicle details destination. Capacity status is an operational eligibility rule,
not a new authentication role. No public navigation exception or account-ID
parameter was introduced. Backend migration deployment remains pending; see
rider_capacity_batching.md for the independent RPC authorization checks.

## Rider status update RPC � 2026-10-13 (deployment pending)

Flutter previously called the revoked generic update_delivery_status. The new
update_current_rider_delivery_status independently rejects missing, anonymous
and expired sessions, resolves the current rider and checks actual assignment,
then calls the existing private transition implementation. Legacy grants remain
denied. Isolated owner/cross-rider and transition tests passed; hosted deployment
and post-change assertions remain pending. See rider_status_rpc.md.

Rider earnings (2026-10-13): pending migration 20261013130000 augments existing current_rider_deliveries with caller-assigned payment snapshots, verifies authenticated/non-anonymous/unexpired session and gateway, and records agreed fees only through a server completion trigger. No client identity, dynamic SQL, new public endpoint, anonymous grant, or ordinary-user payment mutation. See docs/rider_earnings.md for isolated verification and outstanding hosted rollout/full-schema assertions.

## Startup performance (2026-10-15)

Optional Firebase and font preference initialization no longer block the first screen. Session restoration, profile validation and role/status gates remain required for private navigation. Catalogue snapshots require a matching valid non-anonymous Supabase session and clear on account-state reset. No optimistic cached-account authorization was added. See docs/startup_performance.md.

Rider pickup product image (2026-10-15, deployment pending): migration 20261015120000_include_rider_product_images.sql preserves existing selected/assigned delivery visibility and gateway/payment wrappers; private implementation independently rejects missing/anonymous/expired sessions and missing rider identity. Image is selected from actual ordered commodities scoped to fulfillment buyer and seller farm. No new endpoint, grants, tables or storage policy changes. Client maps the existing response field and retains authenticated storage requests. Isolated PostgreSQL access/missing-image/literal-URL tests pass; full-schema assertions and hosted/device verification remain pending. See docs/performance_optimization.md, Pickup product image correction.

2026-10-15 rider pickup/image hosted correction (deployed with explicit user approval): live private.current_rider_deliveries raised 42703 because fulfillment.seller_farm_id does not exist. Migration 20261015130000 fixes the join using representative_order_id -> orders.seller_farm_id, with buyer/farm scoping and unchanged selected/assigned visibility, session guards, fixed search path, grants, gateway/payment wrappers and storage policies. The existing status RPC was present and left unchanged. Hosted rolled-back response, status, authentication, RLS, SQL injection and existing-account isolation assertions pass. Isolated harness now reproduces the original error with actual schema columns and verifies buyer/seller/rider isolation. 27 Flutter tests pass for image/confirmation/snackbar behavior; actual device downloads and delivery mutations remain unverified. Supersedes earlier pending-image-deployment notes. See docs/rider_pickup_refresh_fix.md.

2026-10-16 shared chat limits (prepared, not deployed): buyer/farmer/rider message mutations use shared ChatRpc through application-api with caller JWT and bound parameters. New gateway attempt quotas are persistent and fail closed; SQL insert triggers independently validate sessions, participants, Unicode length and successful-write quotas with required gateway marker. No anonymous grants or client identity trust added. Limits: 500 code points/message, 10 attempts/account/conversation/minute, 100/account/24h, 5 new marketplace conversations/account/24h plus 30 start attempts. Existing rider threads remain assignment-derived. See docs/shared_chat_limits.md for local tests, compatibility constraints and outstanding hosted/device/security assertions.

2026-10-16 buyer catalog redesign: new AllProductsScreen uses guarded navigation plus central buyer role/status checks; quick-add independently checks valid session and buyer authorization. Existing catalog pagination/RPCs and basket sync remain unchanged, with bound parameters and no new backend access contracts. Production product imagery stays dynamic through the existing authenticated image loader. See docs/buyer_catalog_design.md for verification scope and Figma reference boundaries; no hosted data/security mutations were made.

2026-10-16 signup OTP continuation: shared verification now rejects overlapping requests and dismisses only its own active OTP route. Buyer/farmer/rider local continuation tests pass without completing application login early. Pending-profile/requested-role validation and session-loss/private-route guards remain unchanged. Local fixture verification rejects configured Supabase backends. No query/schema/hosted changes; device OTP confirmation remains outstanding. See docs/signup_otp_continuation_fix.md.

2026-10-16 concurrency hardening (prepared, not deployed): owner-scoped retry receipts for buyer/farmer messages and farmer cash-out, independent session/participant/farmer checks, transaction advisory locks, default-deny private receipt RLS, bound/static SQL and caller JWT gateway transport. Shared order queues/cache writes reject account changes; stale callbacks and duplicate submissions are guarded across buyer/farmer/rider/shared flows. Consolidated order bundle retains existing owner RPCs and only falls back when missing. See docs/concurrency_hardening.md for exact scope, isolated fixture verification and outstanding full-schema/hosted/load checks.


Profile persistence repair (2026-10-17): account completeness is derived from the
server-mapped owner by a fixed-path boolean RPC requiring a non-anonymous,
unexpired session. Incomplete active/pending accounts resume existing signup;
role/status checks remain. Suspended Rider status is preserved. Location pending
writes are account-scoped and stale sessions are rejected. See
`profile_edit_persistence_audit.md` for rolled-back hosted and local verification.


2026-10-17: Safe login-stage diagnostics and mocked login/recovery contract tests were added. The same-email login failure followed by same_password still needs device reproduction. See docs/login_recovery_investigation.md. No query or authorization boundary changes.



2026-10-18 rider signup Continue: session-loss cleanup retains already allowlisted public auth pages through the installed navigator observer while removing private routes and unknown dialogs. Private/unknown current pages still reset to login. No new public destinations or backend changes. See docs/rider_signup_continue_navigation.md for local coverage and device-verification limits.

2026-10-19: Rider sample-data testing exposed stale rider verification columns. The verification-details RPC now resolves private.current_rider_id(), returns only caller-owned documents and review actions, requires the existing profile-session and gateway guards, and maps employment status as the app already does. No new public destination or anonymous grant. See docs/mock_rider_testing.md and supabase/tests/rider_verification_identity.sql.


2026-10-19: Nearby rider deliveries exclude completed/cancelled/failed rows before applying the existing response limit. Owner checks, session guards, distance filters, and RPC grants are unchanged. History remains on current_rider_deliveries. Mock-only load fixtures add active deliveries and fresh assignment requests; see docs/mock_rider_testing.md and supabase/tests/rider_nearby_active_requests.sql.

