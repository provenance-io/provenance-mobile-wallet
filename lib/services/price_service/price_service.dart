import 'package:provenance_wallet/services/http_client.dart';
import 'package:provenance_wallet/services/models/price.dart';
import 'package:provenance_wallet/services/price_service/dtos/price_dto.dart';
import 'package:provenance_wallet/util/get.dart';

class PriceService {
  String get _assetServiceBasePathv1 => '/service-pricing-engine/';

  Future<List<Price>> getAssetPrices(
    List<String> denominations,
  ) async {
    final data = await get<HttpClient>().get(
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
