import 'package:fixnum/fixnum.dart' as $fixnum;
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:provenance_dart/proto.dart';
import 'package:provenance_dart/proto_auth.dart';
import 'package:provenance_dart/wallet.dart' as wallet;
import 'package:provenance_wallet/chain_id.dart';
import 'package:provenance_wallet/services/gas_fee_service/dto/gas_fee_dto.dart';
import 'package:provenance_wallet/services/gas_fee_service/gas_fee_service.dart';
import 'package:provenance_wallet/services/models/gas_fee.dart';
import 'package:provenance_wallet/services/wallet_service/model/wallet_gas_estimate.dart';
import 'package:provenance_wallet/services/wallet_service/wallet_connect_transaction_handler.dart';
import 'package:provenance_wallet/util/get.dart';

import 'wallet_connect_transaction_handler_test.mocks.dart';

final gasEstimate = GasEstimate(123);
final gasFee = GasFee(dto: GasFeeDto(gasPrice: 123, gasPriceDenom: "nhash"));
const coin = wallet.Coin.testNet;
final seed = wallet.Mnemonic.createSeed(
  wallet.Mnemonic.fromEntropy(List.generate(256, (index) => index)),
);
final privateKey = wallet.PrivateKey.fromSeed(seed, coin);
final publicKey = privateKey.defaultKey().publicKey;
final txBody = TxBody();
final baseAccount = BaseAccount(address: publicKey.address);
final txRaw = TxRaw();
final txResponse = TxResponse(code: 0, height: $fixnum.Int64(123));
final rawResponse = RawTxResponsePair(txRaw, txResponse);

Matcher _baseSignReqMatcher(
  BaseAccount baseAccount,
  wallet.PublicKey publicKey, [
  int offset = 0,
]) {
  return predicate((arg) {
    final reqSigner = arg as BaseReqSigner;
    expect(reqSigner.baseAccount, baseAccount);
    expect(reqSigner.sequenceOffset, offset);

    final signer = reqSigner.signer;
    expect(signer.address, publicKey.address);
    expect(
      signer.pubKey.compressedPublicKey,
      publicKey.compressedPublicKey,
    );

    return true;
  });
}

Matcher _walletEstimateMatcher(GasEstimate gasEstimate, GasFee gasFee) {
  return predicate((arg) {
    final walletEstimate = arg as WalletGasEstimate;
    expect(walletEstimate.estimate, gasEstimate.estimate);
    expect(walletEstimate.baseFee, gasFee.amount);
    expect(walletEstimate.feeAdjustment, gasEstimate.feeAdjustment);
    expect(
      walletEstimate.feeCalculated!.length,
      1,
    ); // the 1 coin is calculated

    return true;
  });
}

Matcher _baseReqMatcher(
  wallet.Coin coin,
  TxBody txBody,
  BaseAccount baseAccount,
  wallet.PublicKey publicKey,
) {
  return predicate((arg) {
    final baseReq = arg as BaseReq;
    expect(baseReq.chainId, ChainId.forCoin(coin));
    expect(baseReq.feeGranter, null);
    expect(baseReq.body, txBody);
    expect(baseReq.signers, [
      _baseSignReqMatcher(baseAccount, publicKey),
    ]);

    return true;
  });
}

