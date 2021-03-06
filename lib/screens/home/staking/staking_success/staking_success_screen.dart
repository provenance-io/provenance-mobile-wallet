import 'package:provenance_wallet/common/pw_design.dart';
import 'package:provenance_wallet/common/widgets/button.dart';
import 'package:provenance_wallet/screens/home/staking/staking_delegation/staking_delegation_bloc.dart';
import 'package:provenance_wallet/screens/home/staking/staking_flow/staking_flow_bloc.dart';
import 'package:provenance_wallet/util/assets.dart';
import 'package:provenance_wallet/util/get.dart';
import 'package:provenance_wallet/util/strings.dart';

class StakingSuccessScreen extends StatelessWidget {
  const StakingSuccessScreen({
    Key? key,
    required this.selected,
  }) : super(key: key);

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
                  Expanded(child: Container()),
                  PwText(
                    Strings.stakingSuccessSuccess.toUpperCase(),
                    style: PwTextStyle.headline2,
                    textAlign: TextAlign.center,
                    softWrap: false,
                    overflow: TextOverflow.fade,
                  ),
                  VerticalSpacer.large(),
                  PwText(
                    Strings.stakingSuccessSuccessful(
                      selected.dropDownTitle,
                    ),
                    style: PwTextStyle.body,
                    textAlign: TextAlign.center,
                  ),
                  VerticalSpacer.largeX3(),
                  Image.asset(
                    Assets.imagePaths.transactionComplete,
                    height: 80,
                    width: 80,
                  ),
                  Expanded(child: Container()),
                  PwButton(
                    child: PwText(
                      Strings.continueName,
                      style: PwTextStyle.bodyBold,
                      textAlign: TextAlign.center,
                    ),
                    onPressed: () {
                      get<StakingFlowBloc>().onComplete();
                    },
                  ),
                  Padding(
                    padding: EdgeInsets.only(
                      top: Spacing.large,
                      bottom: Spacing.largeX4,
                    ),
                    child: PwTextButton(
                      child: PwText(
                        Strings.stakingSuccessBackToDashboard,
                        style: PwTextStyle.body,
                        textAlign: TextAlign.center,
                        color: PwColor.neutralNeutral,
                      ),
                      onPressed: () {
                        get<StakingFlowBloc>().backToDashboard();
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
