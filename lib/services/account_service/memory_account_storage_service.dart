import 'package:provenance_dart/wallet.dart';
import 'package:provenance_wallet/services/account_service/account_storage_service.dart';
import 'package:provenance_wallet/services/models/account_details.dart';
import 'package:uuid/uuid.dart';

class MemoryStorageData {
  MemoryStorageData(
    this.details,
    this.keys,
    this.selectedKeyIndex,
  );

  final AccountDetails details;
  final List<PrivateKey> keys;
  final int selectedKeyIndex;

  PrivateKey get selectedKey => keys[selectedKeyIndex];
}

class MemoryAccountStorageService implements AccountStorageService {
  MemoryAccountStorageService({
    List<MemoryStorageData>? datas,
    String? selectedWalletId,
    bool? useBiometry,
  })  : _datas = datas ?? [],
        _selectedId = selectedWalletId;

  String? _selectedId;

  final List<MemoryStorageData> _datas;

  @override
  Future<AccountDetails?> addAccount({
    required String name,
    required List<PrivateKey> privateKeys,
    required Coin selectedCoin,
  }) async {
    if (privateKeys.isEmpty) {
      return null;
    }

    final id = Uuid().v1().toString();

    const selectedKeyIndex = 0;
    final selectedPrivateKey =
        privateKeys.firstWhere((e) => e.coin == selectedCoin);
    final selectedPublicKey = selectedPrivateKey.defaultKey().publicKey;

    final details = AccountDetails(
      id: id,
      name: name,
      publicKey: selectedPublicKey,
    );

    _datas.add(MemoryStorageData(
      details,
      privateKeys,
      selectedKeyIndex,
    ));

    return details;
  }

  @override
  Future<AccountDetails?> addPendingAccount({
    required String name,
    required Coin coin,
  }) async {
    final id = Uuid().v1().toString();
    final publicKey = PrivateKey.fromSeed(
      Mnemonic.createSeed([id]),
      Coin.testNet,
    ).defaultKey().publicKey;

    final details = AccountDetails(
      id: id,
      name: name,
      publicKey: publicKey,
    );

    _datas.add(
      MemoryStorageData(
        details,
        [],
        -1,
      ),
    );

    return details;
  }

  @override
  Future<AccountDetails?> getSelectedAccount() async {
    final id = _selectedId;
    if (id == null) {
      return null;
    }

    return getAccount(id);
  }

  @override
  Future<AccountDetails?> getAccount(String id) async {
    AccountDetails? result;

    for (final data in _datas) {
      if (data.details.id == id) {
        result = data.details;
        break;
      }
    }

    return result;
  }

  @override
  Future<List<AccountDetails>> getAccounts() async {
    return _datas.map((e) => e.details).toList();
  }

  @override
  Future<PrivateKey?> loadKey(String id, Coin coin) async {
    PrivateKey? result;

    for (final data in _datas) {
      if (data.details.id == id) {
        result = data.keys.firstWhere((e) => e.coin == coin);
      }
    }

    return result;
  }

  @override
  Future<bool> removeAllAccounts() async {
    _datas.clear();

    return true;
  }

  @override
  Future<bool> removeAccount(String id) async {
    final length = _datas.length;
    _datas.removeWhere((e) => e.details.id == id);

    return _datas.length != length;
  }

  @override
  Future<AccountDetails?> renameAccount({
    required String id,
    required String name,
  }) async {
    AccountDetails? result;

    final index = _datas.indexWhere((e) => e.details.id == id);
    if (index != -1) {
      final old = _datas[index];
      final renamed = AccountDetails(
        id: old.details.id,
        name: name,
        publicKey: old.details.publicKey,
      );
      _datas[index] = MemoryStorageData(
        renamed,
        old.keys,
        old.selectedKeyIndex,
      );
      result = renamed;
    }

    return result;
  }

  @override
  Future<AccountDetails?> setAccountCoin({
    required String id,
    required Coin coin,
  }) async {
    AccountDetails? result;

    final index = _datas.indexWhere((e) => e.details.id == id);
    if (index != -1) {
      final old = _datas[index];

      final keyIndex = old.keys.indexWhere((e) => e.coin == coin);
      if (keyIndex != -1) {
        final updated = AccountDetails(
          id: old.details.id,
          name: old.details.name,
          publicKey: old.details.publicKey,
        );
        _datas[index] = MemoryStorageData(
          updated,
          old.keys,
          keyIndex,
        );
        result = updated;
      }
    }

    return result;
  }

  @override
  Future<AccountDetails?> selectAccount({String? id}) async {
    AccountDetails? result;

    if (id == null && _datas.isNotEmpty) {
      final first = _datas.first.details;
      _selectedId = first.id;

      return first;
    }

    for (final data in _datas) {
      if (data.details.id == id) {
        _selectedId = data.details.id;
        result = data.details;
        break;
      }
    }

    return result;
  }
}
