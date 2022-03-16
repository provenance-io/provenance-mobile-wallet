import 'package:provenance_wallet/services/gas_fee_service/dto/gas_fee_dto.dart';
import 'package:provenance_wallet/services/gas_fee_service/gas_fee_service.dart';
import 'package:provenance_wallet/services/http_client.dart';
import 'package:provenance_wallet/services/models/gas_fee.dart';
import 'package:provenance_wallet/services/notification/client_notification_mixin.dart';
import 'package:provenance_wallet/util/get.dart';

class DefaultGasFeeService extends GasFeeService with ClientNotificationMixin {
  String get _assetServiceBasePath =>
      '/service-mobile-wallet/external/api/v1/pricing/gas-price';

  @override
  Future<GasFee?> getGasFee() async {
    final data = await get<HttpClient>().get(
      _assetServiceBasePath,
      converter: (json) {
        if (json is String) {
          return null;
        }

        final gasDto = GasFeeDto.fromJson(json);

        return GasFee(dto: gasDto);
      },
    );

    notifyOnError(data);

    return data.data;
  }
}
