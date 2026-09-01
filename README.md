# AgriSell

AgriSell is a role-based agricultural marketplace built with Flutter. It
connects buyers, farmers, and riders through product discovery, ordering,
payments, delivery coordination, messaging, and notifications.

The application currently targets Android and the web. Firebase is configured
for both targets, while foreground local notification presentation is
Android-specific.

## Core capabilities

| Role | Main workflows |
| --- | --- |
| Buyer | Browse farms and products, manage a basket, check out with cash on delivery or GCash, track orders, message farmers, manage shipping addresses, and leave feedback. |
| Farmer | Register a farm, manage products and stock, review reservations and payments, select riders, track fulfillment, view order history, and message buyers. |
| Rider | Submit a rider profile, manage availability, receive and accept delivery requests, confirm pickups, capture delivery evidence, complete deliveries, and review performance. |

Shared capabilities include Supabase authentication, role-based navigation,
marketplace messaging, location selection with OpenStreetMap, order and payment
models, Firebase Cloud Messaging, and secure local session persistence.

## Technology

- Flutter and Dart
- Supabase Auth, PostgreSQL, Realtime, Storage, RPCs, and Edge Functions
- Firebase Core and Firebase Cloud Messaging
- `flutter_map` with OpenStreetMap tiles
- Flutter secure storage and shared preferences
- Unit, widget, SQL-contract, and integration tests

## Quick start

### 1. Prepare the project

Install a Flutter SDK that provides Dart `>=3.12.2 <4.0.0`, then run:

```sh
git clone https://github.com/markandoy395/agrisellApp.git
cd agrisellApp
flutter pub get
```

### 2. Add local Supabase configuration

Create `assets/config/supabase.local.json`:

```json
{
  "SUPABASE_URL": "https://your-project.supabase.co",
  "SUPABASE_PUBLISHABLE_KEY": "your-publishable-key"
}
```

This file is ignored by Git. Use only a Supabase publishable/anonymous client
key in the Flutter application; never place a service-role key in this file.

Build-time values override the local asset when needed:

```sh
flutter run --dart-define=SUPABASE_URL=https://your-project.supabase.co --dart-define=SUPABASE_PUBLISHABLE_KEY=your-publishable-key
```

### 3. Run the app

```sh
flutter devices
flutter run -d <device-id>
```

The app starts at the splash screen, restores any secure local session, and
routes authenticated users to the dashboard allowed for their account role and
status.

See [Getting started](docs/getting_started.md) for platform setup, Firebase
notes, optional configuration, and troubleshooting.

## Common checks

```sh
flutter analyze
flutter test
flutter test integration_test/navigation_frame_timing_test.dart
```

The integration test requires a running emulator, simulator, browser, or
connected device. More examples are in [Testing](docs/testing.md).

## Documentation

- [Getting started](docs/getting_started.md) — prerequisites, configuration,
  running the app, and common setup problems
- [Architecture overview](docs/architecture/overview.md) — bootstrap flow,
  layers, feature ownership, and dependency rules
- [Backend and configuration](docs/backend_and_configuration.md) — Supabase,
  migrations, authentication, Firebase notifications, and secret handling
- [Testing](docs/testing.md) — analysis, unit/widget tests, integration tests,
  coverage, and test organization
- [Email OTP configuration](docs/architecture/email_otp_configuration.md) —
  hosted Supabase email verification requirements
- [Notification Edge Function](supabase/functions/send-notification/README.md)
  — FCM sender deployment and required hosted secrets

## Repository layout

```text
lib/
  core/                 App-wide constants, services, theme, utilities, widgets
  features/
    auth/               Authentication, account state, and role routing
    buyer/              Buyer cart, chat, home, orders, and profile
    farmer/             Farmer dashboard, products, reservations, and profile
    rider/              Rider dashboard, deliveries, chat, profile, and safety
    shared/             Cross-role chat, location, orders, payments, and products
assets/                 Fonts, icons, images, logos, and ignored local config
supabase/
  migrations/           Ordered PostgreSQL schema and policy changes
  functions/            Supabase Edge Functions
  templates/            Local Supabase Auth email templates
test/                   Unit, widget, and SQL-contract tests
integration_test/       Device-driven Flutter integration tests
docs/                   Architecture, setup, reports, and archived material
```

The package name remains `agresell_app`; the product name shown to users is
AgriSell.

## Security

- Supabase Auth is the authority for production credentials and email OTPs.
- Database access must remain protected by Row Level Security and authorized
  RPCs.
- Local configuration, signing files, service-account JSON, and private keys
  are ignored and must not be committed.
- Firebase service-account credentials belong only in hosted Edge Function
  secrets, never in the Flutter client.

Before changing application code, review the repository conventions in
`agent.md`.
