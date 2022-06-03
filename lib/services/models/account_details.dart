import 'package:flutter/foundation.dart';
import 'package:provenance_dart/wallet.dart';
import 'package:provenance_wallet/common/pw_design.dart';
import 'package:provenance_wallet/services/account_service/account_storage_service_core.dart';

class AccountDetails with Diagnosticable {
  const AccountDetails({
    required this.id,
    required this.address,
    required this.name,
    required this.publicKey,
    required this.coin,
    this.kind = AccountKind.single,
  });

  final String id;
  final String address;
  final String name;
  final String publicKey;
  final Coin coin;
  final AccountKind kind;

  bool get isReady => address.isNotEmpty && publicKey.isNotEmpty;

  bool get isNotReady => address.isEmpty || publicKey.isEmpty;

  @override
  int get hashCode => hashValues(
        id,
        address,
        name,
        publicKey,
        coin,
        kind,
      );

  @override
  bool operator ==(Object other) {
    return other is AccountDetails &&
        other.id == id &&
        other.address == address &&
        other.name == name &&
        other.publicKey == publicKey &&
        other.coin == coin &&
        other.kind == kind;
  }

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);

    properties.add(StringProperty('id', id));
    properties.add(StringProperty('address', address));
    properties.add(StringProperty('name', name));
    properties.add(EnumProperty('kind', kind));
  }
}
