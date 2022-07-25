import 'package:intl/intl.dart';
import 'package:provenance_wallet/common/pw_design.dart';
import 'package:provenance_wallet/common/widgets/pw_app_bar.dart';
import 'package:provenance_wallet/common/widgets/pw_list_divider.dart';
import 'package:provenance_wallet/screens/home/proposals/proposals_details/address_card.dart';
import 'package:provenance_wallet/screens/home/proposals/proposals_details/single_percentage_bar_chart.dart';
import 'package:provenance_wallet/screens/home/proposals/proposals_details/voting_buttons.dart';
import 'package:provenance_wallet/screens/home/proposals/proposals_screen/proposal_vote_chip.dart';
import 'package:provenance_wallet/screens/home/proposals/proposals_screen/proposals_bloc.dart';
import 'package:provenance_wallet/screens/home/staking/staking_details/details_header.dart';
import 'package:provenance_wallet/screens/home/transactions/details_item.dart';
import 'package:provenance_wallet/services/models/proposal.dart';
import 'package:provenance_wallet/services/models/vote.dart';
import 'package:provenance_wallet/util/get.dart';
import 'package:provenance_wallet/util/strings.dart';

class ProposalDetailsScreen extends StatefulWidget {
  const ProposalDetailsScreen({
    Key? key,
    required this.selectedProposal,
    this.vote,
  }) : super(key: key);

  final Proposal selectedProposal;
  final Vote? vote;

  @override
  State<StatefulWidget> createState() => _ProposalDetailsScreenState();
}

