// Mocks generated by Mockito 5.1.0 from annotations
// in provenance_wallet/test/screens/send_flow/send_flow_test.dart.
// Do not manually edit this file.

import 'dart:async' as _i7;

import 'package:mockito/mockito.dart' as _i1;
import 'package:provenance_dart/proto.dart' as _i4;
import 'package:provenance_dart/wallet.dart' as _i9;
import 'package:provenance_wallet/services/asset_service/asset_service.dart'
    as _i6;
import 'package:provenance_wallet/services/http_client.dart' as _i5;
import 'package:provenance_wallet/services/models/asset.dart' as _i8;
import 'package:provenance_wallet/services/models/asset_graph_item.dart'
    as _i10;
import 'package:provenance_wallet/services/models/price.dart' as _i17;
import 'package:provenance_wallet/services/models/send_transactions.dart'
    as _i12;
import 'package:provenance_wallet/services/models/transaction.dart' as _i13;
import 'package:provenance_wallet/services/models/wallet_details.dart' as _i14;
import 'package:provenance_wallet/services/price_service/price_service.dart'
    as _i16;
import 'package:provenance_wallet/services/transaction_service/transaction_service.dart'
    as _i11;
import 'package:provenance_wallet/services/wallet_service/model/wallet_gas_estimate.dart'
    as _i3;
import 'package:provenance_wallet/services/wallet_service/wallet_connect_transaction_handler.dart'
    as _i15;
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

class _FakeHttpClient_3 extends _i1.Fake implements _i5.HttpClient {}

/// A class which mocks [AssetService].
///
/// See the documentation for Mockito's code generation for more information.
class MockAssetService extends _i1.Mock implements _i6.AssetService {
  MockAssetService() {
    _i1.throwOnMissingStub(this);
  }

