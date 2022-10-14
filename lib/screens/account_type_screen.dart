import 'package:provenance_wallet/common/pw_design.dart';
import 'package:provenance_wallet/common/widgets/pw_app_bar.dart';
import 'package:provenance_wallet/screens/account_button.dart';
import 'package:provenance_wallet/util/strings.dart';

enum AddAccountMethod {
  create,
  recover,
}

abstract class AccountTypeBloc {
  void submitBasic();
  void submitMultiSig();
}

class AccountTypeScreen extends StatelessWidget {
  const AccountTypeScreen({
    required AccountTypeBloc bloc,
    Key? key,
  })  : _bloc = bloc,
        super(key: key);

  static final keyBasicAccountButton =
      ValueKey('$AccountTypeScreen.basic_button');
  static final keyRecoverAccountButton =
      ValueKey('$AccountTypeScreen.recover_account_button');

  final AccountTypeBloc _bloc;

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
                      onPressed: () => _bloc.submitBasic(),
                    ),
                    VerticalSpacer.large(),
                    AccountButton(
                      name: strings.accountTypeOptionMultiName,
                      desc: strings.accountTypeOptionMultiDesc,
                      onPressed: () => _bloc.submitMultiSig(),
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
