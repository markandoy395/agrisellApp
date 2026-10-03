# Authentication audit — 2026-10-03

## Scope and changes

Audited the Flutter application's navigation constructors, named routes, session
lifecycle, database/storage access, Supabase migrations and configuration, and
the sole Edge Function in this repository. This repository has no separate web
admin server or custom REST server to inspect. Hosted policies and deployments
have not been read or changed.

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

## Database deployment is required

Apply `supabase/migrations/20261003120000_require_authenticated_application_access.sql`
after the preceding application migrations, using the project's established
database deployment process. Do not blindly apply other pending migrations.
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

Database assertions were not executed: this environment has no local PostgreSQL
or Docker, and hosted database credentials/state were not inspected. Deno is not
installed, so the full Edge Function runtime/type check was not run; its
authentication helper was tested directly with Node's TypeScript support.
