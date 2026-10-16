# Rider pickup refresh and image correction — 2026-10-15

The deployed private.current_rider_deliveries function referenced
fulfillment.seller_farm_id. The live order_delivery_fulfillments schema contains
representative_order_id instead. Executing the assigned-rider response raised
PostgreSQL 42703, preventing product hydration and the refresh used when marking
pickup confirmation required. Earlier fixture-only checks did not reproduce
this because their fulfillment table incorrectly included seller_farm_id.

Corrective migration 20261015130000_fix_rider_product_image_farm_join.sql resolves
the seller farm through the actual representative order and scopes summary/image
orders to that farm and fulfillment buyer. It preserves selected/assigned rider
visibility, independent valid-session/current-rider guards, fixed search path,
existing gateway/payment wrappers, grants and storage policies. No arbitrary
image fallback or catalogue substitution for captured evidence was introduced.

The user explicitly authorized hosted deployment in this session. The original
image function and assigned-rider status endpoint were already deployed; only
the corrective migration was applied and recorded in migration history. No
unrelated pending migrations or live delivery statuses were changed.

The client now handles confirmation-substep refresh failures through the same
domain error mapping as other status updates, retaining authorization/network
classification instead of a generic failure. Same-database-status substeps check
actual assignment and current server status before updating local progress.
The delivery snackbar wraps fully, stays visible for six seconds, and closes on
request. Existing global snackbar defaults remain unchanged.

Verification:

- Reproduced 42703 on the hosted assigned response using existing riders in a
  rolled-back read-only assertion. The same check passes after deployment.
- Hosted rider_product_image_response.sql, rider_status_rpc.sql,
  authentication_boundary.sql, application_table_rls.sql,
  sql_injection_boundary.sql and existing_account_profile_isolation.sql pass.
  These cover their specific assertion scope, not all live APIs/storage paths.
- Aggregate hosted checks found 8 ordered products with 8 populated image URLs
  and 8 matching stored farmer-media objects. No customer payloads or URLs were
  printed. This verifies storage metadata, not downloads on the user's device.
- The isolated PostgreSQL harness now uses the real fulfillment columns,
  reproduces the original missing-column failure and passes the correction for
  selected/assigned access, two buyers/sellers/riders, expired requests, invalid
  sessions, absent photos and hostile URL characters remaining literal.
- 27 Flutter tests pass across pickup substep repository behavior, snackbar
  wrapping/dismissal at 320px with enlarged text, pickup design/completion,
  status RPC, response image mapping, shared thumbnails and global snackbar
  regressions. Formatting and targeted analysis pass. Changed application
  sources remain below 200 physical lines and contain no inline style definitions.

No production fixtures or delivery mutations were used. Full synthetic
account_data_isolation.sql remains a local/test-only check; local PostgreSQL
was previously unavailable. A physical-device product download and pickup
confirmation still need verification after restarting and refreshing the app.

## Completion and snackbar follow-up

The screenshot showed the fixed snackbar overlapping buttons placed inside the
Scaffold body. Actions now occupy bottomNavigationBar, with compact columns, so
Scaffold reserves footer space and places messages above it. Status substep
messages use their precise display label rather than the coarser legacy stage.

Pickup completion previously let DeliveryDataException escape to the controller's
generic fallback. The complete proof/save/status sequence now maps validation,
storage, authorization, conflict and network errors to domain failures. Existing
GPS freshness, photo and all eight checklist checks remain enforced.

The offline pickup retry uploader incorrectly looked for pickup camera files in
the delivery_proofs subdirectory. It now uses the existing validated pickup
resolver in the documents root and rejects mismatched delivery IDs/stages before
uploading. Cleanup uses the same location after successful completion.

35 focused tests pass, including actual serialized Supabase proof-save/completion
requests through HTTP fixtures, multipart offline pickup upload/cleanup, specific
server failure messages, footer/snackbar non-overlap at 320px/430px with enlarged
text, and existing pickup validations. Analysis/formatting/source checks pass;
modified application files remain at most 194 lines with no inline styles.
Hosted proof/completion definitions and proof metadata were inspected read-only;
no production pickup, photo upload or status mutation was performed. No database
changes were made in this follow-up. Physical-device completion remains pending.

## Invalid proof after completing the pickup form — 2026-10-16

The optional farmer signature button saved a `protected://` attestation after
one tap. Pickup completion submitted that placeholder to the file-proof RPC as
a signature image. The RPC requires an authenticated storage object path, so
adding this optional proof caused otherwise complete photo/checklist submissions
to fail with `Invalid delivery proof`.

The button now captures a signed receipt photo through the same private upload
or offline photo flow as product/package images. Its preview shows the captured
image. Offline resolution accepts the generated farmerSignature filename while
retaining the filename, directory and size checks. Image methods cannot create
tap attestations. Older placeholder drafts receive a specific instruction to
retake the image or remove optional proof before retrying; they are never sent
to the file-proof RPC. Non-image farmer confirmations retain their existing flow.

No queries, RPC signatures, database validation, grants, policies or navigation
boundaries changed. Mocked remote tests cover signature serialization and legacy
placeholder rejection; local tests cover offline signature resolution, storage
attestation rejection and the camera-button interaction. These tests do not
verify hosted storage access or physical-device pickup completion.
