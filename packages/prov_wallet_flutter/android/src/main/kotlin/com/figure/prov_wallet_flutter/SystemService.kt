package com.figure.prov_wallet_flutter

import android.app.KeyguardManager
import android.content.Context
import android.content.pm.PackageManager
import android.content.pm.PackageManager.*
import android.hardware.biometrics.BiometricManager
import android.hardware.biometrics.BiometricManager.Authenticators
import android.hardware.biometrics.BiometricPrompt
import android.os.Build
import android.os.CancellationSignal
import java.lang.Exception
import java.util.concurrent.Executor
import javax.crypto.Cipher
import kotlin.coroutines.resume
import kotlin.coroutines.resumeWithException
import kotlin.coroutines.suspendCoroutine

class AuthenticationHelpException(message: String, val code: String? = null, val details: String? = null) : Exception(message)

class AuthenticationException(message: String, val code: String? = null, val details: String? = null) : Exception(message)

class SystemService(private val packageManager: PackageManager, private val biometricManager: BiometricManager, private val keyguardManager: KeyguardManager, private val executor: Executor) {
    fun hasBiometry(): Boolean {
        val features = setOf(
            FEATURE_FINGERPRINT,
            FEATURE_IRIS,
            FEATURE_FACE
        )

        return features.any { packageManager.hasSystemFeature(it) }
    }

    fun hasStrongBoxKeystore(): Boolean {
        return packageManager.hasSystemFeature(FEATURE_STRONGBOX_KEYSTORE)
    }

    fun canAuthenticate(): Boolean {
        var result = BiometricManager.BIOMETRIC_ERROR_NONE_ENROLLED

        if (Build.VERSION.SDK_INT == 29) {
            result = biometricManager.canAuthenticate()
        }

        if (Build.VERSION.SDK_INT >= 30) {
            val authenticators = Authenticators.BIOMETRIC_STRONG or
                Authenticators.BIOMETRIC_WEAK or
                Authenticators.DEVICE_CREDENTIAL
            result = biometricManager.canAuthenticate(authenticators)
        }

        return result == BiometricManager.BIOMETRIC_SUCCESS || keyguardManager.isDeviceSecure
    }

    suspend fun authenticateCipher(context: Context, cipher: Cipher): Boolean = suspendCoroutine { cont ->
        val cryptoObject = BiometricPrompt.CryptoObject(
            cipher
        )
        val builder = BiometricPrompt.Builder(context)
            .setTitle("Authenticate")
            .setConfirmationRequired(false)

//        if (Build.VERSION.SDK_INT == 29) {
        builder.setDeviceCredentialAllowed(true)
//        }

//        if (Build.VERSION.SDK_INT >= 30) {
//            val authenticators = Authenticators.BIOMETRIC_STRONG or
//                Authenticators.BIOMETRIC_WEAK or
//                Authenticators.DEVICE_CREDENTIAL
//            builder.setAllowedAuthenticators(authenticators)
//        }

        val prompt = builder.build()

        val cancel = CancellationSignal()

        val callback = object: BiometricPrompt.AuthenticationCallback() {
            override fun onAuthenticationSucceeded(result: BiometricPrompt.AuthenticationResult?) {
                cont.resume(result?.cryptoObject?.cipher != null)
            }

            override fun onAuthenticationFailed() {
                cont.resume(false)
            }

            override fun onAuthenticationError(errorCode: Int, errString: CharSequence?) {
                val e = AuthenticationException(errString.toString(), errorCode.toString())
                cont.resumeWithException(e)
            }

            override fun onAuthenticationHelp(helpCode: Int, helpString: CharSequence?) {
                val e = AuthenticationHelpException(helpString.toString(), helpCode.toString())
                cont.resumeWithException(e)
            }
        }

        prompt.authenticate(cryptoObject, cancel, executor, callback)
    }

    suspend fun authenticateBiometry(context: Context): Boolean = suspendCoroutine { cont ->
        val builder = BiometricPrompt.Builder(context)
            .setTitle("Authenticate")
            .setConfirmationRequired(false)

//        if (Build.VERSION.SDK_INT == 29) {
            builder.setDeviceCredentialAllowed(true)
//        }

//        if (Build.VERSION.SDK_INT >= 30) {
//            val authenticators = Authenticators.BIOMETRIC_STRONG or
//                Authenticators.BIOMETRIC_WEAK or
//                Authenticators.DEVICE_CREDENTIAL
//            builder.setAllowedAuthenticators(authenticators)
//        }

        val prompt = builder.build()

        val cancel = CancellationSignal()
        val callback = object: BiometricPrompt.AuthenticationCallback() {
            override fun onAuthenticationSucceeded(result: BiometricPrompt.AuthenticationResult?) {
                cont.resume(true)
            }

            override fun onAuthenticationFailed() {
                cont.resume(false)
            }

            override fun onAuthenticationError(errorCode: Int, errString: CharSequence?) {
                val e = AuthenticationException(errString.toString(), errorCode.toString())
                cont.resumeWithException(e)
            }

            override fun onAuthenticationHelp(helpCode: Int, helpString: CharSequence?) {
                val e = AuthenticationHelpException(helpString.toString(), helpCode.toString())
                cont.resumeWithException(e)
            }
        }

        prompt.authenticate(cancel, executor, callback)
    }
}
