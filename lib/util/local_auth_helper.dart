import 'dart:async';
import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter_tech_wallet/common/fw_design.dart';
import 'package:flutter_tech_wallet/dialogs/error_dialog.dart';
import 'package:flutter_tech_wallet/screens/validate_pin.dart';
import 'package:flutter_tech_wallet/services/secure_storage_service.dart';
import 'package:local_auth/auth_strings.dart';
import 'package:local_auth/local_auth.dart';

enum AuthResult { noAccount, success, failure }

class LocalAuthHelper {
  static final LocalAuthHelper _singleton = LocalAuthHelper._internal();
  LocalAuthHelper._internal() {
    initialize();
  }

  factory LocalAuthHelper() => _singleton;

  static LocalAuthHelper get instance => _singleton;

  LocalAuthentication localAuth = LocalAuthentication();
  final storage = SecureStorageService();
  bool hasBiometrics = false;
  BiometricType? type;
  bool isEnabled = false;
  String get authType {
    if (Platform.isIOS) {
      return type == BiometricType.face ? 'Face ID' : 'Touch ID';
    } else {
      return type == BiometricType.face ? 'Face' : 'Fingerprint';
    }
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
    if (bioEnabled != null) {
      if (bioEnabled == 'true') {
        isEnabled = true;
      } else {
        isEnabled = false;
      }
    } else {
      isEnabled = false;
    }
  }

  Future<bool> enroll(
      String privateKey,
      String code,
      String accountName,
      bool biometricEnabled,
      BuildContext context,
      VoidCallback callback) async {
    bool success = true;
    if (biometricEnabled) {
      if (hasBiometrics) {
        await storage.write(StorageKey.biometricEnabled, 'true');
        await storage.write(StorageKey.privateKey, privateKey);
        await storage.write(StorageKey.code, code);
        await storage.write(StorageKey.accountName, accountName);
        callback();
      } else {
        success = false;
        await showDialog(
                  context: context,
                  builder: (context) =>
                      ErrorDialog(error: 'Failed to enroll, try again in settings'));
      }
      // var result = await localAuth.authenticate(
      //   biometricOnly: true,
      //     localizedReason: 'Authenticate',
      //     iOSAuthStrings: IOSAuthMessages(
      //         cancelButton: 'Cancel',
      //         goToSettingsButton: 'Setting',
      //         goToSettingsDescription: 'Setting Description',
      //         lockOut: 'Try again later, your are locked out'));
      // success = result;
      // if (result) {
      //   await storage.write(StorageKey.biometricEnabled, 'true');
      //   await storage.write(StorageKey.privateKey, privateKey);
      //   await storage.write(StorageKey.code, code);
      //   await storage.write(StorageKey.accountName, accountName);
      //   callback();
      // } else {
      //   success = false;
      //   await showDialog(
      //       context: context,
      //       builder: (context) =>
      //           ErrorDialog(error: 'Failed to enroll, try again in settings'));
      // }
    } else {
      await storage.write(StorageKey.biometricEnabled, 'false');
      await storage.write(StorageKey.privateKey, privateKey);
      await storage.write(StorageKey.code, code);
    }
    return success;
  }

  Future<AuthResult> auth(BuildContext context, Function callback) async {
    final accountExists = await storage.read(StorageKey.privateKey);
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
              lockOut: 'Try again later, your are locked out'));
      if (result) {
        final privateKey = await storage.read(StorageKey.privateKey);
        callback(result, privateKey);
        return AuthResult.success;
      } else {
        final code = await storage.read(StorageKey.code);
        final wasSuccessful = await Navigator.of(context).push(
            ValidatePin(code: code?.split("").map((e) => int.parse(e)).toList())
                .route());
        if (wasSuccessful == true) {
          final privateKey = await storage.read(StorageKey.privateKey);
          callback(true, privateKey);
          return AuthResult.success;
        }
        return AuthResult.failure;
      }
    } else {
      final code = await storage.read(StorageKey.code);
      final wasSuccessful = await Navigator.of(context).push(
          ValidatePin(code: code?.split("").map((e) => int.parse(e)).toList())
              .route());
      if (wasSuccessful == true) {
        final privateKey = await storage.read(StorageKey.privateKey);
        callback(true, privateKey);
        return AuthResult.success;
      }
    }

    return AuthResult.failure;
  }
}
