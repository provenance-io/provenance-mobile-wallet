// @dart=2.12

import 'dart:async';

import 'package:get_it/get_it.dart';
import 'package:rxdart/rxdart.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'key_value_service.dart';

class PlatformKeyValueService implements KeyValueService, Disposable {
  final _streamDatas = <PrefKey, _StreamData>{};
  Future<SharedPreferences>? _lazyPref;
  Future<SharedPreferences> get _pref =>
      (_lazyPref ??= SharedPreferences.getInstance());

  @override
  ValueStream<bool?> streamBool(PrefKey key) {
    var data = _streamDatas[key];
    if (data == null) {
      data = _StreamData<bool>();
      _streamDatas[key] = data;

      _seedStream(key, data);
    }

    return data.stream as BehaviorSubject<bool?>;
  }

  @override
  ValueStream<String?> streamString(PrefKey key) {
    var data = _streamDatas[key];
    if (data == null) {
      data = _StreamData<String>();
      _streamDatas[key] = data;

      _seedStream(key, data);
    }

    return data.stream as BehaviorSubject<String?>;
  }

  @override
  Future<bool> containsKey(PrefKey key) async {
    return (await _pref).containsKey(key.name);
  }

  @override
  Future<bool> remove(PrefKey key) async {
    final success = await (await _pref).remove(key.name);
    if (success) {
      _streamDatas[key]?.stream.add(null);
    }

    return success;
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
  Future<bool> setBool(PrefKey key, bool value) async {
    final data = _streamDatas[key];
    await data?.seeded.future;

    final success = await (await _pref).setBool(key.name, value);
    if (success) {
      _streamDatas[key]?.stream.add(value);
    }

    return success;
  }

  @override
  Future<bool> setString(PrefKey key, String value) async {
    final data = _streamDatas[key];
    await data?.seeded.future;

    final success = await (await _pref).setString(key.name, value);
    if (success) {
      _streamDatas[key]?.stream.add(value);
    }

    return success;
  }

  @override
  FutureOr onDispose() {
    for (final data in _streamDatas.values) {
      data.stream.close();
    }
  }

  Future<void> _seedStream(PrefKey key, _StreamData data) async {
    final value = (await _pref).get(key.name);
    data.stream.value = value;
    data.seeded.complete();
  }
}

class _StreamData<T> {
  final seeded = Completer();
  final stream = BehaviorSubject<T?>.seeded(null);
}
