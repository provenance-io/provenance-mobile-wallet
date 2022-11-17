import 'package:provenance_wallet/clients/multi_sig_client/models/multi_sig_signer.dart';
import 'package:provenance_wallet/network.dart';
import 'package:provenance_wallet/services/models/account.dart';

abstract class AccountStorageServiceCore {
  AccountStorageServiceCore._();

  Future<int> getVersion();

  Future<BasicAccount?> addBasicAccount({
    required String name,
    required String publicKeyHex,
    required Network network,
  });

  Future<MultiAccount?> addMultiAccount({
    required String name,
    required String selectedChainId,
    required String linkedAccountId,
    required String remoteId,
    required int cosignerCount,
    required int signaturesRequired,
    required List<String> inviteIds,
    String? address,
    List<MultiSigSigner>? signers,
  });

  Future<MultiAccount?> setMultiAccountSigners({
    required String id,
    required List<MultiSigSigner> signers,
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

  Future<TransactableAccount?> getSelectedAccount();

  Future<int> removeAccount({
    required String id,
  });

  Future<int> removeAllAccounts();

  Future<Account?> renameAccount({
    required String id,
    required String name,
  });

  Future<Account?> selectNetwork({
    required String id,
    required String publicKeyHex,
    required Network network,
  });

  Future<TransactableAccount?> selectAccount({
    String? id,
  });
}
