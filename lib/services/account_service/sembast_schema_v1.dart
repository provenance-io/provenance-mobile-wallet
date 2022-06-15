enum SembastAccountStatus {
  pending,
  ready,
}

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
    this.status = SembastAccountStatus.ready,
  });

  final String name;
  final List<SembastPublicKeyModel> publicKeys;

  final SembastAccountStatus status;
  final String selectedChainId;
  final List<String> linkedAccountIds;

  Map<String, dynamic> toRecord() => {
        'name': name,
        'status': status.name,
        'publicKeys': publicKeys.map((e) => e.toRecord()).toList(),
        'selectedChainId': selectedChainId,
        'linkedAccounts': linkedAccountIds,
      };

  factory SembastAccountModel.fromRecord(Map<String, dynamic> rec) =>
      SembastAccountModel(
        name: rec['name'] as String,
        status: SembastAccountStatus.values.byName(rec['status'] as String),
        publicKeys: (rec['publicKeys'] as List<dynamic>)
            .map((e) => SembastPublicKeyModel.fromRecord(e))
            .toList(),
        selectedChainId: rec['selectedChainId'] as String,
        linkedAccountIds: (!rec.containsKey('linkedAccounts')
                ? []
                : rec['linkedAccounts'] as List<dynamic>)
            .map((e) => e as String)
            .toList(),
      );

  SembastAccountModel copyWith({
    String? name,
    List<SembastPublicKeyModel>? publicKeys,
    String? selectedChainId,
    List<String>? linkedAccountIds,
    SembastAccountStatus? status,
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
    required this.publicKeys,
    required this.selectedChainId,
    required this.linkedAccountId,
    this.status = SembastAccountStatus.ready,
  });

  final String name;
  final List<SembastPublicKeyModel> publicKeys;

  final SembastAccountStatus status;
  final String selectedChainId;
  final String linkedAccountId;

  Map<String, dynamic> toRecord() => {
        'name': name,
        'status': status.name,
        'publicKeys': publicKeys.map((e) => e.toRecord()).toList(),
        'selectedChainId': selectedChainId,
        'linkedAccountId': linkedAccountId,
      };

  factory SembastMultiAccountModel.fromRecord(Map<String, dynamic> rec) =>
      SembastMultiAccountModel(
        name: rec['name'] as String,
        status: SembastAccountStatus.values.byName(rec['status'] as String),
        publicKeys: (rec['publicKeys'] as List<dynamic>)
            .map((e) => SembastPublicKeyModel.fromRecord(e))
            .toList(),
        selectedChainId: rec['selectedChainId'] as String,
        linkedAccountId: rec['linkedAccountId'] as String,
      );

  SembastMultiAccountModel copyWith({
    String? name,
    List<SembastPublicKeyModel>? publicKeys,
    String? selectedChainId,
    SembastAccountStatus? status,
  }) =>
      SembastMultiAccountModel(
        name: name ?? this.name,
        publicKeys: publicKeys ?? this.publicKeys,
        selectedChainId: selectedChainId ?? this.selectedChainId,
        linkedAccountId: linkedAccountId,
      );
}

class SembastPendingMultiAccountModel {
  SembastPendingMultiAccountModel({
    required this.name,
    required this.remoteId,
    required this.linkedAccountId,
    required this.cosignerCount,
    required this.signaturesRequired,
  });

  final String name;
  final String remoteId;
  final String linkedAccountId;
  final int cosignerCount;
  final int signaturesRequired;

  Map<String, dynamic> toRecord() => {
        'name': name,
        'remoteId': remoteId,
        'linkedAccountId': linkedAccountId,
        'cosignerCount': cosignerCount,
        'signaturesRequired': signaturesRequired,
      };

  factory SembastPendingMultiAccountModel.fromRecord(
          Map<String, dynamic> rec) =>
      SembastPendingMultiAccountModel(
        name: rec['name'] as String,
        remoteId: rec['remoteId'] as String,
        linkedAccountId: rec['linkedAccountId'] as String,
        cosignerCount: rec['cosignerCount'] as int,
        signaturesRequired: rec['signaturesRequired'] as int,
      );

  SembastPendingMultiAccountModel copyWith({
    String? name,
    String? remoteId,
  }) =>
      SembastPendingMultiAccountModel(
        name: name ?? this.name,
        remoteId: remoteId ?? this.remoteId,
        linkedAccountId: linkedAccountId,
        cosignerCount: cosignerCount,
        signaturesRequired: signaturesRequired,
      );
}
