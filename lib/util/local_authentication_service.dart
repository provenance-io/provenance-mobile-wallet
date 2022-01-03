import 'dart:developer';
import 'dart:io';

import 'package:flutter/services.dart';
import 'package:flutter_tech_wallet/services/secure_storage_service.dart';
import 'package:flutter_tech_wallet/services/shared_prefs_service.dart';
import 'package:flutter_tech_wallet/util/strings.dart';
import 'package:local_auth/auth_strings.dart';
import 'package:local_auth/error_codes.dart' as auth_error;
import 'package:local_auth/local_auth.dart';

class LocalAuthenticationService {
  final LocalAuthentication _auth = LocalAuthentication();
  final _storage = SecureStorageService();

  bool _isBiometricEnabled = false;
  bool? _hasDeclinedSecureLogin;
  bool _isAuthenticated = false;

  bool get isBiometricEnabled => _isBiometricEnabled;
  bool get isAuthenticated => _isAuthenticated;
  Future<bool> get hasDeclinedSecureLogin async {
    if (_hasDeclinedSecureLogin == null) {
      _hasDeclinedSecureLogin = await _getDeclinedSecureAuth();
    }
    return _hasDeclinedSecureLogin!;
  }

  bool get displayBiometricOption {
    // logDebug('hasBiometrics $hasBiometrics');
    // logDebug('isBiometricEnabled $isBiometricEnabled');
    return hasBiometrics && isBiometricEnabled;
  }

  set isBiometricEnabled(bool enabled) {
    _storeBiometricSetting(enabled);
    _isBiometricEnabled = enabled;
    _saveDeclinedSecureAuth(!enabled);
  }

  bool hasBiometrics = false;
  BiometricType? type;

  String get authType {
    if (type == null) {
      return BiometricStrings.biometric;
    }
    if (Platform.isIOS) {
      return type == BiometricType.face
          ? BiometricStrings.faceId
          : BiometricStrings.touchId;
    }

    return type == BiometricType.face
        ? BiometricStrings.face
        : BiometricStrings.fingerPrint;
  }

  static const iosStrings = IOSAuthMessages(
    cancelButton: BiometricStrings.cancel,
    goToSettingsButton: BiometricStrings.settings,
    goToSettingsDescription: BiometricStrings.setupBiometric,
    lockOut: BiometricStrings.reEnableBiometric,
  );

  static const androidStrings = AndroidAuthMessages(
    cancelButton: BiometricStrings.cancel,
    goToSettingsButton: BiometricStrings.settings,
    goToSettingsDescription: BiometricStrings.setupBiometric,
  );

  deleteStorage() async {
    await _storage.deleteAll();
    _isAuthenticated = false;
    isBiometricEnabled = false;
  }

  Future<bool> initialize() async {
    hasBiometrics = await _auth.canCheckBiometrics;
    if (hasBiometrics) {
      final biometricTypes = await _auth.getAvailableBiometrics();
      if (biometricTypes.contains(BiometricType.face)) {
        type = BiometricType.face;
      } else if (biometricTypes.contains(BiometricType.fingerprint)) {
        type = BiometricType.fingerprint;
      }
    }

    String? bioEnabled = await _storage.read(StorageKey.biometricEnabled);

    if (bioEnabled == 'true') {
      _isBiometricEnabled = true;
    } else {
      _isBiometricEnabled = false;
    }

    return _isBiometricEnabled;
  }

  // only ask if they want biometric once
  _saveDeclinedSecureAuth(bool decline) async {
    await SharedPrefsService().setBool(PrefKey.declinedSecureAuth, decline);
  }

  Future<bool> _getDeclinedSecureAuth() async {
    return await SharedPrefsService().getBool(PrefKey.declinedSecureAuth) ??
        false;
  }

  _storeBiometricSetting(bool enabled) async {
    final storedValue = enabled ? 'true' : 'false';
    await _storage.write(StorageKey.biometricEnabled, storedValue);
  }

  /// trigger biometric hardware
  Future<bool> authenticate({String? message, bool fromLogin = false}) async {
    try {
      // await FlutterNativeCommands.readyToShowAuthScreen(false);
      _isAuthenticated = await _auth.authenticate(
        localizedReason:
            message ?? BiometricStrings.signInWithBiometric(authType),
        useErrorDialogs: true,
        stickyAuth: false,
        biometricOnly: false,
        iOSAuthStrings: iosStrings,
        androidAuthStrings: androidStrings,
      );
      // logDebug('Attempting Authentication: isAuthenticated :$_isAuthenticated');

      _saveDeclinedSecureAuth(false);
    } on PlatformException catch (e) {
      if (e.code == auth_error.notEnrolled) {
        // logError('auth_error.notEnrolled: isAuthenticated :$_isAuthenticated');
        _saveDeclinedSecureAuth(true);
      }

      if (e.code == auth_error.notAvailable) {
        // logError(
        //     'auth_error.notAvailable: {isAuthenticated :$_isAuthenticated');

        _saveDeclinedSecureAuth(true);
      }
      if (e.code == auth_error.lockedOut) {
        // logError('auth_error.lockedOut: {isAuthenticated :$_isAuthenticated');
      }
      if (e.code == auth_error.permanentlyLockedOut) {
        // logError(
        //     'auth_error.permanentlyLockedOut: {isAuthenticated :$_isAuthenticated');
      }
      log('AUTH ' + e.toString());
      log('AUTH ' + e.message.toString());
    }

    if (_isAuthenticated) {
      // await FlutterNativeCommands.readyToShowAuthScreen(true);
    } else if (!fromLogin) {
      // await FlutterNativeCommands.readyToShowAuthScreen(true);
    }

    return _isAuthenticated;
  }
}
