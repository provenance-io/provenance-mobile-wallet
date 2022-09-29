import 'package:provenance_wallet/common/pw_design.dart';
import 'package:provenance_wallet/common/widgets/button.dart';
import 'package:provenance_wallet/common/widgets/pw_app_bar.dart';
import 'package:provenance_wallet/screens/home/proposals/proposal_weighted_vote/weighted_vote_bloc.dart';
import 'package:provenance_wallet/screens/home/proposals/proposal_weighted_vote/weighted_vote_sliders.dart';
import 'package:provenance_wallet/screens/home/proposals/proposals_screen/proposals_bloc.dart';
import 'package:provenance_wallet/services/models/account.dart';
import 'package:provenance_wallet/services/models/proposal.dart';
import 'package:provenance_wallet/util/strings.dart';
import 'package:provider/provider.dart';

class ProposalWeightedVoteScreen extends StatefulWidget {
  const ProposalWeightedVoteScreen({
    Key? key,
    required this.proposal,
    required this.account,
  }) : super(key: key);

  final Proposal proposal;
  final TransactableAccount account;

  @override
  State<StatefulWidget> createState() => _ProposalDetailsScreenState();
}

class _ProposalDetailsScreenState extends State<ProposalWeightedVoteScreen> {
  @override
  Widget build(BuildContext context) {
    final bloc = Provider.of<WeightedVoteBloc>(context);

    return Scaffold(
      appBar: PwAppBar(
        title: Strings.of(context).proposalWeightedVote,
        style: PwTextStyle.footnote,
        leadingIcon: PwIcons.back,
      ),
      body: Container(
        color: Theme.of(context).colorScheme.neutral750,
        child: Column(
          children: [
            Expanded(
              child: ListView(
                padding: EdgeInsets.symmetric(horizontal: Spacing.large),
                children: const [
                  WeightedVoteSliders(),
                ],
              ),
            ),
            StreamBuilder<WeightedVoteDetails>(
              initialData: bloc.weightedVoteDetails.value,
              stream: bloc.weightedVoteDetails,
              builder: (context, snapshot) {
                final details = snapshot.data;

                if (details == null) {
                  return Container();
                }
                return Padding(
                  padding: EdgeInsets.symmetric(
                    horizontal: Spacing.large,
                  ),
                  child: PwButton(
                    enabled: details.abstainAmount +
                            details.noAmount +
                            details.noWithVetoAmount +
                            details.yesAmount ==
                        100,
                    onPressed: () {
                      Provider.of<ProposalsBloc>(context)
                          .showWeightedVoteReview(widget.proposal);
                    },
                    child: PwText(
                      Strings.of(context).continueName,
                      overflow: TextOverflow.fade,
                      softWrap: false,
                      color: PwColor.neutralNeutral,
                      style: PwTextStyle.body,
                    ),
                  ),
                );
              },
            ),
            VerticalSpacer.largeX3()
          ],
        ),
      ),
    );
  }
}
