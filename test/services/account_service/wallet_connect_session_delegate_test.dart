import 'package:flutter_test/flutter_test.dart';
import 'package:grpc/grpc.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:provenance_dart/proto.dart' as proto;
import 'package:provenance_dart/proto_bank.dart';
import 'package:provenance_dart/wallet.dart';
import 'package:provenance_dart/wallet_connect.dart';
import 'package:provenance_wallet/services/account_service/model/account_gas_estimate.dart';
import 'package:provenance_wallet/services/account_service/transaction_handler.dart';
import 'package:provenance_wallet/services/account_service/wallet_connect_session_delegate.dart';
import 'package:provenance_wallet/services/models/requests/send_request.dart';
import 'package:provenance_wallet/services/models/requests/sign_request.dart';
import 'package:provenance_wallet/services/models/wallet_connect_session_request_data.dart';
import 'package:provenance_wallet/services/wallet_connect_queue_service/wallet_connect_queue_service.dart';

import './wallet_connect_session_delegate_test.mocks.dart';
import '../../test_helpers.dart';

final phrase =
    "nasty carbon end inject case prison foam tube damage poverty timber sea boring someone husband fish whip motion mail canyon census success jungle can"
        .split(" ");

final seed = Mnemonic.createSeed(phrase);
final privateKey = PrivateKey.fromSeed(seed, Coin.mainNet);
final publicKey = privateKey.defaultKey().publicKey;
const walletConnectAddressStr =
    "wc:c2572162-bc23-442c-95c7-a4b6403331f4@1?bridge=wss%3A%2F%2Ftest.figure.tech%2Fservice-wallet-connect-bridge%2Fws%2Fexternal&key=c90653342c66a002944cff439239b79cc6fdde42b61a10c6d1e8d05506bd92bf";
final walletConnectAddr = WalletConnectAddress.create(walletConnectAddressStr)!;

@GenerateMocks(
    [TransactionHandler, WalletConnectQueueService, WalletConnection])
