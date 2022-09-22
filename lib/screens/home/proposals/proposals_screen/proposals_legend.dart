import 'package:provenance_wallet/common/pw_design.dart';
import 'package:provenance_wallet/common/widgets/pw_list_divider.dart';
import 'package:provenance_wallet/screens/home/proposals/proposals_screen/proposal_list_item_status.dart';
import 'package:provenance_wallet/screens/home/proposals/proposals_screen/proposal_vote_chip.dart';
import 'package:provenance_wallet/services/models/vote.dart';
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
    final strings = Strings.of(context);

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
                strings.proposalsScreenLegend,
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
                        ? strings.stakingDetailsViewLess
                        : strings.viewMore,
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
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                PwText(
                  Strings.of(context).proposalsLegendGlobalStatus,
                  style: PwTextStyle.body,
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: const [
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
                    Padding(
                      padding: EdgeInsets.only(left: Spacing.large),
                      child: ProposalListItemStatus(status: depositPeriod),
                    ),
                    Padding(
                      padding: EdgeInsets.only(left: Spacing.large),
                      child: ProposalListItemStatus(status: votingPeriod),
                    ),
                    Padding(
                      padding: EdgeInsets.only(left: Spacing.large),
                      child: ProposalListItemStatus(status: vetoed),
                    ),
                  ],
                )
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
                  strings.proposalsScreenMyStatus,
                  style: PwTextStyle.body,
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        ProposalVoteChip(
                          vote: Vote.demo(answerYes: 1),
                          margin: EdgeInsets.only(bottom: Spacing.small),
                        ),
                        ProposalVoteChip(
                          vote: Vote.demo(
                            answerYes: 1,
                            answerAbstain: 1,
                          ),
                          margin: EdgeInsets.only(
                              bottom: Spacing.small, left: Spacing.small),
                        ),
                      ],
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        ProposalVoteChip(
                          vote: Vote.demo(
                            answerNo: 1,
                          ),
                          margin: EdgeInsets.only(bottom: Spacing.small),
                        ),
                        ProposalVoteChip(
                          vote: Vote.demo(
                            answerNo: 1,
                            answerAbstain: 1,
                          ),
                          margin: EdgeInsets.only(
                              bottom: Spacing.small, left: Spacing.small),
                        ),
                      ],
                    ),
                    ProposalVoteChip(
                      vote: Vote.demo(
                        answerNoWithVeto: 1,
                        answerAbstain: 1,
                      ),
                      margin: EdgeInsets.only(bottom: Spacing.small),
                    ),
                    ProposalVoteChip(
                      vote: Vote.demo(
                        answerNoWithVeto: 1,
                      ),
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
