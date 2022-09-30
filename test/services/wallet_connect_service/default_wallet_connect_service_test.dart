import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:provenance_dart/wallet.dart';
import 'package:provenance_dart/wallet_connect.dart';
import 'package:provenance_wallet/extension/wallet_connect_address_helper.dart';
import 'package:provenance_wallet/services/account_service/account_service.dart';
import 'package:provenance_wallet/services/key_value_service/key_value_service.dart';
import 'package:provenance_wallet/services/models/account.dart';
import 'package:provenance_wallet/services/remote_notification/remote_notification_service.dart';
import 'package:provenance_wallet/services/tx_queue_service/tx_queue_service.dart';
import 'package:provenance_wallet/services/wallet_connect_queue_service/wallet_connect_queue_service.dart';
import 'package:provenance_wallet/services/wallet_connect_service/default_wallet_connect_service.dart';
import 'package:provenance_wallet/services/wallet_connect_service/wallet_connect_session.dart';
import 'package:provenance_wallet/util/get.dart';
import 'package:provenance_wallet/util/local_auth_helper.dart';
import 'package:rxdart/rxdart.dart';

import './default_wallet_connect_service_test.mocks.dart';

class MockAccountServiceEvents implements AccountServiceEvents {
  final _subscriptions = CompositeSubscription();

  final addedStreamController = StreamController<Account>();
  final removeStreamController = StreamController<List<Account>>();
  final updatedStreamController = StreamController<Account>();
  final selectedStreamController =
      BehaviorSubject<TransactableAccount?>.seeded(null);

  @override
  Stream<Account> get added => addedStreamController.stream;
  @override
  Stream<List<Account>> get removed => removeStreamController.stream;
  @override
  Stream<Account> get updated => updatedStreamController.stream;
  @override
  ValueStream<TransactableAccount?> get selected =>
      selectedStreamController.stream;

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
  TxQueueService,
  RemoteNotificationService,
  WalletConnectQueueService,
  WalletConnection,
  LocalAuthHelper,
])
void main() {
  late MockKeyValueService mockKeyValueService;
  late MockAccountService mockAccountService;
  late MockTxQueueService mockTxQueueService;
  late MockRemoteNotificationService mockRemoteNotificationService;
  late MockWalletConnectQueueService mockWalletConnectQueueService;

  late MockWalletConnection mockWalletConnection;
  late MockLocalAuthHelper mockLocalAuthHelper;

  late DefaultWalletConnectService _walletConnectService;

  late MockAccountServiceEvents accountServiceEvents;
  late MockConnectionFactory mockConnectionFactory;

  final BehaviorSubject<AuthStatus> _authStatus =
      BehaviorSubject<AuthStatus>.seeded(AuthStatus.noAccount);

  final accountDetails = BasicAccount(
      id: "ABC", name: "Basic Name", publicKey: privateKey.publicKey);

  setUp(() {
    mockLocalAuthHelper = MockLocalAuthHelper();
    when(mockLocalAuthHelper.onDispose()).thenAnswer((_) => Future.value());
    when(mockLocalAuthHelper.status).thenAnswer((_) => _authStatus);

    mockWalletConnection = MockWalletConnection();
    when(mockWalletConnection.address)
        .thenReturn(WalletConnectAddress.create(walletConnectAddress)!);

    mockConnectionFactory = MockConnectionFactory(mockWalletConnection);

    accountServiceEvents = MockAccountServiceEvents();

    mockKeyValueService = MockKeyValueService();
    mockAccountService = MockAccountService();
    mockTxQueueService = MockTxQueueService();

    when(mockAccountService.events).thenReturn(accountServiceEvents);
    when(mockAccountService.onDispose()).thenAnswer((_) => Future.value());
    when(mockAccountService.getAccount(any))
        .thenAnswer((_) => Future.value(accountDetails));

    mockRemoteNotificationService = MockRemoteNotificationService();
    mockWalletConnectQueueService = MockWalletConnectQueueService();
    when(mockWalletConnectQueueService.onDispose())
        .thenAnswer((_) => Future.value());

    get.registerSingleton<KeyValueService>(mockKeyValueService);
    when(mockKeyValueService.removeString(any))
        .thenAnswer((_) => Future.value(true));
    when(mockKeyValueService.setString(any, any))
        .thenAnswer((_) => Future.value(true));

    _walletConnectService = DefaultWalletConnectService(
      keyValueService: mockKeyValueService,
      accountService: mockAccountService,
      txQueueService: mockTxQueueService,
      connectionFactory: mockConnectionFactory.getConnection,
      notificationService: mockRemoteNotificationService,
      queueService: mockWalletConnectQueueService,
      localAuthHelper: mockLocalAuthHelper,
    );

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
    expect(accountServiceEvents.addedStreamController.hasListener, false);
    expect(accountServiceEvents.removeStreamController.hasListener, false);
    expect(accountServiceEvents.updatedStreamController.hasListener, false);
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
      final accountDetails = mockAccountService.events.selected.value!;

      when(mockAccountService.getAccount(any))
          .thenAnswer((_) => Future.value(accountDetails));

      final success = await _walletConnectService.connectSession(
          "AccountId", walletConnectAddress);

      expect(success, true);

      verify(mockAccountService.loadKey(accountDetails.id));

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

    testWidgets("return false on suspendedTime > 30", (tester) async {
      await tester.runAsync(() async {
        // for som
        final accountDetails = BasicAccount(
            id: "ABC", name: "Basic Name", publicKey: privateKey.publicKey);

        when(mockAccountService.getAccount(any))
            .thenAnswer((_) => Future.value(accountDetails));

        final newExpiredTime = DateTime.now().subtract(
            WalletConnectSession.inactivityTimeout + Duration(seconds: 1));

        when(mockKeyValueService.getString(PrefKey.sessionSuspendedTime))
            .thenAnswer((_) => Future.value(newExpiredTime.toIso8601String()));

        when(mockWalletConnectQueueService.removeWalletConnectSessionGroup(any))
            .thenAnswer((_) => Future.value());

        when(mockWalletConnection.connect(any, any))
            .thenAnswer((_) => Future.value());

        // verify previous connection is closed properly
        when(mockWalletConnection.disconnect())
            .thenAnswer((_) => Future.value());
        when(mockWalletConnection.dispose()).thenAnswer((_) => Future.value());

        final success =
            await _walletConnectService.tryRestoreSession("AccountId");

        verify(mockKeyValueService.removeString(PrefKey.sessionData));
        verify(mockKeyValueService.removeString(PrefKey.sessionSuspendedTime));
        verify(mockWalletConnectQueueService
            .removeWalletConnectSessionGroup(argThat(predicate((arg) {
          final wcAddress = arg as WalletConnectAddress;
          return wcAddress.fullUriString == walletConnectAddress;
        }))));

        expect(success, false);
      });
    });

    testWidgets("return false on private key not found", (_) async {
      when(mockAccountService.loadKey(any))
          .thenAnswer((_) => Future.value(null));
      final success =
          await _walletConnectService.tryRestoreSession("AccountId");
      expect(success, false);
    });

    testWidgets("return false on no account selected", (_) async {
      when(mockAccountService.getAccount(any))
          .thenAnswer((_) => Future.value(null));
      accountServiceEvents.selectedStreamController.add(null);
      final success =
          await _walletConnectService.tryRestoreSession("AccountId");
      expect(success, false);
    });

    testWidgets("verify calls", (_) async {
      final success =
          await _walletConnectService.tryRestoreSession("AccountId");

      expect(success, true);

      verify(mockAccountService.getAccount("AccountId"));
      verify(mockAccountService.loadKey(accountDetails.id));

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
