import 'package:provenance_wallet/clients/multi_sig_client/models/multi_sig_signer.dart';

class SembastPublicKeyModel {
  SembastPublicKeyModel({
    required this.hex,
    required this.chainId,
  });

  final String hex;
  final String chainId;

  Map<String, dynamic> toRecord() => {
        'hex': hex,
        'chainId': chainId,
      };

  factory SembastPublicKeyModel.fromRecord(Map<String, dynamic> rec) {
    return SembastPublicKeyModel(
      hex: rec['hex'] as String,
      chainId: rec['chainId'] as String,
    );
  }
}

class SembastAccountModel {
  SembastAccountModel({
    required this.name,
    required this.publicKey,
    required this.linkedAccountIds,
  });

  final String name;
  final SembastPublicKeyModel publicKey;
  final List<String> linkedAccountIds;

  Map<String, dynamic> toRecord() => {
        'name': name,
        'publicKey': publicKey.toRecord(),
        'linkedAccountIds': linkedAccountIds,
      };

  factory SembastAccountModel.fromRecord(Map<String, dynamic> rec) =>
      SembastAccountModel(
        name: rec['name'] as String,
        publicKey: SembastPublicKeyModel.fromRecord(rec['publicKey']),
        linkedAccountIds: (rec['linkedAccountIds'] as List<dynamic>?)
                ?.map((e) => e as String)
                .toList() ??
            [],
      );

  SembastAccountModel copyWith({
    String? name,
    SembastPublicKeyModel? publicKey,
    String? selectedChainId,
    List<String>? linkedAccountIds,
  }) =>
      SembastAccountModel(
        name: name ?? this.name,
        publicKey: publicKey ?? this.publicKey,
        linkedAccountIds: linkedAccountIds ?? this.linkedAccountIds,
      );
}

class SembastMultiAccountModel {
  SembastMultiAccountModel({
    required this.name,
    required this.linkedAccountId,
    required this.remoteId,
    required this.cosignerCount,
    required this.signaturesRequired,
    required this.inviteIds,
    this.signers,
  });

  final String name;

  final String linkedAccountId;
  final String remoteId;
  final int cosignerCount;
  final int signaturesRequired;
  final List<String> inviteIds;

  final List<SembastMultiAccountSigner>? signers;

  Map<String, dynamic> toRecord() => {
        'name': name,
        'linkedAccountId': linkedAccountId,
        'remoteId': remoteId,
        'cosignerCount': cosignerCount,
        'signaturesRequired': signaturesRequired,
        'inviteIds': inviteIds,
        if (signers != null)
          'signers': signers?.map((e) => e.toRecord()).toList(),
      };

  factory SembastMultiAccountModel.fromRecord(Map<String, dynamic> rec) =>
      SembastMultiAccountModel(
        name: rec['name'] as String,
        linkedAccountId: rec['linkedAccountId'] as String,
        remoteId: rec['remoteId'] as String,
        cosignerCount: rec['cosignerCount'] as int,
        signaturesRequired: rec['signaturesRequired'] as int,
        inviteIds: (rec['inviteIds'] as List<dynamic>?)
                ?.map((e) => e as String)
                .toList() ??
            [],
        signers: rec['signers'] != null
            ? (rec['signers'] as List<dynamic>)
                .map((e) => SembastMultiAccountSigner.fromRecord(e))
                .toList()
            : null,
      );

  SembastMultiAccountModel copyWith({
    String? name,
    String? selectedChainId,
    List<MultiSigSigner>? signers,
  }) =>
      SembastMultiAccountModel(
        name: name ?? this.name,
        linkedAccountId: linkedAccountId,
        remoteId: remoteId,
        cosignerCount: cosignerCount,
        signaturesRequired: signaturesRequired,
        inviteIds: inviteIds,
        signers: signers
            ?.map((e) => SembastMultiAccountSigner(
                  publicKey: e.publicKey!.compressedPublicKeyHex,
                  signerOrder: e.signerOrder,
                ))
            .toList(),
      );
}

class SembastMultiAccountSigner {
  SembastMultiAccountSigner({
    required this.publicKey,
    required this.signerOrder,
  });

  final String? publicKey;
  final int signerOrder;

  Map<String, Object?> toRecord() => {
        if (publicKey != null) 'publicKey': publicKey,
        'signerOrder': signerOrder,
      };

  factory SembastMultiAccountSigner.fromRecord(Map<String, Object?> rec) =>
      SembastMultiAccountSigner(
        publicKey: rec['publicKey'] as String?,
        signerOrder: rec['signerOrder'] as int,
      );
}
