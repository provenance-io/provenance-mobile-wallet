// Mocks generated by Mockito 5.3.0 from annotations
// in provenance_wallet/test/screens/send_flow/send_review/send_review_bloc_test.dart.
// Do not manually edit this file.

// ignore_for_file: no_leading_underscores_for_library_prefixes
import 'dart:async' as _i9;

import 'package:flutter/widgets.dart' as _i4;
import 'package:mockito/mockito.dart' as _i1;
import 'package:provenance_dart/proto.dart' as _i12;
import 'package:provenance_dart/wallet.dart' as _i5;
import 'package:provenance_wallet/clients/multi_sig_client/models/multi_sig_signer.dart'
    as _i11;
import 'package:provenance_wallet/gas_fee_estimate.dart' as _i6;
import 'package:provenance_wallet/network.dart' as _i10;
import 'package:provenance_wallet/screens/send_flow/send_review/send_review_bloc.dart'
    as _i8;
import 'package:provenance_wallet/services/account_service/account_service.dart'
    as _i2;
import 'package:provenance_wallet/services/models/account.dart' as _i3;
import 'package:provenance_wallet/services/tx_queue_service/tx_queue_service.dart'
    as _i7;

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

class _FakeQueuedTx_7 extends _i1.SmartFake implements _i7.QueuedTx {
  _FakeQueuedTx_7(Object parent, Invocation parentInvocation)
      : super(parent, parentInvocation);
}

/// A class which mocks [SendReviewNaviagor].
///
/// See the documentation for Mockito's code generation for more information.
class MockSendReviewNaviagor extends _i1.Mock
    implements _i8.SendReviewNaviagor {
  MockSendReviewNaviagor() {
    _i1.throwOnMissingStub(this);
  }

  @override
  void complete() => super.noSuchMethod(Invocation.method(#complete, []),
      returnValueForMissingStub: null);
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
  _i9.Future<_i3.Account> selectNetwork(
          {String? accountId, _i10.Network? network}) =>
      (super.noSuchMethod(
              Invocation.method(
                  #selectNetwork, [], {#accountId: accountId, #network: network}),
              returnValue: _i9.Future<_i3.Account>.value(_FakeAccount_1(this,
                  Invocation.method(#selectNetwork, [], {#accountId: accountId, #network: network}))))
          as _i9.Future<_i3.Account>);
  @override
  _i9.Future<_i3.BasicAccount> addAccount(
          {List<String>? phrase, String? name, _i10.Network? network}) =>
      (super
          .noSuchMethod(Invocation.method(#addAccount, [], {#phrase: phrase, #name: name, #network: network}),
              returnValue: _i9.Future<_i3.BasicAccount>.value(
                  _FakeBasicAccount_2(
                      this,
                      Invocation.method(#addAccount, [], {
                        #phrase: phrase,
                        #name: name,
                        #network: network
                      })))) as _i9.Future<_i3.BasicAccount>);
  @override
  _i9.Future<_i3.MultiAccount> addMultiAccount(
          {String? name,
          _i5.Coin? coin,
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
          {String? id, List<_i11.MultiSigSigner>? signers}) =>
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
  _i9.Future<_i5.PrivateKey> loadKey(String? accountId, _i5.Coin? coin) =>
      (super.noSuchMethod(Invocation.method(#loadKey, [accountId, coin]),
              returnValue: _i9.Future<_i5.PrivateKey>.value(_FakePrivateKey_5(
                  this, Invocation.method(#loadKey, [accountId, coin]))))
          as _i9.Future<_i5.PrivateKey>);
}

/// A class which mocks [TxQueueService].
///
/// See the documentation for Mockito's code generation for more information.
class MockTxQueueService extends _i1.Mock implements _i7.TxQueueService {
  MockTxQueueService() {
    _i1.throwOnMissingStub(this);
  }

  @override
  _i9.Stream<_i7.TxResult> get response =>
      (super.noSuchMethod(Invocation.getter(#response),
              returnValue: _i9.Stream<_i7.TxResult>.empty())
          as _i9.Stream<_i7.TxResult>);
  @override
  _i9.Future<_i6.GasFeeEstimate> estimateGas(
          {_i12.TxBody? txBody,
          _i3.TransactableAccount? account,
          double? gasAdjustment}) =>
      (super.noSuchMethod(Invocation.method(#estimateGas, [], {#txBody: txBody, #account: account, #gasAdjustment: gasAdjustment}),
          returnValue: _i9.Future<_i6.GasFeeEstimate>.value(
              _FakeGasFeeEstimate_6(
                  this,
                  Invocation.method(#estimateGas, [], {
                    #txBody: txBody,
                    #account: account,
                    #gasAdjustment: gasAdjustment
                  })))) as _i9.Future<_i6.GasFeeEstimate>);
  @override
  _i9.Future<_i7.QueuedTx> scheduleTx(
          {_i12.TxBody? txBody,
          _i3.TransactableAccount? account,
          _i6.GasFeeEstimate? gasEstimate,
          int? walletConnectRequestId}) =>
      (super.noSuchMethod(
          Invocation.method(#scheduleTx, [], {
            #txBody: txBody,
            #account: account,
            #gasEstimate: gasEstimate,
            #walletConnectRequestId: walletConnectRequestId
          }),
          returnValue: _i9.Future<_i7.QueuedTx>.value(_FakeQueuedTx_7(
              this,
              Invocation.method(#scheduleTx, [], {
                #txBody: txBody,
                #account: account,
                #gasEstimate: gasEstimate,
                #walletConnectRequestId: walletConnectRequestId
              })))) as _i9.Future<_i7.QueuedTx>);
  @override
  _i9.Future<void> completeTx({String? txId}) => (super.noSuchMethod(
      Invocation.method(#completeTx, [], {#txId: txId}),
      returnValue: _i9.Future<void>.value(),
      returnValueForMissingStub: _i9.Future<void>.value()) as _i9.Future<void>);
  @override
  _i9.Future<bool> signTx(
          {String? txId,
          String? signerAddress,
          String? multiSigAddress,
          _i12.TxBody? txBody,
          _i12.Fee? fee}) =>
      (super.noSuchMethod(
          Invocation.method(#signTx, [], {
            #txId: txId,
            #signerAddress: signerAddress,
            #multiSigAddress: multiSigAddress,
            #txBody: txBody,
            #fee: fee
          }),
          returnValue: _i9.Future<bool>.value(false)) as _i9.Future<bool>);
  @override
  _i9.Future<bool> declineTx(
          {String? signerAddress, String? txId, _i5.Coin? coin}) =>
      (super.noSuchMethod(
          Invocation.method(#declineTx, [],
              {#signerAddress: signerAddress, #txId: txId, #coin: coin}),
          returnValue: _i9.Future<bool>.value(false)) as _i9.Future<bool>);
}
