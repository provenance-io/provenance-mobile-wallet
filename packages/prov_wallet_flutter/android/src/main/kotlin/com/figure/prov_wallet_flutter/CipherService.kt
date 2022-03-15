package com.figure.prov_wallet_flutter

import android.content.SharedPreferences
import android.security.keystore.KeyGenParameterSpec
import android.security.keystore.KeyProperties
import java.security.KeyStore
import java.util.*
import javax.crypto.Cipher
import javax.crypto.KeyGenerator
import javax.crypto.SecretKey
import javax.crypto.spec.GCMParameterSpec

class CipherService(private val preferences: SharedPreferences) {
    data class Encrypted(val data: String, val iv: String)

    companion object {
        private const val ALIAS_PIN = "pin"
        private const val ALIAS_BIOMETRY_ON = "biometry_on"
        private const val ALIAS_BIOMETRY_OFF = "biometry_off"
        private const val PREF_USE_BIOMETRY = "use_biometry"
        private const val PREF_ENTRY_PREFIX = "entry_"
        private const val PREF_PIN = "pin"
        private const val DEFAULT_USE_BIOMETRY = false
        private const val ANDROID_KEYSTORE = "AndroidKeyStore"

        const val ENCRYPTION_BLOCK_MODE = KeyProperties.BLOCK_MODE_GCM
        const val ENCRYPTION_PADDING = KeyProperties.ENCRYPTION_PADDING_NONE
        const val ENCRYPTION_ALGORITHM = KeyProperties.KEY_ALGORITHM_AES
        const val ENCRYPTION_KEY_SIZE = 128
    }

    private val keyStore: KeyStore by lazy {
        KeyStore.getInstance(ANDROID_KEYSTORE).apply {
            load(null)
        }
    }

    fun resetAuthentication(): Boolean {
        // Timeout is the only supported method
        return true
    }

    fun removeKey(id: String): Boolean {
        val prefKey = getDataPrefKey(id)
        val ivPrefKey = getIvPrefKey(id)

        return preferences.edit()
            .remove(prefKey)
            .remove(ivPrefKey)
            .commit()
    }

    fun clearPin(): Boolean {
        return removeKey(PREF_PIN)
    }

    fun getUseBiometry(): Boolean? {
        if (preferences.contains(PREF_USE_BIOMETRY)) {
            return preferences.getBoolean(PREF_USE_BIOMETRY, DEFAULT_USE_BIOMETRY)
        }

        return null
    }

    fun setUseBiometry(useBiometry: Boolean): Boolean {
        return preferences.edit()
            .putBoolean(PREF_USE_BIOMETRY, useBiometry)
            .commit()
    }

    fun getPin(): String? {
        var decrypted: String? = null

        val secretKey = getPinSecretKey()
        val encrypted = getPref(PREF_PIN)
        if (encrypted != null) {
            val cipher = getCipher(secretKey, encrypted.iv)
            decrypted = decrypt(cipher, encrypted.data)
        }

        return decrypted
    }

    fun setPin(pin: String): Boolean {
        val secretKey = getPinSecretKey()
        val cipher = getCipher(secretKey)

        val encrypted = encrypt(cipher, pin)

        return putPref(PREF_PIN, encrypted)
    }

    fun deletePin(): Boolean {
        return removeKey(PREF_PIN)
    }

    fun getCipher(secretKey: SecretKey, encodedIv: String? = null): Cipher {
        val transformation = "$ENCRYPTION_ALGORITHM/$ENCRYPTION_BLOCK_MODE/$ENCRYPTION_PADDING"
        val cipher: Cipher = Cipher.getInstance(transformation)

        if (encodedIv != null) {
            val iv = Base64.getDecoder().decode(encodedIv)
            val ivSpec = GCMParameterSpec(ENCRYPTION_KEY_SIZE, iv)
            cipher.init(Cipher.DECRYPT_MODE, secretKey, ivSpec)
        } else {
            cipher.init(Cipher.ENCRYPT_MODE, secretKey)
        }

        return cipher
    }

