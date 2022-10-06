// Mocks generated by Mockito 5.3.0 from annotations
// in provenance_wallet/test/screens/send_flow/send_review/send_review_bloc_test.dart.
// Do not manually edit this file.

// ignore_for_file: no_leading_underscores_for_library_prefixes
import 'dart:async' as _i6;

import 'package:mockito/mockito.dart' as _i1;
import 'package:provenance_dart/proto.dart' as _i10;
import 'package:provenance_dart/wallet.dart' as _i8;
import 'package:provenance_wallet/clients/multi_sig_client/models/multi_sig_signer.dart'
    as _i9;
import 'package:provenance_wallet/screens/send_flow/send_review/send_review_bloc.dart'
    as _i5;
import 'package:provenance_wallet/services/account_service/account_service.dart'
    as _i2;
import 'package:provenance_wallet/services/account_service/model/account_gas_estimate.dart'
    as _i3;
import 'package:provenance_wallet/services/models/account.dart' as _i7;
import 'package:provenance_wallet/services/tx_queue_service/tx_queue_service.dart'
    as _i4;

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

class _FakeScheduledTx_2 extends _i1.SmartFake implements _i4.ScheduledTx {
  _FakeScheduledTx_2(Object parent, Invocation parentInvocation)
      : super(parent, parentInvocation);
}

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
  _i6.Future<_i7.Account?> getAccount(String? id) =>
      (super.noSuchMethod(Invocation.method(#getAccount, [id]),
              returnValue: _i6.Future<_i7.Account?>.value())
          as _i6.Future<_i7.Account?>);
  @override
  _i6.Future<_i7.Account?> selectFirstAccount() =>
      (super.noSuchMethod(Invocation.method(#selectFirstAccount, []),
              returnValue: _i6.Future<_i7.Account?>.value())
          as _i6.Future<_i7.Account?>);
  @override
  _i6.Future<_i7.TransactableAccount?> selectAccount({String? id}) =>
      (super.noSuchMethod(Invocation.method(#selectAccount, [], {#id: id}),
              returnValue: _i6.Future<_i7.TransactableAccount?>.value())
          as _i6.Future<_i7.TransactableAccount?>);
  @override
  _i6.Future<_i7.TransactableAccount?> getSelectedAccount() =>
      (super.noSuchMethod(Invocation.method(#getSelectedAccount, []),
              returnValue: _i6.Future<_i7.TransactableAccount?>.value())
          as _i6.Future<_i7.TransactableAccount?>);
  @override
  _i6.Future<List<_i7.Account>> getAccounts() =>
      (super.noSuchMethod(Invocation.method(#getAccounts, []),
              returnValue: _i6.Future<List<_i7.Account>>.value(<_i7.Account>[]))
          as _i6.Future<List<_i7.Account>>);
  @override
  _i6.Future<List<_i7.BasicAccount>> getBasicAccounts() => (super.noSuchMethod(
          Invocation.method(#getBasicAccounts, []),
          returnValue:
              _i6.Future<List<_i7.BasicAccount>>.value(<_i7.BasicAccount>[]))
      as _i6.Future<List<_i7.BasicAccount>>);
  @override
  _i6.Future<List<_i7.TransactableAccount>> getTransactableAccounts() =>
      (super.noSuchMethod(Invocation.method(#getTransactableAccounts, []),
              returnValue: _i6.Future<List<_i7.TransactableAccount>>.value(
                  <_i7.TransactableAccount>[]))
          as _i6.Future<List<_i7.TransactableAccount>>);
  @override
  _i6.Future<_i7.Account?> renameAccount({String? id, String? name}) =>
      (super.noSuchMethod(
              Invocation.method(#renameAccount, [], {#id: id, #name: name}),
              returnValue: _i6.Future<_i7.Account?>.value())
          as _i6.Future<_i7.Account?>);
  @override
  _i6.Future<_i7.Account?> addAccount(
          {List<String>? phrase, String? name, _i8.Coin? coin}) =>
      (super.noSuchMethod(
              Invocation.method(
                  #addAccount, [], {#phrase: phrase, #name: name, #coin: coin}),
              returnValue: _i6.Future<_i7.Account?>.value())
          as _i6.Future<_i7.Account?>);
  @override
  _i6.Future<_i7.MultiAccount?> addMultiAccount(
          {String? name,
          _i8.Coin? coin,
          String? linkedAccountId,
          String? remoteId,
          int? cosignerCount,
          int? signaturesRequired,
          List<String>? inviteIds,
          List<_i9.MultiSigSigner>? signers}) =>
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
              returnValue: _i6.Future<_i7.MultiAccount?>.value())
          as _i6.Future<_i7.MultiAccount?>);
  @override
  _i6.Future<_i7.MultiTransactableAccount?> activateMultiAccount(
          {String? id, List<_i9.MultiSigSigner>? signers}) =>
      (super.noSuchMethod(
              Invocation.method(
                  #activateMultiAccount, [], {#id: id, #signers: signers}),
              returnValue: _i6.Future<_i7.MultiTransactableAccount?>.value())
          as _i6.Future<_i7.MultiTransactableAccount?>);
  @override
  _i6.Future<_i7.Account?> removeAccount({String? id}) =>
      (super.noSuchMethod(Invocation.method(#removeAccount, [], {#id: id}),
              returnValue: _i6.Future<_i7.Account?>.value())
          as _i6.Future<_i7.Account?>);
  @override
  _i6.Future<List<_i7.Account>> resetAccounts() =>
      (super.noSuchMethod(Invocation.method(#resetAccounts, []),
              returnValue: _i6.Future<List<_i7.Account>>.value(<_i7.Account>[]))
          as _i6.Future<List<_i7.Account>>);
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

/// A class which mocks [TxQueueService].
///
/// See the documentation for Mockito's code generation for more information.
class MockTxQueueService extends _i1.Mock implements _i4.TxQueueService {
  MockTxQueueService() {
    _i1.throwOnMissingStub(this);
  }

  @override
  _i6.Stream<_i4.TxResult> get response =>
      (super.noSuchMethod(Invocation.getter(#response),
              returnValue: _i6.Stream<_i4.TxResult>.empty())
          as _i6.Stream<_i4.TxResult>);
  @override
  _i6.Future<_i3.AccountGasEstimate> estimateGas(
          {_i10.TxBody? txBody, _i7.TransactableAccount? account}) =>
      (super.noSuchMethod(
              Invocation.method(
                  #estimateGas, [], {#txBody: txBody, #account: account}),
              returnValue: _i6.Future<_i3.AccountGasEstimate>.value(
                  _FakeAccountGasEstimate_1(this,
                      Invocation.method(#estimateGas, [], {#txBody: txBody, #account: account}))))
          as _i6.Future<_i3.AccountGasEstimate>);
  @override
  _i6.Future<_i4.ScheduledTx> scheduleTx(
          {_i10.TxBody? txBody,
          _i7.TransactableAccount? account,
          _i3.AccountGasEstimate? gasEstimate}) =>
      (super
          .noSuchMethod(Invocation.method(#scheduleTx, [], {#txBody: txBody, #account: account, #gasEstimate: gasEstimate}),
              returnValue: _i6.Future<_i4.ScheduledTx>.value(_FakeScheduledTx_2(
                  this,
                  Invocation.method(#scheduleTx, [], {
                    #txBody: txBody,
                    #account: account,
                    #gasEstimate: gasEstimate
                  })))) as _i6.Future<_i4.ScheduledTx>);
  @override
  _i6.Future<void> completeTx({String? txId}) => (super.noSuchMethod(
      Invocation.method(#completeTx, [], {#txId: txId}),
      returnValue: _i6.Future<void>.value(),
      returnValueForMissingStub: _i6.Future<void>.value()) as _i6.Future<void>);
  @override
  _i6.Future<bool> signTx(
          {String? txId,
          String? signerAddress,
          String? multiSigAddress,
          _i10.TxBody? txBody,
          _i10.Fee? fee}) =>
      (super.noSuchMethod(
          Invocation.method(#signTx, [], {
            #txId: txId,
            #signerAddress: signerAddress,
            #multiSigAddress: multiSigAddress,
            #txBody: txBody,
            #fee: fee
          }),
          returnValue: _i6.Future<bool>.value(false)) as _i6.Future<bool>);
  @override
  _i6.Future<bool> declineTx(
          {String? signerAddress, String? txId, _i8.Coin? coin}) =>
      (super.noSuchMethod(
          Invocation.method(#declineTx, [],
              {#signerAddress: signerAddress, #txId: txId, #coin: coin}),
          returnValue: _i6.Future<bool>.value(false)) as _i6.Future<bool>);
}
