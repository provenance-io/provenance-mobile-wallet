import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:provenance_dart/wallet.dart' as wallet;
import 'package:provenance_dart/wallet_connect.dart';
import 'package:provenance_wallet/services/account_service/wallet_connect_session.dart';
import 'package:provenance_wallet/services/account_service/wallet_connect_session_delegate.dart';
import 'package:provenance_wallet/services/key_value_service/key_value_service.dart';
import 'package:provenance_wallet/services/models/wallet_connect_session_request_data.dart';
import 'package:provenance_wallet/services/models/wallet_connect_session_restore_data.dart';
import 'package:provenance_wallet/services/remote_notification/remote_notification_service.dart';

import 'wallet_connect_session_test.mocks.dart';

const coin = wallet.Coin.testNet;
final seed = wallet.Mnemonic.createSeed(
  wallet.Mnemonic.fromEntropy(List.generate(256, (index) => index)),
);
final privateKey = wallet.PrivateKey.fromSeed(seed, coin);
final publicKey = privateKey.defaultKey().publicKey;

@GenerateMocks([
  WalletConnection,
  WalletConnectSessionDelegate,
  RemoteNotificationService,
  KeyValueService,
])
main() {
  group("WalletConnectSession", () {
    MockWalletConnection? mockWalletConnection;
    MockWalletConnectSessionDelegate? mockWalletConnectSessionDelegate;
    MockRemoteNotificationService? mockRemoteNotificationService;
    WalletConnectSession? session;
    WalletConnectSessionDelegateEvents? events;
    MockKeyValueService? mockKeyValueService;

    setUp(() {
      mockWalletConnection = MockWalletConnection();
      mockWalletConnectSessionDelegate = MockWalletConnectSessionDelegate();
      mockRemoteNotificationService = MockRemoteNotificationService();
      events = WalletConnectSessionDelegateEvents();
      mockKeyValueService = MockKeyValueService();

      when(mockWalletConnectSessionDelegate!.events).thenReturn(events!);

      session = WalletConnectSession(
        accountId: "WalletId",
        connection: mockWalletConnection!,
        delegate: mockWalletConnectSessionDelegate!,
        remoteNotificationService: mockRemoteNotificationService!,
        keyValueService: mockKeyValueService!,
      );
    });

    test('closeButRetainSession', () async {
      await session!.closeButRetainSession();
      verify(mockWalletConnection!.dispose());
    });

    test('dispose', () async {
      await session!.dispose();
      verify(mockWalletConnection!.removeListener(any));
    });

    group("connect", () {
      test('no restore', () async {
        when(mockWalletConnection!.connect(any, any))
            .thenAnswer((_) => Future.value());

        final result = await session!.connect();

        verify(mockWalletConnection!
            .connect(mockWalletConnectSessionDelegate!, null));

        expect(result, true);
      });

      test('with restore', () async {
        final restore = WalletConnectSessionRestoreData(
          ClientMeta(),
          SessionRestoreData(
            privateKey,
            "ChainId",
            "peerId",
            "",
          ),
        );

        when(mockKeyValueService!.setString(any, any))
            .thenAnswer((_) => Future.value(true));

        when(mockWalletConnection!.connect(any, any))
            .thenAnswer((_) => Future.value());

        final result = await session!.connect(restore);

        verify(mockWalletConnection!
            .connect(mockWalletConnectSessionDelegate!, restore.data));

        verify(
          mockRemoteNotificationService!
              .registerForPushNotifications(restore.data.peerId),
        );

        expect(result, true);
        expect(
          session!.sessionEvents.state.value.details,
          restore.clientMeta,
        );
      });

      test('error', () async {
        final exception = Exception('a');
        when(mockWalletConnection!.connect(any, any))
            .thenAnswer((_) => Future.error(exception));

        expect(await session!.connect(), false);
      });
    });

    group("signTransactionFinish", () {
      test('completed', () async {
        when(mockWalletConnectSessionDelegate!.complete(any, any))
            .thenAnswer((_) => Future.value(true));
        when(mockKeyValueService!.setString(any, any))
            .thenAnswer((_) => Future.value(true));
        final result = await session!
            .signTransactionFinish(requestId: "ABCD", allowed: true);

        expect(result, true);
        verify(mockWalletConnectSessionDelegate!.complete("ABCD", true));
      });
    });

    group("sendMessageFinish", () {
      test('completed', () async {
        when(mockWalletConnectSessionDelegate!.complete(any, any))
            .thenAnswer((_) => Future.value(true));
        when(mockKeyValueService!.setString(any, any))
            .thenAnswer((_) => Future.value(true));
        final result =
            await session!.sendMessageFinish(requestId: "ABCD", allowed: true);

        expect(result, true);
        verify(mockWalletConnectSessionDelegate!.complete("ABCD", true));
      });
    });

    group('approveSession', () {
      test('success', () async {
        when(mockWalletConnectSessionDelegate!.complete(any, any))
            .thenAnswer((_) => Future.value(true));
        when(mockKeyValueService!.setString(any, any))
            .thenAnswer((_) => Future.value(true));
        final details = WalletConnectSessionRequestData(
          "ABC",
          SessionRequestData(
            "PeerId",
            "RemoteId",
            ClientMeta(),
            WalletConnectAddress.create(
              "wc:84f16bc5-96de-41e7-b907-084f2f3e8bf6@1?bridge=wss%3A%2F%2Ftest.figure.tech%2Fservice-wallet-connect-bridge%2Fws%2Fexternal&key=d3434a394a9ee70c1e83f683c2d07a3bb8857ec5216c61592d120f44fda48bbf",
            )!,
          ),
        );

        final result =
            await session!.approveSession(details: details, allowed: true);

        expect(result, true);
        expect(
          session!.sessionEvents.state.value.details,
          details.data.clientMeta,
        );
        verify(mockRemoteNotificationService!
            .registerForPushNotifications(details.data.peerId));
        verify(mockWalletConnectSessionDelegate!.complete(details.id, true));
      });
    });
  });
}
