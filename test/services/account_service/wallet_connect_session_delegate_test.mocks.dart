// Mocks generated by Mockito 5.3.0 from annotations
// in provenance_wallet/test/services/account_service/wallet_connect_session_delegate_test.dart.
// Do not manually edit this file.

// ignore_for_file: no_leading_underscores_for_library_prefixes
import 'dart:async' as _i6;
import 'dart:ui' as _i12;

import 'package:mockito/mockito.dart' as _i1;
import 'package:provenance_dart/proto.dart' as _i3;
import 'package:provenance_dart/wallet.dart' as _i7;
import 'package:provenance_dart/wallet_connect.dart' as _i4;
import 'package:provenance_wallet/services/account_service/model/account_gas_estimate.dart'
    as _i2;
import 'package:provenance_wallet/services/account_service/transaction_handler.dart'
    as _i5;
import 'package:provenance_wallet/services/models/requests/send_request.dart'
    as _i10;
import 'package:provenance_wallet/services/models/requests/sign_request.dart'
    as _i9;
import 'package:provenance_wallet/services/models/wallet_connect_session_request_data.dart'
    as _i11;
import 'package:provenance_wallet/services/wallet_connect_queue_service/wallet_connect_queue_service.dart'
    as _i8;

// ignore_for_file: type=lint
// ignore_for_file: avoid_redundant_argument_values
// ignore_for_file: avoid_setters_without_getters
// ignore_for_file: comment_references
// ignore_for_file: implementation_imports
// ignore_for_file: invalid_use_of_visible_for_testing_member
// ignore_for_file: prefer_const_constructors
// ignore_for_file: unnecessary_parenthesis
// ignore_for_file: camel_case_types
// ignore_for_file: subtype_of_sealed_class

class _FakeAccountGasEstimate_0 extends _i1.SmartFake
    implements _i2.AccountGasEstimate {
  _FakeAccountGasEstimate_0(Object parent, Invocation parentInvocation)
      : super(parent, parentInvocation);
}

class _FakeRawTxResponsePair_1 extends _i1.SmartFake
    implements _i3.RawTxResponsePair {
  _FakeRawTxResponsePair_1(Object parent, Invocation parentInvocation)
      : super(parent, parentInvocation);
}

class _FakeWalletConnectAddress_2 extends _i1.SmartFake
    implements _i4.WalletConnectAddress {
  _FakeWalletConnectAddress_2(Object parent, Invocation parentInvocation)
      : super(parent, parentInvocation);
}

