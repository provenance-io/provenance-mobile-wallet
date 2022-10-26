import 'package:prov_wallet_flutter/prov_wallet_flutter.dart';
import 'package:provenance_dart/wallet.dart';
import 'package:provenance_wallet/clients/multi_sig_client/models/multi_sig_signer.dart';
import 'package:provenance_wallet/common/pw_design.dart';
import 'package:provenance_wallet/services/account_service/account_storage_service.dart';
import 'package:provenance_wallet/services/account_service/account_storage_service_core.dart';
import 'package:provenance_wallet/services/models/account.dart';

class AccountStorageServiceImp implements AccountStorageService {
  AccountStorageServiceImp(
    this._serviceCore,
    this._cipherService,
  );

  final AccountStorageServiceCore _serviceCore;
  final CipherService _cipherService;

  @override
  Future<BasicAccount?> addAccount({
    required String name,
    required PrivateKey privateKey,
  }) async {
    final publicKey = privateKey.defaultKey().publicKey;

    final hex = publicKey.compressedPublicKeyHex;

    final details = await _serviceCore.addBasicAccount(
      name: name,
      publicKey: PublicKeyData(
        hex: hex,
        chainId: publicKey.coin.chainId,
      ),
    );

    if (details != null) {
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

    return details;
  }

  @override
  Future<MultiAccount?> addMultiAccount({
    required String name,
    required Coin selectedCoin,
    required String linkedAccountId,
    required String remoteId,
    required int cosignerCount,
    required int signaturesRequired,
    required List<String> inviteIds,
    String? address,
    List<MultiSigSigner>? signers,
  }) async {
    final details = await _serviceCore.addMultiAccount(
      name: name,
      selectedChainId: selectedCoin.chainId,
      linkedAccountId: linkedAccountId,
      remoteId: remoteId,
      cosignerCount: cosignerCount,
      signaturesRequired: signaturesRequired,
      inviteIds: inviteIds,
      address: address,
      signers: signers,
    );

    return details;
  }

  @override
  Future<MultiAccount?> setMultiAccountSigners({
    required String id,
    required List<MultiSigSigner> signers,
  }) {
    return _serviceCore.setMultiAccountSigners(
      id: id,
      signers: signers,
    );
  }

  @override
  Future<TransactableAccount?> getSelectedAccount() {
    return _serviceCore.getSelectedAccount();
  }

  @override
  Future<Account?> getAccount(String id) {
    return _serviceCore.getAccount(id: id);
  }

  @override
  Future<List<BasicAccount>> getBasicAccounts() {
    return _serviceCore.getBasicAccounts();
  }

  @override
  Future<List<MultiAccount>> getMultiAccounts() {
    return _serviceCore.getMultiAccounts();
  }

  @override
  Future<List<Account>> getAccounts() async {
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
    await _cipherService.resetKeys();
    final count = await _serviceCore.removeAllAccounts();

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
  Future<Account?> renameAccount({
    required String id,
    required String name,
  }) {
    return _serviceCore.renameAccount(id: id, name: name);
  }

  @override
  Future<TransactableAccount?> selectAccount({String? id}) {
    return _serviceCore.selectAccount(id: id);
  }

  @visibleForTesting
  String privateKeyId(String accountId, Coin coin) {
    return '$accountId-${coin.chainId}';
  }
}
