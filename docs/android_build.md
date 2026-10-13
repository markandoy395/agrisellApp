# Android dependency resolution

Flutter's SDK `integration_test` plugin participates in debug Android builds,
including a normal `flutter run`. It currently requests floating AndroidX
versions: `runner:1.2+`, `rules:1.2+`, and `espresso-core:3.3+`.

`android/build.gradle.kts` replaces only these requests with `1.2.0`, `1.2.0`,
and `3.3.0`, respectively, across all projects. Explicit dependency versions
are unchanged, and Gradle still resolves transitive version conflicts normally
(for example, Espresso can select a newer runner). This avoids Maven version
listing requests for those floating dependencies without modifying the Flutter
SDK or generated `.flutter-plugins-dependencies` file.

If a build reports that the Google repository is disabled, inspect the first
network error in the Gradle output. Missing artifacts still require access to
Google Maven and Maven Central; version pinning does not repair connectivity.
Keep existing caches while investigating connectivity.

To verify the failing tasks with dependencies already cached, run from `android/`
using a terminal with `JAVA_HOME` set to the JDK used by Flutter:

```powershell
.\gradlew.bat :app:checkDebugAarMetadata :integration_test:compileDebugJavaWithJavac --offline --console=plain
```

Then run `flutter build apk --debug` from the project root and `flutter run`
with the intended device connected. An offline task check alone does not verify
APK assembly or device launch.

## Firebase Kotlin migration warning

Checked on October 13, 2026: the lockfile already resolves `firebase_core`
4.15.0, the latest published release. Its Android script applies KGP on AGP 8
or when built-in Kotlin is disabled, and supports built-in Kotlin on AGP 9.
Flutter 3.44.4 detects the declaration by scanning script text, including
conditional declarations, rather than checking whether that branch executes.

This project uses Flutter 3.44.4 and AGP 8.11.1. Keep
`android.builtInKotlin=false`: Flutter's documented supported path for enabling
built-in Kotlin requires Flutter 3.47+ and AGP 9+. Changing the flag on this
toolchain is not a supported fix. The app already uses the migrated compiler
options DSL and does not explicitly apply KGP in its app plugin block.

The same warning has been reported with Firebase 4.14.0 on Flutter 3.47.2 and
AGP 9 with built-in Kotlin enabled. An SDK upgrade alone therefore does not
establish that the warning will disappear. Recheck the detector and Firebase
script when upgrading; do not edit generated plugin metadata or the Pub cache.
The debug APK build passes with the current warning. There is no supported
configuration-only resolution verified for this toolchain.

References:

- [Firebase Core changelog](https://pub.dev/packages/firebase_core/changelog)
- [Flutter migration requirements](https://docs.flutter.dev/release/breaking-changes/migrate-to-built-in-kotlin/for-app-developers)
- [Existing Firebase warning report](https://github.com/firebase/flutterfire/issues/18649)
