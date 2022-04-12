// Mocks generated by Mockito 5.1.0 from annotations
// in provenance_wallet/test/services/wallet_service/wallet_connect_session_test.dart.
// Do not manually edit this file.

import 'dart:async' as _i5;
import 'dart:ui' as _i6;

import 'package:mockito/mockito.dart' as _i1;
import 'package:provenance_dart/proto.dart' as _i7;
import 'package:provenance_dart/src/wallet_connect/wallet_connect_address.dart'
    as _i2;
import 'package:provenance_dart/wallet_connect.dart' as _i4;
import 'package:provenance_wallet/services/remote_notification/remote_notification_service.dart'
    as _i8;
import 'package:provenance_wallet/services/wallet_service/wallet_connect_session_delegate.dart'
    as _i3;

// ignore_for_file: type=lint
// ignore_for_file: avoid_redundant_argument_values
// ignore_for_file: avoid_setters_without_getters
// ignore_for_file: comment_references
// ignore_for_file: implementation_imports
// ignore_for_file: invalid_use_of_visible_for_testing_member
// ignore_for_file: prefer_const_constructors
// ignore_for_file: unnecessary_parenthesis
// ignore_for_file: camel_case_types

class _FakeWalletConnectAddress_0 extends _i1.Fake
    implements _i2.WalletConnectAddress {}

class _FakeWalletConnectSessionDelegateEvents_1 extends _i1.Fake
    implements _i3.WalletConnectSessionDelegateEvents {}

/// A class which mocks [WalletConnection].
///
/// See the documentation for Mockito's code generation for more information.
class MockWalletConnection extends _i1.Mock implements _i4.WalletConnection {
  MockWalletConnection() {
    _i1.throwOnMissingStub(this);
  }

  @override
  _i2.WalletConnectAddress get address => (super.noSuchMethod(
      Invocation.getter(#address),
      returnValue: _FakeWalletConnectAddress_0()) as _i2.WalletConnectAddress);
  @override
  _i4.WalletConnectState get value => (super.noSuchMethod(
          Invocation.getter(#value),
          returnValue: _i4.WalletConnectState.connecting)
      as _i4.WalletConnectState);
  @override
  _i5.Future<void> connect(_i4.WalletConnectionDelegate? delegate,
          [_i4.SessionRestoreData? restoreData]) =>
      (super.noSuchMethod(Invocation.method(#connect, [delegate, restoreData]),
          returnValue: Future<void>.value(),
          returnValueForMissingStub: Future<void>.value()) as _i5.Future<void>);
  @override
  _i5.Future<void> dispose() =>
      (super.noSuchMethod(Invocation.method(#dispose, []),
          returnValue: Future<void>.value(),
          returnValueForMissingStub: Future<void>.value()) as _i5.Future<void>);
  @override
  _i5.Future<void> disconnect() =>
      (super.noSuchMethod(Invocation.method(#disconnect, []),
          returnValue: Future<void>.value(),
          returnValueForMissingStub: Future<void>.value()) as _i5.Future<void>);
  @override
  void addListener(_i6.VoidCallback? listener) =>
      super.noSuchMethod(Invocation.method(#addListener, [listener]),
          returnValueForMissingStub: null);
  @override
  void removeListener(_i6.VoidCallback? listener) =>
      super.noSuchMethod(Invocation.method(#removeListener, [listener]),
          returnValueForMissingStub: null);
}

/// A class which mocks [WalletConnectSessionDelegate].
///
/// See the documentation for Mockito's code generation for more information.
class MockWalletConnectSessionDelegate extends _i1.Mock
    implements _i3.WalletConnectSessionDelegate {
  MockWalletConnectSessionDelegate() {
    _i1.throwOnMissingStub(this);
  }

  @override
  _i3.WalletConnectSessionDelegateEvents get events =>
      (super.noSuchMethod(Invocation.getter(#events),
              returnValue: _FakeWalletConnectSessionDelegateEvents_1())
          as _i3.WalletConnectSessionDelegateEvents);
  @override
  _i5.Future<bool> complete(String? requestId, bool? allowed) =>
      (super.noSuchMethod(Invocation.method(#complete, [requestId, allowed]),
          returnValue: Future<bool>.value(false)) as _i5.Future<bool>);
  @override
  void onApproveSession(_i4.SessionRequestData? data,
          _i4.AcceptCallback<_i4.SessionApprovalData?>? callback) =>
      super.noSuchMethod(Invocation.method(#onApproveSession, [data, callback]),
          returnValueForMissingStub: null);
  @override
  void onApproveSign(String? description, String? address, List<int>? msg,
          _i4.AcceptCallback<List<int>?>? callback) =>
      super.noSuchMethod(
          Invocation.method(
              #onApproveSign, [description, address, msg, callback]),
          returnValueForMissingStub: null);
  @override
  void onApproveTransaction(
          String? description,
          String? address,
          _i4.SignTransactionData? signTransactionData,
          _i4.AcceptCallback<_i7.RawTxResponsePair?>? callback) =>
      super.noSuchMethod(
          Invocation.method(#onApproveTransaction,
              [description, address, signTransactionData, callback]),
          returnValueForMissingStub: null);
  @override
  void onClose() => super.noSuchMethod(Invocation.method(#onClose, []),
      returnValueForMissingStub: null);
  @override
  void onError(Exception? exception) =>
      super.noSuchMethod(Invocation.method(#onError, [exception]),
          returnValueForMissingStub: null);
}

/// A class which mocks [RemoteNotificationService].
///
/// See the documentation for Mockito's code generation for more information.
class MockRemoteNotificationService extends _i1.Mock
    implements _i8.RemoteNotificationService {
  MockRemoteNotificationService() {
    _i1.throwOnMissingStub(this);
  }

  @override
  _i5.Future<void> registerForPushNotifications(String? topic) => (super
      .noSuchMethod(Invocation.method(#registerForPushNotifications, [topic]),
          returnValue: Future<void>.value(),
          returnValueForMissingStub: Future<void>.value()) as _i5.Future<void>);
  @override
  _i5.Future<void> unregisterForPushNotifications(String? topic) => (super
      .noSuchMethod(Invocation.method(#unregisterForPushNotifications, [topic]),
          returnValue: Future<void>.value(),
          returnValueForMissingStub: Future<void>.value()) as _i5.Future<void>);
}
