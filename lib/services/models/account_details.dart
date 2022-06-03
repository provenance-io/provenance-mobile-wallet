import 'package:flutter/foundation.dart';
import 'package:provenance_dart/wallet.dart';
import 'package:provenance_wallet/common/pw_design.dart';
import 'package:provenance_wallet/services/account_service/account_storage_service_core.dart';

class AccountDetails with Diagnosticable {
  const AccountDetails({
    required this.id,
    required this.name,
    required this.publicKey,
    this.kind = AccountKind.single,
  });

  String get address => publicKey.address;
  Coin get coin => publicKey.coin;

  final String id;
  final String name;
  final PublicKey publicKey;
  final AccountKind kind;

  @override
  int get hashCode => hashValues(
        id,
        name,
        publicKey.address,
        kind,
      );

  @override
  bool operator ==(Object other) {
    return other is AccountDetails &&
        other.id == id &&
        other.name == name &&
        other.publicKey.address == publicKey.address &&
        other.kind == kind;
  }

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);

    properties.add(StringProperty('id', id));
    properties.add(StringProperty('address', publicKey.address));
    properties.add(StringProperty('name', name));
    properties.add(EnumProperty('kind', kind));
  }
}
