import 'package:provenance_dart/proto_gov.dart';
import 'package:provenance_wallet/common/pw_design.dart';
import 'package:provenance_wallet/common/widgets/pw_list_divider.dart';
import 'package:provenance_wallet/screens/home/transactions/details_item.dart';
import 'package:provenance_wallet/util/strings.dart';

class WeightedVoteOptionColumn extends StatelessWidget {
  final double voteAmount;
  final VoteOption option;

  const WeightedVoteOptionColumn({
    Key? key,
    required this.voteAmount,
    required this.option,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        DetailsItem(
          title: Strings.proposalVoteConfirmVoteOption,
          endChild: PwText(
            option.name,
            overflow: TextOverflow.fade,
            softWrap: false,
            color: PwColor.neutralNeutral,
            style: PwTextStyle.body,
          ),
        ),
        PwListDivider(
          indent: Spacing.largeX3,
        ),
        DetailsItem(
          title: Strings.proposalVoteConfirmWeight,
          endChild: PwText(
            "${voteAmount.toInt()}%",
            overflow: TextOverflow.fade,
            softWrap: false,
            color: PwColor.neutralNeutral,
            style: PwTextStyle.body,
          ),
        ),
        PwListDivider(
          indent: Spacing.largeX3,
        ),
      ],
    );
  }
}
