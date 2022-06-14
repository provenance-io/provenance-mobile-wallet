import 'package:provenance_wallet/services/governance_service/dtos/deposit_dto.dart';

class Deposit {
  Deposit({required DepositDto dto})
      : assert(dto.blockHeight != null),
        assert(dto.type != null),
        assert(dto.amount?.amount != null),
        assert(dto.txHash != null),
        assert(dto.txTimestamp != null),
        assert(dto.voter?.address != null),
        type = dto.type!,
        amount = dto.amount!.amount!,
        blockHeight = dto.blockHeight!,
        txHash = dto.txHash!,
        txTimestamp = dto.txTimestamp!,
        voterAddress = dto.voter!.address!;
  final String voterAddress;
  final String type;
  final String amount;
  final int blockHeight;
  final String txHash;
  final DateTime txTimestamp;
}
