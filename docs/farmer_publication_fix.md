# Farmer publication fixes — 2026-10-20

The three findings in `farmer_signup_to_publish_review.md` are addressed by the
application changes and the applied migration
`20261020100000_secure_atomic_farmer_publication.sql`.

## Approval and ownership

Restrictive insert policies require the caller to own an active, verified farmer
and the requested farm, regardless of older permissive insert policies. Existing
administrator paths remain. Product image insertion/replacement and the internal
stock mutation also require approval. Signup/profile images remain available before
approval. RLS, existing table grants, and private buckets remain enabled.

## Atomic publication and retry behavior

The protected `publish_current_farmer_product` RPC independently validates the
session, gateway, farmer status, and farm ownership. It resolves/creates the
category, inserts the product, adds the first dated stock batch, and writes an
owner-scoped retry receipt in one transaction. A rejected stock operation rolls
everything back. A repeated request returns the same product; a changed request
with the same key is rejected. Data values use static SQL parameters throughout.

The form generates one request key, stays open on failure, and blocks duplicate
submissions while saving. It closes after a confirmed success. The photo path uses
the account, request key, and image-content hash, so retries reuse an upload and
edited photos cannot overwrite an already-committed attempt. Definite database
rejections remove an upload only after checking it is unreferenced. If a response
is lost, the image is retained so a retry cannot break a committed publication.
Abandoned ambiguous attempts can therefore leave an unreferenced private image;
automatic deletion is intentionally avoided when commit status is unknown.

## Fresh approval status

The dashboard uses newly loaded verification details rather than keeping its
posting gate tied to the sign-in snapshot. It subscribes to the caller's farmer
updates and polls every 30 seconds as a fallback. Loads carry account/generation
guards; responses arriving after logout or disposal are discarded. The timer and
subscription are disposed with the dashboard. Verification reads use the protected
gateway. Existing cached status is used only until details have been loaded.

## Verification

- All 55 selected Flutter regression tests passed. The final Dart analyzer found
  no issues in the affected product, dashboard, verification, and new test code.
  Formatting, the 200-line source limit, and inline-style checks passed.
- Local PostgreSQL tests execute the production migration and stock function with
  isolated accounts: rollback, same-key retry, changed payload rejection, farm
  tampering, cross-account access, pending approval, storage restrictions,
  revoked approval, anonymous/expired sessions, gateway denial, receipt privacy,
  and literal hostile strings.
- Flutter regressions cover draft preservation, duplicate taps, stable request
  keys after failure, ambiguous responses, safe upload cleanup, approval/revocation
  refresh, and a late approval response after logout.
- The migration was validated with a hosted rollback before application.
  `farmer_publication_contract.sql` and the four required database boundary
  assertions passed after application. No sample accounts or products were added
  to the connected database for these checks.
- Device email OTP, gallery/camera uploads, realtime delivery timing, and a full
  live signup/approval/publication session still require device verification.
  The Flutter changes require an updated app build; the database fix is applied.

## Follow-up retest — 2026-10-20

The full Flutter suite completed with 1,490 passes and two failures in
`test/widget_test.dart`. Both tests still expected a Settings button on the
default buyer Account screen, although its redesign explicitly hides that button.
The default-screen test now follows Personal information → Display → Edit and
the visible Log Out action. The optional settings-panel test explicitly enables
`ProfileScreen(showSettingsIcon: true)`. Existing edit validation, persistence,
cancel, and logout assertions remain. The logout test centers its target above
the bottom navigation before tapping.

All 16 tests across the corrected file, buyer account redesign, and profile header
tests passed on rerun. The full suite was not repeated after these test-only
changes; no application code or database records changed during this retest.

The full-project Dart analyzer reported no issues. Analysis and formatting of
the corrected test also passed. All 12 modified application sources passed the
200-line, inline-style, and formatting checks. The local publication SQL behavior
harness and all 11 API gateway tests passed. The hosted publication contract and
the authentication, table RLS, SQL-injection, and existing-profile isolation
assertions passed again. These hosted checks added no sample records. The device
verification limits above still apply.
