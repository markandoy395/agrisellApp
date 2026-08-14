# agresell_app

A new Flutter project.

## Getting Started

This project is a starting point for a Flutter application.

A few resources to get you started if this is your first Flutter project:

- [Learn Flutter](https://docs.flutter.dev/get-started/learn-flutter)
- [Write your first Flutter app](https://docs.flutter.dev/get-started/codelab)
- [Flutter learning resources](https://docs.flutter.dev/reference/learning-resources)

For help getting started with Flutter development, view the
[online documentation](https://docs.flutter.dev/), which offers tutorials,
samples, guidance on mobile development, and a full API reference.

## Supabase Flutter connection

Copy `supabase.local.example.json` to
`assets/config/supabase.local.json`, then replace the publishable-key
placeholder. The ignored local configuration is loaded automatically, so the
usual command connects to Supabase:

```sh
flutter run
```

Build-time `--dart-define` values remain available as an override for CI and
release workflows.

The shared login accepts an email, Philippine mobile number, or username, then
reads the authenticated account's stored role and status to choose the
destination screen. A remembered local session stores only an account
identifier; it never stores a password or role.

Supabase Auth and database RLS provide the configured production authentication
path. Automated tests retain an isolated local authentication store populated
only by fixtures under `test/`; the running app never seeds demo accounts.

Production password hashes are owned exclusively by Supabase Auth in its
protected `auth.users` schema. The application profile in `public.users` never
stores a password or password hash.

## Rider backend health check

When Supabase is configured, the Rider dashboard checks the Supabase Auth
health endpoint so it can distinguish local network loss from an unavailable
backend. A separate health endpoint can still be supplied at build time:

```powershell
flutter run --dart-define=RIDER_BACKEND_HEALTH_URL=https://api.example.com/health
```

The override configures reachability checks only. Authenticated Rider data is
loaded from Supabase; if Supabase is not configured, the UI clearly identifies
temporary local data instead of presenting it as production data.
