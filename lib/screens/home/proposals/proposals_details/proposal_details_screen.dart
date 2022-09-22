import 'package:intl/intl.dart';
import 'package:provenance_wallet/common/pw_design.dart';
import 'package:provenance_wallet/common/widgets/button.dart';
import 'package:provenance_wallet/common/widgets/pw_app_bar.dart';
import 'package:provenance_wallet/common/widgets/pw_list_divider.dart';
import 'package:provenance_wallet/screens/home/proposals/proposals_details/address_card.dart';
import 'package:provenance_wallet/screens/home/proposals/proposals_details/proposal_voting_info.dart';
import 'package:provenance_wallet/screens/home/proposals/proposals_details/single_percentage_bar_chart.dart';
import 'package:provenance_wallet/screens/home/proposals/proposals_details/voting_buttons.dart';
import 'package:provenance_wallet/screens/home/proposals/proposals_flow_bloc.dart';
import 'package:provenance_wallet/screens/home/proposals/proposals_screen/proposal_vote_chip.dart';
import 'package:provenance_wallet/screens/home/proposals/proposals_screen/proposals_bloc.dart';
import 'package:provenance_wallet/screens/home/staking/staking_details/details_header.dart';
import 'package:provenance_wallet/screens/home/transactions/details_item.dart';
import 'package:provenance_wallet/services/models/proposal.dart';
import 'package:provenance_wallet/services/models/vote.dart';
import 'package:provenance_wallet/util/constants.dart';
import 'package:provenance_wallet/util/extensions/string_extensions.dart';
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
                      DetailsItem.fromStrings(
                        title: strings.proposalDetailsId,
                        value: "${_proposal.proposalId}",
                      ),
                      PwListDivider.alternate(),
                      DetailsItem.fromStrings(
                        title: strings.proposalDetailsTitleString,
                        value: _proposal.title,
                      ),
                      PwListDivider.alternate(),
                      DetailsItem.fromStrings(
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
                        DetailsItem(
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
                      DetailsItem.fromStrings(
                        title: strings.proposalDetailsSubmitTime,
                        value: _formatter.format(_proposal.submitTime),
                      ),
                      PwListDivider.alternate(),
                      DetailsItem.fromStrings(
                        title: strings.proposalDetailsDepositEndTime,
                        value: _formatter.format(_proposal.depositEndTime),
                      ),
                      PwListDivider.alternate(),
                      DetailsItem.fromStrings(
                        title: strings.proposalDetailsVotingStartTime,
                        value: _proposal.startTime.year == 1
                            ? "--"
                            : _formatter.format(_proposal.startTime),
                      ),
                      PwListDivider.alternate(),
                      DetailsItem.fromStrings(
                        title: strings.proposalDetailsVotingEndTime,
                        value: _proposal.endTime.year == 1
                            ? "--"
                            : _formatter.format(_proposal.endTime),
                      ),
                      PwListDivider.alternate(),
                      DetailsItem.withRowChildren(
                        title: strings.proposalDetailsDeposits,
                        children: [
                          PwIcon(
                            PwIcons.hashLogo,
                            size: 24,
                            color: Theme.of(context).colorScheme.neutralNeutral,
                          ),
                          HorizontalSpacer.small(),
                          PwText(
                            Strings.of(context).hashDeposited(
                              _proposal.currentDepositFormatted
                                  .toString()
                                  .formatNumber(),
                              _proposal.depositPercentage,
                            ),
                            overflow: TextOverflow.fade,
                            softWrap: false,
                            style: PwTextStyle.footnote,
                          ),
                        ],
                      ),
                      DetailsItem.withHash(
                        padding: EdgeInsets.only(bottom: Spacing.large),
                        title: strings.proposalDetailsNeededDeposit,
                        hashString: _proposal.neededDepositFormatted.toString(),
                        context: context,
                      ),
                      SinglePercentageBarChart(
                        _proposal.currentDepositFormatted,
                        _proposal.neededDepositFormatted,
                        title: strings.proposalDetailsDeposits,
                      ),
                      if (_proposal.status.toLowerCase() != depositPeriod)
                        ProposalVotingInfo(proposal: _proposal),
                    ],
                  ),
                ),
                if (_proposal.status.toLowerCase() == votingPeriod)
                  VotingButtons(
                    proposal: _proposal,
                  ),
                if (_proposal.status.toLowerCase() == depositPeriod)
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      PwListDivider.alternate(
                        indent: Spacing.large,
                      ),
                      Padding(
                        padding: EdgeInsets.only(
                          top: Spacing.large,
                          left: Spacing.large,
                          right: Spacing.large,
                          bottom: Spacing.largeX3,
                        ),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Flexible(
                              child: PwOutlinedButton(
                                strings.proposalDetailsScreenDeposit,
                                onPressed: () {
                                  get<ProposalsFlowBloc>()
                                      .showDepositReview(_proposal);
                                },
                              ),
                            )
                          ],
                        ),
                      ),
                    ],
                  )
              ],
            ),
          ),
        ),
      ],
    );
  }
}
