// Mocks generated by Mockito 5.1.0 from annotations
// in provenance_wallet/test/screens/send_flow/send_amount/send_amount_bloc_test.dart.
// Do not manually edit this file.

import 'dart:async' as _i7;

import 'package:mockito/mockito.dart' as _i1;
import 'package:provenance_dart/proto.dart' as _i4;
import 'package:provenance_dart/wallet.dart' as _i10;
import 'package:provenance_wallet/screens/send_flow/model/send_asset.dart'
    as _i8;
import 'package:provenance_wallet/screens/send_flow/send_amount/send_amount_bloc.dart'
    as _i6;
import 'package:provenance_wallet/services/account_service/account_service.dart'
    as _i2;
import 'package:provenance_wallet/services/account_service/account_storage_service.dart'
    as _i11;
import 'package:provenance_wallet/services/account_service/model/account_gas_estimate.dart'
    as _i3;
import 'package:provenance_wallet/services/account_service/transaction_handler.dart'
    as _i12;
import 'package:provenance_wallet/services/http_client.dart' as _i5;
import 'package:provenance_wallet/services/models/account.dart' as _i9;
import 'package:provenance_wallet/services/models/price.dart' as _i14;
import 'package:provenance_wallet/services/price_service/price_service.dart'
    as _i13;

// ignore_for_file: type=lint
// ignore_for_file: avoid_redundant_argument_values
// ignore_for_file: avoid_setters_without_getters
// ignore_for_file: comment_references
// ignore_for_file: implementation_imports
// ignore_for_file: invalid_use_of_visible_for_testing_member
// ignore_for_file: prefer_const_constructors
// ignore_for_file: unnecessary_parenthesis
// ignore_for_file: camel_case_types

class _FakeAccountServiceEvents_0 extends _i1.Fake
    implements _i2.AccountServiceEvents {}

class _FakeAccountGasEstimate_1 extends _i1.Fake
    implements _i3.AccountGasEstimate {}

class _FakeRawTxResponsePair_2 extends _i1.Fake
    implements _i4.RawTxResponsePair {}

class _FakeHttpClient_3 extends _i1.Fake implements _i5.HttpClient {}

