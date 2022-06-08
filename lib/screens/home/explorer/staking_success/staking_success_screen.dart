import 'package:provenance_wallet/common/pw_design.dart';
import 'package:provenance_wallet/common/widgets/button.dart';
import 'package:provenance_wallet/screens/home/explorer/staking_delegation/staking_delegation_bloc.dart';
import 'package:provenance_wallet/screens/home/explorer/staking_flow/staking_flow.dart';
import 'package:provenance_wallet/util/assets.dart';
import 'package:provenance_wallet/util/strings.dart';

class StakingSuccessScreen extends StatelessWidget {
  const StakingSuccessScreen({
    Key? key,
    required this.navigator,
    required this.selected,
  }) : super(key: key);

  final StakingFlowNavigator navigator;
  final SelectedDelegationType selected;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          image: DecorationImage(
            image: AssetImage(Assets.imagePaths.background),
            fit: BoxFit.cover,
            alignment: Alignment.topCenter,
          ),
        ),
        padding: EdgeInsets.symmetric(
          horizontal: Spacing.large,
        ),
        child: CustomScrollView(
          slivers: [
            SliverFillRemaining(
              hasScrollBody: false,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  VerticalSpacer.custom(
                    spacing: 110,
                  ),
                  Image.asset(
                    Assets.imagePaths.transactionComplete,
                    height: 80,
                    width: 80,
                  ),
                  VerticalSpacer.medium(),
                  PwText(
                    Strings.stakingSuccessSuccess,
                    style: PwTextStyle.display2,
                    textAlign: TextAlign.center,
                  ),
                  VerticalSpacer.medium(),
                  PwText(
                    Strings.stakingSuccessSuccessful(
                      selected.dropDownTitle,
                    ),
                    style: PwTextStyle.displayBody,
                  ),
                  Expanded(child: Container()),
                  Padding(
                    padding: EdgeInsets.only(
                        left: 20, right: 20, bottom: Spacing.largeX4),
                    child: PwButton(
                      child: PwText(
                        Strings.sendDone,
                        style: PwTextStyle.bodyBold,
                      ),
                      onPressed: () {
                        navigator.onComplete();
                      },
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
