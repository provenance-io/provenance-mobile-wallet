// Mocks generated by Mockito 5.1.0 from annotations
// in provenance_wallet/test/services/wallet_connect_service/default_wallet_connect_service_test.dart.
// Do not manually edit this file.

import 'dart:async' as _i8;
import 'dart:ui' as _i16;

import 'package:mockito/mockito.dart' as _i1;
import 'package:provenance_dart/proto.dart' as _i5;
import 'package:provenance_dart/wallet.dart' as _i10;
import 'package:provenance_dart/wallet_connect.dart' as _i6;
import 'package:provenance_wallet/services/account_service/account_service.dart'
    as _i3;
import 'package:provenance_wallet/services/account_service/model/account_gas_estimate.dart'
    as _i4;
import 'package:provenance_wallet/services/account_service/transaction_handler.dart'
    as _i17;
import 'package:provenance_wallet/services/key_value_service/key_value_service.dart'
    as _i7;
import 'package:provenance_wallet/services/models/account.dart' as _i9;
import 'package:provenance_wallet/services/models/requests/send_request.dart'
    as _i14;
import 'package:provenance_wallet/services/models/requests/sign_request.dart'
    as _i13;
import 'package:provenance_wallet/services/models/wallet_connect_session_request_data.dart'
    as _i15;
import 'package:provenance_wallet/services/remote_notification/remote_notification_service.dart'
    as _i11;
import 'package:provenance_wallet/services/wallet_connect_queue_service/wallet_connect_queue_service.dart'
    as _i12;
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

class _FakeValueStream_0<T> extends _i1.Fake implements _i2.ValueStream<T> {}

class _FakeAccountServiceEvents_1 extends _i1.Fake
    implements _i3.AccountServiceEvents {}

class _FakeAccountGasEstimate_2 extends _i1.Fake
    implements _i4.AccountGasEstimate {}

class _FakeRawTxResponsePair_3 extends _i1.Fake
    implements _i5.RawTxResponsePair {}

