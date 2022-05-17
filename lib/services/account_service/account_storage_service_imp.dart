import 'package:prov_wallet_flutter/prov_wallet_flutter.dart';
import 'package:provenance_dart/wallet.dart';
import 'package:provenance_wallet/chain_id.dart';
import 'package:provenance_wallet/common/pw_design.dart';
import 'package:provenance_wallet/services/account_service/account_storage_service_core.dart';
import 'package:provenance_wallet/services/account_service/wallet_storage_service.dart';
import 'package:provenance_wallet/services/models/account_details.dart';

class AccountStorageServiceImp implements AccountStorageService {
  AccountStorageServiceImp(
    this._serviceCore,
    this._cipherService,
  );

  final AccountStorageServiceCore _serviceCore;
  final CipherService _cipherService;

  @override
  Future<AccountDetails?> addAccount({
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

    final details = await _serviceCore.addAccount(
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
          await _serviceCore.removeAccount(id: details.id);

          return null;
        }
      }
    }

    return details;
  }

  @override
  Future<AccountDetails?> getSelectedAccount() {
    return _serviceCore.getSelectedAccount();
  }

  @override
  Future<AccountDetails?> getAccount(String id) {
    return _serviceCore.getAccount(id: id);
  }

  @override
  Future<List<AccountDetails>> getAccounts() {
    return _serviceCore.getAccounts();
  }

  @override
  Future<PrivateKey?> loadKey(String accountId, Coin coin) async {
    final keyId = privateKeyId(accountId, coin);
    final serializedKey = await _cipherService.decryptKey(id: keyId);

    return serializedKey == null ? null : PrivateKey.fromBip32(serializedKey);
  }

  @override
  Future<bool> removeAllAccounts() async {
    final success = await _cipherService.resetKeys();
    var count = 0;

    if (success) {
      count = await _serviceCore.removeAllAccounts();
    }

    return count != 0;
  }

  @override
  Future<bool> removeAccount(String id) async {
    for (final coin in Coin.values) {
      final keyId = privateKeyId(id, coin);
      await _cipherService.removeKey(id: keyId);
    }

    final count = await _serviceCore.removeAccount(id: id);

    return count != 0;
  }

  @override
  Future<AccountDetails?> renameAccount({
    required String id,
    required String name,
  }) {
    return _serviceCore.renameAccount(id: id, name: name);
  }

  @override
  Future<AccountDetails?> setAccountCoin({
    required String id,
    required Coin coin,
  }) async {
    final network = ChainId.forCoin(coin);

    final details = await _serviceCore.setChainId(
      id: id,
      chainId: network,
    );

    return details;
  }

  @override
  Future<AccountDetails?> selectAccount({String? id}) {
    return _serviceCore.selectAccount(id: id);
  }

  @visibleForTesting
  String privateKeyId(String accountId, Coin coin) {
    final chainId = ChainId.forCoin(coin);

    return '$accountId-$chainId';
  }
}
