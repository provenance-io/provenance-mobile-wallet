// Mocks generated by Mockito 5.3.0 from annotations
// in provenance_wallet/test/services/account_service/wallet_connect_transaction_handler_test.dart.
// Do not manually edit this file.

// ignore_for_file: no_leading_underscores_for_library_prefixes
import 'dart:async' as _i26;

import 'package:mockito/mockito.dart' as _i1;
import 'package:provenance_dart/proto.dart' as _i2;
import 'package:provenance_dart/src/proto/proto_gen/cosmos/auth/v1beta1/auth.pb.dart'
    as _i25;
import 'package:provenance_dart/src/proto/proto_gen/cosmos/auth/v1beta1/query.pbgrpc.dart'
    as _i5;
import 'package:provenance_dart/src/proto/proto_gen/cosmos/authz/v1beta1/query.pbgrpc.dart'
    as _i6;
import 'package:provenance_dart/src/proto/proto_gen/cosmos/bank/v1beta1/query.pbgrpc.dart'
    as _i7;
import 'package:provenance_dart/src/proto/proto_gen/cosmos/base/tendermint/v1beta1/query.pbgrpc.dart'
    as _i3;
import 'package:provenance_dart/src/proto/proto_gen/cosmos/distribution/v1beta1/query.pbgrpc.dart'
    as _i10;
import 'package:provenance_dart/src/proto/proto_gen/cosmos/evidence/v1beta1/query.pbgrpc.dart'
    as _i11;
import 'package:provenance_dart/src/proto/proto_gen/cosmos/feegrant/v1beta1/query.pbgrpc.dart'
    as _i12;
import 'package:provenance_dart/src/proto/proto_gen/cosmos/gov/v1beta1/query.pbgrpc.dart'
    as _i13;
import 'package:provenance_dart/src/proto/proto_gen/cosmos/mint/v1beta1/query.pbgrpc.dart'
    as _i17;
import 'package:provenance_dart/src/proto/proto_gen/cosmos/params/v1beta1/query.pbgrpc.dart'
    as _i19;
import 'package:provenance_dart/src/proto/proto_gen/cosmos/slashing/v1beta1/query.pbgrpc.dart'
    as _i20;
import 'package:provenance_dart/src/proto/proto_gen/cosmos/staking/v1beta1/query.pbgrpc.dart'
    as _i21;
import 'package:provenance_dart/src/proto/proto_gen/cosmos/upgrade/v1beta1/query.pbgrpc.dart'
    as _i23;
import 'package:provenance_dart/src/proto/proto_gen/cosmwasm/wasm/v1/query.pbgrpc.dart'
    as _i24;
import 'package:provenance_dart/src/proto/proto_gen/ibc/applications/transfer/v1/query.pbgrpc.dart'
    as _i22;
import 'package:provenance_dart/src/proto/proto_gen/ibc/core/channel/v1/query.pbgrpc.dart'
    as _i8;
import 'package:provenance_dart/src/proto/proto_gen/ibc/core/connection/v1/query.pbgrpc.dart'
    as _i9;
import 'package:provenance_dart/src/proto/proto_gen/provenance/attribute/v1/query.pbgrpc.dart'
    as _i4;
import 'package:provenance_dart/src/proto/proto_gen/provenance/marker/v1/query.pbgrpc.dart'
    as _i14;
import 'package:provenance_dart/src/proto/proto_gen/provenance/metadata/v1/query.pbgrpc.dart'
    as _i16;
import 'package:provenance_dart/src/proto/proto_gen/provenance/msgfees/v1/query.pbgrpc.dart'
    as _i15;
import 'package:provenance_dart/src/proto/proto_gen/provenance/name/v1/query.pbgrpc.dart'
    as _i18;
import 'package:provenance_dart/src/wallet/keys.dart' as _i27;
import 'package:provenance_dart/src/wallet/private_key.dart' as _i28;
import 'package:provenance_dart/wallet.dart' as _i31;
import 'package:provenance_wallet/services/gas_fee_service/gas_fee_service.dart'
    as _i29;
import 'package:provenance_wallet/services/models/gas_fee.dart' as _i30;

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

class _FakeServiceClient_0 extends _i1.SmartFake implements _i2.ServiceClient {
  _FakeServiceClient_0(Object parent, Invocation parentInvocation)
      : super(parent, parentInvocation);
}

class _FakeServiceClient_1 extends _i1.SmartFake implements _i3.ServiceClient {
  _FakeServiceClient_1(Object parent, Invocation parentInvocation)
      : super(parent, parentInvocation);
}

