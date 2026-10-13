# Rider vehicle capacity and batching — October 13, 2026

Hosted read-only inspection confirmed a motorcycle rider with
maximum_active_deliveries=1 and capacity_kg=NULL. Vehicle policy recommended
three deliveries but configured one. The Flutter entity mapper also dropped
capacity, and its embedded vehicle returned 0 kg.

The prepared migration enables the configured recommendations for previously
unconfigured vehicle policies (motorcycle 3, tricycle/car 5, van 10, truck 20;
bicycle/e-bike 3). Higher individual limits and explicitly manager-configured
vehicle limits are preserved. Missing capacity stays unset: each rider must
enter usable cargo weight under Account > Settings > Vehicle details. Existing
positive capacities within their ceiling remain; above-ceiling values reset to
unset, and changing vehicle type requires declaring capacity again. Unknown
vehicle types require a configured ceiling before capacity can be saved.

Cargo ceilings are app policy values, not universal manufacturer ratings:

| Vehicle | App ceiling (kg) |
|---|---:|
| Bicycle/e-bike | 25 |
| Motorcycle | 30 |
| Tricycle | 200 |
| Car | 200 |
| Van | 1000 |
| Truck | 1500 |

Research references, accessed October 13, 2026:
- [Trek Farley cargo rack](https://www.trekbikes.com/gb/en_GB/equipment/bike-accessories/bike-racks/trek-farley-rear-cargo-rack/p/44355/?colorCode=black): 25 kg rack rating; other racks can be lower.
- [Yamaha XMAX manual](https://www.yamaha-motor.co.th/docs/owner-manual/commuter/en/xmax-en.pdf?Status=Master&sfvrsn=175edc05_4): 161 kg includes operator, passenger, cargo and accessories, not cargo alone.
- [Bajaj Maxima cargo specifications](https://www.bajajauto.com/en-ng/-/media/globalbajajauto/common-media/brochure/3wheelers/maxima-cargo-petrol.pdf): 990 kg gross, 475 kg kerb.
- [Toyota Yaris specifications](https://www.toyota.com.au/yaris/specs): 1575 kg gross, 1130 kg kerb; occupants and accessories reduce available payload.
- [Toyota Hiace specifications](https://www.toyota.com.sa/en/vehicles/hiacevan/full-specs): one variant lists 1140 kg net payload.
- [Isuzu Traviz](https://www.isuzuphil.com/trucks/traviz): 1655–1660 kg cab/chassis payload; fitted body and other added loads reduce usable cargo.

The category ceilings are conservative product-policy choices inferred from
these examples, not guarantees for every vehicle in the category. The rider
must enter the lower actual vehicle/rack rating after allowing for occupants,
accessories and bodywork. No automatic capacity is invented.

The new bound-parameter RPC set_current_rider_capacity resolves the current
rider server-side, rejects missing/anonymous/expired sessions, checks the gateway,
locks the rider row and prevents lowering capacity below active cargo weight.
It returns only the current capacity/ceiling. Direct writes to trusted limits
remain denied. The existing acceptance validator retains its checks and invokes
an additional capacity check, under the same rider row lock, for every new
acceptance including the first. Missing/nonpositive order weights fail closed.
The added helper requires the actual rider or an existing authorized delivery
manager; its execution is denied to end users. No notification/storage/realtime
or participant boundaries change. Migration function replacement uses trusted
regprocedure metadata and a fixed literal patch; no request data becomes SQL.

Local verification: 24 Flutter tests passed; targeted analyzer and formatting
passed. Modified application sources are at most 192 lines; styles remain in
style files. The PGlite harness verifies required user input, ceilings, 3 x 1 kg
acceptance with declared 3 kg capacity, combined-weight rejection, lower-capacity
rejection during active jobs, ownership, hostile bound inputs, NaN/Infinity,
anonymous/expired denial and preservation of manager configuration. This is an
isolated scoped schema, not the entire production acceptance transaction.

Rollout status: LIVE DEPLOYMENT NOT APPLIED. Automatic approval review rejected
the attempted direct deployment because persistent schema/rider/trigger/limit
and authorization changes require explicit user deployment approval. Hosted
inspection was read-only. The live rider remains limited to one with no capacity.
After approval apply 20261013110000_enable_motorcycle_capacity_batching.sql, then
run rider_capacity_batching.sql and the existing authentication_boundary.sql,
application_table_rls.sql, sql_injection_boundary.sql and
existing_account_profile_isolation.sql assertions. Those post-change hosted
assertions have not run. Direct db query does not record CLI migration history.

Full local account_data_isolation.sql could not run: PostgreSQL at
127.0.0.1:54322 refused the connection. It was not redirected to production.
Device saving and real concurrent acceptance remain unverified. The capacity
editor requires the migration, then riders must save capacity before accepting
new jobs. Existing active deliveries are not discarded or reassigned.

## Quantity and item correction — October 13, 2026

The pending acceptance check now recomputes mass from persisted order lines,
scoped by the fulfillment's seller order, seller farm and actual buyer cart.
For kilogram-priced items each quantity unit represents 1 kg, so the sum includes
all items (3 kg vegetables + 2 kg fruit = 5 kg). This replaces reliance on the
cached fulfillment total, which could be stale. The same calculation is used for
all active orders and when lowering the rider's capacity. Exact-capacity totals
are allowed; higher totals are rejected.

The current product catalogue also offers piece, bundle and sack units without
per-unit mass. Those quantities are not kilograms. An order containing such an
item fails closed with cargo_weight_unknown; the UI says the weight in kilograms
must be verified. No per-piece/sack conversion is invented, and no measurement
entry workflow was added in this correction. Such products need stored actual
kg-per-unit or a verified shipment mass before they can pass this check.

The isolated PostgreSQL tests cover mixed items, stale cached totals, separation
of another buyer/farm's lines, and unknown sack mass. Flutter tests cover 5 kg
plus 10 kg reaching a declared 15 kg capacity and rejecting another 1 kg. The
three-order motorcycle configuration is still present pending the user's answer
about keeping an independent order-count limit. No deployment approval has been
received; the hosted database remains unchanged.

## Order-count policy selected from platform research — October 13, 2026

The user delegated the order-count decision to online research. Keep both the
existing small-batch count limit and the calculated cargo limit. Uber's official
triple-batching explanation describes two or three orders and batching based on
location, preparation time and efficient routes:
https://www.uber.com/au/en/blog/triple-batching-for-restaurants/

Lalamove Philippines offers multi-stop parcel routes:
https://www.lalamove.com/en-ph/blog/multi-stop-delivery-logistics-partner

These are different delivery platforms and operating models; neither establishes
a universal physical order-count limit for a motorcycle. Agrisell's choice is
three active motorcycle deliveries as a route-management default, always subject
to combined verified mass <= the rider's declared capacity, compatible handling,
route and deadline checks. A rider with 5 kg available cannot accept a 6 kg order
even when fewer than three deliveries are active. A completed/cancelled job leaves
the active capacity/count calculation. Higher manager-configured limits remain
possible. The migration remains undeployed pending explicit approval.

Follow-up verification: 26 Flutter tests passed and the updated PGlite checks
passed; targeted analysis and formatting passed. Modified follow-up application
sources are 160 and 50 lines, with no inline styling. Production/device behavior
has not been verified and the full local isolation database remains unavailable.

## Home setup for previously registered riders — October 13, 2026

Home now displays Set your cargo capacity above the availability card whenever
the current profile has no positive finite saved capacity. Set capacity opens
the existing Vehicle details form through agrisellPageRoute (AuthPageGate).
The form explicitly tells existing riders to save usable kg once and describes
combined item/quantity weight. It retains server vehicle ceilings and required
positive numeric input. No existing rider is assigned an invented capacity.

The delivery controller blocks additional acceptance whenever at least one
active job exists and capacity is missing, zero, negative or nonfinite. Both
canAcceptRequest and accept use this guard, and direct acceptance returns
capacityNotSet with setup guidance. Saving reloads the remote profile; the
existing RiderRegistrationService listener refreshes Home and the controller,
hides the prompt, and restores batching eligibility. Existing jobs are retained.
This is an eligibility rule, not a new account role.

The pending server migration remains stronger: new acceptance, including the
first, requires verified weight and a saved capacity. No new backend change was
needed for the multi-order guard. Deployment still requires the previously
requested explicit live deployment approval; 'continue' resumed local work and
verification only. Do not claim live saving/acceptance is deployed.

Home follow-up verification completed: the four new home/controller tests and
capacity-editor test passed after applying the existing caption typography to
guidance text. The other 19 targeted dashboard/batching/cargo tests passed in the
preceding run. Final targeted analysis reported no issues. All ten application
sources modified for this follow-up are below 200 physical lines (largest 197),
with no prohibited inline style definitions. The earlier approval-service usage
limit prevented one test invocation; the user's subsequent continue request
resumed local checks successfully. Live migration approval is still outstanding.

## Form ceiling enforcement — October 13, 2026

RiderCargoCapacityPolicy now supplies the agreed app ceilings (25/30/200/200/
1000/1500 kg by vehicle, including 25 kg e-bike). Both the dedicated capacity
editor and Edit vehicle dialog validate with this policy before invoking saves.
A lower server maximum takes precedence; a higher supplied maximum cannot lift
the app ceiling. Missing server metadata falls back to the documented app policy
for form validation, but saving still requires the pending backend RPC migration.
Unknown vehicle types fail closed. Empty, nonnumeric, zero, negative and
nonfinite values are rejected; exact-ceiling values pass. Repository vehicle
validation uses the same helper before remote writes.

The edit dialog was extracted into a separate widget to preserve the 200-line
limit. Local verification: 18 form/navigation tests passed, covering seven vehicle
types, excess weights and exact ceilings; analysis passed. No new database change
or deployment was attempted. The previously documented live deployment block
remains; app validation is not proof of deployed server enforcement.
