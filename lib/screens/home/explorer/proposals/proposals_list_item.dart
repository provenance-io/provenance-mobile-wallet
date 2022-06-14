import 'package:provenance_wallet/common/pw_design.dart';
import 'package:provenance_wallet/services/models/proposal.dart';

class ProposalListItem extends StatelessWidget {
  const ProposalListItem({
    Key? key,
    required this.item,
  }) : super(key: key);

  final Proposal item;
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () async {
        // TODO: Navigate to ProposalDetails
      },
      child: Padding(
        padding: EdgeInsets.zero,
        child: Container(
          padding: EdgeInsets.all(20),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  PwText(
                    "${item.proposalId}. ${item.title}",
                    style: PwTextStyle.bodyBold,
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
              Expanded(child: Container()),
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
