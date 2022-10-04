import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:provenance_dart/wallet.dart';
import 'package:provenance_wallet/screens/home/staking/staking_delegation/staking_delegation_bloc.dart';
import 'package:provenance_wallet/screens/home/staking/staking_details/staking_details_bloc.dart';
import 'package:provenance_wallet/screens/home/staking/staking_flow/staking_flow.dart';
import 'package:provenance_wallet/screens/home/staking/staking_screen_bloc.dart';
import 'package:provenance_wallet/services/models/account.dart';
import 'package:provenance_wallet/services/models/commission.dart';
import 'package:provenance_wallet/services/models/delegation.dart';
import 'package:provenance_wallet/services/models/detailed_validator.dart';
import 'package:provenance_wallet/services/models/rewards.dart';
import 'package:provenance_wallet/services/validator_client/validator_client.dart';
import 'package:provenance_wallet/util/get.dart';

import './staking_details_test.mocks.dart';
import '../../../../test_helpers.dart';

@GenerateMocks([StakingFlowNavigator, ValidatorClient])
main() {
  const pubKeyHex = "AtqS7MRO7zKZ4Azfj0do1bYGv4JC/1J35vB6rdk1JXo3";
  const validatorAddress = "tp1k3zh5ak5xcx0pfq3lynnw0lejnhhrlgfwy33xl";
  final publicKey = PublicKey.fromCompressPublicHex(
      Base64Decoder().convert(pubKeyHex), Coin.testNet);

  final commission = Commission.fake(
      bondedTokensCount: 1000,
      bondedTokensDenom: "nhash",
      selfBondedCount: 500,
      selfBondedDenom: "nhash",
      delegatorBondedCount: 500,
      delegatorBondedDenom: "nhash",
      delegatorCount: 6,
      totalShares: "500",
      commissionRewardsAmount: ".6",
      commissionRewardsDenom: "nhash",
      commissionRate: ".25",
      commissionMaxRate: ".50",
      commissionMaxChangeRate: ".05");

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

  final rewards = Rewards.fake(
      [Reward.fake(".004", "nhash", ".08", ".000032")], validatorAddress);

  late MockStakingFlowNavigator mockStakingFlowNavigator;
  late MockValidatorClient mockValidatorClient;
  late StakingDetailsBloc bloc;

  setUp(() {
    mockStakingFlowNavigator = MockStakingFlowNavigator();
    mockValidatorClient = MockValidatorClient();

    get.registerLazySingleton<ValidatorClient>(() => mockValidatorClient);

    bloc = StakingDetailsBloc(validatorAddress, account, delegation, rewards,
        navigator: mockStakingFlowNavigator);
  });

  tearDown(() {
    get.reset(dispose: false);
  });

  group("load", () {
    setUp(() {
      when(mockValidatorClient.getDetailedValidator(any, any))
          .thenFuture(detailedValidator);
      when(mockValidatorClient.getValidatorCommission(any, any))
          .thenFuture(commission);
    });

    group("loading Stream", () {
      test("isLoading transions on success", () async {
        expectLater(bloc.isLoading,
            emitsInOrder([emits(false), emits(true), emits(false)]));

        bloc.load();
      });

      test("loading is cancelled on getDetailedValidator error", () async {
        final error = Exception("A");

        when(mockValidatorClient.getDetailedValidator(any, any))
            .thenThrow(error);

        expectLater(bloc.isLoading,
            emitsInOrder([emits(false), emits(true), emits(false)]));

        try {
          await bloc.load();
        } catch (e) {}
      });

      test("loading is cancelled on getValidatorCommission error", () async {
        final error = Exception("A");

        when(mockValidatorClient.getValidatorCommission(any, any))
            .thenThrow(error);

        expectLater(bloc.isLoading,
            emitsInOrder([emits(false), emits(true), emits(false)]));
        try {
          await bloc.load();
        } catch (e) {}
      });
    });

    group("Load results", () {
      test("Successful calls update validatorDetailsStream", () async {
        expectLater(
            bloc.validatorDetails,
            emitsInOrder([
              emits(predicate((arg) {
                final details = arg as DetailedValidatorDetails;
                expect(details.validator, null);
                expect(details.commission, null);
                expect(details.delegation, null);
                expect(details.rewards, null);
                return true;
              })),
              emits(predicate((arg) {
                final details = arg as DetailedValidatorDetails;
                expect(details.validator, detailedValidator);
                expect(details.commission, commission);
                expect(details.delegation, delegation);
                expect(details.rewards, rewards);
                return true;
              }))
            ]));

        bloc.load();
      });

      test("loading is cancelled on getDetailedValidator error", () async {
        final error = Exception("A");

        when(mockValidatorClient.getDetailedValidator(any, any))
            .thenThrow(error);

        expectLater(
            bloc.validatorDetails,
            emitsInOrder([
              emits(predicate((arg) {
                final details = arg as DetailedValidatorDetails;
                expect(details.validator, null);
                expect(details.commission, null);
                expect(details.delegation, null);
                expect(details.rewards, null);
                return true;
              })),
            ]));

        try {
          await bloc.load();
        } catch (e) {
          expect(e, error);
        }
      });

      test("loading is cancelled on getValidatorCommission error", () async {
        final error = Exception("A");

        when(mockValidatorClient.getValidatorCommission(any, any))
            .thenThrow(error);

        expectLater(
            bloc.validatorDetails,
            emitsInOrder([
              emits(predicate((arg) {
                final details = arg as DetailedValidatorDetails;
                expect(details.validator, null);
                expect(details.commission, null);
                expect(details.delegation, null);
                expect(details.rewards, null);
                return true;
              })),
            ]));
        try {
          await bloc.load();
        } catch (e) {
          expect(e, error);
        }
      });
    });
  });

  group("onDispose", () {
    test("verify onDispose closes streams", () async {
      await bloc.onDispose();

      expect(bloc.validatorDetails, StreamClosed(true));
      expect(bloc.isLoading, StreamClosed(true));
    });
  });

  group("getProvUrl", () {
    test("getProvUrl points to test url for Coin.testNet", () {
      final pubKey = PublicKey.fromCompressPublicHex(
          Base64Decoder().convert(pubKeyHex), Coin.testNet);

      final account = BasicAccount(
        id: "Id",
        name: "Name",
        publicKey: pubKey,
      );

      var bloc = StakingDetailsBloc(
          validatorAddress, account, delegation, rewards,
          navigator: mockStakingFlowNavigator);

      expect(bloc.getProvUrl(),
          "https://explorer.test.provenance.io/validator/$validatorAddress");
    });

    test("getProvUrl points to test url for Coin.testNet", () {
      final pubKey = PublicKey.fromCompressPublicHex(
          Base64Decoder().convert(pubKeyHex), Coin.mainNet);

      final account = BasicAccount(
        id: "Id",
        name: "Name",
        publicKey: pubKey,
      );

      var bloc = StakingDetailsBloc(
          validatorAddress, account, delegation, rewards,
          navigator: mockStakingFlowNavigator);

      expect(bloc.getProvUrl(),
          "https://explorer.provenance.io/validator/$validatorAddress");
    });
  });

  test("onComplete invokes navigator", () {
    bloc.onComplete();
    verify(mockStakingFlowNavigator.onComplete());
  });

  test("showClaimRewardsReview invokes navigator", () {
    final validator = DetailedValidator.fake(
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

    final reward = Reward.fake(".004", "nhash", ".08", ".000032");

    bloc.showClaimRewardsReview(validator, reward);
    verify(mockStakingFlowNavigator.showClaimRewardsReview(validator, reward));

    bloc.showClaimRewardsReview(validator, null);
    verify(mockStakingFlowNavigator.showClaimRewardsReview(validator, null));
  });

  test("showDelegationReview invokes navigator", () {
    bloc.showDelegationReview();
    verify(mockStakingFlowNavigator.showDelegationReview());
  });

  test("showDelegationScreen invokes navigator", () {
    final validator = DetailedValidator.fake(
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

    final commission = Commission.fake(
        bondedTokensCount: 1000,
        bondedTokensDenom: "nhash",
        selfBondedCount: 500,
        selfBondedDenom: "nhash",
        delegatorBondedCount: 500,
        delegatorBondedDenom: "nhash",
        delegatorCount: 6,
        totalShares: "500",
        commissionRewardsAmount: ".6",
        commissionRewardsDenom: "nhash",
        commissionRate: ".25",
        commissionMaxRate: ".50",
        commissionMaxChangeRate: ".05");

    bloc.showDelegationScreen(validator, commission);
    verify(
        mockStakingFlowNavigator.showDelegationScreen(validator, commission));
  });

  test("showRedelegationReview invokes navigator", () {
    bloc.showRedelegationReview();
    verify(mockStakingFlowNavigator.showRedelegationReview());
  });

  test("showRedelegationScreen invokes navigator", () {
    final validator = DetailedValidator.fake(
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

    bloc.showRedelegationScreen(validator);
    verify(mockStakingFlowNavigator.showRedelegationScreen(validator));
  });

  test("showTransactionData invokes navigator", () {
    bloc.showTransactionData(1, "A Title");
    verify(mockStakingFlowNavigator.showTransactionData(1, "A Title"));

    bloc.showTransactionData(null, "A Title");
    verify(mockStakingFlowNavigator.showTransactionData(null, "A Title"));
  });

  test("showTransactionComplete invokes navigator", () {
    bloc.showTransactionComplete(1, SelectedDelegationType.claimRewards);
    verify(mockStakingFlowNavigator.showTransactionComplete(
        1, SelectedDelegationType.claimRewards));

    bloc.showTransactionComplete(null, SelectedDelegationType.claimRewards);
    verify(mockStakingFlowNavigator.showTransactionComplete(
        null, SelectedDelegationType.claimRewards));
  });

  test("showUndelegationReview invokes navigator", () {
    bloc.showUndelegationReview();
    verify(mockStakingFlowNavigator.showUndelegationReview());
  });

  test("showUndelegationScreen invokes navigator", () {
    final validator = DetailedValidator.fake(
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

    bloc.showUndelegationScreen(validator);
    verify(mockStakingFlowNavigator.showUndelegationScreen(validator));
  });

  test("showRedelegationAmountScreen invokes navigator", () {
    bloc.showRedelegationAmountScreen();
    verify(mockStakingFlowNavigator.showRedelegationAmountScreen());
  });

  test("redirectToRedelegation invokes navigator", () {
    final validator = DetailedValidator.fake(
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

    bloc.redirectToRedelegation(validator);
    verify(mockStakingFlowNavigator.redirectToRedelegation(validator));
  });

  test("backToDashboard invokes navigator", () {
    bloc.backToDashboard();
    verify(mockStakingFlowNavigator.backToDashboard());
  });
}
