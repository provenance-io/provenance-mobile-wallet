import 'package:provenance_wallet/common/pw_design.dart';
import 'package:provenance_wallet/common/widgets/pw_list_divider.dart';
import 'package:provenance_wallet/screens/home/proposals/proposals_screen/proposal_list_item_status.dart';
import 'package:provenance_wallet/screens/home/proposals/proposals_screen/proposal_vote_chip.dart';
import 'package:provenance_wallet/util/constants.dart';
import 'package:provenance_wallet/util/strings.dart';

class ProposalsLegend extends StatefulWidget {
  const ProposalsLegend({Key? key}) : super(key: key);

  @override
  State<ProposalsLegend> createState() => _ProposalsLegendState();
}

class _ProposalsLegendState extends State<ProposalsLegend> {
  bool _isActive = false;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(Spacing.large),
      margin: EdgeInsets.symmetric(horizontal: Spacing.large),
      decoration: BoxDecoration(
        border: Border.all(
          color: Theme.of(context).colorScheme.neutral700,
        ),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              PwText(
                Strings.proposalsScreenLegend,
                style: PwTextStyle.bodyBold,
              ),
              GestureDetector(
                  behavior: HitTestBehavior.opaque,
                  onTap: () async {
                    setState(() {
                      _isActive = !_isActive;
                    });
                  },
                  child: PwText(
                    _isActive
                        ? Strings.stakingDetailsViewLess
                        : Strings.viewMore,
                    color: PwColor.neutral200,
                    style: PwTextStyle.footnote,
                    underline: true,
                  )),
            ],
          ),
          if (_isActive) VerticalSpacer.large(),
          if (_isActive)
            Row(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: const [
                PwText(
                  "Global Status: ",
                  style: PwTextStyle.body,
                ),
                Padding(
                  padding: EdgeInsets.only(left: Spacing.large),
                  child: ProposalListItemStatus(status: passed),
                ),
                Padding(
                  padding: EdgeInsets.only(left: Spacing.large),
                  child: ProposalListItemStatus(status: rejected),
                ),
              ],
            ),
          if (_isActive) VerticalSpacer.large(),
          if (_isActive) PwListDivider.alternate(),
          if (_isActive) VerticalSpacer.large(),
          if (_isActive)
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                PwText(
                  Strings.proposalsScreenMyStatus,
                  style: PwTextStyle.body,
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: const [
                        ProposalVoteChip(
                          vote: Strings.proposalDetailsYes,
                          margin: EdgeInsets.only(bottom: Spacing.small),
                        ),
                        ProposalVoteChip(
                          vote:
                              "${Strings.proposalDetailsYes}, ${Strings.proposalDetailsAbstain}",
                          margin: EdgeInsets.only(
                              bottom: Spacing.small, left: Spacing.small),
                        ),
                      ],
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: const [
                        ProposalVoteChip(
                          vote: Strings.proposalDetailsNo,
                          margin: EdgeInsets.only(bottom: Spacing.small),
                        ),
                        ProposalVoteChip(
                          vote:
                              "${Strings.proposalDetailsNo}, ${Strings.proposalDetailsAbstain}",
                          margin: EdgeInsets.only(
                              bottom: Spacing.small, left: Spacing.small),
                        ),
                      ],
                    ),
                    ProposalVoteChip(
                      vote:
                          "${Strings.proposalDetailsNoWithVeto}, ${Strings.proposalDetailsAbstain}",
                      margin: EdgeInsets.only(bottom: Spacing.small),
                    ),
                    ProposalVoteChip(
                      vote: Strings.proposalDetailsNoWithVeto,
                      margin: EdgeInsets.only(bottom: Spacing.small),
                    ),
                  ],
                )
              ],
            ),
        ],
      ),
    );
  }
}
