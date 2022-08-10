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
    required this.publicKeys,
    required this.selectedChainId,
    required this.linkedAccountIds,
  });

  final String name;
  final List<SembastPublicKeyModel> publicKeys;

  final String selectedChainId;
  final List<String> linkedAccountIds;

  Map<String, dynamic> toRecord() => {
        'name': name,
        'publicKeys': publicKeys.map((e) => e.toRecord()).toList(),
        'selectedChainId': selectedChainId,
        'linkedAccountIds': linkedAccountIds,
      };

  factory SembastAccountModel.fromRecord(Map<String, dynamic> rec) =>
      SembastAccountModel(
        name: rec['name'] as String,
        publicKeys: (rec['publicKeys'] as List<dynamic>)
            .map((e) => SembastPublicKeyModel.fromRecord(e))
            .toList(),
        selectedChainId: rec['selectedChainId'] as String,
        linkedAccountIds: (rec['linkedAccountIds'] as List<dynamic>?)
                ?.map((e) => e as String)
                .toList() ??
            [],
      );

  SembastAccountModel copyWith({
    String? name,
    List<SembastPublicKeyModel>? publicKeys,
    String? selectedChainId,
    List<String>? linkedAccountIds,
  }) =>
      SembastAccountModel(
        name: name ?? this.name,
        publicKeys: publicKeys ?? this.publicKeys,
        selectedChainId: selectedChainId ?? this.selectedChainId,
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
    this.address,
  });

  final String name;

  final String linkedAccountId;
  final String remoteId;
  final int cosignerCount;
  final int signaturesRequired;
  final List<String> inviteIds;
  final String? address;

  Map<String, dynamic> toRecord() => {
        'name': name,
        'linkedAccountId': linkedAccountId,
        'remoteId': remoteId,
        'cosignerCount': cosignerCount,
        'signaturesRequired': signaturesRequired,
        'inviteIds': inviteIds,
        'address': address,
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
        address: rec['address'] as String?,
      );

  SembastMultiAccountModel copyWith({
    String? name,
    String? selectedChainId,
    String? address,
  }) =>
      SembastMultiAccountModel(
        name: name ?? this.name,
        address: address ?? this.address,
        linkedAccountId: linkedAccountId,
        remoteId: remoteId,
        cosignerCount: cosignerCount,
        signaturesRequired: signaturesRequired,
        inviteIds: inviteIds,
      );
}
