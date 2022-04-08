import 'package:flutter/foundation.dart';
import 'package:provenance_dart/wallet.dart';
import 'package:provenance_wallet/common/pw_design.dart';

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
  int get hashCode => hashValues(
        id,
        address,
        name,
        publicKey,
        coin,
      );

  @override
  bool operator ==(Object other) {
    return other is WalletDetails &&
        other.id == id &&
        other.address == address &&
        other.name == name &&
        other.publicKey == publicKey &&
        other.coin == coin;
  }

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);

    properties.add(StringProperty('id', id));
    properties.add(StringProperty('address', address));
    properties.add(StringProperty('name', name));
  }
}
