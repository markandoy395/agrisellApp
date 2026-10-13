# Project agent instructions

## Global coding rules

### Maximum source file length

- Keep every application source file you create or modify at 200 physical lines
  or fewer, including blank lines and comments.
- This limit also applies to dedicated CSS and Flutter style files.
- SQL files, tests, generated code, dependencies, build output, configuration,
  lockfiles, documentation, and binary assets are excluded.
- Extract cohesive widgets, components, helpers, controllers, or styles when a
  source file would exceed the limit. Preserve readable formatting and useful
  comments; do not compress code to meet the limit.
- When modifying an existing oversized source file, refactor the affected file
  to meet the limit while preserving behavior. Avoid unrelated refactoring.

### No inline CSS or Flutter styling

- Do not introduce HTML style attributes, JSX inline style objects, embedded
  `<style>` blocks, or CSS embedded in application source strings.
- Put CSS in dedicated stylesheets or CSS modules and reference markup classes.
  Follow the project's existing stylesheet conventions.
- Put Flutter `TextStyle`, `BoxDecoration`, `ShapeDecoration`, `InputDecoration`,
  `ButtonStyle`, and button `styleFrom` definitions in dedicated style/theme files.
  Screens and widgets must reference those definitions.
- Keep dynamic styling in parameterized helpers in dedicated style/theme files.
- When changing existing inline styling, extract it while preserving appearance
  and behavior.

## Security requirements

These requirements apply to every new or modified page, API, database query,
RPC, realtime subscription, storage operation, and schema migration.

### Authentication and private navigation

- Private destinations are the default. Use the central guarded navigation
  factories and retain role/status authorization checks.
- Only explicitly listed authentication flows (login, signup, OTP, password
  recovery, splash, and signup receipts) may be public.
- Require a valid, non-anonymous, unexpired Supabase session for private pages.
  Cached account state alone is insufficient. Redirect signed-out users to login
  before private widgets mount.
- On logout/session loss, clear account state and private navigation/dialogs and
  prevent back navigation from reopening private content. Prevent stale data
  from surviving account switches.
- Enforce authentication and authorization on the backend as well as in the UI.
  User-facing APIs must reject unauthenticated requests without returning private
  data. APIs should return an appropriate authentication error; pages redirect.
- Machine endpoints require their explicit server credential. The notification
  webhook must reject missing/incorrect secrets and fail closed when its secret
  is unconfigured. Do not expose arbitrary notification dispatch to normal users.

### Ownership and authorization

- Resolve the current account from `auth.uid()` server-side. Never treat a
  client-supplied owner ID, role, or recipient as proof of authorization.
- Scope private reads, updates, and deletes to the current owner. Validate insert
  and upsert ownership, including conflicting record IDs and owner changes.
- Use the actual ownership column and identity mapping. Auth UUIDs and numeric
  application user/buyer/rider IDs are not interchangeable; use `QueryOwner` and
  the existing identity helpers instead of inventing `user_id` columns.
- User A must never read or mutate User B's private data. Apply owner filters to
  client queries as defense in depth and enforce the same boundary in the database.
- Shared authenticated marketplace reads and transaction participant access must
  be explicit, limited to necessary fields, and checked against the caller's
  actual participation. Existing catalogue/participant exceptions do not authorize
  access to another account's private profile, documents, wallet, or support data.
- Preserve recipient/participant checks for notifications, realtime feeds,
  conversations, deliveries, tracking, and evidence.
- Administration and service-role bypass belong only to trusted backend code.
  Never ship service-role keys or server secrets to Flutter clients or logs.

### Row-level security and database privileges

- Enable RLS on all application tables, including private-schema and partitioned
  tables. Supabase-managed/extension-owned relations are outside this requirement.
- Define explicit owner policies using the actual owner column and `auth.uid()`
  or a trusted identity helper. Check both visibility (`USING`) and writes
  (`WITH CHECK`). Use participant/shared policies only for documented workflows.
- Preserve restrictive authentication and ownership boundaries so older
  permissive policies cannot broaden private access. Unclassified tables deny
  end-user access until an explicit access contract is defined.
- Reject both the `anon` role and anonymous authenticated sessions. No application
  table is currently intentionally public to unauthenticated callers; any future
  public exception must be explicitly required and documented.
