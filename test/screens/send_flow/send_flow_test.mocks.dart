// Mocks generated by Mockito 5.1.0 from annotations
// in provenance_wallet/test/screens/send_flow/send_flow_test.dart.
// Do not manually edit this file.

import 'dart:async' as _i8;

import 'package:mockito/mockito.dart' as _i1;
import 'package:provenance_dart/proto.dart' as _i5;
import 'package:provenance_dart/wallet.dart' as _i10;
import 'package:provenance_wallet/services/asset_service/asset_service.dart'
    as _i7;
import 'package:provenance_wallet/services/http_client.dart' as _i6;
import 'package:provenance_wallet/services/models/asset.dart' as _i9;
import 'package:provenance_wallet/services/models/asset_graph_item.dart'
    as _i11;
import 'package:provenance_wallet/services/models/asset_statistic.dart' as _i2;
import 'package:provenance_wallet/services/models/price.dart' as _i17;
import 'package:provenance_wallet/services/models/transaction.dart' as _i13;
import 'package:provenance_wallet/services/models/wallet_details.dart' as _i14;
import 'package:provenance_wallet/services/price_service/price_service.dart'
    as _i16;
import 'package:provenance_wallet/services/transaction_service/transaction_service.dart'
    as _i12;
import 'package:provenance_wallet/services/wallet_service/model/wallet_gas_estimate.dart'
    as _i4;
import 'package:provenance_wallet/services/wallet_service/wallet_connect_transaction_handler.dart'
    as _i15;
import 'package:provenance_wallet/services/wallet_service/wallet_service.dart'
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

class _FakeAssetStatistics_0 extends _i1.Fake implements _i2.AssetStatistics {}

class _FakeWalletServiceEvents_1 extends _i1.Fake
    implements _i3.WalletServiceEvents {}

class _FakeWalletGasEstimate_2 extends _i1.Fake
    implements _i4.WalletGasEstimate {}

class _FakeRawTxResponsePair_3 extends _i1.Fake
    implements _i5.RawTxResponsePair {}

class _FakeHttpClient_4 extends _i1.Fake implements _i6.HttpClient {}

/// A class which mocks [AssetService].
///
/// See the documentation for Mockito's code generation for more information.
class MockAssetService extends _i1.Mock implements _i7.AssetService {
  MockAssetService() {
    _i1.throwOnMissingStub(this);
  }

