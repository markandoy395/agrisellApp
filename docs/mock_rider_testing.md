# Rider sample data

Accounts: `mock.rider01@example.com` through `mock.rider30@example.com`.
Password: `AgrisellTest!2026`. All accounts are tagged `rider_mock_v1` in trusted
Auth app metadata and have active rider profiles. Coordinates are sample points
near Malaybalay, Bukidnon; nearby requests use those coordinates.

Each account has 20 completed deliveries across 20 days, one active delivery,
two cancelled deliveries, two failed deliveries, five pending requests,
75 buyer/seller/support conversations with 20 messages each, 500 alerts,
20 ratings, six safety reports, six document records, two withdrawal methods,
and four payout requests. Wallet credits and payout allocations are synthetic.
No external money transfer is performed. Confirmation-code sample proofs use
`123456`; real device pickup/completion flows still require their normal checks.

Rider 01's active job is accepted. Riders 02–06 cover going to pickup, arrived at
pickup, picked up, going to delivery, and arrived at delivery. This cycle repeats.
Sample requests expire 50 minutes after seeding. Live GPS and the online/offline
switch need testing on a device; the seed starts each rider offline.

To seed, concatenate these files in order and execute them as one owner transaction:

1. `supabase/manual/seed_mock_rider_accounts.sql`
2. `supabase/manual/seed_mock_rider_deliveries.sql`
3. `supabase/manual/seed_mock_rider_activity.sql`

The parts skip existing account/delivery/sample-message identifiers. They require
the existing 30 mock buyers and farmers. Do not use the marketplace-only cleanup
script to remove these linked rider fixtures; its foreign keys will block deletion.

Document previews are private PNGs labeled "FOR APP TESTING ONLY". Generate
`supabase/.temp/sample-rider-document.png`, then run
`node scripts/maintenance/upload_mock_rider_documents.cjs` with the existing
backend credential configuration. Each account has one preview referenced by its
six document records. These are placeholders, not real identity documents.

The verification-details RPC had stale `riders.auth_id` and
`riders.verification_status` references. Migration
`20261019120000_repair_rider_verification_identity.sql` resolves the current rider
through the private identity mapping and uses the existing employment-status
mapping for verification. It requires the existing profile session and gateway
guards, returns only the caller's documents/review, and retains the public wrapper.

Validation uses a rolled-back seed, the four mandatory boundary assertions and
rider earnings/payment/status/capacity checks, followed by authenticated gateway
reads for mock riders 01/02. Verification of document preview download uses private
storage with each caller's JWT. Run `verify_mock_rider_data.cjs` for a fresh API
check. These checks do not substitute for device GPS, camera uploads, realtime
updates, withdrawal submission, or end-to-end delivery transitions.

## Larger active and request lists

Run `seed_mock_rider_accounts.sql` followed by `seed_mock_rider_load.sql` as one
transaction to add 30 active jobs and 50 requests to each mock rider. The seed
raises mock rider batch limits to 50, sets cargo capacity within the configured
vehicle maximum, and supplies extra inventory owned by the sample farmers.
The original active job remains, giving 31 active jobs per untouched mock account.
Requests have a 59-minute window. Re-running refreshes still-pending load requests
without resurrecting declined, cancelled, or expired ones.

The nearby endpoint remains capped at 50 rows by default, with active jobs first.
Migration `20261019130000_exclude_terminal_rider_nearby_jobs.sql` prevents completed,
cancelled, and failed history rows from consuming that nearby limit. Delivery
history remains on its existing endpoint. With 31 active jobs, the default nearby
response contains 19 requests; the supported `p_limit=100` returns all 81 current
jobs/requests. The seed does not change the app's configured fetch limit.
