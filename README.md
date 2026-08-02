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

Copy `supabase.local.example.json` to `supabase.local.json`, replace the
publishable-key placeholder, then pass the ignored local file as build-time
configuration:

```sh
flutter run --dart-define-from-file=supabase.local.json
```

A normal build without this flag remains reproducible, but Supabase-backed
features stay unavailable until configuration is supplied.

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

## Rider Phase 2 backend health check

The Rider dashboard can distinguish local network loss from an unavailable
AgriSell backend when a health endpoint is supplied at build time:

```powershell
flutter run --dart-define=RIDER_BACKEND_HEALTH_URL=https://api.example.com/health
```

This setting configures reachability checks only. Availability, dashboard,
delivery, analytics, messaging, notification, and safety repositories remain
explicit local development adapters until authenticated server endpoints are
added. The UI labels unavailable sections instead of presenting local zeros as
production data.
