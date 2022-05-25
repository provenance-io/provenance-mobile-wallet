enum AccountStatus {
  pending,
  ready,
}

enum AccountKind {
  single,
  multi,
}

class PublicKeyModel {
  PublicKeyModel({
    required this.address,
    required this.hex,
    required this.chainId,
  });

  final String address;
  final String hex;
  final String chainId;

  Map<String, dynamic> toRecord() => {
        'address': address,
        'hex': hex,
        'chainId': chainId,
      };

  factory PublicKeyModel.fromRecord(Map<String, dynamic> rec) {
    return PublicKeyModel(
      address: rec['address'] as String,
      hex: rec['hex'] as String,
      chainId: rec['chainId'] as String,
    );
  }
}

class AccountModel {
  AccountModel({
    required this.name,
    required this.publicKeys,
    required this.selectedChainId,
    this.kind = AccountKind.single,
    this.status = AccountStatus.ready,
  });

  final String name;
  final List<PublicKeyModel> publicKeys;
  final AccountKind kind;
  final AccountStatus status;
  final String selectedChainId;

  Map<String, dynamic> toRecord() => {
        'name': name,
        'kind': kind.name,
        'status': status.name,
        'publicKeys': publicKeys.map((e) => e.toRecord()).toList(),
        'selectedChainId': selectedChainId,
      };

  factory AccountModel.fromRecord(Map<String, dynamic> rec) => AccountModel(
        name: rec['name'] as String,
        kind: AccountKind.values.byName(rec['kind'] as String),
        status: AccountStatus.values.byName(rec['status'] as String),
        publicKeys: (rec['publicKeys'] as List<dynamic>)
            .map((e) => PublicKeyModel.fromRecord(e))
            .toList(),
        selectedChainId: rec['selectedChainId'] as String,
      );

  AccountModel copyWith({
    String? name,
    List<PublicKeyModel>? publicKeys,
    String? selectedChainId,
    AccountKind? kind,
    AccountStatus? status,
  }) =>
      AccountModel(
        name: name ?? this.name,
        publicKeys: publicKeys ?? this.publicKeys,
        selectedChainId: selectedChainId ?? this.selectedChainId,
        kind: kind ?? this.kind,
        status: status ?? this.status,
      );
}
