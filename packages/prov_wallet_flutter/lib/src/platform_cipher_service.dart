import 'dart:async';

import 'package:flutter/services.dart';
import 'package:prov_wallet_flutter/prov_wallet_flutter.dart';

class CipherServiceError {
  CipherServiceError({
    this.message,
    this.details,
  });

  final String? message;
  final String? details;
}

class PlatformCipherService implements CipherService {
  static const _channel = const MethodChannel('prov_wallet_flutter');

  final _errorStream = StreamController<CipherServiceError>.broadcast();

  Stream<CipherServiceError> get error => _errorStream.stream;

  @override
  Future<String?> get platformVersion async {
    String? version;

    try {
      version = await _channel.invokeMethod('getPlatformVersion');
    } on PlatformException catch (e) {
      _handleException(e);
    }

    return version;
  }

  @override
  Future<bool> authenticateBiometry() async {
    var success = false;

    try {
      success = await _channel.invokeMethod('authenticateBiometry');
    } on PlatformException catch (e) {
      _handleException(e);
    }

    return success;
  }

  @override
  Future<bool> resetAuth() async {
    var success = false;

    try {
      success = await _channel.invokeMethod('resetAuth');
    } on PlatformException catch (e) {
      _handleException(e);
    }

    return success;
  }

  @override
  Future<bool?> getUseBiometry() async {
    bool? result;

    try {
      result = await _channel.invokeMethod('getUseBiometry');
    } on PlatformException catch (e) {
      _handleException(e);
    }

    return result;
  }

  @override
  Future<bool> setUseBiometry({required bool useBiometry}) async {
    var params = {
      'use_biometry': useBiometry,
    };

    var success = false;

    try {
      success = await _channel.invokeMethod('setUseBiometry', params);
    } on PlatformException catch (e) {
      _handleException(e);
    }

    return success;
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

    var success = false;

    try {
      success = await _channel.invokeMethod('encryptKey', params);
    } on PlatformException catch (e) {
      _handleException(e);
    }

    return success;
  }

  @override
  Future<String?> decryptKey({
    required String id,
  }) async {
    var params = {
      'id': id,
    };

    String? key;

    try {
      key = await _channel.invokeMethod('decryptKey', params);
    } on PlatformException catch (e) {
      _handleException(e);
    }

    return key;
  }

  @override
  Future<bool> removeKey({required String id}) async {
    var params = {
      'id': id,
    };

    var success = false;

    try {
      success = await _channel.invokeMethod('removeKey', params);
    } on PlatformException catch (e) {
      _handleException(e);
    }

    return success;
  }

  @override
  Future<bool> reset() async {
    var success = false;

    try {
      success = await _channel.invokeMethod('resetKeys');
    } on PlatformException catch (e) {
      _handleException(e);
    }

    return success;
  }

  @override
  Future<String?> getPin() async {
    String? pin;

    try {
      pin = await _channel.invokeMethod('getPin');
    } on PlatformException catch (e) {
      _handleException(e);
    }

    return pin;
  }

  @override
  Future<bool> setPin(String pin) async {
    var success = false;

    try {
      success = await _channel.invokeMethod('setPin', {'pin': pin});
    } on PlatformException catch (e) {
      _handleException(e);
    }

    return success;
  }

  @override
  Future<bool> deletePin() async {
    var success = false;

    try {
      success = await _channel.invokeMethod('deletePin');
    } on PlatformException catch (e) {
      _handleException(e);
    }

    return success;
  }

  void dispose() {
    _errorStream.close();
  }

  Future<void> _handleException(PlatformException e) async {
    final message = e.message;
    final details = e.details as String?;

    final error = CipherServiceError(
      message: message,
      details: details,
    );

    _errorStream.add(error);
  }
}
