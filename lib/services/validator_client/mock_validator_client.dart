import 'package:faker/faker.dart';
import 'package:provenance_dart/wallet.dart';
import 'package:provenance_wallet/screens/home/staking/staking_screen_bloc.dart';
import 'package:provenance_wallet/services/models/commission.dart';
import 'package:provenance_wallet/services/models/delegation.dart';
import 'package:provenance_wallet/services/models/detailed_validator.dart';
import 'package:provenance_wallet/services/models/provenance_validator.dart';
import 'package:provenance_wallet/services/models/rewards.dart';
import 'package:provenance_wallet/services/validator_client/validator_client.dart';

class MockValidatorClient extends ValidatorClient {
  final faker = Faker();
  static const _tokenTotal = 5802852327538;
  static const _addressCharSet = '1234567890abcdefghijklmnopqrstuvwzyz';
  static const _addressLength = 41;

  @override
  Future<List<ProvenanceValidator>> getRecentValidators(
    Coin coin,
    int pageNumber,
  ) async {
    await Future.delayed(Duration(milliseconds: 500));
    return _getValidators().toList();
  }

  @override
  Future<List<Delegation>> getDelegations(
    Coin coin,
    String provenanceAddress,
    int pageNumber,
  ) async {
    await Future.delayed(Duration(milliseconds: 500));
    return _getDelegates(provenanceAddress).toList();
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
        bondedTokensCount: faker.randomGenerator.integer(99999999),
        bondedTokensDenom: 'nhash',
        selfBondedCount: faker.randomGenerator.integer(99999999),
        selfBondedDenom: 'nhash',
        delegatorBondedCount: faker.randomGenerator.integer(99999999),
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

  Delegation _getDelegate(String address) {
    var sourceAddress =
        faker.randomGenerator.fromCharSet(_addressCharSet, _addressLength);
    var amount = faker.randomGenerator.integer(9999999).toString();
    return Delegation.fake(
        address: address,
        sourceAddress: sourceAddress,
        amount: amount,
        denom: 'hash',
        shares: amount);
  }

  Iterable<Delegation> _getDelegates(String address, {int count = 4}) {
    return Iterable.generate(count).map((e) => _getDelegate(address));
  }

  ProvenanceValidator _getValidator() {
    final commission = faker.randomGenerator.decimal();
    return ProvenanceValidator.fake(
        moniker: _getMoniker(),
        addressId:
            faker.randomGenerator.fromCharSet(_addressCharSet, _addressLength),
        consensusAddress:
            faker.randomGenerator.fromCharSet(_addressCharSet, _addressLength),
        commission: commission.toString(),
        rawCommission: commission,
        delegators: faker.randomGenerator.integer(13, min: 1),
        status: faker.randomGenerator.element(ValidatorStatus.values),
        uptime: faker.randomGenerator.decimal(scale: 100, min: 90),
        bondedTokensCount: faker.randomGenerator.integer(9999999),
        bondedTokensDenom: 'nhash',
        bondedTokensTotal: _tokenTotal,
        votingPowerCount: faker.randomGenerator.integer(9999999),
        votingPowerTotal: _tokenTotal,
        hr24Change: faker.randomGenerator.integer(9999).toString(),
        imgUrl: faker.randomGenerator.boolean()
            ? null
            : faker.image.image(width: 60, height: 60, random: true),
        proposerPriority: faker.randomGenerator.integer(9999999));
  }

  Iterable<ProvenanceValidator> _getValidators({int count = 11}) {
    return Iterable.generate(count).map((e) => _getValidator());
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
