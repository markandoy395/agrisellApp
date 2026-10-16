# Performance and install size

## Implemented

- Buyer/farmer and rider notification feeds use lazy sliver builders, retaining
  date grouping and card actions without creating every card on each rebuild.
  Feed transitions are keyed by filter rather than concatenating every item ID;
  incoming updates no longer cross-fade two copies of the entire feed.
- Image and catalogue loading shimmers stop their controllers when reduced
  motion is enabled or their subtree's TickerMode is disabled, then resume when
  enabled. Controllers are still disposed when removed.
- These changes have widget regression coverage in
  `test/notification_memory_performance_test.dart`. Actual RSS, heap retention,
  and frame-time improvements require profiling on a physical device.

- Standard Flutter Material Icons replace the manually maintained 1,645,184-byte
  font reference. Release builds explicitly request icon tree shaking. The prior
  custom font could also be subsetted; this configuration cleanup alone does not
  establish additional release size savings.
- Network placeholders use frame readiness instead of download progress events.
  The existing authenticated image requests and bounded in-memory cache remain.
- Images with one explicit dimension preserve their intrinsic aspect ratio;
  the opposite decode dimension remains unset. This corrects a regression where
  a loosely constrained login logo was decoded to the parent's available height.
  Images without explicit dimensions still use layout-based decode limits.
- PSGC response decoding and address model creation use `compute`; shared OSRM
  and rider alternative-route decoding, geometry, and directions model creation
  use the same native isolate mechanism.
- Horizontal banner/sale list notifications no longer request catalogue pages.
  Loading, exhausted, and failed catalogues suppress redundant pagination calls.
- Sale previews index the original collection without allocating a copied list.
- Navigation profiling records both 16.67 ms and 8.33 ms frame overruns.

## Release builds

Run `./tool/build_android_release.ps1` for a Play Store app bundle, or pass
`-Artifact apk` for separate ABI APKs. Pass `-Artifact size` for an ARM64 APK
and Flutter's size analysis report. Size analysis omits `--split-debug-info`
because Flutter rejects that flag combination. For normal release builds,
archive `build/symbols` with the matching version for stack trace symbolication.
Do not compare a universal debug APK with an ARM64 release APK as evidence of
savings caused by these code changes.

The installed Flutter Gradle plugin already enables R8 minification, optimized
ProGuard rules, and resource shrinking. Duplicating those settings gives no extra
savings. Android release signing currently uses the debug configuration;
configure the production keystore before store submission.

Run Flutter tests and Android builds sequentially in this checkout: both can
regenerate native plugin registration with different dev-plugin inclusion.
If a release compilation reports a missing `IntegrationTestPlugin`, rerun the
normal Flutter release build to regenerate registration. Do not hand-edit the
generated Java file or add the test plugin to release dependencies.

## Further size reductions that need deployment work

- Retain dynamic legacy images until the verification described in
  `architecture/asset_cleanup_candidates.md` is complete. Dart tree shaking
  does not remove files listed in the asset manifest.
- Compress product uploads before storage; serve thumbnail sizes from an
  authenticated image transformation service. Decode-size hints reduce bitmap
  memory, not downloaded bytes. Keep original detail images separate.
- Convert appropriate bundled photographs to WebP offline, compare visual
  quality, and migrate asset constants and stored paths together. Compressing
  at runtime cannot reduce the installed bundle.
- Android Play deferred components can move optional features out of the base
  install, but require deferred Dart libraries, loading UI, and dynamic feature
  modules. A deferred import alone does not reduce a normal mobile install.
  Native map/location plugin dependencies can still remain in the base module.
- Web deferred imports split downloads; they do not provide native Android/iOS
  install savings. No packages were removed: declared runtime packages have
  live application imports, including Android phone hints using Play Auth.

## Verification boundaries

`compute` uses another isolate on native platforms; on web it runs on the main
event loop. A web worker is required for actual web parallelism. Ordinary
`async`/`await` alone does not offload synchronous computation.

Profile product scrolling and navigation on physical 60 Hz and 120 Hz devices.
Inspect UI and raster timings against 16.67 ms and 8.33 ms budgets respectively,
including cold images, search, pagination, and account changes. Existing frame
test assertions are smoke checks, not a guarantee of sustained 120 fps.

