// Mocks generated by Mockito 5.1.0 from annotations
// in provenance_wallet/test/screens/send_flow/send_flow_test.dart.
// Do not manually edit this file.

import 'dart:async' as _i4;

import 'package:mockito/mockito.dart' as _i1;
import 'package:provenance_wallet/common/models/asset.dart' as _i5;
import 'package:provenance_wallet/common/models/transaction.dart' as _i7;
import 'package:provenance_wallet/network/services/asset_service.dart' as _i3;
import 'package:provenance_wallet/network/services/base_service.dart' as _i2;
import 'package:provenance_wallet/network/services/transaction_service.dart'
    as _i6;

// ignore_for_file: type=lint
// ignore_for_file: avoid_redundant_argument_values
// ignore_for_file: avoid_setters_without_getters
// ignore_for_file: comment_references
// ignore_for_file: implementation_imports
// ignore_for_file: invalid_use_of_visible_for_testing_member
// ignore_for_file: prefer_const_constructors
// ignore_for_file: unnecessary_parenthesis
// ignore_for_file: camel_case_types

class _FakeBaseResponse_0<T> extends _i1.Fake implements _i2.BaseResponse<T> {}

/// A class which mocks [AssetService].
///
/// See the documentation for Mockito's code generation for more information.
class MockAssetService extends _i1.Mock implements _i3.AssetService {
  MockAssetService() {
    _i1.throwOnMissingStub(this);
  }

  @override
  _i4.Future<_i2.BaseResponse<List<_i5.Asset>>> getAssets(
          String? provenanceAddresses) =>
      (super.noSuchMethod(Invocation.method(#getAssets, [provenanceAddresses]),
              returnValue: Future<_i2.BaseResponse<List<_i5.Asset>>>.value(
                  _FakeBaseResponse_0<List<_i5.Asset>>()))
          as _i4.Future<_i2.BaseResponse<List<_i5.Asset>>>);
  @override
  _i4.Future<List<_i5.Asset>> getFakeAssets(String? provenanceAddresses) =>
      (super.noSuchMethod(
              Invocation.method(#getFakeAssets, [provenanceAddresses]),
              returnValue: Future<List<_i5.Asset>>.value(<_i5.Asset>[]))
          as _i4.Future<List<_i5.Asset>>);
}

/// A class which mocks [TransactionService].
///
/// See the documentation for Mockito's code generation for more information.
class MockTransactionService extends _i1.Mock
    implements _i6.TransactionService {
  MockTransactionService() {
    _i1.throwOnMissingStub(this);
  }

  @override
  _i4.Future<_i2.BaseResponse<List<_i7.Transaction>>> getTransactions(
          String? provenanceAddress) =>
      (super.noSuchMethod(
          Invocation.method(#getTransactions, [provenanceAddress]),
          returnValue: Future<_i2.BaseResponse<List<_i7.Transaction>>>.value(
              _FakeBaseResponse_0<List<_i7.Transaction>>())) as _i4
          .Future<_i2.BaseResponse<List<_i7.Transaction>>>);
  @override
  _i4.Future<List<_i7.Transaction>> getFakeTransactions(
          String? provenanceAddresses) =>
      (super.noSuchMethod(
              Invocation.method(#getFakeTransactions, [provenanceAddresses]),
              returnValue:
                  Future<List<_i7.Transaction>>.value(<_i7.Transaction>[]))
          as _i4.Future<List<_i7.Transaction>>);
}
