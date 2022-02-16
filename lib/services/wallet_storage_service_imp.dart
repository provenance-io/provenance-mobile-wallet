import 'package:prov_wallet_flutter/prov_wallet_flutter.dart';
import 'package:provenance_dart/src/wallet/private_key.dart';
import 'package:provenance_dart/wallet.dart';
import 'package:provenance_wallet/services/models/wallet_details.dart';
import 'package:provenance_wallet/services/sqlite_wallet_storage_service.dart';
import 'package:provenance_wallet/services/wallet_storage_service.dart';

class WalletStorageServiceImp implements WalletStorageService {
  WalletStorageServiceImp(
    this._sqliteWalletStorageService,
    this._cipherService,
  );

  final SqliteWalletStorageService _sqliteWalletStorageService;
  final CipherService _cipherService;

  @override
  Future<bool> addWallet({
    required String name,
    required PrivateKey privateKey,
    required bool useBiometry,
  }) async {
    final publicKey = privateKey.defaultKey().publicKey;

    final id = await _sqliteWalletStorageService.addWallet(
      name: name,
      address: publicKey.address,
      coin: publicKey.coin,
    );

    final privateKeyStr = privateKey.serialize(
      publicKeyOnly: false,
    );

    final success = await _cipherService.encryptKey(
      id: id,
      privateKey: privateKeyStr,
      useBiometry: useBiometry,
    );

    if (!success) {
      await _sqliteWalletStorageService.removeWallet(id: id);
    }

    return success;
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

    return PrivateKey.fromBip32(serializedKey);
  }

  @override
  Future removeAllWallets() async {
    // TODO: add code to remove wallets in secure storage

    return _sqliteWalletStorageService.removeAllWallets();
  }

  @override
  Future removeWallet(String id) {
    return _sqliteWalletStorageService.removeWallet(id: id);
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

  @override
  Future<bool> getUseBiometry() {
    return _cipherService.getUseBiometry();
  }

  @override
  Future<bool> setUseBiometry(bool useBiometry) {
    return _cipherService.setUseBiometry(useBiometry: useBiometry);
  }
}
