import 'dart:io';

import 'package:pretty_json/pretty_json.dart';
import 'package:provenance_wallet/services/config_service/endpoints.dart';
import 'package:provenance_wallet/services/config_service/flavor.dart';

///
/// Generates json for the Firebase Remote Config console.
///
/// Usage: dart run bin/generate_endpoints_json.dart
///
/// Output:
///   endpoints_dev.g.json
///   endpoints_prod.g.json
///
void main() async {
  for (final flavor in Flavor.values) {
    final file = File('endpoints_${flavor.name}.g.json');
    await file.create();

    final buffer = StringBuffer();

    final json = Endpoints.forFlavor(flavor).toJson();
    buffer.writeln(prettyJson(json));

    await file.writeAsString(buffer.toString());
  }
}
