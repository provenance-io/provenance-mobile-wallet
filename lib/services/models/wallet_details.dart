import 'package:flutter/foundation.dart';

class WalletDetails with Diagnosticable {
  WalletDetails({
    required this.id,
    required this.address,
    required this.name,
  });

  final String id;
  final String address;
  final String name;

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);

    properties.add(StringProperty('id', id));
    properties.add(StringProperty('address', address));
    properties.add(StringProperty('name', name));
  }
}
