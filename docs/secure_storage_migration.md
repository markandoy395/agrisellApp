# Android secure storage startup

The attached Android log reports `Could not decrypt key` from the legacy
EncryptedSharedPreferences (ESP) probe in flutter_secure_storage 10.3.4.
The plugin probes the same preference file used by its current custom ciphers.
Their readable prefixed keys cannot be decrypted as ESP keys, so the probe logs
an error before falling back to the correct cipher backend. This log alone does
not establish lost credentials or a startup crash.

`SecureStorageMigration` runs before plugin registration and Dart startup. It
marks the ESP migration complete only when the default store contains no legacy
encrypted keys: an empty store, keyset metadata, or current prefixed entries.
It changes one migration marker and never deletes data or encryption keys.
Any unknown or mixed entries retain the plugin's normal migration path. Actual
corruption of legacy encrypted entries is not repaired by this guard.

This compatibility code uses the installed plugin's native configuration API and
migration marker; review it when upgrading flutter_secure_storage. Existing
algorithm migration and secure credential encryption remain enabled. Android
backup is already disabled in the manifest. Authentication, ownership, database
policies and query coverage do not change.

Native unit tests cover fresh, current, legacy and mixed key classifications.
Flutter session tests cover preferences migration and credential isolation.
Device verification requires rebuilding/relaunching the Android app; hot reload
cannot apply native startup changes. The supplied performance snapshot is a
separate recording and does not demonstrate that secure storage caused jank.

Validation: all six native migration tests and 16 Flutter session/account tests
passed, including account switching and logout. Targeted Dart analysis reported
no issues. The native test build compiled
the modified Kotlin files. Both application sources are below 200 physical lines
and contain no inline styling. No Kotlin formatter is configured in this project;
formatting follows the existing Kotlin files and `git diff --check` passed.

The 60 Hz recording contains 2,618 frames: 84 builds and 16 rasterizations exceed
16.67 ms (these counts can overlap). Maximum build time is 44.212 ms and maximum
raster time is 29.899 ms. This change does not claim to resolve those frame costs.

Upstream context: [flutter_secure_storage Android migration documentation](https://github.com/juliansteenbakker/flutter_secure_storage).