/// A class which mocks [SendAmountBlocNavigator].
///
/// See the documentation for Mockito's code generation for more information.
class MockSendAmountBlocNavigator extends _i1.Mock
    implements _i6.SendAmountBlocNavigator {
  MockSendAmountBlocNavigator() {
    _i1.throwOnMissingStub(this);
  }

  @override
  _i7.Future<void> showReviewSend(
          _i8.SendAsset? amountToSend, _i8.MultiSendAsset? fee, String? note) =>
      (super.noSuchMethod(
          Invocation.method(#showReviewSend, [amountToSend, fee, note]),
          returnValue: Future<void>.value(),
          returnValueForMissingStub: Future<void>.value()) as _i7.Future<void>);
}

/// A class which mocks [AccountService].
///
/// See the documentation for Mockito's code generation for more information.
class MockAccountService extends _i1.Mock implements _i2.AccountService {
  MockAccountService() {
    _i1.throwOnMissingStub(this);
  }

  @override
  _i2.AccountServiceEvents get events => (super.noSuchMethod(
      Invocation.getter(#events),
      returnValue: _FakeAccountServiceEvents_0()) as _i2.AccountServiceEvents);
  @override
  _i7.Future<_i9.Account?> getAccount(String? id) => (super.noSuchMethod(
      Invocation.method(#getAccount, [id]),
      returnValue: Future<_i9.Account?>.value()) as _i7.Future<_i9.Account?>);
  @override
  _i7.Future<_i9.TransactableAccount?> selectFirstAccount() =>
      (super.noSuchMethod(Invocation.method(#selectFirstAccount, []),
              returnValue: Future<_i9.TransactableAccount?>.value())
          as _i7.Future<_i9.TransactableAccount?>);
  @override
  _i7.Future<_i9.TransactableAccount?> selectAccount({String? id}) =>
      (super.noSuchMethod(Invocation.method(#selectAccount, [], {#id: id}),
              returnValue: Future<_i9.TransactableAccount?>.value())
          as _i7.Future<_i9.TransactableAccount?>);
  @override
  _i7.Future<_i9.TransactableAccount?> getSelectedAccount() =>
      (super.noSuchMethod(Invocation.method(#getSelectedAccount, []),
              returnValue: Future<_i9.TransactableAccount?>.value())
          as _i7.Future<_i9.TransactableAccount?>);
  @override
  _i7.Future<List<_i9.Account>> getAccounts() =>
      (super.noSuchMethod(Invocation.method(#getAccounts, []),
              returnValue: Future<List<_i9.Account>>.value(<_i9.Account>[]))
          as _i7.Future<List<_i9.Account>>);
  @override
  _i7.Future<List<_i9.BasicAccount>> getBasicAccounts() =>
      (super.noSuchMethod(Invocation.method(#getBasicAccounts, []),
              returnValue:
                  Future<List<_i9.BasicAccount>>.value(<_i9.BasicAccount>[]))
          as _i7.Future<List<_i9.BasicAccount>>);
  @override
  _i7.Future<_i9.TransactableAccount?> renameAccount(
          {String? id, String? name}) =>
      (super.noSuchMethod(
              Invocation.method(#renameAccount, [], {#id: id, #name: name}),
              returnValue: Future<_i9.TransactableAccount?>.value())
          as _i7.Future<_i9.TransactableAccount?>);
  @override
  _i7.Future<_i9.TransactableAccount?> setAccountCoin(
          {String? id, _i10.Coin? coin}) =>
      (super.noSuchMethod(
              Invocation.method(#setAccountCoin, [], {#id: id, #coin: coin}),
              returnValue: Future<_i9.TransactableAccount?>.value())
          as _i7.Future<_i9.TransactableAccount?>);
  @override
  _i7.Future<_i9.TransactableAccount?> addAccount(
          {List<String>? phrase, String? name, _i10.Coin? coin}) =>
      (super.noSuchMethod(
              Invocation.method(
                  #addAccount, [], {#phrase: phrase, #name: name, #coin: coin}),
              returnValue: Future<_i9.TransactableAccount?>.value())
          as _i7.Future<_i9.TransactableAccount?>);
  @override
  _i7.Future<_i9.MultiAccount?> addMultiAccount(
          {String? name,
          List<_i11.PublicKeyData>? publicKeys,
          _i10.Coin? coin}) =>
      (super.noSuchMethod(
              Invocation.method(#addMultiAccount, [],
                  {#name: name, #publicKeys: publicKeys, #coin: coin}),
              returnValue: Future<_i9.MultiAccount?>.value())
          as _i7.Future<_i9.MultiAccount?>);
  @override
  _i7.Future<_i9.PendingMultiAccount?> addPendingMultiAccount(
          {String? name,
          String? remoteId,
          String? linkedAccountId,
          int? cosignerCount,
          int? signaturesRequired}) =>
      (super.noSuchMethod(
              Invocation.method(#addPendingMultiAccount, [], {
                #name: name,
                #remoteId: remoteId,
                #linkedAccountId: linkedAccountId,
                #cosignerCount: cosignerCount,
                #signaturesRequired: signaturesRequired
              }),
              returnValue: Future<_i9.PendingMultiAccount?>.value())
          as _i7.Future<_i9.PendingMultiAccount?>);
  @override
  _i7.Future<_i9.Account?> removeAccount({String? id}) => (super.noSuchMethod(
      Invocation.method(#removeAccount, [], {#id: id}),
      returnValue: Future<_i9.Account?>.value()) as _i7.Future<_i9.Account?>);
  @override
  _i7.Future<List<_i9.Account>> resetAccounts() =>
      (super.noSuchMethod(Invocation.method(#resetAccounts, []),
              returnValue: Future<List<_i9.Account>>.value(<_i9.Account>[]))
          as _i7.Future<List<_i9.Account>>);
  @override
  _i7.Future<_i10.PrivateKey?> loadKey(String? accountId) =>
      (super.noSuchMethod(Invocation.method(#loadKey, [accountId]),
              returnValue: Future<_i10.PrivateKey?>.value())
          as _i7.Future<_i10.PrivateKey?>);
  @override
  _i7.Future<bool> isValidWalletConnectData(String? qrData) => (super
      .noSuchMethod(Invocation.method(#isValidWalletConnectData, [qrData]),
          returnValue: Future<bool>.value(false)) as _i7.Future<bool>);
}

/// A class which mocks [TransactionHandler].
///
/// See the documentation for Mockito's code generation for more information.
class MockTransactionHandler extends _i1.Mock
    implements _i12.TransactionHandler {
  MockTransactionHandler() {
    _i1.throwOnMissingStub(this);
  }

  @override
  _i7.Stream<_i12.TransactionResponse> get transaction =>
      (super.noSuchMethod(Invocation.getter(#transaction),
              returnValue: Stream<_i12.TransactionResponse>.empty())
          as _i7.Stream<_i12.TransactionResponse>);
  @override
  _i7.Future<_i3.AccountGasEstimate> estimateGas(
          _i4.TxBody? txBody, _i10.PublicKey? publicKey) =>
      (super.noSuchMethod(Invocation.method(#estimateGas, [txBody, publicKey]),
              returnValue: Future<_i3.AccountGasEstimate>.value(
                  _FakeAccountGasEstimate_1()))
          as _i7.Future<_i3.AccountGasEstimate>);
  @override
  _i7.Future<_i4.RawTxResponsePair> executeTransaction(
          _i4.TxBody? txBody, _i10.PrivateKey? privateKey,
          [_i3.AccountGasEstimate? gasEstimate]) =>
      (super.noSuchMethod(
              Invocation.method(
                  #executeTransaction, [txBody, privateKey, gasEstimate]),
              returnValue: Future<_i4.RawTxResponsePair>.value(
                  _FakeRawTxResponsePair_2()))
          as _i7.Future<_i4.RawTxResponsePair>);
}

/// A class which mocks [PriceService].
///
/// See the documentation for Mockito's code generation for more information.
class MockPriceService extends _i1.Mock implements _i13.PriceService {
  MockPriceService() {
    _i1.throwOnMissingStub(this);
  }

  @override
  _i7.Future<List<_i14.Price>> getAssetPrices(
          _i10.Coin? coin, List<String>? denominations) =>
      (super.noSuchMethod(
              Invocation.method(#getAssetPrices, [coin, denominations]),
              returnValue: Future<List<_i14.Price>>.value(<_i14.Price>[]))
          as _i7.Future<List<_i14.Price>>);
  @override
  _i7.Future<_i5.HttpClient> getClient(_i10.Coin? coin) =>
      (super.noSuchMethod(Invocation.method(#getClient, [coin]),
              returnValue: Future<_i5.HttpClient>.value(_FakeHttpClient_3()))
          as _i7.Future<_i5.HttpClient>);
}
