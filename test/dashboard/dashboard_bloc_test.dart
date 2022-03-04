import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:get_it/get_it.dart';
import 'package:provenance_dart/wallet.dart';
import 'package:provenance_wallet/screens/dashboard/dashboard_bloc.dart';
import 'package:provenance_wallet/services/asset_service/asset_service.dart';
import 'package:provenance_wallet/services/deep_link/deep_link_service.dart';
import 'package:provenance_wallet/services/models/asset.dart';
import 'package:provenance_wallet/services/models/remote_client_details.dart';
import 'package:provenance_wallet/services/models/transaction.dart';
import 'package:provenance_wallet/services/models/wallet_details.dart';
import 'package:provenance_wallet/services/transaction_service/transaction_service.dart';
import 'package:provenance_wallet/services/wallet_service/wallet_connect_session_status.dart';
import 'package:provenance_wallet/services/wallet_service/wallet_service.dart';

import 'dashboard_mocks.dart';
import 'in_memory_wallet_storage_service.dart';

final get = GetIt.instance;
const walletConnectAddress =
    'wc:0a617708-4a2c-42b8-b3cd-21455c5814a3@1?bridge=wss%3A%2F%2Ftest.figure.tech%2Fservice-wallet-connect-bridge%2Fws%2Fexternal&key=7f518dccaf046b1c91e216d7b19701932bfe44e25ac0e51880eace5231934b20';

void main() {
  test(
    'Initial load',
    () async {
      final state = await TestState.create(
        maxWalletId: 1,
      );

      final bloc = state.bloc;

      expect(bloc.selectedWallet.value?.id, '0');
      expect(bloc.assetList.value!.first.amount, '0');
      expect(bloc.transactionDetails.value.transactions.first.amount, 0);
    },
  );

  test('Add first wallet selects wallet', () async {
    const maxWalletId = -1; // No initial wallets

    final state = await TestState.create(
      maxWalletId: maxWalletId,
    );

    final bloc = state.bloc;

    expect(bloc.selectedWallet.value, isNull);
  });

  test(
    'Select wallet loads assets and transactions',
    () async {
      const maxWalletId = 1;
      final maxWalletIdStr = maxWalletId.toString();

      final state = await TestState.create(
        maxWalletId: maxWalletId,
      );

      final bloc = state.bloc;

      await bloc.selectWallet(id: maxWalletId.toString());

      await pumpEventQueue();

      expect(bloc.selectedWallet.value!.id, maxWalletIdStr);
      expect(bloc.assetList.value!.first.amount, maxWalletIdStr);
      expect(
        bloc.transactionDetails.value.transactions.first.amount,
        maxWalletId,
      );
    },
  );

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

  test('Remove selected wallet updates selected wallet', () async {
    final state = await TestState.create(
      maxWalletId: 1,
    );

    final bloc = state.bloc;

    await state.walletService.removeWallet(id: '0');

    await pumpEventQueue();

    expect(bloc.selectedWallet.value!.id, '1');
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

  test('Reset wallets removes selected wallet', () async {
    final state = await TestState.create(
      maxWalletId: 1,
    );

    final bloc = state.bloc;

    await bloc.resetWallets();

    await pumpEventQueue();

    expect(bloc.selectedWallet.value, isNull);
  });

  test('Connect wallet requests session', () async {
    final state = await TestState.create(
      maxWalletId: 0,
    );

    final bloc = state.bloc;

    RemoteClientDetails? details;
    bloc.delegateEvents.sessionRequest.listen((e) async {
      details = e;
    });

    await bloc.connectWallet(walletConnectAddress);

    await pumpEventQueue();

    expect(
      bloc.sessionEvents.state.value.status,
      WalletConnectSessionStatus.connecting,
    );

    expect(details, isNotNull);
  });

  test('Approve session connects session', () async {
    final state = await TestState.createConnected(
      maxWalletId: 0,
    );

    final bloc = state.bloc;

    expect(
      bloc.sessionEvents.state.value.status,
      WalletConnectSessionStatus.connected,
    );
  });

  test('Disconnect session disconnects session', () async {
    final state = await TestState.createConnected(
      maxWalletId: 0,
    );

    final bloc = state.bloc;

    await bloc.disconnectWallet();

    await pumpEventQueue();

    expect(
      bloc.sessionEvents.state.value.status,
      WalletConnectSessionStatus.disconnected,
    );
  });
}

class TestState {
  TestState._(
    this.assetService,
    this.transactionService,
    this.deepLinkService,
    this.walletService,
    this.bloc,
  );

  final AssetService assetService;
  final TransactionService transactionService;
  final DeepLinkService deepLinkService;
  final WalletService walletService;
  final DashboardBloc bloc;

  static Future<TestState> createConnected({
    required int maxWalletId,
  }) async {
    final state = await create(maxWalletId: maxWalletId);

    final bloc = state.bloc;

    final connectedCompleter = Completer();

    bloc.delegateEvents.sessionRequest.listen((e) async {
      await bloc.approveSession(details: e, allowed: true);

      await pumpEventQueue();

      connectedCompleter.complete();
    });

    await bloc.connectWallet(walletConnectAddress);

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
      );

      assets[id] = [asset];
      transactions[id] = [transaction];

      storageDatas.add(
        InMemoryStorageData(
          WalletDetails(
            id: id,
            address: id,
            name: id,
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
      connectionProvider: (address) => MockWalletConnection(address),
    );

    get.registerSingleton<AssetService>(assetService);
    get.registerSingleton<TransactionService>(transactionService);
    get.registerSingleton<DeepLinkService>(deepLinkService);
    get.registerSingleton<WalletService>(walletService);

    final bloc = DashboardBloc();

    await bloc.load();

    await pumpEventQueue();

    return TestState._(
      assetService,
      transactionService,
      deepLinkService,
      walletService,
      bloc,
    );
  }
}
