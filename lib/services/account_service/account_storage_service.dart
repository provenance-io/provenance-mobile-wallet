import 'package:provenance_dart/wallet.dart';
import 'package:provenance_wallet/common/pw_design.dart';
import 'package:provenance_wallet/services/models/account_details.dart';

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

  Future<List<AccountDetails>> getAccounts();

  Future<AccountDetails?> getAccount(String id);

  Future<AccountDetails?> getSelectedAccount();

  Future<AccountDetails?> selectAccount({
    String? id,
  });

  Future<AccountDetails?> renameAccount({
    required String id,
    required String name,
  });

  Future<AccountDetails?> addAccount({
    required String name,
    required List<PrivateKey> privateKeys,
    required Coin selectedCoin,
  });

  Future<AccountDetails?> addPendingAccount({
    required String name,
    required Coin coin,
  });

  Future<PrivateKey?> loadKey(String id, Coin coin);

  Future<bool> removeAccount(String id);

  Future<bool> removeAllAccounts();

  Future<AccountDetails?> setAccountCoin({
    required String id,
    required Coin coin,
  });
}
