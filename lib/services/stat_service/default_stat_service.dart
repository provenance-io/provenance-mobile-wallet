import 'package:provenance_wallet/services/models/onboarding_stat.dart';
import 'package:provenance_wallet/services/stat_service/dtos/stat_dto.dart';
import 'package:provenance_wallet/services/stat_service/stat_service.dart';
import 'package:provenance_wallet/services/http_client.dart';
import 'package:provenance_wallet/util/get.dart';

class DefaultStatService extends StatService {
  String get _statServiceBasePath =>
      '/service-mobile-wallet/external/api/v1/statistics';

  @override
  Future<OnboardingStat?> getStats() async {
    final data = await get<HttpClient>().get(
      _statServiceBasePath,
      converter: (json) => OnboardingStat(dto: StatDto.fromJson(json)),
    );

    return data.data;
  }
}