  @override
  _i7.Future<List<_i8.Asset>> getAssets(
          _i9.Coin? coin, String? provenanceAddresses) =>
      (super.noSuchMethod(
              Invocation.method(#getAssets, [coin, provenanceAddresses]),
              returnValue: Future<List<_i8.Asset>>.value(<_i8.Asset>[]))
          as _i7.Future<List<_i8.Asset>>);
  @override
  _i7.Future<List<_i10.AssetGraphItem>> getAssetGraphingData(
          _i9.Coin? coin, String? assetType, _i6.GraphingDataValue? value,
          {DateTime? startDate, DateTime? endDate}) =>
      (super.noSuchMethod(
              Invocation.method(#getAssetGraphingData, [coin, assetType, value],
                  {#startDate: startDate, #endDate: endDate}),
              returnValue: Future<List<_i10.AssetGraphItem>>.value(
                  <_i10.AssetGraphItem>[]))
          as _i7.Future<List<_i10.AssetGraphItem>>);
}

/// A class which mocks [TransactionService].
///
/// See the documentation for Mockito's code generation for more information.
class MockTransactionService extends _i1.Mock
    implements _i11.TransactionService {
  MockTransactionService() {
    _i1.throwOnMissingStub(this);
  }

  @override
  _i7.Future<List<_i12.SendTransaction>> getSendTransactions(
          _i9.Coin? coin, String? provenanceAddress) =>
      (super.noSuchMethod(
          Invocation.method(#getSendTransactions, [coin, provenanceAddress]),
          returnValue: Future<List<_i12.SendTransaction>>.value(
              <_i12.SendTransaction>[])) as _i7
          .Future<List<_i12.SendTransaction>>);
  @override
  _i7.Future<List<_i13.Transaction>> getTransactions(
          _i9.Coin? coin, String? provenanceAddress, int? pageNumber) =>
      (super.noSuchMethod(
              Invocation.method(
                  #getTransactions, [coin, provenanceAddress, pageNumber]),
              returnValue:
                  Future<List<_i13.Transaction>>.value(<_i13.Transaction>[]))
          as _i7.Future<List<_i13.Transaction>>);
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
  _i7.Future<void> init() => (super.noSuchMethod(Invocation.method(#init, []),
      returnValue: Future<void>.value(),
      returnValueForMissingStub: Future<void>.value()) as _i7.Future<void>);
  @override
  _i7.Future<_i14.WalletDetails?> selectWallet({String? id}) =>
      (super.noSuchMethod(Invocation.method(#selectWallet, [], {#id: id}),
              returnValue: Future<_i14.WalletDetails?>.value())
          as _i7.Future<_i14.WalletDetails?>);
  @override
  _i7.Future<_i14.WalletDetails?> getSelectedWallet() =>
      (super.noSuchMethod(Invocation.method(#getSelectedWallet, []),
              returnValue: Future<_i14.WalletDetails?>.value())
          as _i7.Future<_i14.WalletDetails?>);
  @override
  _i7.Future<List<_i14.WalletDetails>> getWallets() => (super.noSuchMethod(
          Invocation.method(#getWallets, []),
          returnValue:
              Future<List<_i14.WalletDetails>>.value(<_i14.WalletDetails>[]))
      as _i7.Future<List<_i14.WalletDetails>>);
  @override
  _i7.Future<_i14.WalletDetails?> renameWallet({String? id, String? name}) =>
      (super.noSuchMethod(
              Invocation.method(#renameWallet, [], {#id: id, #name: name}),
              returnValue: Future<_i14.WalletDetails?>.value())
          as _i7.Future<_i14.WalletDetails?>);
  @override
  _i7.Future<_i14.WalletDetails?> setWalletCoin({String? id, _i9.Coin? coin}) =>
      (super.noSuchMethod(
              Invocation.method(#setWalletCoin, [], {#id: id, #coin: coin}),
              returnValue: Future<_i14.WalletDetails?>.value())
          as _i7.Future<_i14.WalletDetails?>);
  @override
  _i7.Future<_i14.WalletDetails?> addWallet(
          {List<String>? phrase, String? name, _i9.Coin? coin}) =>
      (super.noSuchMethod(
              Invocation.method(
                  #addWallet, [], {#phrase: phrase, #name: name, #coin: coin}),
              returnValue: Future<_i14.WalletDetails?>.value())
          as _i7.Future<_i14.WalletDetails?>);
  @override
  _i7.Future<_i14.WalletDetails?> removeWallet({String? id}) =>
      (super.noSuchMethod(Invocation.method(#removeWallet, [], {#id: id}),
              returnValue: Future<_i14.WalletDetails?>.value())
          as _i7.Future<_i14.WalletDetails?>);
  @override
  _i7.Future<List<_i14.WalletDetails>> resetWallets() => (super.noSuchMethod(
          Invocation.method(#resetWallets, []),
          returnValue:
              Future<List<_i14.WalletDetails>>.value(<_i14.WalletDetails>[]))
      as _i7.Future<List<_i14.WalletDetails>>);
  @override
  _i7.Future<_i9.PrivateKey?> loadKey(String? walletId) =>
      (super.noSuchMethod(Invocation.method(#loadKey, [walletId]),
              returnValue: Future<_i9.PrivateKey?>.value())
          as _i7.Future<_i9.PrivateKey?>);
  @override
  _i7.Future<bool> isValidWalletConnectData(String? qrData) => (super
      .noSuchMethod(Invocation.method(#isValidWalletConnectData, [qrData]),
          returnValue: Future<bool>.value(false)) as _i7.Future<bool>);
}

/// A class which mocks [WalletConnectTransactionHandler].
///
/// See the documentation for Mockito's code generation for more information.
class MockWalletConnectTransactionHandler extends _i1.Mock
    implements _i15.WalletConnectTransactionHandler {
  MockWalletConnectTransactionHandler() {
    _i1.throwOnMissingStub(this);
  }

  @override
  _i7.Future<_i3.WalletGasEstimate> estimateGas(
          _i4.TxBody? txBody, _i9.PublicKey? publicKey) =>
      (super.noSuchMethod(Invocation.method(#estimateGas, [txBody, publicKey]),
              returnValue: Future<_i3.WalletGasEstimate>.value(
                  _FakeWalletGasEstimate_1()))
          as _i7.Future<_i3.WalletGasEstimate>);
  @override
  _i7.Future<_i4.RawTxResponsePair> executeTransaction(
          _i4.TxBody? txBody, _i9.PrivateKey? privateKey,
          [_i3.WalletGasEstimate? gasEstimate]) =>
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
class MockPriceService extends _i1.Mock implements _i16.PriceService {
  MockPriceService() {
    _i1.throwOnMissingStub(this);
  }

  @override
  _i7.Future<List<_i17.Price>> getAssetPrices(
          _i9.Coin? coin, List<String>? denominations) =>
      (super.noSuchMethod(
              Invocation.method(#getAssetPrices, [coin, denominations]),
              returnValue: Future<List<_i17.Price>>.value(<_i17.Price>[]))
          as _i7.Future<List<_i17.Price>>);
  @override
  _i5.HttpClient getClient(_i9.Coin? coin) =>
      (super.noSuchMethod(Invocation.method(#getClient, [coin]),
          returnValue: _FakeHttpClient_3()) as _i5.HttpClient);
}
