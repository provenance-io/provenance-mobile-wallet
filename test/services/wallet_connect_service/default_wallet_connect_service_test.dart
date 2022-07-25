import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:provenance_dart/wallet.dart';
import 'package:provenance_dart/wallet_connect.dart';
import 'package:provenance_wallet/services/account_service/account_service.dart';
import 'package:provenance_wallet/services/account_service/transaction_handler.dart';
import 'package:provenance_wallet/services/key_value_service/key_value_service.dart';
import 'package:provenance_wallet/services/models/account.dart';
import 'package:provenance_wallet/services/remote_notification/remote_notification_service.dart';
import 'package:provenance_wallet/services/wallet_connect_queue_service/wallet_connect_queue_service.dart';
import 'package:provenance_wallet/services/wallet_connect_service/default_wallet_connect_service.dart';
import 'package:provenance_wallet/services/wallet_connect_service/wallet_connect_service.dart';
import 'package:provenance_wallet/util/get.dart';
import 'package:rxdart/rxdart.dart';

import './default_wallet_connect_service_test.mocks.dart';

class MockAccountServiceEvents implements AccountServiceEvents {
  final _subscriptions = CompositeSubscription();

  final addedStreamController = StreamController<Account>();
  final removeStreamController = StreamController<List<Account>>();
  final updatedStreamController = StreamController<Account>();
  final selectedStreamController = BehaviorSubject<Account?>.seeded(null);

  @override
  Stream<Account> get added => addedStreamController.stream;
  @override
  Stream<List<Account>> get removed => removeStreamController.stream;
  @override
  Stream<Account> get updated => updatedStreamController.stream;
  @override
  ValueStream<Account?> get selected => selectedStreamController.stream;

  @override
  void clear() {
    _subscriptions.clear();
  }

  @override
  void dispose() {
    _subscriptions.dispose();

    addedStreamController.close();
    removeStreamController.close();
    updatedStreamController.close();
    selectedStreamController.close();
  }

  @override
  void listen(AccountServiceEvents other) {
    other.added.listen(addedStreamController.add).addTo(_subscriptions);
    other.removed.listen(removeStreamController.add).addTo(_subscriptions);
    other.updated.listen(updatedStreamController.add).addTo(_subscriptions);
    other.selected.listen(selectedStreamController.add).addTo(_subscriptions);
  }
}

class MockConnectionFactory {
  MockConnectionFactory(this.connection);

  WalletConnection connection;
  WalletConnectAddress? passedAddress;

  WalletConnection getConnection(WalletConnectAddress address) {
    passedAddress = address;
    return connection;
  }
}

final phrase =
    "nasty carbon end inject case prison foam tube damage poverty timber sea boring someone husband fish whip motion mail canyon census success jungle can"
        .split(" ");
final seed = Mnemonic.createSeed(phrase);
final privateKey = PrivateKey.fromSeed(seed, Coin.mainNet);
const walletConnectAddress =
    "wc:c2572162-bc23-442c-95c7-a4b6403331f4@1?bridge=wss%3A%2F%2Ftest.figure.tech%2Fservice-wallet-connect-bridge%2Fws%2Fexternal&key=c90653342c66a002944cff439239b79cc6fdde42b61a10c6d1e8d05506bd92bf";

final account = BasicAccount(
    id: "Id", name: "Account1", publicKey: privateKey.defaultKey().publicKey);

