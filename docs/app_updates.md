# Android APK update popup

The Android app checks `https://markandoy395.github.io/get-agrisell/release.json`
after the splash route is replaced. It compares `buildNumber` with the installed
Android version code, using package_info_plus. Subsequent page navigation can retry
a failed check after five minutes. An update is offered once per app launch.
Offline, invalid metadata, and already-current installs continue normally.

The optional dialog offers Later and Update now. Update now opens the APK in the
external browser using url_launcher. The user must finish downloading, open the
APK, and approve Update in Android. No silent installation is attempted.

This is intentionally public release metadata, containing no user data. Downloads
must be HTTPS APK URLs on the same origin as the configured website. No account
credentials are sent. Authentication guards and logout dialog cleanup remain in
place. No database, private-storage, or query permissions change.

## Prepare each release

From `get-agrisell`, run (choose a higher build number each time):

```powershell
powershell -NoProfile -ExecutionPolicy Bypass -File .\tool\prepare_android_update.ps1 -Version 1.0.6 -BuildNumber 7 -Notes 'Improvements and bug fixes.'
npm.cmd run build
```

The script builds a universal APK with the exact version/build values, copies it
to a versioned filename plus the website's existing `downloads/agrisell.apk`,
and writes `public/release.json` only after the APK build succeeds. The app uses
the versioned filename to avoid downloading an older cached APK. Keep older
versioned APKs available during rollout. The website QR code keeps its existing
download URL. Deploy the entire `get-agrisell/dist` output, including release.json
and downloads, to GitHub Pages. Local changes do not update the hosted website.
The helper builds in the workspace's `.agrisell-release` folder. It copies the
app source, assets and Android project, and omits integration_test from the
temporary release pubspec. The original dependency and integration tests remain
in the source project. This isolates generated files from IDE debug runs and
avoids registering a test-only native plugin in the release APK. Do not run two
release-preparation commands simultaneously; they share this staging folder.

## Test the popup

The seven update service/widget tests and targeted Flutter analysis passed.
The website production build and formatting check passed. All modified application
sources are under 200 lines and introduce no inline Flutter styling.

Install `https://markandoy395.github.io/get-agrisell/downloads/agrisell-1.0.2-3.apk`
first. This APK includes the popup, with installed build number 3. Open the app
with internet access and wait for the login or home screen. Published release
metadata advertises version 1.0.5/build 6, so the update dialog should appear.

Tap Later to continue using the app, or Update now to download build 6. Open that
APK and approve Update in Android. Reopen the upgraded app: the popup should no
longer appear because the installed build matches the published release.

Install build 3 before build 6 when testing. Android normally prevents downgrading
to a lower build number. Use a device that has build 2 or lower, or a separate
test device. The device upgrade still needs manual verification.

Earlier builds failed on generated integration_test Java registration. The
release helper avoids that failure without patching the Flutter SDK or generated
Java. Related upstream reports: https://github.com/flutter/flutter/issues/186800
and https://github.com/flutter/flutter/issues/169336.

Keep the application ID and original APK signing key. The project currently uses
debug signing; changing that key breaks updates to already-installed copies.
Test an upgrade on a phone with the previous APK before distributing a release.

Users on an APK that predates this popup must manually install the first release
containing it. Later releases can be offered from inside the app.

The default website can be overridden at build time using
`--dart-define=AGRISELL_DOWNLOAD_WEBSITE=https://example.com/path/` (include the
trailing slash). If hosting changes, the existing release metadata must remain
reachable until users have upgraded to the new configuration.

References: https://pub.dev/packages/package_info_plus and
https://pub.dev/packages/url_launcher.

## Installed version on Account screens

Buyer, farmer and rider Account overviews and Settings display the installed
version and build number in a shared footer. For this release it reads
`App version 1.0.5 (build 6)`. It uses package_info_plus rather than a hardcoded
version, so older and future APKs display their own package metadata. Version
loading does not block the page; unavailable metadata shows a neutral fallback.
