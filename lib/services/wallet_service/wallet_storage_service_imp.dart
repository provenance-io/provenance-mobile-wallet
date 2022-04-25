import 'package:prov_wallet_flutter/prov_wallet_flutter.dart';
import 'package:provenance_blockchain_wallet/chain_id.dart';
import 'package:provenance_blockchain_wallet/common/pw_design.dart';
import 'package:provenance_blockchain_wallet/services/models/wallet_details.dart';
import 'package:provenance_blockchain_wallet/services/sqlite_wallet_storage_service.dart';
import 'package:provenance_blockchain_wallet/services/wallet_service/wallet_storage_service.dart';
import 'package:provenance_dart/wallet.dart';

class WalletStorageServiceImp implements WalletStorageService {
  WalletStorageServiceImp(
    this._sqliteWalletStorageService,
    this._cipherService,
  );

  final SqliteWalletStorageService _sqliteWalletStorageService;
  final CipherService _cipherService;

  @override
  Future<WalletDetails?> addWallet({
    required String name,
    required List<PrivateKey> privateKeys,
    required Coin selectedCoin,
  }) async {
    final keyDatas = <PublicKeyData>[];
    for (var privateKey in privateKeys) {
      final publicKey = privateKey.defaultKey().publicKey;
      final address = publicKey.address;
      final hex = publicKey.compressedPublicKeyHex;
      final network = ChainId.forCoin(publicKey.coin);
      final data = PublicKeyData(
        address: address,
        hex: hex,
        chainId: network,
      );
      keyDatas.add(data);
    }

    final selectedChainId = ChainId.forCoin(selectedCoin);

    final details = await _sqliteWalletStorageService.addWallet(
      name: name,
      publicKeys: keyDatas,
      selectedChainId: selectedChainId,
    );

    if (details != null) {
      for (var privateKey in privateKeys) {
        final privateKeyStr = privateKey.serialize(
          publicKeyOnly: false,
        );

        final keyId = privateKeyId(details.id, privateKey.coin);
        final success = await _cipherService.encryptKey(
          id: keyId,
          privateKey: privateKeyStr,
        );

        if (!success) {
          await _sqliteWalletStorageService.removeWallet(id: details.id);

          return null;
        }
      }
    }

    return details;
  }

  @override
  Future<WalletDetails?> getSelectedWallet() {
    return _sqliteWalletStorageService.getSelectedWallet();
  }

  @override
  Future<WalletDetails?> getWallet(String id) {
    return _sqliteWalletStorageService.getWallet(id: id);
  }

  @override
  Future<List<WalletDetails>> getWallets() {
    return _sqliteWalletStorageService.getWallets();
  }

  @override
  Future<PrivateKey?> loadKey(String walletId, Coin coin) async {
    final keyId = privateKeyId(walletId, coin);
    final serializedKey = await _cipherService.decryptKey(id: keyId);

    return serializedKey == null ? null : PrivateKey.fromBip32(serializedKey);
  }

  @override
  Future<bool> removeAllWallets() async {
    final success = await _cipherService.reset();
    var count = 0;

    if (success) {
      count = await _sqliteWalletStorageService.removeAllWallets();
    }

    return count != 0;
  }

  @override
  Future<bool> removeWallet(String id) async {
    for (final coin in Coin.values) {
      final keyId = privateKeyId(id, coin);
      await _cipherService.removeKey(id: keyId);
    }

    final count = await _sqliteWalletStorageService.removeWallet(id: id);

    return count != 0;
  }

  @override
  Future<WalletDetails?> renameWallet({
    required String id,
    required String name,
  }) {
    return _sqliteWalletStorageService.renameWallet(id: id, name: name);
  }

  @override
  Future<WalletDetails?> setWalletCoin({
    required String id,
    required Coin coin,
  }) async {
    final network = ChainId.forCoin(coin);

    final details = await _sqliteWalletStorageService.setChainId(
      id: id,
      chainId: network,
    );

    return details;
  }

  @override
  Future<WalletDetails?> selectWallet({String? id}) {
    return _sqliteWalletStorageService.selectWallet(id: id);
  }

  @visibleForTesting
  String privateKeyId(String walletId, Coin coin) {
    final chainId = ChainId.forCoin(coin);

    return '$walletId-$chainId';
  }
}
