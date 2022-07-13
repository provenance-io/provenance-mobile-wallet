import 'package:provenance_dart/proto_gov.dart' as gov;
import 'package:provenance_wallet/common/pw_design.dart';
import 'package:provenance_wallet/common/widgets/button.dart';
import 'package:provenance_wallet/common/widgets/modal_loading.dart';
import 'package:provenance_wallet/common/widgets/pw_list_divider.dart';
import 'package:provenance_wallet/common/widgets/pw_slider.dart';
import 'package:provenance_wallet/dialogs/error_dialog.dart';
import 'package:provenance_wallet/screens/home/proposals/proposal_vote_confirm/proposal_vote_confirm_bloc.dart';
import 'package:provenance_wallet/screens/home/proposals/proposals_flow_bloc.dart';
import 'package:provenance_wallet/screens/home/transactions/details_item.dart';
import 'package:provenance_wallet/services/models/account.dart';
import 'package:provenance_wallet/services/models/proposal.dart';
import 'package:provenance_wallet/util/address_util.dart';
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

  final Account account;
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
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.neutral750,
        elevation: 0.0,
        centerTitle: true,
        title: PwText(
          Strings.proposalVoteConfirmVoteConfirm,
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
                final data = _bloc.getMsgVoteJson();
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
            DetailsItem(
              title: Strings.proposalVoteConfirmVoteOption,
              endChild: PwText(
                widget.voteOption.name,
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
                      await _sendVote(_gasEstimate, context);
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

  Future<void> _sendVote(
    double? gasEstimate,
    BuildContext context,
  ) async {
    try {
      await _bloc.doVote(gasEstimate);
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
