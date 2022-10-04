import 'package:provenance_wallet/services/gas_fee/dto/gas_fee_dto.dart';

class GasFee {
  GasFee({required GasFeeDto dto})
      : assert(dto.gasPrice != null),
        assert(dto.gasPriceDenom != null),
        denom = dto.gasPriceDenom!,
        amount = dto.gasPrice!;

  GasFee.fake({
    required this.denom,
    required this.amount,
  });

  final String denom;
  final int amount;
}
