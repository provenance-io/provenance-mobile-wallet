import 'package:provenance_wallet/common/pw_design.dart';
import 'package:provenance_wallet/services/models/vote.dart';
import 'package:provenance_wallet/util/strings.dart';

class ProposalVoteChip extends StatelessWidget {
  final Vote vote;
  final EdgeInsets? margin;
  const ProposalVoteChip({
    Key? key,
    required this.vote,
    this.margin,
  }) : super(key: key);
  @override
  Widget build(BuildContext context) {
    final strings = Strings.of(context);
    var answers = <String>[];
    if (vote.answerYes != null) {
      answers.add(strings.proposalDetailsYes);
    }
    if (vote.answerNo != null) {
      answers.add(strings.proposalDetailsNo);
    }
    if (vote.answerNoWithVeto != null) {
      answers.add(strings.proposalDetailsNoWithVeto);
    }
    if (vote.answerAbstain != null) {
      answers.add(strings.proposalDetailsAbstain);
    }
    final _vote = answers.join(", ");
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
          Strings.of(context).proposalsScreenVoted(
            _vote,
          ),
          style: PwTextStyle.footnote,
          color: PwColor.neutral150,
        ),
      ),
    );
  }
}
