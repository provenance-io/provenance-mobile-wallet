import 'package:provenance_wallet/common/pw_design.dart';
import 'package:provenance_wallet/common/widgets/pw_app_bar.dart';
import 'package:provenance_wallet/screens/account_button.dart';
import 'package:provenance_wallet/screens/add_account_flow_bloc.dart';
import 'package:provenance_wallet/screens/multi_sig/multi_sig_add_kind.dart';
import 'package:provenance_wallet/util/strings.dart';

class MultiSigCreateOrJoinScreen extends StatelessWidget {
  const MultiSigCreateOrJoinScreen({
    required this.bloc,
    Key? key,
  }) : super(key: key);

  static final keyJoinMultiSig =
      ValueKey('$MultiSigCreateOrJoinScreen.join_button');

  final AddAccountFlowBloc bloc;

  @override
  Widget build(BuildContext context) {
    final strings = Strings.of(context);
    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: PwAppBar(
        title: strings.accountTypeMultiSigTitle,
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
                  horizontal: Spacing.xxLarge,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    VerticalSpacer.largeX3(),
                    PwText(
                      strings.accountTypeMultiSigDesc,
                      style: PwTextStyle.body,
                      color: PwColor.neutralNeutral,
                    ),
                    VerticalSpacer.largeX3(),
                    AccountButton(
                      name: strings.accountTypeMultiSigCreateName,
                      desc: strings.accountTypeMultiSigCreateDesc,
                      onPressed: () {
                        bloc.submitMultiSigCreateOrJoin(MultiSigAddKind.create);
                      },
                    ),
                    VerticalSpacer.large(),
                    AccountButton(
                      name: strings.accountTypeMultiSigJoinName,
                      desc: strings.accountTypeMultiSigJoinDesc,
                      onPressed: () {
                        bloc.submitMultiSigCreateOrJoin(MultiSigAddKind.join);
                      },
                    ),
                    VerticalSpacer.large(),
                    AccountButton(
                        name: strings.accountTypeMultiSigRecoverName,
                        desc: strings.accountTypeMultiSigRecoverDesc,
                        onPressed: () {
                          bloc.submitMultiSigCreateOrJoin(
                              MultiSigAddKind.recover);
                        }),
                    StreamBuilder<String?>(
                      stream: bloc.multiSigInviteLinkError,
                      builder: (context, snapshot) {
                        final error = snapshot.data;
                        if (error == null) {
                          return Container();
                        }

                        return Container(
                          margin: EdgeInsets.only(
                            top: Spacing.large,
                          ),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              PwIcon(
                                PwIcons.warnCircle,
                                color:
                                    Theme.of(context).colorScheme.negative350,
                              ),
                              HorizontalSpacer.xSmall(),
                              Expanded(
                                child: PwText(
                                  error,
                                  color: PwColor.negative350,
                                  style: PwTextStyle.body,
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                    Expanded(
                      child: SizedBox(),
                    ),
                    TextButton(
                      onPressed: () {
                        bloc.submitMultiSigCreateOrJoin(MultiSigAddKind.link);
                      },
                      child: Container(
                        padding: EdgeInsets.all(
                          Spacing.medium,
                        ),
                        child: PwText(
                          strings.accountTypeMultiSigJoinLink,
                          style: PwTextStyle.body,
                          textAlign: TextAlign.center,
                          underline: true,
                        ),
                      ),
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
