import 'package:provenance_wallet/common/pw_design.dart';
import 'package:provenance_wallet/common/widgets/button.dart';
import 'package:provenance_wallet/screens/home/staking/staking_delegation/staking_delegation_bloc.dart';
import 'package:provenance_wallet/screens/home/staking/staking_flow/staking_flow_bloc.dart';
import 'package:provenance_wallet/util/assets.dart';
import 'package:provenance_wallet/util/get.dart';
import 'package:provenance_wallet/util/strings.dart';

class StakingCompleteScreen extends StatelessWidget {
  const StakingCompleteScreen({
    Key? key,
    required this.selected,
    required this.response,
  }) : super(key: key);

  final SelectedDelegationType selected;
  final Object? response;

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
                  Align(
                    alignment: Alignment.topLeft,
                    child: IconButton(
                      color: Theme.of(context).colorScheme.neutralNeutral,
                      icon: PwIcon(
                        PwIcons.back,
                      ),
                      onPressed: () {
                        Navigator.of(context).pop();
                      },
                    ),
                  ),
                  Expanded(child: Container()),
                  PwText(
                    selected.getCompletionMessage(context),
                    style: PwTextStyle.headline2,
                    textAlign: TextAlign.center,
                    softWrap: false,
                    overflow: TextOverflow.fade,
                  ),
                  VerticalSpacer.large(),
                  PwTextButton(
                      child: PwText(
                        Strings.of(context).stakingCompleteTapToSeeResponse,
                        style: PwTextStyle.body,
                        textAlign: TextAlign.center,
                      ),
                      onPressed: () {
                        get<StakingFlowBloc>().showTransactionData(response);
                      }),
                  VerticalSpacer.largeX3(),
                  Image.asset(
                    Assets.imagePaths.transactionComplete,
                    height: 80,
                    width: 80,
                  ),
                  Expanded(child: Container()),
                  PwButton(
                    child: PwText(
                      Strings.of(context).continueName,
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
                        Strings.of(context).stakingCompleteBackToDashboard,
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
