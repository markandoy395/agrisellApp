# Rider map reference feature verification

Reference: `assets/images/sampleReference/map.png`.

This is a code and local-test audit. It does not establish live routing uptime,
actual device GPS behavior, voice navigation, or end-to-end delivery completion.
The reference is not fully implemented: the missing/partial features are listed
explicitly below. No reference names, amounts, traffic, or POIs are fabricated.

| Reference feature | Implementation | Verification / limitation |
| --- | --- | --- |
| Map header, Poppins, central palette | Implemented | Rendered-font and enlarged-layout widget checks. |
| Search icon | Partial | Opens the guarded Deliveries list and its search; no in-map place search. |
| Notification bell/count | Implemented | Existing notification callback and dashboard count. |
| Online/offline control | Implemented | Uses the authoritative availability flow, preserving GPS/account checks. |
| Rider position and recenter | Implemented | Existing location controller and guarded camera; device verification remains. |
| Zoom controls | Implemented | Camera validity/zoom-clamping tests. |
| Pickup and farm markers | Implemented | Existing matching, clustering, marker limits and tap/revalidation tests. |
| Pickup cards, fees, distance/ETA, View all | Implemented | Lazy carousel uses supplied request estimates; View all opens Deliveries. |
| Assigned deliveries and drop-offs | Implemented | Independent visibility controls; cross-rider marker exclusion test. |
| Default map view and attribution | Implemented | Existing OpenStreetMap tiles; widget tests block tile HTTP. |
| Satellite and Terrain views | Not implemented | Shown unavailable; no imagery/terrain provider configured. |
| Traffic overlay | Not implemented | Disabled; no traffic provider configured. |
| Markets/fuel/rest areas/hospitals POI categories and station cards | Not implemented | Farm discovery exists; it is not a substitute for those POI categories. |
| Maneuver banner and road geometry | Implemented | Uses real routing response instructions/geometry; no live drive test. |
| Travel time/distance/arrival | Implemented | Calculated route metrics; not traffic-aware ETA. |
| Navigation Exit | Implemented | Existing controller clear/exit callback. |
| Delivery product, progress and destination panel | Implemented | Reads authorized active delivery and canonical status. |
| Navigate pickup then drop-off | Implemented | Existing target transition after pickup; controller tests. |
| Message | Implemented | Existing participant-scoped delivery conversation callback. |
| Call | Not implemented | No call action or participant phone contact wired into this map panel. |
| Problem | Partial | Available through Manage delivery; no dedicated map Problem shortcut. |
| More | Not implemented | No reference-equivalent More menu in the map panel. |
| Voice/sound navigation button | Not implemented | No speech navigation/voice guidance engine. |
| Alternate-route selection | Implemented on demand | Find alternative routes explicitly requests alternatives; initial load asks for one route. |
| App bottom navigation | Implemented | Existing guarded rider destinations. |

## Route loading corrections

- Initial OSRM requests ask for a single route with full road geometry and
  maneuver steps, instead of waiting for up to three alternatives. The separate
  Find alternative routes action preserves optional route comparisons.
- HTTP requests time out after eight seconds; the controller bounds the complete
  service operation to ten seconds. A timeout or failure shows Route unavailable
  and an enabled Retry route action, rather than retaining Finding route.
- GPS events no longer treat a missing result from the same failed destination
  as a new destination and continually restart requests inside the retry delay.
- Valid routes notify the UI before the local cache save, which has its own
  bounded best-effort write. Cache restoration cannot overwrite a newer route;
  late responses after disposal or destination changes are ignored.
- `RIDER_ROUTING_URL` can configure an OSRM-compatible routing origin at build
  time. Default remains the existing public OSRM endpoint. No alternative host
  has been configured/deployed or verified. A public server cannot guarantee
  production latency/availability; the code changes do not establish a speed SLA.
- Route parsing remains off the UI isolate. No straight-line fallback is presented
  as a driving route, and arrival/acceptance authorization is unchanged.

## Local verification

Tests cover hung network requests, bounded failure, GPS retry suppression,
manual recovery, late responses, slow disk storage, late cache restoration,
Retry UI, single-route request parameters, explicit alternative parameters,
route target transitions, cached/offline behavior, map actions, owner-scoped
markers, camera constraints, and 320-pixel layouts with enlarged text.

No live route latency benchmark, provider outage test, APK build/install, GPS
drive test, hosted database test, or verification of unavailable reference
features has been performed.

Final verification: 34 local route/loading/map/navigation/camera/ownership tests
passed. All changed application sources satisfy the 200-line limit and dedicated
style rule. The map-screen test run also exposed a malformed named-parameter
separator in the farmer delivery-fee dialog; that syntax error was corrected
without changing the form's behavior.
