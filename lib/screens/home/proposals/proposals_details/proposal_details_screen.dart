import 'package:intl/intl.dart';
import 'package:provenance_wallet/common/pw_design.dart';
import 'package:provenance_wallet/common/widgets/pw_app_bar.dart';
import 'package:provenance_wallet/common/widgets/pw_list_divider.dart';
import 'package:provenance_wallet/screens/home/proposals/proposals_details/single_percentage_bar_chart.dart';
import 'package:provenance_wallet/screens/home/proposals/proposals_details/voting_buttons.dart';
import 'package:provenance_wallet/screens/home/proposals/proposals_screen/proposal_vote_chip.dart';
import 'package:provenance_wallet/screens/home/proposals/proposals_screen/proposals_bloc.dart';
import 'package:provenance_wallet/screens/home/staking/staking_details/details_header.dart';
import 'package:provenance_wallet/screens/home/transactions/details_item.dart';
import 'package:provenance_wallet/services/models/proposal.dart';
import 'package:provenance_wallet/services/models/vote.dart';
import 'package:provenance_wallet/util/address_util.dart';
import 'package:provenance_wallet/util/constants.dart';
import 'package:provenance_wallet/util/get.dart';
import 'package:provenance_wallet/util/strings.dart';
import 'package:url_launcher/url_launcher.dart';

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
  bool _isActive = false;
  late final Proposal _proposal;
  @override
  void initState() {
    _proposal = widget.selectedProposal;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Container(
          color: Theme.of(context).colorScheme.neutral750,
          child: Scaffold(
            appBar: PwAppBar(
              title: Strings.proposalDetailsTitle(_proposal.proposalId),
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
                      Container(
                        padding: EdgeInsets.all(Spacing.large),
                        decoration: BoxDecoration(
                          border: Border.all(
                            color: Theme.of(context).colorScheme.neutral700,
                          ),
                          borderRadius: BorderRadius.circular(4),
                          color: Theme.of(context).colorScheme.neutral700,
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            HorizontalSpacer.medium(),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  PwText(
                                    Strings.proposalVoteConfirmProposerAddress,
                                    style: PwTextStyle.body,
                                    color: PwColor.neutralNeutral,
                                    textAlign: TextAlign.left,
                                    overflow: TextOverflow.fade,
                                  ),
                                  HorizontalSpacer.xSmall(),
                                  GestureDetector(
                                    onTap: () async {
                                      setState(() {
                                        _isActive = !_isActive;
                                      });
                                    },
                                    child: PwText(
                                      _isActive
                                          ? widget
                                              .selectedProposal.proposerAddress
                                          : abbreviateAddressAlt(widget
                                              .selectedProposal
                                              .proposerAddress),
                                      color: PwColor.neutral200,
                                      style: PwTextStyle.footnote,
                                      softWrap: false,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            GestureDetector(
                              behavior: HitTestBehavior.opaque,
                              onTap: () async {
                                final url = get<ProposalsBloc>()
                                    .getExplorerUrl(_proposal.proposerAddress);
                                if (await canLaunch(url)) {
                                  await launch(url);
                                } else {
                                  throw 'Could not launch $url';
                                }
                              },
                              child: Padding(
                                padding: EdgeInsets.symmetric(
                                    vertical: Spacing.large),
                                child: PwIcon(
                                  PwIcons.newWindow,
                                  color: Theme.of(context)
                                      .colorScheme
                                      .neutralNeutral,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      DetailsHeader(
                        title: Strings.proposalDetailsProposalInformation,
                      ),
                      PwListDivider.alternate(),
                      DetailsItem.alternateStrings(
                        title: Strings.proposalDetailsId,
                        value: "${_proposal.proposalId}",
                      ),
                      PwListDivider.alternate(),
                      DetailsItem.alternateStrings(
                        title: Strings.proposalDetailsTitleString,
                        value: _proposal.title,
                      ),
                      PwListDivider.alternate(),
                      DetailsItem.alternateStrings(
                        title: Strings.proposalDetailsDescription,
                        value: _proposal.description,
                      ),
                      PwListDivider.alternate(),
                      DetailsItem.alternateStrings(
                        title: Strings.proposalDetailsStatus,
                        value: _proposal.status,
                      ),
                      PwListDivider.alternate(),
                      if (widget.vote != null)
                        DetailsItem.alternateChild(
                          title: Strings.proposalDetailsMyStatus,
                          endChild: ProposalVoteChip(
                            vote: widget.vote!.formattedVote,
                          ),
                        ),
                      if (widget.vote != null) PwListDivider.alternate(),
                      DetailsHeader(
                        title: Strings.proposalDetailsProposalTiming,
                      ),
                      PwListDivider.alternate(),
                      DetailsItem.alternateStrings(
                        title: Strings.proposalDetailsSubmitTime,
                        value: _formatter.format(_proposal.submitTime),
                      ),
                      PwListDivider.alternate(),
                      DetailsItem.alternateStrings(
                        title: Strings.proposalDetailsDepositEndTime,
                        value: _formatter.format(_proposal.depositEndTime),
                      ),
                      PwListDivider.alternate(),
                      DetailsItem.alternateStrings(
                        title: Strings.proposalDetailsVotingStartTime,
                        value: _proposal.startTime.year == 1
                            ? "--"
                            : _formatter.format(_proposal.startTime),
                      ),
                      PwListDivider.alternate(),
                      DetailsItem.alternateStrings(
                        title: Strings.proposalDetailsVotingEndTime,
                        value: _proposal.endTime.year == 1
                            ? "--"
                            : _formatter.format(_proposal.endTime),
                      ),
                      PwListDivider.alternate(),
                      DetailsItem.withHash(
                        title: Strings.proposalDetailsDeposits,
                        hashString: Strings.proposalDetailsDepositsHash(
                          _proposal.currentDepositFormatted
                              .toString()
                              .formatNumber(),
                          _proposal.depositPercentage,
                        ),
                        context: context,
                      ),
                      DetailsItem.withHash(
                        padding: EdgeInsets.only(bottom: Spacing.large),
                        title: Strings.proposalDetailsNeededDeposit,
                        hashString: Strings.proposalDetailsHashNeeded(
                          _proposal.neededDepositFormatted,
                        ),
                        context: context,
                      ),
                      SinglePercentageBarChart(
                        _proposal.currentDepositFormatted,
                        _proposal.neededDepositFormatted,
                        title: Strings.proposalDetailsDeposits,
                        endValue: _proposal.depositPercentage,
                      ),
                      DetailsHeader(
                        title: Strings.proposalDetailsThresholdDetails,
                      ),
                      PwListDivider.alternate(),
                      DetailsItem.alternateStrings(
                        title: Strings.proposalDetailsQuorumThreshold,
                        value:
                            "${(_proposal.quorumThreshold * 100).toStringAsFixed(2)}%",
                      ),
                      PwListDivider.alternate(),
                      DetailsItem.alternateStrings(
                        title: Strings.proposalDetailsPassThreshold,
                        value:
                            "${(_proposal.passThreshold * 100).toStringAsFixed(2)}%",
                      ),
                      PwListDivider.alternate(),
                      DetailsItem.alternateStrings(
                        title: Strings.proposalDetailsVetoThreshold,
                        value:
                            "${(_proposal.vetoThreshold * 100).toStringAsFixed(2)}%",
                      ),
                      PwListDivider.alternate(),
                      VerticalSpacer.large(),
                      SinglePercentageBarChart(
                        _proposal.totalAmount,
                        _proposal.totalEligibleAmount,
                        title: Strings.proposalDetailsPercentVoted,
                        endValue: _proposal.votePercentage,
                      ),
                      DetailsHeader(
                        title: Strings.proposalDetailsProposalVoting,
                      ),
                      PwListDivider.alternate(),
                      VerticalSpacer.large(),
                      SinglePercentageBarChart(
                        _proposal.yesAmount,
                        _proposal.totalAmount,
                        title: Strings.proposalsScreenVoted(
                            Strings.proposalDetailsYes),
                        endValue: _proposal.votePercentage,
                      ),
                      VerticalSpacer.large(),
                      SinglePercentageBarChart(
                        _proposal.noAmount,
                        _proposal.totalAmount,
                        title: Strings.proposalsScreenVoted(
                            Strings.proposalDetailsNo),
                        endValue: _proposal.votePercentage,
                        color: Theme.of(context).colorScheme.error,
                      ),
                      VerticalSpacer.large(),
                      SinglePercentageBarChart(
                        _proposal.noWithVetoAmount,
                        _proposal.totalAmount,
                        title: Strings.proposalsScreenVoted(
                            Strings.proposalDetailsNoWithVeto),
                        endValue: _proposal.votePercentage,
                        color: Theme.of(context).colorScheme.notice350,
                      ),
                      VerticalSpacer.large(),
                      SinglePercentageBarChart(
                          _proposal.abstainAmount, _proposal.totalAmount,
                          title: Strings.proposalsScreenVoted(
                              Strings.proposalDetailsAbstain),
                          endValue: _proposal.votePercentage,
                          color: Theme.of(context).colorScheme.neutral600),
                      DetailsItem.alternateChild(
                        title: Strings.proposalDetailsTotalVotes,
                        endChild: PwText(
                            _proposal.totalAmount
                                .toInt()
                                .toString()
                                .formatNumber(),
                            style: PwTextStyle.bodyBold),
                      ),
                    ],
                  ),
                ),
                if (_proposal.status.toLowerCase() == votingPeriod)
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
