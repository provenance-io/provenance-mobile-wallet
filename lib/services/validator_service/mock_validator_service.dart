import 'package:faker/faker.dart';
import 'package:provenance_dart/wallet.dart';
import 'package:provenance_wallet/screens/home/explorer/explorer_bloc.dart';
import 'package:provenance_wallet/services/models/abbreviated_validator.dart';
import 'package:provenance_wallet/services/models/commission.dart';
import 'package:provenance_wallet/services/models/delegation.dart';
import 'package:provenance_wallet/services/models/detailed_validator.dart';
import 'package:provenance_wallet/services/models/provenance_validator.dart';
import 'package:provenance_wallet/services/models/rewards.dart';
import 'package:provenance_wallet/services/validator_service/validator_service.dart';

class MockValidatorService extends ValidatorService {
  final faker = Faker();
  static const _tokenTotal = 5802852327538;
  static const _addressCharSet = '1234567890abcdefghijklmnopqrstuvwzyz';
  static const _addressLength = 41;

  @override
  Future<List<ProvenanceValidator>> getRecentValidators(
    Coin coin,
    int pageNumber,
    ValidatorStatus status,
  ) async {
    await Future.delayed(Duration(milliseconds: 500));
    return _getValidators(status).toList();
  }

  @override
  Future<List<AbbreviatedValidator>> getAbbreviatedValidators(
    Coin coin,
    int pageNumber,
  ) async {
    await Future.delayed(Duration(milliseconds: 500));
    return _getAbbrVldrs().toList();
  }

  AbbreviatedValidator _getAbbrVldr() {
    return AbbreviatedValidator.fake(
      moniker: _getMoniker(),
      address:
          faker.randomGenerator.fromCharSet(_addressCharSet, _addressLength),
      commission: faker.randomGenerator.decimal().toString(),
      imgUrl: faker.randomGenerator.boolean()
          ? null
          : faker.image.image(width: 60, height: 60, random: true),
    );
  }

  Iterable<AbbreviatedValidator> _getAbbrVldrs({int count = 46}) {
    return Iterable.generate(count).map((e) => _getAbbrVldr());
  }

  @override
  Future<List<Delegation>> getDelegations(
    Coin coin,
    String provenanceAddress,
    int pageNumber,
    DelegationState state,
  ) async {
    await Future.delayed(Duration(milliseconds: 500));
    return _getDelegates(state, provenanceAddress).toList();
  }

  @override
  Future<List<Rewards>> getRewards(
    Coin coin,
    String provenanceAddress,
  ) async {
    await Future.delayed(Duration(milliseconds: 500));
    return faker.randomGenerator.boolean() ? [_getRewards()] : [];
  }

  @override
  Future<DetailedValidator> getDetailedValidator(
    Coin coin,
    String validatorAddress,
  ) async {
    await Future.delayed(Duration(milliseconds: 500));
    return _getDetailedValidator(validatorAddress);
  }

  @override
  Future<Commission> getValidatorCommission(
    Coin coin,
    String validatorAddress,
  ) async {
    await Future.delayed(Duration(milliseconds: 500));
    return _getValidatorCommission();
  }

  Commission _getValidatorCommission() {
    return Commission.fake(
        bondedTokensCount: faker.randomGenerator.fromCharSet('0123456789', 20),
        bondedTokensDenom: 'nhash',
        selfBondedCount: faker.randomGenerator.fromCharSet('0123456789', 20),
        selfBondedDenom: 'nhash',
        delegatorBondedCount:
            faker.randomGenerator.fromCharSet('0123456789', 20),
        delegatorBondedDenom: 'nhash',
        delegatorCount: faker.randomGenerator.integer(20, min: 2),
        totalShares: faker.randomGenerator.fromCharSet('0123456789', 20),
        commissionRewardsAmount:
            faker.randomGenerator.fromCharSet('0123456789', 20),
        commissionRewardsDenom: 'nhash',
        commissionRate: faker.randomGenerator.decimal().toString(),
        commissionMaxRate: faker.randomGenerator.decimal().toString(),
        commissionMaxChangeRate: faker.randomGenerator.decimal().toString());
  }

