import 'package:provenance_wallet/common/pw_design.dart';
import 'package:provenance_wallet/screens/home/proposals/proposals_screen/proposal_vote_chip.dart';
import 'package:provenance_wallet/screens/home/proposals/proposals_screen/proposals_bloc.dart';
import 'package:provenance_wallet/services/models/vote.dart';
import 'package:provenance_wallet/util/get.dart';
import 'package:provenance_wallet/util/strings.dart';

class ProposalListItemStatus extends StatelessWidget {
  final String status;
  final Vote? vote;

  const ProposalListItemStatus({
    Key? key,
    required this.status,
    this.vote,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(
          Icons.brightness_1,
          color: get<ProposalsBloc>().getColor(status, context),
          size: 8,
        ),
        HorizontalSpacer.xSmall(),
        PwText(
          status.capitalize(),
          color: PwColor.neutral200,
          style: PwTextStyle.footnote,
          overflow: TextOverflow.fade,
          softWrap: false,
        ),
        if (vote != null)
          ProposalVoteChip(
            vote: vote!,
          ),
      ],
    );
  }
}
