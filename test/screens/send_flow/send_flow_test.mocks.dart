// Mocks generated by Mockito 5.1.0 from annotations
// in provenance_wallet/test/screens/send_flow/send_flow_test.dart.
// Do not manually edit this file.

import 'dart:async' as _i6;

import 'package:mockito/mockito.dart' as _i1;
import 'package:provenance_dart/proto.dart' as _i4;
import 'package:provenance_dart/wallet.dart' as _i12;
import 'package:provenance_wallet/services/asset_service/asset_service.dart'
    as _i5;
import 'package:provenance_wallet/services/models/asset.dart' as _i7;
import 'package:provenance_wallet/services/models/asset_graph_item.dart' as _i8;
import 'package:provenance_wallet/services/models/asset_statistic.dart' as _i2;
import 'package:provenance_wallet/services/models/transaction.dart' as _i10;
import 'package:provenance_wallet/services/models/wallet_details.dart' as _i11;
import 'package:provenance_wallet/services/transaction_service/transaction_service.dart'
    as _i9;
import 'package:provenance_wallet/services/wallet_service/wallet_connect_transaction_handler.dart'
    as _i13;
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

class _FakeGasEstimate_2 extends _i1.Fake implements _i4.GasEstimate {}

class _FakeRawTxResponsePair_3 extends _i1.Fake
    implements _i4.RawTxResponsePair {}

/// A class which mocks [AssetService].
///
/// See the documentation for Mockito's code generation for more information.
class MockAssetService extends _i1.Mock implements _i5.AssetService {
  MockAssetService() {
    _i1.throwOnMissingStub(this);
  }

  @override
  _i6.Future<List<_i7.Asset>> getAssets(String? provenanceAddresses) =>
      (super.noSuchMethod(Invocation.method(#getAssets, [provenanceAddresses]),
              returnValue: Future<List<_i7.Asset>>.value(<_i7.Asset>[]))
          as _i6.Future<List<_i7.Asset>>);
  @override
  _i6.Future<_i2.AssetStatistics> getAssetStatistics(String? assetType) =>
      (super.noSuchMethod(Invocation.method(#getAssetStatistics, [assetType]),
              returnValue:
                  Future<_i2.AssetStatistics>.value(_FakeAssetStatistics_0()))
          as _i6.Future<_i2.AssetStatistics>);
  @override
  _i6.Future<List<_i8.AssetGraphItem>> getAssetGraphingData(
          String? assetType, _i5.GraphingDataValue? value) =>
      (super.noSuchMethod(
          Invocation.method(#getAssetGraphingData, [assetType, value]),
          returnValue: Future<List<_i8.AssetGraphItem>>.value(
              <_i8.AssetGraphItem>[])) as _i6.Future<List<_i8.AssetGraphItem>>);
}

/// A class which mocks [TransactionService].
///
/// See the documentation for Mockito's code generation for more information.
class MockTransactionService extends _i1.Mock
    implements _i9.TransactionService {
  MockTransactionService() {
    _i1.throwOnMissingStub(this);
  }

  @override
  _i6.Future<List<_i10.Transaction>> getTransactions(
          String? provenanceAddress) =>
      (super.noSuchMethod(
              Invocation.method(#getTransactions, [provenanceAddress]),
              returnValue:
                  Future<List<_i10.Transaction>>.value(<_i10.Transaction>[]))
          as _i6.Future<List<_i10.Transaction>>);
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
  _i6.Future<_i11.WalletDetails?> selectWallet({String? id}) =>
      (super.noSuchMethod(Invocation.method(#selectWallet, [], {#id: id}),
              returnValue: Future<_i11.WalletDetails?>.value())
          as _i6.Future<_i11.WalletDetails?>);
  @override
  _i6.Future<_i11.WalletDetails?> getSelectedWallet() =>
      (super.noSuchMethod(Invocation.method(#getSelectedWallet, []),
              returnValue: Future<_i11.WalletDetails?>.value())
          as _i6.Future<_i11.WalletDetails?>);
  @override
  _i6.Future<List<_i11.WalletDetails>> getWallets() => (super.noSuchMethod(
          Invocation.method(#getWallets, []),
          returnValue:
              Future<List<_i11.WalletDetails>>.value(<_i11.WalletDetails>[]))
      as _i6.Future<List<_i11.WalletDetails>>);
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
  _i6.Future<_i11.WalletDetails?> renameWallet({String? id, String? name}) =>
      (super.noSuchMethod(
              Invocation.method(#renameWallet, [], {#id: id, #name: name}),
              returnValue: Future<_i11.WalletDetails?>.value())
          as _i6.Future<_i11.WalletDetails?>);
  @override
  _i6.Future<_i11.WalletDetails?> addWallet(
          {List<String>? phrase,
          String? name,
          bool? useBiometry,
          _i12.Coin? coin = _i12.Coin.testNet}) =>
      (super.noSuchMethod(
              Invocation.method(#addWallet, [], {
                #phrase: phrase,
                #name: name,
                #useBiometry: useBiometry,
                #coin: coin
              }),
              returnValue: Future<_i11.WalletDetails?>.value())
          as _i6.Future<_i11.WalletDetails?>);
  @override
  _i6.Future<_i11.WalletDetails?> removeWallet({String? id}) =>
      (super.noSuchMethod(Invocation.method(#removeWallet, [], {#id: id}),
              returnValue: Future<_i11.WalletDetails?>.value())
          as _i6.Future<_i11.WalletDetails?>);
  @override
  _i6.Future<List<_i11.WalletDetails>> resetWallets() => (super.noSuchMethod(
          Invocation.method(#resetWallets, []),
          returnValue:
              Future<List<_i11.WalletDetails>>.value(<_i11.WalletDetails>[]))
      as _i6.Future<List<_i11.WalletDetails>>);
  @override
  _i6.Future<_i12.PrivateKey?> loadKey(String? walletId) =>
      (super.noSuchMethod(Invocation.method(#loadKey, [walletId]),
              returnValue: Future<_i12.PrivateKey?>.value())
          as _i6.Future<_i12.PrivateKey?>);
  @override
  _i6.Future<bool> isValidWalletConnectData(String? qrData) => (super
      .noSuchMethod(Invocation.method(#isValidWalletConnectData, [qrData]),
          returnValue: Future<bool>.value(false)) as _i6.Future<bool>);
}

/// A class which mocks [WalletConnectTransactionHandler].
///
/// See the documentation for Mockito's code generation for more information.
class MockWalletConnectTransactionHandler extends _i1.Mock
    implements _i13.WalletConnectTransactionHandler {
  MockWalletConnectTransactionHandler() {
    _i1.throwOnMissingStub(this);
  }

  @override
  _i6.Future<_i4.GasEstimate> estimateGas(
          _i4.TxBody? txBody, _i12.PublicKey? publicKey) =>
      (super.noSuchMethod(Invocation.method(#estimateGas, [txBody, publicKey]),
              returnValue: Future<_i4.GasEstimate>.value(_FakeGasEstimate_2()))
          as _i6.Future<_i4.GasEstimate>);
  @override
  _i6.Future<_i4.RawTxResponsePair> executeTransaction(
          _i4.TxBody? txBody, _i12.PrivateKey? privateKey,
          [_i4.GasEstimate? gasEstimate]) =>
      (super.noSuchMethod(
              Invocation.method(
                  #executeTransaction, [txBody, privateKey, gasEstimate]),
              returnValue: Future<_i4.RawTxResponsePair>.value(
                  _FakeRawTxResponsePair_3()))
          as _i6.Future<_i4.RawTxResponsePair>);
}
