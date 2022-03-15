import 'package:provenance_wallet/services/price_service/dtos/price_dto.dart';

class Price {
  Price({required PriceDto dto})
      : assert(dto.usdPrice != null),
        assert(dto.markerDenom != null),
        denomination = dto.markerDenom!,
        usdPrice = dto.usdPrice!;

  final String denomination;
  final double usdPrice;
}
