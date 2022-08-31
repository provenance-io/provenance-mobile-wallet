import 'package:flutter/widgets.dart';
import 'package:provenance_wallet/common/classes/pw_error.dart';
import 'package:provenance_wallet/util/strings.dart';

enum ActionListError implements PwError {
  txFailed;

  @override
  String toLocalizedString(BuildContext context) {
    switch (this) {
      case ActionListError.txFailed:
        return Strings.of(context).errorMultiSigTxFailed;
    }
  }
}
