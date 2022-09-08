import 'package:flutter/widgets.dart';
import 'package:provenance_wallet/common/classes/pw_error.dart';
import 'package:provenance_wallet/util/strings.dart';

enum ActionListError implements PwError {
  txFailed,
  multiSigAccountNotFound,
  multiSigSendSignatureFailed;

  @override
  String toLocalizedString(BuildContext context) {
    switch (this) {
      case ActionListError.txFailed:
        return Strings.of(context).errorTxFailed;
      case ActionListError.multiSigAccountNotFound:
        return Strings.of(context).multiSigAccountNotFound;
      case ActionListError.multiSigSendSignatureFailed:
        return Strings.of(context).multiSigSendSignatureFailed;
    }
  }
}
