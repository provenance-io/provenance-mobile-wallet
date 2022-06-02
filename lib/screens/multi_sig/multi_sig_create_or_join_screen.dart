import 'package:provenance_wallet/common/pw_design.dart';
import 'package:provenance_wallet/common/widgets/pw_app_bar.dart';
import 'package:provenance_wallet/screens/account_button.dart';
import 'package:provenance_wallet/screens/add_account_flow_bloc.dart';
import 'package:provenance_wallet/screens/multi_sig/multi_sig_add_kind.dart';
import 'package:provenance_wallet/util/get.dart';
import 'package:provenance_wallet/util/strings.dart';

class MultiSigCreateOrJoinScreen extends StatelessWidget {
  MultiSigCreateOrJoinScreen({
    Key? key,
  }) : super(key: key);

  static final keyJoinMultiSig =
      ValueKey('$MultiSigCreateOrJoinScreen.join_button');

  final _bloc = get<AddAccountFlowBloc>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: PwAppBar(
        title: Strings.accountTypeMultiSigTitle,
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
                      Strings.accountTypeMultiSigDesc,
                      style: PwTextStyle.body,
                      color: PwColor.neutralNeutral,
                    ),
                    VerticalSpacer.largeX3(),
                    AccountButton(
                      name: Strings.accountTypeMultiSigCreateName,
                      desc: Strings.accountTypeMultiSigCreateDesc,
                      onPressed: () {
                        _bloc
                            .submitMultiSigCreateOrJoin(MultiSigAddKind.create);
                      },
                    ),
                    // TODO-Roy: Enable join multi-sig
                    //
                    // VerticalSpacer.large(),
                    // AccountTypeButton(
                    //   name: Strings.accountTypeMultiSigJoinName,
                    //   desc: Strings.accountTypeMultiSigJoinDesc,
                    //   onPressed: () {
                    //     _bloc.submitMultiSigCreateOrJoin(MultiSigAddKind.join);
                    //   },
                    // ),
                    VerticalSpacer.largeX3(),
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