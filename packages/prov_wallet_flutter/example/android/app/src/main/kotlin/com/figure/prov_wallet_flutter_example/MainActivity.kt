package com.figure.prov_wallet_flutter_example

import android.app.KeyguardManager
import android.content.SharedPreferences
import android.hardware.biometrics.BiometricManager
import android.os.Bundle
import android.util.Log
import android.widget.Button
import android.widget.Toast
import androidx.preference.PreferenceManager
import com.figure.prov_wallet_flutter.CipherService
import com.figure.prov_wallet_flutter.SystemService
import io.flutter.embedding.android.FlutterActivity
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.GlobalScope
import kotlinx.coroutines.launch
import java.util.concurrent.Executor

class MainActivity: FlutterActivity() {
    companion object {
        val TAG = "$MainActivity"
    }
    private lateinit var  preferences: SharedPreferences
    private lateinit var cipherService: CipherService
    private lateinit var biometricManager: BiometricManager
    private lateinit var keyguardManager: KeyguardManager
    private lateinit var executor: Executor
    private lateinit var systemService: SystemService

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)

        preferences = PreferenceManager.getDefaultSharedPreferences(this)
        cipherService = CipherService(preferences)
        biometricManager = context.getSystemService(BiometricManager::class.java)
        keyguardManager = context.getSystemService(KeyguardManager::class.java)
        executor = context.mainExecutor
        systemService = SystemService(packageManager, biometricManager, keyguardManager, executor)

        setContentView(R.layout.main)

        findViewById<Button>(R.id.go).apply {
            setOnClickListener {
                GlobalScope.launch {
                    val input = "hello"
                    val encrypted = encrypt(input)
                    if (encrypted != null) {
                        val actual = decrypt(encrypted.data, encrypted.iv)
                        val text = if (actual == input) "Success!" else "Fail!"

                        launch(Dispatchers.Main) {
                            Toast.makeText(this@MainActivity, text, Toast.LENGTH_SHORT).show()
                        }
                    }
                }
            }
        }
    }

    private suspend fun encrypt(data: String): CipherService.Encrypted? {
        var encrypted: CipherService.Encrypted? = null

        val useBiometry = true
        val secretKey = cipherService.getOrCreateSecretKey(useBiometry)
        val cipher = cipherService.getCipher(secretKey, null)
        val success = systemService.authenticateCipher(this@MainActivity, cipher)
        if (success) {
            try {
                encrypted = cipherService.encrypt(cipher, data)
            } catch (e: Exception) {
                Log.e(TAG, "Exception", e)

            }
        }

        return encrypted
    }

    private suspend fun decrypt(data: String, iv: String): String? {
        var decrypted: String? = null

        val useBiometry = true
        val secretKey = cipherService.getOrCreateSecretKey(useBiometry)
        val cipher = cipherService.getCipher(secretKey, iv)
        val success = systemService.authenticateCipher(this@MainActivity, cipher)
        if (success) {
            try {
                decrypted = cipherService.decrypt(cipher, data)
            } catch (e: Exception) {
                Log.e(TAG, "Exception", e)
            }
        }

        return decrypted
    }
}
