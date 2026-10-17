# Signup recheck and profile edit persistence — 2026-10-17

The identified persistence defects are repaired in the Flutter source. The
profile/signup database repairs and `application-api` avatar handler are deployed.
Historical missing personal information and consent still require the account
holder's actual input; the application now detects incomplete profiles at login
and routes them through the existing signup completion flow.

## Repairs

- Rider personal edits use one profile update, preserving explicit first,
  middle and last name boundaries. They no longer depend on vehicle model/color
  validation. A database trigger synchronizes the existing license document.
- Rider vehicle brand/model/color/registration details now have stored columns
  and load back correctly. One protected RPC saves details and capacity together,
  preserving vehicle ceilings and active-cargo checks. Owner IDs, employment
  status, logistics company, maximum capacity and vehicle-type changes are
  rejected. New detail writes require the quota gateway, including direct REST.
- Location cache/pending keys contain the authenticated account ID. Stale
  repositories refuse another session, and legacy values without an owner are
  discarded rather than replayed.
- Buyer photos upload through the authenticated, persistently rate-limited API.
  The API derives the Buyer identity, uploads to private `buyer-avatars` storage,
  and saves the authenticated object URL in the owner profile. Failed profile
  writes remove the new object. Client account changes prevent stale UI updates.
- Farm edits and a database trigger keep crop counts consistent. Entered farm
  size/unit are stored separately from normalized hectares. The original local
  `20260930100000` version collides with the hosted admin-permission migration;
  `20261017123000_restore_farmer_size_normalization.sql` restores the missing
  schema without rewriting that historical migration record.
- Buyer/Farmer signup retries save submitted details instead of returning early;
  Rider retries save all submitted personal/address fields. Existing account
  status, verification and role decisions remain intact. Buyer policy acceptance
  is stored at actual completion; Rider agreements are required on retry.
- Buyer/Farmer gender now survives account loading. Suspended Riders retain
  suspended status instead of being mapped to a pending account.

## Current verification

- Final complete Flutter suite: **1,426 tests passed**. The two checkout fixtures
  were updated to use account-scoped locations; the legacy-cache rejection test
  remains. Dart analysis reports no issues.
- **15 Node API tests passed**, including private avatar save/read URL,
  cross-account identity denial, anonymous denial, invalid file handling,
  persistent quotas/429/Retry-After and cleanup after failed profile writes.
  Deno type checking passed for the Edge Function.
- Hosted rollback preflight passed authentication, application-table RLS,
  SQL-injection, existing-account isolation, profile edit round trips and
  `profile_repair_contract.sql`. The repair contract covers signup retry
  read-back, status preservation, literal hostile-looking values, farm units and
  crop counts, atomic vehicle failure, owner tampering, direct gateway bypass,
  anonymous and expired sessions. It creates no synthetic accounts.
- All new/modified application sources are at most 200 physical lines. The
  prohibited inline-style scan and whitespace checks pass.
- Post-deployment assertions passed against the deployed schema and rolled back
  every test mutation. The farm-size column and unique migration version exist,
  the vehicle gateway trigger is installed, the avatar bucket is private,
  crop-count mismatches are zero, and no audit names remain in stored profiles.
  Live avatar HTTP checks returned 401 without authentication and 204 for
  preflight; no real photo or private response was requested.
  The general gateway rollout remains staged; the new vehicle and avatar paths
  always require the gateway. See `rate_limiting_audit.md` for existing gaps.

No local/test PostgreSQL instance was available, so synthetic-account
`account_data_isolation.sql` was not run against production. Live OTP/signup,
real image upload/display and edit/reload on a physical device remain unverified.
The Flutter source changes still require a rebuilt application release.

## Shipping editor lag follow-up

The supplied Android log reports `Skipped 137 frames` during keyboard activity.
A read-only check of the connected phone reported 38 janky frames out of 373
(10.19%) and 24 slow UI-thread events. These are app-wide session statistics,
not a shipping-editor trace or a timing measurement of the repaired build.
The log does not establish the exact cause of the stall or a database failure.

The shared address autocomplete previously constructed dropdown entries for the
entire loaded catalogue on every rebuild. Its controller listener also reported
cursor/composing-only notifications as edits, rebuilding the shipping form.
The source now constructs at most 20 matching suggestions while searching the
full catalogue, and only changed text notifies the parent. Selecting a province
still filters municipalities, manual input remains supported, and reopening a
selected field can show other choices.

Eleven targeted tests passed across the large-catalogue, existing PSGC selection,
shipping GPS/save and floating-label suites. The new tests search and select the
last item in a catalogue of 1,800 options and verify that cursor/composing changes
do not trigger parent edit callbacks. Source formatting, line count and inline
style checks and targeted Dart analysis pass. This follow-up does not rerun the
earlier complete suite.
Improvement on the phone still requires running the updated build and measuring
the same shipping interaction again, preferably in profile mode.

## Findings at initial audit (before the repairs above)

