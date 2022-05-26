import 'package:provenance_wallet/services/account_service/wallet_storage_service.dart';
import 'package:provenance_wallet/services/models/account_details.dart';

enum AccountKind {
  single,
  multi,
}

abstract class AccountStorageServiceCore {
  AccountStorageServiceCore._();

  Future<int> getVersion();

  Future<AccountDetails?> addAccount({
    required String name,
    required List<PublicKeyData> publicKeys,
    required String selectedChainId,
    AccountKind kind = AccountKind.single,
  });

  Future<AccountDetails?> getAccount({required String id});

  Future<List<AccountDetails>> getAccounts();

  Future<AccountDetails?> getSelectedAccount();

  Future<int> removeAccount({
    required String id,
  });

  Future<int> removeAllAccounts();

  Future<AccountDetails?> renameAccount({
    required String id,
    required String name,
  });

  Future<AccountDetails?> selectAccount({
    String? id,
  });

  Future<AccountDetails?> setChainId({
    required String id,
    required String chainId,
  });
}
