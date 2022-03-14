import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:rxdart/streams.dart';

abstract class KeyValueService {
  KeyValueService._();

  Future<bool> containsKey(PrefKey key);

  Future<bool> remove(PrefKey key);

  Future<bool> setBool(PrefKey key, bool value);

  Future<bool?> getBool(PrefKey key);

  Future<String?> getString(PrefKey key);

  Future<bool> setString(PrefKey key, String value);

  ValueStream<bool?> streamBool(PrefKey key);

  ValueStream<String?> streamString(PrefKey key);
}

enum PrefKey {
  releaseMode,
  declinedSecureAuth,
  privateKey,
  publicKey,
  uuid,
  referralInviteFinished,
  firstBankAccountComplete,
  showSaleDialog,
  showReturnDialog,
  isSubsequentRun,
  sessionData,
  showDevMenu,
  httpClientDiagnostics500,
}

extension on PrefKey {
  String get name => describeEnum(this);
}
