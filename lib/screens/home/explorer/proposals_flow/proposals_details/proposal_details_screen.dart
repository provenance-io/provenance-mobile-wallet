import 'package:intl/intl.dart';
import 'package:provenance_wallet/common/pw_design.dart';
import 'package:provenance_wallet/common/widgets/pw_app_bar.dart';
import 'package:provenance_wallet/common/widgets/pw_list_divider.dart';
import 'package:provenance_wallet/screens/home/explorer/proposals_flow/proposals_details/color_key.dart';
import 'package:provenance_wallet/screens/home/explorer/proposals_flow/proposals_details/deposit_bar_chart.dart';
import 'package:provenance_wallet/screens/home/explorer/proposals_flow/proposals_details/voting_bar_chart.dart';
import 'package:provenance_wallet/screens/home/explorer/proposals_flow/proposals_details/voting_buttons.dart';
import 'package:provenance_wallet/screens/home/transactions/details_item.dart';
import 'package:provenance_wallet/services/models/proposal.dart';
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
          child: //StreamBuilder<DetailedValidatorDetails>(
              // initialData: _bloc.validatorDetails.value,
              // stream: _bloc.validatorDetails,
              // builder: (context, snapshot) {
              //   final details = snapshot.data;
              //   final validator = snapshot.data?.validator;
              //   final commission = snapshot.data?.commission;
              //   if (details == null || validator == null || commission == null) {
              //     return Container();
              //   }

              //   return
              Scaffold(
            appBar: PwAppBar(
              title: Strings.proposalDetailsTitle(_proposal.proposalId),
              leadingIcon: PwIcons.back,
            ),
            body: ListView(
              children: [
                Padding(
                  padding: EdgeInsets.symmetric(
                    horizontal: Spacing.largeX3,
                    vertical: Spacing.xLarge,
                  ),
                  child: PwText(
                    Strings.proposalDetailsProposalInformation,
                    style: PwTextStyle.title,
                  ),
                ),
                PwListDivider(
                  indent: Spacing.largeX3,
                ),
                DetailsItem.fromStrings(
                  title: Strings.proposalDetailsId,
                  value: "${_proposal.proposalId}",
                ),
                PwListDivider(
                  indent: Spacing.largeX3,
                ),
                DetailsItem.fromStrings(
                  title: Strings.proposalDetailsTitleString,
                  value: _proposal.title,
                ),
                PwListDivider(
                  indent: Spacing.largeX3,
                ),
                DetailsItem.fromStrings(
                  title: Strings.proposalDetailsStatus,
                  value: _proposal.status,
                ),
                PwListDivider(
                  indent: Spacing.largeX3,
                ),
                DetailsItem.fromStrings(
                  title: Strings.proposalDetailsProposer,
                  value: _proposal.proposerAddress.abbreviateAddress(),
                ),
                PwListDivider(
                  indent: Spacing.largeX3,
                ),
                DetailsItem.fromStrings(
                  title: Strings.proposalDetailsDescription,
                  value: _proposal.description,
                ),
                PwListDivider(
                  indent: Spacing.largeX3,
                ),
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
                PwListDivider(
                  indent: Spacing.largeX3,
                ),
                DetailsItem.fromStrings(
                  title: Strings.proposalDetailsSubmitTime,
                  value: _formatter.format(_proposal.submitTime),
                ),
                PwListDivider(
                  indent: Spacing.largeX3,
                ),
                DetailsItem.fromStrings(
                  title: Strings.proposalDetailsDepositEndTime,
                  value: _formatter.format(_proposal.depositEndTime),
                ),
                PwListDivider(
                  indent: Spacing.largeX3,
                ),
                DetailsItem.fromStrings(
                  title: Strings.proposalDetailsVotingStartTime,
                  value: _proposal.startTime.year == 1
                      ? "--"
                      : _formatter.format(_proposal.startTime),
                ),
                PwListDivider(
                  indent: Spacing.largeX3,
                ),
                DetailsItem.fromStrings(
                  title: Strings.proposalDetailsVotingEndTime,
                  value: _proposal.endTime.year == 1
                      ? "--"
                      : _formatter.format(_proposal.endTime),
                ),
                PwListDivider(
                  indent: Spacing.largeX3,
                ),
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
                PwListDivider(
                  indent: Spacing.largeX3,
                ),
                DetailsItem.fromStrings(
                  title: Strings.proposalDetailsQuorumThreshold,
                  value:
                      "${(_proposal.quorumThreshold * 100).toStringAsFixed(2)}%",
                ),
                PwListDivider(
                  indent: Spacing.largeX3,
                ),
                DetailsItem.fromStrings(
                  title: Strings.proposalDetailsPassThreshold,
                  value:
                      "${(_proposal.passThreshold * 100).toStringAsFixed(2)}%",
                ),
                PwListDivider(
                  indent: Spacing.largeX3,
                ),
                DetailsItem.fromStrings(
                  title: Strings.proposalDetailsVetoThreshold,
                  value:
                      "${(_proposal.vetoThreshold * 100).toStringAsFixed(2)}%",
                ),
                PwListDivider(
                  indent: Spacing.largeX3,
                ),
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
                  _proposal.totalAmount,
                  _proposal.totalEligibleAmount,
                ),
                PwListDivider(
                  indent: Spacing.largeX3,
                ),
                DetailsItem.fromStrings(
                  title: Strings.proposalDetailsTotalVotes,
                  value:
                      _proposal.totalAmount.toInt().toString().formatNumber(),
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
                // if (_proposal.status.toLowerCase() ==
                //     "voting period")
                VotingButtons(
                  proposal: _proposal,
                ),
              ],
            ),
            //);
            //},
          ),
        ),
        // StreamBuilder<bool>(
        //   initialData: _bloc.isLoading.value,
        //   stream: _bloc.isLoading,
        //   builder: (context, snapshot) {
        //     final isLoading = snapshot.data ?? false;
        //     if (isLoading) {
        //       return SizedBox(
        //         height: MediaQuery.of(context).size.height,
        //         width: MediaQuery.of(context).size.width,
        //         child: Center(
        //           child: CircularProgressIndicator(),
        //         ),
        //       );
        //     }

        //     return Container();
        //   },
        // ),
      ],
    );
  }
}
