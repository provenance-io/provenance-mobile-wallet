import 'package:provenance_dart/wallet.dart';
import 'package:provenance_wallet/common/pw_design.dart';
import 'package:provenance_wallet/services/models/account_details.dart';

class PublicKeyData {
  PublicKeyData({
    required this.address,
    required this.hex,
    required this.chainId,
  });

  final String address;
  final String hex;
  final String chainId;

  @override
  int get hashCode => hashValues(
        address,
        hex,
        chainId,
      );

  @override
  bool operator ==(Object other) {
    return other is PublicKeyData &&
        other.address == address &&
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

  Future<PrivateKey?> loadKey(String id, Coin coin);

  Future<bool> removeAccount(String id);

  Future<bool> removeAllAccounts();

  Future<AccountDetails?> setAccountCoin({
    required String id,
    required Coin coin,
  });
}
