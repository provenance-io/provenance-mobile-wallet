import 'package:prov_wallet_flutter/dtos/transaction_message.dart';

class SendRequest {
  SendRequest({
    required this.id,
    required this.message,
    required this.description,
    required this.cost,
  });

  final String id;
  final TransactionMessage message;
  final String description;
  final String cost;
}
