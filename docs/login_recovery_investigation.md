# Login and password recovery investigation - 2026-10-17

Reported behavior: login rejects an email/password pair, but recovery using the
same email rejects that password with Supabase's `same_password` response.
That response means the candidate matches the recovery user's current password;
it does not identify why the earlier login failed.

Both paths use the central Supabase client. Email is trimmed and lowercased;
passwords are passed unchanged. Login distinguishes invalid credentials from
profile, connection, configuration, and rate-limit failures. Recovery returns
Supabase password-update errors. The inspected device logs contained no auth
diagnostic entries, so the reported account failure remains unconfirmed.

Added debug-only stage markers for sign-in start, credentials accepted, and
profile loaded, plus a short invalid-credentials failure code. These markers
contain no email, password, tokens, server responses, or account identifiers.
An incomplete successful auth response now gets a service error rather than
being returned as an incorrect-password result.

Local mocked tests cover exact password preservation (including whitespace and
punctuation), the common server origin, invalid credentials without profile
reads, and valid credentials followed by denied/missing profiles. They do not
verify the affected hosted account or reproduce its login attempt. No database,
ownership policies, queries, rate limits, or authorization gates were changed.

Next device check: restart with the updated build, retry login once with the
same email, and inspect only the `[auth]` stage lines. Do not record credentials.
