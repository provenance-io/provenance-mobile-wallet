import 'package:prov_wallet_flutter/prov_wallet_flutter.dart';
import 'package:provenance_dart/wallet.dart';
import 'package:provenance_wallet/services/models/wallet_details.dart';
import 'package:provenance_wallet/services/sqlite_wallet_storage_service.dart';
import 'package:provenance_wallet/services/wallet_service/wallet_storage_service.dart';

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
    required PrivateKey privateKey,
  }) async {
    final publicKey = privateKey.defaultKey().publicKey;

    final details = await _sqliteWalletStorageService.addWallet(
      name: name,
      address: publicKey.address,
      coin: publicKey.coin,
      publicKey: publicKey.compressedPublicKeyHex,
    );

    final privateKeyStr = privateKey.serialize(
      publicKeyOnly: false,
    );

    if (details != null) {
      final success = await _cipherService.encryptKey(
        id: details.id,
        privateKey: privateKeyStr,
      );

      if (!success) {
        await _sqliteWalletStorageService.removeWallet(id: details.id);

        return null;
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
  Future<PrivateKey?> loadKey(String id) async {
    final serializedKey = await _cipherService.decryptKey(id: id);

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
    var count = 0;
    final success = await _cipherService.removeKey(id: id);
    if (success) {
      count = await _sqliteWalletStorageService.removeWallet(id: id);
    }

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
  Future<WalletDetails?> selectWallet({String? id}) {
    return _sqliteWalletStorageService.selectWallet(id: id);
  }
}
