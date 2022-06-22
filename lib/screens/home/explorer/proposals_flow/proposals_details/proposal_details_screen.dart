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
  // @override
  // void initState() {
  //   get.registerSingleton<StakingDetailsBloc>(_bloc);
  //   super.initState();
  // }

  // @override
  // void dispose() {
  //   get.unregister<StakingDetailsBloc>();
  //   super.dispose();
  // }

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
              title: Strings.proposalDetailsTitle(
                  widget.selectedProposal.proposalId),
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
                  value: "${widget.selectedProposal.proposalId}",
                ),
                PwListDivider(
                  indent: Spacing.largeX3,
                ),
                DetailsItem.fromStrings(
                  title: Strings.proposalDetailsTitleString,
                  value: widget.selectedProposal.title,
                ),
                PwListDivider(
                  indent: Spacing.largeX3,
                ),
                DetailsItem.fromStrings(
                  title: Strings.proposalDetailsStatus,
                  value: widget.selectedProposal.status,
                ),
                PwListDivider(
                  indent: Spacing.largeX3,
                ),
                DetailsItem.fromStrings(
                  title: Strings.proposalDetailsProposer,
                  value: widget.selectedProposal.proposerAddress
                      .abbreviateAddress(),
                ),
                PwListDivider(
                  indent: Spacing.largeX3,
                ),
                DetailsItem.fromStrings(
                  title: Strings.proposalDetailsDescription,
                  value: widget.selectedProposal.description,
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
                  value: _formatter.format(widget.selectedProposal.submitTime),
                ),
                PwListDivider(
                  indent: Spacing.largeX3,
                ),
                DetailsItem.fromStrings(
                  title: Strings.proposalDetailsDepositEndTime,
                  value:
                      _formatter.format(widget.selectedProposal.depositEndTime),
                ),
                PwListDivider(
                  indent: Spacing.largeX3,
                ),
                DetailsItem.fromStrings(
                  title: Strings.proposalDetailsVotingStartTime,
                  value: widget.selectedProposal.startTime.year == 1
                      ? "--"
                      : _formatter.format(widget.selectedProposal.startTime),
                ),
                PwListDivider(
                  indent: Spacing.largeX3,
                ),
                DetailsItem.fromStrings(
                  title: Strings.proposalDetailsVotingEndTime,
                  value: widget.selectedProposal.endTime.year == 1
                      ? "--"
                      : _formatter.format(widget.selectedProposal.endTime),
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
                    widget.selectedProposal.currentDepositFormatted,
                    widget.selectedProposal.depositPercentage,
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
                    widget.selectedProposal.neededDepositFormatted,
                  ),
                ),
                DepositBarChart(
                  widget.selectedProposal.currentDepositFormatted,
                  widget.selectedProposal.neededDepositFormatted,
                ),
                PwListDivider(
                  indent: Spacing.largeX3,
                ),
                DetailsItem.fromStrings(
                  title: Strings.proposalDetailsQuorumThreshold,
                  value:
                      "${(widget.selectedProposal.quorumThreshold * 100).toStringAsFixed(2)}%",
                ),
                PwListDivider(
                  indent: Spacing.largeX3,
                ),
                DetailsItem.fromStrings(
                  title: Strings.proposalDetailsPassThreshold,
                  value:
                      "${(widget.selectedProposal.passThreshold * 100).toStringAsFixed(2)}%",
                ),
                PwListDivider(
                  indent: Spacing.largeX3,
                ),
                DetailsItem.fromStrings(
                  title: Strings.proposalDetailsVetoThreshold,
                  value:
                      "${(widget.selectedProposal.vetoThreshold * 100).toStringAsFixed(2)}%",
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
                  value: widget.selectedProposal.votePercentage,
                ),
                DepositBarChart(
                  widget.selectedProposal.totalAmount,
                  widget.selectedProposal.totalEligibleAmount,
                ),
                PwListDivider(
                  indent: Spacing.largeX3,
                ),
                DetailsItem.fromStrings(
                  title: Strings.proposalDetailsTotalVotes,
                  value: widget.selectedProposal.totalAmount
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
                  yes: widget.selectedProposal.yesAmount,
                  no: widget.selectedProposal.noAmount,
                  noWithVeto: widget.selectedProposal.noWithVetoAmount,
                  abstain: widget.selectedProposal.abstainAmount,
                  total: widget.selectedProposal.totalAmount,
                ),
                // if (widget.selectedProposal.status.toLowerCase() ==
                //     "voting period")
                VotingButtons(
                  proposal: widget.selectedProposal,
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
