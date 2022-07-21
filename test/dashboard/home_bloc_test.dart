import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:prov_wallet_flutter/prov_wallet_flutter.dart';
import 'package:provenance_dart/wallet.dart';
import 'package:provenance_wallet/common/pw_design.dart';
import 'package:provenance_wallet/screens/home/home_bloc.dart';
import 'package:provenance_wallet/services/account_service/account_service.dart';
import 'package:provenance_wallet/services/account_service/account_storage_service_imp.dart';
import 'package:provenance_wallet/services/account_service/default_transaction_handler.dart';
import 'package:provenance_wallet/services/account_service/sembast_account_storage_service.dart';
import 'package:provenance_wallet/services/account_service/transaction_handler.dart';
import 'package:provenance_wallet/services/asset_service/asset_service.dart';
import 'package:provenance_wallet/services/deep_link/deep_link_service.dart';
import 'package:provenance_wallet/services/key_value_service/default_key_value_service.dart';
import 'package:provenance_wallet/services/key_value_service/key_value_service.dart';
import 'package:provenance_wallet/services/key_value_service/memory_key_value_store.dart';
import 'package:provenance_wallet/services/models/asset.dart';
import 'package:provenance_wallet/services/models/send_transactions.dart';
import 'package:provenance_wallet/services/models/transaction.dart';
import 'package:provenance_wallet/services/remote_notification/remote_notification_service.dart';
import 'package:provenance_wallet/services/transaction_service/transaction_service.dart';
import 'package:provenance_wallet/services/wallet_connect_service/wallet_connect_service.dart';
import 'package:provenance_wallet/util/get.dart';
import 'package:provenance_wallet/util/local_auth_helper.dart';
import 'package:sembast/sembast_memory.dart';

import 'home_bloc_test.mocks.dart';
import 'home_mocks.dart';

const walletConnectAddress =
    'wc:0a617708-4a2c-42b8-b3cd-21455c5814a3@1?bridge=wss%3A%2F%2Ftest.figure.tech%2Fservice-wallet-connect-bridge%2Fws%2Fexternal&key=7f518dccaf046b1c91e216d7b19701932bfe44e25ac0e51880eace5231934b20';

@GenerateMocks([RemoteNotificationService, WalletConnectService])
void main() {
  tearDown(() async {
    await get<SembastAccountStorageService>().deleteDatabase();
    await get.reset(dispose: true);
  });

  test(
    'Initial load',
    () async {
      final state = await TestState.create(
        maxWalletId: 1,
      );

      final bloc = state.bloc;
      final walletService = state.walletService;

      await pumpEventQueue();

      expect(walletService.events.selected.value?.id, state.accountIds[0]);
      expect(bloc.assetList.value!.first.amount, '0');
    },
  );

  test('Given empty account service, no account is selected', () async {
    const maxWalletId = -1; // No initial wallets

    final state = await TestState.create(
      maxWalletId: maxWalletId,
    );

    final walletService = state.walletService;

    await pumpEventQueue();

    expect(walletService.events.selected.value, isNull);
  });

  test(
    'Select wallet loads assets and transactions',
    () async {
      const maxWalletId = 1;

      final state = await TestState.create(
        maxWalletId: maxWalletId,
      );

      final bloc = state.bloc;
      final walletService = state.walletService;

      await bloc.selectAccount(id: state.accountIds[maxWalletId]);

      await pumpEventQueue();

      expect(walletService.events.selected.value!.id,
          state.accountIds[maxWalletId]);
      expect(bloc.assetList.value!.first.amount, maxWalletId.toString());
    },
  );

  test('Rename wallet updates selected wallet', () async {
    final state = await TestState.create(
      maxWalletId: 0,
    );

    final bloc = state.bloc;
    final walletService = state.walletService;

    const newName = 'new';

    await bloc.renameAccount(id: '0', name: newName);

    await pumpEventQueue();

    expect(
        (await walletService.events.selected.first)!.id, state.accountIds[0]);
  });

  test('Remove selected wallet updates selected wallet', () async {
    final state = await TestState.create(
      maxWalletId: 1,
    );

    final walletService = state.walletService;

    await state.walletService.removeAccount(id: state.accountIds[0]);

    await pumpEventQueue();

    expect(walletService.events.selected.value!.id, state.accountIds[1]);
  });

  test('Remove non-selected wallet does not update selected wallet', () async {
    final state = await TestState.create(
      maxWalletId: 1,
    );

    final bloc = state.bloc;
    final walletService = state.walletService;

    await bloc.selectAccount(id: state.accountIds[0]);
    await walletService.removeAccount(id: state.accountIds[1]);

    await pumpEventQueue();

    expect(walletService.events.selected.value!.id, state.accountIds[0]);
  });

  test('Reset wallets removes selected wallet', () async {
    final state = await TestState.create(
      maxWalletId: 1,
    );

    final bloc = state.bloc;
    final walletService = state.walletService;

    await bloc.resetAccounts();

    await pumpEventQueue();

    expect((await walletService.events.selected.first), isNull);
  });
}

