# Email OTP configuration

AgriSell uses Supabase Auth as the only authority for signup email OTPs. The
Flutter client never generates, stores, or logs an OTP.

The hosted Supabase project must keep these Authentication settings enabled:

- Email provider and **Confirm email** enabled.
- Confirm signup email template containing `{{ .Token }}` so the user receives
  the six-digit code expected by the app.
- OTP expiry set to the project's approved security window.
- Signup confirmation resend interval set to at least 60 seconds.
- Production custom SMTP configured before launch; the built-in provider has a
  low project-wide email quota.

Supabase Auth enforces expiry and endpoint rate limits. The app mirrors the
60-second resend cooldown and locks a verification screen after five invalid
entries until a new OTP is requested.
