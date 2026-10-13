# Rate limiting and sign-in investigation — 2026-10-05

## Status

Deployed: migration `20261005100000_require_rate_limited_api_gateway.sql`,
`application-api` Edge Function, and updated `send-notification`. A random
gateway secret is stored only in hosted secrets; SQL stores its SHA-256 hash.
The unrelated pending marketplace-address migration was left untouched.

**API enforcement is staged, not complete.** Flutter's relay is enabled with
`--dart-define=SUPABASE_RATE_LIMIT_GATEWAY=true`; the default is false during
fresh-install login diagnosis. Direct REST still bypasses gateway quotas until
`supabase/manual/activate_rate_limit_gateway.sql` is applied. Verify and distribute
compatible clients first: older direct REST APKs receive 403 after activation.
Rollback: `update private.api_gateway_configuration set enforced=false where singleton;`
restores direct REST compatibility, preserving RLS but removing its new quotas.

## Endpoint contracts

| Endpoint | Server protection |
| --- | --- |
| Login/signup/reset/OTP | Supabase Auth native server limits; Auth remains direct |
| Gateway REST/RPC | 300/account/minute |
| Gateway mutations | Additional 120/account/minute |
| Voucher validation | Additional 20/account/minute |
| Financial/code actions | Additional 10/account/minute |
| Support/reports | Additional 10/account/minute |
| Messages | Additional 60/account/minute |
| Valid notification webhook | 600/minute globally, machine secret required |
| Invalid gateway/webhook credentials | Separate global 120/minute allowances |

The atomic, service-only `admin_consume_rate_limit` RPC commits counters before
forwarding, so GET/HEAD and failed requests consume quota. Keys hash verified
account IDs, never client-supplied IDs or forwarding headers. Limits return 429
and `Retry-After`; counter failures deny forwarding with 503. Bodies are bounded
to 1 MiB while streaming. The gateway retains caller JWTs, RLS and RPC ownership
checks. Activated pre-request checks reject missing/spoofed markers. Ordinary
users cannot control gateway configuration or counters. Unused GraphQL privileges
were revoked. Trusted service-role backend work retains its marker bypass.

No custom quota was added to the separate Storage/Realtime services. The hosted
`admin-api` was inspected without redeployment: it already limits login and
mutations, but GET routes lack this new quota. These remain coverage gaps for a
literal “every API route” requirement.

Local Auth TOML retains explicit native quotas and changes email resend spacing
from 1 to 60 seconds. This local change was **not** pushed over hosted Auth/SMTP
settings. Hosted quota values were not independently retrieved. References:
[Auth rate limits](https://supabase.com/docs/guides/auth/rate-limits) and
[API pre-request boundaries](https://supabase.com/docs/guides/api/securing-your-api).

## Verification

- Ten targeted Flutter tests and seven Node gateway tests passed, including
  authentication denial, 429 propagation, caller JWT/bound parameter preservation,
  counter failures, sensitive scopes, and bounded streaming.
- Deno checked both current Edge Function entry points and SDK types successfully.
- Debug APK built and installed while preserving device data. Its sign-in key
  is configured and reached Auth settings with HTTP 200. Device time matches UTC;
  INTERNET permission is granted.
- Hosted rolled-back authentication, application-table RLS, injection, existing
  profile isolation, full login-query, counter and marker checks passed. No
  production account fixtures were created.
- Live negative checks: gateway without bearer 401, preflight 204, webhook without
  secret 401, wrong webhook method 405. No production abuse bursts were sent.
- Modified application sources are below 200 lines with no prohibited inline
  styling; focused Dart analysis passed.

The fresh-install login failure remains unreproduced. Updated error messages
distinguish configuration, authorization, profile, connection and rate failures;
debug logs contain only allowlisted stages and short codes. A new device attempt
and exact message are needed before claiming the underlying login problem fixed.
Real buyer/farmer/rider workflows through the gateway and valid notification
delivery remain unverified. Complete those checks before activating enforcement.

## Rider capacity RPC � 2026-10-13 (deployment pending)

set_current_rider_capacity is called through the same rate-limited Supabase
HTTP client/gateway as existing RPCs and independently invokes the gateway hook.
The existing staged-enforcement gaps still apply; no hosted activation or valid
HTTP capacity-save test was performed. Local RPC tests verify auth and ownership,
not production quotas. See rider_capacity_batching.md.

The pending update_current_rider_delivery_status RPC uses the existing app HTTP
rate-limit gateway and explicitly calls require_rate_limited_gateway. Staged
gateway coverage constraints still apply. Local tests verify ownership and
transitions, not hosted quotas. See rider_status_rpc.md.

Rider earnings (2026-10-13): pending migration 20261013130000 augments existing current_rider_deliveries with caller-assigned payment snapshots, verifies authenticated/non-anonymous/unexpired session and gateway, and records agreed fees only through a server completion trigger. No client identity, dynamic SQL, new public endpoint, anonymous grant, or ordinary-user payment mutation. See docs/rider_earnings.md for isolated verification and outstanding hosted rollout/full-schema assertions.
