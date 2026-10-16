# Shared messaging limits

Prepared 2026-10-16; hosted deployment and device verification are pending.
User requested holding deployment until the updated app rollout. A read-only
hosted check confirmed the database gateway hash is configured; matching Edge
Function secret configuration still requires rollout verification.

Buyer, farmer and rider composers use `ChatMessageField` and `ChatLimits`.
The old duplicated text fields and 1,000-character limit were replaced. The
shared component retains Poppins/theme styling, a visible counter and quota hint.
Controller/repository validation also covers quick replies and retries.

| Limit | Scope |
| --- | --- |
| 500 Unicode code points | Each message, including spaces and emoji |
| 10 send attempts per 60 seconds | Account and conversation |
| 100 send attempts per 86,400 seconds | Account, across marketplace and delivery chat |
| 5 newly created threads per 86,400 seconds | Buyer marketplace conversations |
| 30 conversation-start attempts per 86,400 seconds | Account, including reopening existing threads |
| 100 pending offline messages | Rider account queue admission |

Counters use the existing atomic fixed-window infrastructure, not calendar days
or a sliding window. Unicode code points match PostgreSQL `char_length`; a
multi-code-point emoji can consume more than one character. Empty messages are
rejected. Offline queue admission is a local bound; replay is subject to server
quotas and can fail after reconnection.

Rider conversation identities come from authorized delivery assignments. Riders
cannot create arbitrary delivery threads. Existing marketplace threads remain
reopenable without consuming the five-new-thread allowance. Support messaging
retains its existing separate policy.

## Enforcement and access

`ChatRpc` always sends mutations through `application-api`, regardless of the
general gateway build flag. The gateway verifies the caller JWT, uses hashed
account identities and persists attempt counters before forwarding. Failed
business requests consume attempts too. Exhaustion returns HTTP 429 with
`Retry-After`; unavailable counters fail closed with 503. General gateway quotas
also apply. Malformed bodies consume the daily attempt quota; valid message
attempts additionally consume the conversation quota.

Migration `20261016100000_shared_chat_limits.sql` guards inserts on both message
tables and marketplace conversations, preserving existing RLS and RPC contracts.
It checks the current authenticated, non-anonymous, unexpired account and actual
participant identity, validates length, and enforces successful-write quotas
using atomic private counters. New writes require the configured gateway marker,
so direct REST/RPC calls cannot bypass attempt quotas. Trusted service-role work
retains backend access. No public/anonymous grants or client owner IDs are added.
Idempotent delivery retries reuse existing messages without charging another
successful-write quota; gateway attempt quotas still apply.

## Rollout

1. Verify the hosted gateway secret and matching database hash are configured.
2. Deploy the updated `application-api` function and release the updated client.
3. With explicit deployment approval and compatible clients, apply the chat
   migration. Older clients using direct chat RPCs will receive PT403 and need
   an update; this is independent of staged global gateway enforcement.
4. Run `supabase/tests/shared_chat_limits.sql` and the required authentication,
   RLS, injection and existing-account isolation assertions. Run full account
   fixture isolation only in a local/test database.
5. Verify real participant sends, throttling/recovery, offline replay and
   conversation creation with buyer, farmer and rider test accounts.

## Local verification

The isolated PGlite harness exercises Unicode boundaries, per-conversation and
shared account quotas, new/reopened threads, idempotency, unauthorized
participants, ownership tampering, missing gateway markers and invalid sessions.
It uses the existing atomic counter migration. Its digest shim is test-only;
production keeps the existing pgcrypto SHA-256 function. This does not establish
full production-schema isolation or real concurrent network behavior.

Gateway tests cover failed attempts, caller identity hashing, Unicode validation,
429 headers, unavailable counters and conversation-start quotas. Flutter tests
cover shared fields, counters, bounded input, role controllers and gateway
transport. No hosted chat migration or real chat mutation has been performed.
Final checks: 30 Flutter messaging tests and 10 Node gateway tests passed;
isolated SQL quota and rollout-metadata assertions passed. Focused Dart analysis
reported no issues. Changed application sources satisfy the 200-line limit and
widget styling checks. Hosted full-schema assertions remain pending deployment.
