import 'package:provenance_wallet/common/pw_design.dart';
import 'package:provenance_wallet/common/widgets/button.dart';
import 'package:provenance_wallet/screens/multi_sig/multi_sig_invite_review_flow.dart';
import 'package:provenance_wallet/util/assets.dart';
import 'package:provenance_wallet/util/get.dart';
import 'package:provenance_wallet/util/strings.dart';
import 'package:url_launcher/url_launcher.dart';

class MultiSigInviteReviewLanding extends StatelessWidget {
  const MultiSigInviteReviewLanding({
    required this.name,
    Key? key,
  }) : super(key: key);

  final String name;

  @override
  Widget build(BuildContext context) {
    return Material(
      child: Container(
        decoration: BoxDecoration(
          image: DecorationImage(
            image: AssetImage(Assets.imagePaths.background),
            fit: BoxFit.cover,
            alignment: Alignment.topCenter,
          ),
        ),
        child: CustomScrollView(
          slivers: [
            SliverFillRemaining(
              hasScrollBody: false,
              child: Column(
                children: [
                  Expanded(
                    child: SizedBox(),
                  ),
                  Container(
                    margin: EdgeInsets.symmetric(
                      horizontal: Spacing.large,
                    ),
                    child: Column(
                      children: [
                        PwIcon(
                          PwIcons.provenance,
                          color: Theme.of(context).colorScheme.logo,
                        ),
                        VerticalSpacer.largeX3(),
                        PwText(
                          Strings.of(context).appName,
                          style: PwTextStyle.headline2,
                          color: PwColor.neutralNeutral,
                          textAlign: TextAlign.center,
                        ),
                        VerticalSpacer.largeX3(),
                        PwText(
                          Strings.of(context).multiSigInviteReviewLandingDesc(
                            name,
                          ),
                          style: PwTextStyle.body,
                          color: PwColor.neutralNeutral,
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),
                  Expanded(
                    child: SizedBox(),
                  ),
                  Container(
                    margin: EdgeInsets.symmetric(
                      horizontal: Spacing.large,
                    ),
                    child: Column(
                      children: [
                        PwTextButton.primaryAction(
                          context: context,
                          text: Strings.of(context)
                              .multiSigInviteReviewDetailsTitle,
                          onPressed: () {
                            get<MultiSigInviteReviewFlowNavigator>()
                                .showReviewInvitationDetails();
                          },
                        ),
                        VerticalSpacer.large(),
                        PwTextButton.secondaryAction(
                          context: context,
                          text: Strings.of(context)
                              .multiSigInviteReviewLandingLearnMoreButton,
                          onPressed: () async {
                            const url = 'https://provenance.io';
                            if (await canLaunch(url)) {
                              launch(url);
                            }
                          },
                        ),
                      ],
                    ),
                  ),
                  VerticalSpacer.largeX4(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
