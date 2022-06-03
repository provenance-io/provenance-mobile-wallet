enum SembastAccountStatus {
  pending,
  ready,
}

enum SembastAccountKind {
  single,
  multi,
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
    this.kind = SembastAccountKind.single,
    this.status = SembastAccountStatus.ready,
  });

  final String name;
  final List<SembastPublicKeyModel> publicKeys;
  final SembastAccountKind kind;
  final SembastAccountStatus status;
  final String selectedChainId;

  Map<String, dynamic> toRecord() => {
        'name': name,
        'kind': kind.name,
        'status': status.name,
        'publicKeys': publicKeys.map((e) => e.toRecord()).toList(),
        'selectedChainId': selectedChainId,
      };

  factory SembastAccountModel.fromRecord(Map<String, dynamic> rec) =>
      SembastAccountModel(
        name: rec['name'] as String,
        kind: SembastAccountKind.values.byName(rec['kind'] as String),
        status: SembastAccountStatus.values.byName(rec['status'] as String),
        publicKeys: (rec['publicKeys'] as List<dynamic>)
            .map((e) => SembastPublicKeyModel.fromRecord(e))
            .toList(),
        selectedChainId: rec['selectedChainId'] as String,
      );

  SembastAccountModel copyWith({
    String? name,
    List<SembastPublicKeyModel>? publicKeys,
    String? selectedChainId,
    SembastAccountKind? kind,
    SembastAccountStatus? status,
  }) =>
      SembastAccountModel(
        name: name ?? this.name,
        publicKeys: publicKeys ?? this.publicKeys,
        selectedChainId: selectedChainId ?? this.selectedChainId,
        kind: kind ?? this.kind,
      );
}
