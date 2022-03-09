// @dart=2.12

// import 'package:figure_pay/util/logs/logging.dart';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Wrapper around [SharedPreferences] to consolidate keys and consistency.
class SharedPrefsService {
  SharedPrefsService._();
  factory SharedPrefsService() => _instance ??= SharedPrefsService._();

  static SharedPrefsService? _instance;

  Future<SharedPreferences> get _pref async =>
      await SharedPreferences.getInstance();

  Future<bool> containsKey(PrefKey key) async {
    return (await _pref).containsKey(key.name);
  }

  Future<bool> remove(PrefKey key) async {
    return (await _pref).remove(key.name);
  }

  Future<bool> setBool(PrefKey key, bool value) async {
    return (await _pref).setBool(key.name, value);
  }

  Future<bool?> getBool(PrefKey key) async {
    try {
      return (await _pref).getBool(key.name);
    } catch (e) {
      // logError(e);
      return false;
    }
  }

  Future<String?> getString(PrefKey key) async {
    return (await _pref).getString(key.name);
  }

  Future<bool> setString(PrefKey key, String value) async {
    return (await _pref).setString(key.name, value);
  }
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
}

extension on PrefKey {
  String get name => describeEnum(this);
}
