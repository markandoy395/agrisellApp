# Getting started

This guide prepares a local AgriSell development environment and explains how
the application chooses its backend configuration.

## Prerequisites

- Git
- Flutter with a Dart SDK compatible with `^3.12.2`
- Android Studio and an Android SDK for Android development, or a supported
  browser for web development
- A Supabase project and its project URL and publishable key
- Node.js and npm only when using the repository's local Supabase CLI
- Docker Desktop (or another compatible Docker runtime) when starting the
  local Supabase stack

Confirm the primary tools before continuing. The Dart version must satisfy
`>=3.12.2 <4.0.0`:

```sh
flutter doctor
flutter --version
```

Resolve any required Android toolchain or license issues reported by
`flutter doctor`.

## Install dependencies

```sh
git clone https://github.com/markandoy395/agrisellApp.git
cd agrisellApp
flutter pub get
```

The JavaScript dependency in `package.json` provides a project-local Supabase
CLI. Install it only when you need local database or Edge Function tooling:

```sh
npm install
npx supabase --version
```

## Configure Supabase

The normal local-development path loads an ignored Flutter asset. Create
`assets/config/supabase.local.json` with this shape:

```json
{
  "SUPABASE_URL": "https://your-project.supabase.co",
  "SUPABASE_PUBLISHABLE_KEY": "your-publishable-key"
}
```

The configuration resolver uses the following precedence:

1. `SUPABASE_PUBLISHABLE_KEY` supplied with `--dart-define`, together with the
   optional `SUPABASE_URL` override.
2. `assets/config/supabase.local.json`.
3. No Supabase connection when neither source contains a publishable key.

The repository contains a default project URL for the configured development
project, but it does not contain a private key. Supplying an explicit URL is
recommended when working with another project.

For CI or a one-off run, pass build-time values:

```sh
flutter run --dart-define=SUPABASE_URL=https://your-project.supabase.co --dart-define=SUPABASE_PUBLISHABLE_KEY=your-publishable-key
```

Do not use a Supabase service-role or secret key in a Flutter build. Values
compiled into a client application must be treated as public.

## Firebase configuration

`lib/firebase_options.dart` contains FlutterFire client configuration for
Android and web. The application initializes Firebase during startup and uses
Firebase Cloud Messaging for notifications.

Android also requires the ignored `android/app/google-services.json`. Use the
configuration for the same Firebase Android app as `DefaultFirebaseOptions.android`;
its project ID, sender ID, app ID and API key must agree with the Dart options.
Placeholder native values can break messaging even when Dart options are valid.
Regenerate/download the configuration for `com.agresell.agresell_app` using
FlutterFire or the Firebase console, and supply it separately in CI. Rebuild and
reinstall after changing this file; hot reload cannot update Android resources.
`flutter test test/firebase_configuration_test.dart` verifies an available native
configuration and explicitly skips when that ignored file is absent.

- Android supports FCM token registration and foreground local notification
  display.
- Web has Firebase initialization values, but notification behavior should be
  verified separately when changing web messaging.
- iOS, macOS, Windows, and Linux are not configured in the current
  `DefaultFirebaseOptions` implementation.

If the Firebase project or supported platforms change, regenerate the options
with FlutterFire CLI and validate notification delivery before committing the
result. Never commit a Firebase service-account private key.

## Run on Android

Start an emulator or attach a device, then run:

```sh
flutter devices
flutter run -d <android-device-id>
```

The Android manifest requests network, foreground/background location, and
notification permissions. Runtime prompts still depend on the workflow the
user opens and the Android version.

## Run on the web

```sh
flutter run -d chrome
```

Location, image picking, secure storage, and notification behavior can differ
between Android and browsers. Re-test the affected workflow on both targets
when changing a shared feature.

## Optional rider health endpoint

The rider connectivity service normally checks the configured Supabase Auth
endpoint. A separate reachability endpoint can be supplied without changing
the authenticated data source:

```sh
flutter run --dart-define=RIDER_BACKEND_HEALTH_URL=https://api.example.com/health
```

## Startup behavior

At startup, AgriSell:

1. Locks the app to portrait orientation.
2. Loads the saved font-size preference.
3. Initializes Firebase.
4. Starts Supabase initialization.
5. Renders the app and initializes push-notification handling.
6. Restores the authenticated account and applies account-status and role
   guards before showing a dashboard.

When Supabase is not configured, repositories that support a local fallback
identify that state explicitly. A missing backend configuration must not be
presented as production data.

## Troubleshooting

### Supabase is not initialized

- Confirm the local JSON path is exactly
  `assets/config/supabase.local.json`.
- Confirm the JSON is valid and includes a non-empty
  `SUPABASE_PUBLISHABLE_KEY`.
- Run `flutter clean` followed by `flutter pub get` if an asset change is not
  reflected in the build.

### No Android device is available

Run `flutter doctor` and `flutter devices`, then start an emulator from Android
Studio or enable USB debugging on a physical device.

### Notifications do not arrive

- Confirm the user granted notification permission.
- Confirm the device has a valid FCM token stored in Supabase.
- Confirm the notification Edge Function and database dispatch configuration
  are deployed.
- Review the [notification sender guide](../supabase/functions/send-notification/README.md).

### Email verification does not match the app

Review [Email OTP configuration](architecture/email_otp_configuration.md). The
Flutter client does not generate or validate OTP values by itself.
