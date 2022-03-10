// @dart=2.12

import 'package:shared_preferences/shared_preferences.dart';

import 'key_value_service.dart';

///
/// Wrapper around [SharedPreferences] to consolidate keys and consistency.
///
class PlatformKeyValueService implements KeyValueService {
  Future<SharedPreferences>? _lazyPref;
  Future<SharedPreferences> get _pref =>
      (_lazyPref ??= SharedPreferences.getInstance());

  @override
  Future<bool> containsKey(PrefKey key) async {
    return (await _pref).containsKey(key.name);
  }

  @override
  Future<bool> remove(PrefKey key) async {
    return (await _pref).remove(key.name);
  }

  @override
  Future<bool> setBool(PrefKey key, bool value) async {
    return (await _pref).setBool(key.name, value);
  }

  @override
  Future<bool?> getBool(PrefKey key) async {
    try {
      return (await _pref).getBool(key.name);
    } catch (e) {
      // logError(e);
      return false;
    }
  }

  @override
  Future<String?> getString(PrefKey key) async {
    return (await _pref).getString(key.name);
  }

  @override
  Future<bool> setString(PrefKey key, String value) async {
    return (await _pref).setString(key.name, value);
  }
}
