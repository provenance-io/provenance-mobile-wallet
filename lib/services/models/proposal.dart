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
            .replaceAll("_", " ")
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
        totalEligibleAmount = double.tryParse(dto
                .timings!.voting!.params!.totalEligibleAmount!.amount!
                .nhashToHash()) ??
            0,
        quorumThreshold =
            double.tryParse(dto.timings!.voting!.params!.quorumThreshold!) ?? 0,
        passThreshold =
            double.tryParse(dto.timings!.voting!.params!.passThreshold!) ?? 0,
        vetoThreshold =
            double.tryParse(dto.timings!.voting!.params!.vetoThreshold!) ?? 0,
        submitTime = dto.timings!.submitTime!,
        depositEndTime = dto.timings!.depositEndTime!,
        startTime = dto.timings!.votingTime!.startTime!,
        endTime = dto.timings!.votingTime!.endTime!,
        yesCount = dto.timings!.voting!.tally!.yes!.count!,
        yesAmount = double.tryParse(dto
                .timings!.voting!.tally!.yes!.amount!.amount!
                .nhashToHash()) ??
            0,
        noCount = dto.timings!.voting!.tally!.no!.count!,
        noAmount = double.tryParse(dto
                .timings!.voting!.tally!.no!.amount!.amount!
                .nhashToHash()) ??
            0,
        noWithVetoCount = dto.timings!.voting!.tally!.noWithVeto!.count!,
        noWithVetoAmount = double.tryParse(dto
                .timings!.voting!.tally!.noWithVeto!.amount!.amount!
                .nhashToHash()) ??
            0,
        abstainCount = dto.timings!.voting!.tally!.abstain!.count!,
        abstainAmount = double.tryParse(dto
                .timings!.voting!.tally!.abstain!.amount!.amount!
                .nhashToHash()) ??
            0,
        totalCount = dto.timings!.voting!.tally!.total!.count!,
        totalAmount = double.tryParse(dto
                .timings!.voting!.tally!.total!.amount!.amount!
                .nhashToHash()) ??
            0;
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
  final double totalEligibleAmount;
  final double quorumThreshold;
  final double passThreshold;
  final double vetoThreshold;
  final DateTime submitTime;
  final DateTime depositEndTime;
  final DateTime startTime;
  final DateTime endTime;
  final int yesCount;
  final double yesAmount;
  final int noCount;
  final double noAmount;
  final int noWithVetoCount;
  final double noWithVetoAmount;
  final int abstainCount;
  final double abstainAmount;
  final int totalCount;
  final double totalAmount;

  double get initialDepositFormatted {
    return double.tryParse(initialDeposit.nhashToHash(fractionDigits: 2)) ?? 0;
  }

  double get currentDepositFormatted {
    return double.tryParse(currentDeposit.nhashToHash(fractionDigits: 2)) ?? 0;
  }

  double get neededDepositFormatted {
    return double.tryParse(neededDeposit.nhashToHash(fractionDigits: 2)) ?? 0;
  }

  String get depositPercentage {
    final percentage = (currentDepositFormatted / neededDepositFormatted) * 100;

    return "${(!percentage.isNaN ? percentage : 0).toInt()}%";
  }

  String get votePercentage {
    return "${((totalAmount / totalEligibleAmount) * 100).toStringAsFixed(2)}%";
  }
}
