# Farmer signup to product posting review

Update: the three findings below were addressed on 2026-10-20. See
`farmer_publication_fix.md` for implementation, deployment, tests, and limits.

Reviewed 2026-10-20. Scope: Flutter flow, existing automated tests, and read-only
inspection of the connected database. No accounts, products, approvals, or storage
objects were created or changed for this review.

## Findings

### 1. Approval is enforced by the app but not consistently by the database

`FarmerCommodityRepository.save` rejects a new product unless the owner's farmer
verification status is `verified`. The dashboard also disables posting for pending
accounts. However, deployed `commodities_owner_insert` and `categories_owner_insert`
are permissive policies accepting active owners with statuses `pending`, `verified`,
or `needs_information`. They are ORed with the older verified-only
`authenticated_insert` policies. The restrictive owner boundary only checks farm
ownership, and the deployed commodity insert triggers do not check approval.

Consequently, an authenticated pending farmer has a database insert path that
does not satisfy the app's stated approval requirement. This is a deployed-policy
finding, not an exploit reproduced with a new hosted account. Enforce the intended
approval requirement as a restrictive backend rule, and align storage/restocking
and client behavior with the same documented workflow.

References: `lib/features/farmer/products/data/farmer_commodity_repository.dart:66`,
`lib/features/farmer/dashboard/presentation/utils/farmer_product_editor_coordinator.dart:73`.
Deployed policies were inspected in `pg_policies`; `private.owns_farm` and all
commodity triggers were inspected directly. The local file
`20261018004000_fix_farmer_product_publish_rls.sql` is empty and cannot reproduce
the deployed product-insert policy changes on a fresh database.

### 2. A stock failure leaves a saved product and discards the editing screen

The add-product form pops a new product object before persistence. The repository
then uploads the photo, inserts a commodity with zero quantity, and makes a separate
`restock_current_farmer_inventory_lot` call. If that last request fails, the photo
and commodity remain committed, while the coordinator displays a save error.
The buyer marketplace requires positive marketable inventory, so the product stays
hidden. Starting the add flow again can create a duplicate instead of retrying
stock on the existing commodity. A failed insert can also leave an unused upload.

Use a transactional, retry-safe publish operation for the product and initial lot,
and keep the user's draft available until publication succeeds. Upload cleanup or
reuse must account for failures separately. This finding follows the control flow;
an injected network-failure test was not run against the connected database.

References: `lib/features/farmer/products/presentation/controllers/add_product_screen_actions.dart:48`,
`lib/features/farmer/products/data/farmer_commodity_repository.dart:84`,
`lib/features/farmer/dashboard/presentation/utils/farmer_product_editor_coordinator.dart:53`.

### 3. Approval can remain stale in the product-posting button

The dashboard reads `_canPostProducts` from the account cached by
`AuthSessionService`. Its verification loader updates `_verificationDetails`, but
does not refresh that account or use the fresh details for the posting gate.
There is no approval subscription on this dashboard. Someone who logs in while
pending can remain unable to post after admin approval until their account is
reloaded, for example by signing in again. The repository checks fresh database
status only after the dashboard lets the user enter the add flow.

References: `lib/features/farmer/dashboard/presentation/screens/farmer_dashboard_screen.dart:188`,
`lib/features/farmer/dashboard/presentation/screens/farmer_dashboard_verification.dart:4`.

## Intended flow traced

1. Select Farmer; enter email/password and verify the email OTP.
2. Complete personal details and farm information/location. The current signup UI
   captures farm GPS automatically and retries capture on submission if missing.
3. Submit registration; the backend stores an active farmer with pending
   verification and links the farm. The submitted screen explains admin approval
   and provides Return to login.
4. After admin approval, sign in and open Add new products.
5. Supply photo, name/category/description, price/unit/quantity/minimum order,
   production and selling statuses, and appropriate inventory freshness dates.
6. The client saves the product then its first inventory lot. The buyer marketplace
   exposes it only with available status, a sellable lot with positive stock, and
   an accepting-orders selling option.

The deployed signup RPC also accepts `farm_details_skipped`; the current signup UI
reviewed here collects farm information. The product coordinator can prompt for a
farm when a profile has none, but that fallback only creates a farm name, without
location coordinates. Map-based delivery matching needs complete location details.

## Validation and limits

64 existing tests passed across signup validation/screens/GPS, OTP continuation,
signup persistence contracts, product description/editing, write values/mapping,
inventory lots/restocking, product availability, and date rules. These include
local widget/unit tests and local SQL contract harnesses; they do not establish
the full behavior of the deployed signup/publishing APIs.

The connected database has zero farmer profiles after the requested cleanup.
No real email OTP, admin approval, camera/gallery upload, or complete live
signup-to-buyer-visibility session was performed. Findings above are review results;
application/backend fixes have not been made in this review.
