import 'package:flutter/foundation.dart';
import 'package:prov_wallet_flutter/src/cipher_service_error_code.dart';

class CipherServiceError with Diagnosticable {
  CipherServiceError({
    required this.code,
    this.message,
    this.details,
  });

  final CipherServiceErrorCode code;
  final String? message;
  final String? details;

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);

    properties.add(StringProperty('code', code.name));
    properties.add(StringProperty('message', message));
    properties.add(StringProperty('details', details));
  }
}
