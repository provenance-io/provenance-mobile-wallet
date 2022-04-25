import 'package:provenance_blockchain_wallet/services/client_coin_mixin.dart';
import 'package:provenance_blockchain_wallet/services/gas_fee_service/dto/gas_fee_dto.dart';
import 'package:provenance_blockchain_wallet/services/gas_fee_service/gas_fee_service.dart';
import 'package:provenance_blockchain_wallet/services/models/gas_fee.dart';
import 'package:provenance_blockchain_wallet/services/notification/client_notification_mixin.dart';
import 'package:provenance_dart/wallet.dart';

class DefaultGasFeeService extends GasFeeService
    with ClientNotificationMixin, ClientCoinMixin {
  String get _path =>
      '/service-mobile-wallet/external/api/v1/pricing/gas-price';

  @override
  Future<GasFee?> getGasFee(Coin coin) async {
    final client = await getClient(coin);
    final data = await client.get(
      _path,
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
