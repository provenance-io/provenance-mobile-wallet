import 'package:provenance_wallet/common/pw_design.dart';
import 'package:provenance_wallet/screens/home/proposals/proposals_flow_bloc.dart';
import 'package:provenance_wallet/screens/home/proposals/proposals_screen/proposal_list_item_status.dart';
import 'package:provenance_wallet/services/models/proposal.dart';
import 'package:provenance_wallet/services/models/vote.dart';
import 'package:provenance_wallet/util/get.dart';
import 'package:provenance_wallet/util/strings.dart';

class ProposalListItem extends StatefulWidget {
  const ProposalListItem({
    Key? key,
    required this.item,
    this.vote,
  }) : super(key: key);

  final Proposal item;
  final Vote? vote;

  @override
  State<ProposalListItem> createState() => _ProposalListItemState();
}

class _ProposalListItemState extends State<ProposalListItem> {
  bool _isActive = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () async {
        get<ProposalsFlowBloc>().showProposalDetails(widget.item);
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
                    PwText(
                      "${widget.item.proposalId} ${widget.item.title}",
                      style: PwTextStyle.bodyBold,
                      overflow: TextOverflow.fade,
                      softWrap: false,
                    ),
                    if (widget.item.description.isNotEmpty)
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          if (!_isActive)
                            Flexible(
                              child: PwText(
                                widget.item.description,
                                style: PwTextStyle.footnote,
                                overflow: TextOverflow.ellipsis,
                                color: PwColor.neutral200,
                                softWrap: true,
                              ),
                            ),
                          if (_isActive)
                            Expanded(
                              child: PwText(
                                widget.item.description,
                                style: PwTextStyle.footnote,
                                color: PwColor.neutral200,
                                softWrap: true,
                              ),
                            ),
                          if (widget.item.description.length > 30)
                            GestureDetector(
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
                                softWrap: false,
                              ),
                            ),
                        ],
                      ),
                    VerticalSpacer.medium(),
                    ProposalListItemStatus(
                      status: widget.item.status,
                      vote: widget.vote,
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
