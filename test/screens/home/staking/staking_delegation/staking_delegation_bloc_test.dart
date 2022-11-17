import 'package:decimal/decimal.dart';
import 'package:fixnum/fixnum.dart' as fixnum;
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:provenance_dart/proto.dart' as proto;
import 'package:provenance_dart/type_registry.dart';
import 'package:provenance_dart/wallet.dart';
import 'package:provenance_wallet/gas_fee_estimate.dart';
import 'package:provenance_wallet/screens/home/staking/staking_delegation/staking_delegation_bloc.dart';
import 'package:provenance_wallet/screens/home/staking/staking_screen_bloc.dart';
import 'package:provenance_wallet/services/account_service/account_service.dart';
import 'package:provenance_wallet/services/account_service/transaction_handler.dart';
import 'package:provenance_wallet/services/asset_client/asset_client.dart';
import 'package:provenance_wallet/services/models/account.dart';
import 'package:provenance_wallet/services/models/asset.dart';
import 'package:provenance_wallet/services/models/delegation.dart';
import 'package:provenance_wallet/services/models/detailed_validator.dart';
import 'package:provenance_wallet/services/models/rewards.dart';
import 'package:provenance_wallet/util/constants.dart';
import 'package:provenance_wallet/util/get.dart';

import './staking_delegation_bloc_test.mocks.dart';
import '../../../../test_helpers.dart';

const nHashPerGasUnit = 9625;

