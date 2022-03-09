import 'package:flutter/foundation.dart';
import 'package:provenance_dart/wallet.dart';

class WalletDetails with Diagnosticable {
  WalletDetails({
    required this.id,
    required this.address,
    required this.name,
    required this.publicKey,
    required this.coin,
  });

  final String id;
  final String address;
  final String name;
  final String publicKey;
  final Coin coin;

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);

    properties.add(StringProperty('id', id));
    properties.add(StringProperty('address', address));
    properties.add(StringProperty('name', name));
  }
}
