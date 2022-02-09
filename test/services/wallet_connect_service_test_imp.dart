import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:provenance_dart/proto.dart' as proto;
import 'package:provenance_dart/proto_bank.dart';
import 'package:provenance_dart/wallet.dart';
import 'package:provenance_dart/wallet_connect.dart';
import 'package:provenance_wallet/services/requests/send_request.dart';
import 'package:provenance_wallet/services/requests/sign_request.dart';
import 'package:provenance_wallet/services/wallet_connect_service_imp.dart';
import 'package:provenance_wallet/services/wallet_connect_service.dart';

import 'wallet_connect_service_test_imp.mocks.dart';

@GenerateMocks([ WalletConnection, TransactionHandler, proto.RawTxResponsePair ])
main() {
  final bip32Serialized = "tprv8kxV73NnPZyfSNfQThb5zjzysmbmGABtrZsGNcuhKnqPsmJFuyBvwJzSA24V59AAYWJfBVGxu4fGSKiLh3czp6kE1NNpP2SqUvHeStr8DC1";
  final PrivateKey _privateKey = PrivateKey.fromBip32(bip32Serialized);

  MockWalletConnection? _mockWalletConnection;
  MockTransactionHandler? _mockTransactionHandler;

  WalletConnectServiceImp? _walletConnectionService;

  void Function()? _statusListener;
  WalletConnectionDelegate? _capturedDelegate;

  setUp(() {
    _mockWalletConnection = MockWalletConnection();
    _mockTransactionHandler = MockTransactionHandler();

    when(_mockWalletConnection!.addListener(any)).thenAnswer((realInvocation) {
      _statusListener = realInvocation.positionalArguments[0];
    });

    when(_mockWalletConnection!.removeListener(any)).thenAnswer((realInvocation) {
      _statusListener = null;
    });

    when(_mockWalletConnection!.connect(captureAny))  .thenAnswer((realInvocation) {
      _capturedDelegate = realInvocation.positionalArguments[0];

      return Future.value();
    });

    _walletConnectionService = WalletConnectServiceImp(
      _privateKey,
      _mockWalletConnection!,
      _mockTransactionHandler!,
    );
  });

  test('address', () {
    final connectAddress = WalletConnectAddress.create("wc:739dffc7-0c57-4a1d-b769-4809aba3d41d@1?bridge=wss%3A%2F%2Ftest.figure.tech%2Fservice-wallet-connect-bridge%2Fws%2Fexternal&key=da27c28f9677e36b3f3be9ef0b9d7dc5f24983d322ca0b2d244f5d775f87929c");
    when(_mockWalletConnection!.address).thenReturn(connectAddress!);

    expect(_walletConnectionService!.address, connectAddress.bridge.toString());
  });

  group("disconnectSession", () {
    test('already disconnected', () async {
      when(_mockWalletConnection!.value).thenReturn(WalletConnectState.disconnected);

      final result = await _walletConnectionService!.disconnectSession();
      verify(_mockWalletConnection!.value);
      verify(_mockWalletConnection!.addListener(any));
      expect(result, true);
      verifyNoMoreInteractions(_mockWalletConnection);
    });

    test('already connected', () async {
      when(_mockWalletConnection!.value).thenReturn(WalletConnectState.connected);
      when(_mockWalletConnection!.disconnect()).thenAnswer((_) => Future.value());

      expectLater(_walletConnectionService!.status, emits(WalletConnectionServiceStatus.disconnected));
      final result = await _walletConnectionService!.disconnectSession();

      expect(result, true);
      verify(_mockWalletConnection!.disconnect());
      verify(_mockWalletConnection!.removeListener(any));
    });
  });

  group("connectWallet", () {
    test('already connected', () async {
      when(_mockWalletConnection!.value).thenReturn(WalletConnectState.connected);

      final result = await _walletConnectionService!.connectWallet();
      expect(result, true);
      verify(_mockWalletConnection!.value);
      verify(_mockWalletConnection!.disconnect());
      verify(_mockWalletConnection!.removeListener(any));

      verify(_mockWalletConnection!.connect(any));
      verify(_mockWalletConnection!.addListener(any));
    });

    test('already disconnected', () async {
      when(_mockWalletConnection!.value).thenReturn(WalletConnectState.disconnected);
      when(_mockWalletConnection!.disconnect()).thenAnswer((_) => Future.value());
      when(_mockWalletConnection!.connect(any)).thenAnswer((_) => Future.value());

      final result = await _walletConnectionService!.connectWallet();
      expect(result, true);
      verifyNever(_mockWalletConnection!.disconnect());
      verify(_mockWalletConnection!.addListener(any));
      verify(_mockWalletConnection!.connect(any));
    });
  });

  group("signTransactionFinish", () {
    final Msg = MsgSend(
      fromAddress: "From",
      toAddress: "To",
      amount: [
        proto.Coin(
          denom: "Denom1",
          amount: "123",
        ),
        proto.Coin(
          denom: "Denom2",
          amount: "46",
        ),
      ],
    );

    setUp(() {
      when(_mockWalletConnection!.value).thenReturn(WalletConnectState.disconnected);
    });

    test('no previous message', () async {
      final result = await _walletConnectionService!.signTransactionFinish(
        requestId: "Id",
        allowed: true
      );

      expect(result, false);
      verify(_mockWalletConnection!.addListener(any));
      verifyNoMoreInteractions(_mockWalletConnection);
    });

    test('invoke Delegate', () async {
      await _walletConnectionService!.connectWallet();

      expectLater(_walletConnectionService!.sendRequest, emits(predicate((arg) {
        final sendReq = arg as SendRequest;
        final transMsg = sendReq.message;
        expect(sendReq.description, "Desc");
        expect(sendReq.cost, "");
        expect(sendReq.id, isNotNull);
        expect(transMsg.fromAddress, Msg.fromAddress);
        expect(transMsg.toAddress, Msg.toAddress);
        expect(transMsg.amount, Msg.amount.first.amount);
        expect(transMsg.denom, Msg.amount.first.denom);

        return true;
      })));

      _capturedDelegate!.onApproveTransaction("Desc", "ADDR", Msg);
    });

    test('approve', () async {
      final rawTxResponsePair = MockRawTxResponsePair();

      when(_mockTransactionHandler!.executeTransaction(any, any))
            .thenAnswer((_) => Future.value(rawTxResponsePair));
      await _walletConnectionService!.connectWallet();

      // NOTE: if the stream has no listener then the add will not trigger an event
      // and the .first function will just hang forever
      final sendReqFuture = _walletConnectionService!.sendRequest.first;
      final approvalFuture = _capturedDelegate!.onApproveTransaction("Desc", "ADDR", Msg);

      final sendReq = await sendReqFuture;
      final result = await _walletConnectionService!.signTransactionFinish(
          requestId: sendReq.id,
          allowed: true,
      );

      expect(result, true);
      expect(await approvalFuture, rawTxResponsePair);
      verify(_mockTransactionHandler!.executeTransaction(argThat(predicate((arg) {
        final txBody = arg as proto.TxBody;
        expect(txBody.messages.length, 1);
        final msg = MsgSend.fromBuffer(txBody.messages[0].value);
        expect(msg.amount.length, Msg.amount.length);
        expect(msg.amount[0].amount, Msg.amount[0].amount);
        expect(msg.amount[0].denom, Msg.amount[0].denom);
        expect(msg.amount[1].amount, Msg.amount[1].amount);
        expect(msg.amount[1].denom, Msg.amount[1].denom);

        expect(msg.fromAddress, Msg.fromAddress);
        expect(msg.toAddress, Msg.toAddress);

        return true;
      })),
          _privateKey));
    });

    test('reject', () async {
      final rawTxResponsePair = MockRawTxResponsePair();

      when(_mockTransactionHandler!.executeTransaction(any, any))
          .thenAnswer((_) => Future.value(rawTxResponsePair));

      await _walletConnectionService!.connectWallet();

      // NOTE: if the stream has no listener then the add will not trigger an event
      // and the .first function will just hang forever
      final sendReqFuture = _walletConnectionService!.sendRequest.first;
      final approvalFuture = _capturedDelegate!.onApproveTransaction("Desc", "ADDR", Msg);

      final sendReq = await sendReqFuture;
      final result = await _walletConnectionService!.signTransactionFinish(
        requestId: sendReq.id,
        allowed: false,
      );

      expect(result, true);
      expect(await approvalFuture, null);
      verifyNoMoreInteractions(_mockTransactionHandler);
    });
  });

  group("sendMessageFinish", () {
    final Msg = utf8.encode("A test Message");

    setUp(() {
      when(_mockWalletConnection!.value).thenReturn(WalletConnectState.disconnected);
    });

    test('no previous message', () async {
      final result = await _walletConnectionService!.sendMessageFinish(
          requestId: "Id",
          allowed: true
      );

      expect(result, false);
      verify(_mockWalletConnection!.addListener(any));
      verifyNoMoreInteractions(_mockWalletConnection);
    });

    test('invoke Delegate', () async {
      await _walletConnectionService!.connectWallet();

      expectLater(_walletConnectionService!.signRequest, emits(predicate((arg) {
        final signRequest = arg as SignRequest;
        expect(signRequest.description, "Desc");
        expect(signRequest.message, "A test Message");
        expect(signRequest.cost, "");
        expect(signRequest.id, isNotNull);

        return true;
      })));

      _capturedDelegate!.onApproveSign("Desc", "ADDR", Msg);
    });

    test('approve', () async {
      await _walletConnectionService!.connectWallet();

      // NOTE: if the stream has no listener then the add will not trigger an event
      // and the .first function will just hang forever
      final sendReqFuture = _walletConnectionService!.signRequest.first;
      final approvalFuture = _capturedDelegate!.onApproveSign("Desc", "ADDR", Msg);

      final sendReq = await sendReqFuture;
      final result = await _walletConnectionService!.signTransactionFinish(
        requestId: sendReq.id,
        allowed: true,
      );

      expect(result, true);
      expect(await approvalFuture, _privateKey.defaultKey().signData(Hash.sha256(Msg))..removeLast());
    });

    test('reject', () async {
      await _walletConnectionService!.connectWallet();

      // NOTE: if the stream has no listener then the add will not trigger an event
      // and the .first function will just hang forever
      final sendReqFuture = _walletConnectionService!.signRequest.first;
      final approvalFuture = _capturedDelegate!.onApproveSign("Desc", "ADDR", Msg);

      final sendReq = await sendReqFuture;
      final result = await _walletConnectionService!.signTransactionFinish(
        requestId: sendReq.id,
        allowed: false,
      );

      expect(result, true);
      expect(await approvalFuture, null);
    });
  });

  test('status transition', () async {
    expectLater(_walletConnectionService!.status, emitsInOrder([
      // WalletConnectionServiceStatus.created,
      WalletConnectionServiceStatus.connecting,
      WalletConnectionServiceStatus.connected,
      WalletConnectionServiceStatus.disconnected
    ]));

    when(_mockWalletConnection!.value).thenReturn(WalletConnectState.connecting);
    _statusListener!();

    when(_mockWalletConnection!.value).thenReturn(WalletConnectState.connected);
    _statusListener!();

    when(_mockWalletConnection!.value).thenReturn(WalletConnectState.disconnected);
    _statusListener!();

  });
}