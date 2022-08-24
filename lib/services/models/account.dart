import 'package:flutter/foundation.dart';
import 'package:provenance_dart/wallet.dart';

enum AccountKind {
  basic,
  multi,
}

abstract class Account {
  Account._();

  abstract final String id;
  abstract final String name;
  abstract final AccountKind kind;
  abstract final String? address;
  abstract final Coin? coin;
  abstract final IPubKey? publicKey;
}

abstract class TransactableAccount implements Account {
  TransactableAccount._();

  @override
  abstract final String id;

  @override
  abstract final String name;

  @override
  abstract final AccountKind kind;

  @override
  String get address;

  @override
  Coin get coin;

  @override
  IPubKey get publicKey;
}

class BasicAccount with Diagnosticable implements Account, TransactableAccount {
  const BasicAccount({
    required this.id,
    required this.name,
    required this.publicKey,
    this.linkedAccountIds = const [],
  });

  @override
  AccountKind get kind => AccountKind.basic;

  @override
  final String id;

  @override
  final String name;

  @override
  final PublicKey publicKey;

  @override
  String get address => publicKey.address;

  @override
  Coin get coin => publicKey.coin;

  final List<String> linkedAccountIds;

  @override
  int get hashCode => Object.hashAll([
        id,
        name,
        address,
        linkedAccountIds,
      ]);

  @override
  bool operator ==(Object other) {
    return other is BasicAccount &&
        other.id == id &&
        other.name == name &&
        other.address == address &&
        other.linkedAccountIds == linkedAccountIds;
  }

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);

    properties.add(StringProperty('id', id));
    properties.add(StringProperty('address', address));
    properties.add(StringProperty('name', name));
    properties
        .add(StringProperty('linkedAccountIds', linkedAccountIds.toString()));
  }
}

class MultiAccount with Diagnosticable implements Account {
  const MultiAccount({
    required this.id,
    required this.name,
    required this.linkedAccount,
    required this.remoteId,
    required this.cosignerCount,
    required this.signaturesRequired,
    required this.inviteIds,
    this.publicKey,
  });

  @override
  AccountKind get kind => AccountKind.multi;

  @override
  final String id;

  @override
  final String name;

  final BasicAccount linkedAccount;

  final String remoteId;

  final int cosignerCount;

  final int signaturesRequired;

  final List<String> inviteIds;

  @override
  final AminoPubKey? publicKey;

  @override
  String? get address => publicKey?.address;

  @override
  Coin? get coin => publicKey?.coin;

  @override
  int get hashCode => Object.hashAll([
        id,
        name,
        address,
        linkedAccount,
        remoteId,
        cosignerCount,
        signaturesRequired,
        inviteIds,
      ]);

  @override
  bool operator ==(Object other) {
    return other is MultiAccount &&
        other.id == id &&
        other.name == name &&
        other.address == address &&
        other.linkedAccount == linkedAccount &&
        other.remoteId == remoteId &&
        other.cosignerCount == cosignerCount &&
        other.signaturesRequired == signaturesRequired &&
        other.inviteIds == inviteIds;
  }

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);

    properties.add(StringProperty('id', id));
    properties.add(StringProperty('address', address));
    properties.add(StringProperty('name', name));
  }
}

class MultiTransactableAccount extends MultiAccount
    implements TransactableAccount {
  const MultiTransactableAccount({
    required String id,
    required String name,
    required BasicAccount linkedAccount,
    required String remoteId,
    required int cosignerCount,
    required int signaturesRequired,
    required List<String> inviteIds,
    required AminoPubKey publicKey,
  }) : super(
          id: id,
          name: name,
          linkedAccount: linkedAccount,
          remoteId: remoteId,
          cosignerCount: cosignerCount,
          signaturesRequired: signaturesRequired,
          inviteIds: inviteIds,
          publicKey: publicKey,
        );

  @override
  AminoPubKey get publicKey => super.publicKey!;

  @override
  String get address => super.address!;

  @override
  Coin get coin => super.coin!;
}
