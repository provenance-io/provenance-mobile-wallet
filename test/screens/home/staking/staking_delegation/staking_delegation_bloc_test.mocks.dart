// Mocks generated by Mockito 5.3.0 from annotations
// in provenance_wallet/test/screens/home/staking/staking_delegation/staking_delegation_bloc_test.dart.
// Do not manually edit this file.

// ignore_for_file: no_leading_underscores_for_library_prefixes
import 'dart:async' as _i6;

import 'package:mockito/mockito.dart' as _i1;
import 'package:provenance_dart/proto.dart' as _i4;
import 'package:provenance_dart/wallet.dart' as _i8;
import 'package:provenance_wallet/clients/multi_sig_client/models/multi_sig_signer.dart'
    as _i11;
import 'package:provenance_wallet/services/account_service/account_service.dart'
    as _i2;
import 'package:provenance_wallet/services/account_service/model/account_gas_estimate.dart'
    as _i3;
import 'package:provenance_wallet/services/account_service/transaction_handler.dart'
    as _i12;
import 'package:provenance_wallet/services/asset_client/asset_client.dart'
    as _i5;
import 'package:provenance_wallet/services/models/account.dart' as _i10;
import 'package:provenance_wallet/services/models/asset.dart' as _i7;
import 'package:provenance_wallet/services/models/asset_graph_item.dart' as _i9;

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

class _FakeAccountServiceEvents_0 extends _i1.SmartFake
    implements _i2.AccountServiceEvents {
  _FakeAccountServiceEvents_0(Object parent, Invocation parentInvocation)
      : super(parent, parentInvocation);
}

class _FakeAccountGasEstimate_1 extends _i1.SmartFake
    implements _i3.AccountGasEstimate {
  _FakeAccountGasEstimate_1(Object parent, Invocation parentInvocation)
      : super(parent, parentInvocation);
}

class _FakeRawTxResponsePair_2 extends _i1.SmartFake
    implements _i4.RawTxResponsePair {
  _FakeRawTxResponsePair_2(Object parent, Invocation parentInvocation)
      : super(parent, parentInvocation);
}

/// A class which mocks [AssetClient].
///
/// See the documentation for Mockito's code generation for more information.
class MockAssetClient extends _i1.Mock implements _i5.AssetClient {
  MockAssetClient() {
    _i1.throwOnMissingStub(this);
  }