    fun encrypt(cipher: Cipher, data: String): Encrypted {
        val iv = cipher.iv

        val encodedData = data.toByteArray(Charsets.UTF_8)
        val encrypted = cipher.doFinal(encodedData)
        val encodedEncrypted = Base64.getEncoder().encodeToString(encrypted)
        val encodedIv = Base64.getEncoder().encodeToString(iv)

        return Encrypted(encodedEncrypted, encodedIv)
    }

    fun decrypt(cipher: Cipher, data: String): String {
        val encryptedData = Base64.getDecoder().decode(data)

        val decryptedData = cipher.doFinal(encryptedData)
        return String(decryptedData, Charsets.UTF_8)
    }

    fun getOrCreateSecretKey(useBiometry: Boolean? = null): SecretKey {
        val doUseBiometry = useBiometry ?: getUseBiometry() ?: DEFAULT_USE_BIOMETRY
        val keyAlias = if (doUseBiometry) ALIAS_BIOMETRY_ON else ALIAS_BIOMETRY_OFF
        keyStore.getKey(keyAlias, null)?.let {
            return it as SecretKey
        }

        val paramsBuilder = KeyGenParameterSpec.Builder(
            keyAlias,
            KeyProperties.PURPOSE_ENCRYPT or KeyProperties.PURPOSE_DECRYPT
        )
        paramsBuilder.apply {
            setBlockModes(ENCRYPTION_BLOCK_MODE)
            setEncryptionPaddings(ENCRYPTION_PADDING)
            setKeySize(ENCRYPTION_KEY_SIZE)
            setUserAuthenticationRequired(true)
        }

        val keyGenParams = paramsBuilder.build()
        val keyGenerator = KeyGenerator.getInstance(
            ENCRYPTION_ALGORITHM,
            ANDROID_KEYSTORE
        )
        keyGenerator.init(keyGenParams)

        return keyGenerator.generateKey()
    }

    fun getPref(id: String): Encrypted? {
        var encrypted: Encrypted? = null

        val dataPrefKey = getDataPrefKey(id)
        val ivPrefKey = getIvPrefKey(id)

        val data = preferences.getString(dataPrefKey, null)
        val iv = preferences.getString(ivPrefKey, null)

        if (data != null && iv != null) {
            encrypted = Encrypted(data, iv)
        }

        return encrypted
    }

    fun putPref(id: String, encrypted: Encrypted): Boolean {
        val prefKey = getDataPrefKey(id)
        val ivPrefKey = getIvPrefKey(id)

        return preferences.edit()
            .putString(prefKey, encrypted.data)
            .putString(ivPrefKey, encrypted.iv)
            .commit()
    }

    private fun getPinSecretKey(): SecretKey {
        var entry = keyStore.getEntry(ALIAS_PIN, null) as? KeyStore.SecretKeyEntry
        if (entry == null) {
            val keyGenerator = KeyGenerator.getInstance(
                ENCRYPTION_ALGORITHM,
                ANDROID_KEYSTORE
            )
            val purposes = KeyProperties.PURPOSE_ENCRYPT or KeyProperties.PURPOSE_DECRYPT
            val builder = KeyGenParameterSpec.Builder(ALIAS_PIN, purposes)
                .setBlockModes(KeyProperties.BLOCK_MODE_GCM)
                .setEncryptionPaddings(KeyProperties.ENCRYPTION_PADDING_NONE)
                .setKeySize(ENCRYPTION_KEY_SIZE)
                .setUnlockedDeviceRequired(true)
                .setInvalidatedByBiometricEnrollment(false)

            val spec = builder.build()
            keyGenerator.init(spec)

            // Stores the key
            keyGenerator.generateKey()
        }

        entry = keyStore.getEntry(ALIAS_PIN, null) as KeyStore.SecretKeyEntry

        return entry.secretKey
    }

    private fun getDataPrefKey(id: String): String {
        return PREF_ENTRY_PREFIX + id
    }

    private fun getIvPrefKey(id: String) : String {
        return PREF_ENTRY_PREFIX + id + "_iv"
    }
}
