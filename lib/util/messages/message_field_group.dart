import 'package:provenance_blockchain_wallet/util/messages/message_field_key.dart';

class MessageFieldGroup {
  MessageFieldGroup(
    this.key,
  );

  final MessageFieldKey key;
  final fields = <Object>[];
}
