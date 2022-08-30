// Mocks generated by Mockito 5.3.0 from annotations
// in provenance_wallet/test/services/wallet_connect_service/default_wallet_connect_service_test.dart.
// Do not manually edit this file.

// ignore_for_file: no_leading_underscores_for_library_prefixes
import 'dart:async' as _i8;
import 'dart:ui' as _i17;

import 'package:mockito/mockito.dart' as _i1;
import 'package:provenance_dart/proto.dart' as _i5;
import 'package:provenance_dart/wallet.dart' as _i10;
import 'package:provenance_dart/wallet_connect.dart' as _i6;
import 'package:provenance_wallet/common/pw_design.dart' as _i20;
import 'package:provenance_wallet/services/account_service/account_service.dart'
    as _i3;
import 'package:provenance_wallet/services/account_service/model/account_gas_estimate.dart'
    as _i4;
import 'package:provenance_wallet/services/account_service/transaction_handler.dart'
    as _i18;
import 'package:provenance_wallet/services/key_value_service/key_value_service.dart'
    as _i7;
import 'package:provenance_wallet/services/models/account.dart' as _i9;
import 'package:provenance_wallet/services/models/requests/send_request.dart'
    as _i15;
import 'package:provenance_wallet/services/models/requests/sign_request.dart'
    as _i14;
import 'package:provenance_wallet/services/models/wallet_connect_session_request_data.dart'
    as _i16;
import 'package:provenance_wallet/services/multi_sig_service/models/multi_sig_signer.dart'
    as _i11;
import 'package:provenance_wallet/services/remote_notification/remote_notification_service.dart'
    as _i12;
import 'package:provenance_wallet/services/wallet_connect_queue_service/wallet_connect_queue_service.dart'
    as _i13;
import 'package:provenance_wallet/util/local_auth_helper.dart' as _i19;
import 'package:rxdart/streams.dart' as _i2;

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

class _FakeValueStream_0<T> extends _i1.SmartFake
    implements _i2.ValueStream<T> {
  _FakeValueStream_0(Object parent, Invocation parentInvocation)
      : super(parent, parentInvocation);
}

class _FakeAccountServiceEvents_1 extends _i1.SmartFake
    implements _i3.AccountServiceEvents {
  _FakeAccountServiceEvents_1(Object parent, Invocation parentInvocation)
      : super(parent, parentInvocation);
}

class _FakeAccountGasEstimate_2 extends _i1.SmartFake
    implements _i4.AccountGasEstimate {
  _FakeAccountGasEstimate_2(Object parent, Invocation parentInvocation)
      : super(parent, parentInvocation);
}

class _FakeRawTxResponsePair_3 extends _i1.SmartFake
    implements _i5.RawTxResponsePair {
  _FakeRawTxResponsePair_3(Object parent, Invocation parentInvocation)
      : super(parent, parentInvocation);
}

class _FakeWalletConnectAddress_4 extends _i1.SmartFake
    implements _i6.WalletConnectAddress {
  _FakeWalletConnectAddress_4(Object parent, Invocation parentInvocation)
      : super(parent, parentInvocation);
}

/// A class which mocks [KeyValueService].
///
/// See the documentation for Mockito's code generation for more information.
class MockKeyValueService extends _i1.Mock implements _i7.KeyValueService {
  MockKeyValueService() {
    _i1.throwOnMissingStub(this);
  }

