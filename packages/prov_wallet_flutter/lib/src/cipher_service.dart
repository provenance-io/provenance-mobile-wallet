import 'dart:async';

import 'package:prov_wallet_flutter/src/biometry_type.dart';
import 'package:prov_wallet_flutter/src/cipher_service_error.dart';

enum CipherServiceKind {
  platform,
  memory,
}

abstract class CipherService {
  CipherService._();

  Future<String?> get platformVersion;

  Stream<CipherServiceError> get error;

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

  Future<bool> resetKeys();

  Future<String?> getPin();

  Future<bool> setPin(String pin);

  Future<bool> deletePin();
}