@GenerateMocks([PbClient, GasFeeService])
main() {
  MockPbClient? mockPbClient;
  MockGasFeeService? mockGasFeeService;
  WalletConnectTransactionHandler? transHandler;

  setUp(() {
    mockPbClient = MockPbClient();
    mockGasFeeService = MockGasFeeService();

    when(mockPbClient!.broadcastTx(
      any,
      any,
      any,
    )).thenAnswer((_) => Future.value(rawResponse));

    when(mockPbClient!.getBaseAccount(any))
        .thenAnswer((_) => Future.value(baseAccount));

    when(mockPbClient!.chainId).thenReturn(ChainId.testNet);

    when(mockPbClient!.estimateTx(any))
        .thenAnswer((_) => Future.value(gasEstimate));

    when(mockGasFeeService!.getGasFee(wallet.Coin.testNet))
        .thenAnswer((_) => Future.value(gasFee));

    get.registerSingleton<ProtobuffClientInjector>((_) => mockPbClient!);
    get.registerSingleton<GasFeeService>(mockGasFeeService!);

    transHandler = WalletConnectTransactionHandler();
  });

  tearDown(() {
    get.reset(dispose: true);
  });

  group("estimateGas", () {
    test("success", () async {
      final walletEstimate = await transHandler!.estimateGas(txBody, publicKey);
      expect(walletEstimate, _walletEstimateMatcher(gasEstimate, gasFee));
    });

    test("calls", () async {
      await transHandler!.estimateGas(txBody, publicKey);
      verify(mockPbClient!.getBaseAccount(publicKey.address));
      final req = verify(mockPbClient!.estimateTx(captureAny)).captured.first
          as BaseReq;

      expect(
        req,
        _baseReqMatcher(
          coin,
          txBody,
          baseAccount,
          publicKey,
        ),
      );
    });

    test("error while calling get base account", () async {
      final exception = Exception("A");
      when(mockPbClient!.getBaseAccount(any))
          .thenAnswer((_) => Future.error(exception));

      expect(
        () => transHandler!.estimateGas(txBody, publicKey),
        throwsA(exception),
      );

      verifyZeroInteractions(mockGasFeeService!);
    });

    test("error while calling estimateTx", () async {
      final exception = Exception("A");
      when(mockPbClient!.estimateTx(any))
          .thenAnswer((_) => Future.error(exception));

      expect(
        () => transHandler!.estimateGas(txBody, publicKey),
        throwsA(exception),
      );
      verifyZeroInteractions(mockGasFeeService!);
    });

    test("error while get gas fee", () async {
      final exception = Exception("A");
      when(mockGasFeeService!.getGasFee(wallet.Coin.testNet))
          .thenAnswer((_) => Future.error(exception));

      expect(
        () => transHandler!.estimateGas(txBody, publicKey),
        throwsA(exception),
      );
    });
  });

  group("executeTransaction", () {
    test("success", () async {
      final response =
          await transHandler!.executeTransaction(txBody, privateKey);

      expect(response, rawResponse);
    });

    test("calls", () async {
      await transHandler!.executeTransaction(txBody, privateKey);

      verify(mockPbClient!.getBaseAccount(publicKey.address));
      final req = verify(mockPbClient!.estimateTx(captureAny)).captured.first
          as BaseReq;

      expect(
        req,
        _baseReqMatcher(
          coin,
          txBody,
          baseAccount,
          publicKey,
        ),
      );

      final captures = verify(mockPbClient!.broadcastTx(
        captureAny,
        captureAny,
        BroadcastMode.BROADCAST_MODE_BLOCK,
      )).captured;

      final baseReq = captures[0] as BaseReq;
      expect(
        baseReq,
        _baseReqMatcher(
          coin,
          txBody,
          baseAccount,
          publicKey,
        ),
      );

      final walletEstimate = captures[1] as WalletGasEstimate;
      expect(walletEstimate, _walletEstimateMatcher(gasEstimate, gasFee));
    });

    test("calls - with gas estimate", () async {
      final walletEstimate = WalletGasEstimate(
        100,
        1000,
      );

      await transHandler!.executeTransaction(
        txBody,
        privateKey,
        walletEstimate,
      );

      verifyNever(mockPbClient!.estimateTx(any));
    });

    test("error while calling get base account", () async {
      final exception = Exception("A");
      when(mockPbClient!.getBaseAccount(any))
          .thenAnswer((_) => Future.error(exception));

      expect(
        () => transHandler!.executeTransaction(txBody, privateKey),
        throwsA(exception),
      );

      verifyZeroInteractions(mockGasFeeService!);
    });

    test("error while calling estimateTx", () async {
      final exception = Exception("A");
      when(mockPbClient!.estimateTx(any))
          .thenAnswer((_) => Future.error(exception));

      expect(
        () => transHandler!.executeTransaction(txBody, privateKey),
        throwsA(exception),
      );
      verifyZeroInteractions(mockGasFeeService!);
    });

    test("error while get gas fee", () async {
      final exception = Exception("A");
      when(mockGasFeeService!.getGasFee(wallet.Coin.testNet))
          .thenAnswer((_) => Future.error(exception));

      expect(
        () => transHandler!.executeTransaction(txBody, privateKey),
        throwsA(exception),
      );
    });

    test("error while broadcasting", () async {
      final exception = Exception("A");
      when(mockPbClient!.broadcastTx(
        any,
        any,
        any,
      )).thenAnswer((_) => Future.error(exception));

      expect(
        () => transHandler!.executeTransaction(txBody, privateKey),
        throwsA(exception),
      );
    });
  });
}
