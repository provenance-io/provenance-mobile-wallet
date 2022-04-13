import 'package:flutter/foundation.dart';
import 'package:provenance_wallet/services/config_service/endpoints.dart';

class RemoteConfig with Diagnosticable {
  RemoteConfig({
    required this.endpoints,
  });

  final Endpoints endpoints;

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);

    properties.add(DiagnosticsProperty('endpoints', endpoints));
  }
}
