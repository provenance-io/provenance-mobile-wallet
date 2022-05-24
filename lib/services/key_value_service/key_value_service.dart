import 'dart:async';

import 'package:rxdart/streams.dart';

class KeyValueData<T> {
  KeyValueData({
    this.data,
  });

  final T? data;

  @override
  int get hashCode => data?.hashCode ?? 0;

  @override
  bool operator ==(Object other) {
    return other is KeyValueData<T> && other.data == data;
  }
}

abstract class KeyValueService {
  KeyValueService._();

  Future<bool> containsKey(PrefKey key);

  ValueStream<KeyValueData<T>> stream<T>(PrefKey key);

  Future<bool?> getBool(PrefKey key);

  Future<bool> setBool(PrefKey key, bool value);

  Future<bool> removeBool(PrefKey key);

  Future<String?> getString(PrefKey key);

  Future<bool> setString(PrefKey key, String value);

  Future<bool> removeString(PrefKey key);
}

enum PrefKey {
  allowCrashlitics,
  defaultChainId,
  enableMultiSig,
  endpoints,
  httpClientDiagnostics500,
  isMockingAssetService,
  isMockingTransactionService,
  isSubsequentRun,
  sessionData,
  sessionSuspendedTime,
  showAdvancedUI,
  showDevMenu,
  testBool,
  testString,
}
