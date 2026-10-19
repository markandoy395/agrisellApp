package com.agresell.agresell_app

import android.content.Context
import com.it_nomads.fluttersecurestorage.FlutterSecureStorageConfig
import com.it_nomads.fluttersecurestorage.NamespacedConfigSource

/** Compatibility guard for flutter_secure_storage 10.3.4's legacy ESP probe. */
internal object SecureStorageMigration {
    private val keysetKeys = setOf(
        "__androidx_security_crypto_encrypted_prefs_key_keyset__",
        "__androidx_security_crypto_encrypted_prefs_value_keyset__",
    )

    fun prepare(context: Context) {
        val config = FlutterSecureStorageConfig(emptyMap())
        val source = NamespacedConfigSource(context, config.effectiveDataPrefsName)
        if (source.getBoolean("ENCRYPTED_PREFERENCES_MIGRATED", false)) return

        val preferences = context.getSharedPreferences(
            config.effectiveDataPrefsName,
            Context.MODE_PRIVATE,
        )
        // Custom ciphers encrypt values, but keep the prefixed keys readable.
        // ESP encrypts keys too. Leave any such entries for the plugin to migrate.
        if (canSkipLegacyProbe(preferences.all.keys, config.sharedPreferencesKeyPrefix)) {
            source.edit().putBoolean("ENCRYPTED_PREFERENCES_MIGRATED", true).commit()
        }
    }

    internal fun canSkipLegacyProbe(keys: Set<String>, prefix: String): Boolean =
        keys.all { it in keysetKeys || it.startsWith("${prefix}_") }
}