| Priority | Flow | Finding and evidence |
| --- | --- | --- |
| High | Rider profile | `rider_registration_service_profile_updater.dart` writes the Rider row, then calls `updateVehicle`. Loaded embedded vehicles have empty model/color, but `RiderEntityValidator.vehicle` requires both. A local loaded-vehicle probe reproduces validation failure. Profile data can commit before the overall save reports failure and skips reload. |
| High | Rider vehicle | Editor collects brand/model/color/registration number; `SupabaseRiderDataSource.updateVehicle` ignores them, forwarding only type/plate and capacity. Reload constructs empty/null detail fields. Mock update/reload reproduces loss. Hosted schema has no `rider_vehicles` table or corresponding Rider detail columns. |
| High | Rider names | Coordinator combines first/last names, then `RiderProfile.copyWith` splits at the first word. Probe: first `Ana Maria` + last `De la Cruz` becomes first `Ana` + last `Maria De la Cruz`. Other edits can also rebuild full name without the stored middle name. |
| High | Shared location cache | `ConfirmedLocationRepository` uses role-only cache/pending keys with no account ID. Account cleanup does not remove them; selector restore loads the cache and calls `syncPending`. Two fake remote account contexts sharing device preferences reproduce exposing the earlier address and replaying its pending write into the second context. This was not a live account overwrite. Server owner checks cannot identify the earlier account as the cached values' source. |
| Medium | Buyer avatar | `_pickAvatarImage` changes `_avatarImageBytes` and reports success, but performs no storage upload or `users.profile_photo_url` update. Selection is screen-only state. |
| Medium | Farm crops | `FarmEditDraft.toDatabase` changes `main_crops` without `total_crops`; no hosted farm trigger synchronizes it. One hosted farm has a count different from `cardinality(main_crops)`. The audit cannot identify the historical cause. |
| Medium | Farm size | Local migration `20260930100000_store_farmer_farm_size_and_unit.sql` adds entered `farm_size` and normalization. Hosted database lacks that column, function and trigger. Hosted signup stores the entered number in `farm_size_hectares` plus its unit, while editing labels the number as hectares. Square-metre signups can be misinterpreted. No hosted row had unit `sq m` at audit time. No migration was deployed. |

## Field trace

| Edit | Save/read-back path | Coverage |
| --- | --- | --- |
| Buyer identity | Edit card → `UserProfileService` → owner-filtered `users` update/select | First/last name, extension, normalized phone, birth date; email read-only |
| Farmer identity | Edit card → `UserProfileService` → `farmers.auth_user_id` update/select | First/last name, suffix, normalized phone, birth date; email read-only |
| Buyer shipping | Shipping editor → saver → `set_current_buyer_shipping_address_location` | Literal full address/GPS bound; server derives Buyer identity |
| Farmer farm | Farm editor → draft → farm ID + owner ID filtered update/select | Name/address/GPS/hectares/type/irrigation/crops; count and unit gaps above |
| Rider personal | Editor → coordinator → repository → owner-filtered update | Editable identity/address/license/GPS mapped, but name and later validation defects above |
| Rider capacity | Capacity editor → `set_current_rider_capacity` | Hosted RPC checks non-anonymous unexpired JWT, gateway, capacity ceiling and active cargo; no live capacity write tested |

Buyer/Farmer gender is omitted from account loading and explicitly empty in
`currentAuthenticatedUserProfile`. It is not offered in these edit forms; this
hides stored values without clearing their database column. Farmer middle name,
personal address, experience, tenure and image edits are also absent from its
personal editor. Farm edit selection omits unit/tenure/images from its returned
model, although its update does not explicitly overwrite those database columns.
Profile, document/vehicle writes, uploads and reloads are separate operations.

## Signup recheck

Repeated hosted aggregate audit: **counts unchanged**. Buyer phone/birth
date/shipping missing in 3/4 profiles, gender in 4/4; two Farmer profiles lack a
farm; one of two Rider profiles lacks several personal/address fields. One staged
Auth account already has a Buyer profile. Fresh deployed definitions retain the
existing-profile early returns in `signup_persistence_audit.md`. No repair was
applied. These records cannot establish or reconstruct original missing inputs.

## Initial audit verification and limits (historical)

- **53 local tests passed across 16 files**: signup contracts, profile/vehicle
  capacity, farm edits/ownership, shipping and confirmed locations. New diagnostic
  tests intentionally reproduce the defects; passing does not mean they are fixed.
- Transport tests check exact literal JSON for quoted/wildcard/comment-like
  values. Local Rider signed-out/cross-account requests issue no update.
- `profile_edit_metadata_audit.sql` ran read-only on the linked database. All six
  reviewed application tables have RLS with restrictive login/owner write
  boundaries. Relevant public edit RPCs deny `anon` execution. Shared farm
  catalogue reads retain their separate access contract.
- `existing_profile_edit_roundtrip.sql` passed for two existing accounts per
  role: owner first-name writes/read-back using hostile-looking literal text;
  bidirectional cross-account profile read/update/delete denial; anonymous
  authenticated profile read denial. Numeric Buyer/Farmer IDs and UUID Rider
  IDs are separate. **All temporary edits rolled back.** This does not cover
  every edit field, farm/document writes, uploads, HTTP or UI account switching.
- Hosted authentication, application-table RLS and SQL injection assertions
  passed. Metadata checks do not establish every RPC/storage/realtime path.
- New test formatting, Dart analysis and whitespace checks pass. No application
  sources/styles changed; tests, SQL and docs are exempt from the source line
  limit. No source/style violations were introduced.
- No local/test database was available; synthetic fixtures and
  `account_data_isolation.sql` were not run in production. Fresh OTP/signup,
  edit/reload, upload, failure/retry and account-switching device checks remain.

Priority repairs are account-scoped location cache/pending sync, coherent Rider
profile/vehicle writes, explicit name components, persistent avatar uploads,
crop-count synchronization and reviewed farm-size migration deployment. Missing
historical data and consent dates require actual account-holder input.

## Buyer avatar display repair - 2026-10-17

The buyer header now passes the saved UserProfile.avatarUrl to BuyerHeroAvatar.
Selected image bytes take priority; saved photos use authenticatedNetworkImage,
which normalizes project storage URLs and attaches credentials only to the
configured Supabase origin. Missing or failed images show the avatar placeholder.
Existing private bucket policies, session guards and edit-only controls remain.
Local widget tests cover persisted URL rendering, authenticated path normalization
and failed-download fallback. Hosted downloads and device reload/account switching
were not verified by this UI change.

