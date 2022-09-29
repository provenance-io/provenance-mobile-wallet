import 'package:provenance_wallet/common/pw_design.dart';
import 'package:provenance_wallet/common/widgets/button.dart';
import 'package:provenance_wallet/screens/multi_sig/multi_sig_field.dart';
import 'package:provenance_wallet/screens/multi_sig/multi_sig_invite_review_flow_bloc.dart';
import 'package:provenance_wallet/util/strings.dart';
import 'package:provider/provider.dart';

class MultiSigInviteReviewDetails extends StatelessWidget {
  const MultiSigInviteReviewDetails({
    required this.name,
    required this.cosignerCount,
    required this.signaturesRequired,
    Key? key,
  }) : super(key: key);

  final String name;
  final int cosignerCount;
  final int signaturesRequired;

  @override
  Widget build(BuildContext context) {
    final bloc =
        Provider.of<MultiSigInviteReviewFlowBloc>(context, listen: false);

    const divider = Divider(
      thickness: 1,
    );

    return Scaffold(
      appBar: AppBar(
        leading: Padding(
          padding: EdgeInsets.only(left: 21),
          child: IconButton(
            icon: PwIcon(
              PwIcons.back,
            ),
            onPressed: () {
              Navigator.of(context).pop();
            },
          ),
        ),
        actions: [
          Container(
            padding: EdgeInsets.only(
              right: Spacing.large,
            ),
            child: PwTextButton.shrinkWrap(
              child: PwText(
                Strings.of(context).multiSigInviteReviewDetailsDeclineButton,
                style: PwTextStyle.body,
                color: PwColor.primaryP500,
                textAlign: TextAlign.end,
              ),
              onPressed: () async {
                await bloc.declineInvite();
              },
            ),
          ),
        ],
        backgroundColor: Theme.of(context).colorScheme.neutral750,
        elevation: 0.0,
        centerTitle: false,
      ),
      body: CustomScrollView(
        slivers: [
          SliverFillRemaining(
            hasScrollBody: false,
            child: Column(
              children: [
                VerticalSpacer.largeX4(),
                Container(
                  margin: EdgeInsets.symmetric(
                    horizontal: Spacing.large,
                  ),
                  child: Column(
                    children: [
                      PwText(
                        Strings.of(context).multiSigInviteReviewDetailsTitle,
                        color: PwColor.neutralNeutral,
                        style: PwTextStyle.title,
                        textAlign: TextAlign.center,
                      ),
                      VerticalSpacer.small(),
                      PwText(
                        Strings.of(context).multiSigInviteReviewDetailsDesc,
                        color: PwColor.neutralNeutral,
                        style: PwTextStyle.body,
                        textAlign: TextAlign.center,
                      ),
                      VerticalSpacer.largeX4(),
                      MultiSigField(
                        name:
                            Strings.of(context).multiSigConfirmAccountNameLabel,
                        value: name,
                      ),
                      divider,
                      MultiSigField(
                        name: Strings.of(context).multiSigConfirmCosignersLabel,
                        value: cosignerCount.toString(),
                      ),
                      divider,
                      MultiSigField(
                        name:
                            Strings.of(context).multiSigConfirmSignaturesLabel,
                        value: signaturesRequired.toString(),
                      ),
                      divider,
                    ],
                  ),
                ),
                VerticalSpacer.large(),
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
                            .multiSigInviteReviewDetailsChooseAccountButton,
                        onPressed: () {
                          bloc.showChooseAccount();
                        },
                      ),
                      VerticalSpacer.large(),
                      PwTextButton.secondaryAction(
                        context: context,
                        text: Strings.of(context)
                            .multiSigInviteReviewDetailsMaybeLaterButton,
                        onPressed: () {
                          bloc.submitMaybeLater();
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
    );
  }
}
