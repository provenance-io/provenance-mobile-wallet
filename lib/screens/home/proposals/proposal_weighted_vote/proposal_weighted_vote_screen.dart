import 'package:provenance_wallet/common/pw_design.dart';
import 'package:provenance_wallet/common/widgets/button.dart';
import 'package:provenance_wallet/common/widgets/pw_app_bar.dart';
import 'package:provenance_wallet/screens/home/proposals/proposal_weighted_vote/weighted_vote_bloc.dart';
import 'package:provenance_wallet/screens/home/proposals/proposal_weighted_vote/weighted_vote_sliders.dart';
import 'package:provenance_wallet/screens/home/proposals/proposals_flow_bloc.dart';
import 'package:provenance_wallet/services/models/account.dart';
import 'package:provenance_wallet/services/models/proposal.dart';
import 'package:provenance_wallet/util/get.dart';
import 'package:provenance_wallet/util/strings.dart';

class ProposalWeightedVoteScreen extends StatefulWidget {
  const ProposalWeightedVoteScreen({
    Key? key,
    required this.proposal,
    required this.account,
  }) : super(key: key);

  final Proposal proposal;
  final Account account;

  @override
  State<StatefulWidget> createState() => _ProposalDetailsScreenState();
}

class _ProposalDetailsScreenState extends State<ProposalWeightedVoteScreen> {
  late final WeightedVoteBloc _bloc;

  @override
  void initState() {
    _bloc = WeightedVoteBloc(
      widget.proposal,
      widget.account,
    );
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
          padding: EdgeInsets.symmetric(horizontal: Spacing.large),
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
                return Row(
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
                          get<ProposalsFlowBloc>()
                              .showWeightedVoteReview(widget.proposal);
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
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
