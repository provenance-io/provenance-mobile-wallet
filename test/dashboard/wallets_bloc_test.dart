import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:get_it/get_it.dart';
import 'package:prov_wallet_flutter/prov_wallet_flutter.dart';
import 'package:provenance_dart/wallet.dart';
import 'package:provenance_dart/wallet_connect.dart';
import 'package:provenance_wallet/screens/dashboard/dashboard_bloc.dart';
import 'package:provenance_wallet/screens/dashboard/wallets/wallets_bloc.dart';
import 'package:provenance_wallet/services/asset_service/asset_service.dart';
import 'package:provenance_wallet/services/deep_link/deep_link_service.dart';
import 'package:provenance_wallet/services/key_value_service.dart';
import 'package:provenance_wallet/services/models/asset.dart';
import 'package:provenance_wallet/services/models/transaction.dart';
import 'package:provenance_wallet/services/models/wallet_details.dart';
import 'package:provenance_wallet/services/transaction_service/transaction_service.dart';
import 'package:provenance_wallet/services/wallet_service/wallet_service.dart';
import 'package:provenance_wallet/util/local_auth_helper.dart';

import '../services/memory_key_value_service.dart';
import 'dashboard_mocks.dart';
import 'in_memory_wallet_storage_service.dart';

final get = GetIt.instance;
const walletConnectAddress =
    'wc:0a617708-4a2c-42b8-b3cd-21455c5814a3@1?bridge=wss%3A%2F%2Ftest.figure.tech%2Fservice-wallet-connect-bridge%2Fws%2Fexternal&key=7f518dccaf046b1c91e216d7b19701932bfe44e25ac0e51880eace5231934b20';

void main() {
  test('Rename wallet updates selected wallet', () async {
    final state = await TestState.create(
      maxWalletId: 0,
    );

    final bloc = state.bloc;

    const newName = 'new';

    await bloc.renameWallet(id: '0', name: newName);

    await pumpEventQueue();

    expect(bloc.selectedWallet.value!.name, newName);
  });

  test('Remove non-selected wallet does not update selected wallet', () async {
    final state = await TestState.create(
      maxWalletId: 1,
    );

    final bloc = state.bloc;

    await bloc.selectWallet(id: '0');
    await state.walletService.removeWallet(id: '1');

    await pumpEventQueue();

    expect(bloc.selectedWallet.value!.id, '0');
  });
}

class TestState {
  TestState._(
    this.assetService,
    this.transactionService,
    this.deepLinkService,
    this.walletService,
    this.dbloc,
    this.bloc,
  );

  final AssetService assetService;
  final TransactionService transactionService;
  final DeepLinkService deepLinkService;
  final WalletService walletService;
  final DashboardBloc dbloc;
  final WalletsBloc bloc;

  static Future<TestState> createConnected({
    required int maxWalletId,
  }) async {
    final state = await create(maxWalletId: maxWalletId);

    final bloc = state.bloc;
    final dbloc = state.dbloc;

    final connectedCompleter = Completer();

    dbloc.delegateEvents.sessionRequest.listen((e) async {
      await dbloc.approveSession(details: e, allowed: true);

      await pumpEventQueue();

      connectedCompleter.complete();
    });

    final walletId = bloc.selectedWallet.value!.id;

    await dbloc.connectSession(walletId, walletConnectAddress);

    await pumpEventQueue();

    await connectedCompleter.future;

    return state;
  }

  static Future<TestState> create({
    required int maxWalletId,
  }) async {
    await get.reset(dispose: true);

    final storageDatas = <InMemoryStorageData>[];

    final assets = <String, List<Asset>>{};
    final transactions = <String, List<Transaction>>{};

    for (var i = 0; i <= maxWalletId; i++) {
      final id = i.toString();

      final asset = Asset.fake(
        denom: id,
        amount: id,
        display: id,
        description: id,
        exponent: i,
        displayAmount: id,
        usdPrice: i.toDouble(),
      );

      final transaction = Transaction.fake(
        amount: i,
        block: i,
        denom: id,
        hash: id,
        recipientAddress: id,
        senderAddress: id,
        status: id,
        timestamp: DateTime.fromMillisecondsSinceEpoch(i),
        txFee: i,
        pricePerUnit: i.toDouble(),
        totalPrice: i.toDouble(),
        exponent: 1,
      );

      assets[id] = [asset];
      transactions[id] = [transaction];

      storageDatas.add(
        InMemoryStorageData(
          WalletDetails(
            id: id,
            address: id,
            name: id,
            publicKey: "",
            coin: Coin.testNet,
          ),
          PrivateKey.fromSeed(
            Mnemonic.createSeed([id]),
            Coin.testNet,
          ),
        ),
      );
    }

    final deepLinkService = MockDeepLinkService();
    final assetService = MockAssetService(assets);
    final transactionService = MockTransactionService(transactions);
    final walletService = WalletService(
      storage: InMemoryWalletStorageService(
        datas: storageDatas,
      ),
    );
    final keyValueService = MemoryKeyValueService();
    walletConnectionFactory(WalletConnectAddress address) {
      return MockWalletConnection(address);
    }

    final cipherService = MockCipherService();
    get.registerSingleton<CipherService>(cipherService);
    get.registerSingleton<WalletService>(walletService);

    final authHelper = LocalAuthHelper();

    get.registerSingleton<AssetService>(assetService);
    get.registerSingleton<TransactionService>(transactionService);
    get.registerSingleton<DeepLinkService>(deepLinkService);
    get.registerSingleton<KeyValueService>(keyValueService);
    get.registerSingleton<WalletConnectionFactory>(walletConnectionFactory);

    get.registerSingleton(authHelper);

    final bloc = DashboardBloc();

    await bloc.load();

    bloc.registerWalletBloc();

    final newBloc = get<WalletsBloc>();

    await pumpEventQueue();

    return TestState._(
      assetService,
      transactionService,
      deepLinkService,
      walletService,
      bloc,
      newBloc,
    );
  }
}
