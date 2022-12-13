import 'package:fixnum/fixnum.dart' as $fixnum;
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:provenance_dart/proto.dart';
import 'package:provenance_dart/proto_cosmos_auth_v1beta1.dart';
import 'package:provenance_dart/wallet.dart' as wallet;
import 'package:provenance_wallet/gas_fee_estimate.dart';
import 'package:provenance_wallet/services/account_service/default_transaction_handler.dart';
import 'package:provenance_wallet/services/gas_fee/gas_fee_client.dart';
import 'package:provenance_wallet/services/models/gas_price.dart';
import 'package:provenance_wallet/util/get.dart';

import 'wallet_connect_transaction_handler_test.mocks.dart';

final gasEstimate = GasEstimate(123);
final gasPrice = GasPrice(amountPerUnit: 123, denom: "nhash");
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

@GenerateMocks([PbClient, GasFeeClient])
main() {
  MockPbClient? mockPbClient;
  MockGasFeeClient? mockGasFeeClient;
  DefaultTransactionHandler? transHandler;

  setUp(() {
    mockPbClient = MockPbClient();
    mockGasFeeClient = MockGasFeeClient();

    when(mockPbClient!.broadcastTx(
      any,
      any,
      any,
    )).thenAnswer((_) => Future.value(rawResponse));

    when(mockPbClient!.getBaseAccount(any))
        .thenAnswer((_) => Future.value(baseAccount));

    when(mockPbClient!.chainId).thenReturn(wallet.Coin.testNet.chainId);

    when(mockPbClient!.estimateTx(any))
        .thenAnswer((_) => Future.value(gasEstimate));

    when(mockPbClient!.estimateTransactionFees(
      any,
      any,
      gasAdjustment: anyNamed('gasAdjustment'),
    )).thenAnswer((_) => Future.value(gasEstimate));

    when(mockPbClient!.broadcastTransaction(any, any, any, any))
        .thenAnswer((_) async => rawResponse);

    when(mockGasFeeClient!.getPrice(wallet.Coin.testNet))
        .thenAnswer((_) => Future.value(gasPrice));

    get.registerSingleton<ProtobuffClientInjector>(
      (_) => Future.value(mockPbClient!),
    );
    get.registerSingleton<GasFeeClient>(mockGasFeeClient!);

    transHandler = DefaultTransactionHandler();
  });

  tearDown(() {
    get.reset(dispose: true);
  });

  group("estimateGas", () {
    test("success", () async {
      final walletEstimate =
          await transHandler!.estimateGas(txBody, [publicKey], coin);
      expect(walletEstimate, GasFeeEstimate(gasEstimate.estimate, [gasPrice]));
    });

    test("error while calling estimateTx", () async {
      final exception = Exception("A");
      when(mockPbClient!.estimateTransactionFees(
        any,
        any,
        gasAdjustment: anyNamed('gasAdjustment'),
      )).thenAnswer((_) => Future.error(exception));

      expect(
        () => transHandler!.estimateGas(txBody, [publicKey], coin),
        throwsA(exception),
      );
      verifyZeroInteractions(mockGasFeeClient!);
    });

    test("error while get gas fee", () async {
      final exception = Exception("A");
      when(mockGasFeeClient!.getPrice(wallet.Coin.testNet))
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

    test("error while calling estimateTx", () async {
      final exception = Exception("A");
      when(mockPbClient!.estimateTransactionFees(
        any,
        any,
        gasAdjustment: anyNamed('gasAdjustment'),
      )).thenAnswer((_) => Future.error(exception));

      expect(
        () => transHandler!
            .executeTransaction(txBody, privateKey.defaultKey(), coin),
        throwsA(exception),
      );
      verifyZeroInteractions(mockGasFeeClient!);
    });

    test("error while get gas fee", () async {
      final exception = Exception("A");
      when(mockGasFeeClient!.getPrice(wallet.Coin.testNet))
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
