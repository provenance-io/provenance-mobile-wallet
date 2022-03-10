import 'package:provenance_wallet/services/key_value_service.dart';

class MemoryKeyValueService implements KeyValueService {
  MemoryKeyValueService({
    Map<String, Object>? data,
  }) : _data = data ?? {};

  final Map<String, Object> _data;

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
