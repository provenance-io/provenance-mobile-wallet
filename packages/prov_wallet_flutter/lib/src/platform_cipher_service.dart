import 'dart:async';

import 'package:flutter/services.dart';
import 'package:prov_wallet_flutter/prov_wallet_flutter.dart';

class PlatformCipherService implements CipherService {
  static const _channel = const MethodChannel('prov_wallet_flutter');

  @override
  Future<String?> get platformVersion async {
    final String? version = await _channel.invokeMethod('getPlatformVersion');

    return version;
  }

  @override
  Future<bool> biometryAuth() async {
    final success = await _channel.invokeMethod('biometryAuth');

    return success;
  }

  @override
  Future<void> resetAuth() async {
    await _channel.invokeMethod('resetAuth');
  }

  @override
  Future<bool> getUseBiometry() async {
    final result = await _channel.invokeMethod('getUseBiometry');

    return result;
  }

  @override
  Future<bool> setUseBiometry({required bool useBiometry}) async {
    var params = {
      'use_biometry': useBiometry,
    };

    final result = await _channel.invokeMethod('setUseBiometry', params);

    return result;
  }

  @override
  Future<bool> encryptKey({
    required String id,
    required String privateKey,
    bool? useBiometry,
  }) async {
    var params = {
      "id": id,
      "private_key": privateKey,
      "use_biometry": useBiometry,
    };

    final result = await _channel.invokeMethod('encryptKey', params);

    return result;
  }

  @override
  Future<String> decryptKey({
    required String id,
  }) async {
    var params = {
      'id': id,
    };

    final result = await _channel.invokeMethod('decryptKey', params);

    return result;
  }

  @override
  Future<bool> removeKey({required String id}) async {
    var params = {
      'id': id,
    };

    return await _channel.invokeMethod('removeKey', params);
  }

  @override
  Future<bool> reset() async {
    return await _channel.invokeMethod('resetKeys');
  }

  @override
  Future<String?> getPin() async {
    return await _channel.invokeMethod('getPin');
  }

  @override
  Future<bool> setPin(String pin) async {
    return await _channel.invokeMethod('setPin', {'pin': pin});
  }

  @override
  Future<bool> deletePin() async {
    return await _channel.invokeMethod('deletePin');
  }
}
