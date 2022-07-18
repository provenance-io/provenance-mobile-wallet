import 'package:intl/intl.dart';
import 'package:provenance_wallet/common/pw_design.dart';
import 'package:provenance_wallet/common/widgets/pw_app_bar.dart';
import 'package:provenance_wallet/common/widgets/pw_list_divider.dart';
import 'package:provenance_wallet/screens/home/proposals/proposals_details/color_key.dart';
import 'package:provenance_wallet/screens/home/proposals/proposals_details/deposit_bar_chart.dart';
import 'package:provenance_wallet/screens/home/proposals/proposals_details/voting_bar_chart.dart';
import 'package:provenance_wallet/screens/home/proposals/proposals_details/voting_buttons.dart';
import 'package:provenance_wallet/screens/home/staking/staking_details/details_header.dart';
import 'package:provenance_wallet/screens/home/transactions/details_item.dart';
import 'package:provenance_wallet/services/models/proposal.dart';
import 'package:provenance_wallet/util/address_util.dart';
import 'package:provenance_wallet/util/strings.dart';

class ProposalDetailsScreen extends StatefulWidget {
  const ProposalDetailsScreen({
    Key? key,
    required this.selectedProposal,
  }) : super(key: key);

  final Proposal selectedProposal;

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
            ),
            body: Column(
              children: [
                Expanded(
                  child: ListView(
                    padding: EdgeInsets.symmetric(
                      horizontal: Spacing.large,
                    ),
                    children: [
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
                                          ? abbreviateAddressAlt(widget
                                              .selectedProposal.proposerAddress)
                                          : widget
                                              .selectedProposal.proposerAddress,
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
                                // final url = get<StakingDetailsBloc>().getProvUrl();
                                // if (await canLaunch(url)) {
                                //   await launch(url);
                                // } else {
                                //   throw 'Could not launch $url';
                                // }
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
                        title: Strings.proposalDetailsProposer,
                        value: abbreviateAddress(_proposal.proposerAddress),
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
                      Padding(
                        padding: EdgeInsets.symmetric(
                          horizontal: Spacing.largeX3,
                          vertical: Spacing.xLarge,
                        ),
                        child: PwText(
                          Strings.proposalDetailsProposalTiming,
                          style: PwTextStyle.title,
                        ),
                      ),
                      PwListDivider.alternate(),
                      DetailsItem.fromStrings(
                        title: Strings.proposalDetailsSubmitTime,
                        value: _formatter.format(_proposal.submitTime),
                      ),
                      PwListDivider.alternate(),
                      DetailsItem.fromStrings(
                        title: Strings.proposalDetailsDepositEndTime,
                        value: _formatter.format(_proposal.depositEndTime),
                      ),
                      PwListDivider.alternate(),
                      DetailsItem.fromStrings(
                        title: Strings.proposalDetailsVotingStartTime,
                        value: _proposal.startTime.year == 1
                            ? "--"
                            : _formatter.format(_proposal.startTime),
                      ),
                      PwListDivider.alternate(),
                      DetailsItem.fromStrings(
                        title: Strings.proposalDetailsVotingEndTime,
                        value: _proposal.endTime.year == 1
                            ? "--"
                            : _formatter.format(_proposal.endTime),
                      ),
                      PwListDivider.alternate(),
                      DetailsItem.fromStrings(
                        padding: EdgeInsets.only(
                          left: Spacing.largeX3,
                          right: Spacing.largeX3,
                          top: Spacing.xLarge,
                        ),
                        title: Strings.proposalDetailsDeposits,
                        value: Strings.proposalDetailsDepositsHash(
                          _proposal.currentDepositFormatted,
                          _proposal.depositPercentage,
                        ),
                      ),
                      DetailsItem.fromStrings(
                        padding: EdgeInsets.only(
                          left: Spacing.largeX3,
                          right: Spacing.largeX3,
                          top: Spacing.xLarge,
                        ),
                        title: Strings.proposalDetailsNeededDeposit,
                        value: Strings.proposalDetailsHashNeeded(
                          _proposal.neededDepositFormatted,
                        ),
                      ),
                      DepositBarChart(
                        _proposal.currentDepositFormatted,
                        _proposal.neededDepositFormatted,
                      ),
                      PwListDivider.alternate(),
                      DetailsItem.fromStrings(
                        title: Strings.proposalDetailsQuorumThreshold,
                        value:
                            "${(_proposal.quorumThreshold * 100).toStringAsFixed(2)}%",
                      ),
                      PwListDivider.alternate(),
                      DetailsItem.fromStrings(
                        title: Strings.proposalDetailsPassThreshold,
                        value:
                            "${(_proposal.passThreshold * 100).toStringAsFixed(2)}%",
                      ),
                      PwListDivider.alternate(),
                      DetailsItem.fromStrings(
                        title: Strings.proposalDetailsVetoThreshold,
                        value:
                            "${(_proposal.vetoThreshold * 100).toStringAsFixed(2)}%",
                      ),
                      PwListDivider.alternate(),
                      DetailsItem.fromStrings(
                        padding: EdgeInsets.only(
                          left: Spacing.largeX3,
                          right: Spacing.largeX3,
                          top: Spacing.xLarge,
                        ),
                        title: Strings.proposalDetailsPercentVoted,
                        value: _proposal.votePercentage,
                      ),
                      DepositBarChart(
                        _proposal.totalAmount.toDouble(),
                        _proposal.totalEligibleAmount.toDouble(),
                      ),
                      PwListDivider.alternate(),
                      DetailsItem.fromStrings(
                        title: Strings.proposalDetailsTotalVotes,
                        value: _proposal.totalAmount
                            .toInt()
                            .toString()
                            .formatNumber(),
                      ),
                      Padding(
                        padding: EdgeInsets.only(
                          left: Spacing.largeX3,
                          right: Spacing.largeX3,
                        ),
                        child: Flexible(
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              ColorKey(
                                color: Theme.of(context).colorScheme.primary550,
                              ),
                              PwText(
                                Strings.proposalDetailsYes,
                              ),
                              HorizontalSpacer.large(),
                              ColorKey(
                                color: Theme.of(context).colorScheme.error,
                              ),
                              PwText(
                                Strings.proposalDetailsNo,
                              ),
                              HorizontalSpacer.large(),
                              ColorKey(
                                color: Theme.of(context).colorScheme.notice350,
                              ),
                              PwText(
                                Strings.proposalDetailsNoWithVeto,
                              ),
                              HorizontalSpacer.large(),
                              ColorKey(
                                color: Theme.of(context).colorScheme.neutral600,
                              ),
                              PwText(
                                Strings.proposalDetailsAbstain,
                              ),
                            ],
                          ),
                        ),
                      ),
                      VotingBarChart(
                        yes: _proposal.yesAmount,
                        no: _proposal.noAmount,
                        noWithVeto: _proposal.noWithVetoAmount,
                        abstain: _proposal.abstainAmount,
                        total: _proposal.totalAmount,
                      ),
                    ],
                  ),
                ),
                //if (_proposal.status.toLowerCase() == votingPeriod)
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
