import 'package:provenance_dart/proto_gov.dart' as gov;
import 'package:provenance_wallet/common/pw_design.dart';
import 'package:provenance_wallet/common/widgets/button.dart';
import 'package:provenance_wallet/common/widgets/modal_loading.dart';
import 'package:provenance_wallet/common/widgets/pw_gas_adjustment_slider.dart';
import 'package:provenance_wallet/common/widgets/pw_list_divider.dart';
import 'package:provenance_wallet/dialogs/error_dialog.dart';
import 'package:provenance_wallet/screens/home/proposals/proposal_vote_confirm/proposal_vote_confirm_bloc.dart';
import 'package:provenance_wallet/screens/home/proposals/proposals_details/address_card.dart';
import 'package:provenance_wallet/screens/home/proposals/proposals_flow_bloc.dart';
import 'package:provenance_wallet/screens/home/proposals/proposals_screen/proposal_vote_chip.dart';
import 'package:provenance_wallet/screens/home/staking/staking_details/details_header.dart';
import 'package:provenance_wallet/screens/home/transactions/details_item.dart';
import 'package:provenance_wallet/services/models/account.dart';
import 'package:provenance_wallet/services/models/proposal.dart';
import 'package:provenance_wallet/util/constants.dart';
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
  double _gasEstimate = defaultGasEstimate;
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
                final data = _bloc.getMsgVoteJson();
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
                          ProposalVoteChip(vote: _bloc.getUserFriendlyVote())),
                  PwListDivider.alternate(),
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
      final response = await _bloc.doVote(gasEstimate);
      ModalLoadingRoute.dismiss(context);
      get<ProposalsFlowBloc>().showTransactionComplete(
        response,
        Strings.of(context).proposalVoteComplete,
      );
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
