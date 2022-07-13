import 'package:provenance_dart/proto_gov.dart' as gov;
import 'package:provenance_wallet/common/pw_design.dart';
import 'package:provenance_wallet/common/widgets/button.dart';
import 'package:provenance_wallet/common/widgets/pw_list_divider.dart';
import 'package:provenance_wallet/screens/home/proposals/proposals_flow_bloc.dart';
import 'package:provenance_wallet/services/models/proposal.dart';
import 'package:provenance_wallet/util/get.dart';
import 'package:provenance_wallet/util/strings.dart';

class VotingButtons extends StatelessWidget {
  const VotingButtons({
    Key? key,
    required this.proposal,
  }) : super(key: key);

  final Proposal proposal;
  @override
  Widget build(BuildContext context) {
    final _bloc = get<ProposalsFlowBloc>();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        PwListDivider(
          indent: Spacing.largeX3,
        ),
        Padding(
          padding: EdgeInsets.symmetric(
            horizontal: Spacing.largeX3,
            vertical: Spacing.xLarge,
          ),
          child: PwText(
            Strings.proposalDetailsProposalVoting,
            style: PwTextStyle.title,
          ),
        ),
        PwListDivider(
          indent: Spacing.largeX3,
        ),
        Padding(
          padding: EdgeInsets.only(
            left: Spacing.largeX3,
            right: Spacing.largeX3,
            top: Spacing.xLarge,
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Flexible(
                child: PwButton(
                  onPressed: () {
                    _bloc.showVoteReview(
                      proposal,
                      gov.VoteOption.VOTE_OPTION_YES,
                    );
                  },
                  child: PwText(
                    Strings.proposalDetailsYes,
                    overflow: TextOverflow.fade,
                    softWrap: false,
                    color: PwColor.neutralNeutral,
                    style: PwTextStyle.body,
                  ),
                ),
              ),
              HorizontalSpacer.large(),
              Flexible(
                child: PwButton(
                  onPressed: () {
                    _bloc.showVoteReview(
                      proposal,
                      gov.VoteOption.VOTE_OPTION_NO,
                    );
                  },
                  child: PwText(
                    Strings.proposalDetailsNo,
                    overflow: TextOverflow.fade,
                    softWrap: false,
                    color: PwColor.neutralNeutral,
                    style: PwTextStyle.body,
                  ),
                ),
              )
            ],
          ),
        ),
        Padding(
          padding: EdgeInsets.symmetric(
            horizontal: Spacing.largeX3,
            vertical: Spacing.xLarge,
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Flexible(
                child: PwButton(
                  onPressed: () {
                    _bloc.showVoteReview(
                      proposal,
                      gov.VoteOption.VOTE_OPTION_NO_WITH_VETO,
                    );
                  },
                  child: PwText(
                    Strings.proposalDetailsNoWithVeto,
                    overflow: TextOverflow.fade,
                    softWrap: false,
                    color: PwColor.neutralNeutral,
                    style: PwTextStyle.body,
                  ),
                ),
              ),
              HorizontalSpacer.large(),
              Flexible(
                child: PwButton(
                  onPressed: () {
                    _bloc.showVoteReview(
                      proposal,
                      gov.VoteOption.VOTE_OPTION_ABSTAIN,
                    );
                  },
                  child: PwText(
                    Strings.proposalDetailsAbstain,
                    overflow: TextOverflow.fade,
                    softWrap: false,
                    color: PwColor.neutralNeutral,
                    style: PwTextStyle.body,
                  ),
                ),
              )
            ],
          ),
        ),
        Padding(
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
                  onPressed: () {
                    _bloc.showWeightedVote(proposal);
                  },
                  child: PwText(
                    Strings.proposalWeightedVote,
                    overflow: TextOverflow.fade,
                    softWrap: false,
                    color: PwColor.neutralNeutral,
                    style: PwTextStyle.body,
                  ),
                ),
              )
            ],
          ),
        ),
        HorizontalSpacer.largeX3(),
      ],
    );
  }
}
