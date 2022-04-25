// Mocks generated by Mockito 5.1.0 from annotations
// in provenance_wallet/test/services/wallet_storage_service_imp_test.dart.
// Do not manually edit this file.

import 'dart:async' as _i3;

import 'package:mockito/mockito.dart' as _i1;
import 'package:prov_wallet_flutter/src/biometry_type.dart' as _i7;
import 'package:prov_wallet_flutter/src/cipher_service.dart' as _i6;
import 'package:provenance_blockchain_wallet/services/models/wallet_details.dart'
    as _i4;
import 'package:provenance_blockchain_wallet/services/sqlite_wallet_storage_service.dart'
    as _i2;
import 'package:provenance_blockchain_wallet/services/wallet_service/wallet_storage_service.dart'
    as _i5;

// ignore_for_file: type=lint
// ignore_for_file: avoid_redundant_argument_values
// ignore_for_file: avoid_setters_without_getters
// ignore_for_file: comment_references
// ignore_for_file: implementation_imports
// ignore_for_file: invalid_use_of_visible_for_testing_member
// ignore_for_file: prefer_const_constructors
// ignore_for_file: unnecessary_parenthesis
// ignore_for_file: camel_case_types

/// A class which mocks [SqliteWalletStorageService].
///
/// See the documentation for Mockito's code generation for more information.
class MockSqliteWalletStorageService extends _i1.Mock
    implements _i2.SqliteWalletStorageService {
  MockSqliteWalletStorageService() {
    _i1.throwOnMissingStub(this);
  }

  @override
  _i3.Future<List<_i4.WalletDetails>> getWallets() =>
      (super.noSuchMethod(Invocation.method(#getWallets, []),
              returnValue:
                  Future<List<_i4.WalletDetails>>.value(<_i4.WalletDetails>[]))
          as _i3.Future<List<_i4.WalletDetails>>);
  @override
  _i3.Future<_i4.WalletDetails?> getWallet({String? id}) =>
      (super.noSuchMethod(Invocation.method(#getWallet, [], {#id: id}),
              returnValue: Future<_i4.WalletDetails?>.value())
          as _i3.Future<_i4.WalletDetails?>);
  @override
  _i3.Future<_i4.WalletDetails?> getSelectedWallet() =>
      (super.noSuchMethod(Invocation.method(#getSelectedWallet, []),
              returnValue: Future<_i4.WalletDetails?>.value())
          as _i3.Future<_i4.WalletDetails?>);
  @override
  _i3.Future<_i4.WalletDetails?> selectWallet({String? id}) =>
      (super.noSuchMethod(Invocation.method(#selectWallet, [], {#id: id}),
              returnValue: Future<_i4.WalletDetails?>.value())
          as _i3.Future<_i4.WalletDetails?>);
  @override
  _i3.Future<_i4.WalletDetails?> renameWallet({String? id, String? name}) =>
      (super.noSuchMethod(
              Invocation.method(#renameWallet, [], {#id: id, #name: name}),
              returnValue: Future<_i4.WalletDetails?>.value())
          as _i3.Future<_i4.WalletDetails?>);
  @override
  _i3.Future<_i4.WalletDetails?> setChainId({String? id, String? chainId}) =>
      (super.noSuchMethod(
              Invocation.method(#setChainId, [], {#id: id, #chainId: chainId}),
              returnValue: Future<_i4.WalletDetails?>.value())
          as _i3.Future<_i4.WalletDetails?>);
  @override
  _i3.Future<_i4.WalletDetails?> addWallet(
          {String? name,
          List<_i5.PublicKeyData>? publicKeys,
          String? selectedChainId}) =>
      (super.noSuchMethod(
              Invocation.method(#addWallet, [], {
                #name: name,
                #publicKeys: publicKeys,
                #selectedChainId: selectedChainId
              }),
              returnValue: Future<_i4.WalletDetails?>.value())
          as _i3.Future<_i4.WalletDetails?>);
  @override
  _i3.Future<int> removeWallet({String? id}) =>
      (super.noSuchMethod(Invocation.method(#removeWallet, [], {#id: id}),
          returnValue: Future<int>.value(0)) as _i3.Future<int>);
  @override
  _i3.Future<int> removeAllWallets() =>
      (super.noSuchMethod(Invocation.method(#removeAllWallets, []),
          returnValue: Future<int>.value(0)) as _i3.Future<int>);
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
  _i3.Future<_i7.BiometryType> getBiometryType() => (super.noSuchMethod(
          Invocation.method(#getBiometryType, []),
          returnValue: Future<_i7.BiometryType>.value(_i7.BiometryType.none))
      as _i3.Future<_i7.BiometryType>);
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
  _i3.Future<bool> reset() => (super.noSuchMethod(Invocation.method(#reset, []),
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
