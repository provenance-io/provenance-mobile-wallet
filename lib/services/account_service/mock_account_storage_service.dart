import 'package:faker/faker.dart';
import 'package:provenance_dart/wallet.dart';
import 'package:provenance_wallet/services/account_service/account_storage_service.dart';
import 'package:provenance_wallet/services/account_service/account_storage_service_core.dart';
import 'package:provenance_wallet/services/models/account.dart';
import 'package:provenance_wallet/services/multi_sig_service/models/multi_sig_signer.dart';

class MockAccountStorageService implements AccountStorageServiceCore {
  final List<BasicAccount> _basicAccounts = [
    BasicAccount(
        id: Faker().guid.guid(),
        name: "One",
        publicKey: PublicKey.fromPrivateKey(
            [Faker().randomGenerator.integer(99999)], Coin.testNet)),
    BasicAccount(
        id: Faker().guid.guid(),
        name: "Two",
        publicKey: PublicKey.fromPrivateKey(
            [Faker().randomGenerator.integer(99999)], Coin.testNet)),
  ];

  final List<MultiAccount> _multiAccounts = [];

  List<Account?> get _allAccounts {
    return []
      ..addAll(_multiAccounts)
      ..addAll(_basicAccounts);
  }

  @override
  Future<BasicAccount?> addBasicAccount(
      {required String name,
      required List<PublicKeyData> publicKeys,
      required String selectedChainId}) async {
    return _basicAccounts.first;
  }

  @override
  Future<MultiAccount?> addMultiAccount(
      {required String name,
      required String selectedChainId,
      required String linkedAccountId,
      required String remoteId,
      required int cosignerCount,
      required int signaturesRequired,
      required List<String> inviteIds,
      String? address,
      List<MultiSigSigner>? signers}) async {
    return _multiAccounts.first;
  }

  @override
  Future<Account?> getAccount({required String id}) async {
    return _allAccounts.firstWhere((element) => element?.id == id);
  }

  @override
  Future<List<Account>> getAccounts() async {
    return _allAccounts.map((element) => element!).toList();
  }

  @override
  Future<BasicAccount?> getBasicAccount({required String id}) async {
    return _basicAccounts.firstWhere((element) => element.id == id);
  }

  @override
  Future<List<BasicAccount>> getBasicAccounts() async {
    return _basicAccounts;
  }

  @override
  Future<MultiAccount?> getMultiAccount({required String id}) async {
    return _multiAccounts.firstWhere((element) => element.id == id);
  }

  @override
  Future<List<MultiAccount>> getMultiAccounts() async {
    return _multiAccounts;
  }

  @override
  Future<TransactableAccount?> getSelectedAccount() async {
    return _basicAccounts.first;
  }

  @override
  Future<int> getVersion() async {
    return -99;
  }

  @override
  Future<int> removeAccount({required String id}) async {
    _multiAccounts.removeWhere((element) => element.id == id);
    _basicAccounts.removeWhere((element) => element.id == id);
    return 1;
  }

  @override
  Future<int> removeAllAccounts() async {
    _multiAccounts.clear();
    _basicAccounts.clear();
    return 1;
  }

  @override
  Future<Account?> renameAccount(
      {required String id, required String name}) async {
    if (_multiAccounts.any((element) => element.id == id)) {
      // Do this.
      return null;
    } else if (_basicAccounts.any((element) => element.id == id)) {
      final account = _basicAccounts.firstWhere((element) => element.id == id);
      final newAccount =
          BasicAccount(id: id, name: name, publicKey: account.publicKey);
      _basicAccounts.removeWhere((element) => element.id == id);
      _basicAccounts.add(newAccount);
      return newAccount;
    }
    return null;
  }

  @override
  Future<TransactableAccount?> selectAccount({String? id}) async {
    return _basicAccounts.firstWhere((element) => element.id == id);
  }

  @override
  Future<Account?> setChainId({required String id, required String chainId}) {
    // TODO: implement setChainId
    throw UnimplementedError();
  }

  @override
  Future<MultiAccount?> setMultiAccountSigners(
      {required String id, required List<MultiSigSigner> signers}) {
    // TODO: implement setMultiAccountSigners
    throw UnimplementedError();
  }
}
