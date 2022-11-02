// Mocks generated by Mockito 5.3.0 from annotations
// in provenance_wallet/test/screens/home/staking/staking_delegation/staking_delegation_bloc_test.dart.
// Do not manually edit this file.

// ignore_for_file: no_leading_underscores_for_library_prefixes
import 'dart:async' as _i9;

import 'package:flutter/widgets.dart' as _i4;
import 'package:mockito/mockito.dart' as _i1;
import 'package:provenance_dart/proto.dart' as _i7;
import 'package:provenance_dart/wallet.dart' as _i5;
import 'package:provenance_wallet/clients/multi_sig_client/models/multi_sig_signer.dart'
    as _i12;
import 'package:provenance_wallet/gas_fee_estimate.dart' as _i6;
import 'package:provenance_wallet/services/account_service/account_service.dart'
    as _i2;
import 'package:provenance_wallet/services/account_service/transaction_handler.dart'
    as _i13;
import 'package:provenance_wallet/services/asset_client/asset_client.dart'
    as _i8;
import 'package:provenance_wallet/services/models/account.dart' as _i3;
import 'package:provenance_wallet/services/models/asset.dart' as _i10;
import 'package:provenance_wallet/services/models/asset_graph_item.dart'
    as _i11;

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

class _FakeAccount_1 extends _i1.SmartFake implements _i3.Account {
  _FakeAccount_1(Object parent, Invocation parentInvocation)
      : super(parent, parentInvocation);
}

class _FakeBasicAccount_2 extends _i1.SmartFake implements _i3.BasicAccount {
  _FakeBasicAccount_2(Object parent, Invocation parentInvocation)
      : super(parent, parentInvocation);

  @override
  String toString({_i4.DiagnosticLevel? minLevel = _i4.DiagnosticLevel.info}) =>
      super.toString();
}

class _FakeMultiAccount_3 extends _i1.SmartFake implements _i3.MultiAccount {
  _FakeMultiAccount_3(Object parent, Invocation parentInvocation)
      : super(parent, parentInvocation);

  @override
  String toString({_i4.DiagnosticLevel? minLevel = _i4.DiagnosticLevel.info}) =>
      super.toString();
}

class _FakeMultiTransactableAccount_4 extends _i1.SmartFake
    implements _i3.MultiTransactableAccount {
  _FakeMultiTransactableAccount_4(Object parent, Invocation parentInvocation)
      : super(parent, parentInvocation);

  @override
  String toString({_i4.DiagnosticLevel? minLevel = _i4.DiagnosticLevel.info}) =>
      super.toString();
}

class _FakePrivateKey_5 extends _i1.SmartFake implements _i5.PrivateKey {
  _FakePrivateKey_5(Object parent, Invocation parentInvocation)
      : super(parent, parentInvocation);
}

class _FakeGasFeeEstimate_6 extends _i1.SmartFake
    implements _i6.GasFeeEstimate {
  _FakeGasFeeEstimate_6(Object parent, Invocation parentInvocation)
      : super(parent, parentInvocation);
}

class _FakeRawTxResponsePair_7 extends _i1.SmartFake
    implements _i7.RawTxResponsePair {
  _FakeRawTxResponsePair_7(Object parent, Invocation parentInvocation)
      : super(parent, parentInvocation);
}

/// A class which mocks [AssetClient].
///
/// See the documentation for Mockito's code generation for more information.
class MockAssetClient extends _i1.Mock implements _i8.AssetClient {
  MockAssetClient() {
    _i1.throwOnMissingStub(this);
  }

