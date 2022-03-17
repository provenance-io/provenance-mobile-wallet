import 'package:provenance_wallet/services/key_value_service.dart';
import 'package:rxdart/rxdart.dart';

class MemoryKeyValueService implements KeyValueService {
  MemoryKeyValueService({
    Map<String, Object>? data,
  }) : _data = data ?? {};

  final Map<String, Object> _data;

  final _streams = <PrefKey, BehaviorSubject>{};

  @override
  ValueStream<bool?> streamBool(PrefKey key) {
    var stream = _streams[key];
    if (stream == null) {
      stream = BehaviorSubject<bool?>();
      stream.add(_data[key]);
      _streams[key] = stream;
    }

    return stream as BehaviorSubject<bool?>;
  }

  @override
  ValueStream<String?> streamString(PrefKey key) {
    var stream = _streams[key];
    if (stream == null) {
      stream = BehaviorSubject<String?>();
      stream.add(_data[key]);
      _streams[key] = stream;
    }

    return stream as BehaviorSubject<String?>;
  }

  @override
  Future<bool> containsKey(PrefKey key) async {
    return _data.containsKey(key);
  }

  @override
  Future<bool?> getBool(PrefKey key) async {
    return _data[key.name] as bool?;
  }

  @override
  Future<String?> getString(PrefKey key) async {
    return _data[key.name] as String?;
  }

  @override
  Future<bool> remove(PrefKey key) async {
    return _data.remove(key.name) != null;
  }

  @override
  Future<bool> setBool(PrefKey key, bool value) async {
    _data[key.name] = value;

    return true;
  }

  @override
  Future<bool> setString(PrefKey key, String value) async {
    _data[key.name] = value;

    return true;
  }
}
