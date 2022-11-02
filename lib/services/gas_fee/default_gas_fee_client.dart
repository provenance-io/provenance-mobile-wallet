import 'package:provenance_dart/wallet.dart';
import 'package:provenance_wallet/services/client_coin_mixin.dart';
import 'package:provenance_wallet/services/gas_fee/dto/gas_markup_dto.dart';
import 'package:provenance_wallet/services/gas_fee/gas_fee_client.dart';
import 'package:provenance_wallet/services/notification/client_notification_mixin.dart';

import '../models/gas_price.dart';

class DefaultGasFeeClient extends GasFeeClient
    with ClientNotificationMixin, ClientCoinMixin {
  String get _path =>
      '/service-mobile-wallet/external/api/v1/pricing/gas-price';

  @override
  Future<GasPrice?> getPrice(Coin coin) async {
    final client = await getClient(coin);
    final data = await client.get(
      _path,
      converter: (json) {
        if (json is String) {
          return null;
        }

        final gasDto = GasPriceDto.fromJson(json);

        return GasPrice(
          denom: gasDto.denom!,
          amountPerUnit: gasDto.amount!,
        );
      },
    );

    notifyOnError(data);

    return data.data;
  }
}
