import 'dart:async';

import 'package:prov_wallet_flutter/src/biometry_type.dart';

abstract class CipherService {
  CipherService._();

  Future<String?> get platformVersion;

  Future<BiometryType> getBiometryType();

  Future<bool> getLockScreenEnabled();

  Future<bool> authenticateBiometry();

  Future<bool> resetAuth();

  Future<bool?> getUseBiometry();

  Future<bool> setUseBiometry({required bool useBiometry});

  Future<bool> encryptKey({
    required String id,
    required String privateKey,
  });

  Future<String?> decryptKey({
    required String id,
  });

  Future<bool> removeKey({required String id});

  Future<bool> reset();

  Future<String?> getPin();

  Future<bool> setPin(String pin);

  Future<bool> deletePin();
}
