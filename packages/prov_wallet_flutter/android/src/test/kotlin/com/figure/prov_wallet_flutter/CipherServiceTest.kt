package com.figure.prov_wallet_flutter

import android.content.SharedPreferences
import android.content.pm.PackageManager
import android.hardware.biometrics.BiometricManager
import org.junit.Assert.assertEquals
import org.junit.Test
import org.junit.runner.RunWith
import org.mockito.Mock
import org.mockito.junit.MockitoJUnitRunner
import java.security.SecureRandom
import java.util.concurrent.Executor
import javax.crypto.KeyGenerator

@RunWith(MockitoJUnitRunner::class)
class CipherServiceTest {
    @Mock
    private lateinit var mockPreferences: SharedPreferences

    @Mock
    private lateinit var packageManager: PackageManager

    @Mock
    private lateinit var biometricManager: BiometricManager

    @Test
    fun givenInput_thenRoundTrip_expectDecryptedEqualsInput() {
        val executor = Executor { }
        val systemService = SystemService(packageManager, biometricManager, executor)
        val service = CipherService(mockPreferences, systemService)
        val input = "xprv9s21ZrQH143K2JF8RafpqtKiTbsbaxEeUaMnNHsm5o6wCW3z8ySyH4UxFVSfZ8n7ESu7fgir8imbZKLYVBxFPND1pniTZ81vKfd45EHKX73"

        var keyGenerator = KeyGenerator.getInstance(CipherService.ENCRYPTION_ALGORITHM)
        keyGenerator.init(CipherService.ENCRYPTION_KEY_SIZE, SecureRandom.getInstanceStrong())

        val secretKey = keyGenerator.generateKey()
        val encryptCipher = service.getInitializedCipher(secretKey)
        val encrypted = service.encrypt(encryptCipher, input)

        var decrypted: String? = null
        if (encrypted != null) {
            val decryptCipher = service.getInitializedCipher(secretKey, encrypted.iv)
            decrypted = service.decrypt(decryptCipher, encrypted.data)
        }

        assertEquals(input, decrypted)
    }
}
