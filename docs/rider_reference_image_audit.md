# Rider reference product-image audit

Reviewed all 21 PNG files under assets/images/sampleReference on 2026-10-15.
This covers image slots and their data/rendering paths; it does not claim exact
reproduction of every reference or verification on a live device.

| References | Product/evidence slots | Implementation |
| --- | --- | --- |
| riderhome.png | Next move; ready-for-pickup rows | RiderDeliveryProductImage uses shared RiderProductImage |
| deliveries.png | Requests, Active, detail, History | RiderRequestProductImage and RiderDetailProductImage use the shared loader; history resolves images from requests/completion records |
| map.png | Discovery carousel; active navigation | Carousel and active header use RiderRequestProductImage |
| delivery detailes (2 PNGs) | Product summary; captured evidence | Shared loader; evidence handles private object keys, URLs, offline pickup and existing offline delivery files |
| pickup (2 PNGs) | Product summary behind form/sheet; actual proof | Shared loader; separate proof-image widget for fresh/restored evidence |
| rider_messages_* (4 PNGs) | No catalogue product-image slot | Text-only messaging; photo/file attachments in artwork excluded by user instruction |
| rider profile (10 PNGs) | No catalogue product-image slot | Avatar, vehicle and verification documents use separate identity/document workflows, unchanged by this fix |

All catalogue slots consume DeliveryRequest.productImageUrl, including through
status snapshots and completion records. The Supabase mapper preserves
product_image_url from the existing authorized delivery response. Prepared
migration 20261015120000_include_rider_product_images.sql supplies an actual
ordered commodity image scoped to the fulfillment seller farm and buyer,
retaining selected/assigned visibility, gateway quotas and payment wrappers.

Hosted follow-up found the original image migration already applied but failing
at runtime because it used a nonexistent fulfillment column. The corrective
20261015130000 migration is now deployed with explicit user authorization;
rolled-back assigned-rider response and hosted security assertions pass. See
docs/rider_pickup_refresh_fix.md. Commodities with no image still show an
unavailable thumbnail. No stock/reference art substitutes for product/evidence.
Device download verification and full local fixture isolation remain pending.

The shared loader trims sources, renders explicit assets and HTTP(S) images,
keeps square clipping, bounds single-axis decoding to device pixel ratio and
320 pixels, and reports missing/unsupported/failed sources accessibly. Project
storage uses authenticated object requests through the existing origin-restricted
bearer-header helper. Other hosts receive no token. No dependencies, bundled
images, public/signed URLs or new database queries were added.

37 tests passed across rider_reference_product_images_test,
rider_pickup_images_test, rider_pickup_design_test, rider_home_design_test,
rider_deliveries_design_test, rider_delivery_reference_design_test,
rider_map_design_test and supabase_rider_delivery_repository_test. Actual fixture
pixels decode for all product wrappers and offline pickup evidence. HTTP-blocked
tests verify private URL construction and failure handling, not live remote
downloads or hosted RLS. Modified application files are 16–145 lines and have
no inline style constructors. Formatting and analysis pass.
