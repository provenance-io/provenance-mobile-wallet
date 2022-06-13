import 'package:provenance_wallet/services/governance_service/dtos/height_dto.dart';

class BlockHeight {
  BlockHeight({required HeightDto dto})
      : assert(dto.height != null),
        assert(dto.hash != null),
        assert(dto.time != null),
        assert(dto.proposerAddress != null),
        assert(dto.moniker != null),
        assert(dto.votingPower?.count != null),
        assert(dto.votingPower?.total != null),
        assert(dto.validatorCount?.count != null),
        assert(dto.validatorCount?.total != null),
        assert(dto.txNum != null),
        height = dto.height!,
        hash = dto.hash!,
        time = dto.time!,
        proposerAddress = dto.proposerAddress!,
        moniker = dto.moniker!,
        votingPowerCount = dto.votingPower!.count!,
        votingPowerTotal = dto.votingPower!.total!,
        validatorCount = dto.validatorCount!.count!,
        validatorTotal = dto.validatorCount!.total!,
        txNum = dto.txNum!,
        icon = dto.icon;

  final int height;
  final String hash;
  final DateTime time;
  final String proposerAddress;
  final String moniker;
  final String? icon;
  final int votingPowerCount;
  final int votingPowerTotal;
  final int validatorCount;
  final int validatorTotal;
  final int txNum;
}
