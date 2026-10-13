# Rider delivery status RPC correction — October 13, 2026

The device reported permission denied for function update_delivery_status.
Read-only hosted metadata confirmed the October scope migration revoked EXECUTE
from authenticated on public.update_delivery_status, while Flutter still called
that name. The private implementation retains assigned-rider checks. No live
record or status was changed during inspection.

The client now calls update_current_rider_delivery_status using the same bound
parameter map. The new fixed-search-path security-definer endpoint requires a
valid nonanonymous unexpired session, invokes the existing API gateway hook,
resolves private.current_rider_id(), and independently checks the actual delivery
assignment. It delegates to the existing private transition function, retaining
its row lock, stale-state rejection, idempotency and history contract. Generic
pickup and completion are rejected in favor of their evidence/confirmation
flows. Remarks and coordinates remain literal bound data. Legacy generic RPC
grants remain denied; no RLS/table/storage/realtime grants change.

Verification: 11 targeted Flutter tests passed across the status-RPC client,
Supabase delivery repository and controller. Targeted analysis passed. The
modified application file is 144 lines and contains no prohibited inline styling.
The isolated PGlite harness runs the actual historical private status function
against a scoped schema and verifies owner success, replay, cross-rider denial,
no denied mutation/history, anonymous/expired/missing-session denial, stale state,
pickup/completion bypass rejection and hostile remarks preserved literally.
It does not verify production notifications, GPS or complete delivery workflows.

Deployment is pending explicit approval. The previous automatic review rejected
live schema/authorization changes without explicit approval; this request did not
authorize deployment explicitly. Apply only
20261013120000_restore_rider_status_update_rpc.sql for this fix; the separate
capacity migration is not a dependency and remains separately pending.
Then run rider_status_rpc.sql, authentication_boundary.sql,
application_table_rls.sql, sql_injection_boundary.sql and
existing_account_profile_isolation.sql against the migrated database. These
post-change hosted assertions have not run. Full local account_data_isolation.sql
remains unavailable because local PostgreSQL at 127.0.0.1:54322 is unreachable;
never redirect synthetic-fixture isolation tests to production. No device
status-update test has run with the new endpoint. Deploy it before distributing
the new client; hot restart alone cannot resolve the hosted permission error.
