import 'package:provenance_wallet/common/pw_design.dart';
import 'package:provenance_wallet/common/widgets/button.dart';
import 'package:provenance_wallet/common/widgets/pw_app_bar.dart';
import 'package:provenance_wallet/screens/home/explorer/proposals_flow/proposal_weighted_vote/weighted_vote_bloc.dart';
import 'package:provenance_wallet/screens/home/explorer/proposals_flow/proposal_weighted_vote/weighted_vote_sliders.dart';
import 'package:provenance_wallet/services/models/proposal.dart';
import 'package:provenance_wallet/util/get.dart';
import 'package:provenance_wallet/util/strings.dart';

class ProposalWeightedVoteScreen extends StatefulWidget {
  const ProposalWeightedVoteScreen({
    Key? key,
    required this.proposal,
  }) : super(key: key);

  final Proposal proposal;

  @override
  State<StatefulWidget> createState() => _ProposalDetailsScreenState();
}

class _ProposalDetailsScreenState extends State<ProposalWeightedVoteScreen> {
  late final WeightedVoteBloc _bloc;

  @override
  void initState() {
    _bloc = WeightedVoteBloc();
    get.registerSingleton<WeightedVoteBloc>(_bloc);
    super.initState();
  }

  @override
  void dispose() {
    get.unregister<WeightedVoteBloc>();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: PwAppBar(
        title: Strings.proposalWeightedVote,
        leadingIcon: PwIcons.back,
      ),
      body: Container(
        color: Theme.of(context).colorScheme.neutral750,
        child: ListView(
          children: [
            WeightedVoteSliders(),
            StreamBuilder<WeightedVoteDetails>(
              initialData: _bloc.weightedVoteDetails.value,
              stream: _bloc.weightedVoteDetails,
              builder: (context, snapshot) {
                final details = snapshot.data;

                if (details == null) {
                  return Container();
                }
                return Padding(
                  padding: EdgeInsets.only(
                    left: Spacing.largeX3,
                    right: Spacing.largeX3,
                    bottom: Spacing.largeX3,
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Flexible(
                        child: PwButton(
                          enabled: details.abstainAmount +
                                  details.noAmount +
                                  details.noWithVetoAmount +
                                  details.yesAmount ==
                              100,
                          onPressed: () {
                            // TODO: Submit weighted vote.
                          },
                          child: PwText(
                            Strings.continueName,
                            overflow: TextOverflow.fade,
                            softWrap: false,
                            color: PwColor.neutralNeutral,
                            style: PwTextStyle.body,
                          ),
                        ),
                      )
                    ],
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
