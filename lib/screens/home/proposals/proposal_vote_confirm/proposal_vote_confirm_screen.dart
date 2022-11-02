import 'package:provenance_wallet/common/pw_design.dart';
import 'package:provenance_wallet/common/widgets/button.dart';
import 'package:provenance_wallet/common/widgets/modal_loading.dart';
import 'package:provenance_wallet/common/widgets/pw_dialog.dart';
import 'package:provenance_wallet/common/widgets/pw_gas_adjustment_slider.dart';
import 'package:provenance_wallet/common/widgets/pw_list_divider.dart';
import 'package:provenance_wallet/screens/home/proposals/proposal_details/address_card.dart';
import 'package:provenance_wallet/screens/home/proposals/proposal_vote_confirm/proposal_vote_confirm_bloc.dart';
import 'package:provenance_wallet/screens/home/proposals/proposals_screen/proposal_vote_chip.dart';
import 'package:provenance_wallet/screens/home/proposals/proposals_screen/proposals_bloc.dart';
import 'package:provenance_wallet/screens/home/staking/staking_details/details_header.dart';
import 'package:provenance_wallet/screens/home/transactions/details_item.dart';
import 'package:provenance_wallet/services/models/account.dart';
import 'package:provenance_wallet/services/models/proposal.dart';
import 'package:provenance_wallet/util/constants.dart';
import 'package:provenance_wallet/util/strings.dart';
import 'package:provider/provider.dart';

class ProposalVoteConfirmScreen extends StatefulWidget {
  const ProposalVoteConfirmScreen({
    Key? key,
    required this.account,
    required this.proposal,
  }) : super(key: key);

  final TransactableAccount account;
  final Proposal proposal;

  @override
  State<StatefulWidget> createState() => _ProposalVoteConfirmScreen();
}

class _ProposalVoteConfirmScreen extends State<ProposalVoteConfirmScreen> {
  double _gasEstimate = defaultGasAdjustment;

  @override
  Widget build(BuildContext context) {
    final bloc = Provider.of<ProposalVoteConfirmBloc>(context);
    final strings = Strings.of(context);
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
        leading: Padding(
          padding: EdgeInsets.only(left: 21),
          child: IconButton(
            icon: PwIcon(
              PwIcons.back,
            ),
            onPressed: () {
              Navigator.of(context).pop();
            },
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
                final data = bloc.getMessageJson();
                Provider.of<ProposalsBloc>(context, listen: false)
                    .showTransactionData(
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
                      title: strings.proposalVoteConfirmVotingDetails),
                  PwListDivider.alternate(),
                  DetailsItem.fromStrings(
                    title: strings.proposalVoteConfirmProposalId,
                    value: widget.proposal.proposalId.toString(),
                  ),
                  PwListDivider.alternate(),
                  DetailsItem.fromStrings(
                    title: strings.proposalVoteConfirmTitle,
                    value: widget.proposal.title,
                  ),
                  PwListDivider.alternate(),
                  DetailsItem(
                      title: strings.proposalVoteConfirmVoteOption,
                      endChild:
                          ProposalVoteChip(vote: bloc.getUserFriendlyVote())),
                  PwListDivider.alternate(),
                  PwGasAdjustmentSlider(
                    title: strings.stakingConfirmGasAdjustment,
                    startingValue: defaultGasAdjustment,
                    onValueChanged: (value) {
                      setState(() {
                        _gasEstimate = value;
                      });
                    },
                  ),
                ],
              ),
            ),
            PwListDivider.alternate(),
            VerticalSpacer.large(),
            Padding(
              padding: EdgeInsets.only(
                left: Spacing.large,
                right: Spacing.large,
                bottom: Spacing.largeX3,
              ),
              child: PwButton(
                onPressed: () async {
                  await ModalLoadingRoute.showLoading(
                    context,
                    minDisplayTime: Duration(milliseconds: 500),
                  );
                  await _sendVote(_gasEstimate, context);
                },
                child: PwText(
                  strings.proposalVoteConfirmConfirmVote,
                  softWrap: false,
                  overflow: TextOverflow.fade,
                  color: PwColor.neutralNeutral,
                  style: PwTextStyle.body,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _sendVote(
    double? gasEstimate,
    BuildContext context,
  ) async {
    try {
      final response =
          await Provider.of<ProposalVoteConfirmBloc>(context, listen: false)
              .sendTransaction(gasEstimate);
      ModalLoadingRoute.dismiss(context);
      Provider.of<ProposalsBloc>(context, listen: false)
          .showTransactionComplete(
        response,
        Strings.of(context).proposalVoteComplete,
      );
    } catch (err) {
      await _showErrorModal(err, context);
    }
  }

  Future<void> _showErrorModal(Object error, BuildContext context) async {
    ModalLoadingRoute.dismiss(context);

    await PwDialog.showError(
      context: context,
      error: error,
    );
  }
}
