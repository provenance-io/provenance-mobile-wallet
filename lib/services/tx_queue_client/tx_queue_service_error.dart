import 'package:flutter/widgets.dart';
import 'package:provenance_wallet/common/classes/pw_error.dart';
import 'package:provenance_wallet/util/strings.dart';

enum TxQueueClientError implements PwError {
  accountNotFound,
  cipherKeyNotFound,
  createTxFailed,
  txNotFound;

  @override
  String toLocalizedString(BuildContext context) {
    switch (this) {
      case TxQueueClientError.txNotFound:
        return Strings.of(context).errorTransactionNotFound;
      case TxQueueClientError.accountNotFound:
        return Strings.of(context).errorAccountNotFound;
      case TxQueueClientError.cipherKeyNotFound:
        return Strings.of(context).errorCipherKeyNotFound;
      case TxQueueClientError.createTxFailed:
        return Strings.of(context).errorCreateTransactionFailed;
    }
  }
}