class _FakeQueryClient_2 extends _i1.SmartFake implements _i4.QueryClient {
  _FakeQueryClient_2(Object parent, Invocation parentInvocation)
      : super(parent, parentInvocation);
}

class _FakeQueryClient_3 extends _i1.SmartFake implements _i5.QueryClient {
  _FakeQueryClient_3(Object parent, Invocation parentInvocation)
      : super(parent, parentInvocation);
}

class _FakeQueryClient_4 extends _i1.SmartFake implements _i6.QueryClient {
  _FakeQueryClient_4(Object parent, Invocation parentInvocation)
      : super(parent, parentInvocation);
}

class _FakeQueryClient_5 extends _i1.SmartFake implements _i7.QueryClient {
  _FakeQueryClient_5(Object parent, Invocation parentInvocation)
      : super(parent, parentInvocation);
}

class _FakeQueryClient_6 extends _i1.SmartFake implements _i8.QueryClient {
  _FakeQueryClient_6(Object parent, Invocation parentInvocation)
      : super(parent, parentInvocation);
}

class _FakeQueryClient_7 extends _i1.SmartFake implements _i9.QueryClient {
  _FakeQueryClient_7(Object parent, Invocation parentInvocation)
      : super(parent, parentInvocation);
}

class _FakeQueryClient_8 extends _i1.SmartFake implements _i10.QueryClient {
  _FakeQueryClient_8(Object parent, Invocation parentInvocation)
      : super(parent, parentInvocation);
}

class _FakeQueryClient_9 extends _i1.SmartFake implements _i11.QueryClient {
  _FakeQueryClient_9(Object parent, Invocation parentInvocation)
      : super(parent, parentInvocation);
}

class _FakeQueryClient_10 extends _i1.SmartFake implements _i12.QueryClient {
  _FakeQueryClient_10(Object parent, Invocation parentInvocation)
      : super(parent, parentInvocation);
}

class _FakeQueryClient_11 extends _i1.SmartFake implements _i13.QueryClient {
  _FakeQueryClient_11(Object parent, Invocation parentInvocation)
      : super(parent, parentInvocation);
}

class _FakeQueryClient_12 extends _i1.SmartFake implements _i14.QueryClient {
  _FakeQueryClient_12(Object parent, Invocation parentInvocation)
      : super(parent, parentInvocation);
}

class _FakeQueryClient_13 extends _i1.SmartFake implements _i15.QueryClient {
  _FakeQueryClient_13(Object parent, Invocation parentInvocation)
      : super(parent, parentInvocation);
}

class _FakeQueryClient_14 extends _i1.SmartFake implements _i16.QueryClient {
  _FakeQueryClient_14(Object parent, Invocation parentInvocation)
      : super(parent, parentInvocation);
}

class _FakeQueryClient_15 extends _i1.SmartFake implements _i17.QueryClient {
  _FakeQueryClient_15(Object parent, Invocation parentInvocation)
      : super(parent, parentInvocation);
}

class _FakeQueryClient_16 extends _i1.SmartFake implements _i18.QueryClient {
  _FakeQueryClient_16(Object parent, Invocation parentInvocation)
      : super(parent, parentInvocation);
}

class _FakeQueryClient_17 extends _i1.SmartFake implements _i19.QueryClient {
  _FakeQueryClient_17(Object parent, Invocation parentInvocation)
      : super(parent, parentInvocation);
}

class _FakeQueryClient_18 extends _i1.SmartFake implements _i20.QueryClient {
  _FakeQueryClient_18(Object parent, Invocation parentInvocation)
      : super(parent, parentInvocation);
}

class _FakeQueryClient_19 extends _i1.SmartFake implements _i21.QueryClient {
  _FakeQueryClient_19(Object parent, Invocation parentInvocation)
      : super(parent, parentInvocation);
}

class _FakeQueryClient_20 extends _i1.SmartFake implements _i22.QueryClient {
  _FakeQueryClient_20(Object parent, Invocation parentInvocation)
      : super(parent, parentInvocation);
}

class _FakeQueryClient_21 extends _i1.SmartFake implements _i23.QueryClient {
  _FakeQueryClient_21(Object parent, Invocation parentInvocation)
      : super(parent, parentInvocation);
}

class _FakeQueryClient_22 extends _i1.SmartFake implements _i24.QueryClient {
  _FakeQueryClient_22(Object parent, Invocation parentInvocation)
      : super(parent, parentInvocation);
}

class _FakeBaseReq_23 extends _i1.SmartFake implements _i2.BaseReq {
  _FakeBaseReq_23(Object parent, Invocation parentInvocation)
      : super(parent, parentInvocation);
}

