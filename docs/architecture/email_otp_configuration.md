# Email OTP configuration

AgriSell uses Supabase Auth as the only authority for signup email OTPs. The
Flutter client never generates, stores, or logs an OTP.

Role sequencing is intentional:

- Buyer enters email/password, verifies the OTP, then adds personal and
  shipping information.
- Farmer enters email/password, verifies the OTP, then adds personal and farm
  information.
- Rider enters email/password, verifies the OTP, then adds personal, address,
  vehicle, and document information.

Supabase must create a credentials-only Auth record before it can send and
verify a signup OTP. Application profile records are created only after the
email is verified and the full role form is submitted through verified,
authenticated server operations.

The hosted Supabase project must keep these Authentication settings enabled:

- Email provider and **Confirm email** enabled.
- Confirm signup email template containing `{{ .Token }}` so the user receives
  the six-digit code expected by the app.
- Email OTP length set to `6` so it matches the Flutter input and validation.
- OTP expiry set to the project's approved security window.
- Signup confirmation resend interval set to at least 60 seconds.
- Production custom SMTP configured before launch; the built-in provider has a
  low project-wide email quota.

Supabase Auth enforces expiry and endpoint rate limits. The app mirrors the
60-second resend cooldown and locks a verification screen after five invalid
entries until a new OTP is requested.

The checked-in local `supabase/config.toml` sets the email OTP length to `6`.
Hosted environments must still be checked independently because their
dashboard settings are not derived automatically from this file.
