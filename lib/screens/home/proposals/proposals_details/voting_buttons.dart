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
        PwListDivider.alternate(
          indent: Spacing.large,
        ),
        Padding(
          padding: EdgeInsets.only(
            left: Spacing.large,
            right: Spacing.large,
            top: Spacing.large,
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Flexible(
                child: PwOutlinedButton(
                  Strings.proposalDetailsYes,
                  onPressed: () {
                    _bloc.showVoteReview(
                      proposal,
                      gov.VoteOption.VOTE_OPTION_YES,
                    );
                  },
                  fpTextColor: PwColor.neutralNeutral,
                  fpTextStyle: PwTextStyle.bodyBold,
                ),
              ),
              HorizontalSpacer.large(),
              Flexible(
                child: PwOutlinedButton(
                  Strings.proposalDetailsNo,
                  onPressed: () {
                    _bloc.showVoteReview(
                      proposal,
                      gov.VoteOption.VOTE_OPTION_NO,
                    );
                  },
                  fpTextColor: PwColor.neutralNeutral,
                  fpTextStyle: PwTextStyle.bodyBold,
                ),
              )
            ],
          ),
        ),
        Padding(
          padding: EdgeInsets.all(
            Spacing.large,
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Flexible(
                child: PwOutlinedButton(
                  Strings.proposalDetailsNoWithVeto,
                  onPressed: () {
                    _bloc.showVoteReview(
                      proposal,
                      gov.VoteOption.VOTE_OPTION_NO_WITH_VETO,
                    );
                  },
                  fpTextColor: PwColor.neutralNeutral,
                  fpTextStyle: PwTextStyle.bodyBold,
                ),
              ),
              HorizontalSpacer.large(),
              Flexible(
                child: PwOutlinedButton(
                  Strings.proposalDetailsAbstain,
                  onPressed: () {
                    _bloc.showVoteReview(
                      proposal,
                      gov.VoteOption.VOTE_OPTION_ABSTAIN,
                    );
                  },
                  fpTextColor: PwColor.neutralNeutral,
                  fpTextStyle: PwTextStyle.bodyBold,
                ),
              )
            ],
          ),
        ),
        Padding(
          padding: EdgeInsets.only(
            left: Spacing.large,
            right: Spacing.large,
            bottom: Spacing.largeX3,
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Flexible(
                child: PwTextButton(
                  onPressed: () {
                    _bloc.showWeightedVote(proposal);
                  },
                  child: PwText(
                    Strings.proposalWeightedVote,
                    overflow: TextOverflow.fade,
                    softWrap: false,
                    color: PwColor.neutralNeutral,
                    style: PwTextStyle.bodyBold,
                  ),
                ),
              )
            ],
          ),
        ),
      ],
    );
  }
}
