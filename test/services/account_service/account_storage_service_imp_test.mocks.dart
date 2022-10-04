// Mocks generated by Mockito 5.3.0 from annotations
// in provenance_wallet/test/services/account_service/account_storage_service_imp_test.dart.
// Do not manually edit this file.

// ignore_for_file: no_leading_underscores_for_library_prefixes
import 'dart:async' as _i3;

import 'package:mockito/mockito.dart' as _i1;
import 'package:prov_wallet_flutter/src/biometry_type.dart' as _i9;
import 'package:prov_wallet_flutter/src/cipher_service.dart' as _i7;
import 'package:prov_wallet_flutter/src/cipher_service_error.dart' as _i8;
import 'package:provenance_wallet/clients/multi_sig_client/models/multi_sig_signer.dart'
    as _i6;
import 'package:provenance_wallet/services/account_service/account_storage_service.dart'
    as _i5;
import 'package:provenance_wallet/services/account_service/account_storage_service_core.dart'
    as _i2;
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

/// A class which mocks [AccountStorageServiceCore].
///
/// See the documentation for Mockito's code generation for more information.
class MockAccountStorageServiceCore extends _i1.Mock
    implements _i2.AccountStorageServiceCore {
  MockAccountStorageServiceCore() {
    _i1.throwOnMissingStub(this);
  }

  @override
  _i3.Future<int> getVersion() =>
      (super.noSuchMethod(Invocation.method(#getVersion, []),
          returnValue: _i3.Future<int>.value(0)) as _i3.Future<int>);
  @override
  _i3.Future<_i4.BasicAccount?> addBasicAccount(
          {String? name, _i5.PublicKeyData? publicKey}) =>
      (super.noSuchMethod(
              Invocation.method(
                  #addBasicAccount, [], {#name: name, #publicKey: publicKey}),
              returnValue: _i3.Future<_i4.BasicAccount?>.value())
          as _i3.Future<_i4.BasicAccount?>);
  @override
  _i3.Future<_i4.MultiAccount?> addMultiAccount(
          {String? name,
          String? selectedChainId,
          String? linkedAccountId,
          String? remoteId,
          int? cosignerCount,
          int? signaturesRequired,
          List<String>? inviteIds,
          String? address,
          List<_i6.MultiSigSigner>? signers}) =>
      (super.noSuchMethod(
              Invocation.method(#addMultiAccount, [], {
                #name: name,
                #selectedChainId: selectedChainId,
                #linkedAccountId: linkedAccountId,
                #remoteId: remoteId,
                #cosignerCount: cosignerCount,
                #signaturesRequired: signaturesRequired,
                #inviteIds: inviteIds,
                #address: address,
                #signers: signers
              }),
              returnValue: _i3.Future<_i4.MultiAccount?>.value())
          as _i3.Future<_i4.MultiAccount?>);
  @override
  _i3.Future<_i4.MultiAccount?> setMultiAccountSigners(
          {String? id, List<_i6.MultiSigSigner>? signers}) =>
      (super.noSuchMethod(
              Invocation.method(
                  #setMultiAccountSigners, [], {#id: id, #signers: signers}),
              returnValue: _i3.Future<_i4.MultiAccount?>.value())
          as _i3.Future<_i4.MultiAccount?>);
  @override
  _i3.Future<_i4.Account?> getAccount({String? id}) =>
      (super.noSuchMethod(Invocation.method(#getAccount, [], {#id: id}),
              returnValue: _i3.Future<_i4.Account?>.value())
          as _i3.Future<_i4.Account?>);
  @override
  _i3.Future<_i4.BasicAccount?> getBasicAccount({String? id}) =>
      (super.noSuchMethod(Invocation.method(#getBasicAccount, [], {#id: id}),
              returnValue: _i3.Future<_i4.BasicAccount?>.value())
          as _i3.Future<_i4.BasicAccount?>);
  @override
  _i3.Future<_i4.MultiAccount?> getMultiAccount({String? id}) =>
      (super.noSuchMethod(Invocation.method(#getMultiAccount, [], {#id: id}),
              returnValue: _i3.Future<_i4.MultiAccount?>.value())
          as _i3.Future<_i4.MultiAccount?>);
  @override
  _i3.Future<List<_i4.Account>> getAccounts() =>
      (super.noSuchMethod(Invocation.method(#getAccounts, []),
              returnValue: _i3.Future<List<_i4.Account>>.value(<_i4.Account>[]))
          as _i3.Future<List<_i4.Account>>);
  @override
  _i3.Future<List<_i4.BasicAccount>> getBasicAccounts() => (super.noSuchMethod(
          Invocation.method(#getBasicAccounts, []),
          returnValue:
              _i3.Future<List<_i4.BasicAccount>>.value(<_i4.BasicAccount>[]))
      as _i3.Future<List<_i4.BasicAccount>>);
  @override
  _i3.Future<List<_i4.MultiAccount>> getMultiAccounts() => (super.noSuchMethod(
          Invocation.method(#getMultiAccounts, []),
          returnValue:
              _i3.Future<List<_i4.MultiAccount>>.value(<_i4.MultiAccount>[]))
      as _i3.Future<List<_i4.MultiAccount>>);
  @override
  _i3.Future<_i4.TransactableAccount?> getSelectedAccount() =>
      (super.noSuchMethod(Invocation.method(#getSelectedAccount, []),
              returnValue: _i3.Future<_i4.TransactableAccount?>.value())
          as _i3.Future<_i4.TransactableAccount?>);
  @override
  _i3.Future<int> removeAccount({String? id}) =>
      (super.noSuchMethod(Invocation.method(#removeAccount, [], {#id: id}),
          returnValue: _i3.Future<int>.value(0)) as _i3.Future<int>);
  @override
  _i3.Future<int> removeAllAccounts() =>
      (super.noSuchMethod(Invocation.method(#removeAllAccounts, []),
          returnValue: _i3.Future<int>.value(0)) as _i3.Future<int>);
  @override
  _i3.Future<_i4.Account?> renameAccount({String? id, String? name}) =>
      (super.noSuchMethod(
              Invocation.method(#renameAccount, [], {#id: id, #name: name}),
              returnValue: _i3.Future<_i4.Account?>.value())
          as _i3.Future<_i4.Account?>);
  @override
  _i3.Future<_i4.TransactableAccount?> selectAccount({String? id}) =>
      (super.noSuchMethod(Invocation.method(#selectAccount, [], {#id: id}),
              returnValue: _i3.Future<_i4.TransactableAccount?>.value())
          as _i3.Future<_i4.TransactableAccount?>);
  @override
  _i3.Future<_i4.Account?> setChainId({String? id, String? chainId}) =>
      (super.noSuchMethod(
              Invocation.method(#setChainId, [], {#id: id, #chainId: chainId}),
              returnValue: _i3.Future<_i4.Account?>.value())
          as _i3.Future<_i4.Account?>);
}

/// A class which mocks [CipherService].
///
/// See the documentation for Mockito's code generation for more information.
class MockCipherService extends _i1.Mock implements _i7.CipherService {
  MockCipherService() {
    _i1.throwOnMissingStub(this);
  }

  @override
  _i3.Future<String?> get platformVersion =>
      (super.noSuchMethod(Invocation.getter(#platformVersion),
          returnValue: _i3.Future<String?>.value()) as _i3.Future<String?>);
  @override
  _i3.Stream<_i8.CipherServiceError> get error =>
      (super.noSuchMethod(Invocation.getter(#error),
              returnValue: _i3.Stream<_i8.CipherServiceError>.empty())
          as _i3.Stream<_i8.CipherServiceError>);
  @override
  _i3.Future<_i9.BiometryType> getBiometryType() =>
      (super.noSuchMethod(Invocation.method(#getBiometryType, []),
              returnValue:
                  _i3.Future<_i9.BiometryType>.value(_i9.BiometryType.none))
          as _i3.Future<_i9.BiometryType>);
  @override
  _i3.Future<bool> getLockScreenEnabled() =>
      (super.noSuchMethod(Invocation.method(#getLockScreenEnabled, []),
          returnValue: _i3.Future<bool>.value(false)) as _i3.Future<bool>);
  @override
  _i3.Future<bool> authenticateBiometry() =>
      (super.noSuchMethod(Invocation.method(#authenticateBiometry, []),
          returnValue: _i3.Future<bool>.value(false)) as _i3.Future<bool>);
  @override
  _i3.Future<bool> resetAuth() =>
      (super.noSuchMethod(Invocation.method(#resetAuth, []),
          returnValue: _i3.Future<bool>.value(false)) as _i3.Future<bool>);
  @override
  _i3.Future<bool?> getUseBiometry() =>
      (super.noSuchMethod(Invocation.method(#getUseBiometry, []),
          returnValue: _i3.Future<bool?>.value()) as _i3.Future<bool?>);
  @override
  _i3.Future<bool> setUseBiometry({bool? useBiometry}) => (super.noSuchMethod(
      Invocation.method(#setUseBiometry, [], {#useBiometry: useBiometry}),
      returnValue: _i3.Future<bool>.value(false)) as _i3.Future<bool>);
  @override
  _i3.Future<bool> encryptKey({String? id, String? privateKey}) =>
      (super.noSuchMethod(
          Invocation.method(
              #encryptKey, [], {#id: id, #privateKey: privateKey}),
          returnValue: _i3.Future<bool>.value(false)) as _i3.Future<bool>);
  @override
  _i3.Future<String?> decryptKey({String? id}) =>
      (super.noSuchMethod(Invocation.method(#decryptKey, [], {#id: id}),
          returnValue: _i3.Future<String?>.value()) as _i3.Future<String?>);
  @override
  _i3.Future<bool> removeKey({String? id}) =>
      (super.noSuchMethod(Invocation.method(#removeKey, [], {#id: id}),
          returnValue: _i3.Future<bool>.value(false)) as _i3.Future<bool>);
  @override
  _i3.Future<bool> resetKeys() =>
      (super.noSuchMethod(Invocation.method(#resetKeys, []),
          returnValue: _i3.Future<bool>.value(false)) as _i3.Future<bool>);
  @override
  _i3.Future<String?> getPin() =>
      (super.noSuchMethod(Invocation.method(#getPin, []),
          returnValue: _i3.Future<String?>.value()) as _i3.Future<String?>);
  @override
  _i3.Future<bool> setPin(String? pin) =>
      (super.noSuchMethod(Invocation.method(#setPin, [pin]),
          returnValue: _i3.Future<bool>.value(false)) as _i3.Future<bool>);
  @override
  _i3.Future<bool> deletePin() =>
      (super.noSuchMethod(Invocation.method(#deletePin, []),
          returnValue: _i3.Future<bool>.value(false)) as _i3.Future<bool>);
}