  @override
  _i6.Future<List<_i7.Asset>> getAssets(
          _i8.Coin? coin, String? provenanceAddresses) =>
      (super.noSuchMethod(
              Invocation.method(#getAssets, [coin, provenanceAddresses]),
              returnValue: _i6.Future<List<_i7.Asset>>.value(<_i7.Asset>[]))
          as _i6.Future<List<_i7.Asset>>);
  @override
  _i6.Future<List<_i9.AssetGraphItem>> getAssetGraphingData(
          _i8.Coin? coin, String? assetType, _i5.GraphingDataValue? value,
          {DateTime? startDate, DateTime? endDate}) =>
      (super.noSuchMethod(
          Invocation.method(#getAssetGraphingData, [coin, assetType, value],
              {#startDate: startDate, #endDate: endDate}),
          returnValue: _i6.Future<List<_i9.AssetGraphItem>>.value(
              <_i9.AssetGraphItem>[])) as _i6.Future<List<_i9.AssetGraphItem>>);
}

/// A class which mocks [AccountService].
///
/// See the documentation for Mockito's code generation for more information.
class MockAccountService extends _i1.Mock implements _i2.AccountService {
  MockAccountService() {
    _i1.throwOnMissingStub(this);
  }

  @override
  _i2.AccountServiceEvents get events =>
      (super.noSuchMethod(Invocation.getter(#events),
              returnValue:
                  _FakeAccountServiceEvents_0(this, Invocation.getter(#events)))
          as _i2.AccountServiceEvents);
  @override
  _i6.Future<_i10.Account?> getAccount(String? id) =>
      (super.noSuchMethod(Invocation.method(#getAccount, [id]),
              returnValue: _i6.Future<_i10.Account?>.value())
          as _i6.Future<_i10.Account?>);
  @override
  _i6.Future<_i10.Account?> selectFirstAccount() =>
      (super.noSuchMethod(Invocation.method(#selectFirstAccount, []),
              returnValue: _i6.Future<_i10.Account?>.value())
          as _i6.Future<_i10.Account?>);
  @override
  _i6.Future<_i10.TransactableAccount?> selectAccount({String? id}) =>
      (super.noSuchMethod(Invocation.method(#selectAccount, [], {#id: id}),
              returnValue: _i6.Future<_i10.TransactableAccount?>.value())
          as _i6.Future<_i10.TransactableAccount?>);
  @override
  _i6.Future<_i10.TransactableAccount?> getSelectedAccount() =>
      (super.noSuchMethod(Invocation.method(#getSelectedAccount, []),
              returnValue: _i6.Future<_i10.TransactableAccount?>.value())
          as _i6.Future<_i10.TransactableAccount?>);
  @override
  _i6.Future<List<_i10.Account>> getAccounts() => (super.noSuchMethod(
          Invocation.method(#getAccounts, []),
          returnValue: _i6.Future<List<_i10.Account>>.value(<_i10.Account>[]))
      as _i6.Future<List<_i10.Account>>);
  @override
  _i6.Future<List<_i10.BasicAccount>> getBasicAccounts() => (super.noSuchMethod(
          Invocation.method(#getBasicAccounts, []),
          returnValue:
              _i6.Future<List<_i10.BasicAccount>>.value(<_i10.BasicAccount>[]))
      as _i6.Future<List<_i10.BasicAccount>>);
  @override
  _i6.Future<List<_i10.TransactableAccount>> getTransactableAccounts() =>
      (super.noSuchMethod(Invocation.method(#getTransactableAccounts, []),
              returnValue: _i6.Future<List<_i10.TransactableAccount>>.value(
                  <_i10.TransactableAccount>[]))
          as _i6.Future<List<_i10.TransactableAccount>>);
  @override
  _i6.Future<_i10.Account?> renameAccount({String? id, String? name}) =>
      (super.noSuchMethod(
              Invocation.method(#renameAccount, [], {#id: id, #name: name}),
              returnValue: _i6.Future<_i10.Account?>.value())
          as _i6.Future<_i10.Account?>);
  @override
  _i6.Future<_i10.Account?> setAccountCoin({String? id, _i8.Coin? coin}) =>
      (super.noSuchMethod(
              Invocation.method(#setAccountCoin, [], {#id: id, #coin: coin}),
              returnValue: _i6.Future<_i10.Account?>.value())
          as _i6.Future<_i10.Account?>);
  @override
  _i6.Future<_i10.Account?> addAccount(
          {List<String>? phrase, String? name, _i8.Coin? coin}) =>
      (super.noSuchMethod(
              Invocation.method(
                  #addAccount, [], {#phrase: phrase, #name: name, #coin: coin}),
              returnValue: _i6.Future<_i10.Account?>.value())
          as _i6.Future<_i10.Account?>);
  @override
  _i6.Future<_i10.MultiAccount?> addMultiAccount(
          {String? name,
          _i8.Coin? coin,
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
              returnValue: _i6.Future<_i10.MultiAccount?>.value())
          as _i6.Future<_i10.MultiAccount?>);
  @override
  _i6.Future<_i10.MultiTransactableAccount?> activateMultiAccount(
          {String? id, List<_i11.MultiSigSigner>? signers}) =>
      (super.noSuchMethod(
              Invocation.method(
                  #activateMultiAccount, [], {#id: id, #signers: signers}),
              returnValue: _i6.Future<_i10.MultiTransactableAccount?>.value())
          as _i6.Future<_i10.MultiTransactableAccount?>);
  @override
  _i6.Future<_i10.Account?> removeAccount({String? id}) =>
      (super.noSuchMethod(Invocation.method(#removeAccount, [], {#id: id}),
              returnValue: _i6.Future<_i10.Account?>.value())
          as _i6.Future<_i10.Account?>);
  @override
  _i6.Future<List<_i10.Account>> resetAccounts() => (super.noSuchMethod(
          Invocation.method(#resetAccounts, []),
          returnValue: _i6.Future<List<_i10.Account>>.value(<_i10.Account>[]))
      as _i6.Future<List<_i10.Account>>);
  @override
  _i6.Future<_i8.PrivateKey?> loadKey(String? accountId) =>
      (super.noSuchMethod(Invocation.method(#loadKey, [accountId]),
              returnValue: _i6.Future<_i8.PrivateKey?>.value())
          as _i6.Future<_i8.PrivateKey?>);
  @override
  _i6.Future<bool> isValidWalletConnectData(String? qrData) => (super
      .noSuchMethod(Invocation.method(#isValidWalletConnectData, [qrData]),
          returnValue: _i6.Future<bool>.value(false)) as _i6.Future<bool>);
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
  _i6.Stream<_i12.TransactionResponse> get transaction =>
      (super.noSuchMethod(Invocation.getter(#transaction),
              returnValue: _i6.Stream<_i12.TransactionResponse>.empty())
          as _i6.Stream<_i12.TransactionResponse>);
  @override
  _i6.Future<_i3.AccountGasEstimate> estimateGas(
          _i4.TxBody? txBody, List<_i8.IPubKey>? signers, _i8.Coin? coin) =>
      (super.noSuchMethod(
              Invocation.method(#estimateGas, [txBody, signers, coin]),
              returnValue: _i6.Future<_i3.AccountGasEstimate>.value(
                  _FakeAccountGasEstimate_1(
                      this,
                      Invocation.method(
                          #estimateGas, [txBody, signers, coin]))))
          as _i6.Future<_i3.AccountGasEstimate>);
  @override
  _i6.Future<_i4.RawTxResponsePair> executeTransaction(
          _i4.TxBody? txBody, _i8.IPrivKey? privateKey, _i8.Coin? coin,
          [_i3.AccountGasEstimate? gasEstimate]) =>
      (super.noSuchMethod(Invocation.method(#executeTransaction, [txBody, privateKey, coin, gasEstimate]),
              returnValue: _i6.Future<_i4.RawTxResponsePair>.value(_FakeRawTxResponsePair_2(
                  this,
                  Invocation.method(
                      #executeTransaction, [txBody, privateKey, coin, gasEstimate]))))
          as _i6.Future<_i4.RawTxResponsePair>);
}