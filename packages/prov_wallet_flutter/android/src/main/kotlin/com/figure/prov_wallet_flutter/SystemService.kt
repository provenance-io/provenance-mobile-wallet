package com.figure.prov_wallet_flutter

import android.content.Context
import android.content.pm.PackageManager
import android.content.pm.PackageManager.*
import android.hardware.biometrics.BiometricManager
import android.hardware.biometrics.BiometricManager.Authenticators.BIOMETRIC_STRONG
import android.hardware.biometrics.BiometricManager.Authenticators.DEVICE_CREDENTIAL
import android.hardware.biometrics.BiometricManager.BIOMETRIC_SUCCESS
import android.hardware.biometrics.BiometricPrompt
import android.os.CancellationSignal
import android.util.Log
import java.util.concurrent.Executor
import kotlin.coroutines.Continuation
import kotlin.coroutines.resume
import kotlin.coroutines.suspendCoroutine

enum class BiometryType(val value: String) {
    None("none"),
    FaceId("face_id"),
    TouchId("touch_id"),
    Unknown("unknown")
}

class SystemService(private val packageManager: PackageManager, private val biometricManager: BiometricManager, private val executor: Executor) {
    companion object {
        private val TAG = "$SystemService"
    }
    fun getBiometryType(): BiometryType {
        val canAuthenticate = biometricManager.canAuthenticate(BIOMETRIC_STRONG) == BIOMETRIC_SUCCESS
        if (canAuthenticate) {
            val faceIdFeatures = setOf(
                FEATURE_IRIS,
                FEATURE_FACE
            )

            val hasFaceId = canAuthenticate && faceIdFeatures.any { packageManager.hasSystemFeature(it) }
            if (hasFaceId) {
                return BiometryType.FaceId
            }

            val hasTouchId = canAuthenticate && packageManager.hasSystemFeature(FEATURE_FINGERPRINT)
            if (hasTouchId) {
                return BiometryType.TouchId
            }

            return BiometryType.Unknown
        }

        return BiometryType.None
    }

    suspend fun authenticate(context: Context, useBiometry: Boolean): Boolean = suspendCoroutine { cont ->
        val builder = BiometricPrompt.Builder(context)
            .setTitle("Authenticate")
            .setConfirmationRequired(false)

        var authenticators = DEVICE_CREDENTIAL
        if (useBiometry) {
            authenticators = authenticators or BIOMETRIC_STRONG
        }
        builder.setAllowedAuthenticators(authenticators)

        val prompt = builder.build()
        val cancel = CancellationSignal()
        val callback = AuthCallback(cont)

        try {
            prompt.authenticate(cancel, executor, callback)
        } catch (e: Exception) {
            Log.w(TAG, "Authentication exception", e)
            cont.resume(false)
        }
    }

    private fun hasStrongBoxKeystore(): Boolean {
        return packageManager.hasSystemFeature(FEATURE_STRONGBOX_KEYSTORE)
    }

    private class AuthCallback(private val cont: Continuation<Boolean>) : BiometricPrompt.AuthenticationCallback() {
        private companion object {
            private val TAG = "$AuthCallback"
        }
        override fun onAuthenticationSucceeded(result: BiometricPrompt.AuthenticationResult?) {
            cont.resume(true)
        }

        override fun onAuthenticationFailed() {
            cont.resume(false)
        }

        override fun onAuthenticationError(errorCode: Int, errString: CharSequence?) {
            Log.w(TAG, "Authentication Error $errorCode: $errString")
            cont.resume(false)
        }

        override fun onAuthenticationHelp(helpCode: Int, helpString: CharSequence?) {
            Log.w(TAG, "Authentication Help $helpCode: $helpString")
        }
    }
}