class _ProposalDetailsScreenState extends State<ProposalDetailsScreen> {
  final _formatter = DateFormat.yMMMd('en_US').add_Hms();
  late final Proposal _proposal;
  @override
  void initState() {
    _proposal = widget.selectedProposal;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final strings = Strings.of(context);
    return Stack(
      children: [
        Container(
          color: Theme.of(context).colorScheme.neutral750,
          child: Scaffold(
            appBar: PwAppBar(
              title: Strings.of(context)
                  .proposalDetailsTitle(_proposal.proposalId),
              leadingIcon: PwIcons.back,
              style: PwTextStyle.footnote,
            ),
            body: Column(
              children: [
                Expanded(
                  child: ListView(
                    padding: EdgeInsets.symmetric(
                      horizontal: Spacing.large,
                    ),
                    children: [
                      VerticalSpacer.largeX3(),
                      AddressCard(
                        title: strings.proposalVoteConfirmProposerAddress,
                        address: widget.selectedProposal.proposerAddress,
                      ),
                      DetailsHeader(
                        title: strings.proposalDetailsProposalInformation,
                      ),
                      PwListDivider.alternate(),
                      DetailsItem.alternateStrings(
                        title: strings.proposalDetailsId,
                        value: "${_proposal.proposalId}",
                      ),
                      PwListDivider.alternate(),
                      DetailsItem.alternateStrings(
                        title: strings.proposalDetailsTitleString,
                        value: _proposal.title,
                      ),
                      PwListDivider.alternate(),
                      DetailsItem.alternateStrings(
                        title: strings.proposalDetailsDescription,
                        value: _proposal.description,
                      ),
                      PwListDivider.alternate(),
                      DetailsItem.withRowChildren(
                        title: strings.proposalDetailsStatus,
                        children: [
                          Icon(
                            Icons.brightness_1,
                            color: get<ProposalsBloc>()
                                .getColor(_proposal.status, context),
                            size: 8,
                          ),
                          HorizontalSpacer.xSmall(),
                          PwText(
                            _proposal.status.capitalize(),
                            style: PwTextStyle.footnote,
                            overflow: TextOverflow.fade,
                            softWrap: false,
                          ),
                        ],
                      ),
                      PwListDivider.alternate(),
                      if (widget.vote != null)
                        DetailsItem.alternateChild(
                          title: strings.proposalDetailsMyStatus,
                          endChild: ProposalVoteChip(
                            vote: widget.vote!,
                          ),
                        ),
                      if (widget.vote != null) PwListDivider.alternate(),
                      DetailsHeader(
                        title: strings.proposalDetailsProposalTiming,
                      ),
                      PwListDivider.alternate(),
                      DetailsItem.alternateStrings(
                        title: strings.proposalDetailsSubmitTime,
                        value: _formatter.format(_proposal.submitTime),
                      ),
                      PwListDivider.alternate(),
                      DetailsItem.alternateStrings(
                        title: strings.proposalDetailsDepositEndTime,
                        value: _formatter.format(_proposal.depositEndTime),
                      ),
                      PwListDivider.alternate(),
                      DetailsItem.alternateStrings(
                        title: strings.proposalDetailsVotingStartTime,
                        value: _proposal.startTime.year == 1
                            ? "--"
                            : _formatter.format(_proposal.startTime),
                      ),
                      PwListDivider.alternate(),
                      DetailsItem.alternateStrings(
                        title: strings.proposalDetailsVotingEndTime,
                        value: _proposal.endTime.year == 1
                            ? "--"
                            : _formatter.format(_proposal.endTime),
                      ),
                      PwListDivider.alternate(),
                      DetailsItem.withHash(
                        title: strings.proposalDetailsDeposits,
                        hashString: Strings.of(context).hashDeposited(
                          _proposal.currentDepositFormatted
                              .toString()
                              .formatNumber(),
                          _proposal.depositPercentage,
                        ),
                        context: context,
                      ),
                      DetailsItem.withHash(
                        padding: EdgeInsets.only(bottom: Spacing.large),
                        title: strings.proposalDetailsNeededDeposit,
                        hashString: strings.hashAmount(
                          _proposal.neededDepositFormatted.toString(),
                        ),
                        context: context,
                      ),
                      SinglePercentageBarChart(
                        _proposal.currentDepositFormatted,
                        _proposal.neededDepositFormatted,
                        title: strings.proposalDetailsDeposits,
                      ),
                      DetailsHeader(
                        title: strings.proposalDetailsThresholdDetails,
                      ),
                      PwListDivider.alternate(),
                      DetailsItem.alternateStrings(
                        title: strings.proposalDetailsQuorumThreshold,
                        value:
                            "${(_proposal.quorumThreshold * 100).toStringAsFixed(2)}%",
                      ),
                      PwListDivider.alternate(),
                      DetailsItem.alternateStrings(
                        title: strings.proposalDetailsPassThreshold,
                        value:
                            "${(_proposal.passThreshold * 100).toStringAsFixed(2)}%",
                      ),
                      PwListDivider.alternate(),
                      DetailsItem.alternateStrings(
                        title: strings.proposalDetailsVetoThreshold,
                        value:
                            "${(_proposal.vetoThreshold * 100).toStringAsFixed(2)}%",
                      ),
                      PwListDivider.alternate(),
                      VerticalSpacer.large(),
                      SinglePercentageBarChart(
                        _proposal.totalAmount,
                        _proposal.totalEligibleAmount,
                        title: strings.proposalDetailsPercentVoted,
                      ),
                      DetailsHeader(
                        title: strings.proposalDetailsProposalVoting,
                      ),
                      PwListDivider.alternate(),
                      VerticalSpacer.large(),
                      SinglePercentageBarChart(
                        _proposal.yesAmount,
                        _proposal.totalAmount,
                        title: strings.proposalsScreenVoted(
                          strings.proposalDetailsYes,
                        ),
                      ),
                      VerticalSpacer.large(),
                      SinglePercentageBarChart(
                        _proposal.noAmount,
                        _proposal.totalAmount,
                        title: strings.proposalsScreenVoted(
                          strings.proposalDetailsNo,
                        ),
                        color: Theme.of(context).colorScheme.error,
                      ),
                      VerticalSpacer.large(),
                      SinglePercentageBarChart(
                        _proposal.noWithVetoAmount,
                        _proposal.totalAmount,
                        title: strings.proposalsScreenVoted(
                          strings.proposalDetailsNoWithVeto,
                        ),
                        color: Theme.of(context).colorScheme.notice350,
                      ),
                      VerticalSpacer.large(),
                      SinglePercentageBarChart(
                        _proposal.abstainAmount,
                        _proposal.totalAmount,
                        title: strings.proposalsScreenVoted(
                          strings.proposalDetailsAbstain,
                        ),
                        color: Theme.of(context).colorScheme.neutral600,
                      ),
                      DetailsItem.alternateChild(
                        title: strings.proposalDetailsTotalVotes,
                        endChild: PwText(
                          _proposal.totalAmount
                              .toInt()
                              .toString()
                              .formatNumber(),
                          style: PwTextStyle.bodyBold,
                        ),
                      ),
                    ],
                  ),
                ),
                // if (_proposal.status.toLowerCase() == votingPeriod)
                VotingButtons(
                  proposal: _proposal,
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
