import 'package:flutter/foundation.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

/// Wrapper around [FlutterSecureStorage] to consolidate keys and consistency.
class SecureStorageService {
  static SecureStorageService? _instance;
  SecureStorageService._();
  factory SecureStorageService() => _instance ??= SecureStorageService._();

  static const _storage = FlutterSecureStorage();

  Future<void> deleteAll() {
    return _storage.deleteAll();
  }

  Future<String?> read(StorageKey key) async {
    final value = await _storage.read(key: key.name);
    return value;
  }

  Future<void> write(StorageKey key, String? value) async {
    await _storage.write(key: key.name, value: value);
  }

  Future<void> delete(StorageKey key) => _storage.delete(key: key.name);
}

enum StorageKey { biometricEnabled, privateKey, code, accountName }

extension on StorageKey {
  String get name {
    switch (this) {
      case StorageKey.biometricEnabled:
        return 'biometricEnabled';
      case StorageKey.privateKey:
        return 'privateKey';
      case StorageKey.code:
        return 'code';
      case StorageKey.accountName:
        return 'accountName';
      default:
        return describeEnum(this);
    }
  }
}
