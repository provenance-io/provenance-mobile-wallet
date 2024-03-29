// Mocks generated by Mockito 5.3.0 from annotations
// in provenance_wallet/test/screens/home/accounts/account_cell_test.dart.
// Do not manually edit this file.

// ignore_for_file: no_leading_underscores_for_library_prefixes
import 'dart:async' as _i8;

import 'package:flutter/widgets.dart' as _i5;
import 'package:mockito/mockito.dart' as _i1;
import 'package:provenance_dart/proto.dart' as _i11;
import 'package:provenance_dart/wallet.dart' as _i6;
import 'package:provenance_wallet/clients/multi_sig_client/dto/multi_sig_status.dart'
    as _i13;
import 'package:provenance_wallet/clients/multi_sig_client/models/multi_sig_pending_tx.dart'
    as _i12;
import 'package:provenance_wallet/clients/multi_sig_client/models/multi_sig_register_result.dart'
    as _i10;
import 'package:provenance_wallet/clients/multi_sig_client/models/multi_sig_remote_account.dart'
    as _i9;
import 'package:provenance_wallet/clients/multi_sig_client/models/multi_sig_signer.dart'
    as _i16;
import 'package:provenance_wallet/clients/multi_sig_client/models/multi_sig_update_result.dart'
    as _i14;
import 'package:provenance_wallet/clients/multi_sig_client/multi_sig_client.dart'
    as _i7;
import 'package:provenance_wallet/network.dart' as _i15;
import 'package:provenance_wallet/services/account_service/account_service.dart'
    as _i3;
import 'package:provenance_wallet/services/http_client.dart' as _i2;
import 'package:provenance_wallet/services/models/account.dart' as _i4;

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

class _FakeHttpClient_0 extends _i1.SmartFake implements _i2.HttpClient {
  _FakeHttpClient_0(Object parent, Invocation parentInvocation)
      : super(parent, parentInvocation);
}

class _FakeAccountServiceEvents_1 extends _i1.SmartFake
    implements _i3.AccountServiceEvents {
  _FakeAccountServiceEvents_1(Object parent, Invocation parentInvocation)
      : super(parent, parentInvocation);
}

class _FakeAccount_2 extends _i1.SmartFake implements _i4.Account {
  _FakeAccount_2(Object parent, Invocation parentInvocation)
      : super(parent, parentInvocation);
}

class _FakeBasicAccount_3 extends _i1.SmartFake implements _i4.BasicAccount {
  _FakeBasicAccount_3(Object parent, Invocation parentInvocation)
      : super(parent, parentInvocation);

  @override
  String toString({_i5.DiagnosticLevel? minLevel = _i5.DiagnosticLevel.info}) =>
      super.toString();
}

class _FakeMultiAccount_4 extends _i1.SmartFake implements _i4.MultiAccount {
  _FakeMultiAccount_4(Object parent, Invocation parentInvocation)
      : super(parent, parentInvocation);

  @override
  String toString({_i5.DiagnosticLevel? minLevel = _i5.DiagnosticLevel.info}) =>
      super.toString();
}

class _FakeMultiTransactableAccount_5 extends _i1.SmartFake
    implements _i4.MultiTransactableAccount {
  _FakeMultiTransactableAccount_5(Object parent, Invocation parentInvocation)
      : super(parent, parentInvocation);

  @override
  String toString({_i5.DiagnosticLevel? minLevel = _i5.DiagnosticLevel.info}) =>
      super.toString();
}

class _FakePrivateKey_6 extends _i1.SmartFake implements _i6.PrivateKey {
  _FakePrivateKey_6(Object parent, Invocation parentInvocation)
      : super(parent, parentInvocation);
}

/// A class which mocks [MultiSigClient].
///
/// See the documentation for Mockito's code generation for more information.
class MockMultiSigClient extends _i1.Mock implements _i7.MultiSigClient {
  MockMultiSigClient() {
    _i1.throwOnMissingStub(this);
  }

