import 'package:flutter/foundation.dart';
import 'package:provenance_blockchain_wallet/services/config_service/flavor.dart';

class LocalConfig with Diagnosticable {
  LocalConfig({
    required this.packageId,
    required this.version,
    required this.buildNumber,
    required this.flavor,
  });

  final Flavor flavor;
  final String packageId;
  final String version;
  final String buildNumber;

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);

    properties.add(StringProperty('packageId', packageId));
    properties.add(StringProperty('version', version));
    properties.add(StringProperty('buildNumber', buildNumber));
    properties.add(StringProperty('flavor', flavor.name));
  }
}
