import 'package:intl/intl.dart';
import 'package:provenance_wallet/common/pw_design.dart';
import 'package:provenance_wallet/common/widgets/pw_app_bar.dart';
import 'package:provenance_wallet/common/widgets/pw_list_divider.dart';
import 'package:provenance_wallet/screens/home/explorer/proposals/deposit_bar_chart.dart';
import 'package:provenance_wallet/screens/home/explorer/proposals/voting_bar_chart.dart';
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
              title: "Proposal ${widget.selectedProposal.proposalId}",
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
                    "Proposal Information",
                    style: PwTextStyle.title,
                  ),
                ),
                PwListDivider(
                  indent: Spacing.largeX3,
                ),
                DetailsItem(
                  title: "ID",
                  endChild: PwText("${widget.selectedProposal.proposalId}"),
                ),
                PwListDivider(
                  indent: Spacing.largeX3,
                ),
                DetailsItem(
                  title: "Title",
                  endChild: PwText(widget.selectedProposal.title),
                ),
                PwListDivider(
                  indent: Spacing.largeX3,
                ),
                DetailsItem(
                  title: "Status",
                  endChild: PwText(widget.selectedProposal.status),
                ),
                PwListDivider(
                  indent: Spacing.largeX3,
                ),
                DetailsItem(
                  title: "Proposer",
                  endChild: PwText(widget.selectedProposal.proposerAddress
                      .abbreviateAddress()),
                ),
                PwListDivider(
                  indent: Spacing.largeX3,
                ),
                DetailsItem(
                  title: "Description",
                  needsExpansion: false,
                  endChild: Expanded(
                    child: Column(
                      children: [
                        PwText(
                          widget.selectedProposal.description,
                        ),
                      ],
                    ),
                  ),
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
                    "Proposal Timing",
                    style: PwTextStyle.title,
                  ),
                ),
                PwListDivider(
                  indent: Spacing.largeX3,
                ),
                DetailsItem(
                  title: "Submit Time",
                  endChild: PwText(
                      _formatter.format(widget.selectedProposal.submitTime)),
                ),
                PwListDivider(
                  indent: Spacing.largeX3,
                ),
                DetailsItem(
                  title: "Deposit End Time",
                  endChild: PwText(_formatter
                      .format(widget.selectedProposal.depositEndTime)),
                ),
                PwListDivider(
                  indent: Spacing.largeX3,
                ),
                DetailsItem(
                  title: "Voting Start Time",
                  endChild: PwText(widget.selectedProposal.startTime.year == 1
                      ? "--"
                      : _formatter.format(widget.selectedProposal.startTime)),
                ),
                PwListDivider(
                  indent: Spacing.largeX3,
                ),
                DetailsItem(
                  title: "Voting End Time",
                  endChild: PwText(widget.selectedProposal.endTime.year == 1
                      ? "--"
                      : _formatter.format(widget.selectedProposal.endTime)),
                ),
                PwListDivider(
                  indent: Spacing.largeX3,
                ),
                DetailsItem(
                  padding: EdgeInsets.only(
                    left: Spacing.largeX3,
                    right: Spacing.largeX3,
                    top: Spacing.xLarge,
                  ),
                  title: "Deposits",
                  endChild: PwText(
                    "${widget.selectedProposal.currentDepositFormatted} hash (${widget.selectedProposal.depositPercentage})",
                  ),
                ),
                DepositBarChart(
                  widget.selectedProposal.currentDepositFormatted,
                  widget.selectedProposal.neededDepositFormatted,
                ),
                PwListDivider(
                  indent: Spacing.largeX3,
                ),
                DetailsItem(
                  title: "Quorum Threshold",
                  endChild: PwText(
                    "${(widget.selectedProposal.quorumThreshold * 100).toStringAsFixed(2)}%",
                  ),
                ),
                PwListDivider(
                  indent: Spacing.largeX3,
                ),
                DetailsItem(
                  title: "Pass Threshold",
                  endChild: PwText(
                    "${(widget.selectedProposal.passThreshold * 100).toStringAsFixed(2)}%",
                  ),
                ),
                PwListDivider(
                  indent: Spacing.largeX3,
                ),
                DetailsItem(
                  title: "Veto Threshold",
                  endChild: PwText(
                    "${(widget.selectedProposal.vetoThreshold * 100).toStringAsFixed(2)}%",
                  ),
                ),
                PwListDivider(
                  indent: Spacing.largeX3,
                ),
                DetailsItem(
                  padding: EdgeInsets.only(
                    left: Spacing.largeX3,
                    right: Spacing.largeX3,
                    top: Spacing.xLarge,
                  ),
                  title: "Percent Voted",
                  endChild: PwText(
                    widget.selectedProposal.votePercentage,
                  ),
                ),
                DepositBarChart(
                  widget.selectedProposal.totalAmount.toInt(),
                  widget.selectedProposal.totalEligibleAmount.toInt(),
                ),
                PwListDivider(
                  indent: Spacing.largeX3,
                ),
                DetailsItem(
                  title: "Total Votes",
                  endChild: PwText(
                    widget.selectedProposal.totalAmount
                        .toInt()
                        .toString()
                        .formatNumber(),
                  ),
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
                        Icon(
                          IconData(0xf5e1, fontFamily: 'MaterialIcons'),
                          color: Theme.of(context).colorScheme.primary550,
                          size: 10,
                        ),
                        PwText(
                          "Yes",
                        ),
                        HorizontalSpacer.large(),
                        Icon(
                          IconData(0xf5e1, fontFamily: 'MaterialIcons'),
                          color: Theme.of(context).colorScheme.error,
                          size: 10,
                        ),
                        PwText(
                          "No",
                        ),
                        HorizontalSpacer.large(),
                        Icon(
                          IconData(0xf5e1, fontFamily: 'MaterialIcons'),
                          color: Theme.of(context).colorScheme.notice350,
                          size: 10,
                        ),
                        PwText(
                          "No With Veto",
                        ),
                        HorizontalSpacer.large(),
                        Icon(
                          IconData(0xf5e1, fontFamily: 'MaterialIcons'),
                          color: Theme.of(context).colorScheme.neutral600,
                          size: 10,
                        ),
                        PwText(
                          "Abstain",
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
                // DepositChart(
                //   widget.selectedProposal.startTime,
                //   widget.selectedProposal.endTime,
                //   double.parse(
                //       widget.selectedProposal.currentDeposit.nhashToHash()),
                //   double.parse(
                //       widget.selectedProposal.initialDeposit.nhashToHash()),
                //   double.parse(
                //       widget.selectedProposal.neededDeposit.nhashToHash()),
                // )
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
