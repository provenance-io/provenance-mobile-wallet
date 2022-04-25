import 'dart:async';

import 'package:get_it/get_it.dart';
import 'package:provenance_blockchain_wallet/services/key_value_service/key_value_service.dart';
import 'package:provenance_blockchain_wallet/services/key_value_service/key_value_store.dart';
import 'package:rxdart/rxdart.dart';

class DefaultKeyValueService implements KeyValueService, Disposable {
  DefaultKeyValueService({required KeyValueStore store}) : _store = store;

  final KeyValueStore _store;
  final _streamDatas = <PrefKey, _StreamData>{};

  @override
  ValueStream<KeyValueData<T>> stream<T>(PrefKey key) =>
      _getStreamData<T>(key).stream;

  @override
  Future<bool> containsKey(PrefKey key) async {
    return _store.containsKey(key);
  }

  @override
  Future<bool?> getBool(PrefKey key) async {
    return _store.getBool(key);
  }

  @override
  Future<bool> setBool(PrefKey key, bool value) async {
    await _getStreamData<bool>(key).completer.future;

    final success = await _store.setBool(key, value);
    if (success) {
      _streamDatas[key]?.stream.add(KeyValueData<bool>(data: value));
    }

    return success;
  }

  @override
  Future<bool> removeBool(PrefKey key) async {
    await _getStreamData<bool>(key).completer.future;

    final success = await _store.remove(key);
    if (success) {
      _streamDatas[key]?.stream.add(KeyValueData<bool>());
    }

    return success;
  }

  @override
  Future<String?> getString(PrefKey key) async {
    return _store.getString(key);
  }

  @override
  Future<bool> setString(PrefKey key, String value) async {
    await _getStreamData<String>(key).completer.future;

    final success = await _store.setString(key, value);
    if (success) {
      _streamDatas[key]?.stream.add(KeyValueData<String>(data: value));
    }

    return success;
  }

  @override
  Future<bool> removeString(PrefKey key) async {
    await _getStreamData<String>(key).completer.future;

    final success = await _store.remove(key);
    if (success) {
      _streamDatas[key]?.stream.add(KeyValueData<String>());
    }

    return success;
  }

  @override
  FutureOr onDispose() {
    for (final data in _streamDatas.values) {
      data.stream.close();
    }
  }

  _StreamData<T> _getStreamData<T>(PrefKey key) {
    var streamData = _streamDatas[key];
    if (streamData == null) {
      final data = _StreamData<T>();
      _streamDatas[key] = data;
      _initStream<T>(key, data);
      streamData = data;
    }

    return streamData as _StreamData<T>;
  }

  Future<void> _initStream<T>(PrefKey key, _StreamData<T> data) async {
    final value = await _store.get<T>(key);

    data.stream.add(KeyValueData<T>(data: value));
    data.completer.complete();
  }
}

class _StreamData<T> {
  final completer = Completer();
  final stream = BehaviorSubject<KeyValueData<T>>();
}
