import 'package:flutter/foundation.dart';
import 'package:provenance_dart/wallet.dart';

enum AccountKind {
  basic,
  multi,
  pendingMulti,
}

abstract class Account {
  Account._();

  abstract final String id;
  abstract final String name;
  abstract final AccountKind kind;
}

abstract class TransactableAccount implements Account {
  TransactableAccount._();

  @override
  abstract final String id;

  @override
  abstract final String name;

  abstract final Coin coin;
  abstract final String address;
  abstract final PublicKey publicKey;
}

class BasicAccount with Diagnosticable implements TransactableAccount {
  const BasicAccount({
    required this.id,
    required this.name,
    required this.publicKey,
    this.linkedAccountIds = const [],
  });

  @override
  AccountKind get kind => AccountKind.basic;

  @override
  String get address => publicKey.address;

  @override
  Coin get coin => publicKey.coin;

  @override
  final String id;

  @override
  final String name;

  @override
  final PublicKey publicKey;

  final List<String> linkedAccountIds;

  @override
  int get hashCode => Object.hashAll([
        id,
        name,
        publicKey.address,
        linkedAccountIds,
      ]);

  @override
  bool operator ==(Object other) {
    return other is BasicAccount &&
        other.id == id &&
        other.name == name &&
        other.publicKey.address == publicKey.address &&
        other.linkedAccountIds == linkedAccountIds;
  }

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);

    properties.add(StringProperty('id', id));
    properties.add(StringProperty('address', publicKey.address));
    properties.add(StringProperty('name', name));
    properties
        .add(StringProperty('linkedAccountIds', linkedAccountIds.toString()));
  }
}

class MultiAccount with Diagnosticable implements TransactableAccount {
  const MultiAccount({
    required this.id,
    required this.name,
    required this.publicKey,
    required this.linkedAccountId,
  });

  @override
  AccountKind get kind => AccountKind.multi;

  @override
  String get address => publicKey.address;

  @override
  Coin get coin => publicKey.coin;

  @override
  final String id;

  @override
  final String name;

  @override
  final PublicKey publicKey;

  final String linkedAccountId;

  @override
  int get hashCode => Object.hashAll([
        id,
        name,
        publicKey.address,
        linkedAccountId,
      ]);

  @override
  bool operator ==(Object other) {
    return other is MultiAccount &&
        other.id == id &&
        other.name == name &&
        other.publicKey.address == publicKey.address &&
        other.linkedAccountId == linkedAccountId;
  }

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);

    properties.add(StringProperty('id', id));
    properties.add(StringProperty('address', publicKey.address));
    properties.add(StringProperty('name', name));
    properties.add(StringProperty('linkedAccountId', linkedAccountId));
  }
}

class PendingMultiAccount implements Account {
  PendingMultiAccount({
    required this.id,
    required this.remoteId,
    required this.name,
    required this.linkedAccountId,
    required this.linkedAccountName,
    required this.cosignerCount,
    required this.signaturesRequired,
  });

  @override
  AccountKind get kind => AccountKind.pendingMulti;

  @override
  final String id;
  @override
  final String name;
  final String remoteId;
  final String linkedAccountId;
  final String linkedAccountName;
  final int cosignerCount;
  final int signaturesRequired;
}
