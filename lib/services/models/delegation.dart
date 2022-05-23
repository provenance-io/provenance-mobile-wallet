import 'package:decimal/decimal.dart';
import 'package:provenance_wallet/services/validator_service/dtos/delegation_dto.dart';

class Delegation {
  Delegation({required DelegationDto dto})
      : assert(dto.delegatorAddr != null),
        assert(dto.validatorSrcAddr != null),
        assert(dto.amount?.amount != null),
        assert(dto.amount?.denom != null),
        address = dto.delegatorAddr!,
        sourceAddress = dto.validatorSrcAddr!,
        destinationAddress = dto.validatorDstAddr,
        amount = dto.amount!.amount!,
        denom = dto.amount!.denom!,
        initialAmount = dto.initialBal?.amount,
        initialDenom = dto.initialBal?.denom,
        block = dto.block,
        shares = dto.shares,
        endTime = dto.endTime != null
            ? DateTime.fromMillisecondsSinceEpoch(dto.endTime!)
            : null;

  Delegation.fake({
    required this.address,
    required this.sourceAddress,
    this.destinationAddress,
    required this.amount,
    required this.denom,
    this.initialAmount,
    this.initialDenom,
    this.block,
    this.endTime,
    this.shares,
  });
  final String address;
  final String sourceAddress;
  final String? destinationAddress;
  final String amount;
  final String denom;
  final String? initialAmount;
  final String? initialDenom;
  final int? block;
  final DateTime? endTime;
  final String? shares;

  String get displayDenom {
    // TODO: Consolidate hash conversion somewhere?
    return "${(Decimal.parse(amount) / Decimal.fromInt(10).pow(9)).toDecimal(scaleOnInfinitePrecision: 9).toString()} hash";
  }
}
