// Mocks generated by Mockito 5.1.0 from annotations
// in provenance_wallet/test/screens/send_flow/send_amount/send_amount_bloc_test.dart.
// Do not manually edit this file.

import 'dart:async' as _i3;

import 'package:decimal/decimal.dart' as _i4;
import 'package:mockito/mockito.dart' as _i1;
import 'package:provenance_dart/proto.dart' as _i9;
import 'package:provenance_dart/wallet.dart' as _i7;
import 'package:provenance_wallet/screens/send_flow/send_amount/send_amount_bloc.dart'
    as _i2;
import 'package:provenance_wallet/services/models/wallet_details.dart' as _i6;
import 'package:provenance_wallet/services/wallet_connect_session.dart' as _i8;
import 'package:provenance_wallet/services/wallet_service.dart' as _i5;

// ignore_for_file: type=lint
// ignore_for_file: avoid_redundant_argument_values
// ignore_for_file: avoid_setters_without_getters
// ignore_for_file: comment_references
// ignore_for_file: implementation_imports
// ignore_for_file: invalid_use_of_visible_for_testing_member
// ignore_for_file: prefer_const_constructors
// ignore_for_file: unnecessary_parenthesis
// ignore_for_file: camel_case_types

/// A class which mocks [SendAmountBlocNavigator].
///
/// See the documentation for Mockito's code generation for more information.
class MockSendAmountBlocNavigator extends _i1.Mock
    implements _i2.SendAmountBlocNavigator {
  MockSendAmountBlocNavigator() {
    _i1.throwOnMissingStub(this);
  }

  @override
  _i3.Future<void> showReviewSend(
          String? amountToSend, _i4.Decimal? fee, String? note) =>
      (super.noSuchMethod(
          Invocation.method(#showReviewSend, [amountToSend, fee, note]),
          returnValue: Future<void>.value(),
          returnValueForMissingStub: Future<void>.value()) as _i3.Future<void>);
}

/// A class which mocks [WalletService].
///
/// See the documentation for Mockito's code generation for more information.
class MockWalletService extends _i1.Mock implements _i5.WalletService {
  MockWalletService() {
    _i1.throwOnMissingStub(this);
  }

  @override
  _i3.Future<_i6.WalletDetails?> selectWallet({String? id}) =>
      (super.noSuchMethod(Invocation.method(#selectWallet, [], {#id: id}),
              returnValue: Future<_i6.WalletDetails?>.value())
          as _i3.Future<_i6.WalletDetails?>);
  @override
  _i3.Future<_i6.WalletDetails?> getSelectedWallet() =>
      (super.noSuchMethod(Invocation.method(#getSelectedWallet, []),
              returnValue: Future<_i6.WalletDetails?>.value())
          as _i3.Future<_i6.WalletDetails?>);
  @override
  _i3.Future<List<_i6.WalletDetails>> getWallets() =>
      (super.noSuchMethod(Invocation.method(#getWallets, []),
              returnValue:
                  Future<List<_i6.WalletDetails>>.value(<_i6.WalletDetails>[]))
          as _i3.Future<List<_i6.WalletDetails>>);
  @override
  _i3.Future<bool> getUseBiometry() =>
      (super.noSuchMethod(Invocation.method(#getUseBiometry, []),
          returnValue: Future<bool>.value(false)) as _i3.Future<bool>);
  @override
  _i3.Future<dynamic> setUseBiometry({bool? useBiometry}) =>
      (super.noSuchMethod(
          Invocation.method(#setUseBiometry, [], {#useBiometry: useBiometry}),
          returnValue: Future<dynamic>.value()) as _i3.Future<dynamic>);
  @override
  _i3.Future<dynamic> renameWallet({String? id, String? name}) =>
      (super.noSuchMethod(
          Invocation.method(#renameWallet, [], {#id: id, #name: name}),
          returnValue: Future<dynamic>.value()) as _i3.Future<dynamic>);
  @override
  _i3.Future<bool> saveWallet(
          {List<String>? phrase,
          String? name,
          bool? useBiometry,
          _i7.Coin? coin = _i7.Coin.testNet}) =>
      (super.noSuchMethod(
          Invocation.method(#saveWallet, [], {
            #phrase: phrase,
            #name: name,
            #useBiometry: useBiometry,
            #coin: coin
          }),
          returnValue: Future<bool>.value(false)) as _i3.Future<bool>);
  @override
  _i3.Future<void> removeWallet({String? id}) =>
      (super.noSuchMethod(Invocation.method(#removeWallet, [], {#id: id}),
          returnValue: Future<void>.value(),
          returnValueForMissingStub: Future<void>.value()) as _i3.Future<void>);
  @override
  _i3.Future<void> resetWallets() =>
      (super.noSuchMethod(Invocation.method(#resetWallets, []),
          returnValue: Future<void>.value(),
          returnValueForMissingStub: Future<void>.value()) as _i3.Future<void>);
  @override
  _i3.Future<_i8.WalletConnectSession?> connectWallet(String? addressData) =>
      (super.noSuchMethod(Invocation.method(#connectWallet, [addressData]),
              returnValue: Future<_i8.WalletConnectSession?>.value())
          as _i3.Future<_i8.WalletConnectSession?>);
  @override
  _i3.Future<bool> isValidWalletConnectData(String? qrData) => (super
      .noSuchMethod(Invocation.method(#isValidWalletConnectData, [qrData]),
          returnValue: Future<bool>.value(false)) as _i3.Future<bool>);
  @override
  _i3.Future<int> estimate(
          _i9.TxBody? body, _i6.WalletDetails? walletDetails) =>
      (super.noSuchMethod(Invocation.method(#estimate, [body, walletDetails]),
          returnValue: Future<int>.value(0)) as _i3.Future<int>);
}
