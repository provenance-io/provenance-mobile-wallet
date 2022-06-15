import 'package:provenance_wallet/common/pw_design.dart';
import 'package:provenance_wallet/screens/home/explorer/proposals/proposal_details_screen.dart';
import 'package:provenance_wallet/services/models/proposal.dart';
import 'package:provenance_wallet/services/models/vote.dart';

class ProposalListItem extends StatelessWidget {
  const ProposalListItem({Key? key, required this.item, this.vote})
      : super(key: key);

  final Proposal item;
  final Vote? vote;
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () async {
        // TODO: Navigate to ProposalDetails
        final now = DateTime.now().toUtc();
        print("Now: $now");
        print("StartTime: ${item.startTime}");
        print("EndTime: ${item.endTime}");
        print("StartTime is in past: ${now.compareTo(item.startTime) == 1}");
        print(
            "EndTime has been reached: ${now.compareTo(item.startTime) == 1}");
        print("-------------------------------------------------------");
        Navigator.of(context).push(
          ProposalDetailsScreen(selectedProposal: item).route(),
        );
      },
      child: Padding(
        padding: EdgeInsets.zero,
        child: Container(
          padding: EdgeInsets.all(20),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (vote != null)
                      Row(
                        children: [
                          Flexible(
                            child: PwText(
                              "${item.proposalId} ${item.title}",
                              style: PwTextStyle.bodyBold,
                              overflow: TextOverflow.fade,
                              color: PwColor.neutralNeutral,
                              softWrap: false,
                            ),
                          ),
                          Container(
                            margin: EdgeInsets.only(
                              left: Spacing.large,
                            ),
                            child: Chip(
                              label: PwText(
                                "Voted ${vote!.formattedVote}",
                                style: PwTextStyle.footnote,
                                color: PwColor.primaryP500,
                              ),
                              side: BorderSide(
                                color: Theme.of(context).colorScheme.primary550,
                              ),
                            ),
                          ),
                        ],
                      ),
                    if (vote == null)
                      PwText(
                        "${item.proposalId} ${item.title}",
                        style: PwTextStyle.bodyBold,
                        overflow: TextOverflow.fade,
                        softWrap: false,
                      ),
                    VerticalSpacer.xSmall(),
                    SizedBox(
                      width: 180,
                      child: PwText(
                        item.status,
                        color: PwColor.neutral200,
                        style: PwTextStyle.footnote,
                        overflow: TextOverflow.fade,
                        softWrap: false,
                      ),
                    ),
                  ],
                ),
              ),
              Padding(
                padding: EdgeInsets.only(left: 16),
                child: PwIcon(
                  PwIcons.caret,
                  color: Theme.of(context).colorScheme.neutralNeutral,
                  size: 12.0,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