  @override
  _i8.Future<bool> containsKey(_i7.PrefKey? key) =>
      (super.noSuchMethod(Invocation.method(#containsKey, [key]),
          returnValue: _i8.Future<bool>.value(false)) as _i8.Future<bool>);
  @override
  _i2.ValueStream<_i7.KeyValueData<T>> stream<T>(_i7.PrefKey? key) =>
      (super.noSuchMethod(Invocation.method(#stream, [key]),
              returnValue: _FakeValueStream_0<_i7.KeyValueData<T>>(
                  this, Invocation.method(#stream, [key])))
          as _i2.ValueStream<_i7.KeyValueData<T>>);
  @override
  _i8.Future<bool?> getBool(_i7.PrefKey? key) =>
      (super.noSuchMethod(Invocation.method(#getBool, [key]),
          returnValue: _i8.Future<bool?>.value()) as _i8.Future<bool?>);
  @override
  _i8.Future<bool> setBool(_i7.PrefKey? key, bool? value) =>
      (super.noSuchMethod(Invocation.method(#setBool, [key, value]),
          returnValue: _i8.Future<bool>.value(false)) as _i8.Future<bool>);
  @override
  _i8.Future<bool> removeBool(_i7.PrefKey? key) =>
      (super.noSuchMethod(Invocation.method(#removeBool, [key]),
          returnValue: _i8.Future<bool>.value(false)) as _i8.Future<bool>);
  @override
  _i8.Future<String?> getString(_i7.PrefKey? key) =>
      (super.noSuchMethod(Invocation.method(#getString, [key]),
          returnValue: _i8.Future<String?>.value()) as _i8.Future<String?>);
  @override
  _i8.Future<bool> setString(_i7.PrefKey? key, String? value) =>
      (super.noSuchMethod(Invocation.method(#setString, [key, value]),
          returnValue: _i8.Future<bool>.value(false)) as _i8.Future<bool>);
  @override
  _i8.Future<bool> removeString(_i7.PrefKey? key) =>
      (super.noSuchMethod(Invocation.method(#removeString, [key]),
          returnValue: _i8.Future<bool>.value(false)) as _i8.Future<bool>);
}

/// A class which mocks [AccountService].
///
/// See the documentation for Mockito's code generation for more information.
class MockAccountService extends _i1.Mock implements _i3.AccountService {
  MockAccountService() {
    _i1.throwOnMissingStub(this);
  }

  @override
  _i3.AccountServiceEvents get events =>
      (super.noSuchMethod(Invocation.getter(#events),
              returnValue:
                  _FakeAccountServiceEvents_1(this, Invocation.getter(#events)))
          as _i3.AccountServiceEvents);
  @override
  _i8.Future<_i9.Account?> getAccount(String? id) =>
      (super.noSuchMethod(Invocation.method(#getAccount, [id]),
              returnValue: _i8.Future<_i9.Account?>.value())
          as _i8.Future<_i9.Account?>);
  @override
  _i8.Future<_i9.Account?> selectFirstAccount() =>
      (super.noSuchMethod(Invocation.method(#selectFirstAccount, []),
              returnValue: _i8.Future<_i9.Account?>.value())
          as _i8.Future<_i9.Account?>);
  @override
  _i8.Future<_i9.TransactableAccount?> selectAccount({String? id}) =>
      (super.noSuchMethod(Invocation.method(#selectAccount, [], {#id: id}),
              returnValue: _i8.Future<_i9.TransactableAccount?>.value())
          as _i8.Future<_i9.TransactableAccount?>);
  @override
  _i8.Future<_i9.TransactableAccount?> getSelectedAccount() =>
      (super.noSuchMethod(Invocation.method(#getSelectedAccount, []),
              returnValue: _i8.Future<_i9.TransactableAccount?>.value())
          as _i8.Future<_i9.TransactableAccount?>);
  @override
  _i8.Future<List<_i9.Account>> getAccounts() =>
      (super.noSuchMethod(Invocation.method(#getAccounts, []),
              returnValue: _i8.Future<List<_i9.Account>>.value(<_i9.Account>[]))
          as _i8.Future<List<_i9.Account>>);
  @override
  _i8.Future<List<_i9.BasicAccount>> getBasicAccounts() => (super.noSuchMethod(
          Invocation.method(#getBasicAccounts, []),
          returnValue:
              _i8.Future<List<_i9.BasicAccount>>.value(<_i9.BasicAccount>[]))
      as _i8.Future<List<_i9.BasicAccount>>);
  @override
  _i8.Future<List<_i9.TransactableAccount>> getTransactableAccounts() =>
      (super.noSuchMethod(Invocation.method(#getTransactableAccounts, []),
              returnValue: _i8.Future<List<_i9.TransactableAccount>>.value(
                  <_i9.TransactableAccount>[]))
          as _i8.Future<List<_i9.TransactableAccount>>);
  @override
  _i8.Future<_i9.Account?> renameAccount({String? id, String? name}) =>
      (super.noSuchMethod(
              Invocation.method(#renameAccount, [], {#id: id, #name: name}),
              returnValue: _i8.Future<_i9.Account?>.value())
          as _i8.Future<_i9.Account?>);
  @override
  _i8.Future<_i9.Account?> setAccountCoin({String? id, _i10.Coin? coin}) =>
      (super.noSuchMethod(
              Invocation.method(#setAccountCoin, [], {#id: id, #coin: coin}),
              returnValue: _i8.Future<_i9.Account?>.value())
          as _i8.Future<_i9.Account?>);
  @override
  _i8.Future<_i9.Account?> addAccount(
          {List<String>? phrase, String? name, _i10.Coin? coin}) =>
      (super.noSuchMethod(
              Invocation.method(
                  #addAccount, [], {#phrase: phrase, #name: name, #coin: coin}),
              returnValue: _i8.Future<_i9.Account?>.value())
          as _i8.Future<_i9.Account?>);
  @override
  _i8.Future<_i9.MultiAccount?> addMultiAccount(
          {String? name,
          _i10.Coin? coin,
          String? linkedAccountId,
          String? remoteId,
          int? cosignerCount,
          int? signaturesRequired,
          List<String>? inviteIds,
          List<_i11.MultiSigSigner>? signers}) =>
      (super.noSuchMethod(
              Invocation.method(#addMultiAccount, [], {
                #name: name,
                #coin: coin,
                #linkedAccountId: linkedAccountId,
                #remoteId: remoteId,
                #cosignerCount: cosignerCount,
                #signaturesRequired: signaturesRequired,
                #inviteIds: inviteIds,
                #signers: signers
              }),
              returnValue: _i8.Future<_i9.MultiAccount?>.value())
          as _i8.Future<_i9.MultiAccount?>);
  @override
  _i8.Future<_i9.MultiTransactableAccount?> activateMultiAccount(
          {String? id, List<_i11.MultiSigSigner>? signers}) =>
      (super.noSuchMethod(
              Invocation.method(
                  #activateMultiAccount, [], {#id: id, #signers: signers}),
              returnValue: _i8.Future<_i9.MultiTransactableAccount?>.value())
          as _i8.Future<_i9.MultiTransactableAccount?>);
  @override
  _i8.Future<_i9.Account?> removeAccount({String? id}) =>
      (super.noSuchMethod(Invocation.method(#removeAccount, [], {#id: id}),
              returnValue: _i8.Future<_i9.Account?>.value())
          as _i8.Future<_i9.Account?>);
  @override
  _i8.Future<List<_i9.Account>> resetAccounts() =>
      (super.noSuchMethod(Invocation.method(#resetAccounts, []),
              returnValue: _i8.Future<List<_i9.Account>>.value(<_i9.Account>[]))
          as _i8.Future<List<_i9.Account>>);
  @override
  _i8.Future<_i10.PrivateKey?> loadKey(String? accountId) =>
      (super.noSuchMethod(Invocation.method(#loadKey, [accountId]),
              returnValue: _i8.Future<_i10.PrivateKey?>.value())
          as _i8.Future<_i10.PrivateKey?>);
  @override
  _i8.Future<bool> isValidWalletConnectData(String? qrData) => (super
      .noSuchMethod(Invocation.method(#isValidWalletConnectData, [qrData]),
          returnValue: _i8.Future<bool>.value(false)) as _i8.Future<bool>);
}

/// A class which mocks [RemoteNotificationService].
///
/// See the documentation for Mockito's code generation for more information.
class MockRemoteNotificationService extends _i1.Mock
    implements _i12.RemoteNotificationService {
  MockRemoteNotificationService() {
    _i1.throwOnMissingStub(this);
  }

  @override
  bool isRegistered(String? topic) =>
      (super.noSuchMethod(Invocation.method(#isRegistered, [topic]),
          returnValue: false) as bool);
  @override
  _i8.Future<void> registerForPushNotifications(String? topic) =>
      (super.noSuchMethod(
              Invocation.method(#registerForPushNotifications, [topic]),
              returnValue: _i8.Future<void>.value(),
              returnValueForMissingStub: _i8.Future<void>.value())
          as _i8.Future<void>);
  @override
  _i8.Future<void> unregisterForPushNotifications(String? topic) =>
      (super.noSuchMethod(
              Invocation.method(#unregisterForPushNotifications, [topic]),
              returnValue: _i8.Future<void>.value(),
              returnValueForMissingStub: _i8.Future<void>.value())
          as _i8.Future<void>);
}

/// A class which mocks [WalletConnectQueueService].
///
/// See the documentation for Mockito's code generation for more information.
class MockWalletConnectQueueService extends _i1.Mock
    implements _i13.WalletConnectQueueService {
  MockWalletConnectQueueService() {
    _i1.throwOnMissingStub(this);
  }

  @override
  _i8.Future<void> close() => (super.noSuchMethod(Invocation.method(#close, []),
      returnValue: _i8.Future<void>.value(),
      returnValueForMissingStub: _i8.Future<void>.value()) as _i8.Future<void>);
  @override
  _i8.Future<void> createWalletConnectSessionGroup(
          _i6.WalletConnectAddress? address,
          String? walletAddress,
          _i6.ClientMeta? clientMeta) =>
      (super.noSuchMethod(
              Invocation.method(#createWalletConnectSessionGroup,
                  [address, walletAddress, clientMeta]),
              returnValue: _i8.Future<void>.value(),
              returnValueForMissingStub: _i8.Future<void>.value())
          as _i8.Future<void>);
  @override
  _i8.Future<void> removeWalletConnectSessionGroup(
          _i6.WalletConnectAddress? address) =>
      (super.noSuchMethod(
              Invocation.method(#removeWalletConnectSessionGroup, [address]),
              returnValue: _i8.Future<void>.value(),
              returnValueForMissingStub: _i8.Future<void>.value())
          as _i8.Future<void>);
  @override
  _i8.Future<void> updateConnectionDetails(
          _i6.WalletConnectAddress? address, _i6.ClientMeta? clientMeta) =>
      (super.noSuchMethod(
          Invocation.method(#updateConnectionDetails, [address, clientMeta]),
          returnValue: _i8.Future<void>.value(),
          returnValueForMissingStub:
              _i8.Future<void>.value()) as _i8.Future<void>);
  @override
  _i8.Future<void> addWalletConnectSignRequest(
          _i6.WalletConnectAddress? address, _i14.SignRequest? signRequest) =>
      (super.noSuchMethod(
              Invocation.method(
                  #addWalletConnectSignRequest, [address, signRequest]),
              returnValue: _i8.Future<void>.value(),
              returnValueForMissingStub: _i8.Future<void>.value())
          as _i8.Future<void>);
  @override
  _i8.Future<void> addWalletConnectSendRequest(
          _i6.WalletConnectAddress? address, _i15.SendRequest? sendRequest) =>
      (super.noSuchMethod(
              Invocation.method(
                  #addWalletConnectSendRequest, [address, sendRequest]),
              returnValue: _i8.Future<void>.value(),
              returnValueForMissingStub: _i8.Future<void>.value())
          as _i8.Future<void>);
  @override
  _i8.Future<void> addWalletApproveRequest(_i6.WalletConnectAddress? address,
          _i16.WalletConnectSessionRequestData? approveRequestData) =>
      (super.noSuchMethod(
              Invocation.method(
                  #addWalletApproveRequest, [address, approveRequestData]),
              returnValue: _i8.Future<void>.value(),
              returnValueForMissingStub: _i8.Future<void>.value())
          as _i8.Future<void>);
  @override
  _i8.Future<_i13.WalletConnectQueueGroup?> loadGroup(
          _i6.WalletConnectAddress? address) =>
      (super.noSuchMethod(Invocation.method(#loadGroup, [address]),
              returnValue: _i8.Future<_i13.WalletConnectQueueGroup?>.value())
          as _i8.Future<_i13.WalletConnectQueueGroup?>);
  @override
  _i8.Future<dynamic> loadQueuedAction(
          _i6.WalletConnectAddress? address, String? requestId) =>
      (super.noSuchMethod(
          Invocation.method(#loadQueuedAction, [address, requestId]),
          returnValue: _i8.Future<dynamic>.value()) as _i8.Future<dynamic>);
  @override
  _i8.Future<void> removeRequest(
          _i6.WalletConnectAddress? address, String? requestId) =>
      (super.noSuchMethod(
              Invocation.method(#removeRequest, [address, requestId]),
              returnValue: _i8.Future<void>.value(),
              returnValueForMissingStub: _i8.Future<void>.value())
          as _i8.Future<void>);
  @override
  _i8.Future<List<_i13.WalletConnectQueueGroup>> loadAllGroups() =>
      (super.noSuchMethod(Invocation.method(#loadAllGroups, []),
              returnValue: _i8.Future<List<_i13.WalletConnectQueueGroup>>.value(
                  <_i13.WalletConnectQueueGroup>[]))
          as _i8.Future<List<_i13.WalletConnectQueueGroup>>);
  @override
  void addListener(_i17.VoidCallback? listener) =>
      super.noSuchMethod(Invocation.method(#addListener, [listener]),
          returnValueForMissingStub: null);
  @override
  void removeListener(_i17.VoidCallback? listener) =>
      super.noSuchMethod(Invocation.method(#removeListener, [listener]),
          returnValueForMissingStub: null);
  @override
  void notifyListeners() =>
      super.noSuchMethod(Invocation.method(#notifyListeners, []),
          returnValueForMissingStub: null);
}

/// A class which mocks [TransactionHandler].
///
/// See the documentation for Mockito's code generation for more information.
class MockTransactionHandler extends _i1.Mock
    implements _i18.TransactionHandler {
  MockTransactionHandler() {
    _i1.throwOnMissingStub(this);
  }

  @override
  _i8.Stream<_i18.TransactionResponse> get transaction =>
      (super.noSuchMethod(Invocation.getter(#transaction),
              returnValue: _i8.Stream<_i18.TransactionResponse>.empty())
          as _i8.Stream<_i18.TransactionResponse>);
  @override
  _i8.Future<_i4.AccountGasEstimate> estimateGas(
          _i5.TxBody? txBody, List<_i10.IPubKey>? signers) =>
      (super.noSuchMethod(Invocation.method(#estimateGas, [txBody, signers]),
              returnValue: _i8.Future<_i4.AccountGasEstimate>.value(
                  _FakeAccountGasEstimate_2(this,
                      Invocation.method(#estimateGas, [txBody, signers]))))
          as _i8.Future<_i4.AccountGasEstimate>);
  @override
  _i8.Future<_i5.RawTxResponsePair> executeTransaction(
          _i5.TxBody? txBody, _i10.IPrivKey? privateKey,
          [_i4.AccountGasEstimate? gasEstimate]) =>
      (super.noSuchMethod(Invocation.method(#executeTransaction, [txBody, privateKey, gasEstimate]),
              returnValue: _i8.Future<_i5.RawTxResponsePair>.value(
                  _FakeRawTxResponsePair_3(
                      this,
                      Invocation.method(
                          #executeTransaction, [txBody, privateKey, gasEstimate]))))
          as _i8.Future<_i5.RawTxResponsePair>);
}

/// A class which mocks [WalletConnection].
///
/// See the documentation for Mockito's code generation for more information.
class MockWalletConnection extends _i1.Mock implements _i6.WalletConnection {
  MockWalletConnection() {
    _i1.throwOnMissingStub(this);
  }

  @override
  _i6.WalletConnectAddress get address => (super.noSuchMethod(
          Invocation.getter(#address),
          returnValue:
              _FakeWalletConnectAddress_4(this, Invocation.getter(#address)))
      as _i6.WalletConnectAddress);
  @override
  _i6.WalletConnectState get value => (super.noSuchMethod(
          Invocation.getter(#value),
          returnValue: _i6.WalletConnectState.connecting)
      as _i6.WalletConnectState);
  @override
  _i8.Future<void> connect(_i6.WalletConnectionDelegate? delegate,
          [_i6.SessionRestoreData? restoreData]) =>
      (super.noSuchMethod(Invocation.method(#connect, [delegate, restoreData]),
              returnValue: _i8.Future<void>.value(),
              returnValueForMissingStub: _i8.Future<void>.value())
          as _i8.Future<void>);
  @override
  _i8.Future<void> dispose() => (super.noSuchMethod(
      Invocation.method(#dispose, []),
      returnValue: _i8.Future<void>.value(),
      returnValueForMissingStub: _i8.Future<void>.value()) as _i8.Future<void>);
  @override
  _i8.Future<void> disconnect() => (super.noSuchMethod(
      Invocation.method(#disconnect, []),
      returnValue: _i8.Future<void>.value(),
      returnValueForMissingStub: _i8.Future<void>.value()) as _i8.Future<void>);
  @override
  _i8.Future<void> sendError(int? requestId, String? error) =>
      (super.noSuchMethod(Invocation.method(#sendError, [requestId, error]),
              returnValue: _i8.Future<void>.value(),
              returnValueForMissingStub: _i8.Future<void>.value())
          as _i8.Future<void>);
  @override
  _i8.Future<void> reject(int? requestId) => (super.noSuchMethod(
      Invocation.method(#reject, [requestId]),
      returnValue: _i8.Future<void>.value(),
      returnValueForMissingStub: _i8.Future<void>.value()) as _i8.Future<void>);
  @override
  _i8.Future<void> sendTransactionResult(
          int? requestId, _i5.RawTxResponsePair? txResponsePair) =>
      (super.noSuchMethod(
              Invocation.method(
                  #sendTransactionResult, [requestId, txResponsePair]),
              returnValue: _i8.Future<void>.value(),
              returnValueForMissingStub: _i8.Future<void>.value())
          as _i8.Future<void>);
  @override
  _i8.Future<void> sendSignResult(int? requestId, List<int>? signedData) =>
      (super.noSuchMethod(
              Invocation.method(#sendSignResult, [requestId, signedData]),
              returnValue: _i8.Future<void>.value(),
              returnValueForMissingStub: _i8.Future<void>.value())
          as _i8.Future<void>);
  @override
  _i8.Future<void> sendApproveSession(
          int? requestId, _i6.SessionApprovalData? clientMeta,
          [_i6.ClientMeta? peerMeta]) =>
      (super.noSuchMethod(
              Invocation.method(
                  #sendApproveSession, [requestId, clientMeta, peerMeta]),
              returnValue: _i8.Future<void>.value(),
              returnValueForMissingStub: _i8.Future<void>.value())
          as _i8.Future<void>);
  @override
  void addListener(_i17.VoidCallback? listener) =>
      super.noSuchMethod(Invocation.method(#addListener, [listener]),
          returnValueForMissingStub: null);
  @override
  void removeListener(_i17.VoidCallback? listener) =>
      super.noSuchMethod(Invocation.method(#removeListener, [listener]),
          returnValueForMissingStub: null);
}

/// A class which mocks [LocalAuthHelper].
///
/// See the documentation for Mockito's code generation for more information.
class MockLocalAuthHelper extends _i1.Mock implements _i19.LocalAuthHelper {
  MockLocalAuthHelper() {
    _i1.throwOnMissingStub(this);
  }

  @override
  _i2.ValueStream<_i19.AuthStatus> get status =>
      (super.noSuchMethod(Invocation.getter(#status),
              returnValue: _FakeValueStream_0<_i19.AuthStatus>(
                  this, Invocation.getter(#status)))
          as _i2.ValueStream<_i19.AuthStatus>);
  @override
  void reset() => super.noSuchMethod(Invocation.method(#reset, []),
      returnValueForMissingStub: null);
  @override
  _i8.Future<bool> enroll(String? code, String? accountName, bool? useBiometry,
          _i20.BuildContext? context) =>
      (super.noSuchMethod(
          Invocation.method(#enroll, [code, accountName, useBiometry, context]),
          returnValue: _i8.Future<bool>.value(false)) as _i8.Future<bool>);
  @override
  _i8.Future<_i19.AuthStatus> auth(_i20.BuildContext? context) =>
      (super.noSuchMethod(Invocation.method(#auth, [context]),
              returnValue:
                  _i8.Future<_i19.AuthStatus>.value(_i19.AuthStatus.noAccount))
          as _i8.Future<_i19.AuthStatus>);
  @override
  void didChangeAppLifecycleState(_i17.AppLifecycleState? state) => super
      .noSuchMethod(Invocation.method(#didChangeAppLifecycleState, [state]),
          returnValueForMissingStub: null);
  @override
  _i8.Future<bool> didPopRoute() =>
      (super.noSuchMethod(Invocation.method(#didPopRoute, []),
          returnValue: _i8.Future<bool>.value(false)) as _i8.Future<bool>);
  @override
  _i8.Future<bool> didPushRoute(String? route) =>
      (super.noSuchMethod(Invocation.method(#didPushRoute, [route]),
          returnValue: _i8.Future<bool>.value(false)) as _i8.Future<bool>);
  @override
  _i8.Future<bool> didPushRouteInformation(
          _i20.RouteInformation? routeInformation) =>
      (super.noSuchMethod(
          Invocation.method(#didPushRouteInformation, [routeInformation]),
          returnValue: _i8.Future<bool>.value(false)) as _i8.Future<bool>);
  @override
  void didChangeMetrics() =>
      super.noSuchMethod(Invocation.method(#didChangeMetrics, []),
          returnValueForMissingStub: null);
  @override
  void didChangeTextScaleFactor() =>
      super.noSuchMethod(Invocation.method(#didChangeTextScaleFactor, []),
          returnValueForMissingStub: null);
  @override
  void didChangePlatformBrightness() =>
      super.noSuchMethod(Invocation.method(#didChangePlatformBrightness, []),
          returnValueForMissingStub: null);
  @override
  void didChangeLocales(List<_i17.Locale>? locales) =>
      super.noSuchMethod(Invocation.method(#didChangeLocales, [locales]),
          returnValueForMissingStub: null);
  @override
  void didHaveMemoryPressure() =>
      super.noSuchMethod(Invocation.method(#didHaveMemoryPressure, []),
          returnValueForMissingStub: null);
  @override
  void didChangeAccessibilityFeatures() =>
      super.noSuchMethod(Invocation.method(#didChangeAccessibilityFeatures, []),
          returnValueForMissingStub: null);
}
