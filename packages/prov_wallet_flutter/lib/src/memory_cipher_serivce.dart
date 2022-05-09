import 'package:prov_wallet_flutter/prov_wallet_flutter.dart';

class MemoryCipherService implements CipherService {
  final _privateKeys = <String, String>{};
  var _useBiometry = false;
  String? _pin;

  @override
  Future<String?> get platformVersion async => '';

  @override
  Stream<CipherServiceError> get error => Stream.empty();

  @override
  Future<bool> authenticateBiometry() async {
    return true;
  }

  @override
  Future<bool> resetAuth() async {
    return true;
  }

  @override
  Future<String?> decryptKey({required String id}) async {
    return _privateKeys[id];
  }

  @override
  Future<bool> encryptKey({
    required String id,
    required String privateKey,
  }) async {
    _privateKeys[id] = privateKey;

    return true;
  }

  @override
  Future<bool> removeKey({required String id}) async {
    return _privateKeys.remove(id) != null;
  }

  @override
  Future<BiometryType> getBiometryType() async {
    return BiometryType.faceId;
  }

  @override
  Future<bool> getLockScreenEnabled() async {
    return true;
  }

  @override
  Future<String?> getPin() async {
    return _pin;
  }

  @override
  Future<bool> deletePin() async {
    _pin = null;

    return true;
  }

  @override
  Future<bool> setPin(String pin) async {
    _pin = pin;

    return true;
  }

  @override
  Future<bool?> getUseBiometry() async {
    return _useBiometry;
  }

  @override
  Future<bool> setUseBiometry({
    required bool useBiometry,
  }) async {
    _useBiometry = useBiometry;

    return true;
  }

  @override
  Future<bool> resetKeys() async {
    _privateKeys.clear();

    return true;
  }
}