  @override
  _i8.Future<List<_i9.Asset>> getAssets(
          _i10.Coin? coin, String? provenanceAddresses) =>
      (super.noSuchMethod(
              Invocation.method(#getAssets, [coin, provenanceAddresses]),
              returnValue: Future<List<_i9.Asset>>.value(<_i9.Asset>[]))
          as _i8.Future<List<_i9.Asset>>);
  @override
  _i8.Future<_i2.AssetStatistics> getAssetStatistics(String? assetType) =>
      (super.noSuchMethod(Invocation.method(#getAssetStatistics, [assetType]),
              returnValue:
                  Future<_i2.AssetStatistics>.value(_FakeAssetStatistics_0()))
          as _i8.Future<_i2.AssetStatistics>);
  @override
  _i8.Future<List<_i11.AssetGraphItem>> getAssetGraphingData(
          _i10.Coin? coin, String? assetType, _i7.GraphingDataValue? value) =>
      (super.noSuchMethod(
          Invocation.method(#getAssetGraphingData, [coin, assetType, value]),
          returnValue: Future<List<_i11.AssetGraphItem>>.value(
              <_i11.AssetGraphItem>[])) as _i8
          .Future<List<_i11.AssetGraphItem>>);
}

/// A class which mocks [TransactionService].
///
/// See the documentation for Mockito's code generation for more information.
class MockTransactionService extends _i1.Mock
    implements _i12.TransactionService {
  MockTransactionService() {
    _i1.throwOnMissingStub(this);
  }

  @override
  _i8.Future<List<_i13.Transaction>> getTransactions(
          _i10.Coin? coin, String? provenanceAddress) =>
      (super.noSuchMethod(
              Invocation.method(#getTransactions, [coin, provenanceAddress]),
              returnValue:
                  Future<List<_i13.Transaction>>.value(<_i13.Transaction>[]))
          as _i8.Future<List<_i13.Transaction>>);
}

/// A class which mocks [WalletService].
///
/// See the documentation for Mockito's code generation for more information.
class MockWalletService extends _i1.Mock implements _i3.WalletService {
  MockWalletService() {
    _i1.throwOnMissingStub(this);
  }

  @override
  _i3.WalletServiceEvents get events => (super.noSuchMethod(
      Invocation.getter(#events),
      returnValue: _FakeWalletServiceEvents_1()) as _i3.WalletServiceEvents);
  @override
  _i8.Future<_i14.WalletDetails?> selectWallet({String? id}) =>
      (super.noSuchMethod(Invocation.method(#selectWallet, [], {#id: id}),
              returnValue: Future<_i14.WalletDetails?>.value())
          as _i8.Future<_i14.WalletDetails?>);
  @override
  _i8.Future<_i14.WalletDetails?> getSelectedWallet() =>
      (super.noSuchMethod(Invocation.method(#getSelectedWallet, []),
              returnValue: Future<_i14.WalletDetails?>.value())
          as _i8.Future<_i14.WalletDetails?>);
  @override
  _i8.Future<List<_i14.WalletDetails>> getWallets() => (super.noSuchMethod(
          Invocation.method(#getWallets, []),
          returnValue:
              Future<List<_i14.WalletDetails>>.value(<_i14.WalletDetails>[]))
      as _i8.Future<List<_i14.WalletDetails>>);
  @override
  _i8.Future<_i14.WalletDetails?> renameWallet({String? id, String? name}) =>
      (super.noSuchMethod(
              Invocation.method(#renameWallet, [], {#id: id, #name: name}),
              returnValue: Future<_i14.WalletDetails?>.value())
          as _i8.Future<_i14.WalletDetails?>);
  @override
  _i8.Future<_i14.WalletDetails?> setWalletCoin(
          {String? id, _i10.Coin? coin}) =>
      (super.noSuchMethod(
              Invocation.method(#setWalletCoin, [], {#id: id, #coin: coin}),
              returnValue: Future<_i14.WalletDetails?>.value())
          as _i8.Future<_i14.WalletDetails?>);
  @override
  _i8.Future<_i14.WalletDetails?> addWallet(
          {List<String>? phrase,
          String? name,
          _i10.Coin? coin = _i10.Coin.testNet}) =>
      (super.noSuchMethod(
              Invocation.method(
                  #addWallet, [], {#phrase: phrase, #name: name, #coin: coin}),
              returnValue: Future<_i14.WalletDetails?>.value())
          as _i8.Future<_i14.WalletDetails?>);
  @override
  _i8.Future<_i14.WalletDetails?> removeWallet({String? id}) =>
      (super.noSuchMethod(Invocation.method(#removeWallet, [], {#id: id}),
              returnValue: Future<_i14.WalletDetails?>.value())
          as _i8.Future<_i14.WalletDetails?>);
  @override
  _i8.Future<List<_i14.WalletDetails>> resetWallets() => (super.noSuchMethod(
          Invocation.method(#resetWallets, []),
          returnValue:
              Future<List<_i14.WalletDetails>>.value(<_i14.WalletDetails>[]))
      as _i8.Future<List<_i14.WalletDetails>>);
  @override
  _i8.Future<_i10.PrivateKey?> loadKey(String? walletId) =>
      (super.noSuchMethod(Invocation.method(#loadKey, [walletId]),
              returnValue: Future<_i10.PrivateKey?>.value())
          as _i8.Future<_i10.PrivateKey?>);
  @override
  _i8.Future<bool> isValidWalletConnectData(String? qrData) => (super
      .noSuchMethod(Invocation.method(#isValidWalletConnectData, [qrData]),
          returnValue: Future<bool>.value(false)) as _i8.Future<bool>);
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
  _i8.Future<_i4.WalletGasEstimate> estimateGas(
          _i5.TxBody? txBody, _i10.PublicKey? publicKey) =>
      (super.noSuchMethod(Invocation.method(#estimateGas, [txBody, publicKey]),
              returnValue: Future<_i4.WalletGasEstimate>.value(
                  _FakeWalletGasEstimate_2()))
          as _i8.Future<_i4.WalletGasEstimate>);
  @override
  _i8.Future<_i5.RawTxResponsePair> executeTransaction(
          _i5.TxBody? txBody, _i10.PrivateKey? privateKey,
          [_i4.WalletGasEstimate? gasEstimate]) =>
      (super.noSuchMethod(
              Invocation.method(
                  #executeTransaction, [txBody, privateKey, gasEstimate]),
              returnValue: Future<_i5.RawTxResponsePair>.value(
                  _FakeRawTxResponsePair_3()))
          as _i8.Future<_i5.RawTxResponsePair>);
}

/// A class which mocks [PriceService].
///
/// See the documentation for Mockito's code generation for more information.
class MockPriceService extends _i1.Mock implements _i16.PriceService {
  MockPriceService() {
    _i1.throwOnMissingStub(this);
  }

  @override
  _i8.Future<List<_i17.Price>> getAssetPrices(
          _i10.Coin? coin, List<String>? denominations) =>
      (super.noSuchMethod(
              Invocation.method(#getAssetPrices, [coin, denominations]),
              returnValue: Future<List<_i17.Price>>.value(<_i17.Price>[]))
          as _i8.Future<List<_i17.Price>>);
  @override
  _i6.HttpClient getClient(_i10.Coin? coin) =>
      (super.noSuchMethod(Invocation.method(#getClient, [coin]),
          returnValue: _FakeHttpClient_4()) as _i6.HttpClient);
}