/// A class which mocks [TransactionHandler].
///
/// See the documentation for Mockito's code generation for more information.
class MockTransactionHandler extends _i1.Mock
    implements _i5.TransactionHandler {
  MockTransactionHandler() {
    _i1.throwOnMissingStub(this);
  }

  @override
  _i6.Stream<_i5.TransactionResponse> get transaction =>
      (super.noSuchMethod(Invocation.getter(#transaction),
              returnValue: _i6.Stream<_i5.TransactionResponse>.empty())
          as _i6.Stream<_i5.TransactionResponse>);
  @override
  _i6.Future<_i2.AccountGasEstimate> estimateGas(
          _i3.TxBody? txBody, List<_i7.IPubKey>? signers) =>
      (super.noSuchMethod(Invocation.method(#estimateGas, [txBody, signers]),
              returnValue: _i6.Future<_i2.AccountGasEstimate>.value(
                  _FakeAccountGasEstimate_0(this,
                      Invocation.method(#estimateGas, [txBody, signers]))))
          as _i6.Future<_i2.AccountGasEstimate>);
  @override
  _i6.Future<_i3.RawTxResponsePair> executeTransaction(
          _i3.TxBody? txBody, _i7.IPrivKey? privateKey,
          [_i2.AccountGasEstimate? gasEstimate]) =>
      (super.noSuchMethod(Invocation.method(#executeTransaction, [txBody, privateKey, gasEstimate]),
              returnValue: _i6.Future<_i3.RawTxResponsePair>.value(
                  _FakeRawTxResponsePair_1(
                      this,
                      Invocation.method(
                          #executeTransaction, [txBody, privateKey, gasEstimate]))))
          as _i6.Future<_i3.RawTxResponsePair>);
}

/// A class which mocks [WalletConnectQueueService].
///
/// See the documentation for Mockito's code generation for more information.
class MockWalletConnectQueueService extends _i1.Mock
    implements _i8.WalletConnectQueueService {
  MockWalletConnectQueueService() {
    _i1.throwOnMissingStub(this);
  }

  @override
  _i6.Future<void> close() => (super.noSuchMethod(Invocation.method(#close, []),
      returnValue: _i6.Future<void>.value(),
      returnValueForMissingStub: _i6.Future<void>.value()) as _i6.Future<void>);
  @override
  _i6.Future<void> createWalletConnectSessionGroup(
          _i4.WalletConnectAddress? address,
          String? walletAddress,
          _i4.ClientMeta? clientMeta) =>
      (super.noSuchMethod(
              Invocation.method(#createWalletConnectSessionGroup,
                  [address, walletAddress, clientMeta]),
              returnValue: _i6.Future<void>.value(),
              returnValueForMissingStub: _i6.Future<void>.value())
          as _i6.Future<void>);
  @override
  _i6.Future<void> removeWalletConnectSessionGroup(
          _i4.WalletConnectAddress? address) =>
      (super.noSuchMethod(
              Invocation.method(#removeWalletConnectSessionGroup, [address]),
              returnValue: _i6.Future<void>.value(),
              returnValueForMissingStub: _i6.Future<void>.value())
          as _i6.Future<void>);
  @override
  _i6.Future<void> updateConnectionDetails(
          _i4.WalletConnectAddress? address, _i4.ClientMeta? clientMeta) =>
      (super.noSuchMethod(
          Invocation.method(#updateConnectionDetails, [address, clientMeta]),
          returnValue: _i6.Future<void>.value(),
          returnValueForMissingStub:
              _i6.Future<void>.value()) as _i6.Future<void>);
  @override
  _i6.Future<void> addWalletConnectSignRequest(
          _i4.WalletConnectAddress? address, _i9.SignRequest? signRequest) =>
      (super.noSuchMethod(
              Invocation.method(
                  #addWalletConnectSignRequest, [address, signRequest]),
              returnValue: _i6.Future<void>.value(),
              returnValueForMissingStub: _i6.Future<void>.value())
          as _i6.Future<void>);
  @override
  _i6.Future<void> addWalletConnectSendRequest(
          _i4.WalletConnectAddress? address, _i10.SendRequest? sendRequest) =>
      (super.noSuchMethod(
              Invocation.method(
                  #addWalletConnectSendRequest, [address, sendRequest]),
              returnValue: _i6.Future<void>.value(),
              returnValueForMissingStub: _i6.Future<void>.value())
          as _i6.Future<void>);
  @override
  _i6.Future<void> addWalletApproveRequest(_i4.WalletConnectAddress? address,
          _i11.WalletConnectSessionRequestData? approveRequestData) =>
      (super.noSuchMethod(
              Invocation.method(
                  #addWalletApproveRequest, [address, approveRequestData]),
              returnValue: _i6.Future<void>.value(),
              returnValueForMissingStub: _i6.Future<void>.value())
          as _i6.Future<void>);
  @override
  _i6.Future<_i8.WalletConnectQueueGroup?> loadGroup(
          _i4.WalletConnectAddress? address) =>
      (super.noSuchMethod(Invocation.method(#loadGroup, [address]),
              returnValue: _i6.Future<_i8.WalletConnectQueueGroup?>.value())
          as _i6.Future<_i8.WalletConnectQueueGroup?>);
  @override
  _i6.Future<dynamic> loadQueuedAction(
          _i4.WalletConnectAddress? address, String? requestId) =>
      (super.noSuchMethod(
          Invocation.method(#loadQueuedAction, [address, requestId]),
          returnValue: _i6.Future<dynamic>.value()) as _i6.Future<dynamic>);
  @override
  _i6.Future<void> removeRequest(
          _i4.WalletConnectAddress? address, String? requestId) =>
      (super.noSuchMethod(
              Invocation.method(#removeRequest, [address, requestId]),
              returnValue: _i6.Future<void>.value(),
              returnValueForMissingStub: _i6.Future<void>.value())
          as _i6.Future<void>);
  @override
  _i6.Future<List<_i8.WalletConnectQueueGroup>> loadAllGroups() =>
      (super.noSuchMethod(Invocation.method(#loadAllGroups, []),
              returnValue: _i6.Future<List<_i8.WalletConnectQueueGroup>>.value(
                  <_i8.WalletConnectQueueGroup>[]))
          as _i6.Future<List<_i8.WalletConnectQueueGroup>>);
  @override
  void addListener(_i12.VoidCallback? listener) =>
      super.noSuchMethod(Invocation.method(#addListener, [listener]),
          returnValueForMissingStub: null);
  @override
  void removeListener(_i12.VoidCallback? listener) =>
      super.noSuchMethod(Invocation.method(#removeListener, [listener]),
          returnValueForMissingStub: null);
  @override
  void notifyListeners() =>
      super.noSuchMethod(Invocation.method(#notifyListeners, []),
          returnValueForMissingStub: null);
}

/// A class which mocks [WalletConnection].
///
/// See the documentation for Mockito's code generation for more information.
class MockWalletConnection extends _i1.Mock implements _i4.WalletConnection {
  MockWalletConnection() {
    _i1.throwOnMissingStub(this);
  }

  @override
  _i4.WalletConnectAddress get address => (super.noSuchMethod(
          Invocation.getter(#address),
          returnValue:
              _FakeWalletConnectAddress_2(this, Invocation.getter(#address)))
      as _i4.WalletConnectAddress);
  @override
  _i4.WalletConnectState get value => (super.noSuchMethod(
          Invocation.getter(#value),
          returnValue: _i4.WalletConnectState.connecting)
      as _i4.WalletConnectState);
  @override
  _i6.Future<void> connect(_i4.WalletConnectionDelegate? delegate,
          [_i4.SessionRestoreData? restoreData]) =>
      (super.noSuchMethod(Invocation.method(#connect, [delegate, restoreData]),
              returnValue: _i6.Future<void>.value(),
              returnValueForMissingStub: _i6.Future<void>.value())
          as _i6.Future<void>);
  @override
  _i6.Future<void> dispose() => (super.noSuchMethod(
      Invocation.method(#dispose, []),
      returnValue: _i6.Future<void>.value(),
      returnValueForMissingStub: _i6.Future<void>.value()) as _i6.Future<void>);
  @override
  _i6.Future<void> disconnect() => (super.noSuchMethod(
      Invocation.method(#disconnect, []),
      returnValue: _i6.Future<void>.value(),
      returnValueForMissingStub: _i6.Future<void>.value()) as _i6.Future<void>);
  @override
  _i6.Future<void> sendError(int? requestId, String? error) =>
      (super.noSuchMethod(Invocation.method(#sendError, [requestId, error]),
              returnValue: _i6.Future<void>.value(),
              returnValueForMissingStub: _i6.Future<void>.value())
          as _i6.Future<void>);
  @override
  _i6.Future<void> reject(int? requestId) => (super.noSuchMethod(
      Invocation.method(#reject, [requestId]),
      returnValue: _i6.Future<void>.value(),
      returnValueForMissingStub: _i6.Future<void>.value()) as _i6.Future<void>);
  @override
  _i6.Future<void> sendTransactionResult(
          int? requestId, _i3.RawTxResponsePair? txResponsePair) =>
      (super.noSuchMethod(
              Invocation.method(
                  #sendTransactionResult, [requestId, txResponsePair]),
              returnValue: _i6.Future<void>.value(),
              returnValueForMissingStub: _i6.Future<void>.value())
          as _i6.Future<void>);
  @override
  _i6.Future<void> sendSignResult(int? requestId, List<int>? signedData) =>
      (super.noSuchMethod(
              Invocation.method(#sendSignResult, [requestId, signedData]),
              returnValue: _i6.Future<void>.value(),
              returnValueForMissingStub: _i6.Future<void>.value())
          as _i6.Future<void>);
  @override
  _i6.Future<void> sendApproveSession(
          int? requestId, _i4.SessionApprovalData? clientMeta,
          [_i4.ClientMeta? peerMeta]) =>
      (super.noSuchMethod(
              Invocation.method(
                  #sendApproveSession, [requestId, clientMeta, peerMeta]),
              returnValue: _i6.Future<void>.value(),
              returnValueForMissingStub: _i6.Future<void>.value())
          as _i6.Future<void>);
  @override
  void addListener(_i12.VoidCallback? listener) =>
      super.noSuchMethod(Invocation.method(#addListener, [listener]),
          returnValueForMissingStub: null);
  @override
  void removeListener(_i12.VoidCallback? listener) =>
      super.noSuchMethod(Invocation.method(#removeListener, [listener]),
          returnValueForMissingStub: null);
}
