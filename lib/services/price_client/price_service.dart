import 'package:provenance_dart/wallet.dart';
import 'package:provenance_wallet/services/client_coin_mixin.dart';
import 'package:provenance_wallet/services/models/price.dart';
import 'package:provenance_wallet/services/price_client/dtos/price_dto.dart';

class PriceClient with ClientCoinMixin {
  String get _assetServiceBasePathv1 => '/service-pricing-engine/';

  Future<List<Price>> getAssetPrices(
    Coin coin,
    List<String> denominations,
  ) async {
    final client = await getClient(coin);
    final data = await client.get(
      '$_assetServiceBasePathv1/service-pricing-engine/api/v1/pricing/marker/denom/list?denom[]=${denominations.join(",")}',
      listConverter: (json) {
        if (json is String) {
          return <Price>[];
        }

        final List<Price> prices = json.map((t) {
          return Price(dto: PriceDto.fromJson(t));
        }).toList();

        return prices;
      },
    );

    return data.data ?? [];
  }
}
