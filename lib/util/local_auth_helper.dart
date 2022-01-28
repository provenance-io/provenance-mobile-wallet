import 'dart:async';
import 'dart:io';

import 'package:provenance_wallet/common/fw_design.dart';
import 'package:provenance_wallet/dialogs/error_dialog.dart';
import 'package:provenance_wallet/screens/pin/validate_pin.dart';
import 'package:provenance_wallet/services/secure_storage_service.dart';
import 'package:local_auth/auth_strings.dart';
import 'package:local_auth/local_auth.dart';

enum AuthResult {
  noAccount,
  success,
  failure,
}

class LocalAuthHelper {
  LocalAuthHelper._internal() {
    initialize();
  }

  factory LocalAuthHelper() => _singleton;

  static final LocalAuthHelper _singleton = LocalAuthHelper._internal();

  LocalAuthentication localAuth = LocalAuthentication();
  final storage = SecureStorageService();
  bool hasBiometrics = false;
  BiometricType? type;
  bool isEnabled = false;
  String get authType {
    // ignore: prefer-conditional-expressions
    if (Platform.isIOS) {
      return type == BiometricType.face ? 'Face ID' : 'Touch ID';
    } else {
      return type == BiometricType.face ? 'Face' : 'Fingerprint';
    }
  }

  static LocalAuthHelper get instance => _singleton;

  Future<void> initialize() async {
    hasBiometrics = await localAuth.canCheckBiometrics;
    if (hasBiometrics) {
      final biometricTypes = await localAuth.getAvailableBiometrics();
      if (biometricTypes.contains(BiometricType.face)) {
        type = BiometricType.face;
      } else if (biometricTypes.contains(BiometricType.fingerprint)) {
        type = BiometricType.fingerprint;
      }
    }

    String? bioEnabled = await storage.read(StorageKey.biometricEnabled);
    // ignore: prefer-conditional-expressions
    if (bioEnabled != null) {
      isEnabled = bioEnabled == 'true' ? true : false;
    } else {
      isEnabled = false;
    }
  }

  Future<bool> enroll(
    String code,
    String accountName,
    bool useBiometry,
    BuildContext context,
    VoidCallback callback,
  ) async {
    bool success = true;
    if (useBiometry && !hasBiometrics) {
      success = false;
      await showDialog(
        context: context,
        builder: (context) =>
            ErrorDialog(error: 'Failed to enroll, try again in settings'),
      );
    } else {
      await storage.write(StorageKey.biometricEnabled, useBiometry.toString());
      await storage.write(StorageKey.code, code);
      await storage.write(StorageKey.accountName, accountName);
      callback();
    }

    return success;
  }

  Future<AuthResult> auth(BuildContext context, Function(bool) callback) async {
    final accountExists = await storage.read(StorageKey.accountName);
    if (accountExists == null || accountExists.isEmpty) {
      return AuthResult.noAccount;
    }

    final biometricEnabled = await storage.read(StorageKey.biometricEnabled);
    if (biometricEnabled == "true") {
      var result = await localAuth.authenticate(
        localizedReason: 'Authenticate',
        biometricOnly: false,
        iOSAuthStrings: IOSAuthMessages(
          cancelButton: 'Cancel',
          goToSettingsButton: 'Setting',
          goToSettingsDescription: 'Setting Description',
          lockOut: 'Try again later, your are locked out',
        ),
      );
      if (result) {
        callback(result);

        return AuthResult.success;
      } else {
        final code = await storage.read(StorageKey.code);
        final wasSuccessful = await Navigator.of(context).push(
          ValidatePin(code: code?.split("").map((e) => int.parse(e)).toList())
              .route(),
        );
        if (wasSuccessful == true) {
          callback(true);

          return AuthResult.success;
        }

        return AuthResult.failure;
      }
    } else {
      final code = await storage.read(StorageKey.code);
      final wasSuccessful = await Navigator.of(context).push(
        ValidatePin(code: code?.split("").map((e) => int.parse(e)).toList())
            .route(),
      );
      if (wasSuccessful == true) {
        callback(true);

        return AuthResult.success;
      }
    }

    return AuthResult.failure;
  }
}
