import 'package:provenance_dart/wallet.dart';
import 'package:provenance_wallet/screens/home/explorer/explorer_bloc.dart';
import 'package:provenance_wallet/services/client_coin_mixin.dart';
import 'package:provenance_wallet/services/http_client.dart';
import 'package:provenance_wallet/services/models/abbreviated_validator.dart';
import 'package:provenance_wallet/services/models/commission.dart';
import 'package:provenance_wallet/services/models/delegation.dart';
import 'package:provenance_wallet/services/models/detailed_validator.dart';
import 'package:provenance_wallet/services/models/provenance_validator.dart';
import 'package:provenance_wallet/services/models/rewards.dart';
import 'package:provenance_wallet/services/notification/client_notification_mixin.dart';
import 'package:provenance_wallet/services/validator_service/dtos/abbreviated_validators_dto.dart';
import 'package:provenance_wallet/services/validator_service/dtos/commission_dto.dart';
import 'package:provenance_wallet/services/validator_service/dtos/delegations_dto.dart';
import 'package:provenance_wallet/services/validator_service/dtos/detailed_validator_dto.dart';
import 'package:provenance_wallet/services/validator_service/dtos/recent_validators_dto.dart';
import 'package:provenance_wallet/services/validator_service/dtos/redelegations_dto.dart';
import 'package:provenance_wallet/services/validator_service/dtos/rewards_total_dto.dart';
import 'package:provenance_wallet/services/validator_service/validator_service.dart';

class DefaultValidatorService extends ValidatorService
    with ClientNotificationMixin, ClientCoinMixin {
  String get _validatorServiceBasePath =>
      '/service-mobile-wallet/external/api/v1/validators/recent';

  @override
  Future<List<ProvenanceValidator>> getRecentValidators(
    Coin coin,
    int pageNumber,
    ValidatorStatus status,
  ) async {
    final client = await getClient(coin);
    final data = await client.get(
      // FIXME: Replace this URL with the service's URL
      'https://service-explorer.test.provenance.io/api/v2/validators/recent?page=$pageNumber&count=30&status=${status.name}',
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
  Future<List<AbbreviatedValidator>> getAbbreviatedValidators(
    Coin coin,
    int pageNumber,
  ) async {
    final client = await getClient(coin);
    final data = await client.get(
      // FIXME: Replace this URL with the service's URL
      'https://service-explorer.test.provenance.io/api/v2/validators/recent/abbrev?page=$pageNumber&count=100&status=all',
      converter: (json) {
        if (json is String) {
          return <AbbreviatedValidator>[];
        }

        final List<AbbreviatedValidator> validators = [];

        var dtos = AbbreviatedValidatorsDto.fromJson(json);
        var test = dtos.results?.map((t) {
          return AbbreviatedValidator(dto: t);
        }).toList();

        if (test == null) {
          return <AbbreviatedValidator>[];
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
    DelegationState state,
  ) async {
    final client = await getClient(coin);
    if (DelegationState.bonded == state) {
      return _getDelegations(
        client,
        provenanceAddress,
        pageNumber,
        state,
      );
    } else {
      return _getFormerDelegations(
        client,
        provenanceAddress,
        pageNumber,
        state,
      );
    }
  }

  Future<List<Delegation>> _getDelegations(
    HttpClient client,
    String provenanceAddress,
    int pageNumber,
    DelegationState state,
  ) async {
    final data = await client.get(
      // FIXME: Replace this URL with the service's URL
      'https://service-explorer.test.provenance.io/api/v2/accounts/$provenanceAddress/${state.urlRoute}?page=$pageNumber&count=30',
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

  Future<List<Delegation>> _getFormerDelegations(
    HttpClient client,
    String provenanceAddress,
    int pageNumber,
    DelegationState state,
  ) async {
    final data = await client.get(
      // FIXME: Replace this URL with the service's URL
      'https://service-explorer.test.provenance.io/api/v2/accounts/$provenanceAddress/${state.urlRoute}?page=$pageNumber&count=30',
      converter: (json) {
        if (json is String) {
          return <Delegation>[];
        }

        final List<Delegation> delegates = [];

        var dtos = RedelegationsDto.fromJson(json);
        var test = dtos.records?.map((t) {
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
      // FIXME: Replace this URL with the service's URL
      'https://service-explorer.test.provenance.io/api/v2/accounts/$provenanceAddress/rewards',
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
      // FIXME: Replace this URL with the service's URL
      'https://service-explorer.test.provenance.io/api/v2/validators/$validatorAddress',
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
      // FIXME: Replace this URL with the service's URL
      'https://service-explorer.test.provenance.io/api/v2/validators/$validatorAddress/commission',
      converter: (json) {
        var dto = CommissionDto.fromJson(json);

        return Commission(dto: dto);
      },
    );

    notifyOnError(data);

    return data.data!;
  }
}
