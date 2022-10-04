import 'package:flutter/widgets.dart';
import 'package:provenance_wallet/common/classes/pw_error.dart';
import 'package:provenance_wallet/util/strings.dart';

enum TxQueueServiceError implements PwError {
  accountNotFound,
  cipherKeyNotFound,
  createTxFailed,
  txNotFound;

  @override
  String toLocalizedString(BuildContext context) {
    switch (this) {
      case TxQueueServiceError.txNotFound:
        return Strings.of(context).errorTransactionNotFound;
      case TxQueueServiceError.accountNotFound:
        return Strings.of(context).errorAccountNotFound;
      case TxQueueServiceError.cipherKeyNotFound:
        return Strings.of(context).errorCipherKeyNotFound;
      case TxQueueServiceError.createTxFailed:
        return Strings.of(context).errorCreateTransactionFailed;
    }
  }
}
