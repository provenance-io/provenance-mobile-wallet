// Mocks generated by Mockito 5.1.0 from annotations
// in provenance_wallet/test/screens/send_flow/send_review/send_review_bloc_test.dart.
// Do not manually edit this file.

import 'dart:async' as _i6;

import 'package:mockito/mockito.dart' as _i1;
import 'package:provenance_dart/proto.dart' as _i4;
import 'package:provenance_dart/wallet.dart' as _i8;
import 'package:provenance_wallet/screens/send_flow/send_review/send_review_bloc.dart'
    as _i5;
import 'package:provenance_wallet/services/models/wallet_details.dart' as _i7;
import 'package:provenance_wallet/services/wallet_service/model/wallet_gas_estimate.dart'
    as _i3;
import 'package:provenance_wallet/services/wallet_service/wallet_connect_transaction_handler.dart'
    as _i9;
import 'package:provenance_wallet/services/wallet_service/wallet_service.dart'
    as _i2;

// ignore_for_file: type=lint
// ignore_for_file: avoid_redundant_argument_values
// ignore_for_file: avoid_setters_without_getters
// ignore_for_file: comment_references
// ignore_for_file: implementation_imports
// ignore_for_file: invalid_use_of_visible_for_testing_member
// ignore_for_file: prefer_const_constructors
// ignore_for_file: unnecessary_parenthesis
// ignore_for_file: camel_case_types

class _FakeWalletServiceEvents_0 extends _i1.Fake
    implements _i2.WalletServiceEvents {}

class _FakeWalletGasEstimate_1 extends _i1.Fake
    implements _i3.WalletGasEstimate {}

class _FakeRawTxResponsePair_2 extends _i1.Fake
    implements _i4.RawTxResponsePair {}

/// A class which mocks [SendReviewNaviagor].
///
/// See the documentation for Mockito's code generation for more information.
class MockSendReviewNaviagor extends _i1.Mock
    implements _i5.SendReviewNaviagor {
  MockSendReviewNaviagor() {
    _i1.throwOnMissingStub(this);
  }

  @override
  void complete() => super.noSuchMethod(Invocation.method(#complete, []),
      returnValueForMissingStub: null);
}

/// A class which mocks [WalletService].
///
/// See the documentation for Mockito's code generation for more information.
class MockWalletService extends _i1.Mock implements _i2.WalletService {
  MockWalletService() {
    _i1.throwOnMissingStub(this);
  }

  @override
  _i2.WalletServiceEvents get events => (super.noSuchMethod(
      Invocation.getter(#events),
      returnValue: _FakeWalletServiceEvents_0()) as _i2.WalletServiceEvents);
  @override
  _i6.Future<_i7.WalletDetails?> selectWallet({String? id}) =>
      (super.noSuchMethod(Invocation.method(#selectWallet, [], {#id: id}),
              returnValue: Future<_i7.WalletDetails?>.value())
          as _i6.Future<_i7.WalletDetails?>);
  @override
  _i6.Future<_i7.WalletDetails?> getSelectedWallet() =>
      (super.noSuchMethod(Invocation.method(#getSelectedWallet, []),
              returnValue: Future<_i7.WalletDetails?>.value())
          as _i6.Future<_i7.WalletDetails?>);
  @override
  _i6.Future<List<_i7.WalletDetails>> getWallets() =>
      (super.noSuchMethod(Invocation.method(#getWallets, []),
              returnValue:
                  Future<List<_i7.WalletDetails>>.value(<_i7.WalletDetails>[]))
          as _i6.Future<List<_i7.WalletDetails>>);
  @override
  _i6.Future<bool> getUseBiometry() =>
      (super.noSuchMethod(Invocation.method(#getUseBiometry, []),
          returnValue: Future<bool>.value(false)) as _i6.Future<bool>);
  @override
  _i6.Future<dynamic> setUseBiometry({bool? useBiometry}) =>
      (super.noSuchMethod(
          Invocation.method(#setUseBiometry, [], {#useBiometry: useBiometry}),
          returnValue: Future<dynamic>.value()) as _i6.Future<dynamic>);
  @override
  _i6.Future<_i7.WalletDetails?> renameWallet({String? id, String? name}) =>
      (super.noSuchMethod(
              Invocation.method(#renameWallet, [], {#id: id, #name: name}),
              returnValue: Future<_i7.WalletDetails?>.value())
          as _i6.Future<_i7.WalletDetails?>);
  @override
  _i6.Future<_i7.WalletDetails?> addWallet(
          {List<String>? phrase,
          String? name,
          bool? useBiometry,
          _i8.Coin? coin = _i8.Coin.testNet}) =>
      (super.noSuchMethod(
              Invocation.method(#addWallet, [], {
                #phrase: phrase,
                #name: name,
                #useBiometry: useBiometry,
                #coin: coin
              }),
              returnValue: Future<_i7.WalletDetails?>.value())
          as _i6.Future<_i7.WalletDetails?>);
  @override
  _i6.Future<_i7.WalletDetails?> removeWallet({String? id}) =>
      (super.noSuchMethod(Invocation.method(#removeWallet, [], {#id: id}),
              returnValue: Future<_i7.WalletDetails?>.value())
          as _i6.Future<_i7.WalletDetails?>);
  @override
  _i6.Future<List<_i7.WalletDetails>> resetWallets() =>
      (super.noSuchMethod(Invocation.method(#resetWallets, []),
              returnValue:
                  Future<List<_i7.WalletDetails>>.value(<_i7.WalletDetails>[]))
          as _i6.Future<List<_i7.WalletDetails>>);
  @override
  _i6.Future<_i8.PrivateKey?> loadKey(String? walletId) =>
      (super.noSuchMethod(Invocation.method(#loadKey, [walletId]),
              returnValue: Future<_i8.PrivateKey?>.value())
          as _i6.Future<_i8.PrivateKey?>);
  @override
  _i6.Future<bool> isValidWalletConnectData(String? qrData) => (super
      .noSuchMethod(Invocation.method(#isValidWalletConnectData, [qrData]),
          returnValue: Future<bool>.value(false)) as _i6.Future<bool>);
}

/// A class which mocks [WalletConnectTransactionHandler].
///
/// See the documentation for Mockito's code generation for more information.
class MockWalletConnectTransactionHandler extends _i1.Mock
    implements _i9.WalletConnectTransactionHandler {
  MockWalletConnectTransactionHandler() {
    _i1.throwOnMissingStub(this);
  }

  @override
  _i6.Future<_i3.WalletGasEstimate> estimateGas(
          _i4.TxBody? txBody, _i8.PublicKey? publicKey) =>
      (super.noSuchMethod(Invocation.method(#estimateGas, [txBody, publicKey]),
              returnValue: Future<_i3.WalletGasEstimate>.value(
                  _FakeWalletGasEstimate_1()))
          as _i6.Future<_i3.WalletGasEstimate>);
  @override
  _i6.Future<_i4.RawTxResponsePair> executeTransaction(
          _i4.TxBody? txBody, _i8.PrivateKey? privateKey,
          [_i3.WalletGasEstimate? gasEstimate]) =>
      (super.noSuchMethod(
              Invocation.method(
                  #executeTransaction, [txBody, privateKey, gasEstimate]),
              returnValue: Future<_i4.RawTxResponsePair>.value(
                  _FakeRawTxResponsePair_2()))
          as _i6.Future<_i4.RawTxResponsePair>);
}
