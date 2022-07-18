import 'package:provenance_wallet/common/pw_design.dart';
import 'package:provenance_wallet/util/strings.dart';

class ProposalVoteChip extends StatelessWidget {
  final String vote;
  final EdgeInsets? margin;
  const ProposalVoteChip({
    Key? key,
    required this.vote,
    this.margin,
  }) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return Container(
      margin: margin ??
          EdgeInsets.only(
            left: Spacing.large,
          ),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.neutral600,
        borderRadius: BorderRadius.all(Radius.circular(20)),
      ),
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 8, vertical: 2),
        child: PwText(
          Strings.proposalsScreenVoted(
            vote,
          ),
          style: PwTextStyle.footnote,
          color: PwColor.neutral150,
        ),
      ),
    );
  }
}
