import 'package:flutter/foundation.dart';
import 'package:provenance_dart/wallet.dart';
import 'package:provenance_wallet/common/pw_design.dart';
import 'package:provenance_wallet/services/account_service/account_storage_service_core.dart';

class AccountDetails with Diagnosticable {
  AccountDetails({
    required this.id,
    required this.address,
    required this.name,
    required this.publicKey,
    required this.coin,
    this.kind = AccountKind.single,
    this.status = AccountStatus.ready,
  });

  final String id;
  final String address;
  final String name;
  final String publicKey;
  final Coin coin;
  final AccountKind kind;
  final AccountStatus status;

  @override
  int get hashCode => hashValues(
        id,
        address,
        name,
        publicKey,
        coin,
        kind,
        status,
      );

  @override
  bool operator ==(Object other) {
    return other is AccountDetails &&
        other.id == id &&
        other.address == address &&
        other.name == name &&
        other.publicKey == publicKey &&
        other.coin == coin &&
        other.kind == kind &&
        other.status == status;
  }

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);

    properties.add(StringProperty('id', id));
    properties.add(StringProperty('address', address));
    properties.add(StringProperty('name', name));
    properties.add(EnumProperty('kind', kind));
    properties.add(EnumProperty('status', status));
  }
}
