import 'package:provenance_dart/proto_gov.dart' as gov;
import 'package:provenance_wallet/common/pw_design.dart';
import 'package:provenance_wallet/common/widgets/button.dart';
import 'package:provenance_wallet/common/widgets/pw_list_divider.dart';
import 'package:provenance_wallet/common/widgets/pw_slider.dart';
import 'package:provenance_wallet/screens/home/explorer/proposals_flow/proposal_weighted_vote/weighted_vote_bloc.dart';
import 'package:provenance_wallet/screens/home/explorer/proposals_flow/proposal_weighted_vote_confirm/weighted_vote_option_column.dart';
import 'package:provenance_wallet/screens/home/explorer/proposals_flow/proposals_flow_bloc.dart';
import 'package:provenance_wallet/screens/home/transactions/details_item.dart';
import 'package:provenance_wallet/services/models/account.dart';
import 'package:provenance_wallet/services/models/proposal.dart';
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
  double _gasEstimate = 1.25;
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
                    widget.account.address.abbreviateAddress(),
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
                  startingValue: 1.25,
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
                        onPressed: () {
                          print(_bloc.getMsgVoteWeightedJson());
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
}
