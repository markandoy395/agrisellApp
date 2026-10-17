# Signup OTP continuation

Date: 2026-10-16

The user reported successful buyer email verification returning to login, with
step two appearing only after signing in again. Buyer, farmer and rider use the
same OTP screen. Their existing continuation callbacks already advance to
personal information when that screen returns `true`.

Review found two shared races: verification accepted overlapping submissions,
and a late success popped whichever route was current while the OTP widget was
still mounted during its exit animation. A regression test reproduced duplicate
successful completions before the fix. This establishes a local defect; it does
not establish that every reported single-tap device occurrence has this cause.

The controller now rejects overlapping verification/resend operations, disposed
controllers and exhausted attempts. The screen guards completion and captures
its own route before awaiting verification. Success closes only that active
route; a response arriving after navigation cannot pop the signup screen.

Pending-profile and requested-role validation remain in the registration service.
Verification does not create a completed application login or bypass private
navigation. Session-loss cleanup and existing server OTP limits remain intact.
A local-only verification fixture hook allows tests to exercise actual signup
screens; it rejects configured Supabase backends and requires local test mode.

Verification:

- 26 Flutter tests pass across signup continuation, OTP controller/screen races,
  authentication boundaries and adaptive authentication layouts.
- Each role's actual signup screen advances to personal information exactly once
  after duplicate submit callbacks and remains there after navigation monitoring.
- A delayed response after leaving OTP does not dismiss the underlying signup.
- Existing session-loss, private-dialog cleanup and guarded-route tests pass.
- Targeted Dart analysis reports no issues. Modified application sources remain
  below 200 physical lines and contain no prohibited inline style definitions.

No query, schema, storage, authorization policy or hosted configuration changed.
These tests use local fixtures; real email delivery, hosted verification and the
reported single-tap behavior still require device confirmation.
