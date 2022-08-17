import 'package:provenance_dart/wallet.dart';
import 'package:provenance_wallet/common/pw_design.dart';
import 'package:provenance_wallet/services/models/account.dart';

class PublicKeyData {
  PublicKeyData({
    required this.hex,
    required this.chainId,
  });

  final String hex;
  final String chainId;

  @override
  int get hashCode => hashValues(
        hex,
        chainId,
      );

  @override
  bool operator ==(Object other) {
    return other is PublicKeyData &&
        other.hex == hex &&
        other.chainId == chainId;
  }
}

abstract class AccountStorageService {
  AccountStorageService._();

  Future<List<BasicAccount>> getBasicAccounts();

  Future<List<MultiAccount>> getMultiAccounts();

  Future<List<Account>> getAccounts();

  Future<Account?> getAccount(String id);

  Future<TransactableAccount?> getSelectedAccount();

  Future<TransactableAccount?> selectAccount({
    String? id,
  });

  Future<Account?> renameAccount({
    required String id,
    required String name,
  });

  Future<Account?> addAccount({
    required String name,
    required List<PrivateKey> privateKeys,
    required Coin selectedCoin,
  });

  Future<MultiAccount?> addMultiAccount({
    required String name,
    required Coin selectedCoin,
    required String linkedAccountId,
    required String remoteId,
    required int cosignerCount,
    required int signaturesRequired,
    required List<String> inviteIds,
    String? address,
  });

  Future<MultiAccount?> setMultiAccountAddress({
    required String id,
    required String address,
  });

  Future<PrivateKey?> loadKey(String id, Coin coin);

  Future<bool> removeAccount(String id);

  Future<bool> removeAllAccounts();

  Future<Account?> setAccountCoin({
    required String id,
    required Coin coin,
  });
}
