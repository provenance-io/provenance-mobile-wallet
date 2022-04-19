import 'package:provenance_wallet/services/key_value_service/key_value_service.dart';

abstract class KeyValueStore {
  Future<bool> containsKey(PrefKey key);

  Future<T?> get<T>(PrefKey key);

  Future<bool> remove(PrefKey key);

  Future<bool> setBool(PrefKey key, bool value);

  Future<bool?> getBool(PrefKey key);

  Future<String?> getString(PrefKey key);

  Future<bool> setString(PrefKey key, String value);

  Future<DateTime?> getDateTime(PrefKey key);

  Future<bool> setDateTime(PrefKey key, DateTime value);
}
