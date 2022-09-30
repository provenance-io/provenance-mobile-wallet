import 'package:fixnum/fixnum.dart' as $fixnum;
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:provenance_dart/proto.dart';
import 'package:provenance_dart/proto_auth_v1beta1.dart';
import 'package:provenance_dart/wallet.dart' as wallet;
import 'package:provenance_wallet/chain_id.dart';
import 'package:provenance_wallet/services/account_service/default_transaction_handler.dart';
import 'package:provenance_wallet/services/account_service/model/account_gas_estimate.dart';
import 'package:provenance_wallet/services/gas_fee_service/dto/gas_fee_dto.dart';
import 'package:provenance_wallet/services/gas_fee_service/gas_fee_service.dart';
import 'package:provenance_wallet/services/models/gas_fee.dart';
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

Matcher _walletEstimateMatcher(GasEstimate gasEstimate, GasFee gasFee) {
  return predicate((arg) {
    final walletEstimate = arg as AccountGasEstimate;
    expect(walletEstimate.estimatedGas, gasEstimate.estimate);
    expect(walletEstimate.baseFee, gasFee.amount);
    expect(walletEstimate.gasAdjustment, gasEstimate.feeAdjustment);
    expect(
      walletEstimate.totalFees.length,
      1,
    ); // the 1 coin is calculated

    return true;
  });
}

@GenerateMocks([PbClient, GasFeeService])
main() {
  MockPbClient? mockPbClient;
  MockGasFeeService? mockGasFeeService;
  DefaultTransactionHandler? transHandler;

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

    when(mockPbClient!.estimateTransactionFees(any, any))
        .thenAnswer((_) => Future.value(gasEstimate));

    when(mockPbClient!.broadcastTransaction(any, any, any, any))
        .thenAnswer((_) async => rawResponse);

    when(mockGasFeeService!.getGasFee(wallet.Coin.testNet))
        .thenAnswer((_) => Future.value(gasFee));

    get.registerSingleton<ProtobuffClientInjector>(
      (_) => Future.value(mockPbClient!),
    );
    get.registerSingleton<GasFeeService>(mockGasFeeService!);

    transHandler = DefaultTransactionHandler();
  });

  tearDown(() {
    get.reset(dispose: true);
  });

  group("estimateGas", () {
    test("success", () async {
      final walletEstimate =
          await transHandler!.estimateGas(txBody, [publicKey], coin);
      expect(walletEstimate, _walletEstimateMatcher(gasEstimate, gasFee));
    });

    test("error while calling estimateTx", () async {
      final exception = Exception("A");
      when(mockPbClient!.estimateTransactionFees(any, any))
          .thenAnswer((_) => Future.error(exception));

      expect(
        () => transHandler!.estimateGas(txBody, [publicKey], coin),
        throwsA(exception),
      );
      verifyZeroInteractions(mockGasFeeService!);
    });

    test("error while get gas fee", () async {
      final exception = Exception("A");
      when(mockGasFeeService!.getGasFee(wallet.Coin.testNet))
          .thenAnswer((_) => Future.error(exception));

      expect(
        () => transHandler!.estimateGas(txBody, [publicKey], coin),
        throwsA(exception),
      );
    });
  });

  group("executeTransaction", () {
    test("success", () async {
      final response = await transHandler!
          .executeTransaction(txBody, privateKey.defaultKey(), coin);

      expect(response, rawResponse);
    });

    test("calls - with gas estimate", () async {
      final walletEstimate = AccountGasEstimate(
        100,
        1000,
      );

      await transHandler!.executeTransaction(
        txBody,
        privateKey.defaultKey(),
        coin,
        walletEstimate,
      );

      verifyNever(mockPbClient!.estimateTx(any));
    });

    test("error while calling estimateTx", () async {
      final exception = Exception("A");
      when(mockPbClient!.estimateTransactionFees(any, any))
          .thenAnswer((_) => Future.error(exception));

      expect(
        () => transHandler!
            .executeTransaction(txBody, privateKey.defaultKey(), coin),
        throwsA(exception),
      );
      verifyZeroInteractions(mockGasFeeService!);
    });

    test("error while get gas fee", () async {
      final exception = Exception("A");
      when(mockGasFeeService!.getGasFee(wallet.Coin.testNet))
          .thenAnswer((_) => Future.error(exception));

      expect(
        () => transHandler!
            .executeTransaction(txBody, privateKey.defaultKey(), coin),
        throwsA(exception),
      );
    });

    test("error while broadcasting", () async {
      final exception = Exception("A");
      when(mockPbClient!.broadcastTransaction(
        any,
        any,
        any,
        any,
      )).thenAnswer((_) => Future.error(exception));

      expect(
        () => transHandler!
            .executeTransaction(txBody, privateKey.defaultKey(), coin),
        throwsA(exception),
      );
    });
  });
}