  @override
  _i8.Future<_i9.MultiSigRemoteAccount?> create(
          {String? name,
          int? cosignerCount,
          int? threshold,
          _i6.PublicKey? publicKey}) =>
      (super.noSuchMethod(
              Invocation.method(#create, [], {
                #name: name,
                #cosignerCount: cosignerCount,
                #threshold: threshold,
                #publicKey: publicKey
              }),
              returnValue: _i8.Future<_i9.MultiSigRemoteAccount?>.value())
          as _i8.Future<_i9.MultiSigRemoteAccount?>);
  @override
  _i8.Future<_i10.MultiSigRegisterResult?> register(
          {String? inviteId, _i6.PublicKey? publicKey}) =>
      (super.noSuchMethod(
              Invocation.method(
                  #register, [], {#inviteId: inviteId, #publicKey: publicKey}),
              returnValue: _i8.Future<_i10.MultiSigRegisterResult?>.value())
          as _i8.Future<_i10.MultiSigRegisterResult?>);
  @override
  _i8.Future<List<_i9.MultiSigRemoteAccount>?> getAccounts(
          {String? address, _i6.Coin? coin}) =>
      (super.noSuchMethod(
          Invocation.method(#getAccounts, [], {#address: address, #coin: coin}),
          returnValue:
              _i8.Future<List<_i9.MultiSigRemoteAccount>?>.value()) as _i8
          .Future<List<_i9.MultiSigRemoteAccount>?>);
  @override
  _i8.Future<_i9.MultiSigRemoteAccount?> getAccount(
          {String? remoteId, String? signerAddress, _i6.Coin? coin}) =>
      (super.noSuchMethod(
              Invocation.method(#getAccount, [], {
                #remoteId: remoteId,
                #signerAddress: signerAddress,
                #coin: coin
              }),
              returnValue: _i8.Future<_i9.MultiSigRemoteAccount?>.value())
          as _i8.Future<_i9.MultiSigRemoteAccount?>);
  @override
  _i8.Future<_i9.MultiSigRemoteAccount?> getAccountByInvite(
          {String? inviteId, _i6.Coin? coin}) =>
      (super.noSuchMethod(
              Invocation.method(
                  #getAccountByInvite, [], {#inviteId: inviteId, #coin: coin}),
              returnValue: _i8.Future<_i9.MultiSigRemoteAccount?>.value())
          as _i8.Future<_i9.MultiSigRemoteAccount?>);
  @override
  _i8.Future<String?> createTx(
          {String? multiSigAddress,
          String? signerAddress,
          _i6.Coin? coin,
          _i11.TxBody? txBody,
          _i11.Fee? fee,
          int? walletConnectRequestId}) =>
      (super.noSuchMethod(
          Invocation.method(#createTx, [], {
            #multiSigAddress: multiSigAddress,
            #signerAddress: signerAddress,
            #coin: coin,
            #txBody: txBody,
            #fee: fee,
            #walletConnectRequestId: walletConnectRequestId
          }),
          returnValue: _i8.Future<String?>.value()) as _i8.Future<String?>);
  @override
  _i8.Future<List<_i12.MultiSigPendingTx>> getPendingTxs(
          {List<_i7.SignerData>? signer}) =>
      (super.noSuchMethod(
              Invocation.method(#getPendingTxs, [], {#signer: signer}),
              returnValue: _i8.Future<List<_i12.MultiSigPendingTx>>.value(
                  <_i12.MultiSigPendingTx>[]))
          as _i8.Future<List<_i12.MultiSigPendingTx>>);
  @override
  _i8.Future<List<_i12.MultiSigPendingTx>> getCreatedTxs(
          {List<_i7.SignerData>? signers, _i13.MultiSigStatus? status}) =>
      (super.noSuchMethod(
              Invocation.method(
                  #getCreatedTxs, [], {#signers: signers, #status: status}),
              returnValue: _i8.Future<List<_i12.MultiSigPendingTx>>.value(
                  <_i12.MultiSigPendingTx>[]))
          as _i8.Future<List<_i12.MultiSigPendingTx>>);
  @override
  _i8.Future<bool> signTx(
          {String? signerAddress,
          _i6.Coin? coin,
          String? txUuid,
          String? signatureBytes,
          bool? declineTx}) =>
      (super.noSuchMethod(
          Invocation.method(#signTx, [], {
            #signerAddress: signerAddress,
            #coin: coin,
            #txUuid: txUuid,
            #signatureBytes: signatureBytes,
            #declineTx: declineTx
          }),
          returnValue: _i8.Future<bool>.value(false)) as _i8.Future<bool>);
  @override
  _i8.Future<_i14.MultiSigUpdateResult> updateTxResult(
          {String? txUuid, String? txHash, _i6.Coin? coin}) =>
      (super.noSuchMethod(
              Invocation.method(#updateTxResult, [],
                  {#txUuid: txUuid, #txHash: txHash, #coin: coin}),
              returnValue: _i8.Future<_i14.MultiSigUpdateResult>.value(
                  _i14.MultiSigUpdateResult.success))
          as _i8.Future<_i14.MultiSigUpdateResult>);
  @override
  _i8.Future<_i2.HttpClient> getClient(_i6.Coin? coin) => (super.noSuchMethod(
          Invocation.method(#getClient, [coin]),
          returnValue: _i8.Future<_i2.HttpClient>.value(
              _FakeHttpClient_0(this, Invocation.method(#getClient, [coin]))))
      as _i8.Future<_i2.HttpClient>);
}

/// A class which mocks [AccountService].
///
/// See the documentation for Mockito's code generation for more information.
class MockAccountService extends _i1.Mock implements _i3.AccountService {
  MockAccountService() {
    _i1.throwOnMissingStub(this);
  }

  @override
  _i3.AccountServiceEvents get events =>
      (super.noSuchMethod(Invocation.getter(#events),
              returnValue:
                  _FakeAccountServiceEvents_1(this, Invocation.getter(#events)))
          as _i3.AccountServiceEvents);
  @override
  _i8.Future<_i4.Account?> getAccount(String? id) =>
      (super.noSuchMethod(Invocation.method(#getAccount, [id]),
              returnValue: _i8.Future<_i4.Account?>.value())
          as _i8.Future<_i4.Account?>);
  @override
  _i8.Future<_i4.Account?> selectFirstAccount() =>
      (super.noSuchMethod(Invocation.method(#selectFirstAccount, []),
              returnValue: _i8.Future<_i4.Account?>.value())
          as _i8.Future<_i4.Account?>);
  @override
  _i8.Future<_i4.TransactableAccount?> selectAccount({String? id}) =>
      (super.noSuchMethod(Invocation.method(#selectAccount, [], {#id: id}),
              returnValue: _i8.Future<_i4.TransactableAccount?>.value())
          as _i8.Future<_i4.TransactableAccount?>);
  @override
  _i8.Future<_i4.TransactableAccount?> getSelectedAccount() =>
      (super.noSuchMethod(Invocation.method(#getSelectedAccount, []),
              returnValue: _i8.Future<_i4.TransactableAccount?>.value())
          as _i8.Future<_i4.TransactableAccount?>);
  @override
  _i8.Future<List<_i4.Account>> getAccounts() =>
      (super.noSuchMethod(Invocation.method(#getAccounts, []),
              returnValue: _i8.Future<List<_i4.Account>>.value(<_i4.Account>[]))
          as _i8.Future<List<_i4.Account>>);
  @override
  _i8.Future<List<_i4.BasicAccount>> getBasicAccounts() => (super.noSuchMethod(
          Invocation.method(#getBasicAccounts, []),
          returnValue:
              _i8.Future<List<_i4.BasicAccount>>.value(<_i4.BasicAccount>[]))
      as _i8.Future<List<_i4.BasicAccount>>);
  @override
  _i8.Future<List<_i4.TransactableAccount>> getTransactableAccounts() =>
      (super.noSuchMethod(Invocation.method(#getTransactableAccounts, []),
              returnValue: _i8.Future<List<_i4.TransactableAccount>>.value(
                  <_i4.TransactableAccount>[]))
          as _i8.Future<List<_i4.TransactableAccount>>);
  @override
  _i8.Future<_i4.Account> renameAccount({String? id, String? name}) =>
      (super.noSuchMethod(
              Invocation.method(#renameAccount, [], {#id: id, #name: name}),
              returnValue: _i8.Future<_i4.Account>.value(_FakeAccount_2(
                  this,
                  Invocation.method(
                      #renameAccount, [], {#id: id, #name: name}))))
          as _i8.Future<_i4.Account>);
  @override
  _i8.Future<_i4.Account> selectNetwork(
          {String? accountId, _i15.Network? network}) =>
      (super.noSuchMethod(
              Invocation.method(
                  #selectNetwork, [], {#accountId: accountId, #network: network}),
              returnValue: _i8.Future<_i4.Account>.value(_FakeAccount_2(this,
                  Invocation.method(#selectNetwork, [], {#accountId: accountId, #network: network}))))
          as _i8.Future<_i4.Account>);
  @override
  _i8.Future<_i4.BasicAccount> addAccount(
          {List<String>? phrase, String? name, _i15.Network? network}) =>
      (super
          .noSuchMethod(Invocation.method(#addAccount, [], {#phrase: phrase, #name: name, #network: network}),
              returnValue: _i8.Future<_i4.BasicAccount>.value(
                  _FakeBasicAccount_3(
                      this,
                      Invocation.method(#addAccount, [], {
                        #phrase: phrase,
                        #name: name,
                        #network: network
                      })))) as _i8.Future<_i4.BasicAccount>);
  @override
  _i8.Future<_i4.MultiAccount> addMultiAccount(
          {String? name,
          _i6.Coin? coin,
          String? linkedAccountId,
          String? remoteId,
          int? cosignerCount,
          int? signaturesRequired,
          List<String>? inviteIds,
          List<_i16.MultiSigSigner>? signers}) =>
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
          returnValue: _i8.Future<_i4.MultiAccount>.value(_FakeMultiAccount_4(
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
              })))) as _i8.Future<_i4.MultiAccount>);
  @override
  _i8.Future<_i4.MultiTransactableAccount> activateMultiAccount(
          {String? id, List<_i16.MultiSigSigner>? signers}) =>
      (super.noSuchMethod(Invocation.method(#activateMultiAccount, [], {#id: id, #signers: signers}),
          returnValue: _i8.Future<_i4.MultiTransactableAccount>.value(
              _FakeMultiTransactableAccount_5(
                  this,
                  Invocation.method(#activateMultiAccount, [], {
                    #id: id,
                    #signers: signers
                  })))) as _i8.Future<_i4.MultiTransactableAccount>);
  @override
  _i8.Future<_i4.Account?> removeAccount({String? id}) =>
      (super.noSuchMethod(Invocation.method(#removeAccount, [], {#id: id}),
              returnValue: _i8.Future<_i4.Account?>.value())
          as _i8.Future<_i4.Account?>);
  @override
  _i8.Future<List<_i4.Account>> resetAccounts() =>
      (super.noSuchMethod(Invocation.method(#resetAccounts, []),
              returnValue: _i8.Future<List<_i4.Account>>.value(<_i4.Account>[]))
          as _i8.Future<List<_i4.Account>>);
  @override
  _i8.Future<_i6.PrivateKey> loadKey(String? accountId, _i6.Coin? coin) =>
      (super.noSuchMethod(Invocation.method(#loadKey, [accountId, coin]),
              returnValue: _i8.Future<_i6.PrivateKey>.value(_FakePrivateKey_6(
                  this, Invocation.method(#loadKey, [accountId, coin]))))
          as _i8.Future<_i6.PrivateKey>);
}
