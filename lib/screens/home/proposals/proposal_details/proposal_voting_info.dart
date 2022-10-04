import 'package:provenance_wallet/common/pw_design.dart';
import 'package:provenance_wallet/common/widgets/pw_list_divider.dart';
import 'package:provenance_wallet/screens/home/proposals/proposal_details/single_percentage_bar_chart.dart';
import 'package:provenance_wallet/screens/home/staking/staking_details/details_header.dart';
import 'package:provenance_wallet/screens/home/transactions/details_item.dart';
import 'package:provenance_wallet/services/models/proposal.dart';
import 'package:provenance_wallet/util/extensions/string_extensions.dart';
import 'package:provenance_wallet/util/strings.dart';

class ProposalVotingInfo extends StatelessWidget {
  const ProposalVotingInfo({Key? key, required this.proposal})
      : super(key: key);
  final Proposal proposal;

  @override
  Widget build(BuildContext context) {
    final strings = Strings.of(context);
    return Column(
      children: [
        DetailsHeader(
          title: strings.proposalDetailsThresholdDetails,
        ),
        PwListDivider.alternate(),
        DetailsItem.fromStrings(
          title: strings.proposalDetailsQuorumThreshold,
          value: "${(proposal.quorumThreshold * 100).toStringAsFixed(2)}%",
        ),
        PwListDivider.alternate(),
        DetailsItem.fromStrings(
          title: strings.proposalDetailsPassThreshold,
          value: "${(proposal.passThreshold * 100).toStringAsFixed(2)}%",
        ),
        PwListDivider.alternate(),
        DetailsItem.fromStrings(
          title: strings.proposalDetailsVetoThreshold,
          value: "${(proposal.vetoThreshold * 100).toStringAsFixed(2)}%",
        ),
        PwListDivider.alternate(),
        VerticalSpacer.large(),
        SinglePercentageBarChart(
          proposal.totalAmount,
          proposal.totalEligibleAmount,
          title: strings.proposalDetailsPercentVoted,
        ),
        DetailsHeader(
          title: strings.proposalDetailsProposalVoting,
        ),
        PwListDivider.alternate(),
        VerticalSpacer.large(),
        SinglePercentageBarChart(
          proposal.yesAmount,
          proposal.totalAmount,
          title: strings.proposalsScreenVoted(
            strings.proposalDetailsYes,
          ),
        ),
        VerticalSpacer.large(),
        SinglePercentageBarChart(
          proposal.noAmount,
          proposal.totalAmount,
          title: strings.proposalsScreenVoted(
            strings.proposalDetailsNo,
          ),
          color: Theme.of(context).colorScheme.error,
        ),
        VerticalSpacer.large(),
        SinglePercentageBarChart(
          proposal.noWithVetoAmount,
          proposal.totalAmount,
          title: strings.proposalsScreenVoted(
            strings.proposalDetailsNoWithVeto,
          ),
          color: Theme.of(context).colorScheme.notice350,
        ),
        VerticalSpacer.large(),
        SinglePercentageBarChart(
          proposal.abstainAmount,
          proposal.totalAmount,
          title: strings.proposalsScreenVoted(
            strings.proposalDetailsAbstain,
          ),
          color: Theme.of(context).colorScheme.neutral600,
        ),
        DetailsItem(
          title: strings.proposalDetailsTotalVotes,
          endChild: PwText(
            proposal.totalAmount.toInt().toString().formatNumber(),
            style: PwTextStyle.bodyBold,
          ),
        ),
        VerticalSpacer.largeX3(),
      ],
    );
  }
}