class _FakeGasEstimate_24 extends _i1.SmartFake implements _i2.GasEstimate {
  _FakeGasEstimate_24(Object parent, Invocation parentInvocation)
      : super(parent, parentInvocation);
}

class _FakeRawTxResponsePair_25 extends _i1.SmartFake
    implements _i2.RawTxResponsePair {
  _FakeRawTxResponsePair_25(Object parent, Invocation parentInvocation)
      : super(parent, parentInvocation);
}

class _FakeBaseAccount_26 extends _i1.SmartFake implements _i25.BaseAccount {
  _FakeBaseAccount_26(Object parent, Invocation parentInvocation)
      : super(parent, parentInvocation);
}

/// A class which mocks [PbClient].
///
/// See the documentation for Mockito's code generation for more information.
class MockPbClient extends _i1.Mock implements _i2.PbClient {
  MockPbClient() {
    _i1.throwOnMissingStub(this);
  }

  @override
  String get chainId =>
      (super.noSuchMethod(Invocation.getter(#chainId), returnValue: '')
          as String);
  @override
  _i2.ServiceClient get cosmosService =>
      (super.noSuchMethod(Invocation.getter(#cosmosService),
              returnValue:
                  _FakeServiceClient_0(this, Invocation.getter(#cosmosService)))
          as _i2.ServiceClient);
  @override
  _i3.ServiceClient get tindermintService => (super.noSuchMethod(
          Invocation.getter(#tindermintService),
          returnValue:
              _FakeServiceClient_1(this, Invocation.getter(#tindermintService)))
      as _i3.ServiceClient);
  @override
  _i4.QueryClient get attributeClient =>
      (super.noSuchMethod(Invocation.getter(#attributeClient),
              returnValue:
                  _FakeQueryClient_2(this, Invocation.getter(#attributeClient)))
          as _i4.QueryClient);
  @override
  _i5.QueryClient get authClient => (super.noSuchMethod(
          Invocation.getter(#authClient),
          returnValue: _FakeQueryClient_3(this, Invocation.getter(#authClient)))
      as _i5.QueryClient);
  @override
  _i6.QueryClient get authzClient =>
      (super.noSuchMethod(Invocation.getter(#authzClient),
              returnValue:
                  _FakeQueryClient_4(this, Invocation.getter(#authzClient)))
          as _i6.QueryClient);
  @override
  _i7.QueryClient get bankClient => (super.noSuchMethod(
          Invocation.getter(#bankClient),
          returnValue: _FakeQueryClient_5(this, Invocation.getter(#bankClient)))
      as _i7.QueryClient);
  @override
  _i8.QueryClient get channelClient =>
      (super.noSuchMethod(Invocation.getter(#channelClient),
              returnValue:
                  _FakeQueryClient_6(this, Invocation.getter(#channelClient)))
          as _i8.QueryClient);
  @override
  _i9.QueryClient get connectionClient => (super.noSuchMethod(
          Invocation.getter(#connectionClient),
          returnValue:
              _FakeQueryClient_7(this, Invocation.getter(#connectionClient)))
      as _i9.QueryClient);
  @override
  _i10.QueryClient get distributionClient => (super.noSuchMethod(
          Invocation.getter(#distributionClient),
          returnValue:
              _FakeQueryClient_8(this, Invocation.getter(#distributionClient)))
      as _i10.QueryClient);
  @override
  _i11.QueryClient get evidenceClient =>
      (super.noSuchMethod(Invocation.getter(#evidenceClient),
              returnValue:
                  _FakeQueryClient_9(this, Invocation.getter(#evidenceClient)))
          as _i11.QueryClient);
  @override
  _i12.QueryClient get feeGrantClient =>
      (super.noSuchMethod(Invocation.getter(#feeGrantClient),
              returnValue:
                  _FakeQueryClient_10(this, Invocation.getter(#feeGrantClient)))
          as _i12.QueryClient);
  @override
  _i13.QueryClient get govClient => (super.noSuchMethod(
          Invocation.getter(#govClient),
          returnValue: _FakeQueryClient_11(this, Invocation.getter(#govClient)))
      as _i13.QueryClient);
  @override
  _i14.QueryClient get markerClient =>
      (super.noSuchMethod(Invocation.getter(#markerClient),
              returnValue:
                  _FakeQueryClient_12(this, Invocation.getter(#markerClient)))
          as _i14.QueryClient);
  @override
  _i15.QueryClient get msgFeeClient =>
      (super.noSuchMethod(Invocation.getter(#msgFeeClient),
              returnValue:
                  _FakeQueryClient_13(this, Invocation.getter(#msgFeeClient)))
          as _i15.QueryClient);
  @override
  _i16.QueryClient get metadataClient =>
      (super.noSuchMethod(Invocation.getter(#metadataClient),
              returnValue:
                  _FakeQueryClient_14(this, Invocation.getter(#metadataClient)))
          as _i16.QueryClient);
  @override
  _i17.QueryClient get mintClient =>
      (super.noSuchMethod(Invocation.getter(#mintClient),
              returnValue:
                  _FakeQueryClient_15(this, Invocation.getter(#mintClient)))
          as _i17.QueryClient);
  @override
  _i18.QueryClient get nameClient =>
      (super.noSuchMethod(Invocation.getter(#nameClient),
              returnValue:
                  _FakeQueryClient_16(this, Invocation.getter(#nameClient)))
          as _i18.QueryClient);
  @override
  _i19.QueryClient get paramsClient =>
      (super.noSuchMethod(Invocation.getter(#paramsClient),
              returnValue:
                  _FakeQueryClient_17(this, Invocation.getter(#paramsClient)))
          as _i19.QueryClient);
  @override
  _i20.QueryClient get slashingClient =>
      (super.noSuchMethod(Invocation.getter(#slashingClient),
              returnValue:
                  _FakeQueryClient_18(this, Invocation.getter(#slashingClient)))
          as _i20.QueryClient);
  @override
  _i21.QueryClient get stakingClient =>
      (super.noSuchMethod(Invocation.getter(#stakingClient),
              returnValue:
                  _FakeQueryClient_19(this, Invocation.getter(#stakingClient)))
          as _i21.QueryClient);
  @override
  _i22.QueryClient get transferClient =>
      (super.noSuchMethod(Invocation.getter(#transferClient),
              returnValue:
                  _FakeQueryClient_20(this, Invocation.getter(#transferClient)))
          as _i22.QueryClient);
  @override
  _i23.QueryClient get upgradeClient =>
      (super.noSuchMethod(Invocation.getter(#upgradeClient),
              returnValue:
                  _FakeQueryClient_21(this, Invocation.getter(#upgradeClient)))
          as _i23.QueryClient);
  @override
  _i24.QueryClient get wasmClient =>
      (super.noSuchMethod(Invocation.getter(#wasmClient),
              returnValue:
                  _FakeQueryClient_22(this, Invocation.getter(#wasmClient)))
          as _i24.QueryClient);
  @override
  _i26.Future<void> dispose() =>
      (super.noSuchMethod(Invocation.method(#dispose, []),
              returnValue: _i26.Future<void>.value(),
              returnValueForMissingStub: _i26.Future<void>.value())
          as _i26.Future<void>);
  @override
  _i26.Future<_i2.BaseReq> baseRequest(_i2.TxBody? txBody, List<_i2.BaseReqSigner>? signers,
          {double? gasAdjustment, String? feeGranter}) =>
      (super.noSuchMethod(Invocation.method(#baseRequest, [txBody, signers], {#gasAdjustment: gasAdjustment, #feeGranter: feeGranter}),
          returnValue: _i26.Future<_i2.BaseReq>.value(_FakeBaseReq_23(
              this,
              Invocation.method(#baseRequest, [
                txBody,
                signers
              ], {
                #gasAdjustment: gasAdjustment,
                #feeGranter: feeGranter
              })))) as _i26.Future<_i2.BaseReq>);
  @override
  _i26.Future<_i2.GasEstimate> estimateTx(_i2.BaseReq? baseReq) =>
      (super.noSuchMethod(Invocation.method(#estimateTx, [baseReq]),
          returnValue: _i26.Future<_i2.GasEstimate>.value(_FakeGasEstimate_24(
              this, Invocation.method(#estimateTx, [baseReq])))) as _i26
          .Future<_i2.GasEstimate>);
  @override
  _i26.Future<_i2.RawTxResponsePair> broadcastTx(
          _i2.BaseReq? baseReq, _i2.GasEstimate? gasEstimate,
          [_i2.BroadcastMode? mode = _i2.BroadcastMode.BROADCAST_MODE_SYNC]) =>
      (super.noSuchMethod(
              Invocation.method(#broadcastTx, [baseReq, gasEstimate, mode]),
              returnValue: _i26.Future<_i2.RawTxResponsePair>.value(
                  _FakeRawTxResponsePair_25(this,
                      Invocation.method(#broadcastTx, [baseReq, gasEstimate, mode]))))
          as _i26.Future<_i2.RawTxResponsePair>);
  @override
  _i26.Future<_i2.RawTxResponsePair> estimateAndBroadcastTx(
          _i2.TxBody? txBody, List<_i2.BaseReqSigner>? signers,
          {_i2.BroadcastMode? mode = _i2.BroadcastMode.BROADCAST_MODE_SYNC,
          double? gasAdjustment,
          String? feeGranter}) =>
      (super.noSuchMethod(
              Invocation.method(#estimateAndBroadcastTx, [
                txBody,
                signers
              ], {
                #mode: mode,
                #gasAdjustment: gasAdjustment,
                #feeGranter: feeGranter
              }),
              returnValue: _i26.Future<_i2.RawTxResponsePair>.value(
                  _FakeRawTxResponsePair_25(this, Invocation.method(#estimateAndBroadcastTx, [txBody, signers], {#mode: mode, #gasAdjustment: gasAdjustment, #feeGranter: feeGranter}))))
          as _i26.Future<_i2.RawTxResponsePair>);
  @override
  _i26.Future<_i25.BaseAccount> getBaseAccount(String? bech32Address) =>
      (super.noSuchMethod(Invocation.method(#getBaseAccount, [bech32Address]),
          returnValue: _i26.Future<_i25.BaseAccount>.value(_FakeBaseAccount_26(
              this,
              Invocation.method(#getBaseAccount, [bech32Address])))) as _i26
          .Future<_i25.BaseAccount>);
  @override
  _i26.Future<_i2.GasEstimate> estimateTransactionFees(
          _i2.TxBody? transactionBody, Iterable<_i27.IPubKey>? signers,
          {double? gasAdjustment}) =>
      (super.noSuchMethod(Invocation.method(#estimateTransactionFees, [transactionBody, signers], {#gasAdjustment: gasAdjustment}),
          returnValue: _i26.Future<_i2.GasEstimate>.value(_FakeGasEstimate_24(
              this,
              Invocation.method(
                  #estimateTransactionFees,
                  [transactionBody, signers],
                  {#gasAdjustment: gasAdjustment})))) as _i26.Future<_i2.GasEstimate>);
  @override
  _i26.Future<_i2.RawTxResponsePair> estimateAndBroadcastTransaction(
          _i2.TxBody? transactionBody, List<_i27.IPrivKey>? signers,
          {double? gasAdjustment, String? feeGranter}) =>
      (super.noSuchMethod(
              Invocation.method(
                  #estimateAndBroadcastTransaction,
                  [transactionBody, signers],
                  {#gasAdjustment: gasAdjustment, #feeGranter: feeGranter}),
              returnValue: _i26.Future<_i2.RawTxResponsePair>.value(
                  _FakeRawTxResponsePair_25(this, Invocation.method(#estimateAndBroadcastTransaction, [transactionBody, signers], {#gasAdjustment: gasAdjustment, #feeGranter: feeGranter}))))
          as _i26.Future<_i2.RawTxResponsePair>);
  @override
  _i26.Future<_i2.RawTxResponsePair> broadcastTransaction(
          _i2.TxBody? transactionBody,
          Iterable<_i27.IPrivKey>? signers,
          _i2.Fee? fee,
          [_i2.BroadcastMode? mode = _i2.BroadcastMode.BROADCAST_MODE_SYNC]) =>
      (super.noSuchMethod(Invocation.method(#broadcastTransaction, [transactionBody, signers, fee, mode]),
              returnValue: _i26.Future<_i2.RawTxResponsePair>.value(
                  _FakeRawTxResponsePair_25(this,
                      Invocation.method(#broadcastTransaction, [transactionBody, signers, fee, mode]))))
          as _i26.Future<_i2.RawTxResponsePair>);
  @override
  List<int> generateMultiSigAuthorization(
          _i28.PrivateKey? pk,
          _i2.TxBody? txBody,
          _i2.Fee? fee,
          _i25.BaseAccount? multiSigAccount) =>
      (super.noSuchMethod(
          Invocation.method(#generateMultiSigAuthorization,
              [pk, txBody, fee, multiSigAccount]),
          returnValue: <int>[]) as List<int>);
}

/// A class which mocks [GasFeeService].
///
/// See the documentation for Mockito's code generation for more information.
class MockGasFeeService extends _i1.Mock implements _i29.GasFeeService {
  MockGasFeeService() {
    _i1.throwOnMissingStub(this);
  }

  @override
  _i26.Future<_i30.GasFee?> getGasFee(_i31.Coin? coin) =>
      (super.noSuchMethod(Invocation.method(#getGasFee, [coin]),
              returnValue: _i26.Future<_i30.GasFee?>.value())
          as _i26.Future<_i30.GasFee?>);
}
