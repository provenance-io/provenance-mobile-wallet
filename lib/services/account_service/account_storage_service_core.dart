import 'package:provenance_wallet/services/account_service/account_storage_service.dart';
import 'package:provenance_wallet/services/models/account.dart';

abstract class AccountStorageServiceCore {
  AccountStorageServiceCore._();

  Future<int> getVersion();

  Future<BasicAccount?> addAccount({
    required String name,
    required List<PublicKeyData> publicKeys,
    required String selectedChainId,
  });

  Future<MultiAccount?> addMultiAccount({
    required String name,
    required List<PublicKeyData> publicKeys,
    required String selectedChainId,
  });

  Future<PendingMultiAccount?> addPendingMultiAccount({
    required String name,
    required String remoteId,
    required String linkedAccountId,
    required int cosignerCount,
    required int signaturesRequired,
  });

  Future<Account?> getAccount({
    required String id,
  });

  Future<BasicAccount?> getBasicAccount({
    required String id,
  });

  Future<MultiAccount?> getMultiAccount({
    required String id,
  });

  Future<PendingMultiAccount?> getPendingMultiAccount({
    required String id,
  });

  Future<List<Account>> getAccounts();

  Future<List<BasicAccount>> getBasicAccounts();

  Future<List<MultiAccount>> getMultiAccounts();

  Future<List<PendingMultiAccount>> getPendingMultiAccounts();

  Future<TransactableAccount?> getSelectedAccount();

  Future<int> removeAccount({
    required String id,
  });

  Future<int> removeAllAccounts();

  Future<TransactableAccount?> renameAccount({
    required String id,
    required String name,
  });

  Future<TransactableAccount?> selectAccount({
    String? id,
  });

  Future<TransactableAccount?> setChainId({
    required String id,
    required String chainId,
  });
}
