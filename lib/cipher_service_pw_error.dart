import 'package:flutter/widgets.dart';
import 'package:prov_wallet_flutter/prov_wallet_flutter.dart';
import 'package:provenance_wallet/common/classes/pw_error.dart';
import 'package:provenance_wallet/util/strings.dart';

class CipherServicePwError implements PwError {
  CipherServicePwError({
    required this.inner,
  });

  final CipherServiceError inner;

  @override
  String toLocalizedString(BuildContext context) {
    String message;
    switch (inner.code) {
      case CipherServiceErrorCode.accessError:
        message = Strings.of(context).cipherAccessError;
        break;
      case CipherServiceErrorCode.accountKeyNotFound:
        message = Strings.of(context).cipherAccountKeyNotFoundError;
        break;
      case CipherServiceErrorCode.addSecItem:
        message = Strings.of(context).cipherAddSecItemError;
        break;
      case CipherServiceErrorCode.dataPersistence:
        message = Strings.of(context).cipherDataPersistenceError;
        break;
      case CipherServiceErrorCode.invalidArgument:
        message = Strings.of(context).cipherInvalidArgumentError;
        break;
      case CipherServiceErrorCode.publicKeyError:
        message = Strings.of(context).cipherPublicKeyError;
        break;
      case CipherServiceErrorCode.secKeyNotFound:
        message = Strings.of(context).cipherSecKeyNotFoundError;
        break;
      case CipherServiceErrorCode.unknown:
        message = Strings.of(context).cipherUnknownError;
        break;
      case CipherServiceErrorCode.upgradeError:
        message = Strings.of(context).cipherUpgradeError;
        break;
      case CipherServiceErrorCode.unsupportedAlgorithm:
        message = Strings.of(context).cipherUnsupportedAlgorithmError;
        break;
    }

    return message;
  }
}
