import 'package:provenance_dart/proto_gov.dart' as gov;
import 'package:provenance_wallet/common/pw_design.dart';
import 'package:provenance_wallet/common/widgets/button.dart';
import 'package:provenance_wallet/common/widgets/modal_loading.dart';
import 'package:provenance_wallet/common/widgets/pw_list_divider.dart';
import 'package:provenance_wallet/common/widgets/pw_slider.dart';
import 'package:provenance_wallet/dialogs/error_dialog.dart';
import 'package:provenance_wallet/screens/home/proposals/proposal_weighted_vote/weighted_vote_bloc.dart';
import 'package:provenance_wallet/screens/home/proposals/proposal_weighted_vote_confirm/weighted_vote_option_column.dart';
import 'package:provenance_wallet/screens/home/proposals/proposals_flow_bloc.dart';
import 'package:provenance_wallet/screens/home/transactions/details_item.dart';
import 'package:provenance_wallet/services/models/account.dart';
import 'package:provenance_wallet/services/models/proposal.dart';
import 'package:provenance_wallet/util/address_util.dart';
import 'package:provenance_wallet/util/constants.dart';
import 'package:provenance_wallet/util/get.dart';
import 'package:provenance_wallet/util/strings.dart';

class ProposalWeightedVoteConfirmScreen extends StatefulWidget {
  const ProposalWeightedVoteConfirmScreen({
    Key? key,
    required this.account,
    required this.proposal,
  }) : super(key: key);

  final Account account;
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
              Strings.proposalWeightedVoteConfirmVoteConfirm,
              style: PwTextStyle.subhead,
              textAlign: TextAlign.left,
            ),
            leading: Padding(
              padding: EdgeInsets.only(left: 21),
              child: Flexible(
                child: IconButton(
                  icon: PwIcon(
                    PwIcons.back,
                  ),
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                ),
              ),
            ),
            actions: [
              Padding(
                padding: EdgeInsets.only(right: 21),
                child: PwTextButton(
                  minimumSize: Size(
                    80,
                    50,
                  ),
                  onPressed: () {
                    final data = _bloc.getMsgVoteWeightedJson();
                    get<ProposalsFlowBloc>().showTransactionData(data);
                  },
                  child: PwText(
                    Strings.stakingConfirmData,
                    style: PwTextStyle.body,
                  ),
                ),
              ),
            ],
          ),
          body: Container(
            color: Theme.of(context).colorScheme.neutral750,
            child: ListView(
              children: [
                DetailsItem(
                  title: Strings.proposalVoteConfirmProposerAddress,
                  endChild: PwText(
                    widget.proposal.proposalId.toString(),
                    overflow: TextOverflow.fade,
                    softWrap: false,
                    color: PwColor.neutralNeutral,
                    style: PwTextStyle.body,
                  ),
                ),
                PwListDivider(
                  indent: Spacing.largeX3,
                ),
                DetailsItem(
                  title: Strings.proposalVoteConfirmVoterAddress,
                  endChild: PwText(
                    abbreviateAddress(widget.account.id),
                    overflow: TextOverflow.fade,
                    softWrap: false,
                    color: PwColor.neutralNeutral,
                    style: PwTextStyle.body,
                  ),
                ),
                PwListDivider(
                  indent: Spacing.largeX3,
                ),
                if (details.yesAmount > 0)
                  WeightedVoteOptionColumn(
                    voteAmount: details.yesAmount,
                    option: gov.VoteOption.VOTE_OPTION_YES,
                  ),
                if (details.noAmount > 0)
                  WeightedVoteOptionColumn(
                    voteAmount: details.noAmount,
                    option: gov.VoteOption.VOTE_OPTION_NO,
                  ),
                if (details.noWithVetoAmount > 0)
                  WeightedVoteOptionColumn(
                    voteAmount: details.noWithVetoAmount,
                    option: gov.VoteOption.VOTE_OPTION_NO_WITH_VETO,
                  ),
                if (details.abstainAmount > 0)
                  WeightedVoteOptionColumn(
                    voteAmount: details.abstainAmount,
                    option: gov.VoteOption.VOTE_OPTION_ABSTAIN,
                  ),
                PwSlider(
                  title: Strings.stakingConfirmGasAdjustment,
                  startingValue: defaultGasEstimate,
                  min: 0,
                  max: 5,
                  onValueChanged: (value) {
                    setState(() {
                      _gasEstimate = value;
                    });
                  },
                ),
                PwListDivider(
                  indent: Spacing.largeX3,
                ),
                Padding(
                    padding: EdgeInsets.symmetric(
                      horizontal: Spacing.largeX3,
                      vertical: Spacing.xLarge,
                    ),
                    child: Flexible(
                      child: PwButton(
                        onPressed: () async {
                          ModalLoadingRoute.showLoading('', context);
                          // Give the loading modal time to display
                          await Future.delayed(Duration(milliseconds: 500));
                          await _sendWeightedVote(_gasEstimate, context);
                        },
                        child: PwText(
                          Strings.proposalVoteConfirmVote,
                          softWrap: false,
                          overflow: TextOverflow.fade,
                          color: PwColor.neutralNeutral,
                          style: PwTextStyle.body,
                        ),
                      ),
                    )),
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
      await _bloc.doWeightedVote(gasEstimate);
      ModalLoadingRoute.dismiss(context);
      get<ProposalsFlowBloc>().showTransactionSuccess();
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
