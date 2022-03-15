package com.figure.prov_wallet_flutter


import android.app.KeyguardManager
import android.content.Context
import android.hardware.biometrics.BiometricManager
import android.security.keystore.UserNotAuthenticatedException
import android.util.Log
import androidx.annotation.NonNull
import androidx.preference.PreferenceManager
import io.flutter.embedding.engine.plugins.FlutterPlugin
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.common.MethodChannel.MethodCallHandler
import io.flutter.plugin.common.MethodChannel.Result
import kotlinx.coroutines.*
import java.io.*

class Error {
    companion object {
        const val authenticationException = "authentication_exception"
        const val authenticationHelpException = "authentication_help_exception"
        const val userNotAuthenticated = "user_not_authenticated"
        const val unknown = "unknown"
    }
}

class ProvWalletFlutterPlugin: FlutterPlugin, MethodCallHandler {
    private companion object {
        val TAG = "$ProvWalletFlutterPlugin"
    }

    private lateinit var channel : MethodChannel
    private lateinit var context: Context
    private lateinit var cipherService: CipherService
    private lateinit var systemService: SystemService
    private lateinit var mainScope: CoroutineScope

    override fun onAttachedToEngine(@NonNull flutterPluginBinding: FlutterPlugin.FlutterPluginBinding) {
        val name = "prov_wallet_flutter"
        mainScope = MainScope()
        channel = MethodChannel(flutterPluginBinding.binaryMessenger, name)
        channel.setMethodCallHandler(this)
        context = flutterPluginBinding.applicationContext
        val preferences = PreferenceManager.getDefaultSharedPreferences(context)
        cipherService = CipherService(preferences)
        val packageManager = context.packageManager
        val biometricManager = context.getSystemService(BiometricManager::class.java)
        val keyguardManager = context.getSystemService(KeyguardManager::class.java)
        val executor = context.mainExecutor
        systemService = SystemService(packageManager, biometricManager, keyguardManager, executor)
    }

    override fun onMethodCall(@NonNull call: MethodCall, @NonNull result: Result) {
        mainScope.launch {
            runCatching {
                when (call.method) {
                    "getPlatformVersion" -> {
                        result.success("Android ${android.os.Build.VERSION.RELEASE}")
                    }
                    "meetsRequisites" -> {
                        val meetsRequisites = systemService.hasStrongBoxKeystore()
                        result.success(meetsRequisites)
                    }
                    "hasBiometry" -> {
                        val hasBiometry = systemService.hasBiometry()
                        result.success(hasBiometry)
                    }
                    "canAuthenticate" -> {
                        val canAuthenticate = systemService.canAuthenticate()
                        result.success(canAuthenticate)
                    }
                    "authenticateBiometry" -> {
                        val success = systemService.authenticateBiometry(context)
                        result.success(success)
                    }
                    "resetAuth" -> {
                        val success = cipherService.resetAuthentication()
                        result.success(success)
                    }
                    "encryptKey" -> {
                        val id = call.argument<String>("id")!!
                        val privateKey = call.argument<String>("private_key")!!
                        val useBiometry = call.argument<Boolean>("use_biometry")
                        val secretKey = cipherService.getOrCreateSecretKey(useBiometry)
                        val cipher = cipherService.getCipher(secretKey)

                        var success = systemService.authenticateCipher(context, cipher)
                        if (success) {
                            val encrypted = cipherService.encrypt(cipher, privateKey)
                            success = cipherService.putPref(id, encrypted)
                        }

                        result.success(success)
                    }
                    "decryptKey" -> {
                        val id = call.argument<String>("id")!!
                        var decrypted: String? = null

                        val encrypted = cipherService.getPref(id)
                        if (encrypted != null) {
                            val secretKey = cipherService.getOrCreateSecretKey()
                            val cipher = cipherService.getCipher(secretKey, encrypted.iv)

                            val success = systemService.authenticateCipher(context, cipher)
                            if (success) {
                                decrypted = cipherService.decrypt(cipher, encrypted.data)
                            }
                        }

                        result.success(decrypted)
                    }
                    "removeKey" -> {
                        val id = call.argument<String>("id")!!
                        val success = cipherService.removeKey(id)
                        result.success(success)
                    }
                    "resetKeys" -> {
                        val success = cipherService.clearPin()
                        result.success(success)
                    }
                    "getUseBiometry" -> {
                        val useBiometry = cipherService.getUseBiometry()
                        result.success(useBiometry)
                    }
                    "setUseBiometry" -> {
                        val useBiometry = call.argument<Boolean>("use_biometry")!!
                        val success = cipherService.setUseBiometry(useBiometry)
                        result.success(success)
                    }
                    "getPin" -> {
                        val pin = cipherService.getPin()
                        result.success(pin)
                    }
                    "setPin" -> {
                        val pin = call.argument<String>("pin")!!
                        val success = cipherService.setPin(pin)
                        result.success(success)
                    }
                    "deletePin" -> {
                        val success = cipherService.deletePin()
                        result.success(success)
                    }
                    else -> {
                        result.notImplemented()
                    }
                }
            }.onFailure { e ->
                val stringWriter = StringWriter()
                val printWriter = PrintWriter(stringWriter)
                e.printStackTrace(printWriter)

                var details = e.toString()

                Log.e(TAG, "Exception occurred", e)

                when (e) {
                    is AuthenticationException -> {
                        details = "Code: ${e.code}\n" + details
                        result.error(Error.authenticationException, e.message, details)
                    }
                    is AuthenticationHelpException -> {
                        details = "Code: ${e.code}\n" + details
                        result.error(Error.authenticationHelpException, e.message, details)
                    }
                    is UserNotAuthenticatedException -> {
                        result.error(Error.userNotAuthenticated, e.message, details)
                    }
                    else -> {
                        result.error(Error.unknown, e.message, details)
                    }
                }
            }
        }
    }

    override fun onDetachedFromEngine(@NonNull binding: FlutterPlugin.FlutterPluginBinding) {
        channel.setMethodCallHandler(null)
        mainScope.cancel()
    }
}
