package com.figure.prov_wallet_flutter_example

import android.app.KeyguardManager
import android.content.SharedPreferences
import android.hardware.biometrics.BiometricManager
import android.os.Bundle
import android.widget.Button
import android.widget.Toast
import androidx.preference.PreferenceManager
import com.figure.prov_wallet_flutter.CipherService
import com.figure.prov_wallet_flutter.SystemService
import io.flutter.embedding.android.FlutterActivity
import kotlinx.coroutines.*
import java.util.concurrent.Executor

class MainActivity: FlutterActivity() {
    companion object {
        val TAG = "$MainActivity"
    }

    private lateinit var mainScope: CoroutineScope
    private lateinit var  preferences: SharedPreferences
    private lateinit var cipherService: CipherService
    private lateinit var biometricManager: BiometricManager
    private lateinit var keyguardManager: KeyguardManager
    private lateinit var executor: Executor
    private lateinit var systemService: SystemService


    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)

        mainScope = MainScope()
        preferences = PreferenceManager.getDefaultSharedPreferences(this)
        biometricManager = context.getSystemService(BiometricManager::class.java)
        keyguardManager = context.getSystemService(KeyguardManager::class.java)
        executor = context.mainExecutor
        systemService = SystemService(packageManager, biometricManager, executor)
        cipherService = CipherService(preferences, systemService)
        cipherService.resetSecretKeys()

        setContentView(R.layout.main)

        findViewById<Button>(R.id.round_trip_bio).apply {
            setOnClickListener {
                mainScope.launch {
                    val input = "hello"
                    val id = "0"
                    cipherService.setUseBiometry(true)
                    var success = cipherService.encryptKey(context, id, input)
                    if (success) {
                        val actual = cipherService.decryptKey(context, id)
                        success = actual == input
                    }

                    val text = if (success) "Success!" else "Fail!"

                    launch(Dispatchers.Main) {
                        Toast.makeText(this@MainActivity, text, Toast.LENGTH_SHORT).show()
                    }
                }
            }
        }
        findViewById<Button>(R.id.round_trip_pin).apply {
            setOnClickListener {
                mainScope.launch {
                    val input = "hello"
                    val id = "0"
                    cipherService.setUseBiometry(false)
                    var success = cipherService.encryptKey(context, id, input)
                    if (success) {
                        val actual = cipherService.decryptKey(context, id)
                        success = actual == input
                    }

                    val text = if (success) "Success!" else "Fail!"

                    launch(Dispatchers.Main) {
                        Toast.makeText(this@MainActivity, text, Toast.LENGTH_SHORT).show()
                    }
                }
            }
        }
        findViewById<Button>(R.id.verify_pin).apply {
            setOnClickListener {
                mainScope.launch {
                    val initial = "123456"
                    cipherService.setPin(initial)
                    val actual = cipherService.getPin()
                    val text = if (initial == actual) "Success!" else "Fail!"

                    launch(Dispatchers.Main) {
                        Toast.makeText(this@MainActivity, text, Toast.LENGTH_SHORT).show()
                    }
                }
            }
        }
        findViewById<Button>(R.id.auth_bio).apply {
            setOnClickListener {
                mainScope.launch {
                    val success = systemService.authenticate(context, useBiometry = true)
                    val text = if (success) "Success!" else "Fail!"

                    launch(Dispatchers.Main) {
                        Toast.makeText(this@MainActivity, text, Toast.LENGTH_SHORT).show()
                    }
                }
            }
        }
        findViewById<Button>(R.id.auth_pin).apply {
            setOnClickListener {
                mainScope.launch {
                    val success = systemService.authenticate(context, useBiometry = false)
                    val text = if (success) "Success!" else "Fail!"

                    launch(Dispatchers.Main) {
                        Toast.makeText(this@MainActivity, text, Toast.LENGTH_SHORT).show()
                    }
                }
            }
        }
        findViewById<Button>(R.id.reset_secret_keys).apply {
            setOnClickListener {
                mainScope.launch {
                    cipherService.resetSecretKeys()

                    launch(Dispatchers.Main) {
                        Toast.makeText(this@MainActivity, "Done", Toast.LENGTH_SHORT).show()
                    }
                }
            }
        }
    }

    override fun onDestroy() {
        mainScope.cancel()

        super.onDestroy()
    }
}
