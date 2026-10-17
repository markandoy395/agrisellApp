# Rider test-log follow-up

Reviewed the supplied partial Flutter test log on 2026-10-17.

The log begins at `+970 -5` and ends at `+1401 -10`. It contains five
additional failures, not the details of the initial five failures.

- Address-label assertions expected the previous single-line text. The current
  card renders a label and address separately. Tests now check both values and
  their grouping and vertical order.
- Three safe-area cases referenced `CustomBottomNavBar`. The rider home now
  uses `RiderHomeBottomNav`. Tests retain the page/nav boundary and bottom inset
  checks and tap the Map tab within the actual rider navigation widget.
- The map refresh test referenced a removed status/GPS popup. Normal map usage
  had also lost its refresh action: the toolbar accepted but never used its
  callback. A Refresh map button now calls the existing discovery refresh
  handler and disables during farm loading. The integration test verifies a
  second repository read and the resulting new farm marker without movement.

The full local run then reported 1,406 passing tests and six failures. The
remaining tests needed these updates:

- Inspect both lifecycle part files after the location-sharing method moved.
- Expand Route and handling details and scope deadline assertions to the batch
  summary rather than also matching individual delivery cards.
- Scroll the lazy dashboard list to the capacity banner before checking it;
  check its former position again after supplying the saved-capacity profile.
- Assert the quick amount as `500.00` in the amount field and provide a wallet
  repository fixture for the earnings-screen cash-out flow. Earnings summary
  values alone do not authorize a withdrawal.
- Wait up to five seconds for real local image I/O to produce an Image widget,
  replacing a fixed 100 ms delay; retain the decoded-pixels assertion.

All 37 tests across the nine affected test files passed across focused runs
after their corrections (15 initially, then 20, then the final four including
two repeated passing cash-out cases). The complete suite was not rerun after
the final corrections. The new toolbar test covers refresh activation and
disabling during loading. Formatting passes; the only application source
modified is the 68-line toolbar, with no inline style constructors. No database,
authentication, authorization or application data-query changes were made.
Final Flutter analysis of all ten changed Dart files and direct Dart analysis
of the test directory both reported no issues. The diff whitespace check passes.

## OpenStreetMap warning

### Subsequent supplied run (2026-10-17)

The later attachment includes the end of the older failing run followed by a
new `flutter test` invocation. That new run ends at `07:34 +1412: All tests
passed!`. This is supplied full-suite evidence, separate from the focused local
checks above. Its tile HTTP 400 messages and expected error-path diagnostics
do not indicate test failures. The installed Flutter test binding explicitly
substitutes empty HTTP 400 responses without making network requests. Live
device map loading remains unverified by this run.

Local follow-up reran `rider_map_screen_test.dart` and
`rider_map_toolbar_test.dart`: all five tests passed, including farm refresh
without rider movement and the loading-state button check. This follow-up
changes documentation only; no application sources or styles were changed.

The flutter_map notice is separate from the assertion failures. Flutter's
`TestWidgetsFlutterBinding` replaces the native HTTP client with an empty HTTP
400 response; these widget tests cannot establish whether a live tile server
is available or blocking requests. See the installed Flutter SDK source at
`packages/flutter_test/lib/src/_binding_io.dart`.

The [OSMF tile policy](https://operations.osmfoundation.org/policies/tiles/)
allows ordinary interactive viewing subject to identification, visible
attribution, HTTP caching and other requirements. It provides no SLA and may
withdraw access without notice. For a delivery service requiring guaranteed
map availability, select a provider with suitable terms or host tiles; public
OSMF tiles alone cannot provide that guarantee. Traffic volume and operational
requirements have not been supplied, so this is not production approval.

Repository observations:

- All six OSM TileLayer call sites use the correct HTTPS template and an
  application-specific `userAgentPackageName`.
- The locked flutter_map 8.3.2 uses its built-in native cache by default and
  derives freshness from HTTP response headers. Browser caching applies on
  web. Actual device cache behavior and deployed web Referer headers were not
  verified.
- Rider live/detail maps include visible OSM attribution. Shared
  `delivery_live_map.dart` and `location_map_preview.dart` do not declare
  attribution locally; enclosing surfaces need review. Selector and shipping
  maps use RichAttributionWidget, whose visible presentation needs review
  against the current policy. No blanket attribution compliance is claimed.
- OSM tile URLs remain hardcoded. The policy recommends allowing provider
  switching without an app update. No provider or credentials were selected
  as part of this test fix.
- No OSM bulk-download/offline tile workflow was found in the reviewed map
  widgets. Route persistence is separate from tile downloading.
- Satellite and terrain layers use Esri services. Their terms and attribution
  need separate review; the OSM policy does not cover those layers.

The warning is retained. These observations do not certify production usage,
device tile downloads, provider terms, or traffic capacity.
