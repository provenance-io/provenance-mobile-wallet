import 'dart:async';

import 'package:provenance_wallet/services/key_value_service/key_value_service.dart';
import 'package:provenance_wallet/services/key_value_service/key_value_store.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SharedPreferencesKeyValueStore implements KeyValueStore {
  Future<SharedPreferences>? _lazyPref;
  Future<SharedPreferences> get _pref =>
      (_lazyPref ??= SharedPreferences.getInstance());

  @override
  Future<bool> containsKey(PrefKey key) async {
    return (await _pref).containsKey(key.name);
  }

  @override
  Future<T?> get<T>(PrefKey key) async {
    return (await _pref).get(key.name) as T?;
  }

  @override
  Future<bool> remove(PrefKey key) async {
    return (await _pref).remove(key.name);
  }

  @override
  Future<bool?> getBool(PrefKey key) async {
    return (await _pref).getBool(key.name);
  }

  @override
  Future<String?> getString(PrefKey key) async {
    return (await _pref).getString(key.name);
  }

  @override
  Future<bool> setBool(PrefKey key, bool value) async {
    return (await _pref).setBool(key.name, value);
  }

  @override
  Future<bool> setString(PrefKey key, String value) async {
    return (await _pref).setString(key.name, value);
  }

  @override
  Future<DateTime?> getDateTime(PrefKey key) async {
    final stringDate = (await _pref).getString(key.name);

    return DateTime.tryParse(stringDate ?? "");
  }

  @override
  Future<bool> setDateTime(PrefKey key, DateTime value) async {
    return (await _pref).setString(key.name, value.toIso8601String());
  }
}
