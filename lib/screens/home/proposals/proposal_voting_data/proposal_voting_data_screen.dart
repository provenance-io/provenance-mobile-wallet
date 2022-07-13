import 'package:provenance_wallet/common/pw_design.dart';
import 'package:provenance_wallet/common/widgets/pw_app_bar.dart';
import 'package:provenance_wallet/util/strings.dart';

class ProposalVotingDataScreen extends StatelessWidget {
  const ProposalVotingDataScreen({
    Key? key,
    required this.data,
  }) : super(key: key);
  final String data;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: PwAppBar(
        title: Strings.stakingConfirmData,
        leadingIcon: PwIcons.back,
      ),
      body: Stack(
        children: [
          Container(
            color: Theme.of(context).colorScheme.neutral750,
            child: Padding(
              padding: EdgeInsets.symmetric(
                horizontal: Spacing.largeX3,
                vertical: Spacing.xLarge,
              ),
              child: PwText(
                data,
              ),
            ),
          )
        ],
      ),
    );
  }
}
