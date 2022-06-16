import 'package:provenance_wallet/common/pw_design.dart';
import 'package:provenance_wallet/common/widgets/button.dart';
import 'package:provenance_wallet/common/widgets/pw_list_divider.dart';
import 'package:provenance_wallet/util/strings.dart';

class VotingButtons extends StatelessWidget {
  const VotingButtons({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
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
                    // TODO: Voted yes
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
                    // TODO: Voted no
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
          padding: EdgeInsets.only(
            left: Spacing.largeX3,
            right: Spacing.largeX3,
            top: Spacing.large,
            bottom: Spacing.xLarge,
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Flexible(
                child: PwButton(
                  onPressed: () {
                    // TODO: Voted No with Veto
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
                    // TODO: Voted Abstain
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
      ],
    );
  }
}