class _FakeWalletConnectAddress_4 extends _i1.Fake
    implements _i6.WalletConnectAddress {}

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
          returnValue: Future<bool>.value(false)) as _i8.Future<bool>);
  @override
  _i2.ValueStream<_i7.KeyValueData<T>> stream<T>(_i7.PrefKey? key) =>
      (super.noSuchMethod(Invocation.method(#stream, [key]),
              returnValue: _FakeValueStream_0<_i7.KeyValueData<T>>())
          as _i2.ValueStream<_i7.KeyValueData<T>>);
  @override
  _i8.Future<bool?> getBool(_i7.PrefKey? key) =>
      (super.noSuchMethod(Invocation.method(#getBool, [key]),
          returnValue: Future<bool?>.value()) as _i8.Future<bool?>);
  @override
  _i8.Future<bool> setBool(_i7.PrefKey? key, bool? value) =>
      (super.noSuchMethod(Invocation.method(#setBool, [key, value]),
          returnValue: Future<bool>.value(false)) as _i8.Future<bool>);
  @override
  _i8.Future<bool> removeBool(_i7.PrefKey? key) =>
      (super.noSuchMethod(Invocation.method(#removeBool, [key]),
          returnValue: Future<bool>.value(false)) as _i8.Future<bool>);
  @override
  _i8.Future<String?> getString(_i7.PrefKey? key) =>
      (super.noSuchMethod(Invocation.method(#getString, [key]),
          returnValue: Future<String?>.value()) as _i8.Future<String?>);
  @override
  _i8.Future<bool> setString(_i7.PrefKey? key, String? value) =>
      (super.noSuchMethod(Invocation.method(#setString, [key, value]),
          returnValue: Future<bool>.value(false)) as _i8.Future<bool>);
  @override
  _i8.Future<bool> removeString(_i7.PrefKey? key) =>
      (super.noSuchMethod(Invocation.method(#removeString, [key]),
          returnValue: Future<bool>.value(false)) as _i8.Future<bool>);
}

/// A class which mocks [AccountService].
///
/// See the documentation for Mockito's code generation for more information.
class MockAccountService extends _i1.Mock implements _i3.AccountService {
  MockAccountService() {
    _i1.throwOnMissingStub(this);
  }

  @override
  _i3.AccountServiceEvents get events => (super.noSuchMethod(
      Invocation.getter(#events),
      returnValue: _FakeAccountServiceEvents_1()) as _i3.AccountServiceEvents);
  @override
  _i8.Future<_i9.Account?> getAccount(String? id) => (super.noSuchMethod(
      Invocation.method(#getAccount, [id]),
      returnValue: Future<_i9.Account?>.value()) as _i8.Future<_i9.Account?>);
  @override
  _i8.Future<_i9.Account?> selectFirstAccount() => (super.noSuchMethod(
      Invocation.method(#selectFirstAccount, []),
      returnValue: Future<_i9.Account?>.value()) as _i8.Future<_i9.Account?>);
  @override
  _i8.Future<_i9.Account?> selectAccount({String? id}) => (super.noSuchMethod(
      Invocation.method(#selectAccount, [], {#id: id}),
      returnValue: Future<_i9.Account?>.value()) as _i8.Future<_i9.Account?>);
  @override
  _i8.Future<_i9.Account?> getSelectedAccount() => (super.noSuchMethod(
      Invocation.method(#getSelectedAccount, []),
      returnValue: Future<_i9.Account?>.value()) as _i8.Future<_i9.Account?>);
  @override
  _i8.Future<List<_i9.Account>> getAccounts() =>
      (super.noSuchMethod(Invocation.method(#getAccounts, []),
              returnValue: Future<List<_i9.Account>>.value(<_i9.Account>[]))
          as _i8.Future<List<_i9.Account>>);
  @override
  _i8.Future<List<_i9.BasicAccount>> getBasicAccounts() =>
      (super.noSuchMethod(Invocation.method(#getBasicAccounts, []),
              returnValue:
                  Future<List<_i9.BasicAccount>>.value(<_i9.BasicAccount>[]))
          as _i8.Future<List<_i9.BasicAccount>>);
  @override
  _i8.Future<_i9.Account?> renameAccount({String? id, String? name}) =>
      (super.noSuchMethod(
              Invocation.method(#renameAccount, [], {#id: id, #name: name}),
              returnValue: Future<_i9.Account?>.value())
          as _i8.Future<_i9.Account?>);
  @override
  _i8.Future<_i9.Account?> setAccountCoin({String? id, _i10.Coin? coin}) =>
      (super.noSuchMethod(
              Invocation.method(#setAccountCoin, [], {#id: id, #coin: coin}),
              returnValue: Future<_i9.Account?>.value())
          as _i8.Future<_i9.Account?>);
  @override
  _i8.Future<_i9.Account?> addAccount(
          {List<String>? phrase, String? name, _i10.Coin? coin}) =>
      (super.noSuchMethod(
              Invocation.method(
                  #addAccount, [], {#phrase: phrase, #name: name, #coin: coin}),
              returnValue: Future<_i9.Account?>.value())
          as _i8.Future<_i9.Account?>);
  @override
  _i8.Future<_i9.MultiAccount?> addMultiAccount(
          {String? name,
          List<_i10.PublicKey>? publicKeys,
          _i10.Coin? coin,
          String? linkedAccountId,
          String? remoteId,
          int? cosignerCount,
          int? signaturesRequired,
          List<String>? inviteLinks}) =>
      (super.noSuchMethod(
              Invocation.method(#addMultiAccount, [], {
                #name: name,
                #publicKeys: publicKeys,
                #coin: coin,
                #linkedAccountId: linkedAccountId,
                #remoteId: remoteId,
                #cosignerCount: cosignerCount,
                #signaturesRequired: signaturesRequired,
                #inviteLinks: inviteLinks
              }),
              returnValue: Future<_i9.MultiAccount?>.value())
          as _i8.Future<_i9.MultiAccount?>);
  @override
  _i8.Future<_i9.Account?> removeAccount({String? id}) => (super.noSuchMethod(
      Invocation.method(#removeAccount, [], {#id: id}),
      returnValue: Future<_i9.Account?>.value()) as _i8.Future<_i9.Account?>);
  @override
  _i8.Future<List<_i9.Account>> resetAccounts() =>
      (super.noSuchMethod(Invocation.method(#resetAccounts, []),
              returnValue: Future<List<_i9.Account>>.value(<_i9.Account>[]))
          as _i8.Future<List<_i9.Account>>);
  @override
  _i8.Future<_i10.PrivateKey?> loadKey(String? accountId) =>
      (super.noSuchMethod(Invocation.method(#loadKey, [accountId]),
              returnValue: Future<_i10.PrivateKey?>.value())
          as _i8.Future<_i10.PrivateKey?>);
  @override
  _i8.Future<bool> isValidWalletConnectData(String? qrData) => (super
      .noSuchMethod(Invocation.method(#isValidWalletConnectData, [qrData]),
          returnValue: Future<bool>.value(false)) as _i8.Future<bool>);
}

/// A class which mocks [RemoteNotificationService].
///
/// See the documentation for Mockito's code generation for more information.
class MockRemoteNotificationService extends _i1.Mock
    implements _i11.RemoteNotificationService {
  MockRemoteNotificationService() {
    _i1.throwOnMissingStub(this);
  }

  @override
  _i8.Future<void> registerForPushNotifications(String? topic) => (super
      .noSuchMethod(Invocation.method(#registerForPushNotifications, [topic]),
          returnValue: Future<void>.value(),
          returnValueForMissingStub: Future<void>.value()) as _i8.Future<void>);
  @override
  _i8.Future<void> unregisterForPushNotifications(String? topic) => (super
      .noSuchMethod(Invocation.method(#unregisterForPushNotifications, [topic]),
          returnValue: Future<void>.value(),
          returnValueForMissingStub: Future<void>.value()) as _i8.Future<void>);
}

/// A class which mocks [WalletConnectQueueService].
///
/// See the documentation for Mockito's code generation for more information.
class MockWalletConnectQueueService extends _i1.Mock
    implements _i12.WalletConnectQueueService {
  MockWalletConnectQueueService() {
    _i1.throwOnMissingStub(this);
  }

  @override
  _i8.Future<void> createWalletConnectSessionGroup(
          _i6.WalletConnectAddress? address,
          String? walletAddress,
          _i6.ClientMeta? clientMeta) =>
      (super.noSuchMethod(
          Invocation.method(#createWalletConnectSessionGroup,
              [address, walletAddress, clientMeta]),
          returnValue: Future<void>.value(),
          returnValueForMissingStub: Future<void>.value()) as _i8.Future<void>);
  @override
  _i8.Future<void> removeWalletConnectSessionGroup(
          _i6.WalletConnectAddress? address) =>
      (super.noSuchMethod(
          Invocation.method(#removeWalletConnectSessionGroup, [address]),
          returnValue: Future<void>.value(),
          returnValueForMissingStub: Future<void>.value()) as _i8.Future<void>);
  @override
  _i8.Future<void> updateConnectionDetails(
          _i6.WalletConnectAddress? address, _i6.ClientMeta? clientMeta) =>
      (super.noSuchMethod(
          Invocation.method(#updateConnectionDetails, [address, clientMeta]),
          returnValue: Future<void>.value(),
          returnValueForMissingStub: Future<void>.value()) as _i8.Future<void>);
  @override
  _i8.Future<void> addWalletConnectSignRequest(
          _i6.WalletConnectAddress? address, _i13.SignRequest? signRequest) =>
      (super.noSuchMethod(
          Invocation.method(
              #addWalletConnectSignRequest, [address, signRequest]),
          returnValue: Future<void>.value(),
          returnValueForMissingStub: Future<void>.value()) as _i8.Future<void>);
  @override
  _i8.Future<void> addWalletConnectSendRequest(
          _i6.WalletConnectAddress? address, _i14.SendRequest? sendRequest) =>
      (super.noSuchMethod(
          Invocation.method(
              #addWalletConnectSendRequest, [address, sendRequest]),
          returnValue: Future<void>.value(),
          returnValueForMissingStub: Future<void>.value()) as _i8.Future<void>);
  @override
  _i8.Future<void> addWalletApproveRequest(_i6.WalletConnectAddress? address,
          _i15.WalletConnectSessionRequestData? apporveRequestData) =>
      (super.noSuchMethod(
          Invocation.method(
              #addWalletApproveRequest, [address, apporveRequestData]),
          returnValue: Future<void>.value(),
          returnValueForMissingStub: Future<void>.value()) as _i8.Future<void>);
  @override
  _i8.Future<_i12.WalletConnectQueueGroup?> loadGroup(
          _i6.WalletConnectAddress? address) =>
      (super.noSuchMethod(Invocation.method(#loadGroup, [address]),
              returnValue: Future<_i12.WalletConnectQueueGroup?>.value())
          as _i8.Future<_i12.WalletConnectQueueGroup?>);
  @override
  _i8.Future<dynamic> loadQueuedAction(
          _i6.WalletConnectAddress? address, String? requestId) =>
      (super.noSuchMethod(
          Invocation.method(#loadQueuedAction, [address, requestId]),
          returnValue: Future<dynamic>.value()) as _i8.Future<dynamic>);
  @override
  _i8.Future<void> removeRequest(
          _i6.WalletConnectAddress? address, String? requestId) =>
      (super.noSuchMethod(
          Invocation.method(#removeRequest, [address, requestId]),
          returnValue: Future<void>.value(),
          returnValueForMissingStub: Future<void>.value()) as _i8.Future<void>);
  @override
  _i8.Future<List<_i12.WalletConnectQueueGroup>> loadAllGroups() =>
      (super.noSuchMethod(Invocation.method(#loadAllGroups, []),
              returnValue: Future<List<_i12.WalletConnectQueueGroup>>.value(
                  <_i12.WalletConnectQueueGroup>[]))
          as _i8.Future<List<_i12.WalletConnectQueueGroup>>);
  @override
  void addListener(_i16.VoidCallback? listener) =>
      super.noSuchMethod(Invocation.method(#addListener, [listener]),
          returnValueForMissingStub: null);
  @override
  void removeListener(_i16.VoidCallback? listener) =>
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
    implements _i17.TransactionHandler {
  MockTransactionHandler() {
    _i1.throwOnMissingStub(this);
  }

  @override
  _i8.Stream<_i17.TransactionResponse> get transaction =>
      (super.noSuchMethod(Invocation.getter(#transaction),
              returnValue: Stream<_i17.TransactionResponse>.empty())
          as _i8.Stream<_i17.TransactionResponse>);
  @override
  _i8.Future<_i4.AccountGasEstimate> estimateGas(
          _i5.TxBody? txBody, _i10.PublicKey? publicKey) =>
      (super.noSuchMethod(Invocation.method(#estimateGas, [txBody, publicKey]),
              returnValue: Future<_i4.AccountGasEstimate>.value(
                  _FakeAccountGasEstimate_2()))
          as _i8.Future<_i4.AccountGasEstimate>);
  @override
  _i8.Future<_i5.RawTxResponsePair> executeTransaction(
          _i5.TxBody? txBody, _i10.PrivateKey? privateKey,
          [_i4.AccountGasEstimate? gasEstimate]) =>
      (super.noSuchMethod(
              Invocation.method(
                  #executeTransaction, [txBody, privateKey, gasEstimate]),
              returnValue: Future<_i5.RawTxResponsePair>.value(
                  _FakeRawTxResponsePair_3()))
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
      returnValue: _FakeWalletConnectAddress_4()) as _i6.WalletConnectAddress);
  @override
  _i6.WalletConnectState get value => (super.noSuchMethod(
          Invocation.getter(#value),
          returnValue: _i6.WalletConnectState.connecting)
      as _i6.WalletConnectState);
  @override
  _i8.Future<void> connect(_i6.WalletConnectionDelegate? delegate,
          [_i6.SessionRestoreData? restoreData]) =>
      (super.noSuchMethod(Invocation.method(#connect, [delegate, restoreData]),
          returnValue: Future<void>.value(),
          returnValueForMissingStub: Future<void>.value()) as _i8.Future<void>);
  @override
  _i8.Future<void> dispose() =>
      (super.noSuchMethod(Invocation.method(#dispose, []),
          returnValue: Future<void>.value(),
          returnValueForMissingStub: Future<void>.value()) as _i8.Future<void>);
  @override
  _i8.Future<void> disconnect() =>
      (super.noSuchMethod(Invocation.method(#disconnect, []),
          returnValue: Future<void>.value(),
          returnValueForMissingStub: Future<void>.value()) as _i8.Future<void>);
  @override
  void addListener(_i16.VoidCallback? listener) =>
      super.noSuchMethod(Invocation.method(#addListener, [listener]),
          returnValueForMissingStub: null);
  @override
  void removeListener(_i16.VoidCallback? listener) =>
      super.noSuchMethod(Invocation.method(#removeListener, [listener]),
          returnValueForMissingStub: null);
}
