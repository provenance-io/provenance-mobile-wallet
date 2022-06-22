import 'package:provenance_dart/wallet.dart';
import 'package:provenance_wallet/services/account_service/account_storage_service.dart';
import 'package:provenance_wallet/services/models/account.dart';

abstract class AccountStorageServiceCore {
  AccountStorageServiceCore._();

  Future<int> getVersion();

  Future<BasicAccount?> addBasicAccount({
    required String name,
    required List<PublicKeyData> publicKeys,
    required String selectedChainId,
  });

  Future<MultiAccount?> addMultiAccount({
    required String name,
    required List<PublicKey> publicKeys,
    required String selectedChainId,
    required String linkedAccountId,
    required String remoteId,
    required int cosignerCount,
    required int signaturesRequired,
    required List<String> inviteLinks,
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

  Future<List<Account>> getAccounts();

  Future<List<BasicAccount>> getBasicAccounts();

  Future<List<MultiAccount>> getMultiAccounts();

  Future<Account?> getSelectedAccount();

  Future<int> removeAccount({
    required String id,
  });

  Future<int> removeAllAccounts();

  Future<Account?> renameAccount({
    required String id,
    required String name,
  });

  Future<Account?> selectAccount({
    String? id,
  });

  Future<Account?> setChainId({
    required String id,
    required String chainId,
  });
}
