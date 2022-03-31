package com.figure.prov_wallet_flutter

import android.content.Context
import android.content.SharedPreferences
import android.security.keystore.KeyGenParameterSpec
import android.security.keystore.KeyProperties
import android.security.keystore.UserNotAuthenticatedException
import android.util.Log
import java.security.KeyStore
import java.util.*
import javax.crypto.Cipher
import javax.crypto.KeyGenerator
import javax.crypto.SecretKey
import javax.crypto.spec.GCMParameterSpec

class CipherService(private val preferences: SharedPreferences, private val systemService: SystemService) {
    data class Encrypted(val data: String, val iv: String)

    companion object {
        private const val AUTH_TIMEOUT_SECONDS = 60
        private const val ALIAS_PIN = "pin"
        private const val ALIAS_KEY = "key"
        private const val PREF_USE_BIOMETRY = "use_biometry"
        private const val PREF_ENTRY_PREFIX = "entry_"
        private const val PREF_PIN = "pin"
        private const val DEFAULT_USE_BIOMETRY = false
        private const val ANDROID_KEYSTORE = "AndroidKeyStore"
        private val TAG = "$CipherService"

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

    suspend fun encryptKey(context: Context, id: String, privateKey: String): Boolean {
        val secretKey = getOrCreateSecretKey()

        var success = false
        val cipher = getAuthorizedCipher(secretKey, context)
        if (cipher != null) {
            val encrypted = encrypt(cipher, privateKey)
            if (encrypted != null)
            {
                success = putPref(id, encrypted)
            }
        }

        return success
    }

    suspend fun decryptKey(context: Context, id: String): String? {
        var decrypted: String? = null

        val encrypted = getPref(id)
        if (encrypted != null) {
            val secretKey = getOrCreateSecretKey()

            val cipher = getAuthorizedCipher(secretKey, context, encrypted.iv)
            if (cipher != null) {
                decrypted = decrypt(cipher, encrypted.data)
            }
        }

        return decrypted
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
            val cipher = getInitializedCipher(secretKey, encrypted.iv)
            decrypted = decrypt(cipher, encrypted.data)
        }

        return decrypted
    }

    fun setPin(pin: String): Boolean {
        val secretKey = getPinSecretKey()
        val cipher = getInitializedCipher(secretKey)

        var success = false

        val encrypted = encrypt(cipher, pin)
        if (encrypted != null) {
            success = putPref(PREF_PIN, encrypted)
        }

        return success
    }

    fun deletePin(): Boolean {
        return removeKey(PREF_PIN)
    }

    fun getInitializedCipher(secretKey: SecretKey, encodedIv: String? = null): Cipher {
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

    fun encrypt(cipher: Cipher, data: String): Encrypted? {
        val iv = cipher.iv
        val encodedData = data.toByteArray(Charsets.UTF_8)

        var encrypted: Encrypted? = null

        try {
            val encryptedData = cipher.doFinal(encodedData)
            val encodedEncrypted = Base64.getEncoder().encodeToString(encryptedData)
            val encodedIv = Base64.getEncoder().encodeToString(iv)

            encrypted = Encrypted(encodedEncrypted, encodedIv)
        } catch (e: Exception) {
            Log.w(TAG, "Failed to encrypt", e)
        }

        return encrypted
    }

    fun decrypt(cipher: Cipher, data: String): String? {
        val encryptedData = Base64.getDecoder().decode(data)

        var decrypted: String? = null

        try {
            val decryptedData = cipher.doFinal(encryptedData)
            decrypted = String(decryptedData, Charsets.UTF_8)
        } catch (e: Exception) {
            Log.w(TAG, "Failed to decrypt", e)
        }

        return decrypted
    }

    private fun getOrCreateSecretKey(): SecretKey {
        keyStore.getKey(ALIAS_KEY, null)?.let {
            Log.d(TAG, "Getting existing key")

            return it as SecretKey
        }

        Log.d(TAG, "Creating new key")

        val paramsBuilder = KeyGenParameterSpec.Builder(
            ALIAS_KEY,
            KeyProperties.PURPOSE_ENCRYPT or KeyProperties.PURPOSE_DECRYPT
        )
        paramsBuilder.apply {
            setBlockModes(ENCRYPTION_BLOCK_MODE)
            setEncryptionPaddings(ENCRYPTION_PADDING)
            setKeySize(ENCRYPTION_KEY_SIZE)
            setUserAuthenticationRequired(true)
        }

        val types = KeyProperties.AUTH_BIOMETRIC_STRONG or KeyProperties.AUTH_DEVICE_CREDENTIAL
        paramsBuilder.setUserAuthenticationParameters(AUTH_TIMEOUT_SECONDS, types)

        val keyGenParams = paramsBuilder.build()
        val keyGenerator = KeyGenerator.getInstance(
            ENCRYPTION_ALGORITHM,
            ANDROID_KEYSTORE
        )
        keyGenerator.init(keyGenParams)

        return keyGenerator.generateKey()
    }

    fun resetSecretKeys() {
        val aliases = listOf(ALIAS_PIN, ALIAS_KEY)
        for (alias in aliases) {
            try {
                keyStore.deleteEntry(alias)
            } catch (e: Exception) {
                Log.d(TAG, "Failed to delete: $alias", e)
            }
        }
    }

    private fun getPref(id: String): Encrypted? {
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

    private fun putPref(id: String, encrypted: Encrypted): Boolean {
        val prefKey = getDataPrefKey(id)
        val ivPrefKey = getIvPrefKey(id)

        return preferences.edit()
            .putString(prefKey, encrypted.data)
            .putString(ivPrefKey, encrypted.iv)
            .commit()
    }

    private suspend fun getAuthorizedCipher(secretKey: SecretKey, context: Context, encodedIv: String? = null): Cipher? {
        var result: Cipher? = null

        val useBiometry = getUseBiometry() ?: DEFAULT_USE_BIOMETRY
        val cipher = getUnInitializedCipher()
        var didInit = initializeCipher(cipher, secretKey, encodedIv)
        if (didInit) {
            result = cipher
        } else {
            val didAuth = systemService.authenticate(context, useBiometry)
            if (didAuth) {
                didInit = initializeCipher(cipher, secretKey, encodedIv)
                if (didInit) {
                    result = cipher
                }
            }
        }

        return result
    }

    private fun getUnInitializedCipher(): Cipher {
        val transformation = "$ENCRYPTION_ALGORITHM/$ENCRYPTION_BLOCK_MODE/$ENCRYPTION_PADDING"
        return Cipher.getInstance(transformation)
    }

    private fun initializeCipher(cipher: Cipher, secretKey: SecretKey, encodedIv: String? = null): Boolean {
        return try {
            if (encodedIv != null) {
                val iv = Base64.getDecoder().decode(encodedIv)
                val ivSpec = GCMParameterSpec(ENCRYPTION_KEY_SIZE, iv)
                cipher.init(Cipher.DECRYPT_MODE, secretKey, ivSpec)
            } else {
                cipher.init(Cipher.ENCRYPT_MODE, secretKey)
            }

            true
        } catch (e: UserNotAuthenticatedException) {
            false
        }
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
//                .setUnlockedDeviceRequired(true)
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
