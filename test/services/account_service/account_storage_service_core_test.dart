import 'package:flutter_test/flutter_test.dart';
import 'package:provenance_dart/wallet.dart';
import 'package:provenance_wallet/chain_id.dart';
import 'package:provenance_wallet/services/account_service/account_storage_service.dart';
import 'package:provenance_wallet/services/account_service/account_storage_service_core.dart';
import 'package:provenance_wallet/services/account_service/sembast_account_storage_service.dart';
import 'package:provenance_wallet/services/models/account.dart';
import 'package:sembast/sembast_memory.dart';

SembastAccountStorageService? _service;

AccountStorageServiceCore get service => _service!;

void main() {
  setUp(() async {
    await _service?.deleteDatabase();

    _service = SembastAccountStorageService(
      factory: databaseFactoryMemory,
      directory: '',
    );
    final accounts = await _service!.getBasicAccounts();
    expect(accounts, isEmpty);
  });

  test('Given service, version is set', () async {
    final version = await service.getVersion();
    expect(version, SembastAccountStorageService.version);
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

  test('Given service with accounts, on set chain, account is updated',
      () async {
    final datas = await _initAccounts(count: 2);
    final second = datas[1];

    final coin = ChainId.toCoin(second.selectedKey.chainId);
    final newCoin = Coin.values.firstWhere((e) => e != coin);

    var account = await service.setChainId(
      id: second.id,
      chainId: ChainId.forCoin(newCoin),
    );
    expect(account, isNotNull);
    expect(account!.coin, newCoin);

    account = await service.getBasicAccount(id: second.id);
    expect(account, isNotNull);
    expect(account!.coin, newCoin);
  });
}

class _AccountData {
  _AccountData({
    required this.id,
    required this.name,
    required String selectedChainId,
    required this.publicKeyDatas,
  }) {
    selectedKey =
        publicKeyDatas.firstWhere((e) => e.chainId == selectedChainId);
  }

  final String id;
  final String name;

  final List<PublicKeyData> publicKeyDatas;
  late final PublicKeyData selectedKey;
}

_expectAccountMatches(_AccountData data, TransactableAccount? account) {
  expect(account, isNotNull);
  expect(account!.name, data.name);
  expect(account.publicKey.compressedPublicKeyHex, data.selectedKey.hex);
  expect(account.coin, ChainId.toCoin(data.selectedKey.chainId));
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
    const selectedChainId = ChainId.mainNet;
    final seed = Mnemonic.createSeed([i.toString()]);
    final publicKeyDatas = <PublicKeyData>[];
    for (var coin in Coin.values) {
      final privateKey = PrivateKey.fromSeed(seed, coin);
      publicKeyDatas.add(
        PublicKeyData(
            hex: privateKey.defaultKey().publicKey.compressedPublicKeyHex,
            chainId: ChainId.forCoin(coin)),
      );
    }

    final details = await service.addAccount(
      name: name,
      publicKeys: publicKeyDatas,
      selectedChainId: selectedChainId,
    );

    datas.add(
      _AccountData(
        id: details!.id,
        name: name,
        selectedChainId: selectedChainId,
        publicKeyDatas: publicKeyDatas,
      ),
    );
  }

  return datas;
}