  DetailedValidator _getDetailedValidator(String validatorAddress) {
    return DetailedValidator.fake(
      blockCount: 0,
      blockTotal: faker.randomGenerator.integer(9999, min: 1),
      bondHeight: faker.randomGenerator.integer(999999, min: 20000),
      consensusPubKey:
          faker.randomGenerator.fromCharSet(_addressCharSet, _addressLength),
      description:
          faker.randomGenerator.boolean() ? "" : faker.company.position(),
      identity: "",
      moniker: _getMoniker(),
      operatorAddress: validatorAddress,
      ownerAddress:
          faker.randomGenerator.fromCharSet(_addressCharSet, _addressLength),
      siteUrl: "",
      status: faker.randomGenerator.element(ValidatorStatus.values),
      uptime: faker.randomGenerator.decimal(scale: 100, min: 90),
      withdrawalAddress:
          faker.randomGenerator.fromCharSet(_addressCharSet, _addressLength),
      jailedUntil: DateTime.now(),
      unbondingHeight: faker.randomGenerator.integer(999999, min: 20000),
      imgUrl: faker.randomGenerator.boolean()
          ? null
          : faker.image.image(width: 60, height: 60, random: true),
      votingPowerCount: faker.randomGenerator.integer(4, min: 1),
      votingPowerTotal: faker.randomGenerator.integer(10, min: 5),
    );
  }

  Rewards _getRewards() {
    return Rewards.fake(Iterable.generate(2).map((e) => _getReward()).toList(),
        faker.randomGenerator.fromCharSet(_addressCharSet, _addressLength));
  }

  Reward _getReward() {
    var amount = faker.randomGenerator.integer(9999999);
    var tokenPrice = 0.00000008;
    var total = amount * tokenPrice;
    return Reward.fake(
      amount.toString(),
      'nhash',
      tokenPrice.toString(),
      total.toString(),
    );
  }

  Delegation _getDelegate(DelegationState state, String address) {
    var sourceAddress =
        faker.randomGenerator.fromCharSet(_addressCharSet, _addressLength);
    var amount = faker.randomGenerator.integer(9999999).toString();
    switch (state) {
      case DelegationState.bonded:
        return Delegation.fake(
            address: address,
            sourceAddress: sourceAddress,
            amount: amount,
            denom: 'hash',
            shares: amount);
      case DelegationState.redelegated:
        return Delegation.fake(
          address: address,
          sourceAddress: sourceAddress,
          amount: amount,
          denom: 'hash',
          block: faker.randomGenerator.integer(9999999),
          destinationAddress: faker.randomGenerator
              .fromCharSet(_addressCharSet, _addressLength),
          initialAmount: amount,
          initialDenom: 'hash',
          endTime: DateTime.now(),
          shares: amount,
        );
      case DelegationState.unbonded:
        return Delegation.fake(
          address: address,
          sourceAddress: sourceAddress,
          amount: amount,
          denom: 'hash',
          block: faker.randomGenerator.integer(9999999),
          destinationAddress: faker.randomGenerator
              .fromCharSet(_addressCharSet, _addressLength),
          initialAmount: amount,
          initialDenom: 'hash',
          endTime: DateTime.now(),
        );
    }
  }

  Iterable<Delegation> _getDelegates(DelegationState state, String address,
      {int count = 4}) {
    return Iterable.generate(count).map((e) => _getDelegate(state, address));
  }

  ProvenanceValidator _getValidator(ValidatorStatus status) {
    return ProvenanceValidator.fake(
        moniker: _getMoniker(),
        addressId:
            faker.randomGenerator.fromCharSet(_addressCharSet, _addressLength),
        consensusAddress:
            faker.randomGenerator.fromCharSet(_addressCharSet, _addressLength),
        commission: faker.randomGenerator.decimal().toString(),
        delegators: faker.randomGenerator.integer(13, min: 1),
        status: status.toString(),
        uptime: faker.randomGenerator.decimal(scale: 100, min: 90),
        bondedTokensCount: faker.randomGenerator.integer(9999999).toString(),
        bondedTokensDenom: 'nhash',
        bondedTokensTotal: '$_tokenTotal',
        votingPowerCount: faker.randomGenerator.integer(9999999),
        votingPowerTotal: _tokenTotal,
        hr24Change: faker.randomGenerator.integer(9999).toString(),
        imgUrl: faker.randomGenerator.boolean()
            ? null
            : faker.image.image(width: 60, height: 60, random: true),
        proposerPriority: faker.randomGenerator.integer(9999999));
  }

  Iterable<ProvenanceValidator> _getValidators(ValidatorStatus status,
      {int count = 11}) {
    return Iterable.generate(count).map((e) => _getValidator(status));
  }

  String _getMoniker() {
    return "validator-us-${faker.randomGenerator.element([
          'north',
          'east',
          'west',
          'south',
          'central'
        ])}${faker.randomGenerator.integer(9, min: 1)}-${faker.randomGenerator.integer(9)}";
  }
}
