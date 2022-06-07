import 'package:provenance_wallet/common/pw_design.dart';
import 'package:provenance_wallet/common/widgets/pw_app_bar.dart';
import 'package:provenance_wallet/screens/home/explorer/staking_flow.dart';
import 'package:provenance_wallet/util/strings.dart';

class StakingTransactionDataScreen extends StatelessWidget {
  const StakingTransactionDataScreen({
    Key? key,
    required this.data,
    required this.navigator,
  }) : super(key: key);
  final String data;
  final StakingFlowNavigator navigator;

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
