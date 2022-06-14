import 'package:provenance_wallet/services/governance_service/dtos/proposal_dto.dart';
import 'package:provenance_wallet/util/strings.dart';

class Proposal {
  Proposal({required ProposalDto dto})
      : assert(dto.header?.proposalId != null),
        assert(dto.header?.status != null),
        assert(dto.header?.title != null),
        assert(dto.header?.description != null),
        assert(dto.header?.type != null),
        assert(dto.header?.proposer?.address != null),
        assert(dto.timings?.deposit?.initial != null),
        assert(dto.timings?.deposit?.current != null),
        assert(dto.timings?.deposit?.needed != null),
        assert(dto.timings?.deposit?.denom != null),
        assert(dto.timings?.voting?.params?.quorumThreshold != null),
        assert(dto.timings?.voting?.params?.passThreshold != null),
        assert(dto.timings?.voting?.params?.vetoThreshold != null),
        assert(dto.timings?.submitTime != null),
        assert(dto.timings?.depositEndTime != null),
        assert(dto.timings?.votingTime?.startTime != null),
        assert(dto.timings?.votingTime?.endTime != null),
        assert(dto.timings?.voting?.tally?.yes?.count != null),
        assert(dto.timings?.voting?.tally?.no?.count != null),
        assert(dto.timings?.voting?.tally?.noWithVeto?.count != null),
        assert(dto.timings?.voting?.tally?.abstain?.count != null),
        assert(dto.timings?.voting?.tally?.total?.count != null),
        assert(dto.timings?.voting?.tally?.total?.amount?.amount != null),
        proposalId = dto.header!.proposalId!,
        status = dto.header!.status!
            .replaceAll("PROPOSAL_STATUS_", "")
            .toLowerCase()
            .capitalize(),
        title = dto.header!.title!,
        description = dto.header!.description!,
        type = dto.header!.type!,
        proposerAddress = dto.header!.proposer!.address!,
        initialDeposit = dto.timings!.deposit!.initial!,
        currentDeposit = dto.timings!.deposit!.current!,
        neededDeposit = dto.timings!.deposit!.needed!,
        denomDeposit = dto.timings!.deposit!.denom!,
        totalEligibleAmount =
            dto.timings!.voting!.params!.totalEligibleAmount!.amount!,
        quorumThreshold = dto.timings!.voting!.params!.quorumThreshold!,
        passThreshold = dto.timings!.voting!.params!.passThreshold!,
        vetoThreshold = dto.timings!.voting!.params!.vetoThreshold!,
        submitTime = dto.timings!.submitTime!,
        depositEndTime = dto.timings!.depositEndTime!,
        startTime = dto.timings!.votingTime!.startTime!,
        endTime = dto.timings!.votingTime!.endTime!,
        yesCount = dto.timings!.voting!.tally!.yes!.count!,
        noCount = dto.timings!.voting!.tally!.no!.count!,
        noWithVetoCount = dto.timings!.voting!.tally!.noWithVeto!.count!,
        abstainCount = dto.timings!.voting!.tally!.abstain!.count!,
        totalCount = dto.timings!.voting!.tally!.total!.count!,
        totalAmount = dto.timings!.voting!.tally!.total!.amount!.amount!;
  final int proposalId;
  final String status;
  final String proposerAddress;
  final String type;
  final String title;
  final String description;
  final String initialDeposit;
  final String currentDeposit;
  final String neededDeposit;
  final String denomDeposit;
  final String totalEligibleAmount;
  final String quorumThreshold;
  final String passThreshold;
  final String vetoThreshold;
  final DateTime submitTime;
  final DateTime depositEndTime;
  final DateTime startTime;
  final DateTime endTime;
  final int yesCount;
  final int noCount;
  final int noWithVetoCount;
  final int abstainCount;
  final int totalCount;
  final String totalAmount;
}
