import 'dart:async';
import 'dart:io';

import 'package:local_auth/auth_strings.dart';
import 'package:local_auth/local_auth.dart';
import 'package:provenance_wallet/common/pw_design.dart';
import 'package:provenance_wallet/dialogs/error_dialog.dart';
import 'package:provenance_wallet/screens/pin/validate_pin.dart';
import 'package:provenance_wallet/services/secure_storage_service.dart';
import 'package:provenance_wallet/util/get.dart';
import 'package:provenance_wallet/util/strings.dart';

enum AuthResult {
  noAccount,
  success,
  failure,
}

class LocalAuthHelper {
  LocalAuthentication localAuth = LocalAuthentication();
  final storage = get<SecureStorageService>();
  bool hasBiometrics = false;
  BiometricType? type;
  bool isEnabled = false;
  String get authType {
    return Platform.isIOS
        ? type == BiometricType.face
            ? Strings.faceId
            : Strings.touchId
        : type == BiometricType.face
            ? Strings.face
            : Strings.fingerPrint;
  }

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
    isEnabled = bioEnabled != null
        ? bioEnabled == true.toString()
            ? true
            : false
        : false;
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
        useSafeArea: true,
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
