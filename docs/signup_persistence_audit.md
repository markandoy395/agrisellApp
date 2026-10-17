# Signup persistence audit — 2026-10-17

The signup retry defects are now repaired and deployed. Buyer/Farmer completion
updates the caller's existing profile; Farmer completion updates or creates the
owned farm; Rider retry saves the submitted personal/address data. Existing
role/status decisions remain intact. Buyer policy acceptance is stored, and
Rider retry requires the agreements. Missing historical details and consent are
not fabricated: incomplete profiles return to signup completion at login.

The final complete Flutter suite passed 1,426 tests; 15 API tests and Deno type
checking passed. Hosted rolled-back repair contracts verified retry read-back,
literal values, status preservation, farm unit conversion and access denial.
See `profile_edit_persistence_audit.md` for deployment and remaining device-test
limits. Source fixes require a rebuilt application release.

## Buyer signup address dropdowns

Buyer signup address UI follow-up: the single free-text shipping box is replaced
with a street/purok field, the shared province/city/barangay dropdowns used by Edit
Shipping, and an optional postal code. Required address parts must be filled
before signup can complete. The form combines the parts into the existing bound
`shipping_address` RPC value, including `Philippines`; it preserves literal
quotes and wildcard-like characters. Municipality/barangay lists follow the
selected parent area, and the shared 20-suggestion rendering limit applies.
The client change needs a rebuilt application; a live signup was not submitted
as part of this UI follow-up.

Twenty-eight focused tests passed across Buyer signup selection/validation,
literal RPC payloads, completed signup navigation, and shared address autocomplete.
Targeted Dart analysis reports no issues. Source formatting, the 200-line limit
and inline-style checks passed.

## Initial audit record (before repairs)

The initial read-only checks found the following historical state. Statements
below about missing fixes or no deployment describe that initial audit only.

The current form-to-payload and deployed SQL mappings cover Buyer, Farmer and
Rider profile fields. This does **not** establish that every existing signup
is complete. Hosted aggregate queries found incomplete records, and existing
profile retry paths can skip submitted values.

No hosted accounts, records, objects or functions were changed. No signup emails
were sent or synthetic production accounts created. Queries returned only schema
definitions, aggregate counts and account creation months.

## Findings

1. **Existing Buyer/Farmer profiles bypass completion writes.** Both deployed
   private completion functions return an existing profile immediately when its
   identity mapping is present. They do not apply the submitted profile/farm
   payload or clear `signup_stage` in that branch. One hosted Auth account has
   both a Buyer profile and a remaining signup-stage marker. Therefore a success
   response from this branch is not evidence the latest form values were saved.
   Rider registration similarly updates only structured address fields when an
   existing rider identity is present; edits to other signup fields during an
   upload retry are not applied by that RPC. The subsequent Rider client update
   covers its model fields, but not birth date, gender, middle name or notes.
2. **Existing records have gaps.** Of four Buyer profiles, three lack contact
   number, birth date and shipping address; all four lack gender; one lacks first
   and last names. Of six Farmer profiles, two have no farm record, two lack
   structured personal address fields, and three lack years of experience. Of
   two Rider profiles, one lacks birth date, gender, structured address fields,
   license number and consent timestamps. These are database facts, not proof
   the latest form lost those values. Buyer/Rider profiles are attached to Auth
   accounts created in July/August; no completed October Buyer/Rider signup was
   available to establish current end-to-end behavior. Do not invent missing
   personal/farm values or consent dates to repair these records.
3. **Buyer agreement is not persisted.** `_agreesToPolicy` gates submission in
   `SignUpScreen`, but is absent from `SignUpAccountData`, the completion payload
   and its SQL writes. Rider agreement/accuracy booleans do have timestamp writes.
4. **Uploads remain a separate completion stage.** Farmer profile/farm images
   and Rider profile/documents upload after the profile RPC. A successful profile
   insert alone does not prove the files uploaded and their references were
   saved. Farmer upload failure reports partial completion. Existing optional
   Farmer image references are empty; optional absence is not a failed signup.

## Field trace

