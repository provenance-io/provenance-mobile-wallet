// Mocks generated by Mockito 5.3.0 from annotations
// in provenance_wallet/test/dashboard/home_bloc_test.dart.
// Do not manually edit this file.

// ignore_for_file: no_leading_underscores_for_library_prefixes
import 'dart:async' as _i5;
import 'dart:ui' as _i9;

import 'package:mockito/mockito.dart' as _i1;
import 'package:provenance_wallet/services/remote_notification/multi_sig_remote_notification.dart'
    as _i6;
import 'package:provenance_wallet/services/remote_notification/remote_notification_service.dart'
    as _i4;
import 'package:provenance_wallet/services/wallet_connect_service/models/session_action.dart'
    as _i8;
import 'package:provenance_wallet/services/wallet_connect_service/wallet_connect_service.dart'
    as _i7;
import 'package:provenance_wallet/services/wallet_connect_service/wallet_connect_session.dart'
    as _i2;
import 'package:provenance_wallet/services/wallet_connect_service/wallet_connect_session_delegate.dart'
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
// ignore_for_file: subtype_of_sealed_class

class _FakeWalletConnectSessionEvents_0 extends _i1.SmartFake
    implements _i2.WalletConnectSessionEvents {
  _FakeWalletConnectSessionEvents_0(Object parent, Invocation parentInvocation)
      : super(parent, parentInvocation);
}

class _FakeWalletConnectSessionDelegateEvents_1 extends _i1.SmartFake
    implements _i3.WalletConnectSessionDelegateEvents {
  _FakeWalletConnectSessionDelegateEvents_1(
      Object parent, Invocation parentInvocation)
      : super(parent, parentInvocation);
}

/// A class which mocks [RemoteNotificationService].
///
/// See the documentation for Mockito's code generation for more information.
class MockRemoteNotificationService extends _i1.Mock
    implements _i4.RemoteNotificationService {
  MockRemoteNotificationService() {
    _i1.throwOnMissingStub(this);
  }

  @override
  _i5.Stream<_i6.MultiSigRemoteNotification> get multiSig =>
      (super.noSuchMethod(Invocation.getter(#multiSig),
              returnValue: _i5.Stream<_i6.MultiSigRemoteNotification>.empty())
          as _i5.Stream<_i6.MultiSigRemoteNotification>);
  @override
  bool isRegistered(String? topic) =>
      (super.noSuchMethod(Invocation.method(#isRegistered, [topic]),
          returnValue: false) as bool);
  @override
  _i5.Future<void> registerForPushNotifications(String? topic) =>
      (super.noSuchMethod(
              Invocation.method(#registerForPushNotifications, [topic]),
              returnValue: _i5.Future<void>.value(),
              returnValueForMissingStub: _i5.Future<void>.value())
          as _i5.Future<void>);
  @override
  _i5.Future<void> unregisterForPushNotifications(String? topic) =>
      (super.noSuchMethod(
              Invocation.method(#unregisterForPushNotifications, [topic]),
              returnValue: _i5.Future<void>.value(),
              returnValueForMissingStub: _i5.Future<void>.value())
          as _i5.Future<void>);
}

/// A class which mocks [WalletConnectService].
///
/// See the documentation for Mockito's code generation for more information.
class MockWalletConnectService extends _i1.Mock
    implements _i7.WalletConnectService {
  MockWalletConnectService() {
    _i1.throwOnMissingStub(this);
  }

  @override
  _i2.WalletConnectSessionEvents get sessionEvents =>
      (super.noSuchMethod(Invocation.getter(#sessionEvents),
              returnValue: _FakeWalletConnectSessionEvents_0(
                  this, Invocation.getter(#sessionEvents)))
          as _i2.WalletConnectSessionEvents);
  @override
  _i3.WalletConnectSessionDelegateEvents get delegateEvents =>
      (super.noSuchMethod(Invocation.getter(#delegateEvents),
              returnValue: _FakeWalletConnectSessionDelegateEvents_1(
                  this, Invocation.getter(#delegateEvents)))
          as _i3.WalletConnectSessionDelegateEvents);
  @override
  _i5.Future<bool> disconnectSession() =>
      (super.noSuchMethod(Invocation.method(#disconnectSession, []),
          returnValue: _i5.Future<bool>.value(false)) as _i5.Future<bool>);
  @override
  _i5.Future<bool> approveSession(
          {_i8.SessionAction? details, bool? allowed}) =>
      (super.noSuchMethod(
          Invocation.method(
              #approveSession, [], {#details: details, #allowed: allowed}),
          returnValue: _i5.Future<bool>.value(false)) as _i5.Future<bool>);
  @override
  _i5.Future<bool> connectSession(String? accountId, String? addressData) =>
      (super.noSuchMethod(
          Invocation.method(#connectSession, [accountId, addressData]),
          returnValue: _i5.Future<bool>.value(false)) as _i5.Future<bool>);
  @override
  _i5.Future<bool> sendMessageFinish({String? requestId, bool? allowed}) =>
      (super.noSuchMethod(
          Invocation.method(#sendMessageFinish, [],
              {#requestId: requestId, #allowed: allowed}),
          returnValue: _i5.Future<bool>.value(false)) as _i5.Future<bool>);
  @override
  void addListener(_i9.VoidCallback? listener) =>
      super.noSuchMethod(Invocation.method(#addListener, [listener]),
          returnValueForMissingStub: null);
  @override
  void removeListener(_i9.VoidCallback? listener) =>
      super.noSuchMethod(Invocation.method(#removeListener, [listener]),
          returnValueForMissingStub: null);
}
