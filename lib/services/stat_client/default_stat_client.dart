import 'package:provenance_dart/wallet.dart';
import 'package:provenance_wallet/services/client_coin_mixin.dart';
import 'package:provenance_wallet/services/models/onboarding_stat.dart';
import 'package:provenance_wallet/services/stat_client/dtos/stat_dto.dart';
import 'package:provenance_wallet/services/stat_client/stat_client.dart';

class DefaultStatClient extends StatClient with ClientCoinMixin {
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