  @override
  _i9.Future<List<_i10.Asset>> getAssets(
          _i5.Coin? coin, String? provenanceAddresses) =>
      (super.noSuchMethod(
              Invocation.method(#getAssets, [coin, provenanceAddresses]),
              returnValue: _i9.Future<List<_i10.Asset>>.value(<_i10.Asset>[]))
          as _i9.Future<List<_i10.Asset>>);
  @override
  _i9.Future<List<_i11.AssetGraphItem>> getAssetGraphingData(
          _i5.Coin? coin, String? assetType, _i8.GraphingDataValue? value,
          {DateTime? startDate, DateTime? endDate}) =>
      (super.noSuchMethod(
              Invocation.method(#getAssetGraphingData, [coin, assetType, value],
                  {#startDate: startDate, #endDate: endDate}),
              returnValue: _i9.Future<List<_i11.AssetGraphItem>>.value(
                  <_i11.AssetGraphItem>[]))
          as _i9.Future<List<_i11.AssetGraphItem>>);
  @override
  _i9.Future<void> getHash(_i5.Coin? coin, String? provenanceAddress) => (super
          .noSuchMethod(Invocation.method(#getHash, [coin, provenanceAddress]),
              returnValue: _i9.Future<void>.value(),
              returnValueForMissingStub: _i9.Future<void>.value())
      as _i9.Future<void>);
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
  _i9.Future<_i3.Account?> getAccount(String? id) =>
      (super.noSuchMethod(Invocation.method(#getAccount, [id]),
              returnValue: _i9.Future<_i3.Account?>.value())
          as _i9.Future<_i3.Account?>);
  @override
  _i9.Future<_i3.Account?> selectFirstAccount() =>
      (super.noSuchMethod(Invocation.method(#selectFirstAccount, []),
              returnValue: _i9.Future<_i3.Account?>.value())
          as _i9.Future<_i3.Account?>);
  @override
  _i9.Future<_i3.TransactableAccount?> selectAccount({String? id}) =>
      (super.noSuchMethod(Invocation.method(#selectAccount, [], {#id: id}),
              returnValue: _i9.Future<_i3.TransactableAccount?>.value())
          as _i9.Future<_i3.TransactableAccount?>);
  @override
  _i9.Future<_i3.TransactableAccount?> getSelectedAccount() =>
      (super.noSuchMethod(Invocation.method(#getSelectedAccount, []),
              returnValue: _i9.Future<_i3.TransactableAccount?>.value())
          as _i9.Future<_i3.TransactableAccount?>);
  @override
  _i9.Future<List<_i3.Account>> getAccounts() =>
      (super.noSuchMethod(Invocation.method(#getAccounts, []),
              returnValue: _i9.Future<List<_i3.Account>>.value(<_i3.Account>[]))
          as _i9.Future<List<_i3.Account>>);
  @override
  _i9.Future<List<_i3.BasicAccount>> getBasicAccounts() => (super.noSuchMethod(
          Invocation.method(#getBasicAccounts, []),
          returnValue:
              _i9.Future<List<_i3.BasicAccount>>.value(<_i3.BasicAccount>[]))
      as _i9.Future<List<_i3.BasicAccount>>);
  @override
  _i9.Future<List<_i3.TransactableAccount>> getTransactableAccounts() =>
      (super.noSuchMethod(Invocation.method(#getTransactableAccounts, []),
              returnValue: _i9.Future<List<_i3.TransactableAccount>>.value(
                  <_i3.TransactableAccount>[]))
          as _i9.Future<List<_i3.TransactableAccount>>);
  @override
  _i9.Future<_i3.Account> renameAccount({String? id, String? name}) =>
      (super.noSuchMethod(
              Invocation.method(#renameAccount, [], {#id: id, #name: name}),
              returnValue: _i9.Future<_i3.Account>.value(_FakeAccount_1(
                  this,
                  Invocation.method(
                      #renameAccount, [], {#id: id, #name: name}))))
          as _i9.Future<_i3.Account>);
  @override
  _i9.Future<_i3.BasicAccount> addAccount(
          {List<String>? phrase, String? name, _i5.Coin? coin}) =>
      (super.noSuchMethod(
              Invocation.method(
                  #addAccount, [], {#phrase: phrase, #name: name, #coin: coin}),
              returnValue: _i9.Future<_i3.BasicAccount>.value(_FakeBasicAccount_2(
                  this,
                  Invocation.method(#addAccount, [], {#phrase: phrase, #name: name, #coin: coin}))))
          as _i9.Future<_i3.BasicAccount>);
  @override
  _i9.Future<_i3.MultiAccount> addMultiAccount(
          {String? name,
          _i5.Coin? coin,
          String? linkedAccountId,
          String? remoteId,
          int? cosignerCount,
          int? signaturesRequired,
          List<String>? inviteIds,
          List<_i12.MultiSigSigner>? signers}) =>
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
          returnValue: _i9.Future<_i3.MultiAccount>.value(_FakeMultiAccount_3(
              this,
              Invocation.method(#addMultiAccount, [], {
                #name: name,
                #coin: coin,
                #linkedAccountId: linkedAccountId,
                #remoteId: remoteId,
                #cosignerCount: cosignerCount,
                #signaturesRequired: signaturesRequired,
                #inviteIds: inviteIds,
                #signers: signers
              })))) as _i9.Future<_i3.MultiAccount>);
  @override
  _i9.Future<_i3.MultiTransactableAccount> activateMultiAccount(
          {String? id, List<_i12.MultiSigSigner>? signers}) =>
      (super.noSuchMethod(Invocation.method(#activateMultiAccount, [], {#id: id, #signers: signers}),
          returnValue: _i9.Future<_i3.MultiTransactableAccount>.value(
              _FakeMultiTransactableAccount_4(
                  this,
                  Invocation.method(#activateMultiAccount, [], {
                    #id: id,
                    #signers: signers
                  })))) as _i9.Future<_i3.MultiTransactableAccount>);
  @override
  _i9.Future<_i3.Account?> removeAccount({String? id}) =>
      (super.noSuchMethod(Invocation.method(#removeAccount, [], {#id: id}),
              returnValue: _i9.Future<_i3.Account?>.value())
          as _i9.Future<_i3.Account?>);
  @override
  _i9.Future<List<_i3.Account>> resetAccounts() =>
      (super.noSuchMethod(Invocation.method(#resetAccounts, []),
              returnValue: _i9.Future<List<_i3.Account>>.value(<_i3.Account>[]))
          as _i9.Future<List<_i3.Account>>);
  @override
  _i9.Future<_i5.PrivateKey> loadKey(String? accountId) =>
      (super.noSuchMethod(Invocation.method(#loadKey, [accountId]),
              returnValue: _i9.Future<_i5.PrivateKey>.value(_FakePrivateKey_5(
                  this, Invocation.method(#loadKey, [accountId]))))
          as _i9.Future<_i5.PrivateKey>);
  @override
  _i9.Future<bool> isValidWalletConnectData(String? qrData) => (super
      .noSuchMethod(Invocation.method(#isValidWalletConnectData, [qrData]),
          returnValue: _i9.Future<bool>.value(false)) as _i9.Future<bool>);
}

/// A class which mocks [TransactionHandler].
///
/// See the documentation for Mockito's code generation for more information.
class MockTransactionHandler extends _i1.Mock
    implements _i13.TransactionHandler {
  MockTransactionHandler() {
    _i1.throwOnMissingStub(this);
  }

  @override
  _i9.Stream<_i13.TransactionResponse> get transaction =>
      (super.noSuchMethod(Invocation.getter(#transaction),
              returnValue: _i9.Stream<_i13.TransactionResponse>.empty())
          as _i9.Stream<_i13.TransactionResponse>);
  @override
  _i9.Future<_i6.GasFeeEstimate> estimateGas(
          _i7.TxBody? txBody, List<_i5.IPubKey>? signers, _i5.Coin? coin,
          {double? gasAdjustment}) =>
      (super.noSuchMethod(Invocation.method(#estimateGas, [txBody, signers, coin], {#gasAdjustment: gasAdjustment}),
          returnValue: _i9.Future<_i6.GasFeeEstimate>.value(_FakeGasFeeEstimate_6(
              this,
              Invocation.method(#estimateGas, [txBody, signers, coin],
                  {#gasAdjustment: gasAdjustment})))) as _i9.Future<_i6.GasFeeEstimate>);
  @override
  _i9.Future<_i7.RawTxResponsePair> executeTransaction(
          _i7.TxBody? txBody, _i5.IPrivKey? privateKey, _i5.Coin? coin,
          [_i6.GasFeeEstimate? gasEstimate]) =>
      (super.noSuchMethod(Invocation.method(#executeTransaction, [txBody, privateKey, coin, gasEstimate]),
              returnValue: _i9.Future<_i7.RawTxResponsePair>.value(_FakeRawTxResponsePair_7(
                  this,
                  Invocation.method(
                      #executeTransaction, [txBody, privateKey, coin, gasEstimate]))))
          as _i9.Future<_i7.RawTxResponsePair>);
}