- Do not regrant anonymous application-schema, table/column, sequence, or RPC
  access. Review grants and default privileges whenever creating database objects.
- Security-definer RPCs require independent caller and ownership checks because
  they can bypass RLS. Use a fixed safe search path and schema-qualified objects,
  restrict execution grants, and return only authorized fields.
- Do not grant ordinary users `TRUNCATE`, `REFERENCES`, or `TRIGGER` privileges.
- Firebase currently provides messaging only. If a Firebase database is added,
  enforce equivalent authentication and ownership with Firebase Security Rules;
  PostgreSQL RLS does not protect Firebase data.

### Parameterized queries and SQL injection prevention

- Use structured Supabase query methods and RPC parameter maps in application
  code. Use bound parameters or static SQL variables in database functions.
- Never concatenate user input into executable SQL or raw PostgREST filter
  expressions. Do not introduce a general-purpose SQL execution RPC.
- Treat voucher codes and other exact identifiers as literal values. Do not let
  `%`, `_`, `*`, quotes, comments, or SQL fragments broaden exact matches.
- Prefer static SQL for runtime functions. If dynamic SQL is necessary, bind data
  using `EXECUTE ... USING`; strictly allowlist and quote identifiers, which cannot
  be supplied as ordinary bound values.
- Controlled migration DDL may use trusted metadata and quoted identifiers
  (`%I`, `regclass`, `regprocedure`). Request values must never become SQL command
  text, policy expressions, role lists, or function templates.

### Rate limiting and sign-in errors

- Enforce sensitive endpoint quotas on the server, including reads, writes,
  failed business requests and machine webhooks. Use persistent atomic counters;
  client cooldowns alone are insufficient. Return HTTP 429 with Retry-After when
  exhausted; fail closed if the limiter is unavailable.
- Verify caller identity before choosing an account quota. Hash identities and
  preserve caller JWTs/RLS when forwarding. Do not trust client owner IDs or
  forwarding headers, or allow direct API paths to bypass enforced quotas.
- Preserve Supabase Auth native limits for login, signup, recovery and OTP.
  Local TOML changes do not prove hosted settings changed. Document rollout and
  coverage gaps in docs/rate_limiting_audit.md; verify compatible clients before
  activating gateway enforcement.
- Distinguish configuration, authentication, profile, rate and connection errors.
  Do not label every failure as poor internet. Logs must contain only safe stages
  and short error codes, never credentials, tokens, private responses or payloads.

### Storage and secrets

- Keep application storage buckets private. Use authenticated object requests
  under storage policies; preserve owner checks for document/proof mutations.
- Attach bearer headers only to the configured Supabase origin. Do not introduce
  public or signed download URLs for private files as a substitute for authorization.
- Previously issued signed URLs and downloaded copies cannot be recalled by a
  client change; do not claim otherwise.

## Verification

- Before finishing, count physical lines of new/modified application sources,
  check for prohibited inline styling, and verify extracted style references.
  Run relevant formatting, analysis, and checks. Report remaining violations or
  platform constraints explicitly.
- For security changes, test legitimate owner access, cross-account read/update/
  delete denial, anonymous access, ownership tampering, and relevant participant
  or shared workflows. Test account switching and logout for navigation changes.
- For query changes, include hostile values and verify they remain literal bound
  data. Preserve existing results for authorized callers.
- After database changes, run applicable assertions:
  - `supabase/tests/authentication_boundary.sql`
  - `supabase/tests/application_table_rls.sql`
  - `supabase/tests/sql_injection_boundary.sql`
  - `supabase/tests/existing_account_profile_isolation.sql`
- Run `supabase/tests/account_data_isolation.sql` in a local/test database; do not
  create synthetic account fixtures in production. Use rolled-back checks that
  preserve application records when verifying the hosted database.
- Distinguish local checks, hosted database assertions, deployment, and end-to-end
  verification. Do not claim every HTTP/RPC/realtime/storage path was tested based
  only on metadata checks or a limited profile isolation test.
- Keep `.query-audit.txt` and the relevant audit documents current when changing
  query coverage or security boundaries. Consult these for existing contracts:
  - `docs/authentication_audit.md`
  - `docs/data_ownership_audit.md`
  - `docs/sql_injection_audit.md`
