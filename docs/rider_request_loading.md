# Rider request loading correction — October 13, 2026

The fulfillment delivery RPC constructs location objects whose pickup/dropoff
coordinates can be null. `DeliveryBundle.fromJson` previously applied the strict
normalized-location parser to those objects. One missing pin therefore threw a
`FormatException` and made the whole requests list show a loading error; Retry
repeated the same parsing failure.

RPC bundles now retain addresses with nullable coordinates. The normalized
location parser still requires coordinates by default and rejects malformed
supplied numbers. Missing coordinates remain null, never fabricated as zero.
Existing matching, routing, arrival, pickup, and proof validation still apply.
No query, RPC, database policy, or eligibility boundary changed.

Loading errors distinguish authentication, authorization, offline, timeout,
and unreadable data. Debug diagnostics contain only a stage and a short
allowlisted server code, such as `[rider.requests] load failed (42501)`;
server responses and private delivery fields are not logged. Missing/expired
JWT errors are classified as authentication failures. Denials never trigger
fallback table reads.

Local verification: 45 tests passed, including mixed complete/incomplete request
responses, Retry recovery, malformed coordinate rejection, 401/403 denial,
private-error redaction, matching, routing, arrival, and pickup validation.
These are mocked service and local domain/controller checks. The reported
device account and hosted RPC response were not inspected; a hosted failure
can have a different cause. If the updated app still fails, capture its exact
message and the short `[rider.requests]` diagnostic to identify that cause.

## Confirmed hosted error 42703 — October 13, 2026

The follow-up device log reported `42703` (undefined column). Read-only hosted
inspection confirmed `private.api_impl_current_rider_nearby_deliveries` still
referenced `rider.service_radius_km`, absent from the deployed riders table.
The nearby-farms RPC had already been corrected for the same schema change.

`20261013100000_fix_rider_requests_radius.sql` now uses the existing radius
parameter clamped to 0.5–100 km. Existing rider lookup, selected-request
visibility, assignment retention, distance sorting, and limit bounds remain.
The privileged implementation explicitly rejects missing, anonymous, and
expired sessions. No application records, table policies, or public RPC
signatures change. All values remain bound data and no dynamic SQL is added.

The migration was applied directly to the linked hosted database via `db query`.
It remains in migrations for fresh databases and subsequent migration rollout;
direct SQL application does not register a CLI migration-history entry.
The isolated PGlite harness reproduces the original 42703 and verifies corrected
loading, distance/limit bounds, assigned jobs without pins, two-rider isolation,
invalid sessions, anonymous-role denial, and hostile text preservation. Its
participant source is a scoped fixture stub, not the full production schema.
Hosted `rider_request_loading.sql` passed with existing rider identities and
returns only pass/fail. Device UI verification remains outstanding.

After deployment, hosted `authentication_boundary.sql`,
`application_table_rls.sql`, `sql_injection_boundary.sql`, and
`existing_account_profile_isolation.sql` all passed. The full local
`account_data_isolation.sql` could not run because the local PostgreSQL instance
was unreachable; it was not redirected to production. No Flutter application
sources changed in this database correction, so source-length/style extraction
and Dart formatting/analyzer checks are not applicable to this change. The new
JavaScript test harness is 89 lines; SQL and documentation are excluded from
the application-source limit. Whitespace verification passed.
