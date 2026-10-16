# Rider palette and typography consistency

Updated 2026-10-16.

Rider screens now use AgrisellColors for their application chrome, route lines,
markers, progress indicators, earnings, withdrawal controls and sign-up loading
indicator. Hardcoded bright green/blue/red values were replaced with the existing
brand and semantic tokens. Central translucent effect tokens derive their RGB
values from the same brand colors; opacity remains appropriate for halos and
shadows. Transparent Material surfaces remain intentionally transparent.

Older rider TextStyle definitions now explicitly use AppTypography.fontFamily
(Poppins), including notifications, chat actions, earnings/cash-out/history,
withdrawal methods, confirmation forms, application review and profile editing.
The shared notification filter/state styles use the same family. Existing size
and weight hierarchy is retained except compact map progress labels, which now
use the shared caption size and wrap instead of truncating at ten pixels.

Extracted the inline map progress badges/labels, navigation action text, exit
circle, radar and POI badge decorations into rider_map_progress_styles.dart.
Screens/widgets reference dedicated styles. Authentication, routes, queries,
storage behavior, delivery transitions and business rules were not changed.
No dependencies, fonts or raster assets were added.

Verification: 36 existing tests passed across rider home/button themes, map and
map-view selector, deliveries, delivery details, messaging, profile, withdrawal
methods and responsive notification layouts. The map screenshots use blocked
HTTP tile requests, so they verify UI/route overlays rather than live map tiles.
Reviewed the navigation preview after rendering. All changed application files
are at most 200 physical lines and inline style constructors have been extracted.
Formatting and focused analysis cover every changed file. Physical-device visual
verification remains outstanding; perform a full app restart to reload styles.