@GenerateMocks([AssetClient, AccountService, TransactionHandler])
main() {
  final phrase = Mnemonic.fromEntropy(List.generate(16, (index) => index));
  final seed = Mnemonic.createSeed(phrase);
  final privKey = PrivateKey.fromSeed(seed, Coin.testNet);

  final publicKey = privKey.publicKey;

  final detailedValidator = DetailedValidator.fake(
      blockCount: 200,
      blockTotal: 400,
      bondHeight: 4,
      consensusPubKey: publicKey.compressedPublicKeyHex,
      description: "Fake detailed Validator",
      identity: "tp1g5ugfegkl5gmn049n5a9hgjn3ged0ekp8f2fwx",
      moniker: "Fake Validator",
      operatorAddress: "tp1050wkzt7dr740jvp5xp96vjqamx5kp9jvpjvcu",
      ownerAddress: "tp1ajrjsmd3ljr086lttktcg0nuz8q7e0h8zdjnmg",
      siteUrl: "",
      status: ValidatorStatus.active,
      uptime: 1000,
      withdrawalAddress: "tp1qvfyvxmlqxsffxx4zfwpvscd0h66ahcn7tyt2y");

  final account = BasicAccount(
    id: "Id",
    name: "Name",
    publicKey: publicKey,
  );

  final delegation = Delegation.fake(
      address: "tp1ajrjsmd3ljr086lttktcg0nuz8q7e0h8zdjnmg",
      sourceAddress: "tp1ajrjsmd3ljr086lttktcg0nuz8q7e0h8zdjnmg",
      amount: "123",
      denom: "nhash");

  final reward = Reward.fake(".004", "nhash", ".08", ".000032");

  final nhashCoin = Asset.fake(
      denom: "nhash",
      amount: "1234",
      display: "",
      description: "",
      displayAmount: "",
      usdPrice: 123,
      exponent: 9);

  final usdCoin = Asset.fake(
      denom: "nhash",
      amount: "1234",
      display: "",
      description: "",
      displayAmount: "",
      usdPrice: 123,
      exponent: 9);

  late StakingDelegationBloc bloc;
  late MockAssetClient mockAssetClient;
  late MockAccountService mockAccountService;
  late MockTransactionHandler mockTransactionHandler;

  setUp(() {
    mockAssetClient = MockAssetClient();
    mockAccountService = MockAccountService();
    mockTransactionHandler = MockTransactionHandler();

    get.registerSingleton<AssetClient>(mockAssetClient);
    get.registerSingleton<AccountService>(mockAccountService);
    get.registerSingleton<TransactionHandler>(mockTransactionHandler);

    bloc = StakingDelegationBloc(
        account: account,
        selectedDelegationType: SelectedDelegationType.claimRewards,
        commissionRate: ".45",
        validator: detailedValidator,
        reward: reward,
        delegation: delegation);
  });

  tearDown(() {
    get.reset(dispose: false);
  });

  test("onDispose closes stream", () {
    bloc.onDispose();
    expect(bloc.stakingDelegationDetails, StreamClosed(true));
  });

  group("load", () {
    setUp(() {
      when(mockAssetClient.getAssets(any, any))
          .thenFuture([usdCoin, nhashCoin]);
    });

    test("Stream updated with asset", () async {
      bloc.load();
      verify(mockAssetClient.getAssets(publicKey.coin, publicKey.address));
    });

    test("Stream updated with asset", () async {
      expectLater(
          bloc.stakingDelegationDetails,
          emitsInOrder([
            emits(predicate((arg) {
              final details = arg as StakingDelegationDetails;
              expect(details.validator, detailedValidator);
              expect(details.commissionRate, ".45");
              expect(details.delegation, delegation);
              expect(details.selectedDelegationType,
                  SelectedDelegationType.claimRewards);
              expect(details.asset, null);
              expect(details.hashDelegated, Decimal.zero);
              expect(details.account, account);
              expect(details.reward, reward);
              return true;
            })),
            emits(predicate((arg) {
              final details = arg as StakingDelegationDetails;
              expect(details.validator, detailedValidator);
              expect(details.commissionRate, ".45");
              expect(details.delegation, delegation);
              expect(details.selectedDelegationType,
                  SelectedDelegationType.claimRewards);
              expect(details.asset!.amount, nhashCoin.amount);
              expect(details.asset!.denom, nhashCoin.denom);
              expect(details.hashDelegated, Decimal.zero);
              expect(details.account, account);
              expect(details.reward, reward);
              return true;
            })),
          ]));

      bloc.load();
    });

    test("error while getting asset bubbles up", () async {
      expectLater(
          bloc.stakingDelegationDetails,
          emitsInOrder([
            emits(predicate((arg) {
              final details = arg as StakingDelegationDetails;
              expect(details.validator, detailedValidator);
              expect(details.commissionRate, ".45");
              expect(details.delegation, delegation);
              expect(details.selectedDelegationType,
                  SelectedDelegationType.claimRewards);
              expect(details.asset, null);
              expect(details.hashDelegated, Decimal.zero);
              expect(details.account, account);
              expect(details.reward, reward);
              return true;
            })),
          ]));

      final ex = Exception("Test Message");
      when(mockAssetClient.getAssets(any, any)).thenThrow(ex);
      expect(() => bloc.load(), throwsA(ex));
    });
  });

  group("updateHashDelegated", () {
    setUp(() async {
      when(mockAssetClient.getAssets(any, any))
          .thenFuture([usdCoin, nhashCoin]);
    });

    test("Stream updated with asset", () async {
      final rate = Decimal.fromInt(1234);

      expectLater(
          bloc.stakingDelegationDetails,
          emitsInOrder([
            emits(predicate((arg) {
              final details = arg as StakingDelegationDetails;
              expect(details.validator, detailedValidator);
              expect(details.commissionRate, ".45");
              expect(details.delegation, delegation);
              expect(details.selectedDelegationType,
                  SelectedDelegationType.claimRewards);
              expect(details.asset, null);
              expect(details.hashDelegated, Decimal.zero);
              expect(details.account, account);
              expect(details.reward, reward);
              return true;
            })),
            emits(predicate((arg) {
              final details = arg as StakingDelegationDetails;
              expect(details.validator, detailedValidator);
              expect(details.commissionRate, ".45");
              expect(details.delegation, delegation);
              expect(details.selectedDelegationType,
                  SelectedDelegationType.claimRewards);
              expect(details.asset!.amount, nhashCoin.amount);
              expect(details.asset!.denom, nhashCoin.denom);
              expect(details.hashDelegated, Decimal.zero);
              expect(details.account, account);
              expect(details.reward, reward);
              return true;
            })),
            emits(predicate((arg) {
              final details = arg as StakingDelegationDetails;
              expect(details.validator, detailedValidator);
              expect(details.commissionRate, ".45");
              expect(details.delegation, delegation);
              expect(details.selectedDelegationType,
                  SelectedDelegationType.claimRewards);
              expect(details.asset!.amount, nhashCoin.amount);
              expect(details.asset!.denom, nhashCoin.denom);
              expect(details.hashDelegated, rate);
              expect(details.account, account);
              expect(details.reward, reward);
              return true;
            })),
          ]));

      await bloc.load();
      bloc.updateHashDelegated(rate);
    });
  });

  group("doDelegate", () {
    final response = proto.RawTxResponsePair(proto.TxRaw(),
        proto.TxResponse(height: fixnum.Int64(100), txhash: "ab cde"));
    final gasEstimate = GasFeeEstimate.single(
      units: 134556,
      denom: nHashDenom,
      amountPerUnit: nHashPerGasUnit,
    );

    setUp(() {
      when(mockTransactionHandler.estimateGas(any, any, any,
              gasAdjustment: anyNamed('gasAdjustment')))
          .thenFuture(gasEstimate);
      when(mockAccountService.loadKey(any, any)).thenFuture(privKey);
      when(mockTransactionHandler.executeTransaction(any, any, any, any))
          .thenFuture(response);
    });

    test("txResponse is serialized", () async {
      final value = await bloc.doDelegate(34.55);

      expect(value,
          response.txResponse.toProto3Json(typeRegistry: provenanceTypes));
    });

    test("Error during retrieve private key", () async {
      final ex = Exception("A");
      when(mockAccountService.loadKey(any, any)).thenThrow(ex);
      expect(() => bloc.doDelegate(34.55), throwsA(ex));
    });

    test("Error during estimate gas", () async {
      final ex = Exception("A");
      when(mockTransactionHandler.estimateGas(any, any, any,
              gasAdjustment: anyNamed('gasAdjustment')))
          .thenThrow(ex);
      expect(() => bloc.doDelegate(34.55), throwsA(ex));
    });

    test("Error during execute transaction gas", () async {
      final ex = Exception("A");
      when(mockTransactionHandler.executeTransaction(any, any, any, any))
          .thenThrow(ex);
      expect(() => bloc.doDelegate(34.55), throwsA(ex));
    });
  });

  group("doUndelegate", () {
    final response = proto.RawTxResponsePair(proto.TxRaw(),
        proto.TxResponse(height: fixnum.Int64(100), txhash: "ab cde"));
    final gasEstimate = GasFeeEstimate.single(
      units: 134556,
      denom: nHashDenom,
      amountPerUnit: nHashPerGasUnit,
    );

    setUp(() {
      when(mockTransactionHandler.estimateGas(any, any, any,
              gasAdjustment: anyNamed('gasAdjustment')))
          .thenFuture(gasEstimate);
      when(mockAccountService.loadKey(any, any)).thenFuture(privKey);
      when(mockTransactionHandler.executeTransaction(any, any, any, any))
          .thenFuture(response);
    });

    test("txResponse is serialized", () async {
      final value = await bloc.doUndelegate(34.55);

      expect(value,
          response.txResponse.toProto3Json(typeRegistry: provenanceTypes));
    });

    test("Error during retrieve private key", () async {
      final ex = Exception("A");
      when(mockAccountService.loadKey(any, any)).thenThrow(ex);
      expect(() => bloc.doUndelegate(34.55), throwsA(ex));
    });

    test("Error during estimate gas", () async {
      final ex = Exception("A");
      when(mockTransactionHandler.estimateGas(any, any, any,
              gasAdjustment: anyNamed('gasAdjustment')))
          .thenThrow(ex);
      expect(() => bloc.doUndelegate(34.55), throwsA(ex));
    });

    test("Error during execute transaction gas", () async {
      final ex = Exception("A");
      when(mockTransactionHandler.executeTransaction(any, any, any, any))
          .thenThrow(ex);
      expect(() => bloc.doUndelegate(34.55), throwsA(ex));
    });
  });

  group("claimRewards", () {
    final response = proto.RawTxResponsePair(proto.TxRaw(),
        proto.TxResponse(height: fixnum.Int64(100), txhash: "ab cde"));
    final gasEstimate = GasFeeEstimate.single(
      units: 134556,
      denom: nHashDenom,
      amountPerUnit: nHashPerGasUnit,
    );

    setUp(() {
      when(mockTransactionHandler.estimateGas(any, any, any,
              gasAdjustment: anyNamed('gasAdjustment')))
          .thenFuture(gasEstimate);
      when(mockAccountService.loadKey(any, any)).thenFuture(privKey);
      when(mockTransactionHandler.executeTransaction(any, any, any, any))
          .thenFuture(response);
    });

    test("txResponse is serialized", () async {
      final value = await bloc.claimRewards(34.55);

      expect(value,
          response.txResponse.toProto3Json(typeRegistry: provenanceTypes));
    });

    test("Error during retrieve private key", () async {
      final ex = Exception("A");
      when(mockAccountService.loadKey(any, any)).thenThrow(ex);
      expect(() => bloc.claimRewards(34.55), throwsA(ex));
    });

    test("Error during estimate gas", () async {
      final ex = Exception("A");
      when(mockTransactionHandler.estimateGas(any, any, any,
              gasAdjustment: anyNamed('gasAdjustment')))
          .thenThrow(ex);
      expect(() => bloc.claimRewards(34.55), throwsA(ex));
    });

    test("Error during execute transaction gas", () async {
      final ex = Exception("A");
      when(mockTransactionHandler.executeTransaction(any, any, any, any))
          .thenThrow(ex);
      expect(() => bloc.claimRewards(34.55), throwsA(ex));
    });
  });

  group("getUndelegateMessageJson", () {
    test("json maps is generated", () async {
      final message = bloc.getClaimRewardJson() as Map<String, dynamic>;

      expect(message["delegatorAddress"], account.address);
      expect(message["validatorAddress"], detailedValidator.operatorAddress);
    });
  });

  group("doUndelegate", () {
    test("json maps is generated", () async {
      final message = bloc.getUndelegateMessageJson() as Map<String, dynamic>;

      expect(message["amount"]["denom"], "nhash");
      expect(message["amount"]["amount"], "0");
      expect(message["delegatorAddress"], account.address);
      expect(message["validatorAddress"], detailedValidator.operatorAddress);
    });
  });

  group("doDelegate", () {
    test("json maps is generated", () async {
      final message = bloc.getDelegateMessageJson() as Map<String, dynamic>;

      expect(message["amount"]["denom"], "nhash");
      expect(message["amount"]["amount"], "0");
      expect(message["delegatorAddress"], account.address);
      expect(message["validatorAddress"], detailedValidator.operatorAddress);
    });
  });
}
