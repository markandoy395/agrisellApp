# Optional farmer farm details and product uploads

Farmer signup step 3 now offers **Skip for now**. Email verification and personal
information remain required. Skipping submits a typed boolean flag and omits
unfinished farm fields and the farm image; personal details and profile photo
remain intact. A duplicate submit is ignored while the request is in progress.

Migration 20261017130000_optional_farmer_farm_details_and_uploads.sql preserves
the current caller, role, email, gateway and identity row lock checks. It records
farm_details_skipped on the farmer and creates no placeholder farm. The profile
completion RPC recognizes that choice so the next login does not resume signup.
Normal registration continues to validate and save farm information. A farmer
without a farm uses the existing farm-name prompt when saving the first product.

Active farmers with pending, verified or needs_information verification may
create categories and commodities. Rejected, suspended and disabled accounts
remain blocked. Policies retain JWT expiry and anonymous checks, farm ownership,
and category/farm consistency. No accounts are automatically verified and no
storage policies, public bucket settings or anonymous grants are changed.
The commodity context query additionally selects account_status for the client
check; all owner IDs remain resolved from the signed-in account.

Verification:
- Before implementation: 18 existing signup/validator/route tests passed; new
  skip and upload-permission tests failed because the behavior was missing.
- Isolated PGlite fixture: signup skip, normal signup, retry without duplicates,
  subsequent profile completion, literal hostile name/category values, pending
  and verified uploads, cross-account read/update/delete/insert denial, category
  ownership tampering, anonymous/missing/expired identity, unverified email,
  missing gateway and blocked account status checks pass.
- Flutter regression coverage includes skip payload/UI, pending upload form,
  normal signup GPS validation, product editing/restocking, signup recovery,
  existing payload persistence and SQL contracts: 48 tests passed with
  flutter test --concurrency=1 across the 11 focused test files.
- All 14 changed/new application sources are at most 200 physical lines;
  no prohibited inline Flutter styling was found. Formatting completed.
- Targeted Dart analysis reported no issues. Its first invocation returned
  an additional telemetry-file permission error in the sandbox; the full
  Flutter analyzer wrapper and a follow-up targeted run stalled and were
  cancelled. A final formatter check passed for all 19 touched Dart files.

Deployment and verification scope: prepared locally, not applied to hosted
Supabase. Apply after the existing 20261017121000, 20261017122000 and
20261017123000 profile repairs and before shipping the client. No production
fixtures or live product uploads were made. PGlite uses a minimal schema and
stubbed existing authentication/gateway helpers; it does not replace full-schema
Supabase checks. The required authentication_boundary.sql,
application_table_rls.sql, sql_injection_boundary.sql,
existing_account_profile_isolation.sql and account_data_isolation.sql suites
still require a fully migrated local/test Supabase database. Hosted rollout and
device end-to-end verification remain outstanding.
