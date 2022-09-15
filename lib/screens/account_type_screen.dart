import 'package:provenance_wallet/common/enum/account_add_kind.dart';
import 'package:provenance_wallet/common/pw_design.dart';
import 'package:provenance_wallet/common/widgets/pw_app_bar.dart';
import 'package:provenance_wallet/screens/account_button.dart';
import 'package:provenance_wallet/screens/add_account_flow_bloc.dart';
import 'package:provenance_wallet/util/strings.dart';

class AccountTypeScreen extends StatelessWidget {
  const AccountTypeScreen({
    required this.bloc,
    required this.includeMultiSig,
    Key? key,
  }) : super(key: key);

  static final keyBasicAccountButton =
      ValueKey('$AccountTypeScreen.basic_button');
  static final keyRecoverAccountButton =
      ValueKey('$AccountTypeScreen.recover_account_button');

  final bool includeMultiSig;
  final AddAccountFlowBloc bloc;

  @override
  Widget build(BuildContext context) {
    final strings = Strings.of(context);

    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: PwAppBar(
        title: strings.accountTypeTitle,
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
                      key: keyBasicAccountButton,
                      name: strings.accountTypeOptionBasicName,
                      desc: strings.accountTypeOptionBasicDesc,
                      onPressed: () {
                        bloc.submitAccountType(
                          AccountAddKind.createSingle,
                        );
                      },
                    ),
                    VerticalSpacer.large(),
                    AccountButton(
                      key: keyRecoverAccountButton,
                      name: strings.accountTypeOptionImportName,
                      desc: strings.accountTypeOptionImportDesc,
                      onPressed: () {
                        bloc.submitAccountType(
                          AccountAddKind.recover,
                        );
                      },
                    ),
                    if (includeMultiSig)
                      Container(
                        margin: EdgeInsets.only(
                          top: Spacing.large,
                        ),
                        child: AccountButton(
                          name: strings.accountTypeOptionMultiName,
                          desc: strings.accountTypeOptionMultiDesc,
                          onPressed: () {
                            bloc.submitAccountType(
                              AccountAddKind.createMulti,
                            );
                          },
                        ),
                      ),
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
