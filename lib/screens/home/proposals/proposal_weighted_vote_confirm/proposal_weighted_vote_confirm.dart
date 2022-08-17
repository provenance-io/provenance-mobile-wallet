import 'package:provenance_wallet/common/pw_design.dart';
import 'package:provenance_wallet/common/widgets/button.dart';
import 'package:provenance_wallet/common/widgets/modal_loading.dart';
import 'package:provenance_wallet/common/widgets/pw_gas_adjustment_slider.dart';
import 'package:provenance_wallet/common/widgets/pw_list_divider.dart';
import 'package:provenance_wallet/dialogs/error_dialog.dart';
import 'package:provenance_wallet/screens/home/proposals/proposal_weighted_vote/weighted_vote_bloc.dart';
import 'package:provenance_wallet/screens/home/proposals/proposals_details/address_card.dart';
import 'package:provenance_wallet/screens/home/proposals/proposals_details/single_percentage_bar_chart.dart';
import 'package:provenance_wallet/screens/home/proposals/proposals_flow_bloc.dart';
import 'package:provenance_wallet/screens/home/staking/staking_details/details_header.dart';
import 'package:provenance_wallet/screens/home/transactions/details_item.dart';
import 'package:provenance_wallet/services/models/account.dart';
import 'package:provenance_wallet/services/models/proposal.dart';
import 'package:provenance_wallet/util/constants.dart';
import 'package:provenance_wallet/util/get.dart';
import 'package:provenance_wallet/util/strings.dart';

class ProposalWeightedVoteConfirmScreen extends StatefulWidget {
  const ProposalWeightedVoteConfirmScreen({
    Key? key,
    required this.account,
    required this.proposal,
  }) : super(key: key);

  final TransactableAccount account;
  final Proposal proposal;

  @override
  State<StatefulWidget> createState() =>
      _ProposalWeightedVoteConfirmScreenState();
}

class _ProposalWeightedVoteConfirmScreenState
    extends State<ProposalWeightedVoteConfirmScreen> {
  double _gasEstimate = defaultGasEstimate;
  late final WeightedVoteBloc _bloc;

  @override
  void initState() {
    _bloc = get<WeightedVoteBloc>();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final strings = Strings.of(context);
    return StreamBuilder<WeightedVoteDetails>(
      stream: _bloc.weightedVoteDetails,
      builder: (context, snapshot) {
        final details = snapshot.data;
        if (details == null) {
          return Container();
        }

        return Scaffold(
          appBar: AppBar(
            backgroundColor: Theme.of(context).colorScheme.neutral750,
            elevation: 0.0,
            centerTitle: true,
            title: PwText(
              strings.proposalVoteConfirmConfirmVote,
              style: PwTextStyle.footnote,
              textAlign: TextAlign.left,
            ),
            leading: IconButton(
              icon: PwIcon(
                PwIcons.back,
              ),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            actions: [
              PwTextButton(
                minimumSize: Size(
                  80,
                  50,
                ),
                onPressed: () {
                  final data = _bloc.getMsgVoteWeightedJson();
                  get<ProposalsFlowBloc>().showTransactionData(
                    data,
                    Strings.of(context).stakingConfirmData,
                  );
                },
                child: PwText(
                  strings.stakingConfirmData,
                  style: PwTextStyle.footnote,
                  underline: true,
                ),
              ),
            ],
          ),
          body: Container(
            color: Theme.of(context).colorScheme.neutral750,
            child: Column(
              children: [
                Expanded(
                  child: ListView(
                    padding: EdgeInsets.symmetric(horizontal: Spacing.large),
                    children: [
                      VerticalSpacer.largeX3(),
                      AddressCard(
                        title: strings.proposalVoteConfirmProposerAddress,
                        address: widget.proposal.proposerAddress,
                      ),
                      VerticalSpacer.large(),
                      AddressCard(
                        title: strings.proposalVoteConfirmVoterAddress,
                        address: widget.account.address,
                      ),
                      DetailsHeader(
                        title: strings.proposalVoteConfirmVotingDetails,
                      ),
                      PwListDivider.alternate(),
                      DetailsItem.fromStrings(
                        title: strings.proposalWeightedVoteProposalId,
                        value: widget.proposal.proposalId.toString(),
                      ),
                      PwListDivider.alternate(),
                      DetailsItem.fromStrings(
                        title: strings.proposalDetailsTitleString,
                        value: widget.proposal.title,
                      ),
                      PwListDivider.alternate(),
                      VerticalSpacer.large(),
                      PwText(
                        strings.proposalVoteConfirmVoteOption,
                        style: PwTextStyle.footnote,
                        color: PwColor.neutral200,
                      ),
                      VerticalSpacer.large(),
                      SinglePercentageBarChart(
                        details.yesAmount,
                        100,
                        title: strings.proposalDetailsYes,
                        childStyle: PwTextStyle.footnote,
                        showDecimal: false,
                        color: Theme.of(context).colorScheme.primary500,
                      ),
                      VerticalSpacer.large(),
                      SinglePercentageBarChart(
                        details.noAmount,
                        100,
                        title: strings.proposalDetailsNo,
                        childStyle: PwTextStyle.footnote,
                        showDecimal: false,
                        color: Theme.of(context).colorScheme.error,
                      ),
                      VerticalSpacer.large(),
                      SinglePercentageBarChart(
                        details.noWithVetoAmount,
                        100,
                        title: strings.proposalDetailsNoWithVeto,
                        childStyle: PwTextStyle.footnote,
                        showDecimal: false,
                        color: Theme.of(context).colorScheme.notice350,
                      ),
                      VerticalSpacer.large(),
                      SinglePercentageBarChart(
                        details.abstainAmount,
                        100,
                        title: strings.proposalDetailsAbstain,
                        childStyle: PwTextStyle.footnote,
                        showDecimal: false,
                        color: Theme.of(context).colorScheme.neutral550,
                      ),
                      PwGasAdjustmentSlider(
                        title: strings.stakingConfirmGasAdjustment,
                        startingValue: defaultGasEstimate,
                        onValueChanged: (value) {
                          setState(() {
                            _gasEstimate = value;
                          });
                        },
                      ),
                    ],
                  ),
                ),
                Padding(
                  padding: EdgeInsets.only(
                    top: Spacing.large,
                    left: Spacing.large,
                    right: Spacing.large,
                    bottom: Spacing.largeX3,
                  ),
                  child: Flexible(
                    child: PwButton(
                      onPressed: () async {
                        await ModalLoadingRoute.showLoading(
                          context,
                          minDisplayTime: Duration(milliseconds: 500),
                        );
                        await _sendWeightedVote(_gasEstimate, context);
                      },
                      child: PwText(
                        strings.proposalWeightedVoteConfirmWeightedVote,
                        softWrap: false,
                        overflow: TextOverflow.fade,
                        color: PwColor.neutralNeutral,
                        style: PwTextStyle.body,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Future<void> _sendWeightedVote(
    double? gasEstimate,
    BuildContext context,
  ) async {
    try {
      final response = await _bloc.doWeightedVote(gasEstimate);
      ModalLoadingRoute.dismiss(context);
      get<ProposalsFlowBloc>().showTransactionComplete(response);
    } catch (err) {
      await _showErrorModal(err, context);
    }
  }

  Future<void> _showErrorModal(Object error, BuildContext context) async {
    ModalLoadingRoute.dismiss(context);
    await showDialog(
      context: context,
      builder: (context) {
        return ErrorDialog(
          error: error.toString(),
        );
      },
    );
  }
}
