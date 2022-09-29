import 'package:provenance_wallet/common/pw_design.dart';
import 'package:provenance_wallet/common/widgets/pw_app_bar.dart';
import 'package:provenance_wallet/screens/account_button.dart';
import 'package:provenance_wallet/screens/multi_sig/multi_sig_invite_review_flow_bloc.dart';
import 'package:provenance_wallet/util/strings.dart';
import 'package:provider/provider.dart';

class MultiSigInviteReviewCreateOrLinkScreen extends StatelessWidget {
  const MultiSigInviteReviewCreateOrLinkScreen({
    Key? key,
  }) : super(key: key);

  static final keyJoinMultiSig =
      ValueKey('$MultiSigInviteReviewCreateOrLinkScreen.join_button');

  @override
  Widget build(BuildContext context) {
    final bloc = Provider.of<MultiSigInviteReviewFlowBloc>(context);

    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: PwAppBar(
        title: Strings.of(context).multiSigInviteReviewCreateOrLinkTitle,
        leadingIcon: PwIcons.back,
      ),
      backgroundColor: Theme.of(context).colorScheme.neutral750,
      body: Container(
        color: Theme.of(context).colorScheme.neutral750,
        child: CustomScrollView(
          slivers: [
            SliverFillRemaining(
              hasScrollBody: false,
              child: Container(
                padding: EdgeInsets.symmetric(
                  horizontal: Spacing.large,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    VerticalSpacer.largeX3(),
                    AccountButton(
                      icon: PwIcons.account,
                      name: Strings.of(context)
                          .multiSigInviteReviewCreateOrLinkCreate,
                      desc: Strings.of(context)
                          .multiSigInviteReviewCreateOrLinkCreateDesc,
                      onPressed: () async {
                        await bloc.showCreateNewAccount();
                      },
                    ),
                    VerticalSpacer.large(),
                    AccountButton(
                      icon: PwIcons.link,
                      name: Strings.of(context)
                          .multiSigInviteReviewCreateOrLinkLinkExisting,
                      desc: Strings.of(context)
                          .multiSigInviteReviewCreateOrLinkLinkExistingDesc,
                      onPressed: () {
                        bloc.showLinkExistingAccount();
                      },
                    ),
                    VerticalSpacer.largeX4(),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
