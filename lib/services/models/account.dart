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
  abstract final PublicKey? publicKey;
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
  PublicKey get publicKey;
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

class MultiAccount with Diagnosticable implements Account {
  const MultiAccount({
    required this.id,
    required this.name,
    required this.publicKey,
    required this.linkedAccount,
    required this.remoteId,
    required this.cosignerCount,
    required this.signaturesRequired,
    required this.inviteIds,
  });

  @override
  AccountKind get kind => AccountKind.multi;

  @override
  final String id;

  @override
  final String name;

  @override
  final PublicKey? publicKey;

  final BasicAccount linkedAccount;

  final String remoteId;

  final int cosignerCount;

  final int signaturesRequired;

  final List<String> inviteIds;

  @override
  int get hashCode => Object.hashAll([
        id,
        name,
        publicKey?.address,
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
        other.publicKey?.address == publicKey?.address &&
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
    properties.add(StringProperty('address', publicKey?.address));
    properties.add(StringProperty('name', name));
  }
}

class MultiTransactableAccount extends MultiAccount
    implements TransactableAccount {
  const MultiTransactableAccount({
    required String id,
    required String name,
    required PublicKey publicKey,
    required BasicAccount linkedAccount,
    required String remoteId,
    required int cosignerCount,
    required int signaturesRequired,
    required List<String> inviteIds,
  }) : super(
          id: id,
          name: name,
          publicKey: publicKey,
          linkedAccount: linkedAccount,
          remoteId: remoteId,
          cosignerCount: cosignerCount,
          signaturesRequired: signaturesRequired,
          inviteIds: inviteIds,
        );

  @override
  PublicKey get publicKey => super.publicKey!;
}