class TestState {
  TestState._(
    this.accountIds,
    this.assetService,
    this.transactionService,
    this.deepLinkService,
    this.walletService,
    this.bloc,
  );

  final List<String> accountIds;
  final AssetService assetService;
  final TransactionService transactionService;
  final DeepLinkService deepLinkService;
  final AccountService walletService;
  final HomeBloc bloc;

  static Future<TestState> createConnected({
    required int maxWalletId,
  }) async {
    final state = await create(maxWalletId: maxWalletId);

    final connectedCompleter = Completer();

    await pumpEventQueue();

    await connectedCompleter.future;

    return state;
  }

  static Future<TestState> create({
    required int maxWalletId,
  }) async {
    WidgetsFlutterBinding.ensureInitialized();

    await get.reset(dispose: true);

    final cipherService = MemoryCipherService();
    get.registerSingleton<CipherService>(cipherService);
    final serviceCore = SembastAccountStorageService(
      factory: databaseFactoryMemory,
      directory: sembastInMemoryDatabasePath,
    );
    get.registerSingleton(serviceCore);
    final accountService = AccountService(
      storage: AccountStorageServiceImp(
        serviceCore,
        cipherService,
      ),
    );

    final accountIds = <String>[];
    final assets = <String, List<Asset>>{};
    final transactions = <String, List<Transaction>>{};
    final sendTransactions = <String, List<SendTransaction>>{};

    for (var i = 0; i <= maxWalletId; i++) {
      final id = i.toString();
      final seed = Mnemonic.createSeed([i.toString()]);
      final privateKey = PrivateKey.fromSeed(seed, Coin.mainNet);
      final publicKey = privateKey.defaultKey().publicKey;

      final account = await accountService.addAccount(
        phrase: [i.toString()],
        name: id,
        coin: Coin.mainNet,
      );

      accountIds.add(account!.id);

      cipherService.encryptKey(
        id: account.id,
        privateKey: privateKey.serialize(
          publicKeyOnly: false,
        ),
      );

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
        block: i,
        messageType: id,
        hash: id,
        signer: id,
        status: id,
        time: DateTime.fromMillisecondsSinceEpoch(i),
        feeAmount: i.toString(),
        denom: id,
      );

      final sendTransaction = SendTransaction.fake(
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
        exponent: i,
      );

      assets[publicKey.address] = [asset];
      transactions[id] = [transaction];
      sendTransactions[id] = [sendTransaction];
    }

    await accountService.selectFirstAccount();

    final mockRemoteNotificationService = MockRemoteNotificationService();
    final mockWalletConnectService = MockWalletConnectService();
    when(mockWalletConnectService.tryRestoreSession(any))
        .thenAnswer((_) => Future.value(true));

    final deepLinkService = MockDeepLinkService();
    final assetService = MockAssetService(assets);
    final transactionService =
        MockTransactionService(sendTransactions, transactions);

    final keyValueService = DefaultKeyValueService(
      store: MemoryKeyValueStore(),
    );

    get.registerSingleton<AccountService>(accountService);

    final authHelper = LocalAuthHelper();

    get.registerSingleton<AssetService>(assetService);
    get.registerSingleton<TransactionService>(transactionService);
    get.registerSingleton<DeepLinkService>(deepLinkService);
    get.registerSingleton<KeyValueService>(keyValueService);
    get.registerSingleton<RemoteNotificationService>(
      mockRemoteNotificationService,
    );
    get.registerSingleton<WalletConnectService>(mockWalletConnectService);

    get.registerSingleton(authHelper);
    get.registerSingleton<TransactionHandler>(
      DefaultTransactionHandler(),
    );
    final bloc = HomeBloc();

    await pumpEventQueue();

    return TestState._(
      accountIds,
      assetService,
      transactionService,
      deepLinkService,
      accountService,
      bloc,
    );
  }
}
