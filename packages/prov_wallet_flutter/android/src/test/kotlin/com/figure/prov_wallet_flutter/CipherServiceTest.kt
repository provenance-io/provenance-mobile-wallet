package com.figure.prov_wallet_flutter

import android.content.SharedPreferences
import org.junit.Assert.assertEquals
import org.junit.Test
import org.junit.runner.RunWith
import org.mockito.Mock
import org.mockito.junit.MockitoJUnitRunner
import java.security.SecureRandom
import javax.crypto.KeyGenerator

@RunWith(MockitoJUnitRunner::class)
class CipherServiceTest {
    @Mock
    private lateinit var mockPreferences: SharedPreferences

    @Test
    fun givenInput_thenRoundTrip_expectDecryptedEqualsInput() {
        val service = CipherService(mockPreferences)
        val input = "xprv9s21ZrQH143K2JF8RafpqtKiTbsbaxEeUaMnNHsm5o6wCW3z8ySyH4UxFVSfZ8n7ESu7fgir8imbZKLYVBxFPND1pniTZ81vKfd45EHKX73"

        var keyGenerator = KeyGenerator.getInstance(CipherService.ENCRYPTION_ALGORITHM)
        keyGenerator.init(CipherService.ENCRYPTION_KEY_SIZE, SecureRandom.getInstanceStrong())

        val secretKey = keyGenerator.generateKey()
        val encryptCipher = service.getCipher(secretKey)
        val encrypted = service.encrypt(encryptCipher, input)

        val decryptCipher = service.getCipher(secretKey, encrypted.iv)
        val decrypted = service.decrypt(decryptCipher, encrypted.data)

        assertEquals(input, decrypted)
    }
}
