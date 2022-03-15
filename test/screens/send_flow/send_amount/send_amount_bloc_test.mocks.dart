// Mocks generated by Mockito 5.1.0 from annotations
// in provenance_wallet/test/screens/send_flow/send_amount/send_amount_bloc_test.dart.
// Do not manually edit this file.

import 'dart:async' as _i5;

import 'package:mockito/mockito.dart' as _i1;
import 'package:provenance_dart/proto.dart' as _i3;
import 'package:provenance_dart/wallet.dart' as _i8;
import 'package:provenance_wallet/screens/send_flow/model/send_asset.dart'
    as _i6;
import 'package:provenance_wallet/screens/send_flow/send_amount/send_amount_bloc.dart'
    as _i4;
import 'package:provenance_wallet/services/models/price.dart' as _i10;
import 'package:provenance_wallet/services/models/wallet_details.dart' as _i7;
import 'package:provenance_wallet/services/price_service/price_service.dart'
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

class _FakeGasEstimate_1 extends _i1.Fake implements _i3.GasEstimate {}

/// A class which mocks [SendAmountBlocNavigator].
///
/// See the documentation for Mockito's code generation for more information.
class MockSendAmountBlocNavigator extends _i1.Mock
    implements _i4.SendAmountBlocNavigator {
  MockSendAmountBlocNavigator() {
    _i1.throwOnMissingStub(this);
  }

  @override
  _i5.Future<void> showReviewSend(
          _i6.SendAsset? amountToSend, _i6.MultiSendAsset? fee, String? note) =>
      (super.noSuchMethod(
          Invocation.method(#showReviewSend, [amountToSend, fee, note]),
          returnValue: Future<void>.value(),
          returnValueForMissingStub: Future<void>.value()) as _i5.Future<void>);
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
  _i5.Future<_i7.WalletDetails?> selectWallet({String? id}) =>
      (super.noSuchMethod(Invocation.method(#selectWallet, [], {#id: id}),
              returnValue: Future<_i7.WalletDetails?>.value())
          as _i5.Future<_i7.WalletDetails?>);
  @override
  _i5.Future<_i7.WalletDetails?> getSelectedWallet() =>
      (super.noSuchMethod(Invocation.method(#getSelectedWallet, []),
              returnValue: Future<_i7.WalletDetails?>.value())
          as _i5.Future<_i7.WalletDetails?>);
  @override
  _i5.Future<List<_i7.WalletDetails>> getWallets() =>
      (super.noSuchMethod(Invocation.method(#getWallets, []),
              returnValue:
                  Future<List<_i7.WalletDetails>>.value(<_i7.WalletDetails>[]))
          as _i5.Future<List<_i7.WalletDetails>>);
  @override
  _i5.Future<bool> getUseBiometry() =>
      (super.noSuchMethod(Invocation.method(#getUseBiometry, []),
          returnValue: Future<bool>.value(false)) as _i5.Future<bool>);
  @override
  _i5.Future<dynamic> setUseBiometry({bool? useBiometry}) =>
      (super.noSuchMethod(
          Invocation.method(#setUseBiometry, [], {#useBiometry: useBiometry}),
          returnValue: Future<dynamic>.value()) as _i5.Future<dynamic>);
  @override
  _i5.Future<_i7.WalletDetails?> renameWallet({String? id, String? name}) =>
      (super.noSuchMethod(
              Invocation.method(#renameWallet, [], {#id: id, #name: name}),
              returnValue: Future<_i7.WalletDetails?>.value())
          as _i5.Future<_i7.WalletDetails?>);
  @override
  _i5.Future<_i7.WalletDetails?> addWallet(
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
          as _i5.Future<_i7.WalletDetails?>);
  @override
  _i5.Future<_i7.WalletDetails?> removeWallet({String? id}) =>
      (super.noSuchMethod(Invocation.method(#removeWallet, [], {#id: id}),
              returnValue: Future<_i7.WalletDetails?>.value())
          as _i5.Future<_i7.WalletDetails?>);
  @override
  _i5.Future<List<_i7.WalletDetails>> resetWallets() =>
      (super.noSuchMethod(Invocation.method(#resetWallets, []),
              returnValue:
                  Future<List<_i7.WalletDetails>>.value(<_i7.WalletDetails>[]))
          as _i5.Future<List<_i7.WalletDetails>>);
  @override
  _i5.Future<_i8.PrivateKey?> loadKey(String? walletId) =>
      (super.noSuchMethod(Invocation.method(#loadKey, [walletId]),
              returnValue: Future<_i8.PrivateKey?>.value())
          as _i5.Future<_i8.PrivateKey?>);
  @override
  _i5.Future<bool> isValidWalletConnectData(String? qrData) => (super
      .noSuchMethod(Invocation.method(#isValidWalletConnectData, [qrData]),
          returnValue: Future<bool>.value(false)) as _i5.Future<bool>);
  @override
  _i5.Future<_i3.GasEstimate> estimate(
          _i3.TxBody? body, _i7.WalletDetails? walletDetails) =>
      (super.noSuchMethod(Invocation.method(#estimate, [body, walletDetails]),
              returnValue: Future<_i3.GasEstimate>.value(_FakeGasEstimate_1()))
          as _i5.Future<_i3.GasEstimate>);
  @override
  _i5.Future<void> submitTransaction(
          _i3.TxBody? body, _i7.WalletDetails? walletDetails,
          [_i3.GasEstimate? gasEstimate]) =>
      (super.noSuchMethod(
          Invocation.method(
              #submitTransaction, [body, walletDetails, gasEstimate]),
          returnValue: Future<void>.value(),
          returnValueForMissingStub: Future<void>.value()) as _i5.Future<void>);
}

/// A class which mocks [PriceService].
///
/// See the documentation for Mockito's code generation for more information.
class MockPriceService extends _i1.Mock implements _i9.PriceService {
  MockPriceService() {
    _i1.throwOnMissingStub(this);
  }

  @override
  _i5.Future<List<_i10.Price>> getAssetPrices(List<String>? denominations) =>
      (super.noSuchMethod(Invocation.method(#getAssetPrices, [denominations]),
              returnValue: Future<List<_i10.Price>>.value(<_i10.Price>[]))
          as _i5.Future<List<_i10.Price>>);
}
