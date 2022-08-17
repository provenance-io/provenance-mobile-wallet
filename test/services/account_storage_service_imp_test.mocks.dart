// Mocks generated by Mockito 5.1.0 from annotations
// in provenance_wallet/test/services/account_storage_service_imp_test.dart.
// Do not manually edit this file.

import 'dart:async' as _i3;

import 'package:mockito/mockito.dart' as _i1;
import 'package:prov_wallet_flutter/src/biometry_type.dart' as _i8;
import 'package:prov_wallet_flutter/src/cipher_service.dart' as _i6;
import 'package:prov_wallet_flutter/src/cipher_service_error.dart' as _i7;
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
          returnValue: Future<int>.value(0)) as _i3.Future<int>);
  @override
  _i3.Future<_i4.BasicAccount?> addBasicAccount(
          {String? name,
          List<_i5.PublicKeyData>? publicKeys,
          String? selectedChainId}) =>
      (super.noSuchMethod(
              Invocation.method(#addBasicAccount, [], {
                #name: name,
                #publicKeys: publicKeys,
                #selectedChainId: selectedChainId
              }),
              returnValue: Future<_i4.BasicAccount?>.value())
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
          String? address}) =>
      (super.noSuchMethod(
              Invocation.method(#addMultiAccount, [], {
                #name: name,
                #selectedChainId: selectedChainId,
                #linkedAccountId: linkedAccountId,
                #remoteId: remoteId,
                #cosignerCount: cosignerCount,
                #signaturesRequired: signaturesRequired,
                #inviteIds: inviteIds,
                #address: address
              }),
              returnValue: Future<_i4.MultiAccount?>.value())
          as _i3.Future<_i4.MultiAccount?>);
  @override
  _i3.Future<_i4.MultiAccount?> setMultiAccountAddress(
          {String? id, String? address}) =>
      (super.noSuchMethod(
              Invocation.method(
                  #setMultiAccountAddress, [], {#id: id, #address: address}),
              returnValue: Future<_i4.MultiAccount?>.value())
          as _i3.Future<_i4.MultiAccount?>);
  @override
  _i3.Future<_i4.Account?> getAccount({String? id}) => (super.noSuchMethod(
      Invocation.method(#getAccount, [], {#id: id}),
      returnValue: Future<_i4.Account?>.value()) as _i3.Future<_i4.Account?>);
  @override
  _i3.Future<_i4.BasicAccount?> getBasicAccount({String? id}) =>
      (super.noSuchMethod(Invocation.method(#getBasicAccount, [], {#id: id}),
              returnValue: Future<_i4.BasicAccount?>.value())
          as _i3.Future<_i4.BasicAccount?>);
  @override
  _i3.Future<_i4.MultiAccount?> getMultiAccount({String? id}) =>
      (super.noSuchMethod(Invocation.method(#getMultiAccount, [], {#id: id}),
              returnValue: Future<_i4.MultiAccount?>.value())
          as _i3.Future<_i4.MultiAccount?>);
  @override
  _i3.Future<List<_i4.Account>> getAccounts() =>
      (super.noSuchMethod(Invocation.method(#getAccounts, []),
              returnValue: Future<List<_i4.Account>>.value(<_i4.Account>[]))
          as _i3.Future<List<_i4.Account>>);
  @override
  _i3.Future<List<_i4.BasicAccount>> getBasicAccounts() =>
      (super.noSuchMethod(Invocation.method(#getBasicAccounts, []),
              returnValue:
                  Future<List<_i4.BasicAccount>>.value(<_i4.BasicAccount>[]))
          as _i3.Future<List<_i4.BasicAccount>>);
  @override
  _i3.Future<List<_i4.MultiAccount>> getMultiAccounts() =>
      (super.noSuchMethod(Invocation.method(#getMultiAccounts, []),
              returnValue:
                  Future<List<_i4.MultiAccount>>.value(<_i4.MultiAccount>[]))
          as _i3.Future<List<_i4.MultiAccount>>);
  @override
  _i3.Future<_i4.TransactableAccount?> getSelectedAccount() =>
      (super.noSuchMethod(Invocation.method(#getSelectedAccount, []),
              returnValue: Future<_i4.TransactableAccount?>.value())
          as _i3.Future<_i4.TransactableAccount?>);
  @override
  _i3.Future<int> removeAccount({String? id}) =>
      (super.noSuchMethod(Invocation.method(#removeAccount, [], {#id: id}),
          returnValue: Future<int>.value(0)) as _i3.Future<int>);
  @override
  _i3.Future<int> removeAllAccounts() =>
      (super.noSuchMethod(Invocation.method(#removeAllAccounts, []),
          returnValue: Future<int>.value(0)) as _i3.Future<int>);
  @override
  _i3.Future<_i4.Account?> renameAccount({String? id, String? name}) =>
      (super.noSuchMethod(
              Invocation.method(#renameAccount, [], {#id: id, #name: name}),
              returnValue: Future<_i4.Account?>.value())
          as _i3.Future<_i4.Account?>);
  @override
  _i3.Future<_i4.TransactableAccount?> selectAccount({String? id}) =>
      (super.noSuchMethod(Invocation.method(#selectAccount, [], {#id: id}),
              returnValue: Future<_i4.TransactableAccount?>.value())
          as _i3.Future<_i4.TransactableAccount?>);
  @override
  _i3.Future<_i4.Account?> setChainId({String? id, String? chainId}) =>
      (super.noSuchMethod(
              Invocation.method(#setChainId, [], {#id: id, #chainId: chainId}),
              returnValue: Future<_i4.Account?>.value())
          as _i3.Future<_i4.Account?>);
}

/// A class which mocks [CipherService].
///
/// See the documentation for Mockito's code generation for more information.
class MockCipherService extends _i1.Mock implements _i6.CipherService {
  MockCipherService() {
    _i1.throwOnMissingStub(this);
  }

  @override
  _i3.Future<String?> get platformVersion =>
      (super.noSuchMethod(Invocation.getter(#platformVersion),
          returnValue: Future<String?>.value()) as _i3.Future<String?>);
  @override
  _i3.Stream<_i7.CipherServiceError> get error =>
      (super.noSuchMethod(Invocation.getter(#error),
              returnValue: Stream<_i7.CipherServiceError>.empty())
          as _i3.Stream<_i7.CipherServiceError>);
  @override
  _i3.Future<_i8.BiometryType> getBiometryType() => (super.noSuchMethod(
          Invocation.method(#getBiometryType, []),
          returnValue: Future<_i8.BiometryType>.value(_i8.BiometryType.none))
      as _i3.Future<_i8.BiometryType>);
  @override
  _i3.Future<bool> getLockScreenEnabled() =>
      (super.noSuchMethod(Invocation.method(#getLockScreenEnabled, []),
          returnValue: Future<bool>.value(false)) as _i3.Future<bool>);
  @override
  _i3.Future<bool> authenticateBiometry() =>
      (super.noSuchMethod(Invocation.method(#authenticateBiometry, []),
          returnValue: Future<bool>.value(false)) as _i3.Future<bool>);
  @override
  _i3.Future<bool> resetAuth() =>
      (super.noSuchMethod(Invocation.method(#resetAuth, []),
          returnValue: Future<bool>.value(false)) as _i3.Future<bool>);
  @override
  _i3.Future<bool?> getUseBiometry() =>
      (super.noSuchMethod(Invocation.method(#getUseBiometry, []),
          returnValue: Future<bool?>.value()) as _i3.Future<bool?>);
  @override
  _i3.Future<bool> setUseBiometry({bool? useBiometry}) => (super.noSuchMethod(
      Invocation.method(#setUseBiometry, [], {#useBiometry: useBiometry}),
      returnValue: Future<bool>.value(false)) as _i3.Future<bool>);
  @override
  _i3.Future<bool> encryptKey({String? id, String? privateKey}) =>
      (super.noSuchMethod(
          Invocation.method(
              #encryptKey, [], {#id: id, #privateKey: privateKey}),
          returnValue: Future<bool>.value(false)) as _i3.Future<bool>);
  @override
  _i3.Future<String?> decryptKey({String? id}) =>
      (super.noSuchMethod(Invocation.method(#decryptKey, [], {#id: id}),
          returnValue: Future<String?>.value()) as _i3.Future<String?>);
  @override
  _i3.Future<bool> removeKey({String? id}) =>
      (super.noSuchMethod(Invocation.method(#removeKey, [], {#id: id}),
          returnValue: Future<bool>.value(false)) as _i3.Future<bool>);
  @override
  _i3.Future<bool> resetKeys() =>
      (super.noSuchMethod(Invocation.method(#resetKeys, []),
          returnValue: Future<bool>.value(false)) as _i3.Future<bool>);
  @override
  _i3.Future<String?> getPin() =>
      (super.noSuchMethod(Invocation.method(#getPin, []),
          returnValue: Future<String?>.value()) as _i3.Future<String?>);
  @override
  _i3.Future<bool> setPin(String? pin) =>
      (super.noSuchMethod(Invocation.method(#setPin, [pin]),
          returnValue: Future<bool>.value(false)) as _i3.Future<bool>);
  @override
  _i3.Future<bool> deletePin() =>
      (super.noSuchMethod(Invocation.method(#deletePin, []),
          returnValue: Future<bool>.value(false)) as _i3.Future<bool>);
}
