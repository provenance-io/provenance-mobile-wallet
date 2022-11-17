import 'package:flutter_test/flutter_test.dart';
import 'package:path/path.dart' as path;
import 'package:provenance_dart/wallet.dart';
import 'package:provenance_wallet/network.dart';
import 'package:provenance_wallet/services/account_service/account_storage_service.dart';
import 'package:provenance_wallet/services/account_service/account_storage_service_core.dart';
import 'package:provenance_wallet/services/account_service/sembast_account_storage_service_v2.dart';
import 'package:provenance_wallet/services/models/account.dart';
import 'package:sembast/sembast_memory.dart';

SembastAccountStorageServiceV2? _service;

AccountStorageServiceCore get service => _service!;

final dbPath = path.join(sembastInMemoryDatabasePath, 'account.db');

void main() {
  setUp(() async {
    await _service?.deleteDatabase();

    _service = SembastAccountStorageServiceV2(
      factory: databaseFactoryMemory,
      dbPath: dbPath,
    );
    final accounts = await _service!.getBasicAccounts();
    expect(accounts, isEmpty);
  });

  test('Given service, version is set', () async {
    final version = await service.getVersion();
    expect(version, SembastAccountStorageServiceV2.version);
  });

  test('Given service, accounts is empty', () async {
    final accounts = await service.getBasicAccounts();
    expect(accounts, isEmpty);
  });

  test('Given service with account, on get, account is returned', () async {
    final data = await _initAccount();
    final account = await service.getBasicAccount(id: data.id);
    _expectAccountMatches(data, account);
  });

  test('Given service with accounts, on remove, account is removed', () async {
    final datas = await _initAccounts(count: 2);
    final first = datas[0];

    final count = await service.removeAccount(id: first.id);
    expect(count, 1);

    final accounts = await service.getBasicAccounts();
    expect(accounts.length, 1);

    final second = datas[1];
    _expectAccountMatches(second, accounts.first);
  });

  test('Given service with accounts, on remove all, accounts is empty',
      () async {
    final datas = await _initAccounts(count: 2);
    final count = await service.removeAllAccounts();
    expect(count, datas.length);

    final accounts = await service.getBasicAccounts();
    expect(accounts, isEmpty);
  });

  test('Given service with accounts, on select, account is selected', () async {
    final datas = await _initAccounts(count: 2);
    final second = datas[1];
    var account = await service.selectAccount(id: second.id);
    _expectAccountMatches(second, account);

    account = await service.getSelectedAccount();
    _expectAccountMatches(second, account);
  });

  test(
      'Given service with accounts and selected account, on select null, none is selected',
      () async {
    final datas = await _initAccounts(count: 2);
    final second = datas[1];
    var account = await service.selectAccount(id: second.id);
    _expectAccountMatches(second, account);

    account = await service.selectAccount(id: null);
    expect(account, isNull);

    account = await service.getSelectedAccount();
    expect(account, isNull);
  });

  test('Given service with accounts, on rename, account is updated', () async {
    final datas = await _initAccounts(count: 2);
    final second = datas[1];
    const name = 'new';
    var account = await service.renameAccount(
      id: second.id,
      name: name,
    );
    expect(account, isNotNull);
    expect(account!.name, name);

    account = await service.getBasicAccount(id: second.id);
    expect(account, isNotNull);
    expect(account!.name, name);
  });

  test('When multi-sig is added, linked account is updated', () async {
    final datas = await _initAccounts(count: 1);
    final account = datas.first;
    final chainId = account.publicKeyData.chainId;

    final multiAccount = await service.addMultiAccount(
      name: 'multi',
      selectedChainId: chainId,
      linkedAccountId: account.id,
      remoteId: 'remote-id',
      cosignerCount: 3,
      signaturesRequired: 2,
      inviteIds: [
        'https://provenance.io/invite/0',
        'https://provenance.io/invite/1',
      ],
    );

    expect(multiAccount, isNotNull);

    final linkedAccount = await service.getBasicAccount(id: account.id);
    expect(linkedAccount, isNotNull);

    final linkedAccountIds = linkedAccount!.linkedAccountIds;
    expect(linkedAccountIds.contains(multiAccount!.id), isTrue);
  });

  test('When multi-sig is removed, linked account is updated', () async {
    final datas = await _initAccounts(count: 1);
    final account = datas.first;
    final chainId = account.publicKeyData.chainId;

    final multiAccount = await service.addMultiAccount(
      name: 'multi',
      selectedChainId: chainId,
      linkedAccountId: account.id,
      remoteId: 'remote-id',
      cosignerCount: 3,
      signaturesRequired: 2,
      inviteIds: [
        'https://provenance.io/invite/0',
        'https://provenance.io/invite/1',
      ],
    );

    expect(multiAccount, isNotNull);

    final count = await service.removeAccount(id: multiAccount!.id);
    expect(count, 1);

    final linkedAccount = await service.getBasicAccount(id: account.id);
    expect(linkedAccount, isNotNull);

    final linkedAccountIds = linkedAccount!.linkedAccountIds;
    expect(linkedAccountIds, isEmpty);
  });

  test('Given account with multi-sig, linked account may not be deleted',
      () async {
    final datas = await _initAccounts(count: 1);
    final account = datas.first;
    final chainId = account.publicKeyData.chainId;

    final multiAccount = await service.addMultiAccount(
      name: 'multi',
      selectedChainId: chainId,
      linkedAccountId: account.id,
      remoteId: 'remote-id',
      cosignerCount: 3,
      signaturesRequired: 2,
      inviteIds: [
        'https://provenance.io/invite/0',
        'https://provenance.io/invite/1',
      ],
    );

    expect(multiAccount, isNotNull);

    final linkedAccount = await service.getBasicAccount(id: account.id);
    expect(linkedAccount, isNotNull);

    final count = await service.removeAccount(id: linkedAccount!.id);
    expect(count, isZero);
  });
}

class _AccountData {
  _AccountData({
    required this.id,
    required this.name,
    required this.publicKeyData,
  });

  final String id;
  final String name;

  final PublicKeyData publicKeyData;
}

_expectAccountMatches(_AccountData data, Account? account) {
  expect(account, isNotNull);
  expect(account!.name, data.name);
  expect((account as BasicAccount).publicKey.compressedPublicKeyHex,
      data.publicKeyData.hex);
  expect(account.coin, Coin.forChainId(data.publicKeyData.chainId));
}

Future<_AccountData> _initAccount() async {
  final accounts = await _initAccounts(count: 1);

  return accounts.first;
}

Future<List<_AccountData>> _initAccounts({
  required int count,
}) async {
  final datas = <_AccountData>[];

  for (var i = 0; i < count; i++) {
    final name = 'name-$i';
    const coin = Coin.mainNet;
    final seed = Mnemonic.createSeed([i.toString()]);
    final privateKey = PrivateKey.fromSeed(seed, coin);
    final publicKeyData = PublicKeyData(
      hex: privateKey.defaultKey().publicKey.compressedPublicKeyHex,
      chainId: coin.chainId,
    );

    final details = await service.addBasicAccount(
      name: name,
      publicKeyHex: publicKeyData.hex,
      network: Network.forChainId(coin.chainId),
    );

    datas.add(
      _AccountData(
        id: details!.id,
        name: name,
        publicKeyData: publicKeyData,
      ),
    );
  }

  return datas;
}