| Role and input | Form/submission path | Deployed destination |
| --- | --- | --- |
| All: email/password | Supabase Auth credentials and OTP before profile completion | `auth.users`; password managed by Auth, absent from profile RPC payloads |
| Buyer: first/last name, extension, phone, birth date, gender | `SignUpFormControllers.toAccountData` → `SupabaseRegistrationHandler.completeVerifiedBuyerRegistration` | `users.first_name,last_name,extension_name,contact_number,date_of_birth,gender` |
| Buyer: shipping address | Same completion payload | `buyers.shipping_address`; signup does not collect a map pin |
| Farmer: first/middle/last name, suffix, phone, birth date, gender | `FarmerSignupControllers.data` → `FarmerSignupData.toAuthMetadata` → verified completion RPC | Corresponding `farmers` columns |
| Farmer: street, barangay, city, province, postal code, experience | Same Farmer payload | `farmers.address_line,barangay,city_municipality,province,postal_code,years_of_experience` |
| Farm: name, street, barangay, city, province, coordinates | Same Farmer payload, distinct from personal address | `farms.farm_name,farm_location,barangay,city_municipality,province,gps_lat,gps_long` |
| Farm: size/unit, farming type, tenure, irrigation, crops | Same Farmer payload | `farms.farm_size_hectares,farm_size_unit,farming_type,ownership_type,irrigation_type,main_crops,total_crops` |
| Farmer: optional profile/farm images | Separate private bucket upload and owner-filtered row update | `farmers.profile_image_url`, `farms.farm_images` |
| Rider: identity, phone, birth date, gender | Draft → `RiderSignUpSubmissionService` → `RiderRegistrationPayload` → `create_current_rider_registration` | `riders` identity/personal columns; email derived from authenticated account |
| Rider: address, notes, GPS, accuracy, capture time | Same Rider payload | `riders` structured address, location and GPS columns |
| Rider: vehicle, plate, license, selected logistics company | Same Rider payload | `riders.vehicle_type,vehicle_plate_number,license_number,logistics_company_id`; vehicle entity is embedded from Rider |
| Rider: agreements/accuracy confirmation | Boolean payload values | `riders.accepted_terms_at,accepted_privacy_at,confirmed_accuracy_at` |
| Rider: photo and documents | Separate owner-scoped storage upload and record writes | `riders.profile_photo_url`, `rider_documents` |

`farm_size_hectares` retains the entered numeric value with `farm_size_unit`;
this existing contract does not convert square metres to hectares. Verify both
columns when interpreting it. Middle names, suffixes, notes, postal codes and
images can be optional depending on the role/form. Empty optional values alone
do not demonstrate lost input. Password confirmation is validation-only.

## Verification and limits

- Read the actual hosted public/private definitions of all three completion
  RPCs and `current_email_is_verified`. They use fixed search paths and derive
  identity from `auth.uid()`. Reviewed new-record field writes and retry branches.
- Ran `supabase/tests/signup_persistence_audit.sql` against the linked database
  in a read-only transaction. It is a reusable reporting query, not a migration
  or pass/fail assertion. Zero dangling Buyer/Rider identity targets were found;
  two Farmer profiles have no farm and one staged Auth account has a Buyer profile.
- Seventeen local tests across `signup_persistence_contract_test`,
  `rider_registration_payload_test`, `rider_signup_address_persistence_sql_test`,
  `farmer_signup_coordinates_test`, `farmer_signup_farm_step_test` and
  `auth_registration_service_test` passed across focused runs. The new Buyer
  transport test checks the exact JSON body, normalized phone/email, literal
  quotes/wildcards/comment-like address text, and omission of the password.
  It also checks wrong-email and unverified-email rejection before a write.
  The Farmer test checks all form values, units, crop counts and image byte
  retention. These local tests do not execute the hosted profile writes.
- New test formatting, Dart analysis and whitespace checks pass. No application
  source, inline styling, application queries, security boundaries or schema
  were changed. The new Dart test is excluded from the application line limit.
- A fresh verified signup and read-back for each role in a dedicated test
  environment, including actual file uploads and failure/retry cases, is still
  required before claiming end-to-end persistence. Existing historical records
  do not retain every originally entered value, so their missing values cannot
  be reconstructed from this audit.

Repair work should address existing-profile completion explicitly, preserve
owner identity and role/status checks, define Buyer consent persistence if
required, and add transactional test-database round trips. Historical missing
data requires the actual account holder's input. No repair/deployment was
performed as part of this check.
