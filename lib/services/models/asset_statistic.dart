import 'package:provenance_wallet/services/asset_service/dtos/asset_statistics_dto.dart';

class AssetStatistics {
  AssetStatistics({required AssetStatisticsDto dto})
      : assert(dto.amountChange != null),
        assert(dto.dayHigh != null),
        assert(dto.dayLow != null),
        assert(dto.dayVolume != null),
        amountChange = dto.amountChange!,
        dayHigh = dto.dayHigh!,
        dayLow = dto.dayLow!,
        dayVolume = dto.dayVolume!;

  AssetStatistics.fake({
    required this.amountChange,
    required this.dayVolume,
    required this.dayHigh,
    required this.dayLow,
  });

  final double amountChange;
  final int dayVolume;
  final double dayHigh;
  final double dayLow;
}
