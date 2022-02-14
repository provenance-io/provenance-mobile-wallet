import 'dart:convert';

class TransactionMessage {
  TransactionMessage({
    required this.toAddress,
    required this.amount,
    required this.fromAddress,
    required this.denom,
  });

  final String? toAddress;
  final String? amount;
  final String? fromAddress;
  final String? denom;
  String get displayAmount {
    return "${this.amount} ${this.denom}";
  }

  // ignore: member-ordering
  factory TransactionMessage.fromMessage(String message) {
    final json = jsonDecode(message);
    var amount = "";
    var denom = "";
    if (json["amount"] != null) {
      if (json["amount"] is Map<String, dynamic>) {
        var map = json["amount"] as Map<String, dynamic>;
        amount = map["amount"] as String;
        denom = map["denom"] as String;
      } else if (json["amount"] is List<dynamic>) {
        var list = json["amount"] as List<dynamic>;
        amount = list.first["amount"] as String;
        denom = list.first["denom"] as String;
      }
    }

    String? toAddress = json["toAddress"] ?? json["manager"];
    if (toAddress == null) {
      toAddress = json["administrator"];
    }

    return TransactionMessage(
      toAddress: toAddress,
      amount: amount,
      fromAddress: json['fromAddress'],
      denom: denom,
    );
  }
}
