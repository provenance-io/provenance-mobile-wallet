import 'package:protobuf/protobuf.dart';
import 'package:provenance_blockchain_wallet/util/messages/message_field.dart';
import 'package:provenance_blockchain_wallet/util/messages/message_field_group.dart';
import 'package:provenance_blockchain_wallet/util/messages/message_field_key.dart';
import 'package:provenance_blockchain_wallet/util/strings.dart';

typedef MessageFieldConverter = Object? Function(Object? obj);

class MessageFieldProcessor {
  MessageFieldProcessor({
    Map<String, MessageFieldConverter?> converters = const {},
  }) : _converters = converters;

  final Map<String, MessageFieldConverter?> _converters;

  MessageFieldGroup findFields(Map<String, dynamic> data) {
    final key = MessageFieldKey('root', '');
    final parent = MessageFieldGroup(key);
    _recurseValues(
      parent,
      key,
      data,
    );

    return parent;
  }

  List<String> findPaths(Object? obj) {
    final keys = <String>[];
    _recurseKeys(
      keys,
      '',
      obj,
    );

    return keys;
  }

  void _recurseValues(
    MessageFieldGroup parent,
    MessageFieldKey key,
    Object? obj,
  ) {
    if (obj is String) {
      final converted = _convert(key, obj);
      if (converted is String) {
        parent.fields.add(
          MessageField(
            key,
            converted,
          ),
        );
      } else {
        parent.fields.add(
          MessageField(
            key,
            obj,
          ),
        );
      }
    } else if (obj is int) {
      var converted = _convert(key, obj);
      if (converted is String) {
        parent.fields.add(
          MessageField(
            key,
            converted,
          ),
        );
      } else {
        parent.fields.add(
          MessageField(
            key,
            obj.toString(),
          ),
        );
      }
    } else if (obj is bool) {
      final converted = _convert(key, obj);
      if (converted is String) {
        parent.fields.add(
          MessageField(
            key,
            converted,
          ),
        );
      } else {
        parent.fields.add(
          MessageField(
            key,
            obj ? Strings.transactionFieldTrue : Strings.transactionFieldFalse,
          ),
        );
      }
    } else if (obj is List<dynamic>) {
      final converted = _convert(key, obj);
      if (converted != null) {
        _recurseValues(
          parent,
          key,
          converted,
        );

        return;
      }
      final combine = obj.first is String || obj.first is int;
      if (combine) {
        final value = obj.join('\n');
        parent.fields.add(
          MessageField(
            key,
            value,
          ),
        );
      } else {
        for (var i = 0; i < obj.length; i++) {
          final newKeyName = '${key.name} ${i + 1}';
          final newKeyPath = _joinKey(key.path, newKeyName);
          final newKey = MessageFieldKey(newKeyName, newKeyPath);
          final newParent = MessageFieldGroup(newKey);
          parent.fields.add(newParent);
          final item = obj[i];
          _recurseValues(
            newParent,
            newKey,
            item,
          );
        }
      }
    } else if (obj is Map<String, dynamic>) {
      final converted = _convert(key, obj);
      if (converted != null) {
        _recurseValues(
          parent,
          key,
          converted,
        );

        return;
      } else {
        for (final entry in obj.entries) {
          final newKeyName = entry.key;
          final newKeyPath = _joinKey(key.path, newKeyName);
          final newKey = MessageFieldKey(newKeyName, newKeyPath);
          _recurseValues(
            parent,
            newKey,
            entry.value,
          );
        }
      }
    }
  }

  Object? _convert(MessageFieldKey key, Object? obj) {
    final converter = _converters[key.path] ?? _converters[key.name];

    return converter?.call(obj);
  }

  void _recurseKeys(
    List<String> keys,
    String key,
    Object? obj,
  ) {
    if (obj is String) {
      keys.add(key);
    } else if (obj is bool) {
      keys.add(key);
    } else if (obj is List<dynamic>) {
      for (var i = 0; i < obj.length; i++) {
        final item = obj[i];
        _recurseKeys(
          keys,
          _joinKey(key, i.toString()),
          item,
        );
      }
    } else if (obj is Map<String, dynamic>) {
      for (final entry in obj.entries) {
        _recurseKeys(
          keys,
          _joinKey(key, entry.key),
          entry.value,
        );
      }
    } else if (obj is GeneratedMessage) {
      _recurseKeys(
        keys,
        key,
        obj.toProto3Json(),
      );
    }
  }

  String _joinKey(String first, String second) {
    return first.isEmpty ? second : '$first/$second';
  }
}
