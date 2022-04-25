import 'package:provenance_blockchain_wallet/services/models/wallet_details.dart';
import 'package:provenance_blockchain_wallet/services/wallet_service/wallet_storage_service.dart';
import 'package:provenance_dart/wallet.dart';
import 'package:uuid/uuid.dart';

class InMemoryStorageData {
  InMemoryStorageData(
    this.details,
    this.keys,
    this.selectedKeyIndex,
  );

  final WalletDetails details;
  final List<PrivateKey> keys;
  final int selectedKeyIndex;

  PrivateKey get selectedKey => keys[selectedKeyIndex];
}

class InMemoryWalletStorageService implements WalletStorageService {
  InMemoryWalletStorageService({
    List<InMemoryStorageData>? datas,
    String? selectedWalletId,
    bool? useBiometry,
  })  : _datas = datas ?? [],
        _selectedId = selectedWalletId;

  String? _selectedId;

  final List<InMemoryStorageData> _datas;

  @override
  Future<WalletDetails?> addWallet({
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

    final details = WalletDetails(
      id: id,
      name: name,
      address: selectedPublicKey.address,
      publicKey: selectedPublicKey.compressedPublicKeyHex,
      coin: selectedPrivateKey.coin,
    );

    _datas.add(InMemoryStorageData(
      details,
      privateKeys,
      selectedKeyIndex,
    ));

    return details;
  }

  @override
  Future<WalletDetails?> getSelectedWallet() async {
    final id = _selectedId;
    if (id == null) {
      return null;
    }

    return getWallet(id);
  }

  @override
  Future<WalletDetails?> getWallet(String id) async {
    WalletDetails? result;

    for (final data in _datas) {
      if (data.details.id == id) {
        result = data.details;
        break;
      }
    }

    return result;
  }

  @override
  Future<List<WalletDetails>> getWallets() async {
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
  Future<bool> removeAllWallets() async {
    _datas.clear();

    return true;
  }

  @override
  Future<bool> removeWallet(String id) async {
    final length = _datas.length;
    _datas.removeWhere((e) => e.details.id == id);

    return _datas.length != length;
  }

  @override
  Future<WalletDetails?> renameWallet({
    required String id,
    required String name,
  }) async {
    WalletDetails? result;

    final index = _datas.indexWhere((e) => e.details.id == id);
    if (index != -1) {
      final old = _datas[index];
      final renamed = WalletDetails(
        id: old.details.id,
        address: old.details.address,
        name: name,
        publicKey: old.details.publicKey,
        coin: old.details.coin,
      );
      _datas[index] = InMemoryStorageData(
        renamed,
        old.keys,
        old.selectedKeyIndex,
      );
      result = renamed;
    }

    return result;
  }

  @override
  Future<WalletDetails?> setWalletCoin({
    required String id,
    required Coin coin,
  }) async {
    WalletDetails? result;

    final index = _datas.indexWhere((e) => e.details.id == id);
    if (index != -1) {
      final old = _datas[index];

      final keyIndex = old.keys.indexWhere((e) => e.coin == coin);
      if (keyIndex != -1) {
        final updated = WalletDetails(
          id: old.details.id,
          address: old.details.address,
          name: old.details.name,
          publicKey: old.details.publicKey,
          coin: coin,
        );
        _datas[index] = InMemoryStorageData(
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
  Future<WalletDetails?> selectWallet({String? id}) async {
    WalletDetails? result;

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
