import 'dart:async';

import 'package:flutter/services.dart';
export 'dtos/transaction_message.dart';

class CipherService {
  static const _channel = const MethodChannel('prov_wallet_flutter');

  Future<String?> get platformVersion async {
    final String? version = await _channel.invokeMethod('getPlatformVersion');

    return version;
  }

  Future<bool> getUseBiometry() async {
    final result = await _channel.invokeMethod('getUseBiometry');

    return result;
  }

  Future<bool> setUseBiometry({required bool useBiometry}) async {
    var params = {
      'use_biometry': useBiometry,
    };

    final result = await _channel.invokeMethod('setUseBiometry', params);

    return result;
  }

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

  Future<String> decryptKey({
    required String id,
  }) async {
    var params = {
      'id': id,
    };

    final result = await _channel.invokeMethod('decryptKey', params);

    return result;
  }

  Future<bool> reset() async {
    return await _channel.invokeMethod('reset');
  }
}