References: [Flutter app size](https://docs.flutter.dev/perf/app-size),
[image frame placeholders](https://api.flutter.dev/flutter/widgets/Image/frameBuilder.html),
[Android deferred components](https://docs.flutter.dev/perf/deferred-components).

## Local validation (2026-10-14)

- Final analysis of all changed Dart sources and tests: no issues.
- 30 targeted tests passed across images, address parsing, route parsing,
  product grids, sale previews, shared widgets, and pagination. The updated
  pagination test also passed separately with a real horizontal list drag.
- All eight changed application sources have 14–198 physical lines and contain
  no prohibited inline styles. Dart formatting and PowerShell syntax checked.
- All three build script modes emitted the intended arguments with a stub CLI.
  On Windows with script execution disabled, invoke the script with
  `powershell -NoProfile -ExecutionPolicy Bypass -File tool/build_android_release.ps1`.
  This affects only the child PowerShell process.
- The ARM64 release build verified icon subsetting from 1,645,184 bytes to
  44,288 bytes (97.3%). This measures font subsetting against the full font,
  not an incremental reduction relative to a previous release APK.
- On-device integration/profile tests were not run and no app was installed on
  the connected device. Sustained 60/120 fps remains unverified.
- The Android build reports existing plugin KGP migration and Java deprecation
  warnings. Runtime compatibility of upgraded plugin versions was not evaluated.
- ARM64 release APK build succeeded: 37,941,443 bytes (36.2 MiB), at
  `build/app/outputs/flutter-apk/app-release.apk`. The size report attributes
  approximately 10 MiB to bundled Flutter assets and 23 MiB to ARM64 libraries.
  The application package accounts for roughly 3 MiB of decompressed Dart AOT
  symbols. These categories use different compression measures; do not add the
  decompressed symbol figure to the compressed APK figures.
- DevTools report: `build/flutter_size_03/apk-code-size-analysis.json`.
  No prior comparable release artifact was available; incremental APK savings
  and installed storage usage are not established by this baseline.
- The first build failed with a stale integration-test registration after tests
  ran concurrently. A normal release rebuild regenerated it and passed; no
  generated files or release dependencies were manually changed.
- Follow-up login logo fix: eight image, adaptive authentication layout, and
  selected-account login tests passed. The actual logo asset retains its natural
  aspect ratio under loose vertical constraints. Targeted analysis is clean;
  the shared image source is 173 lines with no inline styles. The APK measured
  above predates this fix and must be rebuilt to include it.

## Rider home redesign

- The reference's online/offline structure is implemented with a gradient
  profile header, overlapping availability card, GPS/connection row, tappable
  earnings snapshot, delivery cards, illustrated empty states, product-image
  request previews, compact daily metrics, and communication cards.
- Existing availability transitions, refresh behavior, warnings, temporary-data
  notices, capacity setup, earnings, messaging, notifications, maps, and safety
  callbacks remain connected. Detailed work states still display their actual
  labels; offline does not conceal a rider's assigned deliveries or earnings.
- The body uses a lazy builder and normal viewport caching rather than the
  previous 10,000-pixel cache. Product image decode widths are bounded. Empty
  illustrations use Flutter vectors and add no raster assets or dependencies.
- Styles are centralized in `rider_home_design_styles.dart`; existing widgets
  retain their dedicated style references. Every modified application source
  remains at or below 200 physical lines and has no prohibited inline styles.
- 27 rider dashboard, tab-state, and availability regression tests passed.
  Online preview coverage was then extended to an assigned delivery; both
  online/offline preview tests passed again at 390 pixels and 320 pixels with
  1.5x text scaling. Existing assertion changes scroll to lazy sections before
  checking them or tapping their actions.
- Rendered previews are in `build/rider_home_previews/online.png` and
  `build/rider_home_previews/offline.png`. They use synthetic test fixtures,
  including fallback avatars, and are not screenshots of a live account.
- No database, query, ownership, storage authorization, or guarded route contract
  changed. No APK installation or physical-device frame profiling was performed
  for the redesign. The earlier release APK does not contain these changes.
- Follow-up production-theme fix: primary and secondary rider button styles
  explicitly override the global 40-pixel maximum height. Their 46/42-pixel
  minimums previously conflicted with that inherited cap. A focused regression
  test reproduced the exception before the fix. All 13 button, dashboard, and
  online/offline layout tests passed afterward. Preview tests now use
  `AgrisellTheme.light`, including narrow screens with enlarged text.

## Rider reference alignment follow-up

- Compared the implementation with
  `assets/images/sampleReference/a_clean_modern_ui_design_image_showing_a_mobile_a.png`.
  Removed the translated status card's retained blank space, grouped the daily
  metrics inside one surface, moved pickup headings inside their card, and
  aligned row spacing, earnings presentation, delivery timeline, and helper text.
- Nearby requests now display a compact thumbnail/name/location/fee column with
  separate distance and travel-time details. Delivery fees use plain green text;
  the active card has an amber progress badge and blue next-action panel.
- Replaced performance chips with responsive metric columns and added lightweight
  vector scooter/crate scenes. Illustrations are code-native approximations of
  the reference artwork, not additional downloaded or bundled raster images.
- Rider navigation now uses a flat white bar with a green active indicator and
  live dashboard message count. Existing navigation callbacks remain in use;
  frame-test navigation finders recognize the rider-specific bar.
- Kept real work-state labels, GPS readiness, warning/temporary-data notices,
  unknown pending balances, and guarded map access. Reference names, amounts,
  delivery counts, and avatars are not substituted for account data.
- 21 dashboard, preview, tab-state, button-theme, and route-guard checks passed.
  The visual checks use the production theme and exercise 320-pixel widths with
  enlarged text. They are widget tests, not an on-device frame-rate measurement.
- Updated top and lower-page previews are in `build/rider_home_previews/`:
  `online.png`, `offline.png`, `online_details.png`, and `offline_details.png`.
  The APK was not rebuilt or installed for this follow-up.
- Header/work-status follow-up: both sections now sit above the scrollable body
  and stay fixed while earnings, requests, metrics, and support scroll below.
  Pull-to-refresh remains on the body. Widget tests compare header/status screen
  positions before and after scrolling; lower-page previews include the pinned
  header and status card.
- Typography/palette follow-up: all rider-home style families now explicitly
  reference `AppTypography.fontFamily` (Poppins). Primary/secondary buttons use
  the shared button typography. Replaced 900-weight styles with the bundled
  Poppins ExtraBold weight and loaded all five bundled weights for previews.
  Rendered RichText checks verify Poppins in both top and lower-page content.
- Rider design colors now resolve to `AgrisellColors`: auth/forest greens,
  home/page/surface backgrounds, central text/border neutrals, and status colors.
  The vector scenes also use these palette tokens. No standalone hex colors
  remain in the rider home/reference style files. Thirteen visual, button-theme,
  and dashboard tests passed; analysis and source/style checks are clean.

## Rider startup follow-up

- Dashboard loads requested by tab mounting or a rider/controller update now
  begin after the frame. The callback checks that the screen is still mounted
  and still uses the same rider/controller. This prevents the navigation bar's
  dashboard listener from being dirtied during `RiderKeepAliveTab` construction.
- Removed the rider-only full-screen profile-loading replacement. The home
  header, work status, and navigation render while the authenticated profile
  lookup runs. In-page dashboard loading feedback remains; network work is not
  represented as already complete. Profile failures still show the retry state.
- Production continues to use the same forced signed-in profile lookup and
  existing role/session gates. A profile-loader dependency allows latency and
  disposal tests without live database requests. Late profile responses stop
  before updating disposed controllers or starting rider requests.
- Twenty-three startup, dashboard, tab-state, role-gate, and route-guard tests
  passed. Source files remain below 200 lines with no inline styles. No hosted
  database or on-device login latency benchmark was run for this change.

## Rider deliveries reference redesign

- Applied `assets/images/sampleReference/deliveries.png` to Requests, Active,
  History, the request filter sheet, and delivery details. The light header and
  tab bar stay outside the scrollable lists. Counts and notification badges use
  account/controller data, with existing notification and map callbacks.
- Added reusable product headers and pickup/drop-off rows, compact request cards,
  estimated-fee and vehicle summaries, a five-step active-trip overview, and live
  load/COD/route metrics. Expandable route details retain batch sequencing and
  handling warnings; the detail screen retains the complete tracking timeline,
  evidence, status controls, safety, conversation, and waybill actions.
- History uses local-date groups, literal client-side search, and status filters
  with an All deliveries reset. Closed trips keep their status; cancelled/failed
  rows do not display an assumed completed earning.
- Filters now use switches, a distance slider, category/deadline dropdowns, and
  validated earning fields. Existing custom values and unlimited/null settings
  survive reopening. Reset/Apply stay pinned while the fields scroll. Pickup and
  drop-off Navigate actions reuse the existing fresh-GPS route validation.
- Delivery styles explicitly use Poppins and central AgrisellColors tokens.
  Lists still build lazily; product thumbnails decode to a bounded device-pixel
  height without forcing a different image aspect ratio. No new image assets or
  dependencies were added, and the reference folder remains outside the bundle.
- Twenty-eight widget/controller/matching/startup checks passed, including
  320-pixel layouts at 1.5 text scale, rendered Poppins checks, pinned header and
  filter actions, custom filter preservation, validation, Reset, history search,
  history status reset, and map/notification callbacks. Dart analysis and
  source/style checks passed; modified application files are at most 189 lines.
- Preview artifacts: `build/rider_deliveries_previews/requests.png`, `active.png`,
  `history.png`, `filters.png`, `details.png`, and `details_addresses.png`.
  Preview data is synthetic test data. No release APK, device frame-rate/storage
  benchmark, live database, or end-to-end network verification was performed.
  This change adds no database queries or authentication-policy changes.

### Delivery saved-state collision fix

- Added distinct PageStorageKey values to the active route/handling expansion
  and the per-delivery information expansion. Unkeyed expansion tiles inherited
  their enclosing list's storage identifier, so Flutter attempted to cast the
  stored double scroll offset to a bool when the tile mounted again.
- Two regression cases first persist a nonzero real scroll offset, remount the
  list with the expansion tile, then expand and remount again. Both confirm
  independent restoration without type errors. Existing deliveries/detail
  layout checks also pass. Source/style checks remain within AGENTS.md limits.

### Deliveries GPS acquisition and resume fix

- Deliveries now starts foreground location tracking on tab entry, even when
  there is no active delivery. Previously only Map or an active delivery started
  tracking, so an enabled device GPS could leave request access at unavailable.
- Returning to the foreground refreshes GPS for a tracked delivery/map workflow
  and restarts tracking after a successful settings return. GPS acquisition
  remains asynchronous and does not block the home/login shell.
- GPS refreshes are coalesced. Cached fixes older than the existing 45-second
  quality window are refreshed on tracking startup. Late fixes after disposal
  are ignored, avoiding stale publication/controller notifications on logout.
- Pending first acquisition displays Finding your location. Permission denial,
  disabled service, poor accuracy, and real acquisition failures retain their
  existing distinct warning behavior. Enabling the device switch alone does not
  bypass precise/current GPS acceptance or arrival validation.
- Twenty-seven GPS, lifecycle, matching, startup, and request-widget checks passed.
  Added concurrent-refresh, freshness, disposal, and pending-warning
  regressions; verified source length and style placement against AGENTS.md.
  No authentication policies, query ownership filters, or database schema were
  changed. Device GPS/settings behavior still requires on-device verification.

## Rider map reference redesign

- Applied `assets/images/sampleReference/map.png` to discovery, navigation, and
  map options using Poppins and AgrisellColors. The light header has pickup search
  and the existing notification destination/badge; View all opens Deliveries.
- Added floating status/GPS, layers, recenter, and zoom controls; a draggable
  pickup carousel/nearby-farm sheet; a green maneuver header; and a draggable
  navigation panel with real route time/distance/arrival, delivery progress,
  addresses, guarded delivery management, and the existing conversation handler.
  Full route alternatives, directions, GPS warnings, and refresh remain available
  in the navigation panel. Status changes use the authoritative availability flow.
- Independent switches control pickups, active destinations, assigned drop-offs,
  and nearby farms. Existing focus filters, clustering, marker limits, farm
  revalidation, participant checks, road-access guides, and route caching remain.
  Drop-offs are informational and only derive from the current rider's assigned
  nonterminal deliveries; tests exclude another rider's delivery markers.
- Map options retain a pinned close/header row. Default uses the existing map
  provider; Satellite, Terrain, traffic, and fuel/rest/hospital POIs are explicitly
  unavailable because no providers for those features are configured. No dummy
  POIs, fake traffic, or external tile providers were introduced. Attribution
  stays visible above the draggable panel and links to OpenStreetMap credits.
- Active routes and rider markers use the central status blue; pickup/farm
  markers use app green, and assigned drop-offs use semantic red. Route fitting
  reserves space for the navigation sheet while keeping a positive viewport.
- Twenty-three map/marker/navigation/route/startup checks passed, including
  320-pixel layouts at 1.5 text scale, rendered Poppins, layer callbacks, pinned
  option header, delivery/message/exit actions, and owner-scoped drop-off markers.
  Four camera-policy checks also passed after adjusting sheet clearance. New and
  modified map application sources are under 200 lines, with styling in dedicated
  files. No packages, bundled raster assets, database queries, or policies added.
- Layout previews: `build/rider_map_previews/discovery.png`, `navigation.png`, and
  `options.png`. Flutter widget tests block HTTP tile requests, so their map
  background is blank; previews verify overlay layout with synthetic fixtures,
  not live tile imagery. No APK build/install, device frame-rate measurements,
  hosted database checks, or live routing/turn-by-turn drive test was performed.

### Route loading recovery and reference feature audit

- Initial routing now requests one road route; Find alternative routes requests
  alternatives explicitly. Full geometry/steps and isolate decoding remain.
- Fixed failed-route GPS retry loops, bounded network/service waits, enabled
  explicit retry after completion, and removed local cache writes from the first
  route render path. Late cache/network results cannot overwrite newer state.
- Route failures now replace Finding route with Route unavailable and Retry.
  A configurable OSRM-compatible `RIDER_ROUTING_URL` permits a separately
  provisioned routing origin; default remains unchanged, with no new host rollout.
- Thirty-four route/loading/map/navigation/camera/ownership checks passed. Fixed
  a farmer fee-dialog parameter-list syntax error that blocked map-screen test
  compilation, preserving the existing dialog behavior. Application source and
  styling checks remain within AGENTS.md constraints.
- Full reference audit: `docs/rider_map_feature_verification.md`. The reference
  is not fully implemented: imagery/traffic/POI providers, direct calls, voice
  guidance, and More are missing; search and Problem use existing destinations.
  No live latency claim or provider availability guarantee is established by
  these local tests, and no device drive test or APK installation was performed.

### Keyless default rider street map

- Replaced the default rider street tile source with the standard OpenStreetMap
  endpoint `https://tile.openstreetmap.org/{z}/{x}/{y}.png`. It requires no
  application API key or Google Maps SDK configuration. Existing rider markers,
  route overlays, GPS controls, and tile caching stay on flutter_map.
- Retained app-identifying tile User-Agent and visible OpenStreetMap credits.
  The standard tile service is online and subject to its usage policy; it is
  not an unlimited/offline map service. Provider policy:
  https://operations.osmfoundation.org/policies/tiles/
- Satellite and Terrain retain their existing separate imagery sources; this
  provider change applies to the Default street view. Firebase messaging keys
  are unrelated to the map layer and were not changed.
- No package, bundled map asset, query, or authentication-policy change added.
  Live tile download behavior still needs device/network verification.

### Map-view thumbnail selector

- Replaced icon-only Default/Satellite/Terrain choices with rounded thumbnail
  cards and labels below, matching the reference hierarchy. Selection uses the
  central auth-green outline, and all text explicitly uses Poppins.
- Preview images use fixed public sample tiles from the existing view providers,
  bounded to a 256-pixel decode width. They never request the rider's current
  position. Loading/offline failures use lightweight code-native map previews
  rather than leaving blank tiles or requiring bundled raster assets.
- All three view-selection callbacks and selected semantics remain functional.
  Five selector/map tests passed, including unavailable images and 320-pixel
  layouts at 1.5 text scale. Modified/new application sources are at most 110
  lines and keep styling in dedicated files.
- Preview: `build/rider_map_previews/view_selector.png`. Widget-test HTTP is
  blocked, so the preview shows the illustrative offline fallbacks; actual
  provider thumbnails still require live network/device verification.

## Rider messaging reference design

- Implemented the inbox, text conversation, offline/error banners, pending text
  summary, and quick-reply sheet from the rider message references. Poppins and
  AgrisellColors are used through dedicated styles. Conversation data, unread
  counts, timestamps, delivery IDs, and delivery statuses come from existing
  models rather than reference artwork examples.
- The rider composer sends text only. Photo/file/location controls and the home
  attachment-capture callback were removed from these flows. Existing historical
  non-text records render their text fallback; no media viewer was added. Existing
  repository compatibility methods and message kinds were retained.
- Inbox rows use SliverList.builder in one scroll view, without nested shrink-wrap
  lists. Chat displays the latest message at the bottom. Failed text drafts remain
  available, repeated composer submissions are guarded, and quick replies have a
  selection preview before confirmation.
- The pending summary is scoped to the controller's authorized conversations.
  Existing guarded navigation, conversation access checks, repository ownership
  checks, and offline retry behavior remain in place. No queries, migrations, or
  hosted configuration were changed.
- Overrode the global 40px button maximum inside messaging styles to prevent
  clipped quick-reply labels and send actions. Removed inherited field borders
  from the composer while retaining the outer rounded container.
- Verification: 19 local tests passed across messaging design, conversation access,
  offline queuing/retry, existing chat layout, and rider startup. Checks include
  320px/430px layouts, 1.3 text scaling, keyboard insets, inbox filters/search,
  absence of attachment controls, pending visibility, and failed-draft retention.
  Modified application sources are at most 187 physical lines; Flutter style
  constructors are confined to dedicated style files.
- Generated previews: build/rider_message_previews/inbox.png,
  chat_320.png, chat_430.png, quick_replies_320.png, quick_replies_430.png.
  These use local test fixtures; live messaging, hosted authorization, realtime
  delivery, and physical-device performance were not verified by these tests.

## Rider profile reference design

- Restyled the profile overview, rider information, logistics partner, document
  overview, settings, edit form, vehicle details, password form, and empty states
  using the rider profile references. All new visual definitions use dedicated
  style files, Poppins, and AgrisellColors. No new bundled raster assets were added.
- Profile, performance, verification, availability, vehicle, and document values
  remain backed by existing models. Missing values are not replaced by reference
  sample data. Offline status uses a muted indicator. Document dates appear only
  when supplied by the record; pending/rejected records are never shown verified.
- Preserved existing guarded navigation, profile saving, exact GPS capture,
  Philippine address selection, password policy/current-password verification,
  vehicle edits/capacity boundaries, font scaling, safety/support, account-switch,
  and logout flows. Extracted the oversized profile screen and edit form into
  cohesive files; modified application sources are at most 166 physical lines.
- The existing backend does not expose a profile photo editing flow in these
  forms, and document viewing previously provided metadata only. This redesign
  uses the existing profile avatar and document/vehicle icons; it does not add a
  document image viewer, public file URLs, upload dates, or a photo upload action.
  Document cards in the standalone list are intentionally noninteractive.
- No database/query/storage policies or hosted settings were changed. Document
  metadata displayed from the current registration service is filtered against
  its current profile ID as defense in depth; existing repository authorization
  remains authoritative.
- Verification: 28 local tests passed covering responsive profile/settings at
  320px and 430px (including 1.4 text scale), action callbacks, status/date
  rendering, password visibility and validation, keyboard insets, exact GPS save,
  and vehicle capacity limits. Preview images are in build/rider_profile_previews.
  Physical-device rendering, real account updates, hosted authentication/RLS,
  live storage, and password changes were not executed by these local tests.
- Static analysis initially reported only an unused test import, which was
  removed. Subsequent broad and focused analyzer runs stalled without a final
  result and were stopped. A clean final analyzer result remains unverified;
  formatting, source/style checks, and all 28 tests completed successfully.

## Rider delivery detail reference layouts

- Implemented request review and active delivery views from the two delivery
  detail references: green fixed header, print-waybill control, status notice,
  larger product thumbnail and handling labels, pickup/drop-off cards,
  instructions, route preview, earnings, requirements, COD/expiry information,
  active progress, quick actions, evidence and problem-report state.
- The seven milestone strip fits normal phone widths and scrolls horizontally
  with enlarged text. Intermediate waiting/confirmation statuses remain visible
  through the current/next action summary and expandable status history; the
  existing state machine and proof/GPS/arrival checks were not changed. Special
  resolution states do not mark normal milestones completed.
- Kept accept/decline and delivery advancement controls below the scrolling body.
  Updated arrival labels to match their action. Acceptance still uses the same
  eligibility checks and confirmation dialog. Route/message/problem/safety and
  waybill actions retain their existing handlers and guarded navigation.
- Added an embedded OpenStreetMap preview using the existing tile URL, user-agent
  and flutter_map cache. It does not require an API key or start a routing request.
  It draws only existing route geometry, filters invalid coordinates, preserves
  attribution, and explicitly identifies missing road geometry. Totals are the
  existing model values; no synthetic ETA, road line, fee components, or deadlines
  are generated to match the artwork.
- Existing secure pickup product-photo and delivery-photo evidence is rendered
  through the existing authenticated image/local evidence helpers. Thumbnail
  decodes are bounded, and local evidence futures are reused across rebuilds.
  Product images also use bounded single-axis decoding with a graceful fallback.
- All new styling is in dedicated files using Poppins and AgrisellColors. No
  extra dependencies or bundled raster assets were added. Modified application
  files remain at most 193 physical lines. No backend queries, authorization
  contracts, database migrations or storage policies were changed.
- Reference previews are in build/rider_delivery_detail_previews. They use local
  fixtures and HTTP-blocked widget tests: background tiles and remote evidence
  photos require live network/device verification. Existing backend authorization
  and actual delivery mutations were not exercised against a hosted service.
- Verification: 19 local tests passed across the new reference layouts plus the
  existing details, progress, acceptance, deliveries-design and page-storage
  suites. Final static analysis reported no issues. Checks cover 320px/430px
  rendering, enlarged text, fixed action positioning, message callbacks, map
  geometry/missing-geometry behavior, attribution, invalid coordinates, evidence
  fallback, and acceptance regressions. Formatting and source/style checks pass.

## Rider pickup reference layouts

- Applied both pickup references: fixed green header and action footer, product
  summary, instructions, handling requirements, waiting timer, GPS status/retry,
  confirmation fields, proof controls, condition checklist and problem sheet.
  Uses Poppins and AgrisellColors through dedicated style files. Narrow screens
  and enlarged text stack the footer controls without clipping their labels.
- Isolated the ticking waiting timer to its own widget, preserving form drafts
  without rebuilding the entire screen each second. Product and fresh camera
  previews use bounded image decoding. No dependencies or bundled artwork added.
- Added ephemeral camera previews and proof removal. Submitted proof references
  still use the existing protected storage flow. Recovery does not persist the
  confirmation code, QR payload or camera-preview paths. Completion retains GPS
  freshness, required proofs, quantities and all eight explicit checklist checks.
- Replaced the problem dialog with a keyboard-aware sheet, purpose-specific
  reason icons, required notes capped at 500 characters, and dismissible saved
  feedback. Existing reporting and completion repository handlers are retained.
- All affected application sources are at most 195 physical lines; prohibited
  inline style constructors are absent. Static analysis is clean. The pickup,
  required-validation, validation, delivery-reference and details-layout suites
  passed 28 local tests, including successful completion through the in-memory
  repository, saved problem feedback, 320px/enlarged text and keyboard layouts.
- Previews are generated under build/rider_pickup_previews. Tests use fixture
  GPS and proof storage; physical camera, live GPS, hosted uploads and backend
  mutations still require device verification. No database or query changes.

### Pickup product image correction (2026-10-15)

- The earlier visual fixture contained a local image, but the live repository
  omitted productImageUrl and the delivery RPC did not supply product_image_url.
  The mapper now preserves this field. Migration
  20261015120000_include_rider_product_images.sql adds one deterministic nonempty
  ordered-product image from the fulfillment's seller farm and buyer, retaining
  existing selected/assigned visibility and outer payment/gateway wrappers.
- Compared both pickup references again: summary uses category icon and separate
  pickup locality, instructions/handling/waiting share a card, and captured product
  evidence is shown beside the add/replace control. No catalogue image is used as
  evidence, and checklist items still require actual rider confirmation.
- 21 focused Flutter tests pass; Dart analysis is clean. The isolated PGlite
  harness test/support/rider_product_images_sql_harness.cjs exercises the actual
  migration for assigned and selected access, two buyers/riders, expired requests,
  missing images, literal hostile URL characters and invalid/anonymous sessions.
- Migration is prepared but not deployed. Local full-schema PostgreSQL on
  127.0.0.1:54322 is unavailable, so authentication_boundary.sql,
  application_table_rls.sql, sql_injection_boundary.sql,
  existing_account_profile_isolation.sql and account_data_isolation.sql remain
  pending there. No production fixtures were created. Real storage fetches and
  camera uploads still need device verification after migration deployment.

### Pickup reference image verification

- Checked both pickup PNGs: the product thumbnail in the summary/behind the
  problem sheet is catalogue data; product/package photo previews are actual
  captured evidence. Category, handling, GPS and problem-type visuals are icons.
  The add-photo action stays beside the saved evidence preview. No catalogue or
  reference artwork is substituted for required captured evidence.
- Added a saved-proof image widget: fresh camera files, authenticated private
  upload object keys, full image URLs and validated offline pickup references
  render bounded thumbnails. Offline file lookup is reused across rebuilds and
  reloaded when its reference changes. Changing references resets stale pixels.
  Missing/invalid images announce Photo preview unavailable instead of displaying
  a success checkmark. Attestations remain icons rather than image requests.
- Offline resolution accepts only pickup filenames generated by the existing
  storage class inside the application documents directory, rejects traversal and
  non-image names, and checks the existing 8 MB bound. Private object keys use
  authenticated delivery-proofs URLs; bearer headers still attach only to the
  configured Supabase origin. Existing owner/participant storage RLS is retained.
- 27 local tests pass across image decoding, pickup reference layouts, repository
  mapping and completion validation. Tests verify actual decoded product/offline
  photo pixels, reused loads, reference changes, private key URL construction,
  hostile paths, unavailable states and existing 320px/430px/keyboard layouts.
  Live private storage and camera remain device checks; the prepared catalogue
  image migration above still requires hosted deployment.

2026-10-15 all rider reference image audit: catalogue thumbnails share RiderProductImage and retain authenticated project-storage/origin-restricted headers. Delivery-detail evidence now resolves existing private object keys and offline pickup references through safe image helpers. No query, schema, policy or grant changes in this follow-up. 37 local tests pass; live remote reads and hosted RLS remain unverified. Prepared product-image migration remains undeployed. See docs/rider_reference_image_audit.md.

2026-10-15 rider pickup/image hosted correction (deployed with explicit user approval): live private.current_rider_deliveries raised 42703 because fulfillment.seller_farm_id does not exist. Migration 20261015130000 fixes the join using representative_order_id -> orders.seller_farm_id, with buyer/farm scoping and unchanged selected/assigned visibility, session guards, fixed search path, grants, gateway/payment wrappers and storage policies. The existing status RPC was present and left unchanged. Hosted rolled-back response, status, authentication, RLS, SQL injection and existing-account isolation assertions pass. Isolated harness now reproduces the original error with actual schema columns and verifies buyer/seller/rider isolation. 27 Flutter tests pass for image/confirmation/snackbar behavior; actual device downloads and delivery mutations remain unverified. Supersedes earlier pending-image-deployment notes. See docs/rider_pickup_refresh_fix.md.

2026-10-15 pickup completion follow-up: existing offline evidence uploader now resolves pickup files through PickupProofStorage.resolveLocalPhoto (documents root), retains strict generated filenames, and validates reference delivery/stage before the existing upload. No new queries, policies or RPCs. Completion maps DeliveryDataException to domain failures so specific server messages reach the form. Hosted inspection was read-only; no delivery mutation or upload tested there. 35 focused local tests pass including HTTP-fixture completion and offline multipart upload/cleanup. See docs/rider_pickup_refresh_fix.md.

2026-10-16 rider theme consistency: rider colors use AgrisellColors, legacy text styles explicitly use Poppins, and remaining map inline styles are extracted. 36 layout/interaction tests pass. No new dependencies or assets. See docs/rider_theme_consistency.md for scope and verification limits.
