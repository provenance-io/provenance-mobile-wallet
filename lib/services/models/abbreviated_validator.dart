import 'package:provenance_wallet/services/validator_service/dtos/abbreviated_validator_dto.dart';

class AbbreviatedValidator {
  AbbreviatedValidator({required AbbreviatedValidatorDto dto})
      : assert(dto.addressId != null),
        assert(dto.commission != null),
        assert(dto.moniker != null),
        assert(double.tryParse(dto.commission!) != null),
        moniker = dto.moniker!,
        address = dto.addressId!,
        commission = '${double.tryParse(dto.commission!)! * 100}%',
        imgUrl = dto.imgUrl;

  AbbreviatedValidator.fake({
    required this.moniker,
    required this.address,
    required this.commission,
    this.imgUrl,
  });
  final String moniker;
  final String address;
  final String commission;
  final String? imgUrl;
}
