import 'package:provenance_blockchain_wallet/services/client_coin_mixin.dart';
import 'package:provenance_blockchain_wallet/services/models/onboarding_stat.dart';
import 'package:provenance_blockchain_wallet/services/stat_service/dtos/stat_dto.dart';
import 'package:provenance_blockchain_wallet/services/stat_service/stat_service.dart';
import 'package:provenance_dart/wallet.dart';

class DefaultStatService extends StatService with ClientCoinMixin {
  String get _statServiceBasePath =>
      '/service-mobile-wallet/external/api/v1/statistics';

  @override
  Future<OnboardingStat?> getStats(Coin coin) async {
    final client = await getClient(coin);
    final data = await client.get(
      _statServiceBasePath,
      converter: (json) => OnboardingStat(dto: StatDto.fromJson(json)),
    );

    return data.data;
  }
}
