import 'package:provenance_dart/proto_gov.dart' as gov;
import 'package:provenance_wallet/common/pw_design.dart';
import 'package:provenance_wallet/common/widgets/button.dart';
import 'package:provenance_wallet/common/widgets/pw_app_bar.dart';
import 'package:provenance_wallet/common/widgets/pw_list_divider.dart';
import 'package:provenance_wallet/common/widgets/pw_slider.dart';
import 'package:provenance_wallet/screens/home/explorer/proposals_flow/proposal_vote_confirm/proposal_vote_confirm_bloc.dart';
import 'package:provenance_wallet/screens/home/transactions/details_item.dart';
import 'package:provenance_wallet/services/models/account.dart';
import 'package:provenance_wallet/services/models/proposal.dart';
import 'package:provenance_wallet/util/get.dart';
import 'package:provenance_wallet/util/strings.dart';

class ProposalVoteConfirmScreen extends StatefulWidget {
  const ProposalVoteConfirmScreen({
    Key? key,
    required this.account,
    required this.proposal,
    required this.voteOption,
  }) : super(key: key);

  final TransactableAccount account;
  final Proposal proposal;
  final gov.VoteOption voteOption;

  @override
  State<StatefulWidget> createState() => _ProposalVoteConfirmScreen();
}

class _ProposalVoteConfirmScreen extends State<ProposalVoteConfirmScreen> {
  double _gasEstimate = 1.25;
  late final ProposalVoteConfirmBloc _bloc;

  @override
  void initState() {
    _bloc = ProposalVoteConfirmBloc(
      widget.account,
      widget.proposal,
      widget.voteOption,
    );
    get.registerSingleton<ProposalVoteConfirmBloc>(_bloc);
    super.initState();
  }

  @override
  void dispose() {
    get.unregister<ProposalVoteConfirmBloc>();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: PwAppBar(
        leadingIcon: PwIcons.back,
        title: Strings.proposalVoteConfirmVoteConfirm,
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
            DetailsItem(
              title: Strings.proposalVoteConfirmVoteOption,
              endChild: PwText(
                widget.voteOption.displayTitle,
                overflow: TextOverflow.fade,
                softWrap: false,
                color: PwColor.neutralNeutral,
                style: PwTextStyle.body,
              ),
            ),
            PwListDivider(
              indent: Spacing.largeX3,
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
                      // TODO: Actually do the voting
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
  }
}
