import 'package:provenance_wallet/common/pw_design.dart';
import 'package:provenance_wallet/common/widgets/button.dart';
import 'package:provenance_wallet/screens/home/proposals/proposals_flow_bloc.dart';
import 'package:provenance_wallet/util/assets.dart';
import 'package:provenance_wallet/util/get.dart';
import 'package:provenance_wallet/util/strings.dart';

class ProposalSuccessScreen extends StatelessWidget {
  const ProposalSuccessScreen({
    Key? key,
  }) : super(key: key);

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
                    Strings.proposalVoteSuccessSuccess,
                    style: PwTextStyle.headline2,
                    textAlign: TextAlign.center,
                    softWrap: false,
                    overflow: TextOverflow.fade,
                  ),
                  VerticalSpacer.large(),
                  PwText(
                    Strings.proposalVoteSuccessVoteSuccessful,
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
                      get<ProposalsFlowBloc>().onComplete();
                    },
                  ),
                  Padding(
                    padding: EdgeInsets.only(
                      top: Spacing.large,
                      bottom: Spacing.largeX4,
                    ),
                    child: PwTextButton(
                      child: PwText(
                        Strings.proposalVoteSuccessBackToDashboard,
                        style: PwTextStyle.body,
                        textAlign: TextAlign.center,
                        color: PwColor.neutralNeutral,
                      ),
                      onPressed: () {
                        get<ProposalsFlowBloc>().backToDashboard();
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