// NOTE: you need to use testWidgets due to the fact that WidgetsBinding.instance.addObserver is used
@GenerateMocks([
  KeyValueService,
  AccountService,
  RemoteNotificationService,
  WalletConnectQueueService,
  TransactionHandler,
  WalletConnection
])
void main() {
  late MockKeyValueService mockKeyValueService;
  late MockAccountService mockAccountService;
  late MockRemoteNotificationService mockRemoteNotificationService;
  late MockWalletConnectQueueService mockWalletConnectQueueService;
  late MockTransactionHandler mockTransactionHandler;
  late MockWalletConnection mockWalletConnection;

  late DefaultWalletConnectService _walletConnectService;

  late MockAccountServiceEvents accountServiceEvents;
  late MockConnectionFactory mockConnectionFactory;

  late WalletConnectionDelegate capturedDelegate;

  setUp(() {
    mockWalletConnection = MockWalletConnection();

    mockConnectionFactory = MockConnectionFactory(mockWalletConnection);

    accountServiceEvents = MockAccountServiceEvents();

    mockKeyValueService = MockKeyValueService();
    mockAccountService = MockAccountService();
    when(mockAccountService.events).thenReturn(accountServiceEvents);
    when(mockAccountService.onDispose()).thenAnswer((_) => Future.value());

    mockRemoteNotificationService = MockRemoteNotificationService();
    mockWalletConnectQueueService = MockWalletConnectQueueService();
    when(mockWalletConnectQueueService.onDispose())
        .thenAnswer((_) => Future.value());
    mockTransactionHandler = MockTransactionHandler();

    get.registerSingleton<KeyValueService>(mockKeyValueService);
    when(mockKeyValueService.removeString(any))
        .thenAnswer((_) => Future.value(true));
    when(mockKeyValueService.setString(any, any))
        .thenAnswer((_) => Future.value(true));

    get.registerSingleton<AccountService>(mockAccountService);
    get.registerSingleton<RemoteNotificationService>(
        mockRemoteNotificationService);
    get.registerSingleton<WalletConnectQueueService>(
        mockWalletConnectQueueService);
    get.registerSingleton<TransactionHandler>(mockTransactionHandler);

    get.registerSingleton<WalletConnectionFactory>(
        mockConnectionFactory.getConnection);

    _walletConnectService = DefaultWalletConnectService();

    // setup values needed by the connect method
    when(mockAccountService.loadKey(any))
        .thenAnswer((_) => Future.value(privateKey));

    when(mockWalletConnection.connect(any, any))
        .thenAnswer((_) => Future.value());

    when(mockWalletConnection.value)
        .thenReturn(WalletConnectState.disconnected);

    accountServiceEvents.selectedStreamController.add(account);
  });

  tearDown(() async {
    await _walletConnectService.onDispose();
    get.reset(dispose: true);
    accountServiceEvents.dispose();
  });

  testWidgets("register accountService event listeners", (tester) async {
    expect(accountServiceEvents.addedStreamController.hasListener, true);
    expect(accountServiceEvents.removeStreamController.hasListener, true);
    expect(accountServiceEvents.updatedStreamController.hasListener, true);
    expect(accountServiceEvents.selectedStreamController.hasListener, true);
  });

  group("connectSession", () {
    testWidgets("return false on private key not found", (_) async {
      when(mockAccountService.loadKey(any))
          .thenAnswer((_) => Future.value(null));
      final success = await _walletConnectService.connectSession(
          "AccountId", walletConnectAddress);
      expect(success, false);
    });

    testWidgets("return false on invalid address", (_) async {
      final success = await _walletConnectService.connectSession(
          "AccountId", "Fake Address");
      expect(success, false);
    });

    testWidgets("return false on no account selected", (_) async {
      accountServiceEvents.selectedStreamController.add(null);
      final success = await _walletConnectService.connectSession(
          "AccountId", walletConnectAddress);
      expect(success, false);
    });

    testWidgets("verify calls", (_) async {
      final success = await _walletConnectService.connectSession(
          "AccountId", walletConnectAddress);

      expect(success, true);

      verify(mockAccountService.loadKey("AccountId"));

      expect(mockConnectionFactory.passedAddress!.bridge,
          WalletConnectAddress.create(walletConnectAddress)!.bridge);
      expect(mockConnectionFactory.passedAddress!.key,
          WalletConnectAddress.create(walletConnectAddress)!.key);
      expect(mockConnectionFactory.passedAddress!.version,
          WalletConnectAddress.create(walletConnectAddress)!.version);
      expect(mockConnectionFactory.passedAddress!.topic,
          WalletConnectAddress.create(walletConnectAddress)!.topic);
    });
  });

  group("tryRestoreSession", () {
    final suspendedTimeStr = DateTime.now().toIso8601String();
    setUp(() {
      when(mockKeyValueService.getString(PrefKey.sessionData))
          .thenAnswer((_) => Future.value("""{
            "walletId": "AccountId",
            "peerId": "PeerId",
            "remotePeerId": "RemotePeerId",
            "address": "$walletConnectAddress",
            "clientMeta": {}
        }"""));

      when(mockKeyValueService.getString(PrefKey.sessionSuspendedTime))
          .thenAnswer((_) => Future.value(suspendedTimeStr));
    });

    testWidgets("return false on null session data", (_) async {
      when(mockKeyValueService.getString(PrefKey.sessionData))
          .thenAnswer((_) => Future.value(null));

      final success =
          await _walletConnectService.tryRestoreSession("AccountId");

      expect(success, false);
    });

    testWidgets("return false on invalid session data", (_) async {
      when(mockKeyValueService.getString(PrefKey.sessionData))
          .thenAnswer((_) => Future.value(""));

      final success =
          await _walletConnectService.tryRestoreSession("AccountId");

      expect(success, false);
    });

    testWidgets("return false on null suspendedTime", (_) async {
      when(mockKeyValueService.getString(PrefKey.sessionSuspendedTime))
          .thenAnswer((_) => Future.value(null));

      final success =
          await _walletConnectService.tryRestoreSession("AccountId");

      expect(success, false);
    });

    testWidgets("return false on invalid suspendedTime", (_) async {
      when(mockKeyValueService.getString(PrefKey.sessionSuspendedTime))
          .thenAnswer((_) => Future.value("A"));

      final success =
          await _walletConnectService.tryRestoreSession("AccountId");

      expect(success, false);
    });

    testWidgets("return false on suspendedTime > 30", (_) async {
      final newExpiredTime =
          DateTime.now().subtract(Duration(minutes: 30, seconds: 1));

      when(mockKeyValueService.getString(PrefKey.sessionSuspendedTime))
          .thenAnswer((_) => Future.value(newExpiredTime.toIso8601String()));

      final success =
          await _walletConnectService.tryRestoreSession("AccountId");

      expect(success, false);
    });

    testWidgets("return false on private key not found", (_) async {
      when(mockAccountService.loadKey(any))
          .thenAnswer((_) => Future.value(null));
      final success =
          await _walletConnectService.tryRestoreSession("AccountId");
      expect(success, false);
    });

    testWidgets("return false on no account selected", (_) async {
      accountServiceEvents.selectedStreamController.add(null);
      final success =
          await _walletConnectService.tryRestoreSession("AccountId");
      expect(success, false);
    });

    testWidgets("verify calls", (_) async {
      final success =
          await _walletConnectService.tryRestoreSession("AccountId");

      expect(success, true);

      verify(mockAccountService.loadKey("AccountId"));

      expect(mockConnectionFactory.passedAddress!.bridge,
          WalletConnectAddress.create(walletConnectAddress)!.bridge);
      expect(mockConnectionFactory.passedAddress!.key,
          WalletConnectAddress.create(walletConnectAddress)!.key);
      expect(mockConnectionFactory.passedAddress!.version,
          WalletConnectAddress.create(walletConnectAddress)!.version);
      expect(mockConnectionFactory.passedAddress!.topic,
          WalletConnectAddress.create(walletConnectAddress)!.topic);

      _walletConnectService
          .disconnectSession(); // make sure activity timer is shutdown
    });
  });
}