void main() {
  late MockTransactionHandler mockTransactionHandler;
  late MockWalletConnectQueueService mockWalletConnectQueueService;
  late MockWalletConnection mockWalletConnection;

  late WalletConnectSessionDelegate delegate;

  final waleltInfo = WalletInfo("ABC", "Name", Coin.testNet);

  setUp(() {
    mockTransactionHandler = MockTransactionHandler();
    mockWalletConnectQueueService = MockWalletConnectQueueService();
    mockWalletConnection = MockWalletConnection();

    delegate = WalletConnectSessionDelegate(
        privateKey: privateKey,
        walletInfo: waleltInfo,
        connection: mockWalletConnection,
        transactionHandler: mockTransactionHandler,
        queueService: mockWalletConnectQueueService,
        address: walletConnectAddr);
  });

  group("WalletConnectSessionDelegateEvents", () {
    late WalletConnectSessionDelegateEvents source;
    late WalletConnectSessionDelegateEvents listener;

    setUp(() {
      source = WalletConnectSessionDelegateEvents();
      listener = WalletConnectSessionDelegateEvents();
    });

    test("Listeners are attached properly", () {
      expect(source.onClose, StreamHasListener(false));
      expect(source.sessionRequest, StreamHasListener(false));
      expect(source.signRequest, StreamHasListener(false));
      expect(source.sendRequest, StreamHasListener(false));
      expect(source.onDidError, StreamHasListener(false));
      expect(source.onResponse, StreamHasListener(false));

      listener.listen(source);

      expect(source.onClose, StreamHasListener(true));
      expect(source.sessionRequest, StreamHasListener(true));
      expect(source.signRequest, StreamHasListener(true));
      expect(source.sendRequest, StreamHasListener(true));
      expect(source.onDidError, StreamHasListener(true));
      expect(source.onResponse, StreamHasListener(true));
    });

    test("Listeners are removed on clear", () async {
      listener.listen(source);

      await listener.clear();

      expect(source.onClose, StreamHasListener(false));
      expect(source.sessionRequest, StreamHasListener(false));
      expect(source.signRequest, StreamHasListener(false));
      expect(source.sendRequest, StreamHasListener(false));
      expect(source.onDidError, StreamHasListener(false));
      expect(source.onResponse, StreamHasListener(false));
    });

    test('dispose', () async {
      listener.listen(source);

      await listener.dispose();

      expect(source.onClose, StreamHasListener(false));
      expect(source.sessionRequest, StreamHasListener(false));
      expect(source.signRequest, StreamHasListener(false));
      expect(source.sendRequest, StreamHasListener(false));
      expect(source.onDidError, StreamHasListener(false));
      expect(source.onResponse, StreamHasListener(false));

      // ensure source stream is still open
      expect(source.onClose, StreamClosed(false));
      expect(source.sessionRequest, StreamClosed(false));
      expect(source.signRequest, StreamClosed(false));
      expect(source.sendRequest, StreamClosed(false));
      expect(source.onDidError, StreamClosed(false));
      expect(source.onResponse, StreamClosed(false));

      expect(listener.onClose, StreamClosed(true));
      expect(listener.sessionRequest, StreamClosed(true));
      expect(listener.signRequest, StreamClosed(true));
      expect(listener.sendRequest, StreamClosed(true));
      expect(listener.onDidError, StreamClosed(true));
      expect(listener.onResponse, StreamClosed(true));
    });
  });

  group("WalletConnectSessionDelegate", () {
    test("onApproveSession", () async {
      const requestId = 100;
      final clientMeta = ClientMeta(
          description: "Desc",
          url: Uri.parse("http://test.com"),
          icons: [],
          name: "Name");

      final sessionData = SessionRequestData(
          "PeerId", "RemotePeerId", clientMeta, walletConnectAddr);

      delegate.onApproveSession(requestId, sessionData);

      verify(mockWalletConnectQueueService.createWalletConnectSessionGroup(
          walletConnectAddr, publicKey.address, clientMeta));

      final pred = predicate((arg) {
        final details = arg as WalletConnectSessionRequestData;
        expect(details.data, sessionData);
        expect(details.id, isNotNull);
        expect(details.requestId, requestId);

        return true;
      });

      await expectLater(delegate.events.sessionRequest, emits(pred));
      verify(mockWalletConnectQueueService.addWalletApproveRequest(
          walletConnectAddr, argThat(pred)));
    });

    test("onApproveSign", () async {
      const requestId = 100;
      const description = "Desc";
      const address = "Address";
      const msg = "TestMsg";

      delegate.onApproveSign(requestId, description, address, msg.codeUnits);

      final pred = predicate((arg) {
        final details = arg as SignRequest;
        expect(details.id, isNotNull);
        expect(details.requestId, requestId);
        expect(details.message, msg);
        expect(details.description, description);
        expect(details.address, address);

        return true;
      });

      // await expectLater(delegate.events.signRequest, emits(neverCalled));

      verify(mockWalletConnectQueueService.addWalletConnectSignRequest(
          walletConnectAddr, argThat(pred)));
    });

    test("onApproveTransaction", () async {
      final gasEstimate = AccountGasEstimate(100, 400);

      when(mockTransactionHandler.estimateGas(any, any))
          .thenAnswer((_) => Future.value(gasEstimate));

      const requestId = 100;
      const description = "Desc";
      const address = "Address";
      final transData = SignTransactionData([
        MsgSend(
            fromAddress: "FromAddress",
            toAddress: "ToAddress",
            amount: [proto.Coin(amount: "1", denom: "nhash")]),
      ], proto.Coin(amount: "111", denom: "nhash"));

      delegate.onApproveTransaction(requestId, description, address, transData);

      final pred = predicate((arg) {
        final details = arg as SendRequest;
        expect(details.id, isNotNull);
        expect(details.requestId, requestId);
        expect(details.messages, transData.proposedMessages);
        expect(details.description, description);
        expect(details.gasEstimate.adjustment, gasEstimate.adjustment);
        expect(details.gasEstimate.estimate, gasEstimate.estimate);
        expect(details.gasEstimate.feeAdjustment, gasEstimate.feeAdjustment);

        return true;
      });

      await untilCalled(
          mockWalletConnectQueueService.addWalletConnectSendRequest(any, any));

      verify(mockWalletConnectQueueService.addWalletConnectSendRequest(
          walletConnectAddr, argThat(pred)));

      verify(mockTransactionHandler.estimateGas(argThat(predicate((arg) {
        return true;
      })), argThat(predicate((arg) {
        final actual = (arg as List<IPubKey>)[0];

        expect(actual.address, publicKey.address);
        return true;
      }))));
    });

    test("onApproveTransaction passes on grpc error", () async {
      final error = GrpcError.cancelled("Test Cancelled");

      when(mockTransactionHandler.estimateGas(any, any))
          .thenAnswer((_) => Future.error(error));

      const requestId = 100;
      const description = "Desc";
      const address = "Address";
      final transData = SignTransactionData([
        MsgSend(
            fromAddress: "FromAddress",
            toAddress: "ToAddress",
            amount: [proto.Coin(amount: "1", denom: "nhash")]),
      ], proto.Coin(amount: "111", denom: "nhash"));

      delegate.onApproveTransaction(requestId, description, address, transData);

      await expectLater(delegate.events.onDidError, emits("Test Cancelled"));
    });

    test("onError - non-WalletConnectException", () async {
      final ex = Exception("Test Exception");

      expectLater(delegate.events.onDidError, emits(ex.toString()));

      delegate.onError(ex);
    });

    test("onError - WalletConnectException", () async {
      final ex = WalletConnectException("Test Exception");

      expectLater(delegate.events.onDidError, emits(ex.message));

      delegate.onError(ex);
    });

    group("onClose", () {
      setUp(() {
        when(mockWalletConnectQueueService
                .removeWalletConnectSessionGroup(walletConnectAddr))
            .thenAnswer((_) => Future.value());
      });

      test("onClose should remove queue WalletConnect items", () async {
        delegate.onClose();

        verify(mockWalletConnectQueueService
            .removeWalletConnectSessionGroup(walletConnectAddr));
      });

      test("onClose sets close event", () async {
        int closeCount = 0;
        await expectLater(delegate.events.onClose, predicate((arg) {
          closeCount += 1;
          return true;
        }));

        delegate.onClose();
        expect(closeCount, 1);
      });
    });
  });
}
