package com.agresell.agresell_app

import org.junit.Assert.assertFalse
import org.junit.Assert.assertTrue
import org.junit.Test

class SecureStorageMigrationTest {
    private val prefix = "secure-prefix"
    private val keysets = setOf(
        "__androidx_security_crypto_encrypted_prefs_key_keyset__",
        "__androidx_security_crypto_encrypted_prefs_value_keyset__",
    )

    @Test
    fun freshInstallSkipsLegacyProbe() {
        assertTrue(SecureStorageMigration.canSkipLegacyProbe(emptySet(), prefix))
    }

    @Test
    fun currentSessionsWithResidualKeysetsSkipLegacyProbe() {
        val keys = keysets + setOf(
            "${prefix}_auth.supabase.current-session.v1",
            "${prefix}_auth.saved-session.v1.account-a",
            "${prefix}_auth.saved-session.v1.account-b",
        )
        assertTrue(SecureStorageMigration.canSkipLegacyProbe(keys, prefix))
    }

    @Test
    fun emptyLegacyKeysetsSkipLegacyProbe() {
        assertTrue(SecureStorageMigration.canSkipLegacyProbe(keysets, prefix))
    }

    @Test
    fun legacyEncryptedKeysStillRequireMigration() {
        assertFalse(SecureStorageMigration.canSkipLegacyProbe(keysets + "encrypted-key", prefix))
    }

    @Test
    fun mixedLegacyAndCurrentKeysStillRequireMigration() {
        val keys = keysets + setOf("encrypted-key", "${prefix}_session")
        assertFalse(SecureStorageMigration.canSkipLegacyProbe(keys, prefix))
    }

    @Test
    fun similarPrefixIsNotTreatedAsCurrentStorage() {
        assertFalse(SecureStorageMigration.canSkipLegacyProbe(setOf("${prefix}other"), prefix))
    }
}
