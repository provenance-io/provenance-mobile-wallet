import 'package:provenance_dart/wallet.dart';
import 'package:provenance_wallet/services/client_coin_mixin.dart';
import 'package:provenance_wallet/services/models/commission.dart';
import 'package:provenance_wallet/services/models/delegation.dart';
import 'package:provenance_wallet/services/models/detailed_validator.dart';
import 'package:provenance_wallet/services/models/provenance_validator.dart';
import 'package:provenance_wallet/services/models/rewards.dart';
import 'package:provenance_wallet/services/notification/client_notification_mixin.dart';
import 'package:provenance_wallet/services/validator_client/dtos/commission_dto.dart';
import 'package:provenance_wallet/services/validator_client/dtos/delegations_dto.dart';
import 'package:provenance_wallet/services/validator_client/dtos/detailed_validator_dto.dart';
import 'package:provenance_wallet/services/validator_client/dtos/recent_validators_dto.dart';
import 'package:provenance_wallet/services/validator_client/dtos/rewards_total_dto.dart';
import 'package:provenance_wallet/services/validator_client/validator_client.dart';

class DefaultValidatorClient extends ValidatorClient
    with ClientNotificationMixin, ClientCoinMixin {
  String get _validatorServiceBasePath =>
      '/service-mobile-wallet/external/api/v1/explorer';

  @override
  Future<List<ProvenanceValidator>> getRecentValidators(
    Coin coin,
    int pageNumber,
  ) async {
    final client = await getClient(coin);
    final data = await client.get(
      '$_validatorServiceBasePath/validators?count=50',
      converter: (json) {
        if (json is String) {
          return <ProvenanceValidator>[];
        }

        final List<ProvenanceValidator> validators = [];

        var dtos = RecentValidatorsDto.fromJson(json);
        var test = dtos.results?.map((t) {
          return ProvenanceValidator(dto: t);
        }).toList();

        if (test == null) {
          return <ProvenanceValidator>[];
        }

        validators.addAll(test);

        return validators;
      },
    );

    notifyOnError(data);

    return data.data ?? [];
  }

  @override
  Future<List<Delegation>> getDelegations(
    Coin coin,
    String provenanceAddress,
    int pageNumber,
  ) async {
    final client = await getClient(coin);
    final data = await client.get(
      '$_validatorServiceBasePath/delegations/$provenanceAddress?page=$pageNumber&count=30',
      converter: (json) {
        if (json is String) {
          return <Delegation>[];
        }

        final List<Delegation> delegates = [];

        var dtos = DelegationsDto.fromJson(json);
        var test = dtos.results?.map((t) {
          return Delegation(dto: t);
        }).toList();

        if (test == null) {
          return <Delegation>[];
        }

        delegates.addAll(test);

        return delegates;
      },
    );

    notifyOnError(data);

    return data.data ?? [];
  }

  @override
  Future<List<Rewards>> getRewards(
    Coin coin,
    String provenanceAddress,
  ) async {
    final client = await getClient(coin);
    final data = await client.get(
      '$_validatorServiceBasePath/rewards/$provenanceAddress',
      converter: (json) {
        var dto = RewardsTotalDto.fromJson(json);

        final List<Rewards> rewards = [];
        var test = dto.rewards?.map((e) => Rewards(dto: e)).toList();

        if (test == null) {
          return rewards;
        }

        rewards.addAll(test);

        return rewards;
      },
    );

    notifyOnError(data);

    return data.data ?? [];
  }

  @override
  Future<DetailedValidator> getDetailedValidator(
    Coin coin,
    String validatorAddress,
  ) async {
    final client = await getClient(coin);
    final data = await client.get(
      '$_validatorServiceBasePath/validators/$validatorAddress',
      converter: (json) {
        var dto = DetailedValidatorDto.fromJson(json);

        return DetailedValidator(dto: dto);
      },
    );

    notifyOnError(data);

    return data.data!;
  }

  @override
  Future<Commission> getValidatorCommission(
    Coin coin,
    String validatorAddress,
  ) async {
    final client = await getClient(coin);
    final data = await client.get(
      '$_validatorServiceBasePath/validators/$validatorAddress/commission',
      converter: (json) {
        var dto = CommissionDto.fromJson(json);

        return Commission(dto: dto);
      },
    );

    notifyOnError(data);

    return data.data!;
  }
}
