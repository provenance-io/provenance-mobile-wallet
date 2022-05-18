import 'package:faker/faker.dart';
import 'package:provenance_dart/wallet.dart';
import 'package:provenance_wallet/screens/home/explorer/explorer_bloc.dart';
import 'package:provenance_wallet/services/models/provenance_validator.dart';
import 'package:provenance_wallet/services/models/validator_delegate.dart';
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
  Future<List<ValidatorDelegate>> getDelegations(
    Coin coin,
    String provenanceAddress,
    int pageNumber,
    ValidatorType type,
  ) async {
    await Future.delayed(Duration(milliseconds: 500));
    return _getDelegates(type, provenanceAddress).toList();
  }

  ValidatorDelegate _getDelegate(ValidatorType type, String address) {
    var sourceAddress =
        faker.randomGenerator.fromCharSet(_addressCharSet, _addressLength);
    var amount = faker.randomGenerator.integer(9999999).toString();
    switch (type) {
      case ValidatorType.delegations:
        return ValidatorDelegate.fake(
            address: address,
            sourceAddress: sourceAddress,
            amount: amount,
            denom: 'hash',
            shares: amount);
      case ValidatorType.redelegations:
        return ValidatorDelegate.fake(
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
      case ValidatorType.unbonding:
        return ValidatorDelegate.fake(
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

  Iterable<ValidatorDelegate> _getDelegates(ValidatorType type, String address,
      {int count = 4}) {
    return Iterable.generate(count).map((e) => _getDelegate(type, address));
  }

  ProvenanceValidator _getValidator(ValidatorStatus status) {
    return ProvenanceValidator.fake(
        moniker: "validator-us-${faker.randomGenerator.element([
              'north',
              'east',
              'west',
              'south',
              'central'
            ])}${faker.randomGenerator.integer(9, min: 1)}-${faker.randomGenerator.integer(9)}",
        addressId:
            faker.randomGenerator.fromCharSet(_addressCharSet, _addressLength),
        consensusAddress:
            faker.randomGenerator.fromCharSet(_addressCharSet, _addressLength),
        commission: faker.randomGenerator.decimal().toString(),
        delegators: faker.randomGenerator.integer(13, min: 1),
        status: status.toString(),
        uptime: faker.randomGenerator.integer(100, min: 90),
        bondedTokensCount: faker.randomGenerator.integer(9999999).toString(),
        bondedTokensDenom: 'nhash',
        bondedTokensTotal: '$_tokenTotal',
        votingPowerCount: faker.randomGenerator.integer(9999999),
        votingPowerTotal: _tokenTotal,
        hr24Change: faker.randomGenerator.integer(9999).toString(),
        imgUrl: faker.randomGenerator.boolean()
            ? null
            : faker.image.image(width: 64, height: 64, random: true),
        proposerPriority: faker.randomGenerator.integer(9999999));
  }

  Iterable<ProvenanceValidator> _getValidators(ValidatorStatus status,
      {int count = 11}) {
    return Iterable.generate(count).map((e) => _getValidator(status));
  }
}
