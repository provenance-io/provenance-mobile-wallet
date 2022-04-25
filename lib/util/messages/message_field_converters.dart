import 'package:provenance_blockchain_wallet/util/denom.dart';
import 'package:provenance_blockchain_wallet/util/strings.dart';

Object? convertAmount(Object? obj) {
  String? amount;
  if (obj is List<dynamic>) {
    // e.g. cosmos.bank.v1beta1.MsgSend
    for (final item in obj) {
      if (item is Map<String, dynamic>) {
        amount = _combineAmount(item);
      }
    }
  } else if (obj is Map<String, dynamic>) {
    // e.g. cosmos.staking.v1beta1.MsgDelegate
    amount = _combineAmount(obj);
  }

  return amount;
}

String? convertAddress(Object? data) {
  return data is String ? data.abbreviateAddress() : null;
}

String? convertPermissions(Object? data) {
  String? permissions;
  if (data is List<dynamic>) {
    // e.g. provenance.marker.v1.MsgAddMarkerRequest
    permissions = data.join('\n');
  }

  return permissions;
}

String? _combineAmount(Map<String, dynamic> obj) {
  String? amount;
  final amountData = obj['amount'];
  final denomData = obj['denom'];

  if (amountData != null && denomData != null) {
    if (denomData == nHashDenom) {
      final units = (int.parse(amountData) / nHashPerHash).toString();
      amount = '$units ${Strings.transactionDenomHash}';
    } else {
      amount = '$amountData $denomData';
    }
  }

  return amount;
}
